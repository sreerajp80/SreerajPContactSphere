// lib/models/call_summary.dart
//
// A lightweight, read-only snapshot shown before placing a call to a contact.
// Built by [PreCallSummaryService] from the interactions/call_logs/contacts tables.
import 'package:smart_contacts_dialer/models/reach_window.dart';

class CallSummary {
  /// Most recent interaction rows (raw maps), newest first.
  final List<Map<String, dynamic>> recentInteractions;

  /// Duration in seconds of the last logged call, if any.
  final int? lastCallDuration;

  /// True if the contact's birthday falls within the next 7 days.
  final bool upcomingBirthday;

  /// Human-readable current time in the contact's timezone, if known.
  final String? currentTimeInContactTimezone;

  /// When calls to this contact usually get answered, or null when the history
  /// is too thin to say. Advice for the user only — it never triggers a call.
  final ReachWindow? bestTimeToReach;

  const CallSummary({
    this.recentInteractions = const [],
    this.lastCallDuration,
    this.upcomingBirthday = false,
    this.currentTimeInContactTimezone,
    this.bestTimeToReach,
  });

  bool get hasRecentInteractions => recentInteractions.isNotEmpty;
}
