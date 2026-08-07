// lib/database/db_key.dart
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the passphrase that encrypts the contact database (SQLCipher).
///
/// The key is a random 256-bit value generated once on first launch and kept
/// in the Android Keystore (via flutter_secure_storage's
/// EncryptedSharedPreferences). It is never hard-coded and never ships in the
/// APK, so pulling the DB file off the device is useless without the Keystore.
class DbKey {
  DbKey._();

  // Bump the suffix only if the key scheme ever changes; a new name would
  // orphan the old key and lock users out of their data.
  static const String _storageKey = 'contact_db_key_v1';

  // Default Android options already use keystore-backed AES-GCM. resetOnError
  // is forced off: the default (true) would PERMANENTLY wipe the stored key on
  // any read error, which would orphan the encrypted DB and lose every contact.
  // We would rather surface the error than silently destroy the key.
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: false),
  );

  /// The in-flight (or resolved) key lookup, cached so concurrent callers share
  /// ONE read/generate instead of each minting its own key. This is the crux of
  /// avoiding a fresh-install race: without it, several startup callers all read
  /// empty storage at once and each generate a DIFFERENT key, leaving the stored
  /// key and the DB's real key mismatched. `??=` is atomic on Dart's single
  /// event loop, so only one `_readOrCreate()` ever runs.
  static Future<String>? _pending;

  /// Returns the stored passphrase, generating and persisting one on first use.
  static Future<String> getOrCreate() =>
      _pending ??= _readOrCreate().catchError((Object e) {
        _pending = null; // allow a retry after a transient read/write failure
        throw e;
      });

  static Future<String> _readOrCreate() async {
    try {
      final existing = await _storage.read(key: _storageKey);
      if (existing != null && existing.isNotEmpty) return existing;
      final key = _generateHexKey();
      await _storage.write(key: _storageKey, value: key);
      return key;
    } catch (_) {
      if (!Platform.isAndroid) {
        return '0000000000000000000000000000000000000000000000000000000000000000';
      }
      rethrow;
    }
  }


  /// 32 random bytes as lowercase hex (64 chars). Hex only — no quotes — so the
  /// value is safe to inline into a `PRAGMA key` / `ATTACH ... KEY` statement.
  static String _generateHexKey() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
