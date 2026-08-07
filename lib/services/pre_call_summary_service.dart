// lib/services/pre_call_summary_service.dart
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/call_summary.dart';
import 'package:smart_contacts_dialer/services/reach_window_service.dart';

class PreCallSummaryService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ReachWindowService _reachWindows = ReachWindowService();

  /// The tz database is initialized lazily, once per process.
  static bool _tzInitialized = false;

  Future<CallSummary> getPreCallSummary(int contactId) async {
    final db = await _dbHelper.database;

    // Get last 3 messages/interactions
    final recentInteractions = await db.query(
      'interactions',
      where: 'contact_id = ?',
      whereArgs: [contactId],
      orderBy: 'timestamp DESC',
      limit: 3,
    );

    // Get last call info
    final lastCall = await db.query(
      'call_logs',
      where: 'contact_id = ?',
      whereArgs: [contactId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    // Get important dates
    final contact = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [contactId],
      limit: 1,
    );

    // Check timezone if contact has location data
    String? timezone;
    final address = await db.query(
      'addresses',
      where: 'contact_id = ?',
      whereArgs: [contactId],
      limit: 1,
    );

    if (address.isNotEmpty) {
      // Calculate timezone based on location
      timezone = await _getTimezoneForLocation(
        address.first['city_town'] as String?,
        address.first['country'] as String?,
      );
    }

    // When calls to them actually get answered. Null — and so no line at all —
    // whenever the history is too thin to support a claim.
    final bestTimeToReach = await _reachWindows.bestWindow(contactId);

    return CallSummary(
      recentInteractions: recentInteractions,
      lastCallDuration: lastCall.isNotEmpty
          ? lastCall.first['duration'] as int?
          : null,
      upcomingBirthday:
          contact.isNotEmpty && _checkUpcomingBirthday(contact.first),
      currentTimeInContactTimezone: timezone,
      bestTimeToReach: bestTimeToReach,
    );
  }

  bool _checkUpcomingBirthday(Map<String, dynamic> contact) {
    if (contact['dob'] == null) return false;

    final dob = DateTime.parse(contact['dob']);
    final today = DateTime.now();
    final thisYearBirthday = DateTime(today.year, dob.month, dob.day);

    final daysUntilBirthday = thisYearBirthday.difference(today).inDays;
    return daysUntilBirthday >= 0 && daysUntilBirthday <= 7;
  }

  /// Resolves a contact's city/country to their current local time, e.g.
  /// `5:30 PM (Asia/Kolkata)`. Offline only — backed by a small built-in
  /// city/country → IANA-zone map and the bundled tz database. Returns null
  /// when the location is unknown, so the summary simply omits the line.
  Future<String?> _getTimezoneForLocation(String? city, String? country) async {
    final zoneName = _resolveZoneName(city, country);
    if (zoneName == null) return null;

    try {
      if (!_tzInitialized) {
        tzdata.initializeTimeZones();
        _tzInitialized = true;
      }
      final location = tz.getLocation(zoneName);
      final now = tz.TZDateTime.now(location);
      return '${DateFormat.jm().format(now)} ($zoneName)';
    } catch (_) {
      // Unknown zone name or tz init failure — degrade gracefully.
      return null;
    }
  }

  /// Maps a free-text city/country to an IANA timezone name. Matches city first
  /// (more specific), then country. Case-insensitive. Covers common cases only;
  /// an unmapped location yields null.
  String? _resolveZoneName(String? city, String? country) {
    final c = city?.trim().toLowerCase();
    if (c != null && c.isNotEmpty && _cityZones.containsKey(c)) {
      return _cityZones[c];
    }
    final co = country?.trim().toLowerCase();
    if (co != null && co.isNotEmpty && _countryZones.containsKey(co)) {
      return _countryZones[co];
    }
    return null;
  }

  static const Map<String, String> _cityZones = {
    'new york': 'America/New_York',
    'los angeles': 'America/Los_Angeles',
    'chicago': 'America/Chicago',
    'toronto': 'America/Toronto',
    'london': 'Europe/London',
    'paris': 'Europe/Paris',
    'berlin': 'Europe/Berlin',
    'dubai': 'Asia/Dubai',
    'mumbai': 'Asia/Kolkata',
    'delhi': 'Asia/Kolkata',
    'bangalore': 'Asia/Kolkata',
    'bengaluru': 'Asia/Kolkata',
    'singapore': 'Asia/Singapore',
    'hong kong': 'Asia/Hong_Kong',
    'tokyo': 'Asia/Tokyo',
    'sydney': 'Australia/Sydney',
  };

  static const Map<String, String> _countryZones = {
    'usa': 'America/New_York',
    'united states': 'America/New_York',
    'us': 'America/New_York',
    'canada': 'America/Toronto',
    'uk': 'Europe/London',
    'united kingdom': 'Europe/London',
    'england': 'Europe/London',
    'france': 'Europe/Paris',
    'germany': 'Europe/Berlin',
    'uae': 'Asia/Dubai',
    'united arab emirates': 'Asia/Dubai',
    'india': 'Asia/Kolkata',
    'singapore': 'Asia/Singapore',
    'japan': 'Asia/Tokyo',
    'australia': 'Australia/Sydney',
  };
}
