# Change log: tenth gap-fill pass on docs/features.md

Implements: `plans/20260805_000000_features_doc_tenth_gap_fill.md`

## What changed

Made two small additions to `docs/features.md`, section 1 ("Contacts
management"), no other content changed:

1. The "Add/edit contact" bullet now lists "salutation" as a field, next to
   name and formal name.
2. The "Contact list" bullet now describes multi-select: long-press a row
   to enter selection mode, a "select all visible" toggle, and bulk delete
   with a confirmation prompt and a deleted/failed count summary.

## Why

A fresh, independent 10th audit (re-checked every screen, service, setting,
manifest entry, and native Kotlin file against the doc) found these two
real, user-facing features in code with no mention anywhere in the doc:
multi-select/bulk-delete in `lib/screens/contact_list_screen.dart`, and the
persisted `salutation` field on `Contact` (used on the Add/Edit screen and
in vCard export/import). No doc claim was found to lack matching code, and
the intro paragraph and all other sections were confirmed accurate, so no
other change was made.
