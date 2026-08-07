# Plan: fifth gap-fill pass on docs/features.md

**Status:** completed

## Issue

`docs/features.md` is meant to be a complete, accurate feature reference. It
has already had five gap-fill passes today. I did a fresh, thorough
cross-check of the whole codebase (every screen, every service,
`app_settings.dart`, native Kotlin classes, models, repositories, and the
intro paragraph) against the doc.

One real gap was found: Smart Redial has a master on/off switch that the doc
never mentions.

- `lib/state/app_settings.dart` — `_smartRedialEnabled` (default `true`),
  `smartRedialEnabled` getter, `setSmartRedialEnabled()`.
- `lib/widgets/call_lifecycle_mixin.dart` — the post-call Smart Redial sheet
  is only offered `if (unanswered && smartRedialEnabled && mounted)`.
- `lib/screens/sim_settings_screen.dart` — a `SwitchListTile` titled
  `'Smart Redial & "Reach Me"'`; the delay and message sub-rows only show
  when the switch is on.

Everything else in the doc (intro paragraph, all 13 numbered sections, known
gaps, roadmap) matched the code — no other omissions or wrong claims found.

## Files to change

- `docs/features.md`

## Fix

1. Section 2 (Dialer / calling), Smart Redial bullet: add that the whole
   feature can be turned off entirely (on by default); when off, no
   post-call sheet is shown at all.
2. Section 12 (Settings screen), SIM & calling settings list: change
   "Smart Redial delay and 'Reach Me' message" to mention the on/off toggle
   as well as the delay and message.

No other changes. Then write a change log referencing this plan.
