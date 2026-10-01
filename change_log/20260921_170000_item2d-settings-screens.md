# Item 2, phase 2d — Settings screens moved to ARB

**Plan:** `plans/20260921_064200_item2-arb-string-externalization.md` (phase 2d of 2a–2g)
**Status:** done. Phases 2e–2g are not started and need approval before any work begins.

---

## What this phase did

Moved every user-visible string in the Settings screens into the three ARB files, with Malayalam
and Sanskrit translations that use the approved glossary words.

Scope, as the plan defines it: `settings_screen.dart`, every `*_settings_screen.dart`, and
`lib/screens/settings/`.

| Screen | File |
|---|---|
| Settings (home) | `lib/screens/settings_screen.dart` |
| Contacts settings | `lib/screens/contacts_settings_screen.dart` |
| Sync (device contacts and call log) | `lib/screens/contact_sync_settings_screen.dart` |
| Display & formatting | `lib/screens/contact_display_settings_screen.dart` |
| SIM & calling | `lib/screens/sim_settings_screen.dart` |
| Identification | `lib/screens/identification_settings_screen.dart` |
| Smart Redial & "Reach Me" | `lib/screens/smart_redial_settings_screen.dart` |
| Ringtone | `lib/screens/ringtone_settings_screen.dart` |
| Theme mode | `lib/screens/theme_mode_settings_screen.dart` |
| Accent color | `lib/screens/accent_color_settings_screen.dart` |
| Typography & text size | `lib/screens/typography_settings_screen.dart` |
| Screenshot guard | `lib/screens/screenshot_guard_settings_screen.dart` |
| Online provider sync | `lib/screens/settings/online_sync_settings_screen.dart` |
| Encrypted cloud backup | `lib/screens/settings/cloud_backup_settings_screen.dart` |

`lib/screens/language_settings_screen.dart` was already converted by item 4.

- **203 new keys**, so each ARB file now holds **716 keys**. The three files have the same key set.
- A search of these screens finds no English UI text left, apart from the items under "Left in
  English on purpose".

### Screens reached from Settings that are not in this phase

These screens open from Settings but are not named `*_settings_screen.dart`, so the plan does not
put them in 2d: Security, Appearance, Speed Dial, Default country, Permissions, Features, Help,
About, Emergency info, Backup & Restore, Sync to another device, SIM preferences, per-SIM
ringtones, ringtone volume and vibration, relationship quiet hours, quick replies, relationship
names, contact counts, secret contacts export and post-call options. Until their phases run
(2e–2g), a user who opens one of them from a translated Settings page will see English.

---

## Files changed

| File | Change |
|---|---|
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | +203 keys each. |
| `lib/l10n/app_localizations*.dart` | Regenerated with `flutter gen-l10n`. |
| `lib/l10n/settings_labels.dart` | **New.** Display text for the settings choices stored in `AppSettings`, explained below. |
| The 14 screens above | All user-visible strings now come from `AppLocalizations`. |
| `test/l10n/settings_screens_l10n_test.dart` | **New.** Tests described under Verification. |
| `test/l10n/label_length_test.dart` | 33 English keys added to `_englishOverBudget` in a phase 2d block; the header comment no longer claims the list is empty. |
| `plans/20260921_064200_item2-arb-string-externalization.md` | Status line updated. |

Each converted screen was run through `dart format`, so some also carry small formatting changes
on lines this phase did not otherwise touch. In `online_sync_settings_screen.dart` the formatter
split a one-line `if` onto two lines, so it now has braces (the lint rules ask for that).

---

## Decisions made along the way

### Settings choices get their text from the language layer

`lib/state/app_settings.dart` has English `label` getters on its enums (dialpad script, text
size, font). The state layer should not hold UI text, and those getters cannot see the app's
language. The new `lib/l10n/settings_labels.dart` gives each choice its translated name:
`dialpadScriptLabel`, `dialpadScriptDescription`, `dialerTopSourceLabel`,
`dialerTopSourceDescription`, `appTextScaleLabel` and `appFontLabel`. The enums and their saved
values are unchanged. Font names ("Manjari", "Anek Malayalam") are proper names and stay as they
are; only "System default" is translated.

### Messages built from parts are now whole messages

The sync screen built results such as "Saved to Device — 12 added or updated (1 failed)" and
"Call log imported — 3 added, 2 updated" by gluing English fragments together. Each result is now
one complete key, or a small set of keys with typed counts, so no language has to join fragments
that only work in English.

### No context lookups after `await`

The sync screen's result messages are produced inside `async` closures. Each card now takes its
translations once, while it builds, and the closure uses that. Nothing looks up `context` after an
`await`.

### The default online-account name is saved in the user's language

When the user leaves the account name blank, the app saves "Account" as the name. That name is
now the translated word, saved as shown, in the same way as suggested tags (phase 2c).

---

## Left in English on purpose

| What | Why |
|---|---|
| "Google Contacts", "Microsoft Outlook", "CardDAV Server (Nextcloud/Fastmail)" | Product names in the provider picker. |
| The English sample "The quick brown fox • 0123" on the typography screen | It is the English preview; a Malayalam sample sits beside it. |
| The account list's provider code (GOOGLE, MICROSOFT, CARDDAV) | An internal code shown as-is; a later phase can give it a label. |
| Technical names: SQLCipher, PBKDF2, AES-GCM-256, .csbak, CardDAV, WebDAV, OneDrive, Google Drive, URL, SIM, Wi-Fi | Formats, algorithms and product names. |

