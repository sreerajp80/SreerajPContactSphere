// lib/repositories/reminder_repository.dart
import 'package:smart_contacts_dialer/database/database_helper.dart';

/// Minimal write path for the `reminders` table, used by the post-call feedback
/// flow to stage an optional follow-up.
///
/// NOTE: per `docs/known-gaps.md`, nothing schedules notifications yet — a
/// reminder created here is **persisted only**. Surfacing/notifying it is out
/// of scope for the dialer work and remains a tracked gap.
class ReminderRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Inserts a reminder row and returns its id. [reminderTime] is written as an
  /// ISO-8601 string to stay consistent with the rest of the schema.
  Future<int> insert({
    required int contactId,
    required String reminderText,
    DateTime? reminderTime,
    String? location,
  }) async {
    final db = await _dbHelper.database;
    return db.insert('reminders', {
      'contact_id': contactId,
      'reminder_text': reminderText,
      'reminder_time': reminderTime?.toIso8601String(),
      'location': location,
      'is_completed': 0,
    });
  }
}
