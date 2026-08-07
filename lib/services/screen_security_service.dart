// lib/services/screen_security_service.dart
import 'package:flutter/services.dart';

/// Toggles the Android window FLAG_SECURE (blocks screenshots, screen recording
/// and the Recents / task-switcher thumbnail). FLAG_SECURE is a single flag for
/// the whole Activity window, so callers acquire/release it by a named reason;
/// the flag stays on until every reason has been released.
class ScreenSecurity {
  ScreenSecurity._();

  static const MethodChannel _channel = MethodChannel('contact_sphere/telecom');

  /// Active reasons the secure flag is currently held for.
  static final Set<String> _reasons = <String>{};

  /// Mark [reason] as needing the secure flag and apply it.
  static Future<void> acquire(String reason) {
    _reasons.add(reason);
    return _apply();
  }

  /// Drop [reason]; clears the secure flag once no reasons remain.
  static Future<void> release(String reason) {
    _reasons.remove(reason);
    return _apply();
  }

  static Future<void> _apply() async {
    try {
      await _channel.invokeMethod('setSecureFlag', {
        'enabled': _reasons.isNotEmpty,
      });
    } on PlatformException {
      // Best-effort: never crash the UI over a window-flag toggle.
    }
  }
}
