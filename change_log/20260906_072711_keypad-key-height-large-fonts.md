# Dial keys grow with the system font size instead of clipping

Implements `plans/20260906_071805_keypad-key-height-large-fonts.md`.
Follows on from `change_log/20260906_071340_keypad-legend-overflow.md`,
which fixed the legend's width and left this one open.

## What was wrong

A key's height is its width divided by the grid's `childAspectRatio`,
which was a fixed 1.85. The digit inside the key scales with the user's
system font-size setting; the key did not. Past roughly 1.3x the key's
column overflowed at the bottom. Narrow screens were worse, because a
narrower key is also a shorter one.

## What changed

**`lib/screens/dialer_screen.dart`**

- New file-level constant `_kMaxKeyScale = 1.5` — how far the keypad
  follows the system font setting.
- In `_dialpad`, the grid's ratio is now
  `1.85 / textScale`, where `textScale` is
  `MediaQuery.textScalerOf(context)` clamped to `1.0 .. _kMaxKeyScale`.
  At normal font sizes the divisor is 1.0 and the keypad is unchanged.
  Above that the keys get taller in step with the text, so the digit
  stays big and readable rather than being shrunk back down.
- In `_key`, the digit `Text` is wrapped in
  `MediaQuery.withClampedTextScaling(maxScaleFactor: _kMaxKeyScale)`.
  Past 1.5x the key has stopped growing, so the digit stops with it.

Nothing else changed: same base font size, legend, colours, spacing and
speed-dial dot.

**`test/dialer_keypad_legend_test.dart`** — now covers height as well as
width. Six tests:

- 320x640;
- 360x740 at 1.5x font size (was 1.3x, the old limit);
- 360x740 with the Malayalam legend;
- 320x640 with the Malayalam legend;
- 320x640 at 1.5x with the Malayalam legend — the worst case in both
  directions at once;
- 320x640 at 1.5x asserting the call button is still on screen, since a
  taller keypad must take its extra height from the flexible strip above
  it and not push the button off the bottom.

The header comment that explained the old 1.3x limit is gone.

## Checks

- `flutter analyze` — no issues.
- `flutter test test/dialer_keypad_legend_test.dart` — 6 tests pass.
- `flutter test test/dialer_speed_dial_keypad_test.dart` — 3 pass.
- `flutter test test/t9_dialing_help_screen_test.dart` — 1 pass.
- Confirmed the fix does the work: with the dialer change reverted, 5 of
  the 6 tests fail, reporting overflows of 50 pixels on the right and 14
  pixels on the bottom.
- The suite is run one file per invocation because of the known
  native-assets crash when several database-backed test files share one
  run.

## Not done

- **No check by eye on a real device yet.** The plan asked for one at the
  largest system font size. The widget test proves the call button stays
  on screen at 1.5x on a 320x640 viewport, but it cannot judge whether
  the taller keypad still looks right. Worth a look before release.
- The 1.5x clamp was kept as planned; the on-screen check passed, so it
  did not need lowering.
