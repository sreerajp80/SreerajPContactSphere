# Dialer: reduced contact-card size and top spacing

Implements plan `plans/20260703_113133_dialer-compact-cards-spacing.md`.

## What changed

Single file: `lib/screens/dialer_screen.dart` (spacing/size only, no logic changes).

### Slimmer contact cards (`_matchRow`, `_avatar`)
- Card outer bottom margin: `9` → `6`.
- Card inner padding: `all(10)` → `all(8)`.
- Avatar: `42x42` → `36x36`; initial font `16` → `14`; square radius `13` → `11`.
- Avatar↔text gap: `12` → `10`.
- Name font: `14.5` → `14`; name↔subtitle gap: `2` → `1`.
- Trailing call button: `38x38` → `34x34`; call icon `18` → `16`.

### Tighter top portion
- `_appBar` padding: `fromLTRB(20, 8, 12, 4)` → `fromLTRB(20, 4, 12, 2)`.
- `_numberDisplay` height `56` → `48`; padding `fromLTRB(20, 4, 20, 2)` → `fromLTRB(20, 0, 20, 0)`.
- `_strip` list top padding (all three `ListView`s): `fromLTRB(16, 6, 16, 4)` → `fromLTRB(16, 2, 16, 4)`.

### Unchanged
- The `chrome = 200.0` strip-cap estimate in `build` was left as-is; shrinking the real
  chrome only makes that over-estimate more conservative, so there is no overflow risk.
- Dialpad keys, call button, and all behavior/logic untouched.

## Verification
- `flutter analyze lib/screens/dialer_screen.dart` → No issues found.
