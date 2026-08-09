// lib/services/quiet_hours_service.dart
import 'dart:async';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';

/// Relationship tier identifiers for quiet-hours exception filtering.
class QuietHoursTiers {
  QuietHoursTiers._();

  static const String emergency = 'emergency';
  static const String immediateFamily = 'immediate_family';
  static const String extendedFamily = 'extended_family';
  static const String friends = 'friends';
  static const String work = 'work';
  static const String starred = 'starred';

  static const Set<String> defaultTiers = {emergency, immediateFamily};

  static const Set<String> immediateFamilyTypes = {
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
  };

  static const Set<String> extendedFamilyTypes = {
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
    'relative',
  };

  static const Set<String> friendTypes = {
    'friend',
    'neighbour',
  };

  static const Set<String> workTypes = {
    'colleague',
  };

  /// Returns the tier category for a given relationship label, or null if unmapped.
  static String? tierForRelationship(String relationshipType) {
    final label = relationshipType.trim().toLowerCase();
    if (immediateFamilyTypes.contains(label)) return immediateFamily;
    if (extendedFamilyTypes.contains(label)) return extendedFamily;
    if (friendTypes.contains(label)) return friends;
    if (workTypes.contains(label)) return work;
    return null;
  }
}

/// Resolves allowed phone numbers for Relationship-tier Quiet Hours and updates
/// the native call-screening mirror in SharedPreferences.
class QuietHoursService {
  static final QuietHoursService _instance = QuietHoursService._internal();
  factory QuietHoursService() => _instance;
  QuietHoursService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TelecomService _telecom = TelecomService();

  /// Resolves digit strings for contacts allowed to ring through during quiet hours.
  Future<Set<String>> resolveAllowedNumbers([
    Set<String> allowedTiers = const {},
    Set<String> allowedTags = const {},
    Set<int> allowedContactIds = const {},
  ]) async {
    if (allowedTiers.isEmpty &&
        allowedTags.isEmpty &&
        allowedContactIds.isEmpty) {
      return {};
    }

    final db = await _dbHelper.database;
    final Set<int> resolvedContactIds = {...allowedContactIds};
    final Set<String> allowedDigits = {};

    // 1. Emergency contacts (ICE)
    if (allowedTiers.contains(QuietHoursTiers.emergency)) {
      final rows = await db.query(
        'emergency_contacts',
        columns: ['contact_id', 'number'],
      );
      for (final r in rows) {
        final cid = r['contact_id'] as int?;
        if (cid != null) resolvedContactIds.add(cid);
        final numStr = r['number'] as String?;
        if (numStr != null && numStr.isNotEmpty) {
          final digits = numStr.replaceAll(RegExp(r'\D'), '');
          if (digits.isNotEmpty) allowedDigits.add(digits);
        }
      }
    }

    // 2. Starred contacts
    if (allowedTiers.contains(QuietHoursTiers.starred)) {
      final rows = await db.query(
        'contacts',
        columns: ['id'],
        where: 'is_favorite = 1 AND is_secret = 0',
      );
      for (final r in rows) {
        resolvedContactIds.add(r['id'] as int);
      }
    }

    // 3. Specific Relationship Types & categories
    final nonSpecialTiers = allowedTiers
        .where(
            (t) => t != QuietHoursTiers.emergency && t != QuietHoursTiers.starred)
        .toSet();

    if (nonSpecialTiers.isNotEmpty) {
      final relRows = await db.rawQuery('''
        SELECT r.related_contact_id AS related_id, r.relationship_type AS rel_type
        FROM relationships r
        JOIN contacts s ON s.id = r.contact_id
        WHERE s.is_self = 1
      ''');

      final lowerSelected =
          nonSpecialTiers.map((t) => t.trim().toLowerCase()).toSet();

      for (final r in relRows) {
        final rawType = r['rel_type'] as String?;
        final relatedId = r['related_id'] as int?;
        if (rawType == null || relatedId == null) continue;

        final lowerType = rawType.trim().toLowerCase();
        final mappedTier = QuietHoursTiers.tierForRelationship(rawType);

        if (lowerSelected.contains(lowerType) ||
            (mappedTier != null && lowerSelected.contains(mappedTier))) {
          resolvedContactIds.add(relatedId);
        }
      }
    }

    // 4. Tagged contacts
    if (allowedTags.isNotEmpty) {
      final placeholders = List.filled(allowedTags.length, '?').join(',');
      final tagRows = await db.rawQuery(
        '''
        SELECT DISTINCT contact_id
        FROM tags
        WHERE name IN ($placeholders)
        ''',
        allowedTags.toList(),
      );
      for (final r in tagRows) {
        final cid = r['contact_id'] as int?;
        if (cid != null) resolvedContactIds.add(cid);
      }
    }

    // 5. Fetch all phone numbers for resolved contact IDs
    if (resolvedContactIds.isNotEmpty) {
      final placeholders =
          List.filled(resolvedContactIds.length, '?').join(',');
      final phoneRows = await db.rawQuery(
        '''
        SELECT number
        FROM phone_numbers
        WHERE contact_id IN ($placeholders)
        ''',
        resolvedContactIds.toList(),
      );

      for (final r in phoneRows) {
        final numStr = r['number'] as String?;
        final digits = (numStr ?? '').replaceAll(RegExp(r'\D'), '');
        if (digits.isNotEmpty) {
          allowedDigits.add(digits);
        }
      }
    }

    return allowedDigits;
  }

  /// Calculates allowed numbers based on current AppSettings and syncs to native mirror.
  Future<void> syncQuietHoursMirror({AppSettings? settings}) async {
    try {
      final s = settings ?? AppSettings();
      final enabled = s.relationshipQuietHoursEnabled;
      final start = s.relationshipQuietHoursStart;
      final end = s.relationshipQuietHoursEnd;
      final allowedTiers = s.relationshipQuietHoursAllowedTiers.toSet();
      final allowedTags = s.relationshipQuietHoursAllowedTags.toSet();
      final allowedContactIds =
          s.relationshipQuietHoursAllowedContactIds.toSet();

      Set<String> allowedNumbers = {};
      if (enabled &&
          (allowedTiers.isNotEmpty ||
              allowedTags.isNotEmpty ||
              allowedContactIds.isNotEmpty)) {
        allowedNumbers = await resolveAllowedNumbers(
          allowedTiers,
          allowedTags,
          allowedContactIds,
        );
      }

      await _telecom.setScreeningMirror(
        quietHoursEnabled: enabled,
        quietHoursStart: start,
        quietHoursEnd: end,
        quietHoursAllowedNumbers: allowedNumbers.toList(),
      );
    } catch (_) {
      // Best-effort push; native screening falls through on error.
    }
  }
}

