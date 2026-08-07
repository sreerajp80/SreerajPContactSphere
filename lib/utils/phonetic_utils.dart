// lib/utils/phonetic_utils.dart
//
// Phonetic matching utilities (Soundex and Double Metaphone algorithms) for
// English, Indic, and Malayalam name transliteration variations (e.g. Sreeraj
// vs Sriraj, Deepak vs Dipak, Menon vs Manon).

import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';

/// Soundex algorithm implementation.
/// Converts a name string (after transliterating Malayalam script to Latin)
/// into a standard 4-character Soundex code (e.g. "Sreeraj" -> "S620").
class Soundex {
  const Soundex._();

  /// Returns the 4-character Soundex code for [input], or an empty string if
  /// input contains no alphabetic characters.
  static String encode(String input) {
    final transliterated = transliterateMalayalam(input).toUpperCase();
    final letters = transliterated.replaceAll(RegExp(r'[^A-Z]'), '');
    if (letters.isEmpty) return '';

    final firstLetter = letters[0];
    final buf = StringBuffer(firstLetter);

    String? lastCode = _soundexCode(firstLetter);

    for (int i = 1; i < letters.length; i++) {
      final code = _soundexCode(letters[i]);
      if (code != null && code != lastCode) {
        buf.write(code);
        lastCode = code;
        if (buf.length == 4) break;
      } else if (code == null) {
        if (letters[i] != 'H' && letters[i] != 'W') {
          lastCode = null;
        }
      }
    }

    final res = buf.toString();
    return res.padRight(4, '0').substring(0, 4);
  }

  static String? _soundexCode(String char) {
    switch (char) {
      case 'B':
      case 'F':
      case 'P':
      case 'V':
        return '1';
      case 'C':
      case 'G':
      case 'J':
      case 'K':
      case 'Q':
      case 'S':
      case 'X':
      case 'Z':
        return '2';
      case 'D':
      case 'T':
        return '3';
      case 'L':
        return '4';
      case 'M':
      case 'N':
        return '5';
      case 'R':
        return '6';
      default:
        return null;
    }
  }
}

/// Double Metaphone algorithm implementation (Lawrence Philips).
/// Computes Primary and Secondary phonetic keys (up to [length] characters) for
/// a given name, accounting for spelling variations in English and transliterated
/// Indian/Malayalam names.
class DoubleMetaphone {
  const DoubleMetaphone._();

