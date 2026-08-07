// lib/services/app_pin_service.dart
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';

/// Stores and verifies the app-only unlock PIN and its recovery code for
/// [LockMode.appPin]. Both are kept **only as salted SHA-256 hashes** in the
/// Android Keystore (via flutter_secure_storage's EncryptedSharedPreferences) —
/// the raw PIN and recovery code are never persisted, so pulling the device
/// storage yields nothing usable.
///
/// The recovery code is a longer random string shown once at setup. Entering it
/// on the lock screen clears the PIN (turning App lock off) so a user who forgot
/// their PIN can get back in and set a new one.
class AppPinService {
  static final AppPinService _instance = AppPinService._internal();
  factory AppPinService() => _instance;
  AppPinService._internal();

  // Same store and options as the DB key: Keystore-backed AES-GCM, and
  // resetOnError forced off so a transient read error never wipes the hashes.
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: false),
  );

  static const String _kPinSalt = 'app_pin_salt_v1';
  static const String _kPinHash = 'app_pin_hash_v1';
  static const String _kRecoverySalt = 'app_recovery_salt_v1';
  static const String _kRecoveryHash = 'app_recovery_hash_v1';

  static final Sha256 _sha256 = Sha256();

  /// Characters used in the recovery code. Excludes easily-confused glyphs
  /// (0/O, 1/I/L) so a hand-copied code is less likely to be mistyped.
  static const String _recoveryAlphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  /// How many characters the recovery code has. 10 from a 31-char alphabet is
  /// far too large to guess, unlike the short numeric PIN.
  static const int _recoveryLength = 10;

  /// Whether a PIN is currently set.
  Future<bool> hasPin() async {
    try {
      final hash = await _storage.read(key: _kPinHash);
      return hash != null && hash.isNotEmpty;
    } catch (e) {
      AppLogger.error('AppPinService.hasPin failed', error: e);
      return false;
    }
  }

  /// Saves [pin] and returns a freshly generated recovery code (shown once).
  /// Overwrites any existing PIN and recovery code. Throws on storage failure so
  /// the caller can avoid switching the lock mode to a PIN that did not persist.
  Future<String> setPin(String pin) async {
    final recoveryCode = _generateRecoveryCode();
    final pinSalt = _generateSalt();
    final recoverySalt = _generateSalt();
    await _storage.write(key: _kPinSalt, value: pinSalt);
    await _storage.write(key: _kPinHash, value: await _hash(pin, pinSalt));
    await _storage.write(key: _kRecoverySalt, value: recoverySalt);
    await _storage.write(
      key: _kRecoveryHash,
      value: await _hash(recoveryCode, recoverySalt),
    );
    return recoveryCode;
  }

  /// True when [pin] matches the stored PIN. False on any mismatch or error.
  Future<bool> verifyPin(String pin) => _verify(pin, _kPinSalt, _kPinHash);

  /// True when [code] matches the stored recovery code (case-insensitive,
  /// whitespace ignored). False on any mismatch or error.
  Future<bool> verifyRecoveryCode(String code) {
    final normalized = code.replaceAll(RegExp(r'\s'), '').toUpperCase();
    return _verify(normalized, _kRecoverySalt, _kRecoveryHash);
  }

  /// Removes the PIN and recovery code (App lock's PIN mode is now unset).
  Future<void> clearPin() async {
    try {
      await _storage.delete(key: _kPinSalt);
      await _storage.delete(key: _kPinHash);
      await _storage.delete(key: _kRecoverySalt);
      await _storage.delete(key: _kRecoveryHash);
    } catch (e) {
      AppLogger.error('AppPinService.clearPin failed', error: e);
    }
  }

  Future<bool> _verify(String value, String saltKey, String hashKey) async {
    try {
      final salt = await _storage.read(key: saltKey);
      final expected = await _storage.read(key: hashKey);
      if (salt == null || expected == null || expected.isEmpty) return false;
      final actual = await _hash(value, salt);
      // Length-guarded constant-time compare so timing doesn't leak the hash.
      if (actual.length != expected.length) return false;
      var diff = 0;
      for (var i = 0; i < actual.length; i++) {
        diff |= actual.codeUnitAt(i) ^ expected.codeUnitAt(i);
      }
      return diff == 0;
    } catch (e) {
      AppLogger.error('AppPinService._verify failed', error: e);
      return false;
    }
  }

  /// Salted SHA-256 of [value], returned as lowercase hex.
  Future<String> _hash(String value, String saltHex) async {
    final bytes = <int>[..._hexToBytes(saltHex), ...utf8.encode(value)];
    final digest = await _sha256.hash(bytes);
    return digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 16 random bytes as lowercase hex.
  static String _generateSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _generateRecoveryCode() {
    final rnd = Random.secure();
    return List.generate(
      _recoveryLength,
      (_) => _recoveryAlphabet[rnd.nextInt(_recoveryAlphabet.length)],
    ).join();
  }

  static List<int> _hexToBytes(String hex) {
    final out = <int>[];
    for (var i = 0; i + 1 < hex.length; i += 2) {
      out.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return out;
  }
}
