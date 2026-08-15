import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';

void main() {
  group('PhoneNormalizer.sameNumber', () {
    test('national number matches the same number with a country code', () {
      // The reported case: contact saved as 9876543210, call arrives as +91....
      expect(
        PhoneNormalizer.sameNumber(
          '9876543210',
          '+919876543210',
          defaultIso: 'IN',
        ),
        isTrue,
      );
    });

    test('is symmetric (stored international, incoming national)', () {
      expect(
        PhoneNormalizer.sameNumber(
          '+919876543210',
          '9876543210',
          defaultIso: 'IN',
        ),
        isTrue,
      );
    });

    test('tolerates formatting differences', () {
      expect(
        PhoneNormalizer.sameNumber(
          '+91 98765 43210',
          '098765-43210',
          defaultIso: 'IN',
        ),
        isTrue,
      );
    });

    test('different numbers do not match', () {
      expect(
        PhoneNormalizer.sameNumber(
          '9876543210',
          '9999999999',
          defaultIso: 'IN',
        ),
        isFalse,
      );
    });

    test('a national number is not confused across a wrong default country', () {
      // Under US, "9876543210" is a 10-digit national number distinct from the
      // Indian +91 number, so they must not be treated as equal.
      expect(
        PhoneNormalizer.sameNumber(
          '9876543210',
          '+919876543210',
          defaultIso: 'US',
        ),
        isFalse,
      );
    });

    test(
      'toE164 canonicalizes a national number under the default country',
      () {
        expect(
          PhoneNormalizer.toE164('9876543210', defaultIso: 'IN'),
          '+919876543210',
        );
      },
    );
  });

  group('PhoneNormalizer.split / compose (Add-contact country chip)', () {
    test('split keeps the embedded country code over the home country', () {
      // A US number typed while the home country is India must resolve to US.
      final parts = PhoneNormalizer.split('+15551234567', defaultIso: 'IN');
      expect(parts, isNotNull);
      expect(parts!.iso, 'US');
      expect(parts.national, '5551234567');
    });

    test('split treats a bare national number as the home country', () {
      final parts = PhoneNormalizer.split('9876543210', defaultIso: 'IN');
      expect(parts, isNotNull);
      expect(parts!.iso, 'IN');
      expect(parts.national, '9876543210');
    });

    test('split returns null for empty input', () {
      expect(PhoneNormalizer.split('   ', defaultIso: 'IN'), isNull);
    });

    test('compose builds E.164 from a picked country and national number', () {
      expect(
        PhoneNormalizer.compose(iso: 'US', national: '5551234567'),
        '+15551234567',
      );
      expect(
        PhoneNormalizer.compose(iso: 'IN', national: '98765 43210'),
        '+919876543210',
      );
    });

    test('compose yields empty string for a digitless national number', () {
      expect(PhoneNormalizer.compose(iso: 'IN', national: '  '), '');
    });

    test(
      'compose(split(x)) round-trips a US number under an IN home country',
      () {
        // The end-to-end guarantee: a US contact stored via the chip while the
        // home country is India remains a US E.164 number (fixes "Case B").
        const stored = '+15551234567';
        final parts = PhoneNormalizer.split(stored, defaultIso: 'IN');
        final composed = PhoneNormalizer.compose(
          iso: parts!.iso,
          national: parts.national,
        );
        expect(composed, stored);
        // And it still matches an incoming US caller ID under the IN default.
        expect(
          PhoneNormalizer.sameNumber(
            composed,
            '+1 (555) 123-4567',
            defaultIso: 'IN',
          ),
          isTrue,
        );
      },
    );
  });

  group('PhoneNormalizer.validateNumber & formatForDisplay', () {
    test('validates standard 10-digit mobile number with default country', () {
      final res = PhoneNormalizer.validateNumber('9876543210', defaultIso: 'IN');
      expect(res.isValid, isTrue);
      expect(res.isPossible, isTrue);
      expect(res.countryDialCode, '91');
      expect(res.countryIso, 'IN');
      expect(res.errorReason, isNull);
    });

    test('validates international format number with country code', () {
      final res = PhoneNormalizer.validateNumber('+12025550123', defaultIso: 'IN');
      expect(res.isValid, isTrue);
      expect(res.isPossible, isTrue);
      expect(res.countryDialCode, '1');
      expect(res.countryIso, 'US');
    });

    test('detects short numbers as invalid', () {
      final res = PhoneNormalizer.validateNumber('123', defaultIso: 'IN');
      expect(res.isValid, isFalse);
      expect(res.errorReason, isNotNull);
    });

    test('formats for display', () {
      final formatted = PhoneNormalizer.formatForDisplay('9876543210', defaultIso: 'IN');
      expect(formatted, contains('+91'));
    });
  });
}
