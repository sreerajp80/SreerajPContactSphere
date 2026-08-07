// lib/services/p2p_sync_service.dart
//
// Offline, LAN-based peer-to-peer sync of ContactSphere data between two phones
// running this app. Security comes from one decision: a fresh, high-entropy
// pairing code is generated per session, shown on the host (as text and a QR),
// and typed/scanned into the client OUT OF BAND — it never crosses the socket.
// Every frame after the salt is AES-GCM sealed with a key derived from that code
// (PBKDF2), so a wrong code derives a wrong key and decryption fails
// (authentication is a side effect of decryption; there is no fallback cipher).
//
// FLOW = connect-then-choose. The host binds a RANDOM port, and after a client
// authenticates it HOLDS the connection open. The sender then chooses what to
// share (a Full Sync or specific categories) and the payload is pushed on that
// action. The receiver keeps its own data and MERGES the payload add-only
// ("client wins"); id remapping and the merge live in [SyncBundleService]. See
// `plans/20260708_104631_p2p-sync-rearchitecture.md`.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import 'package:smart_contacts_dialer/services/sync_bundle_service.dart';

/// Thrown for any P2P failure that should surface as a plain message to the
/// user (bad code, timeout, oversize line, schema mismatch, …). Never contains
/// secret material.
class P2PException implements Exception {
  final String message;
  const P2PException(this.message);
  @override
  String toString() => message;
}

/// The single state that drives the whole sync UI. A [P2PSyncService] is a
/// [ChangeNotifier] holding one of these; the screens rebuild on change.
sealed class SyncState {
  const SyncState();
}

/// Nothing happening.
class SyncIdle extends SyncState {
  const SyncIdle();
}

/// Host is up. Shows [ipAddress] + [port] + the grouped [code] (and a QR built
/// from them) for the other phone. [clientConnected] flips true once a peer has
/// authenticated and the host is holding the connection open, waiting for the
/// sender to choose what to share.
class SyncHosting extends SyncState {
  final String ipAddress;
  final int port;
  final String code;
  final bool clientConnected;
  const SyncHosting(
    this.ipAddress,
    this.port,
    this.code, {
    this.clientConnected = false,
  });

  SyncHosting copyWith({bool? clientConnected}) => SyncHosting(
    ipAddress,
    port,
    code,
    clientConnected: clientConnected ?? this.clientConnected,
  );
}

/// Client is opening the socket to the host.
class SyncConnecting extends SyncState {
  const SyncConnecting();
}

/// Client is authenticated and waiting for the sender to pick what to share.
class SyncWaitingForSender extends SyncState {
  const SyncWaitingForSender();
}

/// Data is moving. [message] is a short human label; [fraction] is 0..1 when a
/// meaningful progress ratio is known, else null (indeterminate).
class SyncInProgress extends SyncState {
  final String message;
  final double? fraction;
  const SyncInProgress(this.message, {this.fraction});
}

/// Finished successfully. On the client [summary] describes what was merged in;
/// on the host it describes what was sent.
class SyncCompleted extends SyncState {
  final SyncSummary summary;
  final bool sent; // true = this phone sent (host), false = received (client)
  const SyncCompleted(this.summary, {required this.sent});
}

/// Something failed. [message] is safe to show to the user.
class SyncError extends SyncState {
  final String message;
  const SyncError(this.message);
}

class P2PSyncService extends ChangeNotifier {
  static final P2PSyncService _instance = P2PSyncService._internal();
  factory P2PSyncService() => _instance;
  P2PSyncService._internal();

  /// A fresh, non-singleton instance for tests, so a host and a client can run
  /// independently over loopback in one process.
  @visibleForTesting
  factory P2PSyncService.forTest() => P2PSyncService._internal();

