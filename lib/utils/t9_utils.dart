// lib/utils/t9_utils.dart
import 'dart:ui' show PlatformDispatcher;

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';

/// Utilities for T9 (Smart Dialing) matching on phone keypads.
///
/// Standard T9 Keypad Layout:
/// - 2: A, B, C
/// - 3: D, E, F
/// - 4: G, H, I
/// - 5: J, K, L
/// - 6: M, N, O
/// - 7: P, Q, R, S
/// - 8: T, U, V
/// - 9: W, X, Y, Z
/// - 0: Space / +
class T9Utils {
  static const Map<String, String> _charToT9Map = {
    'a': '2', 'b': '2', 'c': '2',
    'd': '3', 'e': '3', 'f': '3',
    'g': '4', 'h': '4', 'i': '4',
    'j': '5', 'k': '5', 'l': '5',
    'm': '6', 'n': '6', 'o': '6',
    'p': '7', 'q': '7', 'r': '7', 's': '7',
    't': '8', 'u': '8', 'v': '8',
    'w': '9', 'x': '9', 'y': '9', 'z': '9',
    '0': '0', '1': '1', '2': '2', '3': '3', '4': '4',
    '5': '5', '6': '6', '7': '7', '8': '8', '9': '9',
  };

  /// Malayalam character to T9 digit mapping.
  static const Map<String, String> _malayalamCharToT9Map = {
    // 2: Vowels അ/ആ, Ka-varga (ക, ഖ, ഗ, ഘ, ങ) + matras ാ, ി, ീ
    'അ': '2', 'ആ': '2', 'ാ': '2', 'ി': '2', 'ീ': '2',
    'ക': '2', 'ഖ': '2', 'ഗ': '2', 'ഘ': '2', 'ങ': '2',

    // 3: Vowels ഉ/ഊ/ഋ, Cha-varga (ച, ഛ, ജ, ഝ, ഞ) + matras ു, ൂ, ൃ
    'ഉ': '3', 'ഊ': '3', 'ഋ': '3', 'ു': '3', 'ൂ': '3', 'ൃ': '3',
    'ച': '3', 'ഛ': '3', 'ജ': '3', 'ഝ': '3', 'ഞ': '3',

    // 4: Vowels എ/ഏ/ഐ, Ta-varga (ട, ഠ, ഡ, ഢ, ണ) + matras െ, േ, ൈ
    'എ': '4', 'ഏ': '4', 'ഐ': '4', 'െ': '4', 'േ': '4', 'ൈ': '4',
    'ട': '4', 'ഠ': '4', 'ഡ': '4', 'ഢ': '4', 'ണ': '4',

    // 5: Vowels ഒ/ഓ/ഔ, Tha-varga (ത, ഥ, ദ, ധ, ന) + matras ൊ, ോ, ൌ, ൗ
    'ഒ': '5', 'ഓ': '5', 'ഔ': '5', 'ൊ': '5', 'ോ': '5', 'ൌ': '5', 'ൗ': '5',
    'ത': '5', 'ഥ': '5', 'ദ': '5', 'ധ': '5', 'ന': '5',

    // 6: Pa-varga (പ, ഫ, ബ, ഭ, മ)
    'പ': '6', 'ഫ': '6', 'ബ': '6', 'ഭ': '6', 'മ': '6',

    // 7: Ya, Ra, La, Va (യ, ര, ല, വ)
    'യ': '7', 'ര': '7', 'ല': '7', 'വ': '7',

    // 8: Sha, Sha, Sa, Ha (ശ, ഷ, സ, ഹ)
    'ശ': '8', 'ഷ': '8', 'സ': '8', 'ഹ': '8',

    // 9: La, Zha, Ra (ള, ഴ, റ), Chillus (ൺ, ൻ, ർ, ൽ, ൾ, ൿ), Anusvara/Visarga (ം, ഃ)
    'ള': '9', 'ഴ': '9', 'റ': '9',
    'ൺ': '9', 'ൻ': '9', 'ർ': '9', 'ൽ': '9', 'ൾ': '9', 'ൿ': '9',
    'ം': '9', 'ഃ': '9',
  };

