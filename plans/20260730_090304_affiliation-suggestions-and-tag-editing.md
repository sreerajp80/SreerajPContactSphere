# Household / company suggestions, plus full tag editing (rename, merge, delete, membership)

**Status:** completed

## Why this shape

Earlier idea was a separate "household" feature with its own tables. The better idea (user's)
is to **not** store households at all. Instead, use the address data we already have to
*suggest* members while the user is adding contacts to a group or a tag.

This removes the hard part of the earlier design. There is no saved grouping to go stale, and
no need for an override system, because the group or tag **is** the saved result and the user's
tap **is** the correction. A wrong suggestion costs nothing — it is just not accepted.

## The issues

1. **Adding contacts to a group is all manual.** `_addContactsToGroup` in
   [groups_screen.dart:168](../lib/screens/groups_screen.dart#L168) loads every contact into a
   flat checkbox list. To build a "Nair family" group the user must remember and find each
   member by name, even though the app already knows four contacts share a house name.
2. **`house_name` and `company_name` are dead data.** They are stored
   ([database_helper.dart:172-173](../lib/database/database_helper.dart#L172-L173)), modelled in
   [address.dart](../lib/models/address.dart), and written by the contact editor, vCard import
   and device import — but nothing in the app ever reads them for any feature.
3. **A tag cannot be renamed.** Tags are written only by the full contact-save path
   (`_insertTags`, [contact_repository.dart:663](../lib/repositories/contact_repository.dart#L663)).
   Fixing a typo in a tag used by 20 contacts means editing 20 contacts.
4. **Related bug this exposes:** `getTagCounts` groups by exact `t.name`
   ([contact_repository.dart:1008](../lib/repositories/contact_repository.dart#L1008)) but
   `getContactSummariesByTag` matches with `LOWER(...)`
   ([contact_repository.dart:1052](../lib/repositories/contact_repository.dart#L1052)). So
   "Family" and "family" draw as two separate chips in the cloud, and tapping either shows the
   same contacts. Renaming must merge such rows rather than create more of them.
5. **Contacts cannot be added to or removed from a tag from the Tags screens.** Both
   [tag_cloud_screen.dart](../lib/screens/tag_cloud_screen.dart) and
   [tag_contacts_screen.dart](../lib/screens/tag_contacts_screen.dart) are read-only; the only
   way to tag or untag someone is to open that contact and edit them.
6. **Two tags that mean the same thing cannot be combined** without editing every contact that
   carries the wrong one.

## A note on deleting a tag

A tag is not an entity in this app — the `tags` table holds only per-contact rows
([database_helper.dart:326](../lib/database/database_helper.dart#L326)). So a tag with no
contacts has no rows, does not exist, and cannot be returned by `getTagCounts`. Removing the
last contact from a tag already makes it vanish from the cloud by itself.

"Delete only when empty" therefore cannot work as a literal condition — there would never be a
visible empty tag to delete. It is implemented instead as a **safety guard**: the delete action
is always shown, but stays disabled while the tag still has members, with a hint to remove them
first. This stops one stray tap from stripping a tag off twenty contacts. It only becomes usable
because part 5 below adds remove-from-tag, so the user can actually empty a tag from the tag
screen.

## Files to change

New:
- `lib/utils/affiliation_key.dart` — normalises a house or company name into a match key.
- `lib/widgets/contact_multi_picker_sheet.dart` — the multi-select picker, moved out of
  `groups_screen.dart` and given a suggestions section, so groups and tags share one widget.
- `test/affiliation_key_test.dart` — unit tests for the normaliser (no DB).
- `test/tag_editing_test.dart` — DB tests for rename / add-tag. Run on its own (see Testing).

Changed:
- `lib/repositories/contact_repository.dart` — add `getAffiliationPeers`, `retagAll`,
  `addTagToContacts`, `removeTagFromContacts`, `deleteEmptyTag`.
- `lib/services/contact_sync_service.dart` — thin pass-throughs for the new methods.
- `lib/screens/groups_screen.dart` — delete the private `_ContactMultiPickerSheet` (lines
  331-460) and use the shared widget.
- `lib/screens/tag_cloud_screen.dart` — long-press a chip for rename / merge / delete.
- `lib/screens/tag_contacts_screen.dart` — "Add contacts" button, remove-from-tag on a row, and
  rename / merge / delete in the app-bar menu.

## Plan

### 1. The match key (`lib/utils/affiliation_key.dart`)

One pure function, shaped like the existing [phone_normalizer.dart](../lib/utils/phone_normalizer.dart)
so it is testable without a DB:

```dart
String? affiliationKey(String? raw);   // null when unusable
```

Rules: trim, lowercase, strip punctuation, collapse repeated spaces. For companies also drop
trailing legal words (`ltd`, `limited`, `pvt`, `private`, `inc`, `co`, `company`) so
"Infosys Ltd" and "infosys" agree. Return `null` for blank input, for keys shorter than 3
characters, and for a small stop-list of generic values (`house`, `home`, `office`, `-`, `na`,
`n/a`) that would otherwise cluster unrelated people together.

House keys are paired with `post_office` (falling back to `city_town`) so the same common house
name in two different places does not merge. Company keys are matched on the company name
alone, since a company spans locations.

### 2. Finding peers (`contact_repository.dart`)

```dart
Future<List<AffiliationPeer>> getAffiliationPeers(
  Set<int> seedContactIds, { bool includeSecret = false });
```

`AffiliationPeer` carries `contactId`, `kind` (`house` or `company`) and `label` (the shared
house or company name, for display). Implementation: read the address rows for the seed
contacts, compute their keys in Dart (not SQL — the normalising is too involved for SQLite),
then query address rows for candidate contacts and keep those whose key matches. Excludes the
seeds themselves, respects the secret filter like the other queries here, and returns at most
~50 peers so a large company cannot flood the sheet.

Reading every address row is acceptable at this app's scale; if it ever isn't, the fix is a
stored key column, which this design leaves open.

### 3. Suggestions in the picker (`contact_multi_picker_sheet.dart`)

Move the existing sheet as-is, then add: whenever the checked set changes, ask for the peers of
the checked contacts and show them in a **"Suggested"** section pinned above the full list,
each row labelled with its reason — "Same house: Sreelakshmi" or "Same company: Infosys".
Suggestion rows are checkboxes like any other, so accepting one is a tap and ignoring it is
free. Suggestions are hidden while a search query is active, and never include contacts already
in the group or tag.

The sheet takes a title and an `alreadyIn` set (as today), so it serves both "Add to group X"
and "Add to tag #y" with no branching.

### 4. Tag writes (`contact_repository.dart`)

```dart
Future<int> retagAll(String from, String to);                    // rows moved
Future<int> addTagToContacts(String tag, Set<int> contactIds);
Future<int> removeTagFromContacts(String tag, Set<int> contactIds);
Future<bool> deleteEmptyTag(String tag);                         // false if still in use
```

All run in a transaction, and all match tag names **case-insensitively**, matching how
`getContactSummariesByTag` already behaves.

**Rename and merge are the same operation.** `retagAll('familly', 'family')` moves every row
from the old name to the new one. If nothing already uses the target name, the user experiences
that as a rename; if something does, they experience it as a merge. One method, so there is no
second code path to keep correct. It must delete duplicate `(contact_id, name)` rows the move
creates — a contact carrying both `familly` and `family` ends up with one row, not two — because
`tags` has no unique constraint
([database_helper.dart:326](../lib/database/database_helper.dart#L326)). This is also what
cleans up the existing "Family"/"family" split from issue 4. A blank target is rejected in the
repository, not only in the UI.

`removeTagFromContacts` deletes the matching rows for the given contacts. `deleteEmptyTag`
re-checks the count inside the transaction and returns `false` without deleting if the tag is
still carried by anyone — so the UI guard cannot be defeated by a stale count from before some
other screen added a contact.

No schema change and no migration.

### 5. Tag UI

**Tag cloud** — long-press a chip opens a bottom sheet with:
- *Rename* — text field pre-filled with the current name. If the typed name matches an existing
  tag, the confirm button changes to "Merge into #existing" with a note that both tags become
  one, so a merge is never a surprise.
- *Merge into…* — pick another existing tag from a list. Same `retagAll` call, confirmed with
  how many contacts will move.
- *Delete* — disabled whenever the tag has members, with the hint "Remove its contacts first
  (N contacts)". Enabled only at zero, per the reasoning above.

Counts reload after any of the three.

**Tag contacts screen**
- "Add contacts" FAB, opening the shared picker with `alreadyIn` set to the current members — so
  the household/company suggestions work for tags exactly as they do for groups.
- Remove-from-tag on each row (trailing button, confirmed), which is what lets a tag be emptied
  and then deleted.
- App-bar menu carrying the same rename / merge / delete actions, with the title updating after
  a rename and the screen popping after a successful delete or a merge (its tag no longer
  exists).

## Testing

- `flutter analyze` clean.
- `flutter test test/affiliation_key_test.dart` — keys, the stop-list, the legal-suffix
  stripping, the house+post-office pairing.
- `flutter test test/tag_editing_test.dart` — rename onto an unused name; merge onto a used name;
  a contact carrying both tags collapsing to one row; blank-target rejection; add-tag skipping
  existing carriers; remove-from-tag; `deleteEmptyTag` refusing while members remain and
  succeeding at zero.
- These two run in separate `flutter test` invocations, because sqlite-backed tests crash when
  more than one DB-using file runs in a single invocation.
- On-device check: build a group from one family member and confirm the rest are suggested;
  merge two tags and confirm the cloud shows one chip with the combined count; empty a tag from
  its screen and confirm delete becomes available.

## Not included

- Deleting a tag that still has contacts (deliberately blocked — see the note above).
- Bulk-selecting several tags to merge at once. Merge is one source into one target.
- Any stored household table. If the suggestions prove useful and slow, that is the follow-up.
- Suggestions from `official_details.department`
  ([database_helper.dart:264](../lib/database/database_helper.dart#L264)) — department is
  meaningless without a company, so it would need company matching to land first.

## Open question (does not block)

Nothing in the app reads `house_name`/`company_name` today, so how well-filled those columns are
in the real database is unknown. If almost no contact has them, the suggestions will be quiet
and only part 1-3 of this plan is wasted effort. Worth one count query against the live DB
before or right after building the normaliser.
