// lib/services/caller_id_service.dart
//
// Local caller identification for numbers that aren't saved contacts. There is
// no public spam-database API (Truecaller / Google keep theirs closed), so
// identification is built from what's available on the device:
//   - the user's own spam marks (flagged_numbers, kind 'spam');
//   - India's TRAI number series: commercial calls originate from the
//     dedicated `140` (promotional/telemarketing) and `160` (transactional /
//     service, e.g. banks and utilities) prefixes;
//   - the network's STIR/SHAKEN verification flag (surfaced separately via
//     CallState.verificationStatus — it isn't part of this lookup).
// A commercial reputation API could later back [identify] without the UI
// changing: this service is the seam.

import 'package:smart_contacts_dialer/repositories/flagged_number_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';

/// What could be determined about a non-contact caller. [label] is the short
/// badge text the call UI shows; [isSpam] drives the red styling (and, when
/// the spam filter is on, matches what the native screening service silences).
class CallerIdInfo {
  final String label;
  final bool isSpam;

  const CallerIdInfo({required this.label, required this.isSpam});
}

class CallerIdService {
  CallerIdService({FlaggedNumberRepository? flagged})
    : _flagged = flagged ?? FlaggedNumberRepository();

  final FlaggedNumberRepository _flagged;

  /// Identifies [number] from local sources, strongest signal first: a
  /// user-reported spam mark, then the TRAI series. Null when nothing is known
  /// (the common case — an ordinary unknown number). Callers should skip this
  /// for saved contacts and honor the Caller identification setting.
  Future<CallerIdInfo?> identify(String number, {String? defaultIso}) async {
    if (number.trim().isEmpty) return null;
    final iso = defaultIso ?? await AppSettings.readDefaultCountryIso();
    try {
      if (await _flagged.isFlagged(
        number,
        kind: FlaggedNumberRepository.kindSpam,
        defaultIso: iso,
      )) {
        return const CallerIdInfo(label: 'Suspected spam', isSpam: true);
      }
    } catch (_) {
      // Best-effort; fall through to the series rules.
    }
    return identifyBySeries(number, defaultIso: iso);
  }

  /// The TRAI number-series rules alone (pure, synchronous — also what the
  /// native screening service applies for the spam filter). `140…` numbers are
  /// telemarketing (treated as spam); `160…` are registered service calls
  /// (labelled, not spam). Only applies to Indian numbers.
  static CallerIdInfo? identifyBySeries(
    String number, {
    required String defaultIso,
  }) {
    final parts = PhoneNormalizer.split(number, defaultIso: defaultIso);
    if (parts == null || parts.iso != 'IN') return null;
    final national = parts.national;
    if (national.length >= 10 && national.startsWith('140')) {
      return const CallerIdInfo(label: 'Telemarketing', isSpam: true);
    }
    if (national.length >= 10 && national.startsWith('160')) {
      return const CallerIdInfo(label: 'Service call', isSpam: false);
    }
    return null;
  }
}
