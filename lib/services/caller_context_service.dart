// lib/services/caller_context_service.dart
import 'package:intl/intl.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/caller_context.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';

/// Service that stitches relationships, call history, interactions, pending reminders,
/// and upcoming events (birthdays/anniversaries) to construct a [CallerContext]
/// answering "Why is this person calling?".
class CallerContextService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ContactRepository _contactRepository = ContactRepository();

  /// Builds a [CallerContext] for a phone number by resolving it against contacts.
  /// Returns null if no contact is matched for the number.
  Future<CallerContext?> getCallerContextByNumber(
    String number, {
    String? defaultIso,
    DateTime? notAfter,
  }) async {
    if (number.trim().isEmpty) return null;
    final iso = defaultIso ?? await AppSettings.readDefaultCountryIso();
    final matches = await _contactRepository.findByFullNumber(
      number,
      defaultIso: iso,
    );
    if (matches.isEmpty) return null;

    final match = matches.first;
    return getCallerContextByContactId(
      match.contactId,
      contactName: match.contactName,
      notAfter: notAfter,
    );
  }

  /// Builds a [CallerContext] for a specific contact ID.
  ///
  /// [notAfter] cuts off the "last spoke" history: only calls/interactions
  /// strictly older than it count. Pass the current call's start time to keep a
  /// call that is happening right now out of its own context card.
  Future<CallerContext?> getCallerContextByContactId(
    int contactId, {
    String? contactName,
    DateTime? notAfter,
  }) async {
    final db = await _dbHelper.database;

    // 1. Fetch Contact row if name is missing or for important dates
    final contactRows = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
      limit: 1,
    );

    if (contactRows.isEmpty) return null;
    final contactMap = contactRows.first;

    final resolvedName = (contactName != null && contactName.isNotEmpty)
        ? contactName
        : _constructFullName(contactMap);

    // 2. Resolve Relationship Label
    final relationshipLabel = await _resolveRelationshipLabel(db, contactId);

    // 3. Resolve Last Spoke / Interaction Time
    final lastSpokeInfo = await _resolveLastSpoke(
      db,
      contactId,
      notAfter: notAfter,
    );

    // 4. Resolve Pending Reminders
    final pendingReminders = await _resolvePendingReminders(db, contactId);

    // 5. Resolve Upcoming Events (Birthday / Anniversary / Meetiversary)
    final upcomingEvent = _resolveUpcomingEvent(contactMap);

    // 6. Resolve Recent Note / Sentiment
    final recentNote = await _resolveRecentNote(db, contactId);

    return CallerContext(
      contactId: contactId,
      contactName: resolvedName,
      relationshipLabel: relationshipLabel,
      lastSpokeLabel: lastSpokeInfo?.label,
      lastSpokeTime: lastSpokeInfo?.timestamp,
      pendingReminders: pendingReminders,
      upcomingEventLabel: upcomingEvent,
      recentNote: recentNote,
    );
  }

  String _constructFullName(Map<String, dynamic> c) {
    final parts = [
      c['salutation'],
      c['first_name'],
      c['middle_name'],
      c['last_name'],
    ].where((e) => e != null && (e as String).trim().isNotEmpty).join(' ');

    return parts.isEmpty ? 'Unknown' : parts;
  }

  /// Finds the relationship from the user's perspective.
  Future<String?> _resolveRelationshipLabel(
    dynamic db,
    int contactId,
  ) async {
    // Check if user has designated a "self" contact
    final selfRows = await db.query(
      'contacts',
      columns: ['id'],
      where: 'is_self = 1',
      limit: 1,
    );

    String? rawType;
    if (selfRows.isNotEmpty) {
      final selfId = selfRows.first['id'] as int;
      final relRows = await db.query(
        'relationships',
        columns: ['relationship_type'],
        where: 'contact_id = ? AND related_contact_id = ?',
        whereArgs: [selfId, contactId],
        limit: 1,
      );
      if (relRows.isNotEmpty) {
        rawType = relRows.first['relationship_type'] as String?;
      }
    }

    // Fallback: check any relationship row involving this contact
    if (rawType == null || rawType.trim().isEmpty) {
      final relRows = await db.query(
        'relationships',
        columns: ['relationship_type'],
        where: 'related_contact_id = ? OR contact_id = ?',
        whereArgs: [contactId, contactId],
        limit: 1,
      );
      if (relRows.isNotEmpty) {
        rawType = relRows.first['relationship_type'] as String?;
      }
    }

    if (rawType == null || rawType.trim().isEmpty) return null;

    return formatRelationshipPerspective(rawType.trim());
  }

  /// Formats raw relationship types like "Cousin", "Father", "Colleague"
  /// into conversational phrases like "your cousin", "your father".
  static String formatRelationshipPerspective(String rawType) {
    final lower = rawType.toLowerCase();

    if (lower.startsWith('your ')) return rawType;

    // List of relationship terms that sound natural with "your"
    const prefixable = {
      'father',
      'mother',
      'son',
      'daughter',
      'child',
      'parent',
      'brother',
      'sister',
      'elder brother',
      'younger brother',
      'elder sister',
      'younger sister',
      'sibling',
      'spouse',
      'partner',
      'grandfather',
      'grandmother',
      'grandparent',
      'grandchild',
      'grandson',
      'granddaughter',
      'uncle',
      'aunt',
      'nephew',
      'niece',
      'cousin',
      'cousin brother',
      'cousin sister',
      'father-in-law',
      'mother-in-law',
      'son-in-law',
      'daughter-in-law',
      'brother-in-law',
      'sister-in-law',
      'step-father',
      'step-mother',
      'step-son',
      'step-daughter',
      'step-brother',
      'step-sister',
      'friend',
      'colleague',
      'neighbour',
      'relative',
      'boss',
      'doctor',
      'teacher',
      'manager',
    };

    if (prefixable.contains(lower)) {
      return 'your ${lower.replaceAll('cousin brother', 'cousin').replaceAll('cousin sister', 'cousin')}';
    }

    return rawType;
  }

  /// Fetches the latest timestamp from `call_logs` and `interactions`.
  ///
  /// Only calls that were really conversations count: answered, non-zero
  /// duration, incoming or outgoing. That filter is also what keeps the call in
  /// progress out of its own card — an outgoing call writes a provisional
  /// `call_logs`/`interactions` row (duration still null) the moment it is
  /// placed, and counting that row made every caller read "Last spoke today".
  /// [notAfter] is an extra cut-off for rows that are already complete but
  /// belong to the current call.
  Future<_LastSpokeInfo?> _resolveLastSpoke(
    dynamic db,
    int contactId, {
    DateTime? notAfter,
  }) async {
    DateTime? latestTime;

    final cutoff = notAfter?.toIso8601String();

    // Query newest call log
    final callLogs = await db.query(
      'call_logs',
      columns: ['timestamp'],
      where:
          'contact_id = ? AND duration IS NOT NULL AND duration > 0 '
          "AND call_type IN ('incoming', 'outgoing')"
          '${cutoff != null ? ' AND timestamp < ?' : ''}',
      whereArgs: [contactId, ?cutoff],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (callLogs.isNotEmpty) {
      final tsStr = callLogs.first['timestamp'] as String?;
      if (tsStr != null) {
        latestTime = DateTime.tryParse(tsStr);
      }
    }

    // Query newest interaction
    final interactions = await db.query(
      'interactions',
      columns: ['timestamp'],
      where:
          'contact_id = ? AND duration IS NOT NULL AND duration > 0'
          '${cutoff != null ? ' AND timestamp < ?' : ''}',
      whereArgs: [contactId, ?cutoff],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (interactions.isNotEmpty) {
      final tsStr = interactions.first['timestamp'] as String?;
      if (tsStr != null) {
        final iTime = DateTime.tryParse(tsStr);
        if (iTime != null && (latestTime == null || iTime.isAfter(latestTime))) {
          latestTime = iTime;
        }
      }
    }

    if (latestTime == null) return null;

    final label = formatLastSpokeTime(latestTime);
    return _LastSpokeInfo(timestamp: latestTime, label: label);
  }

  /// Natural language formatting of elapsed time since last spoke/interaction.
  static String formatLastSpokeTime(DateTime time, {DateTime? referenceTime}) {
    final reference = referenceTime ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final targetDate = DateTime(time.year, time.month, time.day);

    final dayDiff = today.difference(targetDate).inDays;

    if (dayDiff == 0) {
      return 'Last spoke today';
    } else if (dayDiff == 1) {
      return 'Last spoke yesterday';
    } else if (dayDiff > 1 && dayDiff < 7) {
      return 'Last spoke $dayDiff days ago';
    } else if (dayDiff >= 7 && dayDiff < 30) {
      final weeks = (dayDiff / 7).floor();
      return 'Last spoke $weeks ${weeks == 1 ? "week" : "weeks"} ago';
    } else if (dayDiff >= 30 && dayDiff < 365) {
      final months = (dayDiff / 30).floor();
      return 'Last spoke $months ${months == 1 ? "month" : "months"} ago';
    } else {
      final years = (dayDiff / 365).floor();
      return 'Last spoke $years ${years == 1 ? "year" : "years"} ago';
    }
  }

  /// Fetches uncompleted reminders from `reminders`.
  Future<List<String>> _resolvePendingReminders(
    dynamic db,
    int contactId,
  ) async {
    final rows = await db.query(
      'reminders',
      columns: ['reminder_text'],
      where: 'contact_id = ? AND is_completed = 0',
      whereArgs: [contactId],
      orderBy: 'id DESC',
    );

    final results = <String>[];
    for (final row in rows) {
      final text = (row['reminder_text'] as String?)?.trim();
      if (text != null && text.isNotEmpty) {
        final lower = text.toLowerCase();
        // Natural callback phrasing
        if (lower.startsWith('you owe') || lower.startsWith('reminder:')) {
          results.add(text);
        } else if (lower.contains('callback') || lower.contains('call back')) {
          results.add('You owe a callback');
        } else {
          results.add(text);
        }
      }
    }

    return results;
  }

  /// Resolves upcoming events (Birthday / Anniversary / Meetiversary) within 14 days.
  String? _resolveUpcomingEvent(
    Map<String, dynamic> contactMap, {
    DateTime? now,
  }) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);

    String? result;

    void checkEvent(String? dateStr, String label) {
      if (result != null || dateStr == null || dateStr.isEmpty) return;
      final parsed = DateTime.tryParse(dateStr);
      if (parsed == null) return;

      var thisYearEvent = DateTime(today.year, parsed.month, parsed.day);
      if (thisYearEvent.isBefore(today)) {
        thisYearEvent = DateTime(today.year + 1, parsed.month, parsed.day);
      }

      final diff = thisYearEvent.difference(today).inDays;
      if (diff >= 0 && diff <= 14) {
        if (diff == 0) {
          result = '$label today!';
        } else if (diff == 1) {
          result = '$label tomorrow';
        } else if (diff <= 7) {
          final dayName = DateFormat('EEEE').format(thisYearEvent);
          result = '$label next $dayName';
        } else {
          result = '$label in $diff days';
        }
      }
    }

    checkEvent(contactMap['dob'] as String?, 'Birthday');
    checkEvent(contactMap['anniversary'] as String?, 'Anniversary');
    checkEvent(contactMap['meetiversary'] as String?, 'Meetiversary');

    return result;
  }

  /// Fetches latest interaction note or call intent from call_logs and interactions.
  Future<String?> _resolveRecentNote(
    dynamic db,
    int contactId,
  ) async {
    final callLogRows = await db.query(
      'call_logs',
      columns: ['notes', 'call_intent'],
      where: 'contact_id = ? AND (notes IS NOT NULL OR call_intent IS NOT NULL)',
      whereArgs: [contactId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (callLogRows.isNotEmpty) {
      final notes = (callLogRows.first['notes'] as String?)?.trim();
      if (notes != null && notes.isNotEmpty) return notes;
      final intent = (callLogRows.first['call_intent'] as String?)?.trim();
      if (intent != null && intent.isNotEmpty) return intent;
    }

    final interactionRows = await db.query(
      'interactions',
      columns: ['emotional_tone'],
      where: 'contact_id = ? AND emotional_tone IS NOT NULL',
      whereArgs: [contactId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (interactionRows.isNotEmpty) {
      final tone = (interactionRows.first['emotional_tone'] as String?)?.trim();
      if (tone != null && tone.isNotEmpty) return tone;
    }

    return null;
  }
}

class _LastSpokeInfo {
  final DateTime timestamp;
  final String label;

  _LastSpokeInfo({required this.timestamp, required this.label});
}
