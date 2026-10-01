# Item 2, phase 2f — Help articles moved to ARB

**Plan:** `plans/20260921_064200_item2-arb-string-externalization.md` (phase 2f of 2a–2g)
**Status:** done.

---

## What this phase did

Moved every user-visible string in the Help hub and all 23 help articles into the three ARB files,
with Malayalam and Sanskrit translations that use the approved glossary words.

| Screen | File |
|---|---|
| Help hub (topic list) | `lib/screens/help/help_home_screen.dart` |
| 23 articles | every other `lib/screens/help/*_help_screen.dart` |

- **537 new keys**, so each ARB file now holds **1913 keys**. The three files have the same key
  set.
- 530 keys hold the help text itself. They are named by screen and by the part of the article
  they belong to, for example `helpGroupsTagsIntro`, `helpGroupsTagsTitle2`,
  `helpGroupsTagsBullet5`, `helpGroupsTagsFooter`, and `helpFaqTroubleshootingQ3` /
  `helpFaqTroubleshootingA3` for the FAQ. The `help…` prefix is prose, so the §8.6 short-label
  budget does not apply to it.
- A search of `lib/screens/help/` finds no English UI text left.

---

## Files changed

| File | Change |
|---|---|
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | +537 keys each. |
| `lib/l10n/app_localizations*.dart` | Regenerated with `flutter gen-l10n`. |
| `lib/screens/help/*.dart` (24 files) | All user-visible strings now come from `AppLocalizations`. |
| `lib/screens/help/help_home_screen.dart` | Also a layout fix: see below. |
| `lib/l10n/relationship_labels.dart` | New `relationshipCategoryDescription`, used by the Relationship categories article. |
| `test/help_screens_test.dart` | Its `MaterialApp` now loads the localization delegates, so its English checks still work. |
| `test/t9_dialing_help_screen_test.dart` | Same change: its `MaterialApp` now loads the localization delegates. |
| `test/l10n/help_screens_l10n_test.dart` | **New.** Tests described under Verification. |
| `plans/20260921_064200_item2-arb-string-externalization.md` | Status line updated. |

---

## Decisions made along the way

### Relationship categories get translated names and descriptions

The Relationship categories article lists the seven categories with the model's English name and
description (`lib/models/relationship.dart`). The article now shows `relationshipCategoryLabel`
(added in phase 2e) and the new `relationshipCategoryDescription`, which reads seven new keys
(`descCatImmediateFamily` … `descCatService`). The line is built from one template key,
`helpRelationshipCategoriesExample(description, examples)`, so no language has to join English
fragments.

### A layout fix on the Help hub

The section headings on the Help hub ("CALLING & DIALER", "PRIVACY & PROTECTION", …) were a plain
`Text` inside a `Row`. At 1.3× text on a 360-pixel-wide phone, the longer headings ran past the
right edge. This happened in English too; the new tests found it. The heading text is now wrapped
in `Expanded`, so it wraps instead of overflowing.

---

## Left in English on purpose

| What | Why |
|---|---|
| The example relationship names in the Relationship categories article ("Father", "Colleague", …) | They are the saved relationship names, which are data. They will be translated for display when the relationship screens are converted in a later phase. |
| The quoted examples "Father" and "Colleague" in the Sanskrit and Malayalam text of that article | They show what the app actually saves. |
| Technical and product names: SQLite, SHA-256, PBKDF2, AES-GCM, .csbak, vCard, CSV, QR, OCR, BLE, P2P, IVR, PIN, SIM, Wi-Fi, Bluetooth, AirQR, Google Drive, OneDrive, WebDAV, CardDAV, WhatsApp, Telegram, Arattai, Android, iOS, Smart Redial, the app name | Formats, protocols, product and feature names. |
| The Malayalam letters inside the Sanskrit T9 article and hub card (അ … അഃ, ക-ങ, "അനിൽ") | They are the Malayalam keypad samples the article is about. |

---

## Sanskrit gate

The §8.5.1 gate flagged three Sanskrit strings during this phase. All were false positives from
substrings of correct Sanskrit words, and each word was replaced:

| Key | Flagged | Now |
|---|---|---|
| `helpHomeSub17` | प्रणालीसङ्ग्रहेण (contains रहे) | प्रणालीकोशेन |
| `helpT9DialingIntro` | कुञ्जिकाप्रहारैः (contains रहा) | कुञ्जिकास्पर्शैः |
| `helpT9DialingBullet8` | कुञ्जिकाप्रहाराः (contains रहा) | कुञ्जिकास्पर्शाः |

The gate now finds nothing in `lib/l10n/app_sa.arb` or `assets/config/app_config.json`.

---

## Verification

- `flutter analyze` → No issues found.
- `flutter test` → see the phase 2g change log, which records the full run after both phases.
- `test/l10n/help_screens_l10n_test.dart` (new, 69 tests): all 23 articles and the Help hub, each
  in `en`, `ml` and `sa`, laid out in full on a 360-pixel-wide, very tall screen at 1.3× text.
  Each shows its translated title and lead paragraph, the English title and lead do not appear in
  `ml`/`sa`, and nothing overflows.
- `test/help_screens_test.dart` (existing, 26 tests) passes.
- Key parity: the three ARB files each have the same 1913 keys.
- Mixed-script check: no Devanagari in the Malayalam help text; the only Malayalam letters in the
  Sanskrit help text are the T9 samples listed above.

## Needs a fluent reader

The help articles are the largest translation in item 2 (about 50,000 characters of English). The
Malayalam and Sanskrit were written to the approved glossary but have not been read by a fluent
speaker. The FAQ, Call management, Emergency info and P2P sync articles are the longest and should
be read first.
