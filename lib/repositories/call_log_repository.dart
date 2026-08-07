// lib/repositories/call_log_repository.dart
import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/call_record.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';

/// Read/management path for the `call_logs` table (the "Recents" history).
///
/// The write path stays in [InteractionRepository] (provisional logging +
/// outcome/feedback back-fill); this repository is purely for displaying and
/// pruning history.
class CallLogRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Recent calls, newest first, joined to the contact's name when linked.
  /// The contact name is assembled from the same columns `Contact.fullName`
  /// uses, so unknown numbers come back with a null `contact_name`.
  /// Pass [offset] to page further back in history — Recents loads the next
  /// page as the user scrolls, so a full device-log import stays reachable
  /// instead of being cut off at the first page.
  Future<List<CallRecord>> recentCalls({int limit = 300, int offset = 0}) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery(
      '''
      SELECT cl.*,
             c.photo_path AS photo_path,
             TRIM(
               COALESCE(c.salutation || ' ', '') ||
               COALESCE(c.first_name, '') ||
               COALESCE(' ' || c.middle_name, '') ||
               COALESCE(' ' || c.last_name, '')
             ) AS contact_name
      FROM call_logs cl
      LEFT JOIN contacts c ON c.id = cl.contact_id
      ORDER BY cl.timestamp DESC
      LIMIT ? OFFSET ?
      ''',
      [limit, offset],
    );
    return rows.map((r) {
      // An all-null name TRIMs to '' — normalise that back to null so the model
      // falls back to the raw number.
      final name = (r['contact_name'] as String?)?.trim();
      final normalized = Map<String, dynamic>.of(r);
      normalized['contact_name'] = (name == null || name.isEmpty) ? null : name;
      return CallRecord.fromJoinedMap(normalized);
    }).toList();
  }

  /// Calls matching [query], newest first — the Recents search.
  ///
  /// Matches the linked contact's name (as typed, or via the romanized
  /// `name_translit` / sound-only `name_phonetic` keys, so a Malayalam-spelled
  /// name is found by its English spelling) and the phone number itself
  /// (digits only, so `98 76` finds `+91 9876…`). Unknown numbers are still
  /// searchable — they match on the number alone. Returns nothing for a blank
  /// query; the caller shows the normal paged list instead.
  Future<List<CallRecord>> searchCalls(String query, {int limit = 500}) async {
    final q = query.trim();
    if (q.isEmpty) return const <CallRecord>[];

    final db = await _dbHelper.database;
    final like = '%${q.toLowerCase()}%';
    final digits = ContactRepository.normalizeDigits(q);
    final key = searchKey(q);
    final useTranslit = key.isNotEmpty;
    final code = phoneticCode(q);
    final usePhonetic = code.length >= phoneticCodeMinLen;

    final rows = await db.rawQuery(
      '''
      SELECT cl.*,
             c.photo_path AS photo_path,
             TRIM(
               COALESCE(c.salutation || ' ', '') ||
               COALESCE(c.first_name, '') ||
               COALESCE(' ' || c.middle_name, '') ||
               COALESCE(' ' || c.last_name, '')
             ) AS contact_name
      FROM call_logs cl
      LEFT JOIN contacts c ON c.id = cl.contact_id
      WHERE
        LOWER(TRIM(
          COALESCE(c.salutation || ' ', '') || COALESCE(c.first_name, '') ||
          COALESCE(' ' || c.middle_name, '') || COALESCE(' ' || c.last_name, '')
        )) LIKE ?
        OR REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
             cl.phone_number, ' ', ''), '-', ''), '(', ''), ')', ''), '+', ''), '.', '')
           LIKE ?
        OR LOWER(COALESCE(c.formal_name, '')) LIKE ?
        ${useTranslit ? "OR c.name_translit LIKE ? OR c.name_translit LIKE ?" : ''}
        ${usePhonetic ? "OR c.name_phonetic LIKE ? OR c.name_phonetic LIKE ?" : ''}
      ORDER BY cl.timestamp DESC
      LIMIT ?
      ''',
      [
        like,
        // An empty digit query must match nothing, not everything — '%%' would
        // return the whole history for a letters-only search.
        digits.isEmpty ? ' ' : '%$digits%',
        like,
        if (useTranslit) ...['$key%', '% $key%'],
        if (usePhonetic) ...['$code%', '% $code%'],
        limit,
      ],
    );
    return rows.map((r) {
      final name = (r['contact_name'] as String?)?.trim();
      final normalized = Map<String, dynamic>.of(r);
      normalized['contact_name'] = (name == null || name.isEmpty) ? null : name;
      return CallRecord.fromJoinedMap(normalized);
    }).toList();
  }

  /// The already-stored calls, as lightweight records for matching a device
  /// call-log entry against them during an import.
  ///
  /// Matching is by number *and a time window* rather than an exact timestamp:
  /// a call the app logged live and the same call in the device log are written
  /// seconds apart, so an exact-millisecond key treated them as two different
  /// calls and the import inserted a twin of every call already in Recents.
  ///
  /// Only calls at or after [since] are returned when given, so an incremental
  /// sync doesn't load the whole history to match a handful of new rows.
  Future<List<StoredCall>> storedCallsForMatching({DateTime? since}) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'call_logs',
      columns: [
        'id',
        'phone_number',
        'timestamp',
        'duration',
        'call_type',
        'call_outcome',
      ],
      where: since != null ? 'timestamp >= ?' : null,
      whereArgs: since != null ? [since.toIso8601String()] : null,
    );
    final calls = <StoredCall>[];
    for (final r in rows) {
      final ts = r['timestamp'] as String?;
      if (ts == null) continue;
      final parsed = DateTime.tryParse(ts);
      if (parsed == null) continue;
      calls.add(
        StoredCall(
          id: r['id'] as int,
          matchKey: matchKey((r['phone_number'] as String?) ?? ''),
          epochMillis: parsed.millisecondsSinceEpoch,
          duration: r['duration'] as int?,
          callType: r['call_type'] as String?,
          callOutcome: r['call_outcome'] as String?,
        ),
      );
    }
    return calls;
  }

  /// The number part of a call match: the last [_matchDigits] digits, so the
  /// `+91…`, `0…` and bare forms of one number all match. Shorter numbers
  /// (short codes) match on everything they have.
  static String matchKey(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) {
      if (digits.length <= _matchDigits) return digits;
      return digits.substring(digits.length - _matchDigits);
    }
    return number.trim().toUpperCase();
  }

  /// Trailing digits compared when matching two records of one call. Ten, the
  /// same width the native number mirror uses — seven collides between real
  /// Indian mobile numbers.
  static const int _matchDigits = 10;

  /// How far apart two records of the same call may be. The app logs a call when
  /// it is *placed*; the device logs it with the moment it actually started, and
  /// dialing/connecting sits in between.
  static const Duration matchWindow = Duration(seconds: 90);

  /// Finds the stored call that [candidates] says is the same call as the device
  /// entry with [key] at [epochMillis], or null when this is a new call. When
  /// several are in the window the closest in time wins.
  static StoredCall? findMatch(
    List<StoredCall> candidates,
    String key,
    int epochMillis,
  ) {
    if (key.isEmpty) return null;
    StoredCall? best;
    var bestDelta = matchWindow.inMilliseconds + 1;
    for (final c in candidates) {
      if (c.matchKey != key) continue;
      final delta = (c.epochMillis - epochMillis).abs();
      if (delta < bestDelta) {
        best = c;
        bestDelta = delta;
      }
    }
    return best;
  }

  /// Collapses Recents rows that are two records of **one** call, and returns
  /// how many rows were removed.
  ///
  /// Until the live logger started deduping, a call could be written twice — once
  /// by the app as the call ended and once by the device-log import — whenever
  /// the two crossed. This repairs the rows that were already written that way;
  /// new calls can no longer produce them (see
  /// [InteractionRepository.logCallIfNew]).
  ///
  /// Two rows are the same call when they share a [matchKey], sit within
  /// [matchWindow] of each other, and are on the same side of the
  /// outgoing/inbound line. The **oldest** row survives — it is the one the user
  /// may have attached a note, intent or feedback to — and takes anything it was
  /// missing (duration, call type, SIM, contact link) from the row being dropped.
  Future<int> mergeDuplicateCalls() async {
    final db = await _dbHelper.database;
    return db.transaction<int>((txn) async {
      final rows = await txn.query('call_logs', orderBy: 'timestamp ASC, id ASC');
      // Survivor per (match key + direction), tracked with the time it sits at
      // so a long run of calls to one number only merges the close pairs.
      final kept = <String, Map<String, Object?>>{};
      final keptAt = <String, DateTime>{};
      final removed = <int>[];

      for (final row in rows) {
        final ts = DateTime.tryParse((row['timestamp'] as String?) ?? '');
        final number = (row['phone_number'] as String?) ?? '';
        final key = matchKey(number);
        if (ts == null || key.isEmpty) continue;
        final type = row['call_type'] as String?;
        final bucket = '$key|${type == 'outgoing' ? 'out' : 'in'}';

        final previous = kept[bucket];
        final previousAt = keptAt[bucket];
        if (previous == null ||
            previousAt == null ||
            ts.difference(previousAt).abs() > matchWindow) {
          // A copy: sqflite hands back read-only rows, and the survivor is
          // updated in place as later duplicates fold into it.
          kept[bucket] = Map<String, Object?>.of(row);
          keptAt[bucket] = ts;
          continue;
        }

        // Same call as the survivor: fold anything it lacks onto it, drop this.
        final patch = <String, Object?>{};
        final keptDuration = previous['duration'] as int?;
        final duration = row['duration'] as int?;
        if (duration != null &&
            (keptDuration == null || (keptDuration == 0 && duration > 0))) {
          patch['duration'] = duration;
        }
        // A row with no duration was provisional; the other row's type is the
        // one that was actually observed.
        if (keptDuration == null && type != null) patch['call_type'] = type;
        if (previous['contact_id'] == null && row['contact_id'] != null) {
          patch['contact_id'] = row['contact_id'];
        }
        for (final column in ['sim_id', 'sim_label', 'call_intent']) {
          final existing = previous[column];
          final incoming = row[column];
          final blank =
              existing == null ||
              (existing is String && existing.trim().isEmpty);
          final hasValue =
              incoming != null &&
              !(incoming is String && incoming.trim().isEmpty);
          if (blank && hasValue) patch[column] = incoming;
        }
        if (patch.isNotEmpty) {
          await txn.update(
            'call_logs',
            patch,
            where: 'id = ?',
            whereArgs: [previous['id']],
          );
          previous.addAll(patch);
        }
        removed.add(row['id'] as int);
      }

      for (final id in removed) {
        await txn.delete('call_logs', where: 'id = ?', whereArgs: [id]);
      }
      return removed.length;
    });
  }

  /// Deletes a single call-history row.
  Future<void> deleteCall(int id) async {
    final db = await _dbHelper.database;
    await db.delete('call_logs', where: 'id = ?', whereArgs: [id]);
  }

  /// Clears the entire call history.
  Future<void> clearHistory() async {
    final db = await _dbHelper.database;
    await db.delete('call_logs');
  }
}

/// A stored call reduced to what matching a device call-log entry needs: which
/// row it is, the number to compare, when it happened, and what the app already
/// knows about it (so an import can tell "nothing to add" from "fill this in").
class StoredCall {
  const StoredCall({
    required this.id,
    required this.matchKey,
    required this.epochMillis,
    required this.duration,
    required this.callType,
    this.callOutcome,
  });

  final int id;

  /// Trailing digits of the number — see [CallLogRepository.matchKey].
  final String matchKey;

  final int epochMillis;

  /// Null while the call is still provisional (placed, not yet reconciled).
  final int? duration;

  final String? callType;

  /// What happened on the call — see `AppCallOutcome`. Null when the row
  /// predates the column, or when nothing has settled it yet.
  final String? callOutcome;

  /// Whether this row is still waiting for the real outcome, i.e. an import has
  /// something worth writing onto it. A row with a duration but no outcome
  /// counts: it was stored before the outcome column existed, and the import is
  /// the only thing that will ever fill it in.
  bool get needsOutcome => duration == null || callOutcome == null;
}
