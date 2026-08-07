# In-call DTMF keypad legibility fix

**Status:** completed

## Files to change

- `lib/screens/in_call_screen.dart`

## Issue

When the DTMF keypad is opened during a call, the full-screen overlay scrim is
`Colors.black.withValues(alpha: 0.72)` and each key circle is
`Colors.white.withValues(alpha: 0.14)` (`_dtmfPad` / `_dtmfKey`). Over a bright
caller image (calling card / profile photo), 28% of the backdrop still bleeds
through, and the in-call controls underneath (Mute / Speaker / Hold labels and
icons) remain visible through the overlay because the keypad is stacked on top
of them without hiding them. The result is the screenshot the user shared:
digits sit on a translucent pad with the photo and the old control labels
showing through, so the numbers are hard to read.

## Fix

In `lib/screens/in_call_screen.dart`:

1. **Hide the underlying call UI while the keypad is open.** In `build()`, wrap
   the main `SafeArea` column in `Visibility`/`Offstage` gated on
   `!_showKeypad` (keep it in the tree so state is preserved, just not
   painted). This removes the Mute/Speaker/Hold labels and buttons bleeding
   through the digits.
2. **Raise the scrim opacity.** In `_dtmfPad`, change the overlay from
   `alpha: 0.72` to `alpha: 0.92` so the caller photo only faintly shows and
   the pad reads as a solid surface, matching the app's own dark in-call
   styling (not a clone of any other dialer).
3. **Strengthen the key circles slightly.** In `_dtmfKey`, bump the key
   background from `alpha: 0.14` to `alpha: 0.20` for clearer hit targets on
   the darker scrim. Digit text stays solid white.

No other screens, no schema/service changes. After approval: implement, run
`flutter analyze` on the touched file, and write the change log.