  /// Encodes [input] into primary and secondary Metaphone keys.
  static ({String primary, String secondary}) encode(
    String input, {
    int length = 4,
  }) {
    final original = transliterateMalayalam(input).toUpperCase().trim();
    if (original.isEmpty) return (primary: '', secondary: '');

    // Pad original to prevent out-of-bounds index errors
    final val = '$original    ';
    final primary = StringBuffer();
    final secondary = StringBuffer();
    var current = 0;
    final last = original.length - 1;

    // Skip initial silent letter pairs
    if (_stringAt(val, 0, 2, ['GN', 'KN', 'PN', 'WR', 'PS'])) {
      current += 1;
    }

    // Initial 'X' sounds like 'S'
    if (val[0] == 'X') {
      primary.write('S');
      secondary.write('S');
      current += 1;
    }

    while (primary.length < length || secondary.length < length) {
      if (current >= original.length) break;

      switch (val[current]) {
        case 'A':
        case 'E':
        case 'I':
        case 'O':
        case 'U':
        case 'Y':
          if (current == 0) {
            primary.write('A');
            secondary.write('A');
          }
          current += 1;
          break;

        case 'B':
          primary.write('P');
          secondary.write('P');
          current += (val[current + 1] == 'B') ? 2 : 1;
          break;

        case 'C':
          if (current > 1 &&
              !_isVowel(val[current - 2]) &&
              _stringAt(val, current - 1, 3, ['ACH']) &&
              val[current + 2] != 'I' &&
              (val[current + 2] != 'E' ||
                  _stringAt(val, current - 2, 6, ['BACHER', 'MACHER']))) {
            primary.write('K');
            secondary.write('K');
            current += 2;
            break;
          }

          if (current == 0 && _stringAt(val, current, 6, ['CAESAR'])) {
            primary.write('S');
            secondary.write('S');
            current += 2;
            break;
          }

          if (_stringAt(val, current, 2, ['CH'])) {
            if (current > 0 && _stringAt(val, current, 4, ['CHAE'])) {
              primary.write('K');
              secondary.write('X');
              current += 2;
              break;
            }

            if (current == 0 &&
                (_stringAt(val, current + 1, 5, [
                      'HARAC',
                      'HARIS',
                      'HORUS',
                      'HYDRA',
                    ]) ||
                    _stringAt(val, current + 1, 3, ['HIA']))) {
              primary.write('K');
              secondary.write('K');
              current += 2;
              break;
            }

            primary.write('X');
            secondary.write('X');
            current += 2;
            break;
          }

          if (_stringAt(val, current, 2, ['CZ'])) {
            primary.write('S');
            secondary.write('X');
            current += 2;
            break;
          }

          if (_stringAt(val, current + 1, 3, ['CIA'])) {
            primary.write('X');
            secondary.write('X');
            current += 3;
            break;
          }

          if (_stringAt(val, current, 2, ['CC']) &&
              !(current == 1 && val[0] == 'M')) {
            if (_stringAt(val, current + 2, 1, ['I', 'E', 'H']) &&
                !_stringAt(val, current + 2, 2, ['HU'])) {
              if ((current == 1 && val[0] == 'A') ||
                  _stringAt(val, current - 1, 5, [
                    'UCCEE',
                    'UCCES',
                  ])) {
                primary.write('KS');
                secondary.write('KS');
              } else {
                primary.write('X');
                secondary.write('X');
              }
              current += 3;
              break;
            } else {
              primary.write('K');
              secondary.write('K');
              current += 2;
              break;
            }
          }

          if (_stringAt(val, current, 2, ['CK', 'CG', 'CQ'])) {
            primary.write('K');
            secondary.write('K');
            current += 2;
            break;
          }

          if (_stringAt(val, current, 2, ['CI', 'CE', 'CY'])) {
            primary.write('S');
            secondary.write('S');
            current += 2;
            break;
          }

          primary.write('K');
          secondary.write('K');

          if (_stringAt(val, current + 1, 2, [' C', ' Q', ' G'])) {
            current += 3;
          } else if (_stringAt(val, current + 1, 1, ['C', 'K', 'Q']) &&
              !_stringAt(val, current + 1, 2, ['CE', 'CI'])) {
            current += 2;
          } else {
            current += 1;
          }
          break;

        case 'D':
          if (_stringAt(val, current, 2, ['DG'])) {
            if (_stringAt(val, current + 2, 1, ['I', 'E', 'Y'])) {
              primary.write('J');
              secondary.write('J');
              current += 3;
              break;
            } else {
              primary.write('TK');
              secondary.write('TK');
              current += 2;
              break;
            }
          }

          if (_stringAt(val, current, 2, ['DT', 'DD'])) {
            primary.write('T');
            secondary.write('T');
            current += 2;
            break;
          }

          primary.write('T');
          secondary.write('T');
          current += 1;
          break;

        case 'F':
          primary.write('F');
          secondary.write('F');
          current += (val[current + 1] == 'F') ? 2 : 1;
          break;

        case 'G':
          if (val[current + 1] == 'H') {
            if (current > 0 && !_isVowel(val[current - 1])) {
              primary.write('K');
              secondary.write('K');
              current += 2;
              break;
            }

            if (current < 3) {
              if (current == 0) {
                if (val[current + 2] == 'I') {
                  primary.write('J');
                  secondary.write('J');
                } else {
                  primary.write('K');
                  secondary.write('K');
                }
                current += 2;
                break;
              }
            }

            if ((current > 1 &&
                    _stringAt(val, current - 2, 1, ['B', 'H', 'D'])) ||
                (current > 2 &&
                    _stringAt(val, current - 3, 1, ['B', 'H', 'D'])) ||
                (current > 3 && _stringAt(val, current - 4, 1, ['B', 'H']))) {
              current += 2;
              break;
            } else {
              if (current > 2 &&
                  val[current - 1] == 'U' &&
                  _stringAt(val, current - 3, 1, [
                    'C',
                    'G',
                    'L',
                    'R',
                    'T',
                  ])) {
                primary.write('F');
                secondary.write('F');
              } else if (current > 0 && val[current - 1] != 'I') {
                primary.write('K');
                secondary.write('K');
              }
              current += 2;
              break;
            }
          }

          if (val[current + 1] == 'N') {
            if (current == 1 && _isVowel(val[0]) && !_isSlavoGermanic(val)) {
              primary.write('KN');
              secondary.write('N');
            } else if (!_stringAt(val, current + 2, 2, ['EY']) &&
                val[current + 1] != 'Y' &&
                !_isSlavoGermanic(val)) {
              primary.write('N');
              secondary.write('KN');
            } else {
              primary.write('KN');
              secondary.write('KN');
            }
            current += 2;
            break;
          }

          if (_stringAt(val, current + 1, 2, ['LI']) && !_isSlavoGermanic(val)) {
            primary.write('KL');
            secondary.write('L');
            current += 2;
            break;
          }

          if (current == 0 &&
              (val[current + 1] == 'Y' ||
                  _stringAt(val, current + 1, 2, [
                    'ES',
                    'EP',
                    'EB',
                    'EL',
                    'EY',
                    'IB',
                    'IL',
                    'IN',
                    'IE',
                    'EI',
                    'ER',
                  ]))) {
            primary.write('K');
            secondary.write('J');
            current += 2;
            break;
          }

          if ((_stringAt(val, current + 1, 2, ['ER']) ||
                  val[current + 1] == 'Y') &&
              !_stringAt(val, 0, 6, [
                'DANGER',
                'RANGER',
                'MANGER',
              ]) &&
              !_stringAt(val, current - 1, 1, ['E', 'I']) &&
              !_stringAt(val, current - 1, 3, ['RGY', 'OGY'])) {
            primary.write('K');
            secondary.write('J');
            current += 2;
            break;
          }

          if (_stringAt(val, current + 1, 1, ['E', 'I', 'Y']) ||
              _stringAt(val, current - 1, 4, ['GGI', 'GGE'])) {
            if (_stringAt(val, 0, 4, ['VAN ', 'VON ']) ||
                _stringAt(val, 0, 3, ['SCH']) ||
                _stringAt(val, current + 1, 2, ['ET'])) {
              primary.write('K');
              secondary.write('K');
            } else {
              primary.write('J');
              secondary.write('J');
            }
            current += 2;
            break;
          }

          primary.write('K');
          secondary.write('K');
          current += (val[current + 1] == 'G') ? 2 : 1;
          break;

        case 'H':
          if ((current == 0 || _isVowel(val[current - 1])) &&
              _isVowel(val[current + 1])) {
            primary.write('H');
            secondary.write('H');
            current += 2;
          } else {
            current += 1;
          }
          break;

        case 'J':
          if (_stringAt(val, current, 4, ['JOSE']) ||
              _stringAt(val, 0, 4, ['SAN '])) {
            if ((current == 0 && val[current + 4] == ' ') ||
                _stringAt(val, 0, 4, ['SAN '])) {
              primary.write('H');
              secondary.write('H');
            } else {
              primary.write('J');
              secondary.write('H');
            }
            current += 1;
            break;
          }

          if (current == 0 && !_stringAt(val, current, 4, ['JOSE'])) {
            primary.write('J');
            secondary.write('A');
          } else if (_isVowel(val[current - 1]) &&
              !_isSlavoGermanic(val) &&
              (val[current + 1] == 'A' || val[current + 1] == 'O')) {
            primary.write('J');
            secondary.write('H');
          } else if (current == last) {
            primary.write('J');
            secondary.write('');
          } else {
            primary.write('J');
            secondary.write('J');
          }

          current += (val[current + 1] == 'J') ? 2 : 1;
          break;

        case 'K':
          primary.write('K');
          secondary.write('K');
          current += (val[current + 1] == 'K') ? 2 : 1;
          break;

        case 'L':
          if (val[current + 1] == 'L') {
            if ((current == last - 1 &&
                    _stringAt(val, current - 1, 4, ['ILL', 'ALL', 'OLL'])) ||
                (_stringAt(val, last - 1, 2, ['AS', 'IS', 'OS']) &&
                    _stringAt(val, current - 1, 4, ['ALLE']))) {
              primary.write('L');
              secondary.write('');
              current += 2;
              break;
            }
            primary.write('L');
            secondary.write('L');
            current += 2;
            break;
          }
          primary.write('L');
          secondary.write('L');
          current += 1;
          break;

        case 'M':
          primary.write('M');
          secondary.write('M');
          if (_stringAt(val, current - 1, 3, ['UMB']) &&
              (current + 1 == last || current + 2 == last)) {
            current += 2;
          } else {
            current += (val[current + 1] == 'M') ? 2 : 1;
          }
          break;

        case 'N':
          primary.write('N');
          secondary.write('N');
          current += (val[current + 1] == 'N') ? 2 : 1;
          break;

        case 'P':
          if (val[current + 1] == 'H') {
            primary.write('F');
            secondary.write('F');
            current += 2;
            break;
          }
          primary.write('P');
          secondary.write('P');
          current += _stringAt(val, current + 1, 1, ['P', 'B']) ? 2 : 1;
          break;

        case 'Q':
          primary.write('K');
          secondary.write('K');
          current += (val[current + 1] == 'Q') ? 2 : 1;
          break;

        case 'R':
          primary.write('R');
          secondary.write('R');
          current += (val[current + 1] == 'R') ? 2 : 1;
          break;

        case 'S':
          if (_stringAt(val, current - 1, 3, ['ISL', 'YSL'])) {
            current += 1;
            break;
          }

          if (current == 0 && _stringAt(val, current, 5, ['SUGAR'])) {
            primary.write('X');
            secondary.write('S');
            current += 1;
            break;
          }

          if (_stringAt(val, current, 2, ['SH'])) {
            primary.write('X');
            secondary.write('X');
            current += 2;
            break;
          }

          if (_stringAt(val, current, 3, ['SIO', 'SIA'])) {
            primary.write('X');
            secondary.write('S');
            current += 3;
            break;
          }

          if ((current == 0 && _stringAt(val, current + 1, 1, ['M', 'N', 'L', 'W'])) ||
              _stringAt(val, current + 1, 1, ['Z'])) {
            primary.write('S');
            secondary.write('X');
            current += _stringAt(val, current + 1, 1, ['Z']) ? 2 : 1;
            break;
          }

          if (_stringAt(val, current, 2, ['SC'])) {
            if (val[current + 2] == 'H') {
              primary.write('SK');
              secondary.write('SK');
              current += 3;
              break;
            }

            if (_stringAt(val, current + 2, 1, ['I', 'E', 'Y'])) {
              primary.write('S');
              secondary.write('S');
              current += 3;
              break;
            }

            primary.write('SK');
            secondary.write('SK');
            current += 3;
            break;
          }

          primary.write('S');
          secondary.write('S');
          current += _stringAt(val, current + 1, 1, ['S', 'Z']) ? 2 : 1;
          break;

        case 'T':
          if (_stringAt(val, current, 4, ['TION', 'TIA', 'TCH'])) {
            primary.write('X');
            secondary.write('X');
            current += (val[current + 2] == 'H') ? 3 : 4;
            break;
          }

          if (_stringAt(val, current, 2, ['TH']) ||
              _stringAt(val, current, 3, ['TTH'])) {
            primary.write('0');
            secondary.write('T');
            current += 2;
            break;
          }

          primary.write('T');
          secondary.write('T');
          current += _stringAt(val, current + 1, 1, ['T', 'D']) ? 2 : 1;
          break;

        case 'V':
          primary.write('F');
          secondary.write('F');
          current += (val[current + 1] == 'V') ? 2 : 1;
          break;

        case 'W':
          if (_stringAt(val, current, 2, ['WR'])) {
            primary.write('R');
            secondary.write('R');
            current += 2;
            break;
          }

          if (current == 0 &&
              (_isVowel(val[current + 1]) || _stringAt(val, current, 2, ['WH']))) {
            primary.write('A');
            secondary.write('F');
            current += 1;
            break;
          }

          current += 1;
          break;

        case 'X':
          if (!(current == last &&
              (_stringAt(val, current - 3, 3, ['IAU', 'EAU']) ||
                  _stringAt(val, current - 2, 2, ['AU', 'OU'])))) {
            primary.write('KS');
            secondary.write('KS');
          }
          current += _stringAt(val, current + 1, 1, ['C', 'X']) ? 2 : 1;
          break;

        case 'Z':
          if (val[current + 1] == 'H') {
            primary.write('J');
            secondary.write('J');
            current += 2;
            break;
          }

          primary.write('S');
          secondary.write('S');
          current += (val[current + 1] == 'Z') ? 2 : 1;
          break;

        default:
          current += 1;
          break;
      }
    }

    final pStr = primary.toString();
    final sStr = secondary.toString();
    return (
      primary: pStr.length > length ? pStr.substring(0, length) : pStr,
      secondary: sStr.length > length ? sStr.substring(0, length) : sStr,
    );
  }

