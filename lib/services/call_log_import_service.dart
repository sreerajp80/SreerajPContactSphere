// lib/services/call_log_import_service.dart
//
// Brings the phone's system call log (Android's `CallLog` content provider)
// into the app's own `call_logs` table — the "Recents" history. This is the
// pull-only counterpart to the contact sync: there is no push direction because
// Android owns the system call log and records calls automatically.
//
// The app also builds Recents *forward* from live call events (CallEventLogger
// / CallService), but that only ever sees calls made while the app is running
// and involved. Anything else — a call from another dialer, from the lock
// screen, or while the app was killed — reaches Recents only through here, so
// [syncFromDevice] runs automatically rather than waiting to be asked.
//
// Two entry points:
//   * [syncFromDevice]  — incremental, automatic, cheap. Reads only what is new.
//   * [importFromDevice] — the manual Settings actions, including the
//     destructive "replace Recents with the phone's log".

import 'package:call_log/call_log.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';
import 'package:smart_contacts_dialer/core/utils/call_log_write_lock.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/state/call_log_events.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';

/// What one import/sync pass did. [failed] separates "the phone's call log
/// couldn't be read" from "there was nothing new" — the two used to look the
/// same to the caller, so a permission problem was reported as "up to date".
class CallLogImportResult {
  const CallLogImportResult({
    this.inserted = 0,
    this.updated = 0,
    this.failed = false,
  });

  /// New calls added to Recents.
  final int inserted;

  /// Calls already in Recents that got their real duration/direction filled in.
  final int updated;

  /// True when the device call log could not be read at all.
  final bool failed;

  bool get changedAnything => inserted > 0 || updated > 0;
}

class CallLogImportService {
  CallLogImportService({
    InteractionRepository? interactions,
    CallLogRepository? callLogs,
    ContactRepository? contacts,
  }) : _interactions = interactions ?? InteractionRepository(),
       _callLogs = callLogs ?? CallLogRepository(),
       _contacts = contacts ?? ContactRepository();

  final InteractionRepository _interactions;
  final CallLogRepository _callLogs;
  final ContactRepository _contacts;

  /// Guards against two syncs running at once — Recents opening, the app
  /// resuming and a call ending can all land within the same moment.
  static bool _syncing = false;

  /// When the last sync ran, for the throttle below.
  static DateTime? _lastSyncAt;

  /// Minimum gap between routine syncs. Switching tabs shouldn't re-query the
  /// content provider every time. A call ending passes `force: true` to skip it.
  static const Duration _throttle = Duration(seconds: 15);

  /// How far back a sync re-checks, on top of the stored watermark. Android can
  /// write a call-log row a little after the call, and its timestamp is the
  /// call's start — so a call in progress when the last sync ran can land
  /// "before" the watermark. The window de-dupe makes the overlap free.
  static const Duration _resyncOverlap = Duration(days: 2);

  /// Pulls in whatever the phone has logged since the last sync.
  ///
  /// Cheap enough to call on every Recents open, app resume and call end: it
  /// asks the device only for calls newer than the stored watermark (minus a
  /// small overlap), and does nothing at all if it ran moments ago.
  ///
  /// Pass [force] when the user just finished a call — that must show up
  /// immediately, throttle or not. Never throws.
  Future<CallLogImportResult> syncFromDevice({bool force = false}) async {
    if (_syncing) return const CallLogImportResult();
    final last = _lastSyncAt;
    if (!force && last != null && DateTime.now().difference(last) < _throttle) {
      return const CallLogImportResult();
    }
    _syncing = true;
    try {
      final syncedThrough = await AppSettings.readCallLogSyncedThrough();
      // First ever run: no watermark, so take the whole device log once.
      final from = syncedThrough?.subtract(_resyncOverlap);
      return await CallLogWriteLock.run(() => _ingest(from: from));
    } catch (e, st) {
      AppLogger.error(
        'CallLogImportService.syncFromDevice failed',
        error: e,
        stackTrace: st,
      );
      return const CallLogImportResult(failed: true);
    } finally {
      _lastSyncAt = DateTime.now();
      _syncing = false;
    }
  }

