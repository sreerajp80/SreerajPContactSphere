# Keypad letter legend no longer overflows its key

Implements `plans/20260906_070732_keypad-legend-overflow.md`.

## What was wrong

The letter legend under each dialpad key ("ABC", "PQRS", and the
secondary script when one is chosen) was a plain `Row` with
`mainAxisSize: MainAxisSize.min`, a fixed `fontSize: 8.5` and
`letterSpacing: 0.8`, with nothing to make it shrink. It asked for the
width its letters needed and overflowed the key when that width was not
available: on a narrow screen, at a large system font size, or when the
row also had to carry the secondary script next to the English letters.

## What changed

**`lib/screens/dialer_screen.dart`** — in the `_key` builder, the legend
row is now wrapped in:

- a full-width `SizedBox`, so there is a known width to fit into;
- `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.2)`, so the
  legend stops growing with very large system font sizes (the digit
  above it still scales as before — it is the label that matters);
- `FittedBox(fit: BoxFit.scaleDown)`, so the row shrinks to fit instead
  of overflowing.

`scaleDown` only ever shrinks, so at normal sizes the keypad renders
exactly as before. Nothing else changed: same digit, key size, spacing,
colours and speed-dial dot.

**`test/dialer_keypad_legend_test.dart`** (new) — four widget tests that
pump the dialer under layout pressure and assert no exception (an
overflow is reported as one):

- 320x640 logical pixels;
- 360x740 at 1.3x system font size;
- 360x740 with the Malayalam legend on the keys;
- 320x640 with the Malayalam legend — the worst width case.

**`test/dialer_speed_dial_keypad_test.dart`** — removed the note that
explained the old 320-pixel overflow, and pointed it at the new test
instead. Its own viewport stays at 360; that test is about speed dial.

## Checks

- `flutter analyze` — no issues.
- `flutter test test/dialer_keypad_legend_test.dart` — 4 tests pass.
- `flutter test test/dialer_speed_dial_keypad_test.dart` — 3 tests pass.
- Confirmed the bug and the fix: with the change reverted, the same new
  tests report horizontal overflows of 21 and 33 pixels; with the change
  in place there are none.
- The suite is run one file per invocation because of the known
  native-assets crash when several database-backed test files share one
  run.
- Not yet checked by eye on a device.

## Known limit left alone

The new tests surfaced a second, older problem in the other direction:
above roughly 1.3x system font size the key's column overflows at the
**bottom** by a few pixels. That is the digit (`fontSize: 24`) growing
inside a key whose height does not, not the legend, and the plan for
this change explicitly left the digit and key size alone. It needs its
own plan. The new font-size test therefore stops at 1.3x, with a comment
saying why.
