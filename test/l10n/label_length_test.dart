// test/l10n/label_length_test.dart
//
// Engineering standard section 8.6 — short UI text budget. Every ARB key whose
// prefix marks it as chrome (action, label, title, tab, nav, tooltip) must fit
// in 20 visible characters in English and 22 in Malayalam and Sanskrit, counted
// as grapheme clusters (`characters.length`), so a vowel sign or virama belongs
// to the letter before it.
//
// Placeholders such as {name} are removed before counting: their length is the
// caller's data, not the translator's. The app name "SreerajP Contacts Sphere"
// is removed too: it stays in Latin letters in every language and is longer
// than the budget on its own, so no translator can shorten it. A plural message is checked branch by
// branch, since only one branch is ever shown.
//
// [_englishOverBudget] records English strings allowed over the budget. An
// entry that fits the budget again fails the last test below, so the list
// cannot hold stale keys.

import 'dart:convert';
import 'dart:io';

import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';

const _shortPrefixes = ['action', 'label', 'title', 'tab', 'nav', 'tooltip'];
const _limits = {'en': 20, 'ml': 22, 'sa': 22};

/// English chrome allowed over the 20-character budget. Add a key here only on
/// purpose, with a reason in the change log.
///
/// The first 14 over-budget labels were shortened
/// (plans/20260921_113000_shorten-over-budget-english-labels.md). The keys below
/// are existing English wording found while moving screens into the ARB
/// (phases 2c, 2d and 2e); whether to shorten them is a copy decision, listed in
/// each phase's change log.
const _englishOverBudget = <String>{
  // Phase 2c (core screens): change_log/20260921_140000_item2c-core-screens.md
  'actionSendAllViaBluetooth',
  'actionShareVcard',
  'actionSmartRedialReachMe',
  'labelCallerIdNotVerified',
  'labelExpiryAfterOneCall',
  'labelMeetiversaryDayYouMet',
  'tooltipBackspace',
  'tooltipRemoveFromFavorites',
  // Phase 2d (Settings screens): change_log/20260921_170000_item2d-settings-screens.md
  'actionAddAccountInProviderSync',
  'actionAddAppToDevice',
  'actionAddDeviceToApp',
  'actionImportCallLog',
  'actionMirrorAppToDevice',
  'actionMirrorDeviceToApp',
  'actionReplaceCallLog',
  'actionResetDarkToDefault',
  'actionResetLightToDefault',
  'actionUploadBackupNow',
  'labelActiveScheduledRedials',
  'labelCallerIdentification',
  'labelContactCountsIndex',
  'labelCustomRelationshipLabels',
  'labelEncryptionPassphrase',
  'labelFilterSuspectedSpam',
  'labelHideNoPhone',
  'labelHowIdentificationWorks',
  'labelMyProfileAddMe',
  'labelPresetReachMe',
  'labelScriptCyrillic',
  'labelScriptDevanagari',
  'labelSecretContactsExport',
  'labelSpokenAnnouncement',
  'labelTierQuietHours',
  'titleDialpadScriptLayout',
  'titleEncryptedCloudBackup',
  'titleMirrorAppToDevice',
  'titleMirrorDeviceToApp',
  'titleReplaceCallHistory',
  'titleSmartRedialReachMe',
  'titleSyncToAnotherDevice',
  'titleTypography',
  // Phase 2e (secondary and Settings sub-screens):
  // change_log/20260922_120000_item2e-secondary-screens.md
  'actionExportSignedAuditLog',
  'actionFullSyncNewPhone',
  'actionOpenNotificationSettings',
  'actionSavedTurnOnLock',
  'actionScanOtherPhoneQr',
  'labelAllowedActiveNumbers',
  'labelAllowedRelationships',
  'labelAllowedRingThrough',
  'labelAskSimEachCall',
  'labelBlockedSpamNumbers',
  'labelDuplicateSetsFound',
  'labelEmergencyContactsIce',
  'labelExportSecretContacts',
  'labelIncludeSecretInExport',
  'labelNameOnCard',
  'labelOtherPhoneAddress',
  'labelOtherPhoneConnected',
  'labelPermCallService',
  'labelSourceP2pSync',
  'labelSourceUndo',
  'labelTestAnnouncement',
  'labelVibrateIncoming',
  'labelWhatStrangerSees',
  'titleChoosePersonToCall',
  'titleLeaveWithoutSaving',
  'titleNotSeeingOnLock',
  'titleReceiveFromDevice',
  'titleResetRelationshipNames',
  'titleSaveRecoveryCode',
  'titleSecretContactsExport',
  'titleSelectAllowedContacts',
  'titleSelectAllowedRelationships',
  'titleSendToDevice',
  'titleSetBackupPassword',
  'titleSpokenAnnouncement',
  'tooltipRemoveTagFromContact',
  'tooltipRenameMergeDeleteTag',
};

