// lib/services/permission_service.dart
import 'package:permission_handler/permission_handler.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';

/// Requests the runtime permissions the app's features rely on.
///
/// Designed to be safe to call from `main()` during startup: it never throws —
/// a denied or unavailable permission is logged and skipped so the app can
/// still launch and ask again contextually later.
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Permissions requested up-front at launch. Feature-specific permissions
  /// (e.g. bluetooth, location) are better requested lazily when the feature is
  /// used, but contacts/phone are core enough to ask for early.
  static const List<Permission> _startupPermissions = <Permission>[
    Permission.contacts,
    Permission.phone,
  ];

  Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    try {
      return await _startupPermissions.request();
    } catch (e, st) {
      AppLogger.error(
        'PermissionService.requestPermissions failed',
        error: e,
        stackTrace: st,
      );
      return <Permission, PermissionStatus>{};
    }
  }

  /// Request a single permission on demand, returning whether it was granted.
  /// Swallows platform errors and returns false rather than throwing.
  Future<bool> ensure(Permission permission) async {
    try {
      final status = await permission.request();
      return status.isGranted || status.isLimited;
    } catch (e, st) {
      AppLogger.error(
        'PermissionService.ensure($permission) failed',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<bool> ensureCallPhone() => ensure(Permission.phone);
  Future<bool> ensureMicrophone() => ensure(Permission.microphone);
  Future<bool> ensureLocation() => ensure(Permission.location);
  Future<bool> ensureCamera() => ensure(Permission.camera);

  /// **Does not cover reading the device call log.** On Android 9+ `READ_CALL_LOG`
  /// lives in its own "Call logs" permission group, which `Permission.phone`
  /// (READ_PHONE_STATE / CALL_PHONE) does not include — and permission_handler
  /// has no constant for it. This method used to be called `ensureReadCallLog`
  /// and guard the call-log import: it returned true while the call log was
  /// still blocked, so the read failed and the failure was reported as
  /// "already up to date".
  ///
  /// The call-log paths now let the `call_log` plugin raise its own
  /// `READ_CALL_LOG` prompt and report a real failure when it is refused, so
  /// nothing should guard on this. Kept only to request the phone-state
  /// permission those paths also rely on.
  Future<bool> ensurePhoneState() => ensure(Permission.phone);
}
