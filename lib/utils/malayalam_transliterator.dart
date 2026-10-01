/// Malayalam → practical Latin ("Manglish") transliteration, used to let an
/// English-script search query match contact names stored in Malayalam script.
///
/// The mapping follows the conventions people actually type (Mozhi-style:
/// `ഴ → zh`, `ത → th`, chillu `ൻ → n`), not academic ISO-15919 — nobody
/// searches for `rameṣ`. Non-Malayalam characters pass through unchanged, so
/// Latin-script names survive the round trip intact.
library;

import 'package:characters/characters.dart';

/// Consonants, mapped to their base sound *without* the inherent `a` (the
/// transliterator adds it unless a vowel sign or virama follows).
const Map<String, String> _consonants = {
  'ക': 'k', 'ഖ': 'kh', 'ഗ': 'g', 'ഘ': 'gh', 'ങ': 'ng', //
  'ച': 'ch', 'ഛ': 'chh', 'ജ': 'j', 'ഝ': 'jh', 'ഞ': 'nj', //
  'ട': 't', 'ഠ': 't', 'ഡ': 'd', 'ഢ': 'd', 'ണ': 'n', //
  'ത': 'th', 'ഥ': 'th', 'ദ': 'd', 'ധ': 'dh', 'ന': 'n', //
  'പ': 'p', 'ഫ': 'ph', 'ബ': 'b', 'ഭ': 'bh', 'മ': 'm', //
  'യ': 'y', 'ര': 'r', 'ല': 'l', 'വ': 'v', //
  'ശ': 'sh', 'ഷ': 'sh', 'സ': 's', 'ഹ': 'h', //
  'ള': 'l', 'ഴ': 'zh', 'റ': 'r',
};

/// Dependent vowel signs (matras) — replace the consonant's inherent `a`.
const Map<String, String> _vowelSigns = {
  'ാ': 'aa', // ാ
  'ി': 'i', // ി
  'ീ': 'ee', // ീ
  'ു': 'u', // ു
  'ൂ': 'oo', // ൂ
  'ൃ': 'ri', // ൃ  (typed "ri": Krishnan, not Krushnan)
  'െ': 'e', // െ
  'േ': 'e', // േ
  'ൈ': 'ai', // ൈ
  'ൊ': 'o', // ൊ
  'ോ': 'o', // ോ
  'ൌ': 'au', // ൌ
  'ൗ': 'au', // ൗ
};

/// Characters that stand on their own: independent vowels, chillus,
/// anusvara/visarga, and Malayalam digits.
const Map<String, String> _standalone = {
  // Independent vowels.
  'അ': 'a', 'ആ': 'aa', 'ഇ': 'i', 'ഈ': 'ee', 'ഉ': 'u', 'ഊ': 'oo', //
  'ഋ': 'ru', 'എ': 'e', 'ഏ': 'e', 'ഐ': 'ai', 'ഒ': 'o', 'ഓ': 'o', 'ഔ': 'au',
  // Chillus (vowel-less consonants).
  'ൺ': 'n', // ൺ
  'ൻ': 'n', // ൻ
  'ർ': 'r', // ർ
  'ൽ': 'l', // ൽ
  'ൾ': 'l', // ൾ
  'ൿ': 'k', // ൿ
  // Anusvara / visarga.
  'ം': 'm', // ം
  'ഃ': 'h', // ഃ
  // Digits.
  '൦': '0', '൧': '1', '൨': '2', '൩': '3', '൪': '4', //
  '൫': '5', '൬': '6', '൭': '7', '൮': '8', '൯': '9',
};

const String _virama = '്'; // ്  (kills the inherent vowel)

/// Consonant clusters that are written one way and said (and typed) another,
/// keyed by their letters with the virama between them.
const Map<String, String> _conjuncts = {
  'ന്റ': 'nt', // ആന്റണി → Antony
  'ൻറ': 'nt', // older encoding of the same cluster
  'റ്റ': 'tt', // മറ്റം → Mattam
  'ങ്ങ': 'ng', // ങ്ങ → ng, not ngng
};