void main() {
  for (final locale in _limits.keys) {
    test(
      'short keys in app_$locale.arb fit the ${_limits[locale]}-character budget',
      () {
        final strings = _strings('lib/l10n/app_$locale.arb');
        final problems = <String>[];
        for (final entry in strings.entries) {
          if (!_isShort(entry.key)) continue;
          if (locale == 'en' && _englishOverBudget.contains(entry.key)) {
            continue;
          }
          for (final text in _visibleTexts(entry.value)) {
            final length = text.characters.length;
            if (length > _limits[locale]!) {
              problems.add('${entry.key}: "$text" is $length characters');
            }
          }
        }
        expect(problems, isEmpty, reason: problems.join('\n'));
      },
    );
  }

  test('every English over-budget exception is still over budget', () {
    final en = _strings('lib/l10n/app_en.arb');
    final stale = <String>[
      for (final key in _englishOverBudget)
        if (!en.containsKey(key))
          '$key is no longer in app_en.arb'
        else if (_visibleTexts(
          en[key]!,
        ).every((t) => t.characters.length <= _limits['en']!))
          '$key now fits — remove it from _englishOverBudget',
    ];
    expect(stale, isEmpty, reason: stale.join('\n'));
  });
}

bool _isShort(String key) => _shortPrefixes.any(
  (p) =>
      key.startsWith(p) &&
      key.length > p.length &&
      key[p.length] == key[p.length].toUpperCase(),
);

/// The fixed app name, not counted (see the file header).
const _appName = 'SreerajP Contacts Sphere';

/// The texts a user can actually see for [message]: each branch of a plural or
/// select, or the message itself, with every {placeholder} and the app name
/// removed.
List<String> _visibleTexts(String message) {
  final branches = _branches(message);
  final texts = branches ?? [message];
  return [
    for (final t in texts)
      t
          .replaceAll(RegExp(r'\{[A-Za-z0-9_]+\}'), '')
          .replaceAll(_appName, '')
          .trim(),
  ];
}

/// Splits `{count, plural, =1{…} other{…}}` into its branch bodies. Returns null
/// when [message] is not a whole-message plural or select.
List<String>? _branches(String message) {
  final head = RegExp(
    r'^\{\s*\w+\s*,\s*(plural|select)\s*,',
  ).firstMatch(message);
  if (head == null) return null;
  final out = <String>[];
  var i = head.end;
  while (i < message.length) {
    final open = message.indexOf('{', i);
    if (open < 0) break;
    var depth = 1;
    var j = open + 1;
    while (j < message.length && depth > 0) {
      if (message[j] == '{') depth++;
      if (message[j] == '}') depth--;
      j++;
    }
    out.add(message.substring(open + 1, j - 1));
    i = j;
  }
  return out;
}

Map<String, String> _strings(String path) {
  final map = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return {
    for (final e in map.entries)
      if (!e.key.startsWith('@')) e.key: e.value.toString(),
  };
}