  /// Devanagari character to T9 digit mapping (Sanskrit / Hindi / Marathi).
  static const Map<String, String> _devanagariCharToT9Map = {
    'अ': '2', 'आ': '2', 'ा': '2', 'ि': '2', 'ी': '2',
    'क': '2', 'ख': '2', 'ग': '2', 'घ': '2', 'ङ': '2',

    'इ': '3', 'ई': '3', 'ु': '3', 'ू': '3', 'ृ': '3',
    'च': '3', 'छ': '3', 'ज': '3', 'झ': '3', 'ञ': '3',

    'उ': '4', 'ऊ': '4', 'ऋ': '4', 'े': '4', 'ै': '4',
    'ट': '4', 'ठ': '4', 'ड': '4', 'ढ': '4', 'ण': '4',

    'ए': '5', 'ऐ': '5', 'ओ': '5', 'औ': '5', 'ो': '5', 'ौ': '5',
    'त': '5', 'थ': '5', 'द': '5', 'ध': '5', 'न': '5',

    'प': '6', 'फ': '6', 'ब': '6', 'भ': '6', 'म': '6',

    'य': '7', 'र': '7', 'ल': '7', 'व': '7',

    'श': '8', 'ष': '8', 'स': '8', 'ह': '8',

    'ळ': '9', 'ऴ': '9', 'क्ष': '9', 'ज्ञ': '9',
    'ः': '9', 'ं': '9', 'ँ': '9',
  };

  /// Cyrillic character to T9 digit mapping (Russian / Ukrainian / Bulgarian).
  static const Map<String, String> _cyrillicCharToT9Map = {
    'а': '2', 'б': '2', 'в': '2', 'г': '2', 'ґ': '2',
    'д': '3', 'е': '3', 'ё': '3', 'ж': '3', 'з': '3',
    'и': '4', 'й': '4', 'к': '4', 'л': '4', 'і': '4', 'ї': '4',
    'м': '5', 'н': '5', 'о': '5', 'п': '5', 'р': '5',
    'с': '6', 'т': '6', 'у': '6', 'ф': '6',
    'х': '7', 'ц': '7', 'ч': '7', 'ш': '7',
    'щ': '8', 'ъ': '8', 'ы': '8', 'ь': '8', 'э': '8',
    'ю': '9', 'я': '9',
  };

  /// Arabic character to T9 digit mapping (Arabic / Persian / Urdu).
  static const Map<String, String> _arabicCharToT9Map = {
    'ا': '2', 'أ': '2', 'إ': '2', 'آ': '2', 'ب': '2', 'ت': '2', 'ث': '2',
    'ج': '3', 'ح': '3', 'خ': '3',
    'د': '4', 'ذ': '4', 'ر': '4', 'ز': '4', 'ژ': '4',
    'س': '5', 'ش': '5', 'ص': '5', 'ض': '5',
    'ط': '6', 'ظ': '6', 'ع': '6', 'غ': '6',
    'ف': '7', 'ق': '7', 'ك': '7', 'گ': '7', 'ل': '7',
    'م': '8', 'ن': '8', 'ه': '8', 'ة': '8',
    'و': '9', 'ي': '9', 'ى': '9', 'ء': '9', 'ؤ': '9', 'ئ': '9',
  };

  /// Greek character to T9 digit mapping.
  static const Map<String, String> _greekCharToT9Map = {
    'α': '2', 'β': '2', 'γ': '2', 'ά': '2',
    'δ': '3', 'ε': '3', 'ζ': '3', 'έ': '3',
    'η': '4', 'θ': '4', 'ι': '4', 'ή': '4', 'ί': '4', 'ϊ': '4', 'ΐ': '4',
    'κ': '5', 'λ': '5', 'μ': '5',
    'ν': '6', 'ξ': '6', 'ο': '6', 'ό': '6',
    'π': '7', 'ρ': '7', 'σ': '7', 'ς': '7',
    'τ': '8', 'υ': '8', 'φ': '8', 'ύ': '8', 'ϋ': '8', 'ΰ': '8',
    'χ': '9', 'ψ': '9', 'ω': '9', 'ώ': '9',
  };

  /// Latin diacritics mapping.
  static const Map<String, String> _diacriticsToT9Map = {
    'à': '2', 'á': '2', 'â': '2', 'ã': '2', 'ä': '2', 'å': '2', 'æ': '2', 'ç': '2',
    'è': '3', 'é': '3', 'ê': '3', 'ë': '3',
    'ì': '4', 'í': '4', 'î': '4', 'ï': '4',
    'ñ': '6', 'ò': '6', 'ó': '6', 'ô': '6', 'õ': '6', 'ö': '6', 'ø': '6',
    'ù': '8', 'ú': '8', 'û': '8', 'ü': '8',
    'ý': '9', 'ÿ': '9',
  };

