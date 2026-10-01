// lib/l10n/about_labels.dart
//
// Labels for the About screen's `details` rows (guideline §1.6). The keys in
// `assets/config/app_config.json` are identifiers; the visible label comes
// from the ARB key aboutDetail<Key>. An unknown key is shown as it is, so a
// newly added config row still renders.

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';

/// Maps a config detail key to its translated label, falling back to the raw key.
String aboutDetailLabel(AppLocalizations l10n, String key) => switch (key) {
  'author' => l10n.aboutDetailAuthor,
  'email' => l10n.aboutDetailEmail,
  'license' => l10n.aboutDetailLicense,
  'aiUsed' => l10n.aboutDetailAiUsed,
  'ideUsed' => l10n.aboutDetailIdeUsed,
  _ => key,
};
