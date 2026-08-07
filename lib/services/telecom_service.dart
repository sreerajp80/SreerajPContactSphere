// lib/services/telecom_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';
import 'package:smart_contacts_dialer/models/call_state.dart';
import 'package:smart_contacts_dialer/models/sim_account.dart';

/// Outcome of starting a ringtone preview (see [TelecomService.previewRingtone]).
enum RingtonePreviewStatus {
  /// Playback started and should be audible.
  playing,

  /// Playback started but the ring stream is silenced — silent/vibrate mode,
  /// ring volume 0, or the in-app ringtone volume set to 0. Callers should
  /// hint the user to raise the ring volume.
  muted,

  /// The tone's source can't be opened (deleted/moved backing file, lost
  /// grant); callers should revert to the default tone.
  missing,
}

/// Dart-side wrapper over the native Telecom bridge (see `MainActivity.kt`).
///
/// Exposes default-dialer status/request and the in-call controls, plus a
/// [callEvents] stream of [CallState] snapshots. Everything degrades to a safe
/// no-op when the platform channels are absent — non-Android hosts and the
/// widget/unit tests — so callers never need to branch on platform.
class TelecomService {
  TelecomService._internal();
  static final TelecomService _instance = TelecomService._internal();
  factory TelecomService() => _instance;

  @visibleForTesting
  static const MethodChannel methodChannel = MethodChannel(
    'contact_sphere/telecom',
  );
  @visibleForTesting
  static const EventChannel eventChannel = EventChannel(
    'contact_sphere/call_events',
  );

  /// True only on Android, where the native channels exist. Elsewhere all calls
  /// below no-op so tests and other platforms stay happy.
  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Stream<CallState>? _callEvents;

  /// Broadcast stream of call-state snapshots. Emits [CallState.none] when no
  /// call is active. On unsupported platforms this is an empty stream.
  Stream<CallState> get callEvents {
    if (!_supported) return const Stream<CallState>.empty();
    return _callEvents ??= eventChannel
        .receiveBroadcastStream()
        .map((event) => CallState.fromMap(event as Map<dynamic, dynamic>?))
        .handleError((_) {}); // swallow platform stream errors
  }

  Future<bool> isDefaultDialer() => _invokeBool('isDefaultDialer');

