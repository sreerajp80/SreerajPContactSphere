// lib/models/caller_context.dart

/// A smart, relationship-aware context snapshot generated for an incoming or active call.
///
/// Combines relationship type, last spoke/interaction time, pending reminders/callbacks,
/// and upcoming birthdays or events to answer "Why is this person calling?".
class CallerContext {
  final int? contactId;
  final String contactName;

  /// Human-readable relationship from the user's perspective (e.g. "your cousin", "your father", "Colleague").
  final String? relationshipLabel;

  /// Human-readable time since last completed call or interaction (e.g. "Last spoke 3 weeks ago").
  final String? lastSpokeLabel;

  /// Exact date and time of the last call or interaction.
  final DateTime? lastSpokeTime;

  /// Uncompleted follow-up tasks or callbacks (e.g. ["You owe him a callback"]).
  final List<String> pendingReminders;

  /// Upcoming milestone/event (e.g. "Birthday next Tuesday", "Anniversary in 3 days").
  final String? upcomingEventLabel;

  /// Latest interaction note or sentiment snippet.
  final String? recentNote;

  const CallerContext({
    this.contactId,
    required this.contactName,
    this.relationshipLabel,
    this.lastSpokeLabel,
    this.lastSpokeTime,
    this.pendingReminders = const [],
    this.upcomingEventLabel,
    this.recentNote,
  });

  /// Whether there is any meaningful context available to show on the card.
  bool get hasContext =>
      (relationshipLabel != null && relationshipLabel!.isNotEmpty) ||
      (lastSpokeLabel != null && lastSpokeLabel!.isNotEmpty) ||
      pendingReminders.isNotEmpty ||
      (upcomingEventLabel != null && upcomingEventLabel!.isNotEmpty) ||
      (recentNote != null && recentNote!.isNotEmpty);

  /// Assembles a natural language headline summarizing why this contact is calling.
  /// Example: "Ravi — your cousin. Last spoke 3 weeks ago. You owe him a callback. Birthday next Tuesday."
  String buildSmartHeadline() {
    final parts = <String>[];

    // Name + Relationship
    if (relationshipLabel != null && relationshipLabel!.trim().isNotEmpty) {
      parts.add('$contactName — ${relationshipLabel!.trim()}');
    } else {
      parts.add(contactName);
    }

    // Last Spoke
    if (lastSpokeLabel != null && lastSpokeLabel!.trim().isNotEmpty) {
      parts.add(lastSpokeLabel!.trim());
    }

    // Pending Callback / Reminder
    if (pendingReminders.isNotEmpty) {
      final firstReminder = pendingReminders.first.trim();
      if (firstReminder.isNotEmpty) {
        parts.add(firstReminder);
      }
    }

    // Upcoming Event (Birthday / Anniversary)
    if (upcomingEventLabel != null && upcomingEventLabel!.trim().isNotEmpty) {
      parts.add(upcomingEventLabel!.trim());
    }

    // Join with sentence terminators or dots
    final buffer = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      buffer.write(part);
      if (!part.endsWith('.') && !part.endsWith('!')) {
        buffer.write('.');
      }
      if (i < parts.length - 1) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }
}
