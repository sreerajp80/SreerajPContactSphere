# Features doc — fifteenth gap fill

Implements: `plans/20260805_060000_features_doc_fifteenth_gap_fill.md`

## What changed

Added two small facts to `docs/features.md` that a fresh audit of the code
found were missing:

1. Section 1 ("Contacts management"), "Contact list" bullet: noted that
   long-pressing the Call button on a contact with more than one phone
   number opens a sheet to pick which number to dial, before the SIM
   chooser runs (`lib/widgets/number_picker_sheet.dart`).

2. Section 2 ("Dialer / calling"), "Recents / call history" bullet: added
   "Copy number" and "Share number" to the list of actions on a Recents
   entry's long-press menu (`lib/screens/call_history_screen.dart`).

No other gaps were found this round. All screens, services, native Kotlin
files, `pubspec.yaml` dependencies, and app settings already had matching
coverage in the doc. The App Description intro paragraph did not need any
changes.
