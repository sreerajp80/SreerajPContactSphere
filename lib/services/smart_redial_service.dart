// lib/services/smart_redial_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';

/// Represents an active scheduled auto-redial task.
class SmartRedialTask {
  final String id;
  final String phoneNumber;
  final int? contactId;
  final String displayName;
  final int delayMinutes;
  final DateTime scheduledAt;
  final DateTime fireAt;
  final String? simId;
  bool isCompleted;
  bool isCancelled;

  SmartRedialTask({
    required this.id,
    required this.phoneNumber,
    this.contactId,
    required this.displayName,
    required this.delayMinutes,
    required this.scheduledAt,
    required this.fireAt,
    this.simId,
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
    'phoneNumber': phoneNumber,
    'contactId': contactId,
    'displayName': displayName,
    'delayMinutes': delayMinutes,
    'scheduledAt': scheduledAt.toIso8601String(),
    'fireAt': fireAt.toIso8601String(),
    'simId': simId,
    'isCompleted': isCompleted,
    'isCancelled': isCancelled,
  };

  factory SmartRedialTask.fromJson(Map<String, dynamic> json) =>
      SmartRedialTask(
        id: json['id'] as String,
        phoneNumber: json['phoneNumber'] as String,
        contactId: json['contactId'] as int?,
        displayName: json['displayName'] as String,
        delayMinutes: json['delayMinutes'] as int,
        scheduledAt: DateTime.parse(json['scheduledAt'] as String),
        fireAt: DateTime.parse(json['fireAt'] as String),
        simId: json['simId'] as String?,
        isCompleted: json['isCompleted'] as bool? ?? false,
        isCancelled: json['isCancelled'] as bool? ?? false,
      );
}

/// Service to handle Smart Redial auto-retry schedules and "Reach Me" messages.
///
/// Scheduling, firing, and auto-cancel-on-callback are all owned natively
/// (see `SmartRedialManager.kt`) so they keep working even if Android kills
/// the app process during the user-chosen delay (1-30 min) — which it
/// routinely does. This class mirrors the native task list into
/// [SharedPreferences] purely so the "Active scheduled redials" UI has
/// something to show and a "cancel" button to call, and reconciles that
/// mirror against native truth on [init] so a task the native side already
/// fired or auto-cancelled (e.g. the contact called back) doesn't linger in
/// the list.
class SmartRedialService extends ChangeNotifier {
  static final SmartRedialService _instance = SmartRedialService._internal();
  factory SmartRedialService() => _instance;

  SmartRedialService._internal();

  static const _prefsKey = 'smart_redial_tasks';

  final List<SmartRedialTask> _tasks = [];
  bool _initialized = false;

  List<SmartRedialTask> get activeTasks =>
      List.unmodifiable(_tasks.where((t) => !t.isCompleted && !t.isCancelled));

  /// Restores persisted tasks and reconciles them against the native task
  /// list, so a task the native side already fired or auto-cancelled (the
  /// contact called back) doesn't keep showing as active. Safe to call more
  /// than once; only the first call does anything. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _restoreTasks();
    await _reconcileWithNative();
  }

  /// Re-checks the task list against native truth, same as the reconcile
  /// [init] does once at startup, but callable any time the app is already
  /// running. Native fires and auto-cancels reminders on its own (so they
  /// keep working while this app process is killed) — call this whenever the
  /// app comes back to the foreground, or right after handling a reminder's
  /// auto-placed call, so a task that fired or auto-cancelled while this
  /// process stayed alive doesn't linger as "active" in the UI.
  Future<void> refresh() => _reconcileWithNative();

  Future<void> _restoreTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as List;
      final restored = decoded
          .map((e) => SmartRedialTask.fromJson(e as Map<String, dynamic>))
          .toList();

