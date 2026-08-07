// lib/services/ble_share_service.dart
//
// Dart side of the native "Share via Bluetooth" sender. flutter_blue_plus is
// central-role only (it can scan/connect/read but cannot advertise or host a
// GATT server), so the sender half lives in native Kotlin
// (android/.../BleShareServer.kt) behind this method/event channel pair — the
// same bridge pattern as the Telecom integration. The receiver half is
// ble_receive_service.dart.

import 'package:flutter/services.dart';

/// Lifecycle of one share session, as reported by the native peripheral.
enum BleShareState {
  /// Advertising; waiting for a receiver to connect.
  advertising,

  /// A receiver connected (transfer not started yet).
  connected,

  /// The receiver is reading the payload.
  sending,

  /// The final payload byte was served — the contact is across.
  complete,

  /// The receiver dropped the connection (may reconnect; still advertising).
  disconnected,

  /// Advertising or the transfer failed; see [BleShareEvent.message].
  error,
}

class BleShareEvent {
  final BleShareState state;
  final String? message;

  /// Bytes served so far / payload size — only on [BleShareState.sending]
  /// events, so long (whole-book) transfers can show a percentage.
  final int? sent;
  final int? total;

  const BleShareEvent(this.state, {this.message, this.sent, this.total});

  /// Served fraction in [0, 1], or null when this event carries no progress.
  double? get progress {
    final s = sent, t = total;
    if (s == null || t == null || t <= 0) return null;
    return (s / t).clamp(0.0, 1.0);
  }
}

class BleShareService {
  static final BleShareService _instance = BleShareService._internal();
  factory BleShareService() => _instance;
  BleShareService._internal();

  static const MethodChannel _channel = MethodChannel(
    'contact_sphere/ble_share',
  );
  static const EventChannel _events = EventChannel(
    'contact_sphere/ble_share_events',
  );

  Stream<BleShareEvent>? _eventStream;

  /// Starts advertising [payload] (a UTF-8 vCard) under [name] (shown in the
  /// receiver's scan list, truncated to 13 UTF-8 bytes by the advertiser).
  /// Returns null on success or a short error code: `bluetooth_off`,
  /// `unsupported`, `no_permission`, `already_sharing`, `start_failed`.
  Future<String?> start({
    required Uint8List payload,
    required String name,
  }) async {
    try {
      return await _channel.invokeMethod<String?>('start', <String, dynamic>{
        'payload': payload,
        'name': name,
      });
    } on PlatformException {
      return 'start_failed';
    } on MissingPluginException {
      // Host-side tests / non-Android platforms: no bridge registered.
      return 'unsupported';
    }
  }

  /// Stops advertising and closes the GATT server. Safe to call repeatedly.
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException {
      // Nothing to stop.
    } on MissingPluginException {
      // See start().
    }
  }

  /// The device's Android SDK level (0 when the bridge is unavailable).
  /// Used to decide the runtime-permission set: legacy BLE scans on
  /// Android 11 and below additionally need location.
  Future<int> sdkInt() async {
    try {
      return await _channel.invokeMethod<int>('getSdkInt') ?? 0;
    } on PlatformException {
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }

  /// Share-session events from the native peripheral. Broadcast; listen from
  /// the share dialog while it is open. Unknown states map to [BleShareState.error].
  Stream<BleShareEvent> get events {
    return _eventStream ??= _events.receiveBroadcastStream().map((raw) {
      final map = raw is Map ? raw : const <Object?, Object?>{};
      final state = switch (map['state']) {
        'advertising' => BleShareState.advertising,
        'connected' => BleShareState.connected,
        'sending' => BleShareState.sending,
        'complete' => BleShareState.complete,
        'disconnected' => BleShareState.disconnected,
        _ => BleShareState.error,
      };
      return BleShareEvent(
        state,
        message: map['message'] as String?,
        sent: map['sent'] as int?,
        total: map['total'] as int?,
      );
    });
  }
}
