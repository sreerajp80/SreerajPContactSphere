// test/filename_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/utils/filename_utils.dart';

void main() {
  group('sanitizeFileName', () {
    test('preserves Malayalam names', () {
      expect(sanitizeFileName('ശ്രീരാജ്'), 'ശ്രീരാജ്');
      expect(sanitizeFileName('അനൂപ് P'), 'അനൂപ് P');
      expect(sanitizeFileName('സുരേഷ് കുമാർ'), 'സുരേഷ് കുമാർ');
    });

    test('replaces illegal OS filesystem characters with underscores', () {
      expect(sanitizeFileName('ശ്രീരാജ്/P'), 'ശ്രീരാജ്_P');
      expect(sanitizeFileName('John:Doe*Test'), 'John_Doe_Test');
      expect(sanitizeFileName('Contact? <1>'), 'Contact_ _1');
    });

    test('handles empty or whitespace strings with fallback', () {
      expect(sanitizeFileName(''), 'contact');
      expect(sanitizeFileName('   '), 'contact');
      expect(sanitizeFileName('***'), 'contact');
    });

    test('trims surrounding spaces and dots', () {
      expect(sanitizeFileName(' .ശ്രീരാജ്. '), 'ശ്രീരാജ്');
    });
  });
}
