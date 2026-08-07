// test/voice_dial_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/utils/voice_dial_parser.dart';

void main() {
  group('VoiceDialParser.parse', () {
    test('blank input yields nothing', () {
      expect(VoiceDialParser.parse(''), isNull);
      expect(VoiceDialParser.parse('   '), isNull);
    });

    test('recognizer digits become a number', () {
      expect(
        VoiceDialParser.parse('9847 12345'),
        const VoiceDialResult.number('984712345'),
      );
      expect(
        VoiceDialParser.parse('98-47'),
        const VoiceDialResult.number('9847'),
      );
    });

    test('digit words become a number', () {
      expect(
        VoiceDialParser.parse('nine eight four seven'),
        const VoiceDialResult.number('9847'),
      );
      expect(
        VoiceDialParser.parse('plus nine one 98'),
        const VoiceDialResult.number('+9198'),
      );
      expect(
        VoiceDialParser.parse('star six seven hash'),
        const VoiceDialResult.number('*67#'),
      );
    });

    test('a leading command word is dropped', () {
      expect(
        VoiceDialParser.parse('call nine one one'),
        const VoiceDialResult.number('911'),
      );
      expect(
        VoiceDialParser.parse('Call Amma'),
        const VoiceDialResult.name('Amma'),
      );
      expect(
        VoiceDialParser.parse('dial 9847'),
        const VoiceDialResult.number('9847'),
      );
    });

    test('anything not fully dialable is a name query', () {
      expect(
        VoiceDialParser.parse('Sreeraj'),
        const VoiceDialResult.name('Sreeraj'),
      );
      expect(
        VoiceDialParser.parse('John from work'),
        const VoiceDialResult.name('John from work'),
      );
      // Mixed digits + words → still a name search, not a mangled number.
      expect(
        VoiceDialParser.parse('flat 42 warden'),
        const VoiceDialResult.name('flat 42 warden'),
      );
    });

    test('a lone command word stays a name query', () {
      expect(VoiceDialParser.parse('call'), const VoiceDialResult.name('call'));
    });

    test('a Malayalam lead-in command word is dropped', () {
      // A Malayalam-locale recognizer renders spoken English "Call Vava" as
      // "കോൾ സീത" — the loanword "കോൾ" must be dropped like "call".
      expect(
        VoiceDialParser.parse('കോൾ സീത'),
        const VoiceDialResult.name('സീത'),
      );
      // Native "call" verb leading the phrase.
      expect(
        VoiceDialParser.parse('വിളിക്കൂ സീത'),
        const VoiceDialResult.name('സീത'),
      );
    });

    test(
      'a trailing Malayalam call-verb is dropped (verb-last word order)',
      () {
        // Natural Malayalam puts the verb last: "സീതയെ വിളിക്കൂ" → the name
        // "സീതയെ" (its case suffix is resolved later by stem matching).
        expect(
          VoiceDialParser.parse('സീതയെ വിളിക്കൂ'),
          const VoiceDialResult.name('സീതയെ'),
        );
      },
    );

    test('a lone Malayalam command word stays a name query', () {
      expect(VoiceDialParser.parse('കോൾ'), const VoiceDialResult.name('കോൾ'));
      expect(
        VoiceDialParser.parse('വിളിക്കൂ'),
        const VoiceDialResult.name('വിളിക്കൂ'),
      );
    });
  });
}