  /// Collects (and clears) a number handed to the app via a dial/call intent —
  /// a missed-call notification's "Call back", a tapped `tel:` link. Returns the
  /// number and whether it should be placed immediately (`autoCall` true for an
  /// ACTION_CALL intent) or shown pre-filled in the dialer (`autoCall` false, for
  /// ACTION_DIAL/VIEW). Null when nothing is parked (or off Android). One-shot:
  /// the native side clears it on read so a re-poll can't dial it twice.
  Future<({String number, bool autoCall})?> getPendingDial() async {
    if (!_supported) return null;
    try {
      final map = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getPendingDial',
      );
      final number = (map?['number'] as String?)?.trim();
      if (number == null || number.isEmpty) return null;
      return (number: number, autoCall: map?['autoCall'] == true);
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.getPendingDial failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Arms a native Smart Redial alarm ([SmartRedialManager]) that auto-dials
  /// [phoneNumber] at [fireAt], reusing the same trusted auto-call path as the
  /// missed-call notification's "Call back" — so the call is placed even if
  /// this app process has been killed for the whole delay. Returns whether
  /// the alarm was actually armed — native only persists a task record on
  /// success, so a false here means nothing was scheduled at all (e.g. the
  /// exact-alarm permission isn't granted). Always false off Android.
  Future<bool> scheduleSmartRedial({
    required String id,
    required String phoneNumber,
    required String displayName,
    required DateTime fireAt,
    String? phoneAccountId,
    String? componentName,
  }) => _invokeBool('scheduleSmartRedial', {
    'id': id,
    'number': phoneNumber,
    'displayName': displayName,
    'fireAtMillis': fireAt.millisecondsSinceEpoch,
    // The SIM to dial on, decided now rather than when the alarm fires: the
    // retry is placed natively with nobody around to answer a SIM chooser.
    // Null lets Telecom use the system default.
    'phoneAccountId': phoneAccountId,
    'componentName': componentName,
  });

  /// Cancels a pending Smart Redial alarm by [id]. No-op if it already fired
  /// or was already cancelled (e.g. the contact called back first).
  Future<void> cancelSmartRedial(String id) =>
      _invokeVoid('cancelSmartRedial', {'id': id});

  /// Whether the app currently holds the "Alarms & reminders" permission
  /// Smart Redial's alarm needs (Android 13+ only; always true elsewhere/off
  /// Android). Without it, [scheduleSmartRedial] arms nothing.
  Future<bool> hasExactAlarmPermission() async {
    if (!_supported) return true;
    try {
      return await methodChannel.invokeMethod<bool>(
            'hasExactAlarmPermission',
          ) ??
          false;
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.hasExactAlarmPermission failed',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Opens the system "Alarms & reminders" settings screen for this app, so
  /// the user can grant [hasExactAlarmPermission] — there's no runtime
  /// request dialog for this one. No-op off Android.
  Future<void> requestExactAlarmPermission() =>
      _invokeVoid('requestExactAlarmPermission');

  /// Ids of every Smart Redial task still pending natively, so the Dart-side
  /// task list can reconcile itself (a task native auto-cancelled — the
  /// contact called back — or already fired won't appear here). Empty off
  /// Android.
  Future<Set<String>> pendingSmartRedialIds() async {
    if (!_supported) return const <String>{};
    try {
      final raw = await methodChannel.invokeMethod<List<dynamic>>(
        'getPendingSmartRedialIds',
      );
      return raw?.whereType<String>().toSet() ?? const <String>{};
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.pendingSmartRedialIds failed',
        error: e,
        stackTrace: st,
      );
      return const <String>{};
    }
  }

  /// Launches the system "default phone app" prompt (RoleManager on API 29+, the
  /// legacy TelecomManager intent below it). Resolves to the effective state.
  Future<bool> requestDefaultDialer() => _invokeBool('requestDefaultDialer');

  /// The device's call-capable SIMs / phone accounts. Empty off Android or when
  /// READ_PHONE_STATE hasn't been granted.
  Future<List<SimAccount>> getSimAccounts() async {
    if (!_supported) return const <SimAccount>[];
    try {
      final raw = await methodChannel.invokeMethod<List<dynamic>>(
        'getSimAccounts',
      );
      if (raw == null) return const <SimAccount>[];
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(SimAccount.fromMap)
          .where((s) => s.phoneAccountId.isNotEmpty)
          .toList();
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.getSimAccounts failed',
        error: e,
        stackTrace: st,
      );
      return const <SimAccount>[];
    }
  }

  /// Places a call through TelecomManager so it surfaces in our own in-call UI.
  /// When [sim] is given, routes the call over that SIM's phone account.
  /// Returns false when we're not the default dialer or the platform refused.
  Future<bool> placeCall(String number, {SimAccount? sim}) =>
      _invokeBool('placeCall', {
        'number': number,
        'phoneAccountId': sim?.phoneAccountId,
        'componentName': sim?.componentName,
      });

  /// Resolves a call parked in `SELECT_PHONE_ACCOUNT` onto [sim]. Used when we
  /// placed a call with no chosen SIM ("System default") and the OS has no default
  /// outgoing account, so Telecom asked us (the default dialer) to pick.
  Future<void> selectPhoneAccount(SimAccount sim) => _invokeVoid(
    'selectPhoneAccount',
    {'phoneAccountId': sim.phoneAccountId, 'componentName': sim.componentName},
  );

  /// Overrides the incoming-call ringtone with the tone at [path] (a file path
  /// or content URI). [source] is `'contact'` or `'sim'`; the native ringer
  /// resolves the tone from the mirror (see [setRingtoneMirror]) the instant a
  /// call arrives, so this late push is only a safety net for a stale mirror —
  /// it applies natively only when it upgrades the playing tone's tier
  /// (default < sim < contact) or corrects a different tone at the same tier,
  /// and never restarts a tone that is already playing. No-op off Android or
  /// when the ringer isn't sounding (silent / vibrate mode).
  Future<void> setIncomingRingtone(String path, {required String source}) =>
      _invokeVoid('setIncomingRingtone', {'path': path, 'source': source});

  /// Mirrors the ringtone maps to the native side so the incoming-call ringer can
  /// resolve the correct tone synchronously the instant a call arrives (before the
  /// Flutter engine is up on a cold start). [contactTones] maps the trailing
  /// digits of a phone number (see [ContactRepository.ringtoneMirrorEntries]) to a
  /// tone path/URI; [simTones] maps a phoneAccountId to a per-SIM tone;
  /// [contactNames] maps the same trailing digits (see
  /// [ContactRepository.contactNameMirrorEntries]) to a contact's display name so
  /// native can title a missed-call notification before the Flutter engine is up.
  /// Each map replaces the stored one wholesale; a null map leaves that side
  /// untouched. No-op off Android.
  Future<void> setRingtoneMirror({
    Map<String, String>? contactTones,
    Map<String, String>? simTones,
    Map<String, String>? contactNames,
  }) => _invokeVoid('setRingtoneMirror', {
    'contactTones': contactTones,
    'simTones': simTones,
    'contactNames': contactNames,
  });

  /// Mirrors the call-screening data to the native side so the
  /// CallScreeningService can decide synchronously — before the phone rings and
  /// before the Flutter engine is up on a cold start. [blockedNumbers] /
  /// [spamNumbers] are digit strings (of the E.164 form); each list replaces
  /// the stored one wholesale. [blockUnknown] / [spamFilter] mirror the
  /// Identification settings toggles. Null args leave that key untouched.
  /// No-op off Android.
  Future<void> setScreeningMirror({
    List<String>? blockedNumbers,
    List<String>? spamNumbers,
    bool? blockUnknown,
    bool? spamFilter,
  }) => _invokeVoid('setScreeningMirror', {
    'blockedNumbers': blockedNumbers,
    'spamNumbers': spamNumbers,
    'blockUnknown': blockUnknown,
    'spamFilter': spamFilter,
  });

  /// Collects (and clears) calls the native screening service rejected while
  /// the app wasn't running, as `(number, when)` records, oldest first. The
  /// native side parks them in its prefs; draining writes them into Recents.
  /// Empty off Android / when nothing was blocked.
  Future<List<({String number, DateTime when})>>
  drainBlockedCallEvents() async {
    if (!_supported) return const [];
    try {
      final raw = await methodChannel.invokeMethod<List<dynamic>>(
        'getBlockedCallEvents',
      );
      if (raw == null) return const [];
      final out = <({String number, DateTime when})>[];
      for (final e in raw.whereType<Map<dynamic, dynamic>>()) {
        final number = e['number'] as String?;
        final at = (e['at'] as num?)?.toInt();
        if (number == null || number.isEmpty || at == null) continue;
        out.add((
          number: number,
          when: DateTime.fromMillisecondsSinceEpoch(at),
        ));
      }
      return out;
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.drainBlockedCallEvents failed',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }

  /// Collects (and clears) the call-waiting calls the in-call service parked —
  /// incoming calls that ended while another call was live, so the snapshot
  /// logger (which tracks only the primary call) never saw them. Covers both
  /// answered calls (`wasActive` true, with a real `durationSeconds`) and misses
  /// (`wasActive` false, `durationSeconds` 0). Returns records oldest first;
  /// draining writes them into Recents. Empty off Android / when nothing was
  /// parked.
  Future<
    List<
      ({
        String number,
        DateTime when,
        String? phoneAccountId,
        bool wasActive,
        int durationSeconds,
      })
    >
  >
  drainCallWaitingEvents() async {
    if (!_supported) return const [];
    try {
      final raw = await methodChannel.invokeMethod<List<dynamic>>(
        'getMissedCallEvents',
      );
      if (raw == null) return const [];
      final out =
          <
            ({
              String number,
              DateTime when,
              String? phoneAccountId,
              bool wasActive,
              int durationSeconds,
            })
          >[];
      for (final e in raw.whereType<Map<dynamic, dynamic>>()) {
        final number = e['number'] as String?;
        final at = (e['at'] as num?)?.toInt();
        if (number == null || number.isEmpty || at == null) continue;
        out.add((
          number: number,
          when: DateTime.fromMillisecondsSinceEpoch(at),
          phoneAccountId: e['phoneAccountId'] as String?,
          wasActive: e['wasActive'] == true,
          durationSeconds: (e['duration'] as num?)?.toInt() ?? 0,
        ));
      }
      return out;
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.drainCallWaitingEvents failed',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }

  /// Collects (and clears) the outgoing-call outcomes the in-call service parked
  /// — calls the app didn't place through [CallLifecycleMixin], so nothing on
  /// this side was holding a pending record to latch the reason onto. Chiefly a
  /// Smart Redial retry, which is dialed natively and can fire with the app
  /// closed. `outcome` is an `AppCallOutcome` value and `when` is the call's
  /// creation time, matching how the device call log dates an outgoing call.
  /// Returns records oldest first; empty off Android / when nothing was parked.
  Future<List<({String number, DateTime when, String outcome})>>
  drainOutgoingOutcomeEvents() async {
    if (!_supported) return const [];
    try {
      final raw = await methodChannel.invokeMethod<List<dynamic>>(
        'getOutgoingOutcomeEvents',
      );
      if (raw == null) return const [];
      final out = <({String number, DateTime when, String outcome})>[];
      for (final e in raw.whereType<Map<dynamic, dynamic>>()) {
        final number = e['number'] as String?;
        final at = (e['at'] as num?)?.toInt();
        final outcome = e['outcome'] as String?;
        if (number == null || number.isEmpty || at == null) continue;
        if (outcome == null || outcome.isEmpty) continue;
        out.add((
          number: number,
          when: DateTime.fromMillisecondsSinceEpoch(at),
          outcome: outcome,
        ));
      }
      return out;
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.drainOutgoingOutcomeEvents failed',
        error: e,
        stackTrace: st,
      );
      return const [];
    }
  }

  /// Pushes an identification label for the current call (e.g. "Suspected
  /// spam", "Telemarketing") to the native side so the call notification can
  /// show it alongside the number. An empty [label] clears a previously pushed
  /// one. No-op off Android or when no call is present.
  Future<void> setCallerLabel(String label) =>
      _invokeVoid('setCallerLabel', {'label': label});

  /// Pushes the resolved contact [name] for the current call to the native side so
  /// the call notification (ringing or ongoing, incoming or outgoing) shows the
  /// contact's name instead of the raw number. Native only has the number; name
  /// resolution lives in Flutter. An empty [name] clears a previously pushed name
  /// (falls back to the number). No-op off Android or when no call is present.
  Future<void> setCallerName(String name) =>
      _invokeVoid('setCallerName', {'name': name});

  /// Mirrors the user's ringer preferences to the native side so the incoming-call
  /// ringer can read them synchronously the instant a call arrives (before the
  /// Flutter engine is up on a cold start). [volumePercent] is 0–100; [vibrate]
  /// toggles vibration. Null args leave that preference untouched. No-op off Android.
  Future<void> setRingerPrefs({int? volumePercent, bool? vibrate}) =>
      _invokeVoid('setRingerPrefs', {
        'volumePercent': volumePercent,
        'vibrate': vibrate,
      });

  /// Launches the Android system ringtone picker (built-in ringtones), pre-
  /// selecting [existingUri] when given. Returns the chosen tone as a
  /// `(path, label)` record, or null when the user cancelled / no tone was
  /// picked. `path` is a `content://` URI; `label` is the tone's display title.
  Future<({String path, String label})?> pickRingtone({
    String? existingUri,
  }) async {
    if (!_supported) return null;
    try {
      final map = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'pickRingtone',
        {'existingUri': existingUri},
      );
      final uri = map?['uri'] as String?;
      if (uri == null || uri.isEmpty) return null;
      final title = (map?['title'] as String?)?.trim();
      return (path: uri, label: (title == null || title.isEmpty) ? uri : title);
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.pickRingtone failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// The device's current default ringtone as a `(path, label)` record, or null
  /// when it can't be resolved (or off Android). Used to show the real default
  /// tone name where no override is set.
  Future<({String path, String label})?> defaultRingtone() async {
    if (!_supported) return null;
    try {
      final map = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getDefaultRingtone',
      );
      final uri = map?['uri'] as String?;
      if (uri == null || uri.isEmpty) return null;
      final title = (map?['title'] as String?)?.trim();
      return (path: uri, label: (title == null || title.isEmpty) ? uri : title);
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.defaultRingtone failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Launches the system document picker for an audio file and takes a persistable
  /// read grant on it, so the tone survives app restarts without copying the file.
  /// Returns the chosen file as a `(path, label)` record where `path` is a
  /// `content://` URI, or null when the user cancelled (or off Android).
  Future<({String path, String label})?> pickAudioDocument() async {
    if (!_supported) return null;
    try {
      final map = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'pickAudioDocument',
      );
      final uri = map?['uri'] as String?;
      if (uri == null || uri.isEmpty) return null;
      final title = (map?['title'] as String?)?.trim();
      return (path: uri, label: (title == null || title.isEmpty) ? uri : title);
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.pickAudioDocument failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Plays an in-app preview of the tone at [uri] (a file path or `content://`
  /// URI) through a native media player on the **ring** stream, with the same
  /// audio attributes and in-app volume scale as the incoming-call ringer — the
  /// preview sounds exactly like an actual call. Preview only — it doesn't
  /// touch the OS ringer. Loops until [stopRingtonePreview].
  ///
  /// Returns [RingtonePreviewStatus.missing] when the source can't be opened —
  /// e.g. a `content://` tone whose backing file was deleted/moved — so the
  /// caller can revert to the default tone. Always `missing` off Android.
  Future<RingtonePreviewStatus> previewRingtone(String uri) async {
    if (!_supported) return RingtonePreviewStatus.missing;
    try {
      final status = await methodChannel.invokeMethod<String>(
        'previewRingtone',
        {'uri': uri},
      );
      return switch (status) {
        'playing' => RingtonePreviewStatus.playing,
        'muted' => RingtonePreviewStatus.muted,
        _ => RingtonePreviewStatus.missing,
      };
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.previewRingtone failed',
        error: e,
        stackTrace: st,
      );
      return RingtonePreviewStatus.missing;
    }
  }

  /// Stops the native ringtone preview started by [previewRingtone].
  Future<void> stopRingtonePreview() => _invokeVoid('stopRingtonePreview');

  Future<void> answer() => _invokeVoid('answer');
  Future<void> disconnect() => _invokeVoid('disconnect');

  /// Answers the ringing *waiting* call (a second call arriving while another is
  /// active). Telecom auto-holds the active call. No-op unless a call is
  /// ringing while another is live.
  Future<void> answerWaiting() => _invokeVoid('answerWaiting');

  /// Declines the ringing *waiting* call, leaving the active call untouched.
  Future<void> rejectWaiting() => _invokeVoid('rejectWaiting');

  /// Rejects the ringing incoming call and asks Telecom to send [message] to
  /// the caller as an SMS. The OS sends the text itself (on the SIM the call
  /// arrived on), so no SMS permission is involved. No-op unless a call is
  /// ringing.
  Future<void> rejectWithMessage(String message) =>
      _invokeVoid('rejectWithMessage', {'message': message});
  Future<void> hold() => _invokeVoid('hold');
  Future<void> unhold() => _invokeVoid('unhold');
  Future<void> setMuted(bool muted) =>
      _invokeVoid('setMuted', {'muted': muted});
  Future<void> setSpeaker(bool on) => _invokeVoid('setSpeaker', {'on': on});

  /// Sends a DTMF touch-tone (a single character: 0-9, `*`, `#`) on the active
  /// call — for IVR menus and dial-in conference bridges. Pair with [stopDtmf]
  /// on key release.
  Future<void> playDtmf(String digit) =>
      _invokeVoid('playDtmf', {'digit': digit});

  /// Ends the DTMF tone started by [playDtmf].
  Future<void> stopDtmf() => _invokeVoid('stopDtmf');

  /// Conferences the foreground and background calls into one line. No-op unless
  /// the network reports conference support (see [CallState.canMerge]).
  Future<void> mergeCalls() => _invokeVoid('merge');

  /// Swaps which of two calls (or a conference and its held call) is foreground.
  Future<void> swapCalls() => _invokeVoid('swap');

  /// One-shot snapshot of the current call (or [CallState.none]).
  Future<CallState> activeCall() async {
    if (!_supported) return CallState.none;
    try {
      final map = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getActiveCall',
      );
      return CallState.fromMap(map);
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.activeCall failed',
        error: e,
        stackTrace: st,
      );
      return CallState.none;
    }
  }

  Future<bool> _invokeBool(String method, [Map<String, dynamic>? args]) async {
    if (!_supported) return false;
    try {
      return await methodChannel.invokeMethod<bool>(method, args) ?? false;
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.$method failed',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Future<void> _invokeVoid(String method, [Map<String, dynamic>? args]) async {
    if (!_supported) return;
    try {
      await methodChannel.invokeMethod<void>(method, args);
    } catch (e, st) {
      AppLogger.error(
        'TelecomService.$method failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}
