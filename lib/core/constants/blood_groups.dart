// lib/core/constants/blood_groups.dart
//
// The eight ABO/Rh blood groups, plus a cleaner for values that were typed by
// hand before the pickers existed (and for values arriving from device-contact
// sync or an imported backup).
//
// Blood group is a closed set, so the UI offers a picker rather than a text
// field: a typo like "0+" (zero) or "B-" for "B+" is silent and, on the
// emergency lock-screen card, dangerous.

/// The eight standard blood groups, in the order shown in the pickers.
const List<String> kBloodGroups = [
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];

/// Turns a free-text blood group into one of [kBloodGroups].
///
/// Handles the spellings people actually type — `o positive`, `B +ve`, `AB neg`,
/// `0-` (zero instead of the letter O). Returns `null` when [raw] is empty or
/// cannot be read as a blood group; callers keep the original text in that case
/// so nothing is silently thrown away.
String? normalizeBloodGroup(String? raw) {
  if (raw == null) return null;

  // Strip everything that is only decoration: spaces, dots, slashes and the
  // hyphens used as separators ("O - ve"). The sign is recovered from the
  // words/symbols below, so losing a separator hyphen is safe only after we
  // have looked for a real minus — hence the sign is read first.
  final upper = raw.toUpperCase();
  if (upper.trim().isEmpty) return null;

  final bool negative =
      upper.contains('NEG') || upper.contains('-VE') || upper.contains('-');
  final bool positive =
      upper.contains('POS') || upper.contains('+VE') || upper.contains('+');
  // Ambiguous or missing sign — a blood group without Rh is not usable.
  if (negative == positive) return null;

  // What is left of the letters decides the ABO group, so drop everything that
  // only spelled out the sign. No group contains V or E, so clearing the "VE"
  // of "+ve"/"-ve" cannot damage a real value.
  final letters = upper
      .replaceAll('POSITIVE', '')
      .replaceAll('POS', '')
      .replaceAll('NEGATIVE', '')
      .replaceAll('NEG', '')
      .replaceAll(RegExp(r'[^A-Z0]'), '')
      .replaceAll('VE', '')
      // A zero here is nearly always a mistyped letter O.
      .replaceAll('0', 'O');

  const groups = {'AB', 'A', 'B', 'O'};
  if (!groups.contains(letters)) return null;

  return '$letters${negative ? '-' : '+'}';
}
