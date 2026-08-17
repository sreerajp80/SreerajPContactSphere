// lib/utils/business_card_parser.dart
//
// Turns the loose text lines read off a paper business card (by
// BusinessCardScanService) into a draft Contact for the Add/Edit form.
//
// Pure Dart on purpose — no Flutter and no plugin imports — so the whole
// mapping is unit-testable on the host (`flutter test`). Reading a card is
// guesswork, so this file follows one rule: never invent a value. A detection
// rule that does not fire leaves its field empty, and every line the parser
// could not place is handed back in [BusinessCardDraft.unmatchedLines] so the
// review sheet can still show it. The user confirms everything before save.

import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/official_details.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/models/social_link.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';

/// The result of reading one business card: a draft [contact] (nothing saved
/// yet), the lines the parser could not place, and the full recognized text.
class BusinessCardDraft {
  final Contact contact;
  final List<String> unmatchedLines;
  final String rawText;

  const BusinessCardDraft({
    required this.contact,
    required this.unmatchedLines,
    required this.rawText,
  });

  /// True when no field at all could be read — the scan screen shows its
  /// "nothing recognized" state for this.
  bool get isEmpty =>
      contact.firstName.trim().isEmpty &&
      contact.phoneNumbers.isEmpty &&
      contact.emails.isEmpty &&
      contact.addresses.isEmpty &&
      contact.socialLinks.isEmpty &&
      (contact.officialDetails?.isEmpty ?? true);
}

class BusinessCardParser {
  const BusinessCardParser._();

  // ----- detection patterns --------------------------------------------------