      _tasks
        ..clear()
        ..addAll(restored);
      notifyListeners();
    } catch (_) {
      // Best-effort; a missing/corrupt store just starts fresh.
    }
  }

  /// Marks any task we think is still active, but that native no longer has
  /// pending, as completed (fired) or cancelled (auto-cancelled on a
  /// callback, or a stale task dropped after a reboot).
  Future<void> _reconcileWithNative() async {
    final active = _tasks.where((t) => !t.isCompleted && !t.isCancelled);
    if (active.isEmpty) return;

    final pendingIds = await TelecomService().pendingSmartRedialIds();
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

  Future<void> _persistTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_prefsKey, raw);
    } catch (_) {
      // Best-effort; losing the persisted list only degrades survival across
      // app restarts, it doesn't break the current session.
    }
  }

  /// Schedules auto-redial for [phoneNumber] after [delayMinutes]. The call
  /// is placed automatically by native Android code when the delay elapses,
  /// even if this app has been killed in the meantime.
  ///
  /// The SIM is resolved **now**, not when the alarm fires: [simId] (the SIM
  /// the unanswered call went out on) when it is still an active SIM, else the
  /// user's default SIM, else the system default. The native fire path has no
  /// UI, so there is nobody to answer a SIM chooser at that point.
  ///
  /// Throws a [StateError] if the native alarm couldn't actually be armed
  /// (e.g. the exact-alarm permission isn't granted) — callers should check
  /// for that themselves before calling this (see the Smart Redial sheet's
  /// upfront permission check), but this is the backstop that keeps the
  /// Dart-side list from ever claiming a reminder is active when nothing was
  /// really scheduled.
  Future<SmartRedialTask> scheduleAutoRedial({
    required String phoneNumber,
    int? contactId,
    String displayName = 'this contact',
    required int delayMinutes,
    String? simId,
  }) async {
    await init();

    final now = DateTime.now();
    final fireAt = now.add(Duration(minutes: delayMinutes));
    final id = 'redial_${now.millisecondsSinceEpoch}_${phoneNumber.replaceAll(RegExp(r'\D'), '')}';

    final sim = await _resolveSim(simId);

    final armed = await TelecomService().scheduleSmartRedial(
      id: id,
      phoneNumber: phoneNumber,
      displayName: displayName,
      fireAt: fireAt,
      phoneAccountId: sim?.phoneAccountId,
      componentName: sim?.componentName,
    );
    if (!armed) {
      throw StateError('Could not schedule Smart Redial (native alarm not armed)');
    }

    final task = SmartRedialTask(
      id: id,
      phoneNumber: phoneNumber,
      contactId: contactId,
      displayName: displayName,
      delayMinutes: delayMinutes,
      scheduledAt: now,
      fireAt: fireAt,
      simId: simId,
    );

    _tasks.add(task);
    await _persistTasks();
    notifyListeners();

    return task;
  }

  /// The SIM a scheduled retry should dial on: the one the original call used
  /// ([simId]) when it is still active, else the user's configured default,
  /// else null (the platform's own default). Never throws — a SIM we can't
  /// resolve just means "let the platform pick".
  Future<SimAccount?> _resolveSim(String? simId) async {
    try {
      final sims = await SimService().list();
      for (final s in sims) {
        if (s.phoneAccountId == simId) return s;
      }
      return await SimService().defaultSim(await AppSettings.readDefaultSimId());
    } catch (_) {
      return null;
    }
  }

  /// Cancels an active auto-redial task by id.
  Future<void> cancelTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final task = _tasks[idx];
    if (task.isCompleted || task.isCancelled) return;

    task.isCancelled = true;
    await TelecomService().cancelSmartRedial(id);
    await _persistTasks();
    notifyListeners();
  }

  /// Sends a pre-set "trying to reach you" message via SMS channel.
  Future<bool> sendReachMeMessage({
    required String phoneNumber,
    String? customMessage,
  }) async {
    final message = (customMessage != null && customMessage.trim().isNotEmpty)
        ? customMessage.trim()
        : await AppSettings.readPresetReachMeMessage();

    // Try Telecom send SMS first if available, else launch SMS URL intent
    try {
      final uri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: <String, String>{'body': message},
      );
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('SmartRedialService SMS error: $e');
    }
    return false;
  }
}
