# Change log: five more gaps fixed in features.md

Implements: `plans/20260803_010000_features_doc_second_gap_fill.md`

## What changed

Five documentation-only edits to `docs/features.md`:

1. Section 1 (Tags): added rename/merge/delete a tag, and that delete is blocked
   while the tag has members.
2. Section 1 (near duplicate detection): added "suggested member" hints (shared
   house name or employer) when building a group or tag.
3. Section 2 (default dialer bullet): added the full in-call background fallback
   order, including the relationship-based gradient step between the calling-card
   photo and the plain brand gradient.
4. Section 6 (P2P sync exclusions): added that the emergency card is the one
   exception to "add-only" — it installs only if the receiver has no card yet,
   never overwriting.
5. Section 8 (emergency card): corrected the storage claim. The full record always
   stays in the encrypted database; only an opted-in subset mirrors to plain
   storage for lock-screen display — it is not that the whole card is plaintext.

## Why

A fresh cross-check of `docs/features.md` against the code (screens, services,
repositories) found these five items either missing or stated imprecisely. Each
was confirmed by reading the relevant source file (`tag_actions_sheet.dart`,
`affiliation_key.dart`, `caller_backdrop.dart`, `sync_bundle_service.dart`,
`emergency_info_repository.dart`) before editing the doc.

## Not changed

No code changes. This is separate from the earlier intro-paragraph fix
(`plans/20260803_000000_features_doc_intro_gap_fill.md`), which is already applied.