  // --- Protocol / crypto constants (kept aligned with the guide) ---
  static const int _saltLen = 16;
  static const int _ivLen = 12; // AES-GCM nonce
  static const int _macLen = 16; // 128-bit GCM tag
  static const int _pbkdf2Iterations = 300000;
  static const int _pbkdf2KeyBits = 256;
  static const int _codeLen = 64;
  static const int codeGroup = 8; // display grouping (8-char chunks)
  static const String _alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  static const int _maxHandshakeLine = 4096;
  // Per-frame cap. Media frames are base64 of one file; base64 inflates ~4/3,
  // so this comfortably covers a large photo without allowing an OOM line.
  static const int _maxPayloadLine = 96 * 1024 * 1024;
  static const Duration _readTimeout = Duration(seconds: 30);
  static const Duration _connectTimeout = Duration(seconds: 6);
  // The sender may take a while to choose what to share after the peer connects;
  // the client waits this long for the META frame (distinct from the short
  // per-line handshake timeout).
  static const Duration _payloadWaitTimeout = Duration(minutes: 10);
  // Host stops hosting if no client authenticates within this window.
  static const Duration _hostIdleTimeout = Duration(seconds: 120);

  // --- QR out-of-band URI: contactspheresync://sync?v=1&ip=…&port=…&code=… ---
  static const String qrScheme = 'contactspheresync';
  static const String qrHost = 'sync';
  static const String qrVersion = '1';

