// Loopback test for the P2P transport (connect-then-choose). No database and no
// devices: a host and a client run as independent P2PSyncService instances over
// 127.0.0.1. Covers the happy path (client connects, the host holds open and
// then pushes a payload the client receives), a wrong pairing code being
// rejected, and pushing with no connected client reporting an error.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/services/p2p_sync_service.dart';
import 'package:smart_contacts_dialer/services/sync_bundle_service.dart';

ExportBundle _bundle(String metaJson) => ExportBundle(
  metaJson,
  const [],
  const SyncSummary(contactsAdded: 3, groups: 1, callLogs: 2),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('client connects, then receives the payload the host pushes', () async {
    final host = P2PSyncService.forTest();
    final client = P2PSyncService.forTest();
    const metaJson = '{"protocol":2,"files":[],"tables":{}}';

    await host.startHost();
    final hosting = host.state as SyncHosting;

    // Model "sender chooses": push as soon as the client authenticates.
    host.addListener(() {
      final s = host.state;
      if (s is SyncHosting && s.clientConnected) {
        host.debugPushBundle(_bundle(metaJson));
      }
    });

    var sawConnected = false;
    final received = await client.debugConnectFetchMeta(
      '127.0.0.1',
      hosting.port,
      hosting.code,
      onConnected: () => sawConnected = true,
    );

    expect(received, metaJson);
    expect(sawConnected, isTrue);

    await host.cancel();
    await client.cancel();
  });

  test('a wrong pairing code is rejected and never connects', () async {
    final host = P2PSyncService.forTest();
    final client = P2PSyncService.forTest();

    await host.startHost();
    final hosting = host.state as SyncHosting;

    await expectLater(
      client.debugConnectFetchMeta(
        '127.0.0.1',
        hosting.port,
        'ZZZZ2345ZZZZ2345',
      ),
      throwsA(isA<P2PException>()),
    );

    await host.cancel();
    await client.cancel();
  });

  test('pushing with no connected client reports an error', () async {
    final host = P2PSyncService.forTest();
    await host.debugPushBundle(
      _bundle('{"protocol":2,"files":[],"tables":{}}'),
    );
    expect(host.state, isA<SyncError>());
    await host.cancel();
  });
}