  /// Resolves secondary script key legends for digits 0–9 based on [script].
  static Map<String, String> getScriptKeyLegends(DialpadScript script) {
    DialpadScript effectiveScript = script;
    if (script == DialpadScript.auto) {
      final lang = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      if (lang == 'ml') {
        effectiveScript = DialpadScript.malayalam;
      } else if (['hi', 'sa', 'mr', 'ne'].contains(lang)) {
        effectiveScript = DialpadScript.devanagari;
      } else if (['ru', 'uk', 'be', 'bg', 'sr', 'mk'].contains(lang)) {
        effectiveScript = DialpadScript.cyrillic;
      } else if (['ar', 'fa', 'ur'].contains(lang)) {
        effectiveScript = DialpadScript.arabic;
      } else if (lang == 'el') {
        effectiveScript = DialpadScript.greek;
      } else {
        // Fallback for Indian region or default: Malayalam
        effectiveScript = DialpadScript.malayalam;
      }
    }

    switch (effectiveScript) {
      case DialpadScript.malayalam:
        return const {
          '2': 'ക-ങ', '3': 'ച-ഞ', '4': 'ട-ണ', '5': 'ത-ന',
          '6': 'പ-മ', '7': 'യ-വ', '8': 'ശ-ഹ', '9': 'ള-റ',
        };
      case DialpadScript.devanagari:
        return const {
          '2': 'क-ङ', '3': 'च-ञ', '4': 'ट-ण', '5': 'त-न',
          '6': 'प-म', '7': 'य-व', '8': 'श-ह', '9': 'ळ-क्ष',
        };
      case DialpadScript.cyrillic:
        return const {
          '2': 'АБВГ', '3': 'ДЕЖЗ', '4': 'ИЙКЛ', '5': 'МНОПР',
          '6': 'СТУФ', '7': 'ХЦЧШ', '8': 'ЩЪЫЬ', '9': 'ЭЮЯ',
        };
      case DialpadScript.arabic:
        return const {
          '2': 'ا ب ت ث', '3': 'ج ح خ', '4': 'د ذ ر ز', '5': 'س ش ص ض',
          '6': 'ط ظ ع غ', '7': 'ف ق ك ل', '8': 'م ن هـ', '9': 'و ي',
        };
      case DialpadScript.greek:
        return const {
          '2': 'ΑΒΓ', '3': 'ΔΕΖ', '4': 'ΗΘΙ', '5': 'ΚΛΜ',
          '6': 'ΝΞΟ', '7': 'ΠΡΣ', '8': 'ΤΥΦ', '9': 'ΧΨΩ',
        };
      case DialpadScript.none:
      case DialpadScript.auto:
        return const {};
    }
  }

  /// Converts a single character into its T9 digit string ('2'-'9'), or null if unmapped.
  static String? charToT9Digit(String char) {
    if (char.isEmpty) return null;
    final lower = char.toLowerCase();
    return _charToT9Map[lower] ??
        _malayalamCharToT9Map[char] ??
        _devanagariCharToT9Map[char] ??
        _cyrillicCharToT9Map[lower] ??
        _arabicCharToT9Map[char] ??
        _greekCharToT9Map[lower] ??
        _diacriticsToT9Map[lower];
  }

  /// Converts a string of text (e.g. "John Doe") into T9 digit representation ("5646 363").
  /// Characters outside A-Z/0-9/Malayalam are kept or mapped to space.
  static String textToT9(String text) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      final digit = charToT9Digit(ch);
      if (digit != null) {
        buffer.write(digit);
      } else if (ch.trim().isEmpty) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  /// Converts Malayalam script text into direct Malayalam T9 digits.
  /// When [consonantsOnly] is true, dependent vowel signs (matras) and virama
  /// are omitted so users typing consonant keys on dialpad match the name.
  static String textToMalayalamT9(String text, {bool consonantsOnly = false}) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      if (consonantsOnly) {
        // Skip combining matras / virama in consonant-only sequence
        final code = ch.codeUnitAt(0);
        if (code >= 0x0D3E && code <= 0x0D4D) continue;
      }
      final digit = _malayalamCharToT9Map[ch] ?? _charToT9Map[ch.toLowerCase()];
      if (digit != null) {
        buffer.write(digit);
      } else if (ch.trim().isEmpty) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  /// Returns all variant T9 string representations for [name], covering both
  /// English transliteration variants and direct Malayalam script T9 variants.
  static List<String> getNameT9Variants(String name) {
    final variants = <String>[];
    final latinName = transliterateMalayalam(name);
    final keyName = searchKey(name);

    variants.add(latinName);
    if (keyName != latinName) {
      variants.add(keyName);
    }

    // Direct Malayalam script T9
    final mlFullT9 = textToMalayalamT9(name);

    if (mlFullT9.trim().isNotEmpty) {
      variants.add(name);
    }

    return variants;
  }

