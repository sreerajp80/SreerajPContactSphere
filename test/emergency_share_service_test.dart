// test/emergency_share_service_test.dart
//
// Unit tests for EmergencyShareService text formatting.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/models/emergency_info.dart';
import 'package:smart_contacts_dialer/services/emergency_share_service.dart';

void main() {
  group('EmergencyShareService formatAsText', () {
    test('formats filled emergency info into clean text block', () {
      final info = EmergencyInfo(
        enabled: true,
        ownerName: 'Sreeraj P',
        bloodGroup: 'B+',
        allergies: 'Penicillin',
        contacts: [
          EmergencyContactEntry(
            displayName: 'Amma',
            number: '+919876543210',
            relationLabel: 'Mother',
          ),
        ],
      );

      final text = EmergencyShareService().formatAsText(info);

      expect(text, contains('🚨 IN CASE OF EMERGENCY (ICE) 🚨'));
      expect(text, contains('Name: Sreeraj P'));
      expect(text, contains('• Blood group: B+'));
      expect(text, contains('• Allergies: Penicillin'));
      expect(text, contains('• Amma (Mother): +919876543210'));
    });

    test('omits switched-off fields from text block', () {
      final info = EmergencyInfo(
        enabled: true,
        ownerName: 'Sreeraj P',
        showOwnerName: false,
        bloodGroup: 'B+',
        showBloodGroup: false,
        allergies: 'Penicillin',
      );

      final text = EmergencyShareService().formatAsText(info);

      expect(text, isNot(contains('Name: Sreeraj P')));
      expect(text, isNot(contains('Blood group')));
      expect(text, contains('• Allergies: Penicillin'));
    });
  });
}
