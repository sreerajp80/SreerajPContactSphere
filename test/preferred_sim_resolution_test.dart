// Unit tests for SimService.resolve — which SIM a call goes out on.
//
// Pure and synchronous on purpose: the precedence (contact preference, then the
// global default, then "let Android choose") is the part that decides where a
// call is actually placed, so it is tested without a device, a database, or a
// platform channel.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';

SimAccount _sim(String id, {int? slot, String? name}) => SimAccount(
  phoneAccountId: id,
  componentName: 'com.example/Service',
  subscriptionId: int.tryParse(id),
  slotIndex: slot,
  displayName: name,
);

void main() {
  final sim1 = _sim('1', slot: 0, name: 'Personal');
  final sim2 = _sim('2', slot: 1, name: 'Work');
  final sims = [sim1, sim2];

  test('a contact preference wins over the global default', () {
    final chosen = SimService.resolve(
      contactPreferredId: '2',
      defaultSimId: '1',
      sims: sims,
    );
    expect(chosen?.phoneAccountId, '2');
  });

  test('the global default is used when the contact has no preference', () {
    expect(
      SimService.resolve(defaultSimId: '1', sims: sims)?.phoneAccountId,
      '1',
    );
    expect(
      SimService.resolve(
        contactPreferredId: '',
        defaultSimId: '1',
        sims: sims,
      )?.phoneAccountId,
      '1',
    );
  });

  test('a preference for a SIM no longer in the phone falls back', () {
    // SIM 2 was removed; the contact still points at it.
    final chosen = SimService.resolve(
      contactPreferredId: '2',
      defaultSimId: '1',
      sims: [sim1],
    );
    expect(chosen?.phoneAccountId, '1');
  });

  test('a stale preference AND a stale default give null', () {
    expect(
      SimService.resolve(
        contactPreferredId: '9',
        defaultSimId: '8',
        sims: sims,
      ),
      isNull,
    );
  });

  test('no preference and no default means let Android choose', () {
    expect(SimService.resolve(sims: sims), isNull);
  });

  test('no SIMs at all means let Android choose', () {
    expect(
      SimService.resolve(
        contactPreferredId: '1',
        defaultSimId: '1',
        sims: const [],
      ),
      isNull,
    );
  });
}
