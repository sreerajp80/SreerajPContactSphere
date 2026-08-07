import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/utils/t9_utils.dart';

void main() {
  group('T9Utils tests', () {
    test('textToT9 converts English letters to keypad digits', () {
      expect(T9Utils.textToT9('John'), '5646');
      expect(T9Utils.textToT9('Doe'), '363');
      expect(T9Utils.textToT9('John Doe'), '5646 363');
      expect(T9Utils.textToT9('Alex'), '2539');
    });

    test('isT9Match identifies word prefix matches', () {
      // "John Doe" -> "5646 363"
      expect(T9Utils.isT9Match('John Doe', '5646'), isTrue); // "John"
      expect(T9Utils.isT9Match('John Doe', '564'), isTrue);  // prefix of "John"
      expect(T9Utils.isT9Match('John Doe', '363'), isTrue);  // "Doe"
      expect(T9Utils.isT9Match('John Doe', '36'), isTrue);   // prefix of "Doe"
      expect(T9Utils.isT9Match('John Doe', '999'), isFalse);
    });

    test('isT9Match supports Malayalam transliteration T9 matching', () {
      // "ശ്രീരാജ്" transliterates to "shreeraaj" (747...) and searchKey "sriraj" (774...)
      expect(T9Utils.isT9Match('ശ്രീരാജ്', '747'), isTrue); // "shr..."
      expect(T9Utils.isT9Match('ശ്രീരാജ്', '774'), isTrue); // "sri..."
    });

    test('scoreMatch ranks name prefix higher than phone number prefix', () {
      final namePrefixScore = T9Utils.scoreMatch('John Doe', '9847012345', '5646'); // "John"
      final phonePrefixScore = T9Utils.scoreMatch('Alice', '5646123456', '5646');  // phone start
      final phoneSubstrScore = T9Utils.scoreMatch('Bob', '9956460000', '5646');    // phone mid

      expect(namePrefixScore, equals(100));
      expect(phonePrefixScore, equals(85));
      expect(phoneSubstrScore, equals(45));

      expect(namePrefixScore, greaterThan(phonePrefixScore));
      expect(phonePrefixScore, greaterThan(phoneSubstrScore));
    });

    test('textToMalayalamT9 maps Malayalam script characters to digits 2-9', () {
      // "ക" -> 2, "ച" -> 3, "ട" -> 4, "ത" -> 5, "പ" -> 6, "യ" -> 7, "ശ" -> 8, "ള" -> 9
      expect(T9Utils.textToMalayalamT9('ക'), '2');
      expect(T9Utils.textToMalayalamT9('ച'), '3');
      expect(T9Utils.textToMalayalamT9('ട'), '4');
      expect(T9Utils.textToMalayalamT9('ത'), '5');
      expect(T9Utils.textToMalayalamT9('പ'), '6');
      expect(T9Utils.textToMalayalamT9('യ'), '7');
      expect(T9Utils.textToMalayalamT9('ശ'), '8');
      expect(T9Utils.textToMalayalamT9('ള'), '9');

      // "സുരേഷ്": സ (8), ു (3), ര (7), േ (4), ഷ (8) -> "83748"
      expect(T9Utils.textToMalayalamT9('സുരേഷ്'), '83748');
      // Consonant-only: സ (8), ര (7), ഷ (8) -> "878"
      expect(T9Utils.textToMalayalamT9('സുരേഷ്', consonantsOnly: true), '878');
    });

    test('isT9Match supports direct Malayalam keypad dialing', () {
      // "സുരേഷ്" matches when dialing full Malayalam T9 digits "83748"
      expect(T9Utils.isT9Match('സുരേഷ്', '83748'), isTrue);
      // "സുരേഷ്" matches when dialing consonant-only Malayalam T9 digits "878"
      expect(T9Utils.isT9Match('സുരേഷ്', '878'), isTrue);
      // "സുരേഷ്" matches prefix "87"
      expect(T9Utils.isT9Match('സുരേഷ്', '87'), isTrue);
      // Non-matching digits
      expect(T9Utils.isT9Match('സുരേഷ്', '222'), isFalse);
    });

    test('scoreMatch ranks direct Malayalam keypad matches with high score', () {
      final score = T9Utils.scoreMatch('സുരേഷ്', '9847000000', '878');
      expect(score, equals(100));
    });

    test('getScriptKeyLegends resolves legends for all supported scripts', () {
      final mlLegends = T9Utils.getScriptKeyLegends(DialpadScript.malayalam);
      expect(mlLegends['2'], 'ക-ങ');

      final devLegends = T9Utils.getScriptKeyLegends(DialpadScript.devanagari);
      expect(devLegends['2'], 'क-ङ');

      final cyrLegends = T9Utils.getScriptKeyLegends(DialpadScript.cyrillic);
      expect(cyrLegends['2'], 'АБВГ');

      final arLegends = T9Utils.getScriptKeyLegends(DialpadScript.arabic);
      expect(arLegends['2'], 'ا ب ت ث');

      final grLegends = T9Utils.getScriptKeyLegends(DialpadScript.greek);
      expect(grLegends['2'], 'ΑΒΓ');

      final noneLegends = T9Utils.getScriptKeyLegends(DialpadScript.none);
      expect(noneLegends, isEmpty);
    });

    test('charToT9Digit supports global scripts (Devanagari, Cyrillic, Arabic, Greek, Diacritics)', () {
      // Devanagari
      expect(T9Utils.charToT9Digit('क'), '2');
      expect(T9Utils.charToT9Digit('म'), '6');

      // Cyrillic
      expect(T9Utils.charToT9Digit('а'), '2');
      expect(T9Utils.charToT9Digit('я'), '9');

      // Arabic
      expect(T9Utils.charToT9Digit('ا'), '2');
      expect(T9Utils.charToT9Digit('م'), '8');

      // Greek
      expect(T9Utils.charToT9Digit('α'), '2');
      expect(T9Utils.charToT9Digit('ω'), '9');

      // Latin Diacritics
      expect(T9Utils.charToT9Digit('é'), '3');
      expect(T9Utils.charToT9Digit('ñ'), '6');
      expect(T9Utils.charToT9Digit('ç'), '2');
    });
  });
}
