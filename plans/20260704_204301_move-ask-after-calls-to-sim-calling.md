# Move "Ask after calls" toggle into SIM & calling

**Status:** completed

## Issue

The "Ask after calls" toggle (post-call "How did it go?" feedback sheet) currently sits as a
standalone card near the top of the Settings hub (`_PostCallFeedbackCard` in
`lib/screens/settings_screen.dart`). The user wants it grouped under the **SIM & calling**
settings screen instead, where the other calling-related options live.

## Files to change

1. `lib/screens/settings_screen.dart`
   - Remove the `_PostCallFeedbackCard` entry (and its trailing `SizedBox`) from the hub's
     `ListView`.
   - Delete the now-unused `_PostCallFeedbackCard` class.
   - Update the SIM & calling hub card subtitle from "Default SIM and per-call SIM prompt" to
     also hint at the feedback option, e.g. "Default SIM, SIM prompt and post-call feedback".

2. `lib/screens/sim_settings_screen.dart`
   - Add an "Ask after calls" toggle card (`SwitchListTile`-style, matching `_askSimCard`'s
     look: bold 16px title, muted 13px subtitle, accent thumb) wired to
     `AppSettings.postCallFeedbackEnabled` / `setPostCallFeedbackEnabled`.
   - Placement: at the **end** of the list, and shown **always** — including when no SIMs are
     detected — because post-call feedback doesn't depend on SIM availability. Layout becomes:
     - no SIMs: no-SIMs note → Ask after calls
     - SIMs present: Default SIM → Ask which SIM → SIM colours → Ask after calls

## Not changing

- `AppSettings` (`lib/state/app_settings.dart`) — the setting key, default, and setter stay
  as-is; only the UI location moves.
- The feedback sheet itself (`lib/widgets/post_call_feedback_sheet.dart`).

## Verification

- `flutter analyze` (expect only the pre-existing known-gaps errors, no new ones).
- Visual check: hub no longer shows the toggle; SIM & calling shows it and it flips the
  setting.
