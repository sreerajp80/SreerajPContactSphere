// lib/services/sim_service.dart
import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';

/// Thin, caching front-end over [TelecomService.getSimAccounts].
///
/// The SIM set rarely changes within a session, so we cache it and expose small
/// helpers the settings screen, the call lifecycle, and [CallEventLogger] all
/// share: list the SIMs, map a phone-account id to a label, and resolve which
/// SIM to place a call on given the user's settings. Degrades to "no SIMs" off
/// Android / when the permission is missing.
class SimService {
  SimService._internal();
  static final SimService _instance = SimService._internal();
  factory SimService() => _instance;

  final TelecomService _telecom = TelecomService();

  List<SimAccount>? _cache;

  /// Active SIMs, cached after the first successful load. Pass [refresh] to
  /// force a re-query (e.g. the settings screen pulling to refresh).
  Future<List<SimAccount>> list({bool refresh = false}) async {
    if (!refresh && _cache != null) return _cache!;
    final sims = await _telecom.getSimAccounts();
    _cache = sims;
    return sims;
  }

  /// Whether the device exposes more than one SIM (so a chooser makes sense).
  Future<bool> get hasMultiple async => (await list()).length > 1;

  /// The SIM with [phoneAccountId], or null if it isn't among the current SIMs.
  SimAccount? _byId(List<SimAccount> sims, String? phoneAccountId) {
    if (phoneAccountId == null || phoneAccountId.isEmpty) return null;
    for (final s in sims) {
      if (s.phoneAccountId == phoneAccountId) return s;
    }
    return null;
  }

  /// Human label for a logged call's [phoneAccountId], using the cached SIM
  /// list. Returns null when it can't be resolved (unknown / no SIMs loaded).
  Future<String?> labelFor(String? phoneAccountId) async {
    final sim = _byId(await list(), phoneAccountId);
    return sim?.displayLabel;
  }

  /// The full [SimAccount] for [phoneAccountId] (e.g. for its slot index), or
  /// null when it can't be resolved. Uses the cached SIM list like [labelFor].
  Future<SimAccount?> accountFor(String? phoneAccountId) async =>
      _byId(await list(), phoneAccountId);

  /// The user's configured default SIM ([defaultSimId]), or null to let the
  /// platform pick (system default). Falls back to null when the stored id no
  /// longer matches an active SIM.
  Future<SimAccount?> defaultSim(String? defaultSimId) async =>
      _byId(await list(), defaultSimId);

  /// Which SIM a call should go out on, given the contact's own preference and
  /// the global default. Pure and synchronous so the precedence is unit-testable
  /// without a device: pass the SIM list in.
  ///
  /// Order: the **contact's preferred SIM**, then the **global default SIM**,
  /// then null (let Android choose). An id that no longer matches a SIM in
  /// [sims] — a removed or swapped SIM — is skipped rather than honoured, so a
  /// stale preference silently degrades to the default instead of failing the
  /// call.
  static SimAccount? resolve({
    String? contactPreferredId,
    String? defaultSimId,
    required List<SimAccount> sims,
  }) {
    for (final id in [contactPreferredId, defaultSimId]) {
      if (id == null || id.isEmpty) continue;
      for (final sim in sims) {
        if (sim.phoneAccountId == id) return sim;
      }
    }
    return null;
  }

  /// [resolve] against the live SIM list, looking the contact's preference up
  /// by id. Skips the database read when [contactId] is null (an unknown number
  /// from the dialer), so the common case costs nothing extra.
  Future<SimAccount?> resolveForCall({
    int? contactId,
    String? defaultSimId,
    ContactRepository? contacts,
  }) async {
    String? preferred;
    if (contactId != null) {
      try {
        preferred = await (contacts ?? ContactRepository()).preferredSimId(
          contactId,
        );
      } catch (_) {
        // A failed lookup must never block the call — fall back to the default.
      }
    }
    return resolve(
      contactPreferredId: preferred,
      defaultSimId: defaultSimId,
      sims: await list(),
    );
  }
}
