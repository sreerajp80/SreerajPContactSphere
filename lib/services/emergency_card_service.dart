// lib/services/emergency_card_service.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';

/// Why the card notification may not reach the lock screen.
///
/// Defaults are the all-clear, so non-Android platforms and any bridge failure
/// simply show no warning.
class EmergencyNotificationStatus {
  const EmergencyNotificationStatus({
    this.notificationsEnabled = true,
    this.channelBlocked = false,
    this.channelSilent = false,
    this.published = false,
  });

  /// False when notifications for this app are switched off (or the
  /// POST_NOTIFICATIONS permission was denied). Nothing shows anywhere.
  final bool notificationsEnabled;

  /// The emergency card channel itself was turned off in system settings.
  final bool channelBlocked;

  /// The channel was turned down to silent, so the lock screen may hide it.
  final bool channelSilent;

  /// A card is currently published to the native mirror.
  final bool published;

  /// True when the system is stopping the card from being seen at all.
  bool get isBlocked => !notificationsEnabled || channelBlocked;

  /// True when the card can show but may be filtered off the lock screen.
  bool get mayBeHiddenOnLockScreen => !isBlocked && channelSilent;
}

/// Dart-side wrapper over the native emergency-card bridge (see
/// `MainActivity.kt` → `EmergencyCardNotifier` / `EmergencyInfoActivity`).
///
/// The native side keeps the published card in its own SharedPreferences file
/// and posts the lock-screen notification that opens it. Everything here
/// degrades to a no-op off Android, so tests and other platforms never branch.
class EmergencyCardService {
  EmergencyCardService._internal();
  static final EmergencyCardService _instance =
      EmergencyCardService._internal();
  factory EmergencyCardService() => _instance;

  @visibleForTesting
  static const MethodChannel methodChannel = MethodChannel(
    'contact_sphere/emergency',
  );

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Publishes [payload] (the output of `EmergencyInfo.toMirrorJson`) as the
  /// lock-screen card and posts the notification that opens it.
  ///
  /// The payload is stored **in plaintext** — it has to be readable while the
  /// phone is locked. Only pass what the user explicitly chose to publish.
  Future<void> publish(Map<String, dynamic> payload) =>
      _invokeVoid('setEmergencyMirror', {'json': jsonEncode(payload)});

  /// Removes the published card and cancels the notification. Called when the
  /// master switch goes off, or when nothing is left to show.
  Future<void> clear() => _invokeVoid('clearEmergencyMirror');

  /// What the system currently allows for the card notification, so the screen
  /// can explain why the card is missing from the lock screen. Returns an
  /// all-clear status off Android or when the bridge fails.
  Future<EmergencyNotificationStatus> status() async {
    if (!_supported) return const EmergencyNotificationStatus();
    try {
      final map = await methodChannel.invokeMapMethod<String, dynamic>(
        'emergencyNotificationStatus',
      );
      if (map == null) return const EmergencyNotificationStatus();
      return EmergencyNotificationStatus(
        notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
        channelBlocked: map['channelBlocked'] as bool? ?? false,
        channelSilent: map['channelSilent'] as bool? ?? false,
        published: map['published'] as bool? ?? false,
      );
    } catch (e, st) {
      AppLogger.error(
        'EmergencyCardService.status failed',
        error: e,
        stackTrace: st,
      );
      return const EmergencyNotificationStatus();
    }
  }

  /// Opens this app's settings for the emergency card notification channel.
  Future<void> openChannelSettings() =>
      _invokeVoid('openEmergencyChannelSettings');

  /// Opens the system lock-screen notification settings. The "hide silent
  /// notifications" choice lives there and cannot be changed by this app.
  Future<void> openLockScreenSettings() =>
      _invokeVoid('openLockScreenNotificationSettings');

  Future<void> _invokeVoid(String method, [Map<String, dynamic>? args]) async {
    if (!_supported) return;
    try {
      await methodChannel.invokeMethod<void>(method, args);
    } catch (e, st) {
      AppLogger.error(
        'EmergencyCardService.$method failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}
