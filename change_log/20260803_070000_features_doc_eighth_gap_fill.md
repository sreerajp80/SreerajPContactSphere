# Change log: eighth gap-fill pass on docs/features.md

Implements `plans/20260803_070000_features_doc_eighth_gap_fill.md`.

## What changed

Ran a fresh, independent audit of `docs/features.md` against the codebase
(all `lib/` screens, services, models, native Kotlin files, and
`AndroidManifest.xml`), plus a specific re-check of the "What this app is"
intro paragraph for completeness. No missing feature was found — this is
the eighth pass today, and the doc is already thorough.

Made two small precision additions (mechanism detail, not new features):

1. Section 4, Bluetooth bullet: noted that BLE scanning requires location
   permission on older Android versions, so a location prompt can appear.
2. Section 2, Quick replies bullet: noted it sends silently via the
   system's "reject call with message" API (no SMS app, no `SEND_SMS`
   permission), distinguishing it from Smart Redial's "Reach Me" message,
   which opens the phone's own SMS app.

No other content changed. No code changes; documentation only.
