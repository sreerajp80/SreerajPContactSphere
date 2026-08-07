// lib/repositories/interaction_repository.dart
import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/state/call_log_events.dart';

/// Write path for the `call_logs` and `interactions` tables.
///
/// These two tables are read by [PreCallSummaryService] and
/// [RelationshipScoringService] but nothing else populates them — this
/// repository is what makes those features have data to work with.
///
/// Calls are logged in two steps because `flutter_phone_direct_caller` returns
/// before the call completes: a provisional row at placement ([logCall] /
/// [logInteraction], duration unknown), then [updateCallOutcome] back-fills the
/// real duration/type/timestamp once the device call log is reconciled.
class InteractionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Inserts a `call_logs` row and returns its id. Timestamp is written as an
  /// ISO-8601 string (not the SQL `CURRENT_TIMESTAMP` default) because the
  /// services parse it with `DateTime.parse`. Pass [timestamp] to back-date a
  /// row (blocked calls drained after the fact); it defaults to now.
  Future<int> logCall({
    required int? contactId,
    required String phoneNumber,
    String callType = 'outgoing',
    String? callOutcome,
    int? duration,
    String? callIntent,
    String? simId,
    String? simLabel,
    DateTime? timestamp,
  }) async {
    final db = await _dbHelper.database;
    return db.insert('call_logs', {
      'contact_id': contactId,
      'phone_number': phoneNumber,
      'call_type': callType,
      'call_outcome': callOutcome,
      'duration': duration,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      'call_intent': callIntent,
      'sim_id': simId,
      'sim_label': simLabel,
    });
  }

  /// Inserts a `call_logs` row **unless the same call is already there**, and
  /// returns the id of the row that now represents the call.
  ///
  /// Recents is written from two sides: this app logs a call as it ends, and
  /// [CallLogImportService] pulls the same call out of the system call log. The
  /// import side has always matched against what is stored (same number, within
  /// [CallLogRepository.matchWindow]); the live side used to insert blindly, so
  /// whenever the import's read of the stored rows happened *before* the live
  /// insert landed, neither saw the other and one call became two rows. Missed
  /// calls hit this most often — the platform writes its call-log row the moment
  /// the ringing stops, which is exactly when the live logger is still resolving
  /// the SIM label and the contact.
  ///
  /// The look-up and the insert run in one transaction, so two concurrent
  /// writers can no longer both conclude "nothing is there".
  ///
  /// On a match the device-owned facts are filled in rather than overwritten:
  /// a value already on the row wins, and this only supplies what is missing.
  /// Outgoing calls never match an incoming/missed/blocked one (or the other way
  /// round), so a call placed to a number and a missed call from it moments later
  /// stay two rows.
  ///
  /// [logCall] remains the plain insert, for the provisional row the outgoing
  /// path writes at placement (which must always create a row to reconcile).
  Future<int> logCallIfNew({
    required int? contactId,
    required String phoneNumber,
    String callType = 'outgoing',
    String? callOutcome,
    int? duration,
    String? callIntent,
    String? simId,
    String? simLabel,
    DateTime? timestamp,
  }) async {
    final db = await _dbHelper.database;
    final when = timestamp ?? DateTime.now();
    final key = CallLogRepository.matchKey(phoneNumber);
    const window = CallLogRepository.matchWindow;

    return db.transaction<int>((txn) async {
      Map<String, Object?>? match;
      if (key.isNotEmpty) {
        final rows = await txn.query(
          'call_logs',
          where: 'timestamp >= ? AND timestamp <= ?',
          whereArgs: [
            when.subtract(window).toIso8601String(),
            when.add(window).toIso8601String(),
          ],
        );
        var bestDelta = window.inMilliseconds + 1;
        for (final row in rows) {
          if (CallLogRepository.matchKey(
                (row['phone_number'] as String?) ?? '',
              ) !=
              key) {
            continue;
          }
          if (_isOutgoing(row['call_type'] as String?) !=
              _isOutgoing(callType)) {
            continue;
          }
          final ts = DateTime.tryParse((row['timestamp'] as String?) ?? '');
          if (ts == null) continue;
          final delta = ts.difference(when).inMilliseconds.abs();
          if (delta < bestDelta) {
            bestDelta = delta;
            match = row;
          }
        }
      }

      final existing = match;
      if (existing == null) {
        return txn.insert('call_logs', {
          'contact_id': contactId,
          'phone_number': phoneNumber,
          'call_type': callType,
          'call_outcome': callOutcome,
          'duration': duration,
          'timestamp': when.toIso8601String(),
          'call_intent': callIntent,
          'sim_id': simId,
          'sim_label': simLabel,
        });
      }

      // Same call, already stored. Supply only what that row is missing. A
      // provisional row (no duration yet) also takes this call's type, since
      // its own was a guess.
      final wasProvisional = existing['duration'] == null;
      final patch = <String, Object?>{};
      final storedDuration = existing['duration'] as int?;
      if (duration != null &&
          (storedDuration == null || (storedDuration == 0 && duration > 0))) {
        patch['duration'] = duration;
      }
      if (wasProvisional) patch['call_type'] = callType;
      // Outcome only ever fills a gap. The other caller is the device-log
      // import, whose reading is derived from duration alone — and some devices
      // round a short answered call down to 0 seconds. Letting that overwrite
      // would stamp "No answer" on calls the app watched connect.
      if (existing['call_outcome'] == null && callOutcome != null) {
        patch['call_outcome'] = callOutcome;
      }
      if (contactId != null && existing['contact_id'] == null) {
        patch['contact_id'] = contactId;
      }
      if (_isBlank(existing['sim_id']) && simId != null && simId.isNotEmpty) {
        patch['sim_id'] = simId;
      }
      if (_isBlank(existing['sim_label']) &&
          simLabel != null &&
          simLabel.isNotEmpty) {
        patch['sim_label'] = simLabel;
      }
      if (_isBlank(existing['call_intent']) &&
          callIntent != null &&
          callIntent.isNotEmpty) {
        patch['call_intent'] = callIntent;
      }
      final id = existing['id'] as int;
      if (patch.isNotEmpty) {
        await txn.update('call_logs', patch, where: 'id = ?', whereArgs: [id]);
      }
      return id;
    });
  }

  /// Whether a stored/incoming call type is the outgoing direction. Everything
  /// else — incoming, missed, blocked, or an absent type — counts as inbound.
  static bool _isOutgoing(String? callType) => callType == 'outgoing';

  static bool _isBlank(Object? value) =>
      value == null || (value is String && value.trim().isEmpty);

  /// Inserts an `interactions` row and returns its id.
  Future<int> logInteraction({
    required int contactId,
    String interactionType = 'call',
    String? emotionalTone,
    int? duration,
  }) async {
    final db = await _dbHelper.database;
    return db.insert('interactions', {
      'contact_id': contactId,
      'interaction_type': interactionType,
      'timestamp': DateTime.now().toIso8601String(),
      'emotional_tone': emotionalTone,
      'duration': duration,
    });
  }

  /// Most-recent interaction timestamp per contact, in one `GROUP BY` query
  /// (avoids an N+1 over the contact list). Contacts with no interactions are
  /// simply absent from the map.
  Future<Map<int, DateTime>> lastInteractionByContact() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      'SELECT contact_id, MAX(timestamp) AS last_ts '
      'FROM interactions GROUP BY contact_id',
    );
    final result = <int, DateTime>{};
    for (final row in rows) {
      final id = row['contact_id'] as int?;
      final ts = row['last_ts'] as String?;
      if (id == null || ts == null) continue;
      final parsed = DateTime.tryParse(ts);
      if (parsed != null) result[id] = parsed;
    }
    return result;
  }

  /// Count of interactions per contact within [window] (default: last 30 days).
  /// Used to drive the lightweight "streak" badge on the contact list.
  Future<Map<int, int>> recentInteractionCountByContact({
    Duration window = const Duration(days: 30),
  }) async {
    final db = await _dbHelper.database;
    final since = DateTime.now().subtract(window).toIso8601String();
    final rows = await db.rawQuery(
      'SELECT contact_id, COUNT(*) AS cnt FROM interactions '
      'WHERE timestamp >= ? GROUP BY contact_id',
      [since],
    );
    final result = <int, int>{};
    for (final row in rows) {
      final id = row['contact_id'] as int?;
      final cnt = row['cnt'] as int?;
      if (id == null || cnt == null) continue;
      result[id] = cnt;
    }
    return result;
  }

  /// Back-fills the real outcome of a call onto the provisional rows created by
  /// [logCall] / [logInteraction]. Updates the `call_logs` row's
  /// duration/type/timestamp and, when [interactionId] is given, the matching
  /// `interaction` row's duration/timestamp — both in one transaction.
  ///
  /// [timestamp] is the call's real time (ISO-8601). When omitted the existing
  /// provisional timestamp is kept.
  ///
  /// [simId]/[simLabel] back-fill which SIM the call used when it wasn't known
  /// at placement (e.g. the system default was used) — only written when given.
  ///
  /// [callOutcome] is what actually happened on the call (see `AppCallOutcome`).
  /// This path is the app's own live observation, so unlike the device-log
  /// back-fill it *does* overwrite — it is the most reliable source there is.
  /// Written only when given, so a caller that doesn't know leaves it alone.
  Future<void> updateCallOutcome({
    required int callLogId,
    int? interactionId,
    required int duration,
    required String callType,
    String? callOutcome,
    String? timestamp,
    String? simId,
    String? simLabel,
  }) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.update(
        'call_logs',
        {
          'duration': duration,
          'call_type': callType,
          'call_outcome': ?callOutcome,
          'timestamp': ?timestamp,
          'sim_id': ?simId,
          'sim_label': ?simLabel,
        },
        where: 'id = ?',
        whereArgs: [callLogId],
      );
      if (interactionId != null) {
        await txn.update(
          'interactions',
          {'duration': duration, 'timestamp': ?timestamp},
          where: 'id = ?',
          whereArgs: [interactionId],
        );
      }
    });
    // Tell any open history view the row changed. Notifying after the
    // transaction commits (not before) means a listener that re-queries
    // immediately reads the new values.
    CallLogEvents.instance.notifyCallLogged();
  }

  /// Writes what the device call log knows onto an existing `call_logs` row,
  /// for a call the import matched to one the app had already logged.
  ///
  /// Only the facts the device owns are touched — duration, direction and which
  /// SIM carried the call. App-only fields (`call_intent`, notes, feedback,
  /// the contact link) are deliberately left alone, so back-filling a call
  /// never costs the user something they typed.
  ///
  /// [simId]/[simLabel] are written only when given, so a device log that
  /// doesn't report the SIM can't blank out one the app recorded at placement.
  ///
  /// [callOutcome] is the exception to "the device owns this": it is written
  /// **only when the row has none**. The device log infers the outcome from
  /// duration, and some devices round a short answered call down to 0 seconds,
  /// so letting it win would relabel calls the app watched connect as
  /// "No answer".
  Future<void> backfillFromDeviceLog({
    required int callLogId,
    required int duration,
    required String callType,
    String? callOutcome,
    DateTime? timestamp,
    String? simId,
    String? simLabel,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      'call_logs',
      {
        'duration': duration,
        'call_type': callType,
        'timestamp': ?timestamp?.toIso8601String(),
        'sim_id': ?simId,
        'sim_label': ?simLabel,
      },
      where: 'id = ?',
      whereArgs: [callLogId],
    );
    if (callOutcome != null) {
      await db.update(
        'call_logs',
        {'call_outcome': callOutcome},
        where: 'id = ? AND call_outcome IS NULL',
        whereArgs: [callLogId],
      );
    }
  }

  /// Writes an outcome the app observed live onto an existing `call_logs` row,
  /// and **only** when that row has none. Returns whether anything changed.
  ///
  /// Patch-only by design: this is the drain of the native outgoing-outcome
  /// journal (see `CallEventLogger.drainOutgoingOutcomes`), which reports why a
  /// call ended but knows nothing else about it. Creating rows stays with the
  /// device-log import, so this path can never add a second Recents entry for a
  /// call. Never overwriting means the reason latched by the screen that placed
  /// the call still wins, and a re-drain is harmless.
  Future<bool> backfillObservedOutcome({
    required int callLogId,
    required String callOutcome,
  }) async {
    final db = await _dbHelper.database;
    final changed = await db.update(
      'call_logs',
      {'call_outcome': callOutcome},
      where: 'id = ? AND call_outcome IS NULL',
      whereArgs: [callLogId],
    );
    return changed > 0;
  }

  /// Persists the user's post-call feedback onto the rows logged for a call:
  /// the sentiment ([tone]) lands on the `interactions` row so it feeds
  /// `RelationshipScoringService` (which weights `emotional_tone` at 30%), while
  /// the [intent] tag and free-text [notes] land on the `call_logs` row. All in
  /// one transaction. Null fields are left untouched.
  ///
  /// [tone] must be one of 'positive' | 'neutral' | 'negative' to affect
  /// scoring (the scorer switches on exactly those strings).
  Future<void> recordCallFeedback({
    required int callLogId,
    int? interactionId,
    String? tone,
    String? intent,
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      final callLogValues = <String, Object?>{
        'call_intent': ?intent,
        'notes': ?notes,
      };
      if (callLogValues.isNotEmpty) {
        await txn.update(
          'call_logs',
          callLogValues,
          where: 'id = ?',
          whereArgs: [callLogId],
        );
      }
      if (interactionId != null && tone != null) {
        await txn.update(
          'interactions',
          {'emotional_tone': tone},
          where: 'id = ?',
          whereArgs: [interactionId],
        );
      }
    });
  }
}
