# Change log: sixth gap-fill pass on docs/features.md

Implements `plans/20260803_050000_features_doc_sixth_gap_fill.md`.

## What changed

A fresh, independent cross-check of the codebase against `docs/features.md`
(screens, services, `app_settings.dart`, widgets, models, repositories, and
native Kotlin code) found the doc largely accurate after five earlier
gap-fill passes today, with two small gaps left:

1. **Intro paragraph** — added ephemeral (self-destructing) contacts to the
   "What this app is" summary, alongside the other security/privacy features
   already named there (app lock, secret contacts, emergency-info card,
   audit log). The feature was already fully documented in section 1 but was
   missing from the top-level description a first-time reader sees first.

2. **Section 12 known-gaps note** — corrected "around 27 persisted settings"
   to "around 30 persisted settings," matching the current count of
   `static const String _k...` keys in `lib/state/app_settings.dart`
   (excluding two legacy/migration-only keys). The old figure was stale from
   before the Smart Redial toggle/delay/message and screenshot-guard
   settings were added earlier today.

No other gaps were found — screens, services, native Kotlin classes, models,
and the Known Gaps / Roadmap sections all still matched the code.

No code changes; documentation only.
