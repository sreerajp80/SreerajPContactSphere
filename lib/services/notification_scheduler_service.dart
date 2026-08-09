// lib/services/notification_scheduler_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/services/telecom_service.dart';

/// Represents a generic scheduled notification item.
class ScheduledNotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final DateTime fireAt;
  final String? payload;
  final String? category;
  bool isCompleted;
  bool isCancelled;

  ScheduledNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.fireAt,
    this.payload,
    this.category,
    this.isCompleted = false,
    this.isCancelled = false,
  });

  Duration get remainingDuration {
    final diff = fireAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isExpired => DateTime.now().isAfter(fireAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'scheduledAt': scheduledAt.toIso8601String(),
        'fireAt': fireAt.toIso8601String(),
        'payload': payload,
        'category': category,
        'isCompleted': isCompleted,
        'isCancelled': isCancelled,
      };

  factory ScheduledNotificationItem.fromJson(Map<String, dynamic> json) =>
      ScheduledNotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        fireAt: DateTime.parse(json['fireAt'] as String),
        payload: json['payload'] as String?,
        category: json['category'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
        isCancelled: json['isCancelled'] as bool? ?? false,
      );
}

/// Generic notification scheduler service that manages exact AlarmManager alarms
/// and boot-surviving scheduled alerts across ContactSphere.
class NotificationSchedulerService extends ChangeNotifier {
  static final NotificationSchedulerService _instance =
      NotificationSchedulerService._internal();
  factory NotificationSchedulerService() => _instance;

  NotificationSchedulerService._internal();

  static const _prefsKey = 'scheduled_notification_tasks';

  final List<ScheduledNotificationItem> _tasks = [];
  bool _initialized = false;

  List<ScheduledNotificationItem> get activeTasks => List.unmodifiable(
        _tasks.where((t) => !t.isCompleted && !t.isCancelled),
      );

  List<ScheduledNotificationItem> get allTasks =>
      List.unmodifiable(_tasks);

  /// Initializes the service, restoring persisted tasks and reconciling against native pending IDs.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _restoreTasks();
    await refresh();
  }

  /// Reconciles Dart-side tasks against native pending IDs.
  Future<void> refresh() async {
    final active = _tasks.where((t) => !t.isCompleted && !t.isCancelled);
    if (active.isEmpty) return;

    final pendingIds = await TelecomService().pendingNotificationIds();
    var changed = false;
    for (final task in active) {
      if (!pendingIds.contains(task.id)) {
        if (task.isExpired) {
          task.isCompleted = true;
        } else {
          task.isCancelled = true;
        }
        changed = true;
      }
    }
    if (changed) {
      await _persistTasks();
      notifyListeners();
    }
  }

  Future<void> _restoreTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as List;
      final restored = decoded
          .map((e) =>
              ScheduledNotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();

      _tasks
        ..clear()
        ..addAll(restored);
      notifyListeners();
    } catch (_) {
      // Best-effort
    }
  }

  Future<void> _persistTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_prefsKey, raw);
    } catch (_) {
      // Best-effort
    }
  }

  /// Schedules a generic notification at [fireAt].
  ///
  /// Throws [StateError] if native exact alarm permission is missing or arming fails.
  Future<ScheduledNotificationItem> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime fireAt,
    String? payload,
    String? category,
  }) async {
    await init();

    final now = DateTime.now();
    final armed = await TelecomService().scheduleNotification(
      id: id,
      title: title,
      body: body,
      fireAt: fireAt,
      payload: payload,
      category: category,
    );

    if (!armed) {
      throw StateError(
        'Could not schedule notification (native alarm not armed)',
      );
    }

    final item = ScheduledNotificationItem(
      id: id,
      title: title,
      body: body,
      scheduledAt: now,
      fireAt: fireAt,
      payload: payload,
      category: category,
    );

    _tasks.removeWhere((t) => t.id == id);
    _tasks.add(item);
    await _persistTasks();
    notifyListeners();

    return item;
  }

  /// Cancels a scheduled notification task by [id].
  Future<void> cancelNotification(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final task = _tasks[idx];
    if (task.isCompleted || task.isCancelled) return;

    task.isCancelled = true;
    await TelecomService().cancelNotification(id);
    await _persistTasks();
    notifyListeners();
  }

  /// Returns whether the app has exact alarm permissions.
  Future<bool> hasExactAlarmPermission() =>
      TelecomService().hasExactAlarmPermission();

  /// Prompts system settings for exact alarm permission.
  Future<void> requestExactAlarmPermission() =>
      TelecomService().requestExactAlarmPermission();

  /// Gets any pending notification payload delivered via a notification tap.
  Future<String?> getPendingNotificationPayload() =>
      TelecomService().pendingNotificationPayload();
}
