# Shorten the 14 over-budget English labels

**Plan:** `plans/20260921_113000_shorten-over-budget-english-labels.md`
**Status:** done.

---

## What changed

Engineering standard §8.6 limits short UI text to 20 characters in English. Fourteen English
labels were longer than that, and `test/l10n/label_length_test.dart` carried them as known
exceptions. They are now shortened, and the exception list is empty.

| Key | Before | After |
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

The Malayalam and Sanskrit values did not change. They already fit the 22-character budget and
carry the same meaning.

## Files changed

| File | Change |
|---|---|
| `lib/l10n/app_en.arb` | The 14 values above. Removed the "over the 20-character budget" and "all capitals by design" notes from their descriptions. Updated one description and one placeholder example that named the old labels. |
| `lib/l10n/app_localizations*.dart` | Regenerated with `flutter gen-l10n`. |
| `lib/screens/contact_list_screen.dart` | Menu item "Receive via Bluetooth" → "Get via Bluetooth". The Bluetooth share dialog tells the user to pick this item by name, so the two now match. |
| `lib/screens/ble_receive_screen.dart` | App-bar title and header comment → "Get via Bluetooth". |
| `lib/main.dart` | The second SIM chooser's note → "Usual SIM", matching `labelUsualSimForCall`. |
| `lib/screens/help/caller_id_spam_help_screen.dart` | Section title and bullet that name the switch → "Block unknown". |
| `lib/screens/help/call_screening_help_screen.dart` | Bullet that names the switch → "Block unknown". |
| `lib/screens/blocked_numbers_screen.dart` | Doc comment that names the toggle. |
| `docs/architecture.md`, `docs/known-gaps.md` | Mentions of the menu item → "Get via Bluetooth". |
| `test/l10n/label_length_test.dart` | `_englishOverBudget` is now empty. The set and its staleness check stay, so a future over-budget English label has to be added on purpose. |
| `plans/20260921_113000_shorten-over-budget-english-labels.md` | Status line updated. |

The four screens above are not translated yet (phases 2c and 2f). Only their English wording
changed, to stay in step with the ARB.

## Verification

| Check | Result |
|---|---|
| `flutter analyze` | No issues found. |
| `flutter test` (whole suite) | 601 passed, 2 skipped, 0 failed. |
| `test/l10n/label_length_test.dart` | All English short keys within 20 characters with no exceptions; Malayalam and Sanskrit within 22. |
| `dart format` on the reformatted test and help files | Clean. |

One note: on the first full run,
`test/smart_redial_service_test.dart` ("rescheduling auto-redial for same phone number cancels
previous active task") failed once. It passed when run alone and on a second full run. This change
touches no code that test uses, so it looks like a timing-dependent (flaky) test. Worth its own
look if it fails again.
