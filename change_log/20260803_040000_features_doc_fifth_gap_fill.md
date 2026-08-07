# Change log: fifth gap-fill pass on docs/features.md

Implements `plans/20260803_040000_features_doc_fifth_gap_fill.md`.

## What changed

A thorough cross-check of the whole codebase (every screen, every service,
`app_settings.dart`, native Kotlin classes, models, repositories, and the
intro paragraph) against `docs/features.md` found one real gap: Smart
Redial has a master on/off switch that the doc never mentioned.

Two edits to `docs/features.md`:

1. **Section 2, Smart Redial bullet** — added that the whole feature has a
   master on/off switch (on by default, in SIM & calling settings); when
   off, no post-call Smart Redial sheet is shown at all
   (`lib/state/app_settings.dart` — `smartRedialEnabled`;
   `lib/widgets/call_lifecycle_mixin.dart` gates the sheet on it;
   `lib/screens/sim_settings_screen.dart` has the `SwitchListTile`).

2. **Section 12, SIM & calling settings list** — changed "Smart Redial
   delay and 'Reach Me' message" to "a Smart Redial on/off toggle (on by
   default), delay, and 'Reach Me' message".

No other gaps or inaccuracies were found in this pass — the intro
paragraph, all 13 numbered sections, known gaps, and roadmap all matched
the current code.

No code changes; documentation only.