  final Random _random = Random.secure();
  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _pbkdf2Iterations,
    bits: _pbkdf2KeyBits,
  );
  final AesGcm _gcm = AesGcm.with256bits();

  ServerSocket? _server;
  Timer? _idleTimer;
  bool _authenticated = false;
  bool _stopped = false;

  // Held-open client session (host side), populated after a peer authenticates.
  Socket? _activeSocket;
  SecretKey? _activeKey;
  _LineConn? _activeConn;

  SyncState _state = const SyncIdle();
  SyncState get state => _state;

  void _set(SyncState s) {
    _state = s;
    notifyListeners();
  }

  bool get isBusy =>
      _state is SyncHosting ||
      _state is SyncConnecting ||
      _state is SyncWaitingForSender ||
      _state is SyncInProgress;

  /// True once a peer has authenticated to the host and is waiting for the
  /// sender to choose. The send screen enables its "choose what to share"
  /// actions on this.
  bool get hasConnectedClient => _activeSocket != null;

  /// Resets to idle and tears down any host server / open socket. Safe to call
  /// at any time (e.g. when the user leaves the screen).
  Future<void> cancel() async {
    await _teardown();
    _set(const SyncIdle());
  }

  Future<void> _teardown() async {
    _stopped = true;
    _idleTimer?.cancel();
    _idleTimer = null;
    _authenticated = false;
    await _clearActive();
    final server = _server;
    _server = null;
    if (server != null) {
      try {
        await server.close();
      } catch (_) {}
    }
  }

  Future<void> _clearActive() async {
    final conn = _activeConn;
    _activeConn = null;
    if (conn != null) {
      try {
        await conn.dispose();
      } catch (_) {}
    }
    final socket = _activeSocket;
    _activeSocket = null;
    _activeKey = null;
    if (socket != null) {
      try {
        socket.destroy();
      } catch (_) {}
    }
  }

  // ===========================================================================
  // Crypto
  // ===========================================================================

  Uint8List _newSalt() =>
      Uint8List.fromList(List.generate(_saltLen, (_) => _random.nextInt(256)));

  /// Fresh ~320-bit pairing code (64 chars over a 31-symbol alphabet).
  String generatePairingCode() {
    final sb = StringBuffer();
    for (var i = 0; i < _codeLen; i++) {
      sb.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    return sb.toString();
  }

  /// Both sides normalize identically, so the hyphen-grouped displayed code
  /// matches what is typed (case + separators are irrelevant).
  static String normalizeCode(String input) {
    final upper = input.toUpperCase();
    final sb = StringBuffer();
    for (final ch in upper.split('')) {
      if (_alphabet.contains(ch)) sb.write(ch);
    }
    return sb.toString();
  }

  /// Groups the code into [codeGroup]-char chunks joined by '-', for display.
  static String groupCode(String code) {
    final chunks = <String>[];
    for (var i = 0; i < code.length; i += codeGroup) {
      chunks.add(code.substring(i, min(i + codeGroup, code.length)));
    }
    return chunks.join('-');
  }

  // --- QR out-of-band URI ---

  /// Builds the versioned pairing URI the host renders as a QR. The code is only
  /// moved OUT OF BAND (screen → camera); it is never sent over the socket.
  static String buildSyncUri({
    required String ip,
    required int port,
    required String code,
  }) => Uri(
    scheme: qrScheme,
    host: qrHost,
    queryParameters: {
      'v': qrVersion,
      'ip': ip,
      'port': port.toString(),
      'code': code,
    },
  ).toString();

  /// Strictly parses a scanned pairing URI. Returns null for anything that is
  /// not one of our current-version pairing QRs (wrong scheme/host/version,
  /// bad port, or empty code), so a foreign QR is rejected.
  static ({String ip, int port, String code})? parseSyncUri(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null) return null;
    if (uri.scheme != qrScheme || uri.host != qrHost) return null;
    if (uri.queryParameters['v'] != qrVersion) return null;
    final ip = uri.queryParameters['ip'] ?? '';
    final code = uri.queryParameters['code'] ?? '';
    final port = int.tryParse(uri.queryParameters['port'] ?? '');
    if (ip.isEmpty || code.isEmpty) return null;
    if (port == null || port < 1 || port > 65535) return null;
    return (ip: ip, port: port, code: code);
  }

  Future<SecretKey> _deriveKey(String code, List<int> salt) =>
      _pbkdf2.deriveKey(secretKey: SecretKey(utf8.encode(code)), nonce: salt);

  /// Encrypts raw bytes → a single base64 line of (IV ‖ ciphertext ‖ tag).
  Future<String> _encryptBytes(List<int> data, SecretKey key) async {
    final box = await _gcm.encrypt(data, secretKey: key);
    return base64.encode(box.concatenation());
  }

  /// Decrypts a base64 line back to bytes. Throws on tamper / wrong key, which
  /// callers treat as authentication failure.
  Future<Uint8List> _decryptBytes(String encoded, SecretKey key) async {
    final box = SecretBox.fromConcatenation(
      base64.decode(encoded),
      nonceLength: _ivLen,
      macLength: _macLen,
    );
    final clear = await _gcm.decrypt(box, secretKey: key);
    return Uint8List.fromList(clear);
  }

  Future<String> _encrypt(String data, SecretKey key) =>
      _encryptBytes(utf8.encode(data), key);

  Future<String> _decrypt(String encoded, SecretKey key) async =>
      utf8.decode(await _decryptBytes(encoded, key));

  /// Test hook: derive a key from [code]+[salt] and encrypt [data]. Exposes the
  /// otherwise-private crypto so tests can verify the round-trip and that a
  /// wrong code fails to decrypt.
  @visibleForTesting
  Future<String> debugEncrypt(String data, String code, List<int> salt) async =>
      _encrypt(data, await _deriveKey(code, salt));

  /// Test hook: counterpart to [debugEncrypt]. Throws on a wrong code (wrong key
  /// → GCM tag fails), which is exactly the authentication guarantee.
  @visibleForTesting
  Future<String> debugDecrypt(
    String encoded,
    String code,
    List<int> salt,
  ) async => _decrypt(encoded, await _deriveKey(code, salt));

  /// Decrypts [encoded] and compares to [expected]; false on any failure. Used
  /// so a wrong code (which throws on decrypt) reads as "not authenticated".
  Future<bool> _decryptEquals(
    String? encoded,
    SecretKey key,
    String expected,
  ) async {
    if (encoded == null) return false;
    try {
      return await _decrypt(encoded, key) == expected;
    } catch (_) {
      return false;
    }
  }

  // ===========================================================================
  // Host (sender: holds the connection open, then pushes the chosen payload)
  // ===========================================================================

  /// Starts hosting: binds a random port, shows IP + port + a fresh pairing
  /// code, and waits for a client to authenticate. Any prior server is torn
  /// down first. If no client authenticates within the idle window, hosting
  /// stops on its own.
  Future<void> startHost() async {
    await _teardown();
    _stopped = false;
    _authenticated = false;
    try {
      final code = generatePairingCode();
      final ip = await _localIpAddress();
      final server = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
      _server = server;
      _set(SyncHosting(ip, server.port, code));
      _idleTimer = Timer(_hostIdleTimeout, () {
        if (!_authenticated && !_stopped) {
          _teardown();
          _set(
            const SyncError(
              'No other phone connected in time. Tap Start to try again.',
            ),
          );
        }
      });
      server.listen(
        (socket) => _handleHostConnection(socket, code),
        onError: (e) {
          if (!_stopped) _set(SyncError('Server error: $e'));
        },
      );
    } catch (e) {
      await _teardown();
      _set(SyncError('Could not start hosting: $e'));
    }
  }

  Future<void> _handleHostConnection(Socket socket, String code) async {
    // Serve a single client at a time; drop extra connections.
    if (_activeSocket != null || _authenticated) {
      try {
        socket.destroy();
      } catch (_) {}
      return;
    }
    final conn = _LineConn(socket);
    try {
      // 0. Per-session salt in clear, then derive the key.
      final salt = _newSalt();
      await conn.writeLine(base64.encode(salt));
      final key = await _deriveKey(code, salt);

      // 1. Authenticated greeting. Wrong code → wrong key → decrypt fails.
      final greeting = await conn
          .readLine(_maxHandshakeLine)
          .timeout(_readTimeout);
      if (!await _decryptEquals(greeting, key, 'HELLO_SYNC')) {
        try {
          await conn.writeLine(await _encrypt('DENIED', key));
        } catch (_) {}
        await conn.dispose();
        try {
          socket.destroy();
        } catch (_) {}
        return; // stay hosting so the user can retry with the right code
      }

      // 2. Authenticated: acknowledge NOW and HOLD the connection open. The
      //    sender picks what to share; the payload is pushed later.
      _authenticated = true;
      _idleTimer?.cancel();
      _idleTimer = null;
      await conn.writeLine(await _encrypt('ACCEPT_SYNC', key));

      _activeSocket = socket;
      _activeKey = key;
      _activeConn = conn;
      // Notice the peer dropping while we wait for the sender to choose.
      unawaited(conn.closed.then((_) => _handleClientDrop()));
      _set((_state as SyncHosting).copyWith(clientConnected: true));
    } catch (_) {
      // Pre-auth transport error; keep listening quietly.
      try {
        await conn.dispose();
      } catch (_) {}
      try {
        socket.destroy();
      } catch (_) {}
    }
  }

  void _handleClientDrop() {
    if (_stopped || _activeSocket == null) return; // ignore our own teardown
    _authenticated = false;
    _clearActive();
    final s = _state;
    if (s is SyncHosting) {
      _set(s.copyWith(clientConnected: false));
    } else if (s is! SyncCompleted) {
      _set(const SyncError('The other phone disconnected.'));
    }
  }

  /// Sends a Full Sync (every category; settings overwrite) to the connected
  /// client. For a brand-new phone this reproduces the old whole-clone, but as
  /// an add-only merge that never wipes.
  Future<void> sendFullSync() =>
      _pushBundle(() => SyncBundleService().exportBundle(mode: SyncMode.full));

  /// Sends only the chosen [categories] (settings fill-only) to the connected
  /// client.
  Future<void> sendSelectiveSync(Set<SyncCategory> categories) => _pushBundle(
    () => SyncBundleService().exportBundle(
      mode: SyncMode.incremental,
      categories: categories,
    ),
  );

  Future<void> _pushBundle(Future<ExportBundle> Function() build) async {
    final socket = _activeSocket;
    final key = _activeKey;
    if (socket == null || key == null) {
      _set(const SyncError('The other phone is no longer connected.'));
      return;
    }
    try {
      _set(const SyncInProgress('Preparing data…'));
      final bundle = await build();
      await _writeLine(socket, await _encrypt(bundle.metaJson, key));

      final total = bundle.files.length;
      for (var i = 0; i < total; i++) {
        await _writeLine(
          socket,
          await _encryptBytes(bundle.files[i].bytes, key),
        );
        _set(
          SyncInProgress(
            'Sending photos… ${i + 1}/$total',
            fraction: total == 0 ? null : (i + 1) / total,
          ),
        );
      }
      await socket.flush();
      _set(SyncCompleted(bundle.summary, sent: true));
    } catch (e) {
      _set(SyncError('Send failed: ${_clean(e)}'));
    } finally {
      await _teardown(); // one payload per session
    }
  }

  Future<void> _writeLine(Socket socket, String line) async {
    socket.add(utf8.encode('$line\n'));
    await socket.flush();
  }

  // ===========================================================================
  // Client (receiver: connects, waits for the sender, then merges add-only)
  // ===========================================================================

  /// Connects to [hostIp]:[port], authenticates with [pin], waits for the
  /// sender to choose, receives the payload, and merges it into this phone's
  /// data add-only (the receiver keeps its own; see [SyncBundleService]).
  Future<void> connectAndReceive(String hostIp, int port, String pin) async {
    _set(const SyncConnecting());
    try {
      final payload = await _connectAndFetch(
        hostIp,
        port,
        pin,
        onConnected: () => _set(const SyncWaitingForSender()),
        onReceiving: () => _set(const SyncInProgress('Receiving data…')),
        onProgress: (i, total) => _set(
          SyncInProgress(
            'Receiving photos… ${i + 1}/$total',
            fraction: (i + 1) / total,
          ),
        ),
      );
      // Merge add-only (the receiver keeps its own data).
      _set(const SyncInProgress('Merging into this phone…'));
      final summary = await SyncBundleService().applyBundle(
        payload.metaJson,
        payload.files,
      );
      _set(SyncCompleted(summary, sent: false));
    } on P2PException catch (e) {
      _set(SyncError(e.message));
    } on TimeoutException {
      _set(const SyncError('The connection timed out'));
    } on SocketException catch (e) {
      _set(SyncError('Could not connect to host: ${e.message}'));
    } catch (e) {
      _set(SyncError('Sync failed: ${_clean(e)}'));
    }
  }

  /// The transport half of the client: connect, authenticate, wait for the
  /// sender, and read META + media frames — WITHOUT touching the database. Kept
  /// app-agnostic so it is loopback-testable in isolation. Owns the socket.
  Future<({String metaJson, List<IncomingFile> files})> _connectAndFetch(
    String hostIp,
    int port,
    String pin, {
    void Function()? onConnected,
    void Function()? onReceiving,
    void Function(int i, int total)? onProgress,
  }) async {
    Socket? socket;
    _LineConn? conn;
    try {
      final code = normalizeCode(pin);
      socket = await Socket.connect(hostIp, port, timeout: _connectTimeout);
      conn = _LineConn(socket);

      // 0. Read host salt, derive key.
      final saltLine = await conn
          .readLine(_maxHandshakeLine)
          .timeout(_readTimeout);
      if (saltLine == null) {
        throw const P2PException('Host closed the connection');
      }
      final List<int> salt;
      try {
        salt = base64.decode(saltLine);
      } catch (_) {
        throw const P2PException('Invalid response from host');
      }
      final key = await _deriveKey(code, salt);

      // 1. Authenticated greeting.
      await conn.writeLine(await _encrypt('HELLO_SYNC', key));

      // 2. Read accept (wrong code → decrypt fails → not accepted).
      final ans = await conn.readLine(_maxHandshakeLine).timeout(_readTimeout);
      if (!await _decryptEquals(ans, key, 'ACCEPT_SYNC')) {
        throw const P2PException(
          'Incorrect pairing code, or the host rejected it',
        );
      }
      onConnected?.call();

      // 3. Connected — the sender now chooses what to share. This can take a
      //    while, so META is read with the long payload-wait timeout.
      final metaLine = await conn
          .readLine(_maxPayloadLine)
          .timeout(_payloadWaitTimeout);
      if (metaLine == null) {
        throw const P2PException('The other phone closed the connection');
      }
      onReceiving?.call();
      final metaJson = await _decrypt(metaLine, key);

      final manifest = SyncBundleService.manifestFrom(metaJson);
      final files = <IncomingFile>[];
      for (var i = 0; i < manifest.length; i++) {
        final line = await conn.readLine(_maxPayloadLine).timeout(_readTimeout);
        if (line == null) throw const P2PException('Transfer ended early');
        final bytes = await _decryptBytes(line, key);
        files.add(
          IncomingFile(
            ref: manifest[i].ref,
            ext: manifest[i].ext,
            bytes: bytes,
          ),
        );
        onProgress?.call(i, manifest.length);
      }
      return (metaJson: metaJson, files: files);
    } finally {
      try {
        await conn?.dispose();
      } catch (_) {}
      socket?.destroy();
    }
  }

  /// Test hook: push an arbitrary [bundle] over the held connection without
  /// touching the database (mirrors what the sender's category choice does).
  @visibleForTesting
  Future<void> debugPushBundle(ExportBundle bundle) =>
      _pushBundle(() async => bundle);

  /// Test hook: run the client transport and return the raw received META JSON,
  /// without merging it into any database.
  @visibleForTesting
  Future<String> debugConnectFetchMeta(
    String hostIp,
    int port,
    String code, {
    void Function()? onConnected,
  }) async => (await _connectAndFetch(
    hostIp,
    port,
    code,
    onConnected: onConnected,
  )).metaJson;

  String _clean(Object e) => e is P2PException ? e.message : e.toString();

  /// First non-loopback IPv4 address (the LAN address the client connects to).
  Future<String> _localIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      for (final ni in interfaces) {
        for (final addr in ni.addresses) {
          if (!addr.isLoopback) return addr.address;
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }
}

