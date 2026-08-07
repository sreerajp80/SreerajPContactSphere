// lib/services/reach_window_service.dart
import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/reach_window.dart';

/// Works out when calls to a contact actually get answered, from the app's own
/// Recents history (`call_logs`).
///
/// **Advice only.** This service never places, schedules or cancels a call, and
/// deliberately depends on nothing that can — no `TelecomService`, no
/// `url_launcher`, no `SmartRedialService`. Its two consumers both just display
/// or re-order: the pre-call summary line, and the dialer's "Likely to answer
/// now" ordering. Every resulting call is still a tap the user makes. Smart
/// Redial remains the only place the app dials on its own, because there the
/// user set the delay themselves.
class ReachWindowService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Calls needed before the app will say anything at all about a contact.
  static const int minTotalCalls = 8;

  /// Calls needed inside a window before it can win.
  static const int minWindowCalls = 3;

  /// How far the winning window's answer rate must sit above the contact's
  /// overall rate (0.20 = 20 percentage points). Without a margin this would
  /// dress up ordinary noise as a finding.
  static const double minMargin = 0.20;

  /// Only calls this recent are counted, so a habit from two years ago cannot
  /// outvote how someone behaves now.
  static const Duration lookback = Duration(days: 180);

  /// A row with no duration this recent is a call still in progress (logged when
  /// placed, reconciled afterwards), not an unanswered one.
  static const Duration provisionalGrace = Duration(minutes: 2);

  /// Cached per contact for the life of the service instance — a screen builds
  /// one, asks once or twice, and drops it.
  final Map<int, ReachWindow?> _cache = {};

  /// The day part [contactId] is most likely to answer in, or null when the
  /// history doesn't support saying anything. Callers show nothing on null.
  Future<ReachWindow?> bestWindow(int contactId) async {
    if (_cache.containsKey(contactId)) return _cache[contactId];
    final window = await _computeBestWindow(contactId);
    _cache[contactId] = window;
    return window;
  }

  /// Forgets cached results — call after the call history changes.
  void invalidate() => _cache.clear();

  Future<ReachWindow?> _computeBestWindow(int contactId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final rows = await db.query(
      'call_logs',
      columns: ['call_type', 'duration', 'timestamp'],
      where:
          'contact_id = ? AND timestamp >= ? '
          "AND (call_type IS NULL OR call_type != 'blocked')",
      whereArgs: [contactId, now.subtract(lookback).toIso8601String()],
    );

    final calls = <_Call>[];
    for (final r in rows) {
      final ts = r['timestamp'] as String?;
      if (ts == null) continue;
      // Timestamps are written as local-time ISO strings; toLocal() is a no-op
      // for those and corrects anything that arrived with a UTC 'Z'.
      final at = DateTime.tryParse(ts)?.toLocal();
      if (at == null) continue;
      final duration = r['duration'] as int?;
      if (duration == null &&
          now.difference(at).abs() < provisionalGrace) {
        continue; // still in progress
      }
      calls.add(_Call(at: at, answered: duration != null && duration > 0));
    }

    if (calls.length < minTotalCalls) return null;

    final overallRate =
        calls.where((c) => c.answered).length / calls.length;

    ReachWindow? best;
    for (final part in DayPart.values) {
      final inPart = calls.where((c) => part.contains(c.at.hour)).toList();
      if (inPart.length < minWindowCalls) continue;
      final rate = inPart.where((c) => c.answered).length / inPart.length;
      if (rate < overallRate + minMargin) continue;
      if (best != null &&
          (rate < best.answerRate ||
              (rate == best.answerRate && inPart.length <= best.sampleSize))) {
        continue;
      }
      best = ReachWindow(
        dayPart: part,
        scope: ReachScope.any,
        answerRate: rate,
        overallAnswerRate: overallRate,
        sampleSize: inPart.length,
        totalCalls: calls.length,
      );
    }

    if (best == null) return null;
    return _narrowScope(best, calls, overallRate);
  }

  /// Splits the winning window into weekdays and weekends, and keeps the split
  /// only when one side clearly beats the other. Otherwise the sentence stays
  /// plain — claiming "on weekdays" off two calls would be noise.
  ReachWindow _narrowScope(
    ReachWindow window,
    List<_Call> calls,
    double overallRate,
  ) {
    final inPart =
        calls.where((c) => window.dayPart.contains(c.at.hour)).toList();
    final weekend = inPart.where((c) => c.isWeekend).toList();
    final weekday = inPart.where((c) => !c.isWeekend).toList();
    if (weekend.length < minWindowCalls || weekday.length < minWindowCalls) {
      return window;
    }

    final weekendRate = weekend.where((c) => c.answered).length / weekend.length;
    final weekdayRate = weekday.where((c) => c.answered).length / weekday.length;
    final (scope, side, rate) = weekdayRate >= weekendRate + minMargin
        ? (ReachScope.weekdays, weekday, weekdayRate)
        : weekendRate >= weekdayRate + minMargin
        ? (ReachScope.weekends, weekend, weekendRate)
        : (ReachScope.any, inPart, window.answerRate);
    if (scope == ReachScope.any) return window;

    return ReachWindow(
      dayPart: window.dayPart,
      scope: scope,
      answerRate: rate,
      overallAnswerRate: overallRate,
      sampleSize: side.length,
      totalCalls: window.totalCalls,
    );
  }

  /// Contact ids whose answer rate in the *current* day part clears the same
  /// thresholds, best rate first — the ordering behind the dialer's "Likely to
  /// answer now" section. Returns an empty list when nobody qualifies, and the
  /// dialer then falls back to its usual list.
  ///
  /// One aggregate query rather than per-contact work, and no weekday/weekend
  /// split: this only decides the order of a handful of rows.
  Future<List<int>> contactIdsLikelyNow({int limit = 5}) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    const hourExpr = "CAST(strftime('%H', cl.timestamp) AS INTEGER)";
    final inWindow = DayPart.of(now.hour).sqlPredicate(hourExpr);

    final rows = await db.rawQuery(
      '''
      SELECT cl.contact_id AS contact_id,
             COUNT(*) AS total,
             SUM(CASE WHEN cl.duration > 0 THEN 1 ELSE 0 END) AS answered,
             SUM(CASE WHEN $inWindow THEN 1 ELSE 0 END) AS window_total,
             SUM(CASE WHEN $inWindow AND cl.duration > 0 THEN 1 ELSE 0 END)
               AS window_answered
      FROM call_logs cl
      JOIN contacts c ON c.id = cl.contact_id
      WHERE cl.contact_id IS NOT NULL
        AND cl.timestamp >= ?
        AND (cl.call_type IS NULL OR cl.call_type != 'blocked')
        AND NOT (cl.duration IS NULL AND cl.timestamp >= ?)
        AND c.is_secret = 0 AND c.is_favorite = 0
      GROUP BY cl.contact_id
      HAVING total >= ? AND window_total >= ?
      ''',
      [
        now.subtract(lookback).toIso8601String(),
        now.subtract(provisionalGrace).toIso8601String(),
        minTotalCalls,
        minWindowCalls,
      ],
    );

    final scored = <({int id, double rate})>[];
    for (final r in rows) {
      final total = (r['total'] as int?) ?? 0;
      final windowTotal = (r['window_total'] as int?) ?? 0;
      if (total == 0 || windowTotal == 0) continue;
      final overall = ((r['answered'] as int?) ?? 0) / total;
      final rate = ((r['window_answered'] as int?) ?? 0) / windowTotal;
      if (rate < overall + minMargin) continue;
      scored.add((id: r['contact_id'] as int, rate: rate));
    }
    scored.sort((a, b) => b.rate.compareTo(a.rate));
    return scored.take(limit).map((s) => s.id).toList();
  }
}

/// One counted call: when it happened and whether they picked up.
class _Call {
  _Call({required this.at, required this.answered});

  final DateTime at;
  final bool answered;

  bool get isWeekend =>
      at.weekday == DateTime.saturday || at.weekday == DateTime.sunday;
}
