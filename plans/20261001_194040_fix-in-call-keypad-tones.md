# Fix the in-call keypad (DTMF tones and the stray "+91")

**Status:** completed

## What the user sees

1. During a customer-care call, pressing 1, 2, … on the in-call keypad often does
   nothing. The IVR menu does not react.
2. While typing on that keypad, a "+91 …" line shows under the digits.

## What is wrong

The in-call **Keypad** button opens `DialerScreen(dtmfMode: true)` — the normal
dialer screen reused for touch tones (DTMF). Two problems come from this:

### 1. Tones are lost on quick taps

In `lib/screens/dialer_screen.dart` (`_key`), every key has two tap handlers
stacked on top of each other:

- an outer `GestureDetector` that sends the tone (`playDtmf` / `stopDtmf`), and
- an inner `InkWell` that adds the digit to the text box (plus long-press for
  speed dial and `0 → +`).

Flutter lets only one of these "win" a tap. The inner `InkWell` always wins.
The outer one only fires its `onTapDown` if the finger stays down longer than
about 100 ms, and then it is cancelled straight away. So:

- a quick tap → the digit appears on screen, but **no tone is sent**;
- a slower press → the tone starts and is cut short.

That is why the IVR menu does not respond reliably.

### 2. The dialer extras still run in keypad mode

In keypad mode the screen still behaves like the dialer:

- the number check line under the box shows the digits as a phone number
  using the default country, e.g. "+91 1" — this is the "+91" the user sees;
- the strip above the keypad searches contacts and offers "Add to contacts";
- the voice-dial mic button is shown;
- long-press on 1–9 can **start a speed-dial call** (or open the picker) in the
  middle of the current call;
- long-press on 0 types "+", which is not a DTMF key.

None of these make sense while sending tones.

## The fix

All in `lib/screens/dialer_screen.dart`, only when `widget.dtmfMode` is true
(the normal dialer is not changed):

1. **Send tones from a raw pointer listener.** Wrap the key in a `Listener`
   with `onPointerDown` → `playDtmf(digit)` and `onPointerUp` /
   `onPointerCancel` → `stopDtmf()`. A `Listener` is not part of Flutter's tap
   contest, so the tone fires the moment the finger touches the key, every
   time, and stops when it lifts. Remove the outer `GestureDetector`.
2. **No long-press actions in keypad mode.** `onLongPress` is `null` (no speed
   dial, no "+").
3. **Hide the number check line** (the "+91 …" text) in keypad mode.
4. **Hide the contact strip** (suggestions, "Add to contacts", favourites) in
   keypad mode — show an empty area so the keypad stays in place — and skip the
   contact search on each key press.
5. **Hide the voice-dial mic** in keypad mode.

The native side (`CallRegistry.playDtmf` / `stopDtmf`) is fine and is not changed.

## Files to change

- `lib/screens/dialer_screen.dart`

## Not in this change

`lib/screens/in_call_screen.dart` still holds an older keypad overlay
(`_dtmfPad`, `_showKeypad`) that nothing opens any more. It is dead code. It can
be removed in a separate clean-up.

## Checks

- `dart format`, `flutter analyze` (zero warnings), `flutter test`.
- On the phone: call a customer-care IVR, open Keypad, tap digits quickly — the
  menu should react to each tap, and no "+91" line or contact list appears.
