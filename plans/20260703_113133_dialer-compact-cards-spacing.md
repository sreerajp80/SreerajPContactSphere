# Dialer: reduce contact-card size and top spacing

**Status:** completed

## Issue

On the Dialer screen the Favorites / Top-contacts / suggestion cards are taller than they
need to be, and the top of the screen (title bar + number-display row) eats vertical space.
The user wants both trimmed so more contacts fit and the pad sits with less dead space up top.

## Files to change

- `lib/screens/dialer_screen.dart` — the only file. Adjust the contact-card widget
  (`_matchRow`), the shared avatar (`_avatar`), and the top chrome (`_appBar`,
  `_numberDisplay`, and the `_strip` list padding).

## Plan for the fix

### 1. Slimmer contact cards (`_matchRow`, `_avatar`)
- `_matchRow` outer `margin` bottom: `9` → `6`.
- `_matchRow` inner `Padding`: `all(10)` → `all(8)`.
- Avatar in `_avatar`: `42x42` → `36x36`; avatar initial `fontSize` `16` → `14`;
  square `borderRadius` `13` → `11`.
- Gap between avatar and text: `SizedBox(width: 12)` → `10`.
- Name `fontSize` `14.5` → `14`; subtitle gap `SizedBox(height: 2)` → `1`.
- Trailing call button: `38x38` container → `34x34`; icon size `18` → `16`.

### 2. Tighter top portion
- `_appBar` padding: `fromLTRB(20, 8, 12, 4)` → `fromLTRB(20, 4, 12, 2)`.
- `_numberDisplay` `SizedBox(height: 56)` → `48`, and padding
  `fromLTRB(20, 4, 20, 2)` → `fromLTRB(20, 0, 20, 0)`.
- `_strip` top padding on the three `ListView`s: `fromLTRB(16, 6, 16, 4)` → `fromLTRB(16, 2, 16, 4)`.

### 3. Keep layout math safe
- The `build` LayoutBuilder uses a `const chrome = 200.0` over-estimate to cap the strip.
  Shrinking the chrome only makes that estimate more conservative (more slack), so no
  overflow risk; leave `chrome` as-is.

## Non-goals
- No change to the dialpad keys, call button, or behavior/logic — spacing/size only.
