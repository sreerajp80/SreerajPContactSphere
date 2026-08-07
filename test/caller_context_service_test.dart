// test/caller_context_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/caller_context.dart';
import 'package:smart_contacts_dialer/repositories/relationship_repository.dart';
import 'package:smart_contacts_dialer/repositories/reminder_repository.dart';
import 'package:smart_contacts_dialer/services/caller_context_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_caller_context.db');
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_caller_context.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  group('CallerContext Model & Helpers', () {
    test('buildSmartHeadline constructs natural sentences', () {
      const ctx = CallerContext(
        contactName: 'Ravi',
        relationshipLabel: 'your cousin',
        lastSpokeLabel: 'Last spoke 3 weeks ago',
        pendingReminders: ['You owe him a callback'],
        upcomingEventLabel: 'Birthday next Tuesday',
      );

      expect(ctx.hasContext, isTrue);
      expect(
        ctx.buildSmartHeadline(),
        'Ravi — your cousin. Last spoke 3 weeks ago. You owe him a callback. Birthday next Tuesday.',
      );
    });

    test('formatRelationshipPerspective converts raw labels to conversational phrases', () {
      expect(
        CallerContextService.formatRelationshipPerspective('Cousin'),
        'your cousin',
      );
      expect(
        CallerContextService.formatRelationshipPerspective('Father'),
        'your father',
      );
      expect(
        CallerContextService.formatRelationshipPerspective('Colleague'),
        'your colleague',
      );
      expect(
        CallerContextService.formatRelationshipPerspective('your spouse'),
        'your spouse',
      );
    });

    test('formatLastSpokeTime formats relative dates correctly', () {
      final now = DateTime(2026, 7, 27, 12);

      // Today
      expect(
        CallerContextService.formatLastSpokeTime(
          DateTime(2026, 7, 27, 8),
          referenceTime: now,
        ),
        'Last spoke today',
      );

      // Yesterday
      expect(
        CallerContextService.formatLastSpokeTime(
          DateTime(2026, 7, 26, 18),
          referenceTime: now,
        ),
        'Last spoke yesterday',
      );

      // Days ago
      expect(
        CallerContextService.formatLastSpokeTime(
          DateTime(2026, 7, 24, 12),
          referenceTime: now,
        ),
        'Last spoke 3 days ago',
      );

      // Weeks ago
      expect(
        CallerContextService.formatLastSpokeTime(
          DateTime(2026, 7, 6, 12),
          referenceTime: now,
        ),
        'Last spoke 3 weeks ago',
      );

      // Months ago
      expect(
        CallerContextService.formatLastSpokeTime(
          DateTime(2026, 5, 27, 12),
          referenceTime: now,
        ),
        'Last spoke 2 months ago',
      );
    });
  });

  group('CallerContextService Integration', () {
    test('stitches relationships, call logs, reminders, and birthdays into caller context', () async {
      final db = await DatabaseHelper().database;
      final service = CallerContextService();
      final relRepo = RelationshipRepository();
      final reminderRepo = ReminderRepository();

      // 1. Create owner (is_self = 1) contact
      final selfId = await db.insert('contacts', {
        'first_name': 'Me',
        'is_self': 1,
      });

      // 2. Create caller contact "Ravi"
      final raviDob = DateTime.now().add(const Duration(days: 4));
      final dobStr =
          '${raviDob.year}-${raviDob.month.toString().padLeft(2, '0')}-${raviDob.day.toString().padLeft(2, '0')}';

      final raviId = await db.insert('contacts', {
        'first_name': 'Ravi',
        'last_name': 'Kumar',
        'dob': dobStr,
      });

      await db.insert('phone_numbers', {
        'contact_id': raviId,
        'number': '+919876543210',
        'type': 'personal',
        'is_primary': 1,
      });

      // 3. Set Relationship: Ravi is Cousin to Me
      await relRepo.setRelationship(
        contactId: selfId,
        relatedContactId: raviId,
        type: 'Cousin',
      );

      // 4. Insert Call Log from 21 days ago (3 weeks)
      final threeWeeksAgo = DateTime.now().subtract(const Duration(days: 21));
      await db.insert('call_logs', {
        'contact_id': raviId,
        'phone_number': '+919876543210',
        'call_type': 'incoming',
        'duration': 120,
        'timestamp': threeWeeksAgo.toIso8601String(),
      });

      // 5. Add Pending Reminder / Callback
      await reminderRepo.insert(
        contactId: raviId,
        reminderText: 'You owe him a callback',
      );

      // 6. Query Caller Context by Number
      final ctx = await service.getCallerContextByNumber('+919876543210');

      expect(ctx, isNotNull);
      expect(ctx!.contactName, 'Ravi Kumar');
      expect(ctx.relationshipLabel, 'your cousin');
      expect(ctx.lastSpokeLabel, 'Last spoke 3 weeks ago');
      expect(ctx.pendingReminders, contains('You owe him a callback'));
      expect(ctx.upcomingEventLabel, contains('Birthday'));

      final headline = ctx.buildSmartHeadline();
      expect(headline, contains('Ravi Kumar — your cousin.'));
      expect(headline, contains('Last spoke 3 weeks ago.'));
      expect(headline, contains('You owe him a callback.'));
      expect(headline, contains('Birthday'));
    });

    test('ignores the call in progress and unanswered calls when reporting last spoke', () async {
      final db = await DatabaseHelper().database;
      final service = CallerContextService();

      final contactId = await db.insert('contacts', {'first_name': 'Meera'});

      final now = DateTime.now();

      // The call happening right now: written provisionally at placement, so
      // its duration is still null. Must not count.
      await db.insert('call_logs', {
        'contact_id': contactId,
        'phone_number': '+919000000001',
        'call_type': 'outgoing',
        'timestamp': now.toIso8601String(),
      });
      await db.insert('interactions', {
        'contact_id': contactId,
        'interaction_type': 'call',
        'timestamp': now.toIso8601String(),
      });

      // A call she missed yesterday: nobody talked, so it isn't "spoke".
      await db.insert('call_logs', {
        'contact_id': contactId,
        'phone_number': '+919000000001',
        'call_type': 'missed',
        'duration': 0,
        'timestamp': now
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      });

      // A call that rang out three days ago: answered never, duration 0.
      await db.insert('call_logs', {
        'contact_id': contactId,
        'phone_number': '+919000000001',
        'call_type': 'outgoing',
        'duration': 0,
        'timestamp': now
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      });

      // The real last conversation: three weeks ago.
      await db.insert('call_logs', {
        'contact_id': contactId,
        'phone_number': '+919000000001',
        'call_type': 'outgoing',
        'duration': 95,
        'timestamp': now
            .subtract(const Duration(days: 21))
            .toIso8601String(),
      });

      final ctx = await service.getCallerContextByContactId(contactId);

      expect(ctx, isNotNull);
      expect(ctx!.lastSpokeLabel, 'Last spoke 3 weeks ago');
    });

    test('leaves last spoke empty when there is no real conversation on record', () async {
      final db = await DatabaseHelper().database;
      final service = CallerContextService();

      final contactId = await db.insert('contacts', {'first_name': 'Anil'});

      // Only a call in progress and a missed call — neither is a conversation.
      await db.insert('call_logs', {
        'contact_id': contactId,
        'phone_number': '+919000000002',
        'call_type': 'outgoing',
        'timestamp': DateTime.now().toIso8601String(),
      });
      await db.insert('call_logs', {
        'contact_id': contactId,
        'phone_number': '+919000000002',
        'call_type': 'missed',
        'duration': 0,
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      });

      final ctx = await service.getCallerContextByContactId(contactId);

      expect(ctx, isNotNull);
      expect(ctx!.lastSpokeLabel, isNull);
    });

    test('notAfter cuts off history at the start of the current call', () async {
      final db = await DatabaseHelper().database;
      final service = CallerContextService();

      final contactId = await db.insert('contacts', {'first_name': 'Latha'});

      final now = DateTime.now();
      final callStart = now.subtract(const Duration(minutes: 2));

      // A complete row belonging to the call in progress (e.g. rebuilt by the
      // device call-log import while the call is still on screen).
      await db.insert('call_logs', {
        'contact_id': contactId,
        'phone_number': '+919000000003',
        'call_type': 'incoming',
        'duration': 60,
        'timestamp': now.toIso8601String(),
      });

      // The previous real conversation.
      await db.insert('call_logs', {
        'contact_id': contactId,
        'phone_number': '+919000000003',
        'call_type': 'incoming',
        'duration': 200,
        'timestamp': now
            .subtract(const Duration(days: 21))
            .toIso8601String(),
      });

      final ctx = await service.getCallerContextByContactId(
        contactId,
        notAfter: callStart,
      );

      expect(ctx, isNotNull);
      expect(ctx!.lastSpokeLabel, 'Last spoke 3 weeks ago');
    });
  });
}
