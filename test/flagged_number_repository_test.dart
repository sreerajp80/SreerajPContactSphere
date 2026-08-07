// Unit tests for FlaggedNumberRepository (the blocked / spam number lists) and
// the CallerIdService series rules.
//
// Runs sqflite on the host VM via sqflite_common_ffi. The native screening
// mirror push is platform-channel bound and no-ops harmlessly under
// `flutter test`; blocking/silencing enforcement is verified on a device.
// Tests pass `defaultIso` explicitly so they don't depend on persisted
// settings or the host locale.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/repositories/flagged_number_repository.dart';
import 'package:smart_contacts_dialer/services/caller_id_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_flagged.db');
  });

  setUp(() async {
    // Start each test from a clean schema.
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_flagged.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  group('FlaggedNumberRepository', () {
    test('add normalizes to E.164 and lists the entry', () async {
      final repo = FlaggedNumberRepository();

      final added = await repo.add(
        '98765 43210',
        kind: FlaggedNumberRepository.kindBlocked,
        defaultIso: 'IN',
      );
      expect(added, isTrue);

      final entries = await repo.listByKind(
        FlaggedNumberRepository.kindBlocked,
      );
      expect(entries, hasLength(1));
      expect(entries.single.number, '98765 43210');
      expect(entries.single.numberE164, '+919876543210');
    });

    test(
      'national and +country forms are the same entry (idempotent add)',
      () async {
        final repo = FlaggedNumberRepository();

        await repo.add(
          '9876543210',
          kind: FlaggedNumberRepository.kindBlocked,
          defaultIso: 'IN',
        );
        await repo.add(
          '+91 98765 43210',
          kind: FlaggedNumberRepository.kindBlocked,
          defaultIso: 'IN',
        );

        final entries = await repo.listByKind(
          FlaggedNumberRepository.kindBlocked,
        );
        expect(entries, hasLength(1));

        expect(
          await repo.isFlagged(
            '+919876543210',
            kind: FlaggedNumberRepository.kindBlocked,
            defaultIso: 'IN',
          ),
          isTrue,
        );
        expect(
          await repo.isFlagged(
            '9876543210',
            kind: FlaggedNumberRepository.kindBlocked,
            defaultIso: 'IN',
          ),
          isTrue,
        );
      },
    );

    test('blocked and spam are independent kinds of the same number', () async {
      final repo = FlaggedNumberRepository();
      const number = '9876543210';

      await repo.add(
        number,
        kind: FlaggedNumberRepository.kindBlocked,
        defaultIso: 'IN',
      );
      await repo.add(
        number,
        kind: FlaggedNumberRepository.kindSpam,
        defaultIso: 'IN',
      );

      expect(
        await repo.listByKind(FlaggedNumberRepository.kindBlocked),
        hasLength(1),
      );
      expect(
        await repo.listByKind(FlaggedNumberRepository.kindSpam),
        hasLength(1),
      );

      // Clearing spam leaves the block in place.
      await repo.removeNumber(
        number,
        kind: FlaggedNumberRepository.kindSpam,
        defaultIso: 'IN',
      );
      expect(
        await repo.isFlagged(
          number,
          kind: FlaggedNumberRepository.kindSpam,
          defaultIso: 'IN',
        ),
        isFalse,
      );
      expect(
        await repo.isFlagged(
          number,
          kind: FlaggedNumberRepository.kindBlocked,
          defaultIso: 'IN',
        ),
        isTrue,
      );
    });

    test('remove by id deletes the entry', () async {
      final repo = FlaggedNumberRepository();
      await repo.add(
        '9876543210',
        kind: FlaggedNumberRepository.kindBlocked,
        defaultIso: 'IN',
      );
      final entry = (await repo.listByKind(
        FlaggedNumberRepository.kindBlocked,
      )).single;

      await repo.remove(entry.id);

      expect(
        await repo.listByKind(FlaggedNumberRepository.kindBlocked),
        isEmpty,
      );
    });

    test(
      'unparseable input falls back to its digit string; no digits fails',
      () async {
        final repo = FlaggedNumberRepository();

        // A short code can't parse as E.164 but must still be blockable.
        final added = await repo.add(
          '12345',
          kind: FlaggedNumberRepository.kindBlocked,
          defaultIso: 'IN',
        );
        expect(added, isTrue);
        final entries = await repo.listByKind(
          FlaggedNumberRepository.kindBlocked,
        );
        expect(entries.single.numberE164, '12345');

        expect(
          await repo.add(
            'no digits here',
            kind: FlaggedNumberRepository.kindBlocked,
            defaultIso: 'IN',
          ),
          isFalse,
        );
      },
    );
  });

  group('CallerIdService.identifyBySeries', () {
    test('recognises the TRAI 140 telemarketing series', () {
      final info = CallerIdService.identifyBySeries(
        '1409876543',
        defaultIso: 'IN',
      );
      expect(info, isNotNull);
      expect(info!.label, 'Telemarketing');
      expect(info.isSpam, isTrue);
    });

    test('recognises the TRAI 160 service series, with country code', () {
      final info = CallerIdService.identifyBySeries(
        '+911609876543',
        defaultIso: 'IN',
      );
      expect(info, isNotNull);
      expect(info!.label, 'Service call');
      expect(info.isSpam, isFalse);
    });

    test('ordinary mobile numbers and non-Indian numbers are unlabelled', () {
      expect(
        CallerIdService.identifyBySeries('9876543210', defaultIso: 'IN'),
        isNull,
      );
      expect(
        CallerIdService.identifyBySeries('+14155550123', defaultIso: 'IN'),
        isNull,
      );
    });
  });
}
