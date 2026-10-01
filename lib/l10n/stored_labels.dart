// lib/l10n/stored_labels.dart
//
// Some contact fields save a preset's English word ("Mobile", "Work", "Male")
// or a code ("personal", "official") rather than translated text. Those saved
// values must never change with the UI language, or rows saved in one language
// would stop matching presets in another. So the value is saved as-is and only
// translated when it is shown, here.

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';

/// The label to show for a saved phone, email or social-link label, gender, or
/// address type. Known presets are translated; anything else (a custom label the
/// user typed, a brand name such as "LinkedIn") is returned unchanged.
String storedLabelText(AppLocalizations l10n, String stored) =>
    switch (stored) {
      'Mobile' => l10n.labelTypeMobile,
      'Home' => l10n.labelTypeHome,
      'Work' => l10n.labelTypeWork,
      'Main' => l10n.labelTypeMain,
      'Fax' => l10n.labelTypeFax,
      'Other' => l10n.labelTypeOther,
      'Personal' => l10n.labelTypePersonal,
      'School' => l10n.labelTypeSchool,
      'Website' => l10n.labelTypeWebsite,
      'Male' => l10n.labelGenderMale,
      'Female' => l10n.labelGenderFemale,
      'Non-binary' => l10n.labelGenderNonBinary,
      'Prefer not to say' => l10n.labelGenderPreferNotToSay,
      'personal' => l10n.labelAddressPersonal,
      'official' => l10n.labelAddressOfficial,
      _ => stored,
    };
