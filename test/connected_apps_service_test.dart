// test/connected_apps_service_test.dart
//
// ConnectedAppsService is a thin channel wrapper; these tests pin down its two
// contracts: it never throws (empty list / false when the platform is absent,
// as under `flutter test`), and it maps the channel payload — including rows
// with missing fields — into the typed models.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/services/connected_apps_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('contact_sphere/connected_apps');
  final service = ConnectedAppsService();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('without a platform handler (test host)', () {
    test('fetchConnectedApps returns an empty list', () async {
      expect(await service.fetchConnectedApps('42'), isEmpty);
    });

    test('openAction returns false', () async {
      const action = ConnectedAppAction(
        dataId: 1,
        mimetype: 'vnd.android.cursor.item/vnd.com.whatsapp.profile',
        label: 'Message',
      );
      expect(await service.openAction(action), isFalse);
    });
  });

  test('fetchConnectedApps with an empty id skips the channel', () async {
    var called = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          called = true;
          return <dynamic>[];
        });
    expect(await service.fetchConnectedApps(''), isEmpty);
    expect(called, isFalse);
  });

  test('fetchConnectedApps maps the channel payload to models', () async {
    final icon = Uint8List.fromList([1, 2, 3]);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getConnectedApps');
          expect(call.arguments, {'contactId': '42'});
          return <dynamic>[
            {
              'package': 'com.whatsapp',
              'name': 'WhatsApp',
              'icon': icon,
              'actions': <dynamic>[
                {
                  'dataId': 10,
                  'mimetype':
                      'vnd.android.cursor.item/vnd.com.whatsapp.profile',
                  'label': 'Message +91 98…',
                },
                // Broken rows (missing id / mimetype) are dropped, not thrown.
                {'label': 'broken'},
              ],
            },
            {
              'package': 'org.telegram.messenger',
              'name': 'Telegram',
              'icon': null,
              'actions': <dynamic>[
                {
                  'dataId': 11,
                  'mimetype':
                      'vnd.android.cursor.item/vnd.org.telegram.messenger.android.profile',
                  'label': 'Message',
                },
              ],
            },
          ];
        });

    final apps = await service.fetchConnectedApps('42');
    expect(apps, hasLength(2));

    final whatsapp = apps[0];
    expect(whatsapp.packageName, 'com.whatsapp');
    expect(whatsapp.name, 'WhatsApp');
    expect(whatsapp.icon, icon);
    expect(whatsapp.actions, hasLength(1));
    expect(whatsapp.actions[0].dataId, 10);
    expect(
      whatsapp.actions[0].mimetype,
      'vnd.android.cursor.item/vnd.com.whatsapp.profile',
    );
    expect(whatsapp.actions[0].label, 'Message +91 98…');

    final telegram = apps[1];
    expect(telegram.icon, isNull);
    expect(telegram.actions, hasLength(1));
  });

  test(
    'openAction forwards the action and returns the platform answer',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'openConnectedAppAction');
            expect(call.arguments, {
              'dataId': 10,
              'mimetype': 'vnd.android.cursor.item/vnd.com.whatsapp.profile',
            });
            return true;
          });
      const action = ConnectedAppAction(
        dataId: 10,
        mimetype: 'vnd.android.cursor.item/vnd.com.whatsapp.profile',
        label: 'Message',
      );
      expect(await service.openAction(action), isTrue);
    },
  );
}
