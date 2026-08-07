// test/device_contact_service_test.dart
//
// Host-side tests for DeviceContactService's device -> app mapping (mapToApp
// is pure Dart; `persistPhoto: false` keeps it away from path_provider). The
// device fetch itself is platform-bound and covered manually on a device.

import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/services/device_contact_service.dart';

void main() {
  final service = DeviceContactService();

  test('a nameless device contact falls back to its phone number', () async {
    final mapped = await service.mapToApp(
      const fc.Contact(
        id: 'dev-1',
        phones: [fc.Phone(number: '98765 43210')],
      ),
      persistPhoto: false,
    );
    expect(mapped, isNotNull);
    // Shown by number, like the OS contacts app — not dropped.
    expect(mapped!.firstName, '98765 43210');
    expect(mapped.deviceId, 'dev-1');
  });

  test(
    'a nameless, numberless device contact falls back to its email',
    () async {
      final mapped = await service.mapToApp(
        const fc.Contact(
          id: 'dev-2',
          emails: [fc.Email(address: 'x@y.z')],
        ),
        persistPhoto: false,
      );
      expect(mapped, isNotNull);
      expect(mapped!.firstName, 'x@y.z');
    },
  );

  test('a device contact with nothing usable is dropped', () async {
    final mapped = await service.mapToApp(
      const fc.Contact(id: 'dev-3'),
      persistPhoto: false,
    );
    expect(mapped, isNull);
  });

  test('a named contact keeps its name (no fallback)', () async {
    final mapped = await service.mapToApp(
      const fc.Contact(
        id: 'dev-4',
        name: fc.Name(first: 'Asha', last: 'Menon'),
        phones: [fc.Phone(number: '111')],
      ),
      persistPhoto: false,
    );
    expect(mapped!.firstName, 'Asha');
    expect(mapped.lastName, 'Menon');
  });
}