  /// Returns whether [typedDigits] matches [name] using T9 Smart Dialing rules.
  ///
  /// Matches if [typedDigits] is a T9 prefix of any word in [name], or a prefix
  /// of the full transliterated or direct Malayalam name.
  static bool isT9Match(String name, String typedDigits) {
    final cleanDigits = typedDigits.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.isEmpty || name.trim().isEmpty) return false;

    // 1. Check English T9 transliterated variants
    final latinName = transliterateMalayalam(name);
    final keyName = searchKey(name);

    for (final variant in [latinName, keyName]) {
      final words = variant.toLowerCase().split(RegExp(r'\s+'));

      for (final word in words) {
        if (word.isEmpty) continue;
        final wordT9 = textToT9(word);
        if (wordT9.startsWith(cleanDigits)) {
          return true;
        }
      }

      final fullT9 = textToT9(variant).replaceAll(' ', '');
      if (fullT9.contains(cleanDigits)) {
        return true;
      }
    }

    // 2. Check Direct Malayalam T9 (full and consonant-only)
    for (final consonantsOnly in [false, true]) {
      final mlT9Text = textToMalayalamT9(name, consonantsOnly: consonantsOnly);
      if (mlT9Text.trim().isEmpty) continue;

      final words = mlT9Text.split(RegExp(r'\s+'));
      for (final word in words) {
        if (word.isEmpty) continue;
        if (word.startsWith(cleanDigits)) {
          return true;
        }
      }

      final fullT9 = mlT9Text.replaceAll(' ', '');
      if (fullT9.contains(cleanDigits)) {
        return true;
      }
    }

    return false;
  }

  /// Scores a contact match for ranking dialer search results.
  ///
  /// Returns a numeric score (higher = better match, 0 = no match):
  /// - 100+: Name word prefix T9 match
  /// - 80+:  Phone number prefix match
  /// - 60+:  Name substring T9 match
  /// - 40+:  Phone number mid-string match
  static int scoreMatch(String name, String rawNumber, String typedDigits) {
    final cleanDigits = typedDigits.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.isEmpty) return 0;

    int maxScore = 0;

    // 1. Phone number match scoring
    final cleanPhone = rawNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.isNotEmpty) {
      if (cleanPhone.startsWith(cleanDigits)) {
        maxScore = 85; // Strong phone prefix match
      } else if (cleanPhone.contains(cleanDigits)) {
        maxScore = 45; // Phone substring match
      }
    }

    // 2. Name T9 match scoring (English transliteration)
    if (name.trim().isNotEmpty) {
      final variants = [transliterateMalayalam(name), searchKey(name)];
      for (final variant in variants) {
        final words = variant.toLowerCase().split(RegExp(r'\s+'));

        bool wordPrefixMatched = false;
        for (int i = 0; i < words.length; i++) {
          final word = words[i];
          if (word.isEmpty) continue;
          final wordT9 = textToT9(word);
          if (wordT9.startsWith(cleanDigits)) {
            wordPrefixMatched = true;
            final score = (i == 0) ? 100 : 95;
            if (score > maxScore) maxScore = score;
          }
        }

        if (!wordPrefixMatched) {
          final fullT9 = textToT9(variant).replaceAll(' ', '');
          if (fullT9.contains(cleanDigits)) {
            const score = 65;
            if (score > maxScore) maxScore = score;
          }
        }
      }

      // 3. Direct Malayalam script T9 scoring (full & consonant-only)
      for (final consonantsOnly in [false, true]) {
        final mlT9Text = textToMalayalamT9(name, consonantsOnly: consonantsOnly);
        if (mlT9Text.trim().isEmpty) continue;

        final words = mlT9Text.split(RegExp(r'\s+'));
        bool wordPrefixMatched = false;
        for (int i = 0; i < words.length; i++) {
          final word = words[i];
          if (word.isEmpty) continue;
          if (word.startsWith(cleanDigits)) {
            wordPrefixMatched = true;
            final score = (i == 0) ? 100 : 95;
            if (score > maxScore) maxScore = score;
          }
        }

        if (!wordPrefixMatched) {
          final fullT9 = mlT9Text.replaceAll(' ', '');
          if (fullT9.contains(cleanDigits)) {
            const score = 65;
            if (score > maxScore) maxScore = score;
          }
        }
      }
    }

    return maxScore;
  }
}
