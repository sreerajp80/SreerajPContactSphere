# Per-SIM colours + visible SIM name on the call screen

Implements [plans/20260704_194611_per-sim-colors-call-screen.md](../plans/20260704_194611_per-sim-colors-call-screen.md).

## What changed

1. **lib/theme/app_theme.dart**
   - Added `AppTheme.simColorChoices` — a 10-colour preset palette, all bright enough to
     read on the dark in-call SIM chip.
   - Added `AppTheme.defaultSimColor(int? slotIndex)` — slot-cycled default so dual SIMs
     are distinct out of the box (SIM 1 light blue `0xFF4FC3F7`, SIM 2 orange `0xFFFFB74D`).

2. **lib/state/app_settings.dart**
   - New pref `per_sim_colors` (JSON map `phoneAccountId → ARGB int`), following the
     existing `per_sim_ringtones` pattern: `_perSimColors` field loaded in `load()`,
     `perSimColors` / `colorForSim()` getters, `setSimColor()` setter (null clears back
     to the slot default), `_encodeSimColors` / `_decodeSimColors` codecs.
   - Static `readSimColor(phoneAccountId)` for the call flow (mirrors `readSimRingtone`,
     usable before `load()` on a cold-start incoming call).

3. **lib/services/sim_service.dart**
   - Added `accountFor(phoneAccountId)` returning the full `SimAccount` (the in-call
     screen needs `slotIndex` for the default colour), alongside the existing `labelFor`.

4. **lib/screens/in_call_screen.dart**
   - `_resolveSim` now resolves label + colour in one pass: user pick via
     `AppSettings.readSimColor`, else `AppTheme.defaultSimColor(slotIndex)`.
   - `_simChip` restyled for visibility: solid dark pill (`black` @ 45%) with a subtle
     border in the SIM colour, icon + SIM name in the SIM colour at `w700` / 13.5 —
     replaces the old 14%-foreground pill that vanished over light photo backdrops.

5. **lib/screens/sim_settings_screen.dart**
   - New "SIM colours" card (when SIMs exist): one row per SIM with a colour swatch and
     the SIM name tinted in its colour; the subtitle notes when the default colour is in
     use. Tapping opens a bottom sheet with the preset palette (checkmark on the current
     pick) plus a "Use default" action. Persists via `AppSettings.setSimColor`.

## Verification

- `flutter analyze`: **No issues found.**
- `flutter test`: 46 pass; 1 pre-existing failure in `test/widget_test.dart` (expects
  the Material `NavigationBar`, which `HomeShell` had already replaced with a custom bar
  before this change — stale test, unrelated; not fixed here as it's outside the plan).
- Manual on-device verification (call on each SIM over photo/gradient backdrops) still
  pending — requires a dual-SIM device.
