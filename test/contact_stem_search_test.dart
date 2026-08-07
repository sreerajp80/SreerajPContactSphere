// Unit tests for ContactRepository.searchContactsByNameStem — the voice-dial
// fallback that resolves an inflected Malayalam name to its base contact.
//
// Runs sqflite on the host VM via sqflite_common_ffi (the default sqflite
// factory is Android-only and unavailable under `flutter test`).

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_stem_search.db');
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_stem_search.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  final repo = ContactRepository();

  Future<List<String>> stemNames(String query) async {
    final hits = await repo.searchContactsByNameStem(query);
    return hits.map((c) => c.firstName).toList();
  }

  test('an accusative-inflected name matches its base contact', () async {
    await repo.insertContact(Contact(firstName: 'സീത')); // "Seetha"
    await repo.insertContact(Contact(firstName: 'അമ്മ')); // distractor

    // "സീതയെ" (accusative) → stem "സീത".
    expect(await stemNames('സീതയെ'), ['സീത']);
  });

  test(
    'other case endings (sociative/dative) also resolve to the stem',
    () async {
      await repo.insertContact(Contact(firstName: 'സീത'));

      expect(await stemNames('സീതയോട്'), ['സീത']); // sociative
      expect(await stemNames('സീതയ്ക്ക്'), ['സീത']); // dative
    },
  );

  test('a different name is not returned', () async {
    await repo.insertContact(Contact(firstName: 'സീത'));

    expect(await stemNames('രാജു'), isEmpty); // "Raju" — unrelated
  });

  test('a stem shorter than the guard length matches nothing', () async {
    await repo.insertContact(Contact(firstName: 'സീത'));

    // searchKey('ബി') → "bi" (2 chars) is below the 3-char stem guard, so the
    // query yields no tokens to match on rather than matching everything.
    expect(await stemNames('ബി'), isEmpty);
  });

  test('an exact stem hit ranks above a prefix-only hit', () async {
    await repo.insertContact(Contact(firstName: 'സീത')); // key "vava"
    await repo.insertContact(Contact(firstName: 'സീതന')); // key "vavana"

    // Query stem "സീത": "സീത" matches exactly, "സീതന" only by prefix, so the
    // exact hit is ranked first while both are returned.
    final hits = await repo.searchContactsByNameStem('സീത');
    expect(hits.map((c) => c.firstName), containsAll(['സീത', 'സീതന']));
    expect(hits.first.firstName, 'സീത');
  });
}
