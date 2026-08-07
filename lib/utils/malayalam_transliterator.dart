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
  'ൃ': 'ru', // ൃ
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

  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    // Joiners only disambiguate rendering (legacy chillu encoding); the
    // preceding virama already handled the sound.
    if (ch == '‌' || ch == '‍') continue;
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
  return storedCode.startsWith(queryCode) ||
      storedCode.contains(' $queryCode');
}

/// The single "does this name match what was typed" test, shared by the
/// in-memory searches so they agree with the SQL-backed ones: plain text substring,
/// word-anchored [searchKey] prefix hit, or word-anchored [phoneticCode] hit.
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
