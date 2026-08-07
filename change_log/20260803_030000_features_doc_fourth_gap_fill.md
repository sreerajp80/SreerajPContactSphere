# Change log: fourth gap-fill pass on docs/features.md

Implements `plans/20260803_030000_features_doc_fourth_gap_fill.md`.

## What changed

Two small edits to `docs/features.md`, found by a fresh critical re-check
after three earlier gap-fill passes today:

1. **Section 1, Audit log bullet** — added that entries for secret contacts
   are hidden by default and only revealed after a biometric/PIN check via a
   lock icon in the app bar, and that the signed export respects the same
   show/hide state (`lib/screens/audit_log_screen.dart`).

2. **"Known gaps" section intro sentence** — fixed a wrong citation. It
   claimed all six bullets below it are documented as missing in
   `docs/known-gaps.md`, but three of them (release build hardening,
   in-app "delete all data", iOS/other platforms) are not in that file —
   the first two are actually in `docs/security.md`. Reworded to cite both
   docs.

No code changes; documentation only.
