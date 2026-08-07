# Household / company suggestions, and full tag editing

Implements [plans/20260730_090304_affiliation-suggestions-and-tag-editing.md](../plans/20260730_090304_affiliation-suggestions-and-tag-editing.md).

## What this adds

**1. Suggested members when building a group or tag.** When you add contacts to a group or a
tag, the picker now shows a "Suggested" section above the full list: people who share a house
name or an employer with whoever you have already ticked, each labelled with the reason ("Same
house: Sreelakshmi", "Same company: Infosys"). Nothing is saved automatically — a suggestion is
just a pre-found row you can tick or ignore.

This is the first feature to read the `house_name` and `company_name` address columns, which
until now were written by the contact editor, vCard import and device import but never used.

No household is stored anywhere. The group or tag is the saved result, and accepting or ignoring
a suggestion is the only correction needed, so there is nothing to go stale and no override
system to maintain.

**2. Tags can now be renamed, merged and deleted**, and their membership edited, without opening
each contact one at a time.

## Files changed

New:
- `lib/utils/affiliation_key.dart` — folds free-text house and company names into comparable
  keys. Lowercases, strips punctuation, collapses spaces, and drops trailing noise words:
  company suffixes (`Ltd`, `Pvt`, `Limited`, …) and Kerala house markers (`(H)`, `House`), so
  "Sreelakshmi (H)" and "sreelakshmi" agree. Ignores blanks, keys under 3 characters, and generic
  values (`house`, `home`, `office`, `n/a`, …) that would otherwise cluster strangers together.
  House keys are paired with the post office (falling back to city/town); company keys are not,
  since one employer spans locations.
- `lib/widgets/contact_multi_picker_sheet.dart` — the multi-select contact picker, lifted out of
  `groups_screen.dart` and given the suggestions section, so groups and tags share one widget.
- `lib/widgets/tag_actions_sheet.dart` — rename / merge / delete for one tag, shared by both tag
  screens.
- `test/affiliation_key_test.dart`, `test/affiliation_peers_test.dart`, `test/tag_editing_test.dart`.

Changed:
- `lib/repositories/contact_repository.dart` — added `getAffiliationPeers` (plus the
  `AffiliationPeer` / `AffiliationKind` types), `retagAll`, `addTagToContacts`,
  `removeTagFromContacts`, `deleteEmptyTag`.
- `lib/services/contact_sync_service.dart` — pass-throughs for the above.
- `lib/screens/groups_screen.dart` — uses the shared picker; the private
  `_ContactMultiPickerSheet` is gone.
- `lib/screens/tag_cloud_screen.dart` — long-press a chip for rename / merge / delete, plus a
  one-line hint, since long-press has no visible affordance otherwise.
- `lib/screens/tag_contacts_screen.dart` — "Add contacts" button, a remove-tag button per row,
  and a rename / merge / delete menu in the app bar.

**No schema change and no migration.**

## Decisions worth knowing

**Rename and merge are one database operation.** `retagAll(from, to)` moves every carrier of one
tag onto another name. When nothing uses the target it reads as a rename; when something does it
reads as a merge. One code path, so the two cannot drift apart. The rename dialog notices when
the typed name already exists and switches its button to "Merge into #existing", so combining two
tags is never accidental.

Because the `tags` table has no unique constraint, a contact carrying *both* names would end up
with two identical rows after a merge, so `retagAll` collapses duplicates itself. It also
normalises the surviving rows' spelling, which cleans up an existing quirk: the tag cloud groups
by exact name while the per-tag list matches case-insensitively, so "Family" and "family" drew as
two chips that opened the same contacts. A rename or merge now collapses them into one.

**Deleting a tag is blocked while it has members.** A tag is not a row of its own — it exists
only as the tag rows on contacts — so a tag with no contacts does not exist and cannot appear in
the cloud. "Delete only when empty" is therefore implemented as a guard rather than a literal
condition: the action is always visible but disabled while members remain, with the hint "Remove
its contacts first (N)". That is why the per-row remove was added — without it there was no way to
empty a tag except editing every contact. `deleteEmptyTag` re-checks the count inside its
transaction, so a contact tagged elsewhere a moment earlier cannot be silently stripped by a
stale count in the UI.

**Peer matching happens in Dart, not SQL.** Folding "Infosys Ltd" and "INFOSYS" onto one key is
past what SQLite can express, so address rows are read and keyed in Dart. Fine at this app's
scale; if it ever isn't, the fix is a stored key column and no API change. Suggestions are capped
at 50 so a large employer cannot bury the picker, ordered house-matches first (a household is a
stronger signal than a shared employer), and respect the secret-contact filter like every other
query here.

## Testing

- `flutter analyze` — no issues.
- `flutter test test/affiliation_key_test.dart` — 10 tests pass (folding, the generic-value
  stop-list, suffix stripping, house+locality pairing, Malayalam script, house/company keys never
  colliding).
- `flutter test test/affiliation_peers_test.dart` — 8 tests pass (same house, colleagues across
  spellings, same house name in another town excluded, generic values not clustering, seeds not
  suggesting themselves, house-before-company ordering, secret filter).
- `flutter test test/tag_editing_test.dart` — 16 tests pass (rename, case-only rename,
  case-insensitive source match, merge, a contact holding both tags collapsing to one row, an
  existing case-split collapsing, add skipping existing carriers, remove leaving other tags
  alone, the delete guard in both states, blank-name rejection).
- Existing suites re-run and still green: `group_ringtone_test.dart`,
  `contact_sync_service_test.dart`, `features_screen_test.dart`.
- These run in separate `flutter test` invocations, because sqlite-backed tests crash when more
  than one DB-using file runs in a single invocation.

One test failure during development was a genuine code gap, not a bad test: "Sreelakshmi (H)" did
not match "Sreelakshmi", because the `(H)` for *House* was left as a stray "h" token. Fixed in
`affiliation_key.dart` by stripping trailing house markers.

## Not done

- **Not verified on a device.** All checks above are host tests. The suggestion quality depends
  on real address data (see below).
- Deleting a tag that still has contacts — deliberately blocked.
- Bulk-selecting several tags to merge at once; merge is one source into one target.
- Suggestions from `official_details.department`, which is meaningless without company matching
  in place first.

## Open item

How well-filled `house_name` and `company_name` are in the real database is still unknown — no
feature read them before this one, and the DB is SQLCipher-encrypted so it cannot be inspected
from the desktop. If few contacts have those fields, the "Suggested" section will simply stay
empty and everything else here still works. Worth watching on-device before investing further in
the matching rules.
