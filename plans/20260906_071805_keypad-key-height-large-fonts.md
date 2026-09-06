# Dial keys overflow at the bottom at large system font sizes

**Status:** completed

## The issue

Each dial key is a fixed shape: the keypad is a `GridView.count` with
`crossAxisCount: 3` and `childAspectRatio: 1.85`, so a key's height is
always its width divided by 1.85 (`lib/screens/dialer_screen.dart`, the
`_dialpad` builder). Inside the key a `Column` stacks the digit
(`fontSize: 24`, `height: 1.1`) over the letter legend.

The digit scales with the user's system font-size setting. The key does
not. So as the font setting goes up, the digit grows inside a box that
stays the same, and past roughly 1.3x the column overflows at the
bottom.

Measured on a 320x640 viewport: the key is about 82.7 wide and 44.7
high, and the column overflows by a few pixels. It is worse on narrower
screens, because a narrower screen means a narrower key, and a narrower
key is also a shorter one.

This is a pre-existing problem, not something the recent legend change
introduced — it reproduces with that change reverted (6.3 pixels).
It was found by the tests added in
`plans/20260906_070732_keypad-legend-overflow.md`, which deliberately
left the digit and the key size alone. This plan covers what that one
left out.

Note the earlier fix already handles the legend: it is clamped to 1.2x
and shrinks to fit. The remaining growth is the digit alone.

## Files to change

- `lib/screens/dialer_screen.dart` — the `_dialpad` builder (key shape)
  and the `_key` builder (a safety net on the digit).
- `test/dialer_keypad_legend_test.dart` — raise the font-size test past
  1.3x and drop the comment that explains why it stopped there.

## The plan for the fix

1. **Let the key grow with the font setting.** In `_dialpad`, divide the
   aspect ratio by the current text scale, clamped:

   `childAspectRatio: 1.85 / textScale.clamp(1.0, 1.5)`

   taking the scale from `MediaQuery.textScalerOf(context)`. At normal
   font sizes the divisor is 1.0 and the keypad is unchanged. At larger
   settings the keys get taller in step with the text, which is the
   accessible answer — the digit stays big and readable instead of being
   shrunk back down. The clamp at 1.5 stops the keypad eating the whole
   screen at extreme accessibility settings.

   Rough check of the numbers at 320 pixels wide: the column needs about
   `26.4 x scale + 11.5` pixels, and this gives it `44.7 x scale`. That
   fits with room to spare through 1.5x.

2. **Keep a safety net on the digit.** Past the 1.5x clamp the key stops
   growing, so clamp the digit's own text scaling to 1.5
   (`MediaQuery.withClampedTextScaling` around the digit `Text` only, the
   same tool already used for the legend). Beyond that point the key is
   as tall as it is going to get, so the digit must stop too. Below 1.5x
   nothing changes.

3. **Check the keypad still fits the screen.** The dialpad sits in a
   `Column` under an `Expanded` strip (`build`), so a taller keypad takes
   its extra height from that flexible strip rather than pushing the call
   button off-screen. This needs checking on a short screen at 1.5x — if
   the strip cannot give up enough room, lower the clamp in step 1 from
   1.5 to whatever does fit, and say so in the change log.

4. **Do not change** the digit's base size, the legend, key colours,
   spacing, or the speed-dial dot.

## Testing

- In `test/dialer_keypad_legend_test.dart`, raise the font-size test from
  1.3x to 1.5x, add the narrow-screen-plus-large-font case back, and
  remove the comment explaining the old limit.
- Add a test at 320x640 and 1.5x with the Malayalam legend on — the worst
  case in both directions at once — asserting no overflow and that the
  call button is still on screen.
- Run `flutter analyze` (must stay at zero warnings) and the dialer test
  files (one file per invocation, because of the known crash when several
  database-backed files share one run).
- Check by eye on a device at the largest system font size: the keys
  should look taller, the digits bigger, and nothing clipped.

## Risk

Medium — higher than the legend fix, because the keypad's height now
changes with a system setting, and everything below it shares the same
screen. The mitigation is the clamp in step 1 and the on-screen check in
step 3. Nothing changes at all at normal font sizes.
