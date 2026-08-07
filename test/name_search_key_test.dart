import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';

/// The names that motivated the phonetic code: an English spelling and its
/// Malayalam spelling must produce the same sound-only key, without any
/// per-name rule in the transliterator.
void main() {
  group('phoneticCode collapses spelling disagreements', () {
    const pairs = <String, List<String>>{
      'Michael': ['മൈക്കിൾ'],
      'Suresh': ['സുരേഷ്', 'സുരേശ്'],
      'Sreeraj': ['ശ്രീരാജ്'],
    };

    pairs.forEach((latin, malayalamSpellings) {
      for (final mal in malayalamSpellings) {
        test('$latin == $mal', () {
          expect(phoneticCode(mal), phoneticCode(latin));
          expect(phoneticCode(latin).length, greaterThanOrEqualTo(2));
        });
      }
    });

    test('vowel choice does not change the code', () {
      expect(phoneticCode('Suresh'), phoneticCode('Sirosh'));
      expect(phoneticCode('Sudheer'), phoneticCode('Sudhir'));
    });

    test('aspiration and doubling do not change the code', () {
      expect(phoneticCode('Sudheer'), phoneticCode('Sudeer'));
      expect(phoneticCode('Michael'), phoneticCode('Micchaell'));
    });

    test('c/k/g and t/d and p/f/b fold together', () {
      expect(phoneticCode('Cecil'), phoneticCode('Kekil'));
      expect(phoneticCode('Vinod'), phoneticCode('Vinot'));
      expect(phoneticCode('Philip'), phoneticCode('Pilip'));
    });
  });

  group('phoneticCode keeps genuinely different names apart', () {
    test('v is not b', () {
      expect(phoneticCode('Vinu'), isNot(phoneticCode('Binu')));
    });

    test('n is not m, r is not l, j is not s', () {
      expect(phoneticCode('Anand'), isNot(phoneticCode('Amand')));
      expect(phoneticCode('Ravi'), isNot(phoneticCode('Lavi')));
      expect(phoneticCode('Raju'), isNot(phoneticCode('Rasu')));
    });

    test('zh stays distinct from z and s', () {
      expect(phoneticCode('Ezhil'), isNot(phoneticCode('Ezil')));
    });
  });

  group('phoneticMatches is word-anchored and length-guarded', () {
    test('matches at the start of the name', () {
      expect(phoneticMatches(phoneticCode('Michael'), phoneticCode('മൈക്കിൾ')), isTrue);
    });

    test('matches at the start of a later word', () {
      expect(
        phoneticMatches(phoneticCode('Suresh'), phoneticCode('Anil Suresh')),
        isTrue,
      );
    });

    test('does not match mid-word', () {
      // "res" sits inside Suresh but does not start a word there.
      expect(phoneticMatches(phoneticCode('res'), phoneticCode('Suresh')), isFalse);
    });

    test('a one-letter code never matches', () {
      expect(phoneticMatches(phoneticCode('a'), phoneticCode('Michael')), isFalse);
      expect(phoneticMatches(phoneticCode('M'), phoneticCode('Michael')), isFalse);
    });
  });

  group('nameMatches keeps the existing searchKey behaviour', () {
    test('plain English substring still matches', () {
      expect(nameMatches('chae', 'Michael'), isTrue);
    });

    test('Manglish spelling variants still match', () {
      expect(nameMatches('sriraj', 'ശ്രീരാജ്'), isTrue);
      expect(nameMatches('Sreeraj', 'ശ്രീരാജ്'), isTrue);
    });

    test('the reported failures now match', () {
      expect(nameMatches('Michael', 'മൈക്കിൾ'), isTrue);
      expect(nameMatches('Suresh', 'സുരേഷ്'), isTrue);
      expect(nameMatches('Suresh', 'സുരേശ്'), isTrue);
    });

    test('an unrelated name does not match', () {
      expect(nameMatches('Michael', 'Ramesh'), isFalse);
      expect(nameMatches('Suresh', 'Michael'), isFalse);
    });
  });
}
