# Fill five more gaps in features.md found by a fresh code cross-check

**Status:** completed

## Files to change

- `docs/features.md` only.

## The issue

A fresh, thorough comparison of `docs/features.md` against the current code (screens,
services, repositories, native Kotlin) found five things the doc misses or gets wrong.
I confirmed each one by reading the actual source file. This is separate from, and in
addition to, the earlier intro-paragraph fix already applied to this file.

1. **Tag rename/merge/delete is missing.** `lib/widgets/tag_actions_sheet.dart`
   implements renaming a tag, merging it into another tag, and deleting an empty tag,
   reachable by long-pressing a chip in the Tag Cloud or from the per-tag contact
   list's app-bar menu. Section 1 ("Tags") only mentions "add/remove contacts from a
   tag" — no rename, merge, or delete.

2. **"Suggested member" hints when building a group/tag are missing.**
   `lib/utils/affiliation_key.dart` and `lib/widgets/contact_multi_picker_sheet.dart`
   suggest contacts who share a house name (from their address) or an employer (from
   their organization) when the user is picking members for a group or tag. Not
   mentioned anywhere in section 1.

3. **The in-call backdrop has a third fallback step that's missing.**
   `lib/theme/caller_backdrop.dart` shows the full fallback order is: calling-card
   photo → profile photo → a gradient chosen by the caller's relationship (warm for
   family, cool/flat for work) → plain brand gradient. Section 2 mentions only the
   calling-card photo as the in-call background, not the relationship-based gradient
   step in between.

4. **The emergency card's P2P sync rule is an exception, and that exception isn't
   documented.** `lib/services/sync_bundle_service.dart` states the emergency card is
   the one exception to P2P's normal "add-only" rule: since it's a single record, not
   a list, it is only installed on the receiving phone if that phone has no card of
   its own — never overwriting an existing one. Section 6 lists what's excluded from
   P2P sync but doesn't call out this special install-if-absent rule for the
   emergency card.

5. **Section 8's claim about the emergency card's storage is imprecise.** It currently
   says the card's "content is stored as plain text outside the encrypted database by
   design." Checking `lib/repositories/emergency_info_repository.dart`: the full
   record always stays in the encrypted SQLCipher database. Only a **published
   subset** of the fields the user opted to show on the lock screen is mirrored to
   plain Android `SharedPreferences`, for lock-screen access without unlocking. The
   doc should say "full record: encrypted DB; opted-in mirror subset: plaintext, for
   lock-screen display" instead of implying the whole card is plaintext.

## The fix

Documentation-only edits to `docs/features.md`, no code changes:

- **Section 1 (Tags bullet):** add rename, merge, and delete.
- **Section 1 (Groups/Tags area):** add a short bullet on "suggested members" from a
  shared house name or employer when building a group or tag.
- **Section 2 (in-call background):** add the relationship-based gradient as the
  fallback step between calling-card photo and the plain brand gradient.
- **Section 6 (P2P sync exclusions):** add a sentence noting the emergency card is the
  one exception — install-if-absent, never overwrite.
- **Section 8 (emergency card storage):** rewrite the sentence to distinguish the
  full record (always in the encrypted DB) from the opted-in mirror subset (plaintext,
  lock-screen only).

No other part of the file changes.
