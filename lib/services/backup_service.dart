// lib/services/backup_service.dart
//
// Makes and restores a password-protected backup of the WHOLE app database plus
// its photo / calling-card images.
//
// Why not just copy the DB file? The live database is encrypted with SQLCipher
// using a random key kept only in the Android Keystore (see db_key.dart). That
// key never leaves the device and dies on uninstall, so a raw copy is unreadable
// anywhere else — a new phone, a re-install, or a differently-signed build. So a
// portable backup MUST be re-protected with something the user controls: a
// passphrase. That is exactly how the app's P2P sync secures its payload, and we
// reuse the same primitives (PBKDF2 + AES-GCM-256, from the `cryptography`
// package) here.
//
// The data itself is produced by SyncBundleService.exportBundle(full), which
// serializes every table + the portable settings + staged media into plain,
// Keystore-independent data. We wrap that in one encrypted file. Restore reverses
// it and does a FULL REPLACE via SyncBundleService.replaceAllFromBundle.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/services/sync_bundle_service.dart';

/// A user-facing backup / restore failure (bad password, wrong file, version
/// mismatch, …). The message is safe to show directly.
class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
  @override
  String toString() => message;
}

class BackupService {
  // File header: ASCII "CSBK" + one format-version byte. Bump [_formatVersion]
  // only if this container layout changes.
  static const List<int> _magic = [0x43, 0x53, 0x42, 0x4B]; // 'C' 'S' 'B' 'K'
  static const int _formatVersion = 1;

  // Crypto parameters, kept in step with p2p_sync_service.dart so the same
  // security review covers both.
  static const int _saltLen = 16;
  static const int _ivLen = 12; // AES-GCM nonce
  static const int _macLen = 16; // 128-bit GCM tag
  static const int _pbkdf2Iterations = 300000;
  static const int _pbkdf2KeyBits = 256;

  // Smallest sane file: header + salt + (nonce + tag). Anything shorter is not
  // one of our backups.
  static const int _minFileLen =
      5 + _saltLen + _ivLen + _macLen; // magic(4)+ver(1)+salt+nonce+tag