/// A newline-framed reader/writer over a [Socket]. Replaces an unbounded
/// readLine with a capped one (guards against OOM from one giant line) and
/// exposes a [closed] future so the host can notice the peer dropping while it
/// holds the connection open. Callers apply their own timeout to [readLine].
class _LineConn {
  final Socket socket;
  final List<int> _buf = [];
  int _scanned = 0; // how far into _buf we've already searched for '\n'
  bool _done = false;
  Object? _error;
  int _maxLen = 0;
  Completer<String?>? _pending;
  final Completer<void> _closed = Completer<void>();
  late final StreamSubscription<Uint8List> _sub;

  static const int _lf = 10;
  static const int _cr = 13;

  _LineConn(this.socket) {
    _sub = socket.listen(
      _onData,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: false,
    );
  }

  /// Completes when the peer closes the connection.
  Future<void> get closed => _closed.future;
  void _markClosed() {
    if (!_closed.isCompleted) _closed.complete();
  }

  void _onData(Uint8List data) {
    _buf.addAll(data);
    _serve();
  }

  void _onError(Object e) {
    _error = e;
    _serve();
    _markClosed();
  }

  void _onDone() {
    _done = true;
    _serve();
    _markClosed();
  }

  Future<String?> readLine(int maxLen) {
    if (_pending != null) {
      throw StateError('readLine already pending');
    }
    final c = Completer<String?>();
    _pending = c;
    _maxLen = maxLen;
    _serve();
    return c.future;
  }

