# In-call DTMF keypad legibility fix

Implements plan: `plans/20260705_140916_dtmf-keypad-legibility.md`

## Changed

- `lib/screens/in_call_screen.dart`
  - Wrapped the main in-call `SafeArea` column in `Visibility(visible: !_showKeypad,
    maintainState: true, ...)` so the Mute/Speaker/Hold controls and labels no longer
    bleed through the DTMF keypad overlay while it is open (state is preserved, just
    not painted).
  - `_dtmfPad`: raised the full-screen overlay scrim from `Colors.black` alpha 0.72
    to 0.92, so the caller image only faintly shows and the pad reads as a near-solid
    surface.
  - `_dtmfKey`: raised the key-circle background from `Colors.white` alpha 0.14 to
    0.20 for clearer targets on the darker scrim.

## Verification

- `flutter analyze lib/screens/in_call_screen.dart` — no issues found.
