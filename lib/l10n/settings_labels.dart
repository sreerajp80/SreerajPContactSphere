// lib/l10n/settings_labels.dart
//
// Display text for settings enums. The enums live in lib/state/app_settings.dart
// and are saved by name, so their text belongs here, in the language layer,
// not in the state layer.

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';

/// The name of a dialpad secondary-script choice.
String dialpadScriptLabel(AppLocalizations l10n, DialpadScript script) =>
    switch (script) {
      DialpadScript.auto => l10n.labelScriptAuto,
      DialpadScript.malayalam => l10n.labelScriptMalayalam,
      DialpadScript.devanagari => l10n.labelScriptDevanagari,
      DialpadScript.cyrillic => l10n.labelScriptCyrillic,
      DialpadScript.arabic => l10n.labelScriptArabic,
      DialpadScript.greek => l10n.labelScriptGreek,
      DialpadScript.none => l10n.labelScriptNone,
    };

/// One line explaining a dialpad secondary-script choice.
String dialpadScriptDescription(AppLocalizations l10n, DialpadScript script) =>
    switch (script) {
      DialpadScript.auto => l10n.descScriptAuto,
      DialpadScript.malayalam => l10n.descScriptMalayalam,
      DialpadScript.devanagari => l10n.descScriptDevanagari,
      DialpadScript.cyrillic => l10n.descScriptCyrillic,
      DialpadScript.arabic => l10n.descScriptArabic,
      DialpadScript.greek => l10n.descScriptGreek,
      DialpadScript.none => l10n.descScriptNone,
    };

/// The name of a dialer top-contacts choice.
String dialerTopSourceLabel(AppLocalizations l10n, DialerTopSource source) =>
    switch (source) {
      DialerTopSource.relations => l10n.labelFamilyFriends,
      DialerTopSource.likelyToAnswer => l10n.labelLikelyToAnswer,
      DialerTopSource.recent => l10n.labelMostRecent,
    };

/// One line explaining a dialer top-contacts choice.
String dialerTopSourceDescription(
  AppLocalizations l10n,
  DialerTopSource source,
) => switch (source) {
  DialerTopSource.relations => l10n.descTopRelations,
  DialerTopSource.likelyToAnswer => l10n.descTopLikely,
  DialerTopSource.recent => l10n.descTopRecent,
};

/// The name of a text-size choice.
String appTextScaleLabel(AppLocalizations l10n, AppTextScale scale) =>
    switch (scale) {
      AppTextScale.small => l10n.labelScaleSmall,
      AppTextScale.normal => l10n.labelScaleDefault,
      AppTextScale.large => l10n.labelScaleLarge,
      AppTextScale.larger => l10n.labelScaleLarger,
    };

/// The name of a font choice. Font names are proper names and stay as they
/// are; only "System default" is translated.
String appFontLabel(AppLocalizations l10n, AppFont font) =>
    font == AppFont.system ? l10n.labelSystemDefault : font.label;
