// Unit tests for RelationshipRepository and the reciprocal-row storage model.
//
// Runs sqflite on the host VM via sqflite_common_ffi (the default sqflite
// factory is Android-only and unavailable under `flutter test`).

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/repositories/relationship_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName('smart_contacts_test_relationship.db');
  });

  setUp(() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(
      join(await getDatabasesPath(), 'smart_contacts_test_relationship.db'),
    );
  });

  tearDown(() async {
    await DatabaseHelper().close();
  });

  Future<int> insertContact(String firstName, {String? gender}) async {
    final db = await DatabaseHelper().database;
    return db.insert('contacts', {'first_name': firstName, 'gender': gender});
  }

  group('RelationshipTypes.reciprocalOf', () {
    test('maps directional types to their inverse', () {
      expect(RelationshipTypes.reciprocalOf('Father'), 'Child');
      expect(RelationshipTypes.reciprocalOf('Daughter'), 'Parent');
      expect(RelationshipTypes.reciprocalOf('Uncle'), 'Nephew');
    });

    test('symmetric types map to themselves', () {
      expect(RelationshipTypes.reciprocalOf('Spouse'), 'Spouse');
      expect(RelationshipTypes.reciprocalOf('Friend'), 'Friend');
    });

    test('unknown types fall back to the same label', () {
      expect(RelationshipTypes.reciprocalOf('Mentor'), 'Mentor');
    });

    test('gendered reverse depends on the subject gender', () {
      // Cousin group.
      expect(
        RelationshipTypes.reciprocalOf(
          'Cousin Brother',
          subjectGender: 'Female',
        ),
        'Cousin Sister',
      );
      expect(
        RelationshipTypes.reciprocalOf('Cousin Brother', subjectGender: 'Male'),
        'Cousin Brother',
      );
      expect(
        RelationshipTypes.reciprocalOf('Cousin Brother'),
        'Cousin Brother',
      );
      expect(RelationshipTypes.reciprocalOf('Cousin'), 'Cousin');

      // Sibling group.
      expect(
        RelationshipTypes.reciprocalOf('Brother', subjectGender: 'Female'),
        'Sister',
      );
      expect(
        RelationshipTypes.reciprocalOf('Sister', subjectGender: 'male'),
        'Brother',
      );

      // Parent / child group.
      expect(
        RelationshipTypes.reciprocalOf('Father', subjectGender: 'Male'),
        'Son',
      );
      expect(
        RelationshipTypes.reciprocalOf('Father', subjectGender: 'Female'),
        'Daughter',
      );

      // Uncle / niece.
      expect(
        RelationshipTypes.reciprocalOf('Uncle', subjectGender: 'Female'),
        'Niece',
      );
    });

    test('non-binary / unknown gender uses the neutral reverse', () {
      expect(
        RelationshipTypes.reciprocalOf(
          'Cousin Brother',
          subjectGender: 'Non-binary',
        ),
        'Cousin Brother',
      );
      expect(
        RelationshipTypes.reciprocalOf('Brother', subjectGender: ''),
        'Sibling',
      );
      // Non-gendered types are unaffected by gender.
      expect(
        RelationshipTypes.reciprocalOf('Spouse', subjectGender: 'Female'),
        'Spouse',
      );
    });
  });

  group('RelationshipTypes.forGender', () {
    test('swaps a wrong-gender label to the matching-gender sibling', () {
      expect(
        RelationshipTypes.forGender('Cousin Brother', 'Female'),
        'Cousin Sister',
      );
      expect(
        RelationshipTypes.forGender('Cousin Sister', 'Male'),
        'Cousin Brother',
      );
      expect(RelationshipTypes.forGender('Brother', 'Female'), 'Sister');
      expect(RelationshipTypes.forGender('Uncle', 'female'), 'Aunt');
      expect(RelationshipTypes.forGender('Nephew', 'Female'), 'Niece');
      expect(RelationshipTypes.forGender('Father', 'Female'), 'Mother');
    });

    test('keeps a label that already matches the gender', () {
      expect(
        RelationshipTypes.forGender('Cousin Brother', 'Male'),
        'Cousin Brother',
      );
      expect(RelationshipTypes.forGender('Sister', 'Female'), 'Sister');
    });

    test('never touches neutral labels', () {
      expect(RelationshipTypes.forGender('Cousin', 'Female'), 'Cousin');
      expect(RelationshipTypes.forGender('Sibling', 'Male'), 'Sibling');
      expect(RelationshipTypes.forGender('Child', 'Female'), 'Child');
    });

    test('never touches non-gendered relations', () {
      expect(RelationshipTypes.forGender('Spouse', 'Female'), 'Spouse');
      expect(RelationshipTypes.forGender('Friend', 'Male'), 'Friend');
    });

    test('leaves rows with unknown / non-binary gender unchanged', () {
      expect(
        RelationshipTypes.forGender('Cousin Brother', null),
        'Cousin Brother',
      );
      expect(
        RelationshipTypes.forGender('Cousin Brother', ''),
        'Cousin Brother',
      );
      expect(
        RelationshipTypes.forGender('Cousin Sister', 'Non-binary'),
        'Cousin Sister',
      );
    });
  });

  test('repairGenderedRelationshipLabels fixes only wrong-gender rows', () async {
    final db = await DatabaseHelper().database;
    final she = await insertContact('Asha', gender: 'Female');
    final he = await insertContact('Bimal', gender: 'Male');
    final nb = await insertContact('Sam', gender: 'Non-binary');

    // Seed the pre-fix state directly (bypassing the gender-aware setRelationship),
    // as legacy data would look:
    //  - the reverse row on the female contact wrongly says "Cousin Brother"
    //  - the correct row on the male contact says "Cousin Brother"
    //  - a female contact wrongly stored as "Brother"
    //  - a neutral "Cousin" that must stay neutral
    //  - a row describing the non-binary contact that must be left alone
    Future<void> seed(int c, int related, String type) =>
        db.insert('relationships', {
          'contact_id': c,
          'related_contact_id': related,
          'relationship_type': type,
        });
    await seed(he, she, 'Cousin Brother'); // describes she (F) -> wrong
    await seed(she, he, 'Cousin Brother'); // describes he (M)  -> correct
    await seed(nb, she, 'Brother'); // describes she (F) -> wrong -> Sister
    await seed(she, nb, 'Cousin'); // neutral -> keep
    await seed(he, nb, 'Cousin Sister'); // describes Sam (NB) -> keep

    final fixedCount = await DatabaseHelper().repairGenderedRelationshipLabels(
      db,
    );
    expect(fixedCount, 2);

    Future<String?> typeOf(int c, int related) async {
      final rows = await db.query(
        'relationships',
        columns: ['relationship_type'],
        where: 'contact_id = ? AND related_contact_id = ?',
        whereArgs: [c, related],
      );
      return rows.single['relationship_type'] as String?;
    }

    expect(await typeOf(he, she), 'Cousin Sister'); // corrected
    expect(await typeOf(she, he), 'Cousin Brother'); // untouched (was right)
    expect(await typeOf(nb, she), 'Sister'); // corrected
    expect(await typeOf(she, nb), 'Cousin'); // neutral kept
    expect(await typeOf(he, nb), 'Cousin Sister'); // non-binary target kept

    // Idempotent: a second pass changes nothing.
    expect(await DatabaseHelper().repairGenderedRelationshipLabels(db), 0);
  });

  test('setRelationship genders the reverse row by the owner gender', () async {
    final repo = RelationshipRepository();
    final she = await insertContact('Asha', gender: 'Female');
    final he = await insertContact('Bimal', gender: 'Male');

    // "Bimal is Asha's Cousin Brother" — the reverse describes Asha (female),
    // so it must read "Cousin Sister", not "Cousin Brother".
    await repo.setRelationship(
      contactId: she,
      relatedContactId: he,
      type: 'Cousin Brother',
    );

    final fromShe = await repo.getRelationsOf(she);
    final fromHe = await repo.getRelationsOf(he);

    expect(fromShe.single.relationshipType, 'Cousin Brother');
    expect(fromHe.single.relationshipType, 'Cousin Sister');
  });

  test(
    'setRelationship stores both directions with reciprocal types',
    () async {
      final repo = RelationshipRepository();
      final a = await insertContact('Anil');
      final b = await insertContact('Bina');

      await repo.setRelationship(
        contactId: a,
        relatedContactId: b,
        type: 'Father',
      );

      final fromA = await repo.getRelationsOf(a);
      final fromB = await repo.getRelationsOf(b);

      expect(fromA, hasLength(1));
      expect(fromA.single.contactId, b);
      expect(fromA.single.relationshipType, 'Father');

      expect(fromB, hasLength(1));
      expect(fromB.single.contactId, a);
      expect(fromB.single.relationshipType, 'Child');
    },
  );

  test('setRelationship replaces an existing link (no duplicates)', () async {
    final repo = RelationshipRepository();
    final a = await insertContact('Anil');
    final b = await insertContact('Bina');

    await repo.setRelationship(
      contactId: a,
      relatedContactId: b,
      type: 'Friend',
    );
    await repo.setRelationship(
      contactId: a,
      relatedContactId: b,
      type: 'Colleague',
    );

    final fromA = await repo.getRelationsOf(a);
    expect(fromA, hasLength(1));
    expect(fromA.single.relationshipType, 'Colleague');
  });

  test('removeRelationship clears both directed rows', () async {
    final repo = RelationshipRepository();
    final a = await insertContact('Anil');
    final b = await insertContact('Bina');

    await repo.setRelationship(
      contactId: a,
      relatedContactId: b,
      type: 'Sibling',
    );
    await repo.removeRelationship(contactId: a, relatedContactId: b);

    expect(await repo.getRelationsOf(a), isEmpty);
    expect(await repo.getRelationsOf(b), isEmpty);
  });

  test('setRelationship ignores a self-link', () async {
    final repo = RelationshipRepository();
    final a = await insertContact('Anil');

    await repo.setRelationship(
      contactId: a,
      relatedContactId: a,
      type: 'Friend',
    );

    expect(await repo.getRelationsOf(a), isEmpty);
  });

  test(
    'getRelationsOf de-duplicates a contact with duplicate directed rows',
    () async {
      final repo = RelationshipRepository();
      final db = await DatabaseHelper().database;
      final a = await insertContact('Anil');
      final b = await insertContact('Bina');

      // Two directed rows for the same pair — the state a contact merge can
      // leave behind (setRelationship de-dupes, so we insert directly here).
      await db.insert('relationships', {
        'contact_id': a,
        'related_contact_id': b,
        'relationship_type': 'Spouse',
      });
      await db.insert('relationships', {
        'contact_id': a,
        'related_contact_id': b,
        'relationship_type': 'Spouse',
      });

      final fromA = await repo.getRelationsOf(a);
      expect(fromA, hasLength(1));
      expect(fromA.single.contactId, b);
    },
  );

  group('RelationshipCategory', () {
    test('categoryFor maps known labels to their bucket', () {
      expect(
        RelationshipCategory.categoryFor('Father'),
        RelationshipCategory.immediateFamily,
      );
      expect(
        RelationshipCategory.categoryFor('cousin brother'),
        RelationshipCategory.extendedFamily,
      );
      expect(
        RelationshipCategory.categoryFor('Brother-in-law'),
        RelationshipCategory.familyByMarriage,
      );
      expect(
        RelationshipCategory.categoryFor('Colleague'),
        RelationshipCategory.professional,
      );
      expect(
        RelationshipCategory.categoryFor('Teacher'),
        RelationshipCategory.educational,
      );
      expect(
        RelationshipCategory.categoryFor('Neighbour'),
        RelationshipCategory.social,
      );
      expect(
        RelationshipCategory.categoryFor('Doctor'),
        RelationshipCategory.service,
      );
    });

    test('categoryFor falls back to social for unknown/blank labels', () {
      expect(
        RelationshipCategory.categoryFor('Gym buddy'),
        RelationshipCategory.social,
      );
      expect(
        RelationshipCategory.categoryFor(''),
        RelationshipCategory.social,
      );
      expect(
        RelationshipCategory.categoryFor(null),
        RelationshipCategory.social,
      );
    });

    test('fromStorageKey round-trips every category', () {
      for (final c in RelationshipCategory.values) {
        expect(RelationshipCategory.fromStorageKey(c.storageKey), c);
      }
      expect(RelationshipCategory.fromStorageKey('nonsense'), isNull);
      expect(RelationshipCategory.fromStorageKey(null), isNull);
    });

    test('every category offers at least one suggested label', () {
      for (final c in RelationshipCategory.values) {
        expect(c.suggestedLabels, isNotEmpty, reason: c.displayName);
      }
    });
  });

  test('setRelationship stores the category on both directed rows', () async {
    final repo = RelationshipRepository();
    final a = await insertContact('Anil');
    final b = await insertContact('Bina');

    await repo.setRelationship(
      contactId: a,
      relatedContactId: b,
      type: 'Father',
      category: RelationshipCategory.immediateFamily,
    );

    final fromA = await repo.getRelationsOf(a);
    final fromB = await repo.getRelationsOf(b);
    expect(fromA.single.category, RelationshipCategory.immediateFamily);
    // The reverse row ("Child") stays in the same bucket.
    expect(fromB.single.category, RelationshipCategory.immediateFamily);
  });

  test('setRelationship derives the category when none is given', () async {
    final repo = RelationshipRepository();
    final a = await insertContact('Anil');
    final b = await insertContact('Bina');
    final c = await insertContact('Chandran');

    await repo.setRelationship(
      contactId: a,
      relatedContactId: b,
      type: 'Colleague',
    );
    // An unknown label falls back to social rather than being left blank.
    await repo.setRelationship(
      contactId: a,
      relatedContactId: c,
      type: 'Gym buddy',
    );

    final fromA = await repo.getRelationsOf(a);
    final colleague = fromA.firstWhere((r) => r.contactId == b);
    final buddy = fromA.firstWhere((r) => r.contactId == c);
    expect(colleague.category, RelationshipCategory.professional);
    expect(buddy.category, RelationshipCategory.social);
  });

  test('an explicit category overrides what the label would imply', () async {
    final repo = RelationshipRepository();
    final a = await insertContact('Anil');
    final b = await insertContact('Bina');

    // "Uncle" normally means extended family, but the user may file a family
    // friend called Uncle under Social — their pick wins.
    await repo.setRelationship(
      contactId: a,
      relatedContactId: b,
      type: 'Uncle',
      category: RelationshipCategory.social,
    );

    final fromA = await repo.getRelationsOf(a);
    expect(fromA.single.category, RelationshipCategory.social);
  });

  test('the v29 migration backfills categories on old rows', () async {
    final db = await DatabaseHelper().database;
    final a = await insertContact('Anil');
    final b = await insertContact('Bina');
    final c = await insertContact('Chandran');

    // Rows as a pre-v29 database holds them: a label, no category.
    Future<void> seed(int owner, int related, String? type) =>
        db.insert('relationships', {
          'contact_id': owner,
          'related_contact_id': related,
          'relationship_type': type,
          'relationship_category': null,
        });
    await seed(a, b, 'Mother');
    await seed(a, c, 'Gym buddy');
    await seed(b, c, null);

    // Reopening runs the self-healing migration in _onOpen.
    await DatabaseHelper().close();
    final reopened = await DatabaseHelper().database;

    Future<String?> categoryOf(int owner, int related) async {
      final rows = await reopened.query(
        'relationships',
        columns: ['relationship_category'],
        where: 'contact_id = ? AND related_contact_id = ?',
        whereArgs: [owner, related],
      );
      return rows.single['relationship_category'] as String?;
    }

    expect(
      await categoryOf(a, b),
      RelationshipCategory.immediateFamily.storageKey,
    );
    // Unknown and null labels both land in the safe default.
    expect(await categoryOf(a, c), RelationshipCategory.social.storageKey);
    expect(await categoryOf(b, c), RelationshipCategory.social.storageKey);
  });
}
