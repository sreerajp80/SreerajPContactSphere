# Shorten the 14 over-budget English labels

**Status:** done — see `change_log/20260921_114500_shorten-over-budget-english-labels.md`

Follow-up to `change_log/20260921_110000_item2b-app-chrome-and-shared-widgets.md` ("Left for
later", item 3). The user chose to shorten all 14 labels to the wording suggested there.

## The issue

Engineering standard §8.6 limits short UI text (buttons, titles, tabs, labels, tooltips) to
20 characters in English, so a label does not wrap onto two lines on a small phone. Fourteen
English strings in `lib/l10n/app_en.arb` are longer than that. They were long before they moved
into the ARB. `test/l10n/label_length_test.dart` currently lists them in `_englishOverBudget` as
known exceptions.

Two of them also break the standard's other wording rules: the "OPTION 1/2" headings are all
capitals, and several use Title Case where the standard asks for sentence case.

## The new wording

| Key | Current | New |
|---|---|---|
| `labelBlockUnknownCallers` | Block unknown callers | Block unknown |
| `labelAddFollowUpReminder` | Add a follow-up reminder | Follow-up reminder |
| `actionReceiveViaBluetooth` | Receive via Bluetooth | Get via Bluetooth |
| `titleAuthenticateToReceive` | Authenticate to receive | Verify to receive |
| `titleAllowAlarmsReminders` | Allow "Alarms & reminders" | Allow alarms |
| `labelOptionAutoRetry` | OPTION 1: ONE-TAP AUTO-RETRY | 1. Auto-retry |
| `labelOptionReachMe` | OPTION 2: REACH ME MESSAGE | 2. Reach-me message |
| `actionSendReachMeSms` | Send "Trying to Reach You" SMS | Send reach-me SMS |
| `titleSelectSimForRetry` | Select SIM for Auto-Retry | SIM for auto-retry |
| `actionHideScannedText` | Hide all scanned text | Hide scanned text |
| `actionShowScannedText` | Show all scanned text | Show scanned text |
| `tooltipAirGapStream` | Air-Gap Stream (Full Contact) | Full-contact QR |
| `labelUsualSimForCall` | Usual SIM for this call | Usual SIM |
| `labelContactsToImport` | Contacts to Import ({count}): | To import ({count}): |

The Malayalam and Sanskrit values already fit the 22-character budget and still mean the same
thing, so they do not change. Their meaning was always the shorter one (for example the Sanskrit
for the "OPTION 1" heading already reads "first way: call-back").

## Files to be changed

| File | Change |
|---|---|
| `lib/l10n/app_en.arb` | The 14 English values above. Drop the "over the 20-character budget; see the phase 2b change log" sentence from each `@key` description, and the matching sentence in `labelBlockUnknownCallers`' description. |
| `lib/l10n/app_localizations*.dart` | Regenerated with `flutter gen-l10n`. |
| `lib/screens/contact_list_screen.dart` | Menu item "Receive via Bluetooth" → "Get via Bluetooth". The Bluetooth share dialog tells the user to pick this menu item by name, so the two must match. The screen is still an English literal until phase 2c; only the wording changes here. |
| `lib/screens/ble_receive_screen.dart` | App-bar title and header comment "Receive via Bluetooth" → "Get via Bluetooth", to match the menu item. |
| `lib/main.dart` | The second SIM chooser's note `'Usual SIM for this call'` → `'Usual SIM'`, to match `labelUsualSimForCall`. |
| `lib/screens/help/caller_id_spam_help_screen.dart`, `lib/screens/help/call_screening_help_screen.dart` | Help text that quotes the switch name "Block unknown callers" → "Block unknown". |
| `lib/screens/blocked_numbers_screen.dart` | Doc comment naming the toggle. |
| `docs/architecture.md`, `docs/known-gaps.md` | Mentions of the "Receive via Bluetooth" menu item. |
| `test/l10n/label_length_test.dart` | Empty `_englishOverBudget`. Keep the set and the staleness test, so a future over-budget English label must be listed on purpose rather than slipping in. |
| Any test that asserts one of the old English strings | Updated to the new wording. A search at planning time found none, but the full suite will confirm. |

## The plan for the fix

1. Edit the 14 values and descriptions in `app_en.arb`; run `flutter gen-l10n`.
2. Update the English literals and docs listed above.
3. Empty `_englishOverBudget` in the label-length test.
4. Run `flutter analyze` (zero warnings), `flutter test`, and `dart format` on the touched files.
5. Write the change log.

## Risk

Very low. English wording only; no logic, key names, or translations change. The one thing to get
right is keeping "Get via Bluetooth" identical in the menu, the receive screen and the share
dialog hint, which step 2 covers.

## Explicitly out of scope

- Translating `contact_list_screen.dart`, `ble_receive_screen.dart` or the help screens. That is
  phases 2c and 2f.
- Any Malayalam or Sanskrit wording.