  static bool _isVowel(String ch) {
    return 'AEIOUY'.contains(ch);
  }

  static bool _stringAt(
    String val,
    int start,
    int length,
    List<String> matches,
  ) {
    if (start < 0 || start + length > val.length) return false;
    final sub = val.substring(start, start + length);
    return matches.contains(sub);
  }

  static bool _isSlavoGermanic(String val) {
    return val.contains('W') ||
        val.contains('K') ||
        val.contains('CZ') ||
        val.contains('WITZ');
  }
}

/// Evaluates whether [name1] and [name2] phonetically match each other using
/// Soundex, Double Metaphone, `searchKey`, and `phoneticCode`.
bool phoneticNameMatches(String name1, String name2) {
  final n1 = name1.trim();
  final n2 = name2.trim();
  if (n1.isEmpty || n2.isEmpty) return false;

  // 1. Manglish searchKey equality (e.g. "Sreeraj" vs "Sriraj" -> "sriraj")
  final key1 = searchKey(n1);
  final key2 = searchKey(n2);
  if (key1.isNotEmpty && key1 == key2) return true;

  // 2. Soundex code equality
  final sx1 = Soundex.encode(n1);
  final sx2 = Soundex.encode(n2);
  if (sx1.isNotEmpty && sx1 == sx2) return true;

  // 3. Double Metaphone primary/secondary key match
  final dm1 = DoubleMetaphone.encode(n1);
  final dm2 = DoubleMetaphone.encode(n2);
  if (dm1.primary.isNotEmpty && dm2.primary.isNotEmpty) {
    if (dm1.primary == dm2.primary ||
        (dm2.secondary.isNotEmpty && dm1.primary == dm2.secondary) ||
        (dm1.secondary.isNotEmpty && dm1.secondary == dm2.primary) ||
        (dm1.secondary.isNotEmpty &&
            dm2.secondary.isNotEmpty &&
            dm1.secondary == dm2.secondary)) {
      return true;
    }
  }

  // 4. Fallback: phoneticCode match from malayalam_transliterator
  final pc1 = phoneticCode(n1);
  final pc2 = phoneticCode(n2);
  if (pc1.isNotEmpty && pc2.isNotEmpty && pc1 == pc2) return true;

  return false;
}
