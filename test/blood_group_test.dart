// test/blood_group_test.dart
//
// Covers the cleaner that turns hand-typed blood groups (from records saved
// before the pickers existed, from device-contact sync, or from an imported
// backup) into one of the eight standard values.

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/core/constants/blood_groups.dart';

void main() {
  group('normalizeBloodGroup', () {
    test('keeps already standard values', () {
      for (final g in kBloodGroups) {
        expect(normalizeBloodGroup(g), g);
      }
    });

    test('reads the spelled-out sign', () {
      expect(normalizeBloodGroup('o positive'), 'O+');
      expect(normalizeBloodGroup('A Negative'), 'A-');
      expect(normalizeBloodGroup('AB+ve'), 'AB+');
      expect(normalizeBloodGroup('b -ve'), 'B-');
      expect(normalizeBloodGroup('AB neg'), 'AB-');
    });

    test('treats a zero as the letter O', () {
      expect(normalizeBloodGroup('0-'), 'O-');
      expect(normalizeBloodGroup('0 positive'), 'O+');
    });

    test('ignores spacing and punctuation', () {
      expect(normalizeBloodGroup('  B  +  '), 'B+');
      expect(normalizeBloodGroup('a.b+'), 'AB+');
    });

    test('returns null for empty or unreadable input', () {
      expect(normalizeBloodGroup(null), isNull);
      expect(normalizeBloodGroup(''), isNull);
      expect(normalizeBloodGroup('   '), isNull);
      expect(normalizeBloodGroup('xyz'), isNull);
      // No Rh sign at all — not a usable blood group.
      expect(normalizeBloodGroup('O'), isNull);
      // Contradictory signs.
      expect(normalizeBloodGroup('O+-'), isNull);
      // A letter that is not an ABO group.
      expect(normalizeBloodGroup('C+'), isNull);
    });
  });
}
