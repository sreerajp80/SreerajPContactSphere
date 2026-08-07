# Change log — Settings-section gaps in docs/features.md

Implements: `plans/20260802_151621_features_doc_settings_gaps.md`

## What changed

Edited `docs/features.md` only. No code files were touched.

- **Section 2 (Dialer / calling), Recents bullet:** reworded the call-log
  import mention to say it can run as either a merge (add/update only) or a
  destructive "replace" that clears the app's call history first — both
  modes exist in `contact_sync_settings_screen.dart`, only the merge mode
  was previously mentioned.
- **Section 12 (Settings screen), top-level list:** reworded "About (app
  version)" to say it shows version and build number plus other
  config-driven app details (e.g. author/email), matching what
  `about_screen.dart` actually renders.
- **Section 12, "Contacts settings" subsection:** added three bullets for
  cards that exist in `contacts_settings_screen.dart` but weren't listed
  here: "Sync" (opens the dedicated device-contact merge/mirror + call-log
  import screen), "Blocked numbers", and "Relationship names" — the latter
  two were already described as features elsewhere in the doc, but their
  Settings location was missing.

## Why

A fresh critical review compared the doc directly against the running
settings screens (`contacts_settings_screen.dart`,
`contact_sync_settings_screen.dart`, `sim_settings_screen.dart`,
`about_screen.dart`) rather than trusting the doc's own earlier
self-review. The doc's "Settings screen" section is meant to be the map of
what's reachable from where, but it omitted three real cards and
undersold two existing features (call-log replace mode, About screen
contents).
