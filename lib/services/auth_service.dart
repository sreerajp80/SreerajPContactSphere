// lib/services/auth_service.dart
import 'package:local_auth/local_auth.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';

/// Wraps device biometric / credential authentication, used to gate access to
/// secret contacts. All methods are defensive: on any platform error they
/// return false (access denied) rather than throwing.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device can authenticate at all (biometrics or device PIN).
  Future<bool> get isAvailable async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      AppLogger.error('AuthService.isAvailable failed', error: e);
      return false;
    }
  }

  /// Prompts for authentication. Returns true only on a successful unlock.
  ///
  /// If the device has no auth set up at all, callers can choose to treat a
  /// false result as "no protection available" — but the default here is to
  /// fail closed (deny) so secret contacts stay hidden.
  Future<bool> authenticate({
    String reason = 'Authenticate to view secret contacts',
  }) async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      AppLogger.error('AuthService.authenticate failed', error: e);
      return false;
    }
  }
}