  /// The manual Settings action: imports the device call log into Recents.
  ///
  /// When [replace] is true the app's call history is cleared first, giving a
  /// clean mirror of the device log (and losing call notes/feedback saved in the
  /// app). Otherwise entries are merged: a device call that matches one already
  /// in Recents fills in that row rather than adding a second copy of it.
  Future<CallLogImportResult> importFromDevice({bool replace = false}) async {
    try {
      if (replace) {
        await _callLogs.clearHistory();
        await AppSettings.clearCallLogSyncedThrough();
      }
      return await CallLogWriteLock.run(() => _ingest(from: null));
    } catch (e, st) {
      AppLogger.error(
        'CallLogImportService.importFromDevice failed',
        error: e,
        stackTrace: st,
      );
      return const CallLogImportResult(failed: true);
    }
  }

  /// Reads the device call log (everything, or only from [from]) and folds it
  /// into `call_logs`, then advances the sync watermark.
  Future<CallLogImportResult> _ingest({required DateTime? from}) async {
    final Iterable<CallLogEntry> entries;
    try {
      // The call_log plugin raises its own READ_CALL_LOG prompt when it needs
      // one, so there is no permission check here to get wrong. A refusal comes
      // back as an error, which is a *failure* — not "nothing new".
      entries = from == null
          ? await CallLog.get()
          : await CallLog.query(dateFrom: from.millisecondsSinceEpoch);
    } catch (e, st) {
      AppLogger.error(
        'CallLogImportService: reading the device call log failed',
        error: e,
        stackTrace: st,
      );
      return const CallLogImportResult(failed: true);
    }

    // Only calls that could plausibly match a device entry need loading: the
    // window reaches at most `matchWindow` before the oldest entry we asked for.
    final since = from?.subtract(CallLogRepository.matchWindow);
    final existing = await _callLogs.storedCallsForMatching(since: since);

    final iso = await AppSettings.readDefaultCountryIso();

    var inserted = 0;
    var updated = 0;
    DateTime? newest;

    for (final e in entries) {
      final rawNumber = e.number?.trim() ?? '';
      final number = rawNumber.isEmpty ? 'Unknown' : rawNumber;
      final millis = e.timestamp;
      if (millis == null) continue;
      final ts = DateTime.fromMillisecondsSinceEpoch(millis);
      if (newest == null || ts.isAfter(newest)) newest = ts;

      final callType = mapDeviceCallType(e.callType);
      final duration = e.duration ?? 0;
      // What the device log can say about the outcome. Weaker than what the app
      // observes live (a short answered call can be logged as 0 seconds), so
      // every write below only fills a gap — see [backfillFromDeviceLog].
      final callOutcome = mapDeviceCallOutcome(e.callType, e.duration);
      final key = CallLogRepository.matchKey(number);

      final match = CallLogRepository.findMatch(
        existing, key, millis,
        isOutgoing: CallLogRepository.isOutgoingType(callType),
      );
      if (match != null) {
        // Already in Recents. Fill in what the device knows and the app may not
        // (a provisional row has no duration yet, and its direction is a guess).
        if (match.needsOutcome ||
            match.duration != duration ||
            match.callType != callType) {
          await _interactions.backfillFromDeviceLog(
            callLogId: match.id,
            duration: duration,
            callType: callType,
            callOutcome: callOutcome,
            timestamp: ts,
            simId: e.phoneAccountId,
            simLabel: e.simDisplayName,
          );
          updated++;
        }
        continue;
      }

      final contactId = await _resolveContactId(number, iso);
      final id = await _interactions.logCall(
        contactId: contactId,
        phoneNumber: number,
        callType: callType,
        callOutcome: callOutcome,
        duration: duration,
        simId: e.phoneAccountId,
        simLabel: e.simDisplayName,
        timestamp: ts,
      );
      // Track it so a duplicate later in this same batch matches too.
      existing.add(
        StoredCall(
          id: id,
          matchKey: key,
          epochMillis: millis,
          duration: duration,
          callType: callType,
          callOutcome: callOutcome,
        ),
      );
      inserted++;
    }

    if (newest != null) {
      await AppSettings.writeCallLogSyncedThrough(newest);
    }

    final result = CallLogImportResult(inserted: inserted, updated: updated);
    if (result.changedAnything) CallLogEvents.instance.notifyCallLogged();
    return result;
  }

  /// Resolves a number to a contact id (E.164 match under the default country),
  /// mirroring the loggers; null when unlinked or on any failure.
  Future<int?> _resolveContactId(String number, String iso) async {
    try {
      final matches = await _contacts.findByFullNumber(number, defaultIso: iso);
      if (matches.isEmpty) return null;
      return matches.first.contactId;
    } catch (_) {
      return null;
    }
  }
}
