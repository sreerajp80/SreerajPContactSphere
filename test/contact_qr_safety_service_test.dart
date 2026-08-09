// test/contact_qr_safety_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/social_link.dart';
import 'package:smart_contacts_dialer/services/contact_qr_safety_service.dart';

void main() {
  group('ContactQrSafetyService', () {
    final service = ContactQrSafetyService();

    test('flags normal safe contact payload as safe', () {
      final contact = Contact(firstName: 'Jane', lastName: 'Doe')
        ..phoneNumbers = []
        ..emails = [];
      const payload = 'BEGIN:VCARD\r\nVERSION:3.0\r\nN:Doe;Jane;;;\r\nFN:Jane Doe\r\nEND:VCARD';

      final report = service.analyzePayload(payload, [contact]);

      expect(report.isSafe, isTrue);
      expect(report.riskLevel, equals(ContactQrRiskLevel.safe));
      expect(report.overallRiskScore, lessThan(0.2));
    });

    test('flags suspicious script injection in payload', () {
      final contact = Contact(firstName: 'Malicious', lastName: 'User');
      const payload =
          'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:<script>alert(1)</script>\r\nEND:VCARD';

      final report = service.analyzePayload(payload, [contact]);

      expect(report.isSafe, isFalse);
      expect(report.riskLevel, equals(ContactQrRiskLevel.highRisk));
      expect(
        report.detectedSignals.any((s) => s.contains('code injection')),
        isTrue,
      );
    });

    test('flags raw IP address and executable payload links', () {
      final contact = Contact(firstName: 'John', lastName: 'Smith')
        ..socialLinks = [
          SocialLink(label: 'URL', value: 'http://192.168.1.100/download.apk'),
        ];
      const payload =
          'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:John Smith\r\nURL:http://192.168.1.100/download.apk\r\nEND:VCARD';

      final report = service.analyzePayload(payload, [contact]);

      expect(report.isSafe, isFalse);
      expect(
        report.detectedSignals.any((s) => s.contains('IP address link')),
        isTrue,
      );
      expect(
        report.detectedSignals.any((s) => s.contains('executable payload link')),
        isTrue,
      );
      expect(report.sanitizedContacts.first.socialLinks.isEmpty, isTrue);
    });

    test('flags overlong field names and notes', () {
      final longName = 'A' * 300;
      final contact = Contact(firstName: longName, lastName: 'Test');
      final payload =
          'BEGIN:VCARD\r\nVERSION:3.0\r\nFN:$longName Test\r\nEND:VCARD';

      final report = service.analyzePayload(payload, [contact]);

      expect(report.riskLevel, isNot(equals(ContactQrRiskLevel.safe)));
      expect(
        report.detectedSignals.any((s) => s.contains('unusually long')),
        isTrue,
      );
      expect(
        report.sanitizedContacts.first.firstName.length,
        lessThanOrEqualTo(256),
      );
    });
  });
}
