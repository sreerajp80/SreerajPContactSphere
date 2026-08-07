import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';

void main() {
  group('transliterateMalayalam', () {
    test('simple name with word-final virama', () {
      expect(transliterateMalayalam('രമേഷ്'), 'ramesh');
    });

    test('conjuncts double the consonant', () {
      // ക്ക via virama → kk
      expect(transliterateMalayalam('അക്കു'), 'akku');
    });

    test('chillu endings', () {
      expect(transliterateMalayalam('കുമാർ'), 'kumaar');
      expect(transliterateMalayalam('ഉണ്ണിക്കണ്ണൻ'), 'unnikkannan');
    });

    test('zha is preserved', () {
      expect(transliterateMalayalam('കോഴിക്കോട്'), 'kozhikkot');
    });

    test('anusvara becomes m', () {
      expect(transliterateMalayalam('രാം'), 'raam');
    });

    test('mixed Malayalam and Latin passes Latin through', () {
      expect(transliterateMalayalam('Dr. രമേഷ്'), 'Dr. ramesh');
    });

    test('pure Latin input is unchanged', () {
      expect(transliterateMalayalam('John Smith'), 'John Smith');
    });

    test('empty input', () {
      expect(transliterateMalayalam(''), '');
    });
  });

  group('searchKey', () {
    test('query and stored Malayalam name produce the same key', () {
      expect(searchKey('ramesh'), searchKey('രമേഷ്'));
      expect(searchKey('kumar'), searchKey('കുമാർ'));
      expect(searchKey('priya'), searchKey('പ്രിയ'));
    });

    test('common Manglish spelling variants converge', () {
      expect(searchKey('sreeraj'), searchKey('ശ്രീരാജ്'));
      expect(searchKey('sriraj'), searchKey('ശ്രീരാജ്'));
      expect(searchKey('santhosh'), searchKey('santosh'));
      expect(searchKey('aswathy'), searchKey('asvati'));
    });

    test('latin names normalize consistently for both sides', () {
      // Both the stored key and the query go through searchKey, so Latin
      // names still match themselves after normalization.
      expect(searchKey('Reena Thomas'), searchKey('reena thomas'));
    });

    test('substring matching works on multi-word names', () {
      final stored = searchKey('രമേഷ് കുമാർ');
      expect(stored.contains(searchKey('ramesh')), isTrue);
      expect(stored.contains(searchKey('kumar')), isTrue);
    });

    test('Alex and Malayalam transliterations match accurately', () {
      expect(nameMatches('Ale', 'അലക്സ്'), isTrue);
      expect(nameMatches('Alex', 'അലക്സ്'), isTrue);
      expect(nameMatches('Ale', 'City Time Gallery'), isFalse);
      expect(nameMatches('അലക', 'Kumar Electrician'), isFalse);
      expect(nameMatches('അലക', 'ലൂക്കോസ്'), isFalse);
    });

    test('whitespace is collapsed and trimmed', () {
      expect(searchKey('  ramesh   kumar '), searchKey('ramesh kumar'));
    });
  });

  group('sortRoman', () {
    test('romanizes Malayalam so it can interleave with English', () {
      // "അനു" → "anu" sorts next to English "Anu"/"Ajay", not after 'z'.
      expect(sortRoman('അനു'), 'anu');
      expect(sortRoman('രമേഷ്'), 'ramesh');
    });

    test('lower-cases and trims Latin input, leaving spelling intact', () {
      // Lighter than searchKey: no th→t / doubled-letter collapsing.
      expect(sortRoman('  Reena Thomas '), 'reena thomas');
    });

    test('empty input', () {
      expect(sortRoman(''), '');
    });
  });

  group('initialFor', () {
    test('English first letter, upper-cased', () {
      expect(initialFor('ramesh'), 'R');
      expect(initialFor('  anu'), 'A');
    });

    test('Malayalam letter is a whole grapheme, not a half glyph', () {
      // A base consonant + vowel sign is several UTF-16 units; the initial must
      // be a whole letter, not name[0].
      final initial = initialFor('രമേഷ്');
      expect(initial, 'ര'.characters.first.toUpperCase());
      // Not a broken single code unit.
      expect(initial.characters.length, 1);
    });

    test('vowel signs are stripped, leaving the base consonant', () {
      // 'ൊ' is a *split* vowel sign: it draws to the left and the right of its
      // consonant, so keeping it makes the initial far too wide for an avatar.
      expect(initialFor('കൊച്ചി'), 'ക');
      expect(initialFor('ചിന്നു'), 'ച');
      expect(initialFor('രമേഷ്'), 'ര');
      expect(initialFor('കൊച്ചി').characters.length, 1);
    });

    test('chillu is a base letter and is kept', () {
      expect(initialFor('ൻസി'), 'ൻ');
    });

    test('empty name falls back to ?', () {
      expect(initialFor(''), '?');
      expect(initialFor('   '), '?');
    });
  });

  group('sectionLetterFor', () {
    test('buckets English and Malayalam under the same Latin letter', () {
      expect(sectionLetterFor('Anu'), 'A');
      expect(sectionLetterFor('അനു'), 'A'); // romanizes to "anu"
      expect(sectionLetterFor('രമേഷ്'), 'R');
    });

    test('digits and symbols and empty fall under #', () {
      expect(sectionLetterFor('3M'), '#');
      expect(sectionLetterFor('+Team'), '#');
      expect(sectionLetterFor(''), '#');
    });
  });
}
