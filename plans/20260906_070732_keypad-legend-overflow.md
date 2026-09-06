# Keypad letter legend overflows on narrow keys

**Status:** completed

## The issue

Each dial key draws its digit and, under it, a letter legend row
("ABC", "PQRS", and in Malayalam mode the Malayalam letters too).
That legend row has no give in it:

- It is a `Row` with `mainAxisSize: MainAxisSize.min` and no
  `Flexible`, `FittedBox`, or clipping around it
  (`lib/screens/dialer_screen.dart`, the `_key` builder).
- Its `Text` widgets use a fixed `fontSize: 8.5` with
  `letterSpacing: 0.8`.
- `Text` scales with the user's system font-size setting by default,
  so the row grows while the key it sits in does not.

So the row asks for whatever width its letters need, and overflows the
key when that width is not available.

This was found while testing speed dial: at a 320 logical-pixel wide
viewport the "PQRS" legend is about 7 pixels too wide. It overflows the
same amount on the unmodified dialer, so it is a pre-existing bug, not
one speed dial introduced. The widget test currently sidesteps it by
using a 360-pixel viewport (see the comment in
`test/dialer_speed_dial_keypad_test.dart`).

320-pixel phones barely exist any more, so that exact case does not
matter. Two cases that do:

1. **Large system font size.** A normal 360-pixel phone with the display
   font setting turned up hits the same limit, because the legend text
   scales but the key does not.
2. **Malayalam mode.** The row can hold the English letters, a
   " · " separator, and the Malayalam letters. That is much wider than
   "PQRS" alone, so it runs out of room sooner than the English-only
   keypad does.

The widest key content is "WXYZ" (key 9) in English and, in Malayalam
mode, whichever key has the longest combined legend.

## Files to change

- `lib/screens/dialer_screen.dart` — the `_key` builder: make the letter
  legend row shrink instead of overflow.
- `test/dialer_speed_dial_keypad_test.dart` — drop the note that
  explains the 320-pixel overflow, once it is no longer true.
- `test/dialer_keypad_legend_test.dart` (new) — a test that proves the
  legend no longer overflows under pressure.

## The plan for the fix

1. **Make the legend shrink to fit.** Wrap the legend `Row` in a
   `FittedBox(fit: BoxFit.scaleDown)`. `scaleDown` only ever shrinks:
   at normal sizes nothing changes at all, and when the row is too wide
   it is scaled down to fit the key instead of overflowing. This fixes
   every cause at once — narrow screen, large font setting, and the
   longer Malayalam legend — rather than the one viewport that was found.

2. **Give the `FittedBox` a width to fit into.** A `FittedBox` inside a
   `Column` still needs a bounded width, so the legend will be placed in
   a full-width child of the key's `Column` (the `Column` already
   stretches to the key). Keep the legend centred as it is today.

3. **Also clamp how far the legend text scales.** Even scaled down, a
   very large system font setting would make the legend shrink so much
   it stops being readable, while the digit above it grows and squeezes
   the key vertically. Clamp the legend's text scale to a maximum of
   about 1.2 (`MediaQuery.withClampedTextScaling`, legend only). The
   digit keeps scaling as it does now, so accessibility is not reduced
   where it matters — the digit is the tap target's label; the letters
   are a hint.

4. **Do not change** the digit, key size, spacing, colours, the speed
   dial dot, or any layout above or below the keypad. This plan is only
   about the legend row not overflowing.

## Testing

- New widget test `test/dialer_keypad_legend_test.dart`:
  - pumps the dialer at 320x640 logical pixels and asserts no overflow
    (the test framework fails on an overflow, so simply pumping and
    settling proves it);
  - pumps again at 360x740 with the text scale raised (about 1.5) and
    asserts no overflow;
  - pumps once more in Malayalam mode, so the dual legend is covered.
- Remove the now-wrong explanation comment in
  `test/dialer_speed_dial_keypad_test.dart`. Its viewport can stay at
  360 — that test is about speed dial, not about legend width.
- Run `flutter analyze` (must stay at zero warnings) and
  `flutter test`.
- Check the keypad by eye on a device at normal font size, at the
  largest font size, and in Malayalam, to confirm the legend still looks
  right and is not visibly shrunken in the normal case.

## Risk

Low. The change is confined to one widget subtree inside `_key`.
`BoxFit.scaleDown` is a no-op when the content already fits, so the
keypad most users see should be pixel-identical to today.
