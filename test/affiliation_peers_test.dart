// Tests for ContactRepository.getAffiliationPeers — the query behind the
// "Suggested" section when adding members to a group or tag. Checks that shared
// houses and employers are found through messy spelling, that unrelated contacts
// are not dragged in, and that seeds never suggest themselves.
//
// Runs sqflite on the host VM via sqflite_common_ffi (the default sqflite factory
// is Android-only and unavailable under `flutter test`).

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_affiliation.db';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(dbName);
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(join(await getDatabasesPath(), dbName));
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  final repo = ContactRepository();

  Future<int> addContact(
    String name, {
    String? house,
    String? locality,
    String? company,
  }) {
    return repo.insertContact(
      Contact(firstName: name)
        ..addresses = [
          Address(
            type: company == null ? 'personal' : 'official',
            houseName: house,
            postOffice: locality,
            companyName: company,
          ),
        ],
    );
  }

  Future<Set<int>> peerIds(Set<int> seeds) async {
    final peers = await repo.getAffiliationPeers(seeds);
    return peers.map((p) => p.contactId).toSet();
  }

  test('suggests others in the same house', () async {
    final anu = await addContact('Anu', house: 'Sreelakshmi', locality: 'Kakkanad');
    final binu = await addContact(
      'Binu',
      house: 'sreelakshmi',
      locality: 'Kakkanad',
    );
    final stranger = await addContact(
      'Cinu',
      house: 'Vrindavan',
      locality: 'Kakkanad',
    );

    final ids = await peerIds({anu});

    expect(ids, contains(binu));
    expect(ids, isNot(contains(stranger)));
    expect(ids, isNot(contains(anu)), reason: 'a seed is not its own suggestion');
  });

  test('suggests colleagues through different company spellings', () async {
    final anu = await addContact('Anu', company: 'Infosys Ltd');
    final binu = await addContact('Binu', company: 'INFOSYS');
    final other = await addContact('Cinu', company: 'Wipro');

    final ids = await peerIds({anu});

    expect(ids, contains(binu));
    expect(ids, isNot(contains(other)));
  });

  test('the same house name in another town is not a peer', () async {
    final anu = await addContact('Anu', house: 'Sreelakshmi', locality: 'Kakkanad');
    final far = await addContact(
      'Binu',
      house: 'Sreelakshmi',
      locality: 'Karunagappally',
    );

    expect(await peerIds({anu}), isNot(contains(far)));
  });

  test('generic house values do not cluster strangers together', () async {
    final anu = await addContact('Anu', house: 'House', locality: 'Kakkanad');
    final binu = await addContact('Binu', house: 'house', locality: 'Kakkanad');

    expect(await peerIds({anu}), isNot(contains(binu)));
  });

  test('a contact with no address suggests nothing', () async {
    final bare = await repo.insertContact(Contact(firstName: 'Anu'));
    await addContact('Binu', house: 'Sreelakshmi', locality: 'Kakkanad');

    expect(await peerIds({bare}), isEmpty);
  });

  test('no seeds means no suggestions', () async {
    await addContact('Anu', house: 'Sreelakshmi', locality: 'Kakkanad');

    expect(await repo.getAffiliationPeers(<int>{}), isEmpty);
  });

  test('house matches are reported before company matches', () async {
    final anu = await repo.insertContact(
      Contact(firstName: 'Anu')
        ..addresses = [
          Address(
            type: 'personal',
            houseName: 'Sreelakshmi',
            postOffice: 'Kakkanad',
          ),
          Address(type: 'official', companyName: 'Infosys'),
        ],
    );
    await addContact('Colleague', company: 'Infosys');
    await addContact('Sibling', house: 'Sreelakshmi', locality: 'Kakkanad');

    final peers = await repo.getAffiliationPeers({anu});

    expect(peers.first.kind, AffiliationKind.house);
    expect(peers.first.reason, 'Same house: Sreelakshmi');
    expect(peers.any((p) => p.kind == AffiliationKind.company), isTrue);
  });

  test('secret contacts stay out unless asked for', () async {
    final anu = await addContact('Anu', house: 'Sreelakshmi', locality: 'Kakkanad');
    final secret = await repo.insertContact(
      Contact(firstName: 'Hidden', isSecret: true)
        ..addresses = [
          Address(
            type: 'personal',
            houseName: 'Sreelakshmi',
            postOffice: 'Kakkanad',
          ),
        ],
    );

    expect(await peerIds({anu}), isNot(contains(secret)));

    final withSecret = await repo.getAffiliationPeers({
      anu,
    }, includeSecret: true);
    expect(withSecret.map((p) => p.contactId), contains(secret));
  });
}
