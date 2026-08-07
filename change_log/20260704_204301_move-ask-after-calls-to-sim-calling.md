# Move "Ask after calls" toggle into SIM & calling

Implements [plans/20260704_204301_move-ask-after-calls-to-sim-calling.md](../plans/20260704_204301_move-ask-after-calls-to-sim-calling.md).

## What changed

1. `lib/screens/settings_screen.dart`
   - Removed the `_PostCallFeedbackCard` entry from the Settings hub `ListView` and deleted
     the now-unused `_PostCallFeedbackCard` class.
   - Updated the SIM & calling card subtitle to
     "Default SIM, SIM prompt and post-call feedback".

2. `lib/screens/sim_settings_screen.dart`
   - Added `_postCallFeedbackCard`, a `SwitchListTile` card ("Ask after calls" / "Show the
     'How did it go?' sheet when a call ends") wired to
     `AppSettings.postCallFeedbackEnabled` / `setPostCallFeedbackEnabled`, styled like the
     existing "Ask which SIM" card.
   - It renders at the end of the list and is shown even when no SIMs are detected, since
     post-call feedback doesn't depend on SIM availability.

No changes to `AppSettings` — the stored key, default (off), and setter are unchanged; only
the UI location moved.

## Verification

`flutter analyze lib/screens/settings_screen.dart lib/screens/sim_settings_screen.dart` —
no issues found.
