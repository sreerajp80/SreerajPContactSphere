// lib/services/contact_intent_service.dart
import 'package:flutter/services.dart';

enum ContactIntentAction {
  view,
  edit,
  insert,
  insertOrEdit,
  pick,
  unknown,
}

class ContactIntent {
  final ContactIntentAction action;
  final String? uri;
  final String? mimeType;
  final Map<String, String> extras;

  ContactIntent({
    required this.action,
    this.uri,
    this.mimeType,
    required this.extras,
  });

  factory ContactIntent.fromMap(Map<dynamic, dynamic> map) {
    final actionStr = map['action'] as String?;
    final action = ContactIntentAction.values.firstWhere(
      (e) => e.name == actionStr,
      orElse: () => ContactIntentAction.unknown,
    );
    final extrasRaw = map['extras'] as Map<dynamic, dynamic>? ?? {};
    final extras = extrasRaw.map((k, v) => MapEntry(k.toString(), v.toString()));

    return ContactIntent(
      action: action,
      uri: map['uri'] as String?,
      mimeType: map['mimeType'] as String?,
      extras: extras,
    );
  }
}

class ContactIntentService {
  static const MethodChannel _channel = MethodChannel('contact_sphere/contact_intents');
  static final ContactIntentService _instance = ContactIntentService._internal();
  factory ContactIntentService() => _instance;
  ContactIntentService._internal();

  /// Fetches the contact intent that launched the app (if any) and clears it.
  Future<ContactIntent?> getPendingContactIntent() async {
    try {
      final map = await _channel.invokeMapMethod<dynamic, dynamic>('getPendingContactIntent');
      if (map == null) return null;
      return ContactIntent.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  /// Sets the MethodCallHandler to listen for incoming contact intents while the app is running (warm delivery).
  void setIntentListener(VoidCallback onIntentReceived) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'contactIntentReceived') {
        onIntentReceived();
      }
      return null;
    });
  }

  /// Returns the picked contact result back to the calling app and finishes the activity.
  Future<void> submitContactPickerResult({
    String? contactUri,
    String? phone,
    String? email,
  }) async {
    try {
      await _channel.invokeMethod('submitContactPickerResult', {
        'contactUri': contactUri,
        'phone': phone,
        'email': email,
      });
    } catch (_) {}
  }
}
