# Fix the in-call keypad (DTMF tones and the stray "+91")

Implements plan: [plans/20261001_194040_fix-in-call-keypad-tones.md](../plans/20261001_194040_fix-in-call-keypad-tones.md)

## Problem

- On a customer-care call, keys pressed on the in-call keypad often sent no tone,
  so the IVR menu did not react.
- A "+91 …" line showed under the digits while typing on that keypad.

## What changed

File: `lib/screens/dialer_screen.dart` — only when the screen is opened as the
in-call keypad (`dtmfMode: true`). The normal dialer and the "Add call" screen
are unchanged.

1. **Tones now go out on every tap.** The tone used to be sent by an outer
   `GestureDetector` that always lost the tap to the inner `InkWell`, so a quick
   tap sent no tone. It is now sent from a `Listener` (raw finger down / up
   events), which is not part of that contest: the tone starts when the finger
   touches the key and stops when it lifts.
2. **No long-press actions** in keypad mode — no speed-dial call and no "+".
3. **No "+91 …" number check line** in keypad mode.
4. **No contact strip** (suggestions, "Add to contacts", favourites) and no
   contact search per key press in keypad mode. The empty space keeps the
   keypad in place.
5. **No voice-dial mic** in keypad mode.

## Checks

- `dart format` — no changes needed.
- `flutter analyze` — no issues.
- `flutter test` — all tests passed.
- Not yet tested on the phone: call an IVR, open Keypad, tap digits quickly.

## Left for later

`lib/screens/in_call_screen.dart` still has an older keypad overlay
(`_dtmfPad`, `_showKeypad`) that nothing opens. It is dead code for a separate
clean-up.