/// The [_conjuncts] entry starting at [i], as (latin, letters used), or null.
(String, int)? _conjunctAt(List<String> chars, int i) {
  for (final len in const [3, 2]) {
    if (i + len > chars.length) continue;
    final latin = _conjuncts[chars.sublist(i, i + len).join()];
    if (latin != null) return (latin, len);
  }
  return null;
}

/// Transliterates any Malayalam script in [input] to Latin, passing other
/// characters through unchanged. Handles conjuncts via the virama (ക്ക → kk)
/// and both modern atomic chillus and the legacy consonant+virama+ZWJ form.
String transliterateMalayalam(String input) {
  final buf = StringBuffer();
  var pendingA = false; // a consonant was emitted and may still take its `a`

  void flush() {
    if (pendingA) {
      buf.write('a');
      pendingA = false;
    }
  }

  final chars = input.runes.map(String.fromCharCode).toList();
  for (var i = 0; i < chars.length; i++) {
    final ch = chars[i];
    // Joiners only disambiguate rendering (legacy chillu encoding); the
    // preceding virama already handled the sound.
    if (ch == '‌' || ch == '‍') continue;
    // Conjuncts whose sound differs from their letters (ന്റ is said and typed
    // `nt`, not `nr`). The cluster keeps its inherent `a` like a consonant.
    final conjunct = _conjunctAt(chars, i);
    if (conjunct != null) {
      flush();
      buf.write(conjunct.$1);
      pendingA = true;
      i += conjunct.$2 - 1;
      continue;
    }
    final cons = _consonants[ch];
    if (cons != null) {
      flush();
      buf.write(cons);
      pendingA = true;
      continue;
    }
    final sign = _vowelSigns[ch];
    if (sign != null) {
      buf.write(sign);
      pendingA = false;
      continue;
    }
    if (ch == _virama) {
      pendingA = false;
      continue;
    }
    final standalone = _standalone[ch];
    if (standalone != null) {
      flush();
      buf.write(standalone);
      continue;
    }
    flush();
    buf.write(ch);
  }
  flush();
  return buf.toString();
}

final RegExp _aspirate = RegExp('([kgcjtdpbs])h');
final RegExp _doubles = RegExp(r'(.)\1+');
final RegExp _spaces = RegExp(r'\s+');

/// A loosely-normalized search key: transliterates, lowercases, and collapses
/// the spelling variations Manglish typists disagree on (th/t, sh/s, ee/i,
/// doubled letters, w/v, y/i, x/ks) so `sreeraj`, `sriraj`, and ശ്രീരാജ് all
/// produce the same key. Apply to **both** the stored name and the query —
/// keys are only ever compared against other keys.
String searchKey(String input) {
  var s = transliterateMalayalam(input).toLowerCase();
  s = s.replaceAll('x', 'ks');
  // `f` and `ph` are one sound (ഫ): Fathima / Phathima / ഫാത്തിമ.
  s = s.replaceAll('f', 'p');
  // Aspirated digraphs → base letter (kh→k, th→t, sh→s …; zh is untouched —
  // it's a distinct sound, not an aspirate). Loop so chh → ch → c.
  String prev;
  do {
    prev = s;
    s = s.replaceAllMapped(_aspirate, (m) => m[1]!);
  } while (s != prev);
  s = s.replaceAll('w', 'v').replaceAll('y', 'i');
  // Long-vowel digraphs whose collapse target differs from the letter itself
  // (ee → i, oo → u). aa/ii/uu are handled by the doubles collapse below.
  s = s.replaceAll('ee', 'i').replaceAll('oo', 'u');
  s = s.replaceAllMapped(_doubles, (m) => m[1]!);
  return s.replaceAll(_spaces, ' ').trim();
}

/// Letters that carry no reliable information about how a name is spelled:
/// every vowel, plus `y` (a glide people write as a vowel — Jayan/Jain) and
/// `h` (silent, or the aspiration half of th/kh/bh — Sudheer/Sudeer).
final RegExp _unreliable = RegExp('[aeiouyh]');

