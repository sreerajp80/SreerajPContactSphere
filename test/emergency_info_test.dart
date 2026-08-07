// Unit tests for the emergency card's mirror payload — the one place data
// leaves the encrypted DB in plaintext, so the "only what the user switched on"
// rule is worth pinning down. Pure Dart: no DB, no binding needed.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/models/emergency_info.dart';

EmergencyInfo _filled({bool enabled = true}) => EmergencyInfo(
  enabled: enabled,
  ownerName: 'Sreeraj P',
  bloodGroup: 'B+',
  allergies: 'Penicillin',
  medications: 'Metformin',
  conditions: 'Diabetes',
  notes: 'Speaks Malayalam',
  address: '12 Kakkanad, Kochi',
  showAddress: true,
  organDonor: true,
  contacts: [
    EmergencyContactEntry(
      contactId: 7,
      displayName: 'Anita',
      number: '+919876543210',
      relationLabel: 'Wife',
    ),
  ],
);

void main() {
  group('toMirrorJson', () {
    test('publishes nothing while the master switch is off', () {
      expect(_filled(enabled: false).toMirrorJson(), isNull);
    });

    test('publishes nothing when the card would be empty', () {
      final info = EmergencyInfo(enabled: true);
      expect(info.toMirrorJson(), isNull);
      expect(info.hasNothingToShow, isTrue);
    });

    test('publishes every switched-on field', () {
      final json = _filled().toMirrorJson()!;
      final labels = (json['rows'] as List)
          .map((r) => (r as Map)['label'])
          .toList();

      expect(json['v'], 1);
      expect(json['owner'], 'Sreeraj P');
      expect(labels, [
        EmergencyInfo.labelBloodGroup,
        EmergencyInfo.labelAllergies,
        EmergencyInfo.labelMedications,
        EmergencyInfo.labelConditions,
        EmergencyInfo.labelAddress,
        EmergencyInfo.labelNotes,
        EmergencyInfo.labelOrganDonor,
      ]);
    });

    test('a switched-off field never reaches the payload', () {
      final info = _filled()
        ..showAllergies = false
        ..showAddress = false
        ..showOwnerName = false;
      final json = info.toMirrorJson()!;
      final values = (json['rows'] as List)
          .map((r) => (r as Map)['value'] as String)
          .toList();

      expect(json.containsKey('owner'), isFalse);
      expect(values, isNot(contains('Penicillin')));
      expect(values, isNot(contains('12 Kakkanad, Kochi')));
      expect(values, contains('B+'));
    });

    test('an empty field is skipped even when switched on', () {
      final info = EmergencyInfo(enabled: true, bloodGroup: '   ', notes: 'X');
      final json = info.toMirrorJson()!;
      final labels = (json['rows'] as List)
          .map((r) => (r as Map)['label'])
          .toList();

      expect(labels, [EmergencyInfo.labelNotes]);
    });

    test('organ donor shows only when the flag itself is true', () {
      final info = _filled()..organDonor = false;
      final labels = info
          .visibleRows()
          .map((r) => r.label)
          .toList();
      expect(labels, isNot(contains(EmergencyInfo.labelOrganDonor)));
    });

    test('contacts carry name, relation and number — nothing else', () {
      final json = _filled().toMirrorJson()!;
      final people = (json['contacts'] as List).cast<Map>();

      expect(people, hasLength(1));
      expect(people.first.keys.toSet(), {'name', 'relation', 'number'});
      expect(people.first['name'], 'Anita');
      expect(people.first['number'], '+919876543210');
      // The DB link is deliberately not published.
      expect(people.first.containsKey('contact_id'), isFalse);
    });

    test('a hidden or incomplete contact is left out', () {
      final info = _filled();
      info.contacts.first.showOnLock = false;
      info.contacts.add(
        EmergencyContactEntry(displayName: 'No number', number: '  '),
      );

      final people = (info.toMirrorJson()!['contacts'] as List);
      expect(people, isEmpty);
    });

    test('contacts keep their sort order', () {
      final info = EmergencyInfo(
        enabled: true,
        contacts: [
          EmergencyContactEntry(
            displayName: 'Second',
            number: '2',
            sortOrder: 1,
          ),
          EmergencyContactEntry(displayName: 'First', number: '1'),
        ],
      );
      final names = (info.toMirrorJson()!['contacts'] as List)
          .map((c) => (c as Map)['name'])
          .toList();
      expect(names, ['First', 'Second']);
    });

    test('relation is omitted when blank', () {
      final info = EmergencyInfo(
        enabled: true,
        contacts: [
          EmergencyContactEntry(
            displayName: 'Anita',
            number: '1',
            relationLabel: '  ',
          ),
        ],
      );
      final people = (info.toMirrorJson()!['contacts'] as List).cast<Map>();
      expect(people.first.containsKey('relation'), isFalse);
    });
  });

  group('row round-trip', () {
    test('toMap / fromMap preserves values and flags', () {
      final original = _filled()..showNotes = false;
      final restored = EmergencyInfo.fromMap(
        original.toMap(),
        contacts: original.contacts,
      );

      expect(restored.enabled, isTrue);
      expect(restored.bloodGroup, 'B+');
      expect(restored.showNotes, isFalse);
      expect(restored.showAddress, isTrue);
      expect(restored.organDonor, isTrue);
      expect(restored.toMirrorJson(), original.toMirrorJson());
    });

    test('a fresh row (no saved record) is off and shows nothing', () {
      final fresh = EmergencyInfo.fromMap(const <String, dynamic>{});
      expect(fresh.enabled, isFalse);
      expect(fresh.toMirrorJson(), isNull);
    });

    test('contact entry round-trips through its map', () {
      final entry = EmergencyContactEntry(
        contactId: 3,
        displayName: 'Anita',
        number: '+919876543210',
        relationLabel: 'Wife',
        sortOrder: 2,
        showOnLock: false,
      );
      final restored = EmergencyContactEntry.fromMap(entry.toMap());

      expect(restored.contactId, 3);
      expect(restored.displayName, 'Anita');
      expect(restored.number, '+919876543210');
      expect(restored.relationLabel, 'Wife');
      expect(restored.sortOrder, 2);
      expect(restored.showOnLock, isFalse);
    });
  });
}
