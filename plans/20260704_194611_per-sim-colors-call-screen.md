# Per-SIM colours + visible SIM name on the call screen

**Status:** completed

## Issue

On the in-call screen the SIM chip ([in_call_screen.dart:361](../lib/screens/in_call_screen.dart#L361))
is drawn as `fg.withValues(alpha: 0.14)` — i.e. 14% white over the caller photo. Over a light
backdrop (see the screenshot: pale saree) the pill and the "Jio" text are nearly invisible.

Requested:
1. Make the SIM name properly visible on the calling screen.
2. Give each SIM its own colour; show the SIM name in that colour.
3. Let the user choose the colour per SIM in **Settings → SIM & calling**.

## Design

- **Default colours per slot** so dual-SIM users get distinct colours out of the box:
  SIM 1 → light blue `0xFF4FC3F7`, SIM 2 → orange `0xFFFFB74D` (both legible on a dark pill),
  further slots cycle a small palette. User's picked colour overrides the default.
- **Storage**: a JSON map `phoneAccountId → ARGB int` in shared_preferences
  (`per_sim_colors`), same pattern as the existing `per_sim_ringtones` map.
- **Visibility fix** (independent of colour): the chip stops using 14% foreground and instead
  always sits on a solid dark scrim pill (`Colors.black` @ ~45% over photo, slightly less over
  the gradient), with the SIM icon + name rendered in the SIM's colour at w700. This reads on
  both light photos and the brand gradient.

## Files to change

1. **lib/theme/app_theme.dart**
   - Add `simColorChoices` (a small preset palette, ~10 colours chosen to read on the dark
     chip) and `defaultSimColor(int? slotIndex)` (slot-cycled default).

2. **lib/state/app_settings.dart**
   - New pref key `per_sim_colors`; field, `perSimColors` getter, `colorForSim(String?)`,
     `setSimColor(String phoneAccountId, Color? color)` (null clears → default), encode/decode
     helpers, loading in `load()`.
   - Static `readSimColor(String? phoneAccountId)` for the call flow (InCallScreen doesn't use
     Provider and may run before `load()` — mirrors `readSimRingtone`).

3. **lib/services/sim_service.dart**
   - Add `accountFor(String? phoneAccountId)` returning the full `SimAccount` (so the in-call
     screen can get `slotIndex` for the default colour). `labelFor` stays.

4. **lib/screens/in_call_screen.dart**
   - `_resolveSim` also resolves the SIM colour: user pick via `AppSettings.readSimColor`,
     else `AppTheme.defaultSimColor(slotIndex)`.
   - Restyle `_simChip`: solid dark pill, icon + label in the SIM colour, fontWeight 700,
     slightly larger text (13 → 13.5) — properly visible over any backdrop.

5. **lib/screens/sim_settings_screen.dart**
   - New "SIM colours" card (shown when SIMs exist), one row per SIM: colour swatch +
     SIM name (tinted in its colour) + subtitle. Tapping opens a bottom sheet with the
     preset palette plus a "Use default" option; selection persists via `setSimColor`.

## Out of scope

- Colouring SIM labels elsewhere (call history, SIM picker sheet) — call screen only, as asked.
- A full colour wheel — presets keep the sheet simple; can be added later if wanted.

## Test/verify

- `flutter analyze` (expected: only the pre-existing known-gaps errors, no new ones).
- Manual: set colours in Settings → SIM & calling, place/receive a call on each SIM, confirm
  the chip is legible over both a photo backdrop and the gradient.

## Change log

To be written to `change_log/` after implementation.
