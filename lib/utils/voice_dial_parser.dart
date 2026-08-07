// lib/utils/voice_dial_parser.dart

/// What a spoken dialer phrase turned out to be: a dialable [number] or a
/// contact-name [name] search query.
class VoiceDialResult {
  final bool isNumber;
  final String value;

  const VoiceDialResult.number(this.value) : isNumber = true;
  const VoiceDialResult.name(this.value) : isNumber = false;

  @override
  bool operator ==(Object other) =>
      other is VoiceDialResult &&
      other.isNumber == isNumber &&
      other.value == value;

  @override
  int get hashCode => Object.hash(isNumber, value);

  @override
  String toString() => isNumber ? 'number($value)' : 'name($value)';
}

/// Classifies what the dialer's voice input heard.
///
/// The recognizer usually returns spoken numbers already as digits
/// ("nine eight" → "98"), but not always — so digit *words* are mapped too.
/// A leading command word ("call amma", "dial 98…") is dropped. If every
/// remaining word reads as digits/dial symbols the phrase is a number to
/// type into the field; anything else is a name to search contacts for.
class VoiceDialParser {
  static const Map<String, String> _digitWords = {
    'zero': '0',
    'oh': '0',
    'one': '1',
    'two': '2',
    'three': '3',
    'four': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'nine': '9',
    'plus': '+',
    'star': '*',
    'hash': '#',
    'pound': '#',
  };

  // Command words that introduce the target, dropped when they lead the phrase.
  // English, plus the Malayalam forms a Malayalam-locale recognizer produces:
  // "കോൾ" is how it renders spoken *English* "call"; വിളി/വിളിക്ക്/… are the
  // native "call/summon" verb; ഡയൽ/ഫോൺ/റിംഗ് are the other loanwords.
  static const Set<String> _leadIns = {
    'call',
    'dial',
    'ring',
    'phone',
    'കോൾ',
    'വിളി',
    'വിളിക്ക്',
    'വിളിക്കൂ',
    'വിളിക്കണം',
    'ഡയൽ',
    'ഫോൺ',
    'റിംഗ്',
  };

  // Malayalam puts the verb last ("സീതയെ വിളിക്കൂ"), so a call-verb trailing a
  // name is dropped too. (English "call/dial" only ever lead, so they are not
  // here — a trailing English word is part of the name, e.g. "John from work".)
  static const Set<String> _trailingVerbs = {
    'വിളി',
    'വിളിക്ക്',
    'വിളിക്കൂ',
    'വിളിക്കണം',
    'ഡയൽ',
  };

  /// Groups the recognizer may glue into one token ("nine-eight", "98 47").
  static final RegExp _dialToken = RegExp(r'^[0-9+*#\-\.\(\)]+$');

  /// Returns null when nothing usable was said.
  static VoiceDialResult? parse(String words) {
    final tokens = words.trim().split(RegExp(r'\s+'))
      ..removeWhere((t) => t.isEmpty);
    if (tokens.isEmpty) return null;

    // "Call amma" → "amma"; a lone "call" stays a name query as-is.
    if (tokens.length > 1 && _leadIns.contains(tokens.first.toLowerCase())) {
      tokens.removeAt(0);
    }
    // "സീതയെ വിളിക്കൂ" → "സീതയെ": drop a trailing Malayalam call-verb, but never
    // the last remaining token (a lone verb stays a name query, as above).
    if (tokens.length > 1 &&
        _trailingVerbs.contains(tokens.last.toLowerCase())) {
      tokens.removeLast();
    }

    final number = StringBuffer();
    var allDialable = true;
    for (final token in tokens) {
      final mapped = _digitWords[token.toLowerCase()] ?? token;
      if (_dialToken.hasMatch(mapped)) {
        // Keep only what the dialpad can type (drop -, ., parens).
        number.write(mapped.replaceAll(RegExp(r'[^0-9+*#]'), ''));
      } else {
        allDialable = false;
        break;
      }
    }
    if (allDialable && number.isNotEmpty) {
      return VoiceDialResult.number(number.toString());
    }
    return VoiceDialResult.name(tokens.join(' '));
  }
}