/// Sound classes for [phoneticCode]. Letters land in the same class only when
/// Malayalam speakers actually disagree about which one to type. Deliberately
/// *not* merged: `v`/`b` (Vinu is not Binu), `n`/`m`, `r`/`l`, and `j`/`s`.
const Map<String, String> _soundClass = {
  'k': 'k', 'c': 'k', 'q': 'k', 'g': 'k', // hard velar
  't': 't', 'd': 't', // dental/retroflex stop
  'p': 'p', 'f': 'p', 'b': 'p', // labial stop
  's': 's', 'z': 's', // sibilant
  'v': 'v', 'w': 'v', //
  'j': 'j', 'n': 'n', 'm': 'm', 'r': 'r', 'l': 'l',
};

/// Minimum length of a query's [phoneticCode] before it is allowed to match.
/// A one-letter code is a whole consonant class and would list most of the
/// address book.
const int phoneticCodeMinLen = 2;

/// A **sound-only** key: the name with every unreliable letter removed and the
/// rest folded to its sound class, so spellings that disagree about vowels or
/// about which letter stands for a sound still collide.
///
/// `Michael` and മൈക്കിൾ both give `mkl`; `Suresh`, സുരേഷ് and സുരേശ് all give
/// `srs`. Vowel-starting words preserve their initial vowel to prevent matching
/// consonant-starting or different-vowel-starting words.
String phoneticCode(String input) {
  final words = transliterateMalayalam(input).toLowerCase().split(_spaces);
  final codeWords = <String>[];
  for (var word in words) {
    if (word.isEmpty) continue;
    final initialChar = word.substring(0, 1);
    final isVowelStart = RegExp('[aeiou]').hasMatch(initialChar);
    word = word.replaceAll('zh', 'x');
    word = word.replaceAll('x', 'ks');
    word = word.replaceAll(_unreliable, '');
    final buf = StringBuffer();
    if (isVowelStart) {
      buf.write(initialChar);
    }
    for (final ch in word.split('')) {
      final cls = _soundClass[ch];
      buf.write(cls ?? ch);
    }
    final folded = buf.toString().replaceAllMapped(_doubles, (m) => m[1]!);
    if (folded.isNotEmpty) {
      codeWords.add(folded);
    }
  }
  return codeWords.join(' ');
}

/// Whether [queryCode] — a [phoneticCode] — matches [storedCode] at the start
/// of a word. Word-anchored on purpose: matching mid-word turns every short
/// code into a wildcard. Returns false for codes under [phoneticCodeMinLen].
bool phoneticMatches(String queryCode, String storedCode) {
  if (queryCode.length < phoneticCodeMinLen || storedCode.isEmpty) return false;
  return storedCode.startsWith(queryCode) || storedCode.contains(' $queryCode');
}

/// Shortest typed key (spaces removed) used for [compactKeyMatches].
const int compactMatchMinLen = 3;

/// [searchKey] with the spaces removed, so `sree raj`, `sreeraj` and
/// `Sreeraj P` can be compared regardless of where words split.
String compactKey(String key) => key.replaceAll(' ', '');

/// Whether typed [queryKey] matches stored [nameKey] (both [searchKey]s) when
/// spaces are ignored, starting at the beginning of some word of the name:
/// `sree raj` → `sriraj`, `sreerajp` → `sriraj p`. Still word-anchored on
/// purpose — matching mid-word made `Ale` find `City Time Gallery`.
bool compactKeyMatches(String queryKey, String nameKey) {
  final q = compactKey(queryKey);
  if (q.length < compactMatchMinLen) return false;
  for (var i = 0; i < nameKey.length; i++) {
    if (i > 0 && nameKey[i - 1] != ' ') continue;
    if (nameKey[i] == ' ') continue;
    if (compactKey(nameKey.substring(i)).startsWith(q)) return true;
  }
  return false;
}

/// How many typing mistakes a typed word of [length] letters may contain and
/// still count as "similar": none for short words (Binu/Vinu/Minu would all
/// collide), one for normal words, two for long ones.
int similarMistakeBudget(int length) {
  if (length <= 4) return 0;
  if (length <= 7) return 1;
  return 2;
}