  void _serve() {
    final c = _pending;
    if (c == null || c.isCompleted) return;
    final nl = _indexOf(_buf, _lf, _scanned);
    if (nl >= 0) {
      var end = nl;
      if (end > 0 && _buf[end - 1] == _cr) end--;
      if (end > _maxLen) {
        _fail('Received an oversized line; aborting');
        return;
      }
      final line = _buf.sublist(0, end);
      _buf.removeRange(0, nl + 1);
      _scanned = 0;
      _pending = null;
      c.complete(String.fromCharCodes(line));
      return;
    }
    _scanned = _buf.length;
    if (_buf.length > _maxLen) {
      _fail('Received an oversized line; aborting');
      return;
    }
    if (_error != null) {
      _fail('Connection error');
      return;
    }
    if (_done) {
      _pending = null;
      c.complete(null); // EOF before a full line
    }
  }

  void _fail(String message) {
    final c = _pending;
    _pending = null;
    if (c != null && !c.isCompleted) c.completeError(P2PException(message));
  }

  Future<void> writeLine(String line) async {
    socket.add(utf8.encode('$line\n'));
    await socket.flush();
  }

  Future<void> dispose() async {
    _markClosed();
    try {
      await _sub.cancel();
    } catch (_) {}
  }

  static int _indexOf(List<int> buf, int byte, int start) {
    for (var i = start; i < buf.length; i++) {
      if (buf[i] == byte) return i;
    }
    return -1;
  }
}