  static final RegExp _email = RegExp(
    r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}',
  );

  /// A URL or bare domain. Excludes an address that is part of an email (the
  /// email is stripped from the line before this runs).
  static final RegExp _url = RegExp(
    r'(?:https?://|www\.)[^\s,]+|\b[A-Za-z0-9\-]+\.(?:com|net|org|io|in|co|dev|app|biz|info|ai)\b(?:/[^\s,]*)?',
    caseSensitive: false,
  );

  /// Phone-ish run: digits with the separators cards use, optionally
  /// international. Verified by digit count afterwards.
  static final RegExp _phoneRun = RegExp(
    r'(?:\+\s?\d[\d\s().\-]{5,}|\b\d[\d\s().\-]{5,})',
  );

  /// Labels cards put in front of a number ("Mob:", "T."); dropped so they
  /// don't end up in the name or the street. The label must not run straight
  /// into more letters — otherwise the "t" alternative would eat the T of
  /// "Tower B" — and it is only stripped from a line that did yield a number.
  static final RegExp _phoneLabel = RegExp(
    r'^\s*(?:telephone|tel|phone|ph|mobile|mob|cell|office|direct|fax|whatsapp|[mtpo])(?![A-Za-z])\s*[.:]?\s*',
    caseSensitive: false,
  );

  static const _titleWords = <String>{
    'manager', 'engineer', 'director', 'head', 'officer', 'lead', 'consultant',
    'executive', 'president', 'vice', 'founder', 'cofounder', 'co-founder',
    'analyst', 'architect', 'developer', 'designer', 'specialist', 'partner',
    'associate', 'administrator', 'coordinator', 'supervisor', 'advisor',
    'adviser', 'sales', 'marketing', 'business', 'development', 'technical',
    'senior', 'junior', 'assistant', 'principal', 'chief', 'ceo', 'cto', 'cfo',
    'coo', 'cmo', 'md', 'gm', 'vp', 'avp', 'svp', 'proprietor', 'owner',
    'accountant', 'auditor', 'advocate', 'doctor', 'professor', 'scientist',
    'researcher', 'trainer', 'strategist', 'representative', 'agent',
  };

  static const _companyWords = <String>{
    'pvt', 'pvt.', 'private', 'ltd', 'ltd.', 'limited', 'llp', 'llc', 'inc',
    'inc.', 'corp', 'corp.', 'corporation', 'company', 'co', 'co.',
    'technologies', 'technology', 'tech', 'solutions', 'services', 'systems',
    'labs', 'laboratories', 'group', 'industries', 'enterprises', 'ventures',
    'holdings', 'consulting', 'consultants', 'associates', 'partners', 'gmbh',
    'plc', 'ag', 'sa', 'bv', 'nv', 'oy', 'ab', 'srl', 'spa', 'pte', 'sdn',
    'bhd', 'foundation', 'trust', 'institute', 'bank', 'agencies',
  };

  /// Words that mark an address line even without a company suffix.
  static final RegExp _addressHint = RegExp(
    r'\b(?:floor|flr|tower|block|street|st|road|rd|lane|ln|avenue|ave|nagar|park|plaza|building|bldg|suite|no|door|house|colony|sector|phase|cross|main|opp|near|behind|po|p\.o|district|dist|taluk|village|city|state)\b',
    caseSensitive: false,
  );

  /// 5–6 digit postal code as a standalone token.
  static final RegExp _postalCode = RegExp(r'(?<!\d)(\d{5,6})(?!\d)');

  /// Honorifics that precede a name on a card.
  static final RegExp _salutation = RegExp(
    r'^(mr|mrs|ms|miss|dr|prof|er|adv|shri|smt|sri)\.?$',
    caseSensitive: false,
  );

  // ----- entry point ---------------------------------------------------------

  /// Maps [lines] (in reading order, as recognized) to a draft contact.
  ///
  /// [defaultIso] is the user's Default country (AppSettings.defaultCountryIso)
  /// and is used only to give a bare national number its country code, exactly
  /// as the Add/Edit phone field does.
  static BusinessCardDraft parse(
    List<String> lines, {
    required String defaultIso,
    String rawText = '',
  }) {
    final clean = <String>[
      for (final line in lines)
        if (_squash(line).isNotEmpty) _squash(line),
    ];

    final emails = <Email>[];
    final phones = <PhoneNumber>[];
    final links = <SocialLink>[];

    // Lines still in play after the machine-readable bits are taken out, kept
    // with their original index so "the line after the name" still means that.
    final leftovers = <_Line>[];

    for (var i = 0; i < clean.length; i++) {
      final line = clean[i];
      var residue = line;
      var consumed = false;
      var phoneFound = false;

      for (final match in _email.allMatches(line)) {
        final value = match.group(0)!;
        if (!emails.any((e) => e.email.toLowerCase() == value.toLowerCase())) {
          emails.add(
            Email(
              email: value,
              type: 'official',
              isPrimary: emails.isEmpty,
            ),
          );
        }
        residue = residue.replaceFirst(value, ' ');
        consumed = true;
      }

      for (final match in _url.allMatches(residue)) {
        final value = _trimPunctuation(match.group(0)!);
        if (value.isEmpty) continue;
        if (!links.any((l) => l.value.toLowerCase() == value.toLowerCase())) {
          links.add(
            SocialLink(
              label: 'Website',
              value: value,
              isPrimary: links.isEmpty,
            ),
          );
        }
        residue = residue.replaceFirst(match.group(0)!, ' ');
        consumed = true;
      }

      // A postal code is 5–6 digits and would otherwise look like a phone run,
      // so numbers are only harvested from lines that aren't address lines.
      if (!_looksLikeAddress(residue)) {
        for (final match in _phoneRun.allMatches(residue)) {
          final raw = match.group(0)!;
          final digits = raw.replaceAll(RegExp(r'\D'), '');
          if (digits.length < 7 || digits.length > 15) continue;
          final normalized =
              PhoneNormalizer.toE164(raw.trim(), defaultIso: defaultIso) ??
              raw.trim();
          final duplicate = phones.any(
            (p) => PhoneNormalizer.sameNumber(
              p.number,
              normalized,
              defaultIso: defaultIso,
            ),
          );
          if (!duplicate) {
            phones.add(
              PhoneNumber(
                number: normalized,
                type: 'official',
                isPrimary: phones.isEmpty,
              ),
            );
          }
          residue = residue.replaceFirst(raw, ' ');
          consumed = true;
          phoneFound = true;
        }
      }

      // A one-character remnant of a line we already harvested (a stray bullet
      // or separator) is dropped; anything longer stays a candidate.
      final rest = _squash(
        phoneFound ? residue.replaceAll(_phoneLabel, ' ') : residue,
      );
      if (rest.length > 1 || (rest.isNotEmpty && !consumed)) {
        leftovers.add(_Line(index: i, text: rest));
      }
    }

    // ----- company, designation, name, address ------------------------------

    final companyLine = leftovers.firstWhere(
      (l) => _looksLikeCompany(l.text),
      orElse: () => _Line.none,
    );

    // A full name has two or more words, so those win over a stray single word
    // (a logo word like "software" reads as a one-word name otherwise). Among
    // equals, the earliest line wins — the name is at the top of a card.
    final nameCandidates = leftovers
        .where(
          (l) =>
              l != companyLine &&
              _looksLikeName(l.text) &&
              !_looksLikeTitle(l.text) &&
              !_looksLikeAddress(l.text),
        )
        .toList()
      ..sort((a, b) {
        final aMulti = _wordCount(a.text) > 1 ? 0 : 1;
        final bMulti = _wordCount(b.text) > 1 ? 0 : 1;
        return aMulti != bMulti
            ? aMulti.compareTo(bMulti)
            : a.index.compareTo(b.index);
      });
    final nameLine = nameCandidates.isEmpty ? _Line.none : nameCandidates.first;

    // The designation sits next to the name on virtually every card, so prefer
    // the nearest title-looking line to the name over any later one.
    final titleCandidates = leftovers
        .where(
          (l) =>
              l != companyLine &&
              l != nameLine &&
              _looksLikeTitle(l.text) &&
              !_looksLikeAddress(l.text),
        )
        .toList();
    if (nameLine != _Line.none) {
      titleCandidates.sort(
        (a, b) => (a.index - nameLine.index).abs().compareTo(
          (b.index - nameLine.index).abs(),
        ),
      );
    }
    final titleLine = titleCandidates.isEmpty
        ? _Line.none
        : titleCandidates.first;

    final placed = <_Line>{companyLine, nameLine, titleLine}
      ..removeWhere((l) => l == _Line.none);

    // Everything below the company line that isn't already placed is address
    // material; anything above it stays unmatched rather than being guessed at.
    final addressLines = <_Line>[];
    final unmatched = <String>[];
    for (final line in leftovers) {
      if (placed.contains(line)) continue;
      final isAddressish =
          _looksLikeAddress(line.text) ||
          _postalCode.hasMatch(line.text) ||
          (companyLine != _Line.none && line.index > companyLine.index);
      if (isAddressish) {
        addressLines.add(line);
      } else {
        unmatched.add(line.text);
      }
    }

    final contact = Contact(firstName: '');
    contact.emails = emails;
    contact.phoneNumbers = phones;
    contact.socialLinks = links;

    if (nameLine != _Line.none) {
      _applyName(contact, nameLine.text);
    } else if (emails.isNotEmpty) {
      // Fallback only: no name line was found, so derive one from the email
      // local part ("ajay.shankar" -> Ajay Shankar).
      final local = emails.first.email.split('@').first;
      final guess = local
          .split(RegExp(r'[._\-]+'))
          .where((w) => w.isNotEmpty && !RegExp(r'^\d+$').hasMatch(w))
          .map(_capitalize)
          .join(' ');
      if (guess.isNotEmpty) _applyName(contact, guess);
    }

    if (titleLine != _Line.none) {
      contact.officialDetails = OfficialDetails(designation: titleLine.text);
    }

    final address = _buildAddress(
      companyName: companyLine == _Line.none ? null : companyLine.text,
      lines: addressLines.map((l) => l.text).toList(),
    );
    if (address != null) contact.addresses = [address];

    return BusinessCardDraft(
      contact: contact,
      unmatchedLines: unmatched,
      rawText: rawText.isNotEmpty ? rawText : clean.join('\n'),
    );
  }

  // ----- field builders ------------------------------------------------------

  static void _applyName(Contact contact, String line) {
    final words = line.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return;

    if (_salutation.hasMatch(words.first)) {
      contact.salutation = words.removeAt(0).replaceAll('.', '');
      if (words.isEmpty) return;
    }

    contact.firstName = words.first;
    if (words.length == 2) {
      contact.lastName = words[1];
    } else if (words.length > 2) {
      contact.lastName = words.last;
      contact.middleName = words.sublist(1, words.length - 1).join(' ');
    }
  }

  /// Splits the address block into street / city / state / postal / country.
  /// Returns null when there is nothing to store.
  static Address? _buildAddress({
    required String? companyName,
    required List<String> lines,
  }) {
    if (companyName == null && lines.isEmpty) return null;

    String? postalCode;
    String? country;
    final segments = <String>[];

    for (final line in lines) {
      for (final part in line.split(',')) {
        final piece = _squash(part);
        if (piece.isEmpty) continue;

        final postal = _postalCode.firstMatch(piece);
        if (postal != null) {
          postalCode ??= postal.group(1);
          final without = _squash(piece.replaceFirst(postal.group(0)!, ' '));
          if (without.isNotEmpty) segments.add(without);
          continue;
        }

        if (country == null && _isCountryName(piece)) {
          country = piece;
          continue;
        }

        segments.add(piece);
      }
    }

    String? state;
    String? city;
    if (segments.length >= 2) {
      state = segments.removeLast();
      city = segments.removeLast();
    } else if (segments.length == 1) {
      city = segments.removeLast();
    }

    final street = segments.join(', ');
    final address = Address(
      type: 'official',
      companyName: companyName,
      street: street.isEmpty ? null : street,
      cityTown: city,
      state: state,
      postalCode: postalCode,
      country: country,
    );

    final hasAnything =
        address.companyName != null ||
        address.street != null ||
        address.cityTown != null ||
        address.state != null ||
        address.postalCode != null ||
        address.country != null;
    return hasAnything ? address : null;
  }

  // ----- line classifiers ----------------------------------------------------

  static bool _looksLikeCompany(String line) {
    final words = _words(line);
    return words.any((w) => _companyWords.contains(w));
  }

  static bool _looksLikeTitle(String line) {
    final words = _words(line);
    if (words.isEmpty || words.length > 6) return false;
    if (_looksLikeCompany(line)) return false;
    return words.any((w) => _titleWords.contains(w));
  }

  static bool _looksLikeAddress(String line) {
    if (_looksLikeCompany(line)) return false;
    if (_addressHint.hasMatch(line)) return true;
    // "Bangalore, Karnataka 560103" — a comma list ending in a postal code.
    return line.contains(',') && _postalCode.hasMatch(line);
  }

  static bool _looksLikeName(String line) {
    final words = line.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty || words.length > 5) return false;
    if (RegExp(r'\d').hasMatch(line)) return false;
    // Names are letters, and may carry an initial's dot or a hyphen.
    return words.every((w) => RegExp(r"^[A-Za-z][A-Za-z'\-.]*$").hasMatch(w));
  }

  static bool _isCountryName(String piece) {
    final normalized = piece.trim().toUpperCase();
    for (final option in PhoneNormalizer.allCountries()) {
      if (option.name.toUpperCase() == normalized) return true;
    }
    return false;
  }

  // ----- small helpers -------------------------------------------------------

  static List<String> _words(String line) => line
      .toLowerCase()
      .split(RegExp(r'[\s,]+'))
      .where((w) => w.isNotEmpty)
      .toList();

  static int _wordCount(String line) =>
      line.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  static String _squash(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _trimPunctuation(String s) =>
      s.replaceAll(RegExp(r'^[^A-Za-z0-9]+|[^A-Za-z0-9/]+$'), '');

  static String _capitalize(String w) =>
      w.length < 2 ? w.toUpperCase() : w[0].toUpperCase() + w.substring(1);
}

/// One candidate line plus its position in reading order.
class _Line {
  final int index;
  final String text;

  const _Line({required this.index, required this.text});

  static const _Line none = _Line(index: -1, text: '');
}