/// Edit distance between [a] and [b]: the fewest single-letter inserts,
/// deletes, changes, or swaps of two neighbouring letters that turn one into
/// the other (`suresh` → `sureesh` is 1). Stops early and returns
/// `limit + 1` once the distance is sure to exceed [limit].
int editDistance(String a, String b, {int limit = 1 << 20}) {
  if ((a.length - b.length).abs() > limit) return limit + 1;
  if (a.isEmpty || b.isEmpty) return a.length + b.length;
  final n = b.length;
  var prev2 = List<int>.filled(n + 1, 0);
  var prev = List<int>.generate(n + 1, (j) => j);
  var cur = List<int>.filled(n + 1, 0);
  var prevRowMin = 0;
  for (var i = 1; i <= a.length; i++) {
    cur[0] = i;
    var rowMin = cur[0];
    for (var j = 1; j <= n; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      var d = prev[j] + 1;
      if (cur[j - 1] + 1 < d) d = cur[j - 1] + 1;
      if (prev[j - 1] + cost < d) d = prev[j - 1] + cost;
      if (i > 1 &&
          j > 1 &&
          a.codeUnitAt(i - 1) == b.codeUnitAt(j - 2) &&
          a.codeUnitAt(i - 2) == b.codeUnitAt(j - 1) &&
          prev2[j - 2] + 1 < d) {
        d = prev2[j - 2] + 1;
      }
      cur[j] = d;
      if (d < rowMin) rowMin = d;
    }
    // A swap reaches back two rows, so stop only once two rows in a row are
    // over the limit — nothing later can come back under it.
    if (rowMin > limit && prevRowMin > limit) return limit + 1;
    prevRowMin = rowMin;
    final t = prev2;
    prev2 = prev;
    prev = cur;
    cur = t;
  }
  final result = prev[n];
  return result > limit ? limit + 1 : result;
}

/// Fewest mistakes between typed word [word] and the start of [target], or
/// null when that is over the word's [similarMistakeBudget]. Comparing against
/// the start of [target] lets a half-typed name (`sures` → `suresh kumar`)
/// still match. The first letter must agree — people rarely get it wrong, and
/// it keeps `Vinu` and `Binu` apart.
int? _wordDistance(String word, String target) {
  final budget = similarMistakeBudget(word.length);
  if (budget == 0) return target.startsWith(word) ? 0 : null;
  if (target.isEmpty || target[0] != word[0]) return null;
  int? best;
  final lo = word.length - budget;
  final hi = word.length + budget;
  for (var len = lo; len <= hi; len++) {
    if (len < 1 || len > target.length) continue;
    final d = editDistance(word, target.substring(0, len), limit: budget);
    if (d <= budget && (best == null || d < best)) best = d;
  }
  return best;
}

/// How similar typed [queryKey] is to a stored name key [nameKey] (both
/// [searchKey]s), as the total number of typing mistakes — or null when they
/// are not similar. Every typed word must be close to the start of some word
/// in the name; failing that, the whole query (spaces removed) must be close
/// to the start of the whole name (spaces removed), so `sree raj` still finds
/// `sriraj`. Lower is closer; 0 is an exact prefix hit.
int? similarNameDistance(String queryKey, String nameKey) {
  final queryWords = queryKey.split(' ').where((w) => w.isNotEmpty).toList();
  final nameWords = nameKey.split(' ').where((w) => w.isNotEmpty).toList();
  if (queryWords.isEmpty || nameWords.isEmpty) return null;

  var total = 0;
  var allWordsMatched = true;
  for (final qw in queryWords) {
    int? best;
    for (final nw in nameWords) {
      final d = _wordDistance(qw, nw);
      if (d != null && (best == null || d < best)) best = d;
      if (best == 0) break;
    }
    if (best == null) {
      allWordsMatched = false;
      break;
    }
    total += best;
  }
  final byWords = allWordsMatched ? total : null;

  final whole = _wordDistance(compactKey(queryKey), compactKey(nameKey));
  if (byWords == null) return whole;
  if (whole == null) return byWords;
  return whole < byWords ? whole : byWords;
}

