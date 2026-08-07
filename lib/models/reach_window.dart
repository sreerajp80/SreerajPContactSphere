// lib/models/reach_window.dart
//
// When calls to a contact actually get answered, measured from the app's own
// Recents history. Built by [ReachWindowService].
//
// This is **advice only**. Nothing here schedules or places a call — it exists
// to print one line on the pre-call summary and to re-order the dialer's Top
// contacts section. Auto-dialing lives solely in Smart Redial, where the user
// sets the delay themselves.

/// A part of the day that calls are bucketed into.
///
/// Day parts rather than raw hours: a personal call history has far too few
/// calls per hour for an hourly split to mean anything.
enum DayPart {
  morning(6, 12, 'in the morning'),
  afternoon(12, 17, 'in the afternoon'),
  evening(17, 21, 'after 5pm'),

  /// Wraps midnight — 21:00 through 05:59.
  night(21, 6, 'late in the evening');

  const DayPart(this.startHour, this.endHour, this.phrase);

  /// First hour in the part (inclusive).
  final int startHour;

  /// First hour *after* the part (exclusive). Smaller than [startHour] for
  /// [night], which wraps past midnight.
  final int endHour;

  /// How the part is described to the user, e.g. "after 5pm".
  final String phrase;

  /// Whether [hour] (0–23, local) falls in this part.
  bool contains(int hour) => startHour < endHour
      ? hour >= startHour && hour < endHour
      : hour >= startHour || hour < endHour;

  /// The part [hour] (0–23, local) belongs to.
  static DayPart of(int hour) =>
      DayPart.values.firstWhere((p) => p.contains(hour));

  /// A SQLite predicate selecting rows in this part, over an integer hour
  /// expression such as `CAST(strftime('%H', timestamp) AS INTEGER)`. Kept here
  /// so the SQL and Dart bucketing can never drift apart.
  String sqlPredicate(String hourExpr) => startHour < endHour
      ? '($hourExpr >= $startHour AND $hourExpr < $endHour)'
      : '($hourExpr >= $startHour OR $hourExpr < $endHour)';
}

/// Which days a window was measured over.
enum ReachScope {
  /// Every day — weekdays and weekends behave alike.
  any(''),
  weekdays(' on weekdays'),
  weekends(' at weekends');

  const ReachScope(this.suffix);

  /// Text appended to the sentence, e.g. " on weekdays".
  final String suffix;
}

/// The day part a contact is most likely to answer in.
///
/// Only produced when the history genuinely supports it — see the thresholds in
/// `ReachWindowService`. When it doesn't, callers get null and show nothing,
/// which is much better than a confident wrong guess.
class ReachWindow {
  const ReachWindow({
    required this.dayPart,
    required this.scope,
    required this.answerRate,
    required this.overallAnswerRate,
    required this.sampleSize,
    required this.totalCalls,
  });

  final DayPart dayPart;
  final ReachScope scope;

  /// Share of calls in this window that were answered, 0.0–1.0.
  final double answerRate;

  /// Share answered across all of the contact's counted calls, 0.0–1.0.
  final double overallAnswerRate;

  /// Calls counted inside this window.
  final int sampleSize;

  /// Calls counted for the contact overall.
  final int totalCalls;

  /// The line shown to the user, e.g. "Usually answers after 5pm on weekdays".
  String get sentence => 'Usually answers ${dayPart.phrase}${scope.suffix}';

  /// Whether [when] (local) falls inside this window, used to order the dialer's
  /// Top contacts by who is reachable right now.
  bool matches(DateTime when) {
    if (!dayPart.contains(when.hour)) return false;
    final isWeekend =
        when.weekday == DateTime.saturday || when.weekday == DateTime.sunday;
    return switch (scope) {
      ReachScope.any => true,
      ReachScope.weekdays => !isWeekend,
      ReachScope.weekends => isWeekend,
    };
  }
}