  final Pbkdf2 _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _pbkdf2Iterations,
    bits: _pbkdf2KeyBits,
  );
  final AesGcm _gcm = AesGcm.with256bits();
  final SyncBundleService _bundles = SyncBundleService();

  // ===========================================================================
  // Backup
  // ===========================================================================

  /// Builds the whole encrypted backup as bytes. Pure of app file I/O beyond the
  /// media files the export reads, so tests can round-trip it without a
  /// temp-directory plugin.
  Future<Uint8List> encodeBackup(String passphrase) async {
    if (passphrase.isEmpty) {
      throw const BackupException('A password is required to back up.');
    }
    final bundle = await _bundles.exportBundle(mode: SyncMode.full);

    // ext per media file lives in the META manifest, not on the byte frame.
    final extByRef = <String, String>{
      for (final e in SyncBundleService.manifestFrom(bundle.metaJson))
        e.ref: e.ext,
    };

    final plain = _packPlaintext(bundle, extByRef);

    final salt = _randomBytes(_saltLen);
    final key = await _deriveKey(passphrase, salt);
    final box = await _gcm.encrypt(plain, secretKey: key);

    final out = BytesBuilder();
    out.add(_magic);
    out.addByte(_formatVersion);
    out.add(salt);
    out.add(box.concatenation()); // nonce ‖ ciphertext ‖ tag
    return out.toBytes();
  }

  /// Writes [encodeBackup] to a temp file the caller can hand to the share sheet
  /// (where the user picks the save location). Returns the file.
  Future<File> createBackup(String passphrase) async {
    final bytes = await encodeBackup(passphrase);
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[:.]'), '-')
        .replaceAll('T', '_')
        .split('_')
        .take(2)
        .join('_');
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'ContactSphere_Backup_$stamp.csbak'));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Suggested user-facing file name for a share subject / save dialog.
  String suggestedFileName() {
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[:.]'), '-')
        .split('T')
        .first;
    return 'ContactSphere_Backup_$stamp.csbak';
  }

  // ===========================================================================
  // Restore (FULL REPLACE)
  // ===========================================================================

  /// Decrypts [bytes] with [passphrase] and REPLACES all current app data with
  /// the backup's. Throws [BackupException] on a wrong password, a corrupt /
  /// foreign file, or a schema-version mismatch — nothing is changed in those
  /// cases (the replace only runs after every check passes).
  Future<void> restoreBytes(Uint8List bytes, String passphrase) async {
    if (passphrase.isEmpty) {
      throw const BackupException('A password is required to restore.');
    }
    if (bytes.length < _minFileLen ||
        !_startsWith(bytes, _magic) ||
        bytes[4] != _formatVersion) {
      throw const BackupException(
        'This is not a ContactSphere backup file (or it was made by a newer '
        'app version).',
      );
    }

    final salt = bytes.sublist(5, 5 + _saltLen);
    final sealed = bytes.sublist(5 + _saltLen);
    final key = await _deriveKey(passphrase, salt);

    Uint8List plain;
    try {
      final box = SecretBox.fromConcatenation(
        sealed,
        nonceLength: _ivLen,
        macLength: _macLen,
      );
      plain = Uint8List.fromList(await _gcm.decrypt(box, secretKey: key));
    } catch (_) {
      // Wrong password or a tampered file: the GCM tag check fails.
      throw const BackupException(
        'Wrong password, or the backup file is damaged.',
      );
    }

    final (metaJson, files) = _unpackPlaintext(plain);

    await _assertSchemaMatches(metaJson);
    await _bundles.replaceAllFromBundle(metaJson, files);
  }

  /// Reads [file] and restores it. See [restoreBytes].
  Future<void> restoreBackup(XFile file, String passphrase) async {
    final bytes = await file.readAsBytes();
    await restoreBytes(bytes, passphrase);
  }

  // ===========================================================================
  // Plaintext container (framed BEFORE encryption)
  // ===========================================================================
  //
  //   [uint32 metaLen][meta JSON bytes]
  //   then per media file, in manifest order:
  //     [uint16 refLen][ref][uint8 extLen][ext][uint32 bytesLen][bytes]
  //
  // The META JSON already lists the media manifest, so the reader knows how many
  // frames follow.

  Uint8List _packPlaintext(ExportBundle bundle, Map<String, String> extByRef) {
    final out = BytesBuilder();
    final metaBytes = utf8.encode(bundle.metaJson);
    out.add(_u32(metaBytes.length));
    out.add(metaBytes);
    for (final f in bundle.files) {
      final refBytes = utf8.encode(f.ref);
      final ext = extByRef[f.ref] ?? 'img';
      final extBytes = utf8.encode(ext);
      out.add(_u16(refBytes.length));
      out.add(refBytes);
      out.addByte(extBytes.length);
      out.add(extBytes);
      out.add(_u32(f.bytes.length));
      out.add(f.bytes);
    }
    return out.toBytes();
  }

  (String, List<IncomingFile>) _unpackPlaintext(Uint8List data) {
    final view = ByteData.sublistView(data);
    var pos = 0;

    int readU8() {
      _need(data, pos, 1);
      return data[pos++];
    }

    int readU16() {
      _need(data, pos, 2);
      final v = view.getUint16(pos);
      pos += 2;
      return v;
    }

    int readU32() {
      _need(data, pos, 4);
      final v = view.getUint32(pos);
      pos += 4;
      return v;
    }

    Uint8List readBytes(int n) {
      _need(data, pos, n);
      final b = data.sublist(pos, pos + n);
      pos += n;
      return b;
    }

    final metaLen = readU32();
    final metaJson = utf8.decode(readBytes(metaLen));

    final files = <IncomingFile>[];
    while (pos < data.length) {
      final refLen = readU16();
      final ref = utf8.decode(readBytes(refLen));
      final extLen = readU8();
      final ext = utf8.decode(readBytes(extLen));
      final bytesLen = readU32();
      final bytes = readBytes(bytesLen);
      files.add(IncomingFile(ref: ref, ext: ext, bytes: bytes));
    }
    return (metaJson, files);
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  Future<SecretKey> _deriveKey(String passphrase, List<int> salt) => _pbkdf2
      .deriveKey(secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);

  /// Refuses a backup whose schema version does not match this app's live DB.
  /// Restoring across a schema change is not supported yet.
  Future<void> _assertSchemaMatches(String metaJson) async {
    final meta = jsonDecode(metaJson);
    final backupVersion = meta is Map ? meta['dbVersion'] : null;
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('PRAGMA user_version');
    final localVersion = Sqflite.firstIntValue(result) ?? 0;
    if (backupVersion is! int || backupVersion != localVersion) {
      throw BackupException(
        'This backup was made with a different app version (data format '
        'v$backupVersion vs v$localVersion). Update the app to the version that '
        'made the backup, then restore.',
      );
    }
  }

  Uint8List _randomBytes(int n) {
    // Reuse the platform CSPRNG the crypto package exposes via a throwaway key.
    final key = SecretKeyData.random(length: n);
    return Uint8List.fromList(key.bytes);
  }

  bool _startsWith(Uint8List data, List<int> prefix) {
    if (data.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }

  void _need(Uint8List data, int pos, int n) {
    if (pos + n > data.length) {
      throw const BackupException('The backup file is damaged (truncated).');
    }
  }

  Uint8List _u16(int v) {
    final b = ByteData(2)..setUint16(0, v);
    return b.buffer.asUint8List();
  }

  Uint8List _u32(int v) {
    final b = ByteData(4)..setUint32(0, v);
    return b.buffer.asUint8List();
  }
}