/// The single "does this name match what was typed" test, shared by the
/// in-memory searches so they agree with the SQL-backed ones: plain text
/// substring, word-anchored [searchKey] prefix hit (also with spaces ignored,
/// see [compactKeyMatches]), word-anchored [phoneticCode] hit, or a similar name (see
/// [similarNameDistance]).
bool nameMatches(String query, String name) {
  final q = query.trim();
  if (q.isEmpty) return false;

  final qLower = q.toLowerCase();
  final nLower = name.toLowerCase();
  if (nLower.contains(qLower)) return true;

  final key = searchKey(q);
  if (key.isNotEmpty) {
    final nameKey = searchKey(name);
    for (final word in nameKey.split(' ')) {
      if (word.startsWith(key)) return true;
    }
    if (compactKeyMatches(key, nameKey)) return true;
    if (phoneticMatches(phoneticCode(q), phoneticCode(name))) return true;
    return similarNameDistance(key, nameKey) != null;
  }
  return phoneticMatches(phoneticCode(q), phoneticCode(name));
}

/// A romanized key for **sorting** the contact list. Lighter than [searchKey]:
/// it transliterates and lower-cases but does *not* collapse spelling variants
/// (no th→t, no doubled-letter squashing), so the order stays close to the
/// actual spelling. Malayalam names become Latin, so they interleave with
/// English names under one A–Z order instead of clumping after `z` by code
/// point. Latin names pass through unchanged.
String sortRoman(String name) =>
    transliterateMalayalam(name).toLowerCase().trim();

/// True if [code] is a combining mark that hangs off a base letter — an Indic
/// vowel sign or virama, a Latin/other combining diacritic, or a variation
/// selector. Not a full Unicode category-Mn table, just the blocks that turn up
/// in contact names.
bool _isCombiningMark(int code) {
  // Combining diacritical marks (accents on decomposed Latin, etc.).
  if (code >= 0x0300 && code <= 0x036F) return true;
  // Indic scripts (Devanagari .. Sinhala). Each block lays out its marks in the
  // same slots: the matra/vowel-sign runs and the virama at 0x?4D.
  if (code >= 0x0900 && code <= 0x0DFF) {
    final low = code & 0x7F;
    // 0x3E..0x4D covers the right/left/two-part vowel signs and the virama;
    // 0x00..0x03 covers the anusvara/visarga signs; 0x55..0x57 the extra
    // Malayalam/Tamil vowel-sign slots; 0x62..0x63 the vocalic marks.
    if (low >= 0x3E && low <= 0x4D) return true;
    if (low <= 0x03) return true;
    if (low >= 0x55 && low <= 0x57) return true;
    if (low >= 0x62 && low <= 0x63) return true;
  }
  // Variation selectors.
  if (code >= 0xFE00 && code <= 0xFE0F) return true;
  return false;
}

/// The single letter to show for [name] — as an avatar initial or a list
/// section header. Takes the first **grapheme cluster** (so a Malayalam letter
/// is whole, not a half glyph from indexing a UTF-16 code unit), then strips
/// the combining marks off it so only the base letter is left, uppercased.
///
/// Stripping matters because some Malayalam vowel signs are *split*: `ൊ` draws
/// as `െ` on the left and `ാ` on the right of its consonant, so `കൊ` is about
/// three glyphs wide and overflows a round avatar. `കൊച്ചി` gives `ക`, and
/// `രമേഷ്` gives `ര`. Chillu letters (`ൻ ർ ൽ ൾ ൺ`) are base characters, not
/// marks, so they survive. Latin, digits and emoji pass through unchanged.
///
/// Returns `'?'` for an empty name, and falls back to the whole cluster if
/// stripping would leave nothing.
String initialFor(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  final cluster = trimmed.characters.first;
  final base = String.fromCharCodes(
    cluster.runes.takeWhile((r) => !_isCombiningMark(r)),
  );
  return (base.isEmpty ? cluster : base).toUpperCase();
}

/// The A–Z section bucket for [name], derived from its romanized sort key so
/// English and Malayalam group together. Letters come back upper-case `A`–`Z`;
/// names that start with a digit or symbol (or are empty) bucket under `#`.
String sectionLetterFor(String name) {
  final key = sortRoman(name);
  if (key.isEmpty) return '#';
  final first = key.characters.first.toUpperCase();
  final code = first.codeUnitAt(0);
  final isAtoZ = code >= 0x41 && code <= 0x5A; // 'A'..'Z'
  return isAtoZ ? first : '#';
}
