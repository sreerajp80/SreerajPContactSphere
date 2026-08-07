// lib/services/connected_apps_service.dart
//
// Reads the "connected apps" rows that third-party messengers (WhatsApp,
// Telegram, Arattai, …) sync into the Android contacts provider for a device
// contact, and fires the intents that open them. Backed by the
// `contact_sphere/connected_apps` MethodChannel in MainActivity — this data is
// not exposed by `flutter_contacts`, so it needs native code.
//
// Defensive like DeviceContactService: a missing platform (tests), a denied
// permission, or any channel error degrades to an empty list / false instead
// of throwing.

import 'package:flutter/services.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';

/// One tappable row inside a connected app (e.g. "Message +91 98…").
class ConnectedAppAction {
  final int dataId;
  final String mimetype;
  final String label;

  const ConnectedAppAction({
    required this.dataId,
    required this.mimetype,
    required this.label,
  });
}

/// A third-party app that knows this contact, with its launchable actions.
class ConnectedApp {
  final String packageName;
  final String name;
  final Uint8List? icon;
  final List<ConnectedAppAction> actions;

  const ConnectedApp({
    required this.packageName,
    required this.name,
    this.icon,
    required this.actions,
  });
}

class ConnectedAppsService {
  static final ConnectedAppsService _instance =
      ConnectedAppsService._internal();
  factory ConnectedAppsService() => _instance;
  ConnectedAppsService._internal();

  static const MethodChannel _channel = MethodChannel(
    'contact_sphere/connected_apps',
  );

  /// Apps connected to the device contact [deviceContactId], sorted by name.
  /// Returns an empty list on any failure (no permission, no platform, …).
  Future<List<ConnectedApp>> fetchConnectedApps(String deviceContactId) async {
    if (deviceContactId.isEmpty) return const <ConnectedApp>[];
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>(
        'getConnectedApps',
        {'contactId': deviceContactId},
      );
      if (raw == null) return const <ConnectedApp>[];
      return raw.whereType<Map<dynamic, dynamic>>().map(_toApp).toList();
    } catch (e, st) {
      AppLogger.error(
        'ConnectedAppsService.fetchConnectedApps failed',
        error: e,
        stackTrace: st,
      );
      return const <ConnectedApp>[];
    }
  }

  /// Opens [action]'s owning app on this contact (chat, voice call, …).
  /// Returns false (never throws) when the app can't be launched.
  Future<bool> openAction(ConnectedAppAction action) async {
    try {
      final ok = await _channel.invokeMethod<bool>('openConnectedAppAction', {
        'dataId': action.dataId,
        'mimetype': action.mimetype,
      });
      return ok ?? false;
    } catch (e, st) {
      AppLogger.error(
        'ConnectedAppsService.openAction failed',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  ConnectedApp _toApp(Map<dynamic, dynamic> map) {
    final actions = (map['actions'] as List<dynamic>? ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (a) => ConnectedAppAction(
            dataId: (a['dataId'] as num?)?.toInt() ?? -1,
            mimetype: a['mimetype'] as String? ?? '',
            label: a['label'] as String? ?? '',
          ),
        )
        .where((a) => a.dataId >= 0 && a.mimetype.isNotEmpty)
        .toList();
    return ConnectedApp(
      packageName: map['package'] as String? ?? '',
      name: map['name'] as String? ?? '',
      icon: map['icon'] is Uint8List ? map['icon'] as Uint8List : null,
      actions: actions,
    );
  }
}