---

## Over-budget English

33 existing English labels in these screens are longer than the §8.6 limit of 20 characters. They
are listed in `test/l10n/label_length_test.dart` in a separate phase 2d block. Every Malayalam and
Sanskrit label fits the 22-character limit.

The longest ones:

| Key | English | Length |
|---|---|---|
| `actionMirrorDeviceToApp` | Add device contacts to app (destructive) | 40 |
| `actionMirrorAppToDevice` | Add app contacts to device (destructive) | 40 |
| `actionReplaceCallLog` | Add device call log to app (destructive) | 40 |
| `labelHideNoPhone` | Hide contacts without phone numbers | 35 |
| `labelScriptCyrillic` | Cyrillic (Russian / Ukrainian) | 30 |
| `labelScriptDevanagari` | Devanagari (Sanskrit / Hindi) | 29 |
| `labelContactCountsIndex` | Contact counts & search index | 29 |
| `labelTierQuietHours` | Relationship-tier quiet hours | 29 |
| `actionAddAccountInProviderSync` | Add Account in Provider Sync | 28 |
| `actionUploadBackupNow` | Upload Encrypted Backup Now | 27 |

The other 23 are 21 to 26 characters. Whether to shorten them is a copy decision for the owner.
In Malayalam and Sanskrit, the three "(destructive)" titles are written as arrows
("ഫോൺ → ആപ്പ് (മായ്ക്കലോടെ)", "दूरभाषः → अनुप्रयोगः (लोपसहितम्)"), which fit the budget.

---

## Sanskrit gate

The §8.5.1 gate flagged one Sanskrit string. It was the same kind of false positive as in phases
2b and 2c: `मेघसङ्ग्रहे` ("in cloud storage", in `descCloudBackupIntro`) contains the letters रहे.
It now reads `मेघकोशे` ("in the cloud store"). The gate passes.

A script check over every Malayalam and Sanskrit value finds no mixing. The only exceptions are
the language names and the dialpad-script samples, which show the other script on purpose.

---

## Translations — needs native-reader review

Terms not in the §8.5.4 glossary that this phase introduced or leaned on:

| English | Malayalam | Sanskrit |
|---|---|---|
| Sync | സമന്വയം | समन्वयः |
| Mirror (make one side match the other) | പകർത്തുക | प्रतिबिम्ब्यताम् |
| Call log | വിളി രേഖ | आह्वानलेखः |
| Passphrase | രഹസ്യവാക്യം | गुप्तवाक्यम् |
| Encrypted | ഗൂഢീകരിച്ച | गुप्त- |
| Cloud | ക്ലൗഡ് | मेघः |
| Upload | അപ്‌ലോഡ് ചെയ്യുക | आरोप्यताम् (glossary) |
| Screen lock | സ്ക്രീൻ ലോക്ക് | पटलतालकम् |
| Screenshot | സ്ക്രീൻഷോട്ട് | पटलचित्रम् |
| Provider (service) | സേവനദാതാവ് | सेवाप्रदाता |
| Speed Dial | വേഗ വിളി | शीघ्राह्वानम् |
| Quiet hours | നിശ്ശബ്ദ സമയം | शान्तिकालः |
| Greek script | ഗ്രീക്ക് | यवनलिपिः |
| Byte | ബൈറ്റ് | बाइट् (a loanword; a reviewer may prefer another) |

One Malayalam pattern to confirm: compounds use the short `വിളി` ("call") — `വിളി രേഖ`, `വിളി
കാർഡ്` — while a standalone call is the glossary's `ഫോൺ വിളി`.

---

## Verification

| Check | Result |
|---|---|
| `flutter analyze` | No issues found. |
| `flutter test` (whole suite) | 635 passed, 2 skipped, 0 failed. The two skips existed before. |
| `test/l10n/settings_screens_l10n_test.dart` | 27 passed (9 screens × 3 languages). |
| ARB key parity | 716 keys in each file; no untranslated copies. |
| §8.6 label budget | All Malayalam and Sanskrit short keys within 22 characters; English within 20 apart from the listed exceptions. |
| §8.5.1 Sanskrit gate | No markers in `app_sa.arb` or `app_config.json`. |
| `dart format` on every file this phase touched | Clean. |

The new test pumps Settings, Contacts settings, SIM & calling, Ringtone, Theme mode, Screenshot
guard, Identification, Display & formatting and Sync on a 360×740 phone at 1.3× text, in each of
`en`, `ml` and `sa`. For each it checks the translated title and a row, that none of the listed
English strings appears under `ml` or `sa`, and that nothing overflows.

While writing it, one mistake in the test itself made the first run hang: it replaced Flutter's
error handler and a failing check ran before the handler was put back, which stops the test
binding instead of reporting. The handler is now restored before any check runs. The failing
check was a test-setup issue, not a translation one: the "Quick replies" row sits below the fold
of a small screen, so the list had not built it; the test now checks a row near the top.

---

## What happens next

Phase 2e (features, sync, backup, groups, tags, emergency info, duplicates, audit; roughly 180
keys) is next and **needs approval before it starts**. It would be a natural place to also pick up
the Settings sub-screens listed above that fall outside 2d's file-name scope.
