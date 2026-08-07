// lib/utils/affiliation_key.dart
//
// Match keys for "who shares a home or an employer with this contact".
//
// Address house/company names are free text typed by hand, so the same house is
// spelled "Sreelakshmi", "sreelakshmi " and "Sreelakshmi (H)", and the same
// employer is "Infosys Ltd", "INFOSYS" and "Infosys Limited". Comparing the raw
// strings finds almost nothing; these functions fold each one into a canonical
// key so equal keys mean "same house" / "same company".
//
// Used only to *suggest* group/tag members — a wrong key costs the user one
// ignored suggestion, never a wrong write. Nothing here is persisted, so the
// rules can be tightened later without a migration.

/// Words that carry no identifying information at the end of a company name, so
/// "Infosys Ltd" and "Infosys" fold together.
const Set<String> _legalSuffixes = {
  'ltd',
  'limited',
  'pvt',
  'private',
  'inc',
  'incorporated',
  'llp',
  'llc',
  'plc',
  'co',
  'corp',
  'corporation',
  'company',
  'group',
  'enterprises',
};

/// Trailing markers that just say "this is a house", not which house. Kerala
/// addresses very often carry them — "Sreelakshmi (H)", "Sreelakshmi House" —
/// and they must not split one household in two.
const Set<String> _houseSuffixes = {'h', 'ho', 'house', 'hs'};

/// Values people type to mean "nothing useful". Left as real keys these would
/// cluster every unrelated contact into one huge false household.
const Set<String> _stopValues = {
  'house',
  'home',
  'my house',
  'my home',
  'office',
  'work',
  'na',
  'n a',
  'nil',
  'none',
  'nothing',
  'unknown',
  'address',
  'self',
  'same',
};

/// Shortest key we trust. Two characters match far too much to be a useful
/// suggestion (and is usually an abbreviation, not a name).
const int _minKeyLength = 3;

/// Folds free text into a comparable key: lowercased, punctuation removed,
/// whitespace collapsed. Returns null when the text carries no usable signal —
/// blank, too short, or a stop value like "house" or "n/a".
String? _fold(String? raw) {
  if (raw == null) return null;
  final cleaned = raw
      .toLowerCase()
      // Keep letters, digits and marks (so Malayalam survives intact); every
      // separator and punctuation mark becomes a space.
      .replaceAll(RegExp(r'[^\p{L}\p{N}\p{M}]+', unicode: true), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
  if (cleaned.isEmpty) return null;
  if (_stopValues.contains(cleaned)) return null;
  if (cleaned.replaceAll(' ', '').length < _minKeyLength) return null;
  return cleaned;
}

/// Key for a **house**, pairing the house name with its locality so a common
/// house name in two different places does not merge into one household.
///
/// [locality] should be the address's post office, falling back to its
/// city/town. A house name with no locality at all still yields a key — losing
/// the pairing is better than losing the suggestion, and the house name alone is
/// usually distinctive enough.
String? houseAffiliationKey(String? houseName, {String? locality}) {
  final folded = _fold(houseName);
  if (folded == null) return null;

  final name = _dropTrailing(folded, _houseSuffixes);
  if (name == null) return null;

  final place = _fold(locality);
  return place == null ? 'house:$name' : 'house:$name@$place';
}

/// Drops trailing noise words while something identifying remains, so a name
/// made only of such words ("House", "Group") keeps its key rather than
/// vanishing. Returns null if what is left is too short to trust.
String? _dropTrailing(String folded, Set<String> suffixes) {
  final words = folded.split(' ');
  while (words.length > 1 && suffixes.contains(words.last)) {
    words.removeLast();
  }
  final trimmed = words.join(' ');
  if (trimmed.replaceAll(' ', '').length < _minKeyLength) return null;
  return trimmed;
}

/// Key for a **company**, matched on the name alone: one employer legitimately
/// spans many addresses, so pairing it with a locality would split colleagues in
/// different offices apart.
///
/// Trailing legal words are dropped so "Infosys Ltd" and "Infosys" agree. They
/// are only dropped while something else remains — a company literally named
/// "Group" keeps its key rather than becoming null.
String? companyAffiliationKey(String? companyName) {
  final folded = _fold(companyName);
  if (folded == null) return null;

  final name = _dropTrailing(folded, _legalSuffixes);
  if (name == null) return null;
  return 'company:$name';
}
