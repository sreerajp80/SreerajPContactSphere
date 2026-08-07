# Change log — Fix inaccurate "state management" claim

Implements: `plans/20260802_151349_features_doc_state_mgmt_fix.md`

## What changed

- `docs/features.md` — corrected the "General app state management" bullet
  under "Known gaps / not yet implemented". It previously said `provider` is
  wired up "only for theme mode and accent color." Corrected to say
  `AppSettings` (`lib/state/app_settings.dart`) is an app-wide `ChangeNotifier`
  covering around 27 persisted settings (ringtone, SIM, dialer, security
  toggles, and more), not just theme/accent. Kept the real gap: individual
  screens (contacts list, detail, etc.) still use local `setState` for their
  own UI state.
- `docs/known-gaps.md` — same correction to the matching "State management"
  bullet under "Architectural notes", since `features.md` was paraphrasing
  this file and the error originated here.

No code files were touched.

## Why

A fresh critical review (requested by the user) compared `docs/features.md`
against the actual code — every screen, every service, native Kotlin code,
and the manifest. The document held up well overall: no missing features, no
missing screens, and the opening "What this app is" description already
fairly represents the depth of the file (an earlier review round had already
fixed that). One factual error remained: the claim that `provider` is only
used for theme mode and accent color. In fact `AppSettings` is a single
app-wide `ChangeNotifier` backing roughly 27 different settings. Left
uncorrected, this could mislead a developer into thinking they'd need to
re-plumb settings state that already exists.
