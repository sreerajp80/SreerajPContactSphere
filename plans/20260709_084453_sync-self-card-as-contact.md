# Plan: Sync the sender's Self card to the other phone (as a normal contact)

**Status:** completed

## The issue

During P2P sync, the sender's own "Self" / "YOU" card never appears on the other
phone. It is **not a UI problem** — the card is never written into the receiver's
database at all.

The receiver's merge loop skips it on purpose. In
[lib/services/sync_bundle_service.dart](../lib/services/sync_bundle_service.dart),
inside `applyBundle` (step 4, the add/skip decision):

```dart
// Never merge the sender's owner ("Self") card — the receiver keeps its
// own identity. ...
if (_asInt(raw['is_self']) == 1) continue;
```

So the row is dropped before any insert. (The card *is* present in the sent
bundle — `exportBundle` queries all `contacts` rows — the drop only happens on
the receiving side.)

The user wants their Self card to transfer to the other phone.

## The design point (why not just delete the `continue`)

On the receiver there can be only one Self card — it is the phone owner's own
identity, fetched separately via `getSelfSummary()` (`WHERE is_self = 1`) and
pinned to the top of the list. If we merged the incoming card with `is_self = 1`
still set, the receiver would end up with **two** owner cards, breaking the
"singleton self" assumption and the pinned-self UI, and effectively hijacking
their identity.

**Fix approach:** on a **Full Sync**, add the incoming Self card but store it as
an **ordinary contact** on the receiver — force `is_self = 0`. The receiver keeps
its own Self card; the sender simply shows up as a normal contact (which is what
"sync my card to your phone" should mean). On a **selective/incremental** sync
the owner card is still skipped, so it only travels when the user chooses Full
Sync.

## Files to change

1. `lib/services/sync_bundle_service.dart` — the only code change.
2. `plans/` / `change_log/` — this plan and its change log (workflow rule).

Tests to update/add:

3. `test/*` — a merge test that a sender's Self card is added on the receiver as
   a non-self contact (see "Tests" below for the exact file).

## The plan for the fix

In `sync_bundle_service.dart`, `applyBundle`, the contacts loop (currently
around lines 356–387):

1. **Gate the skip on sync mode.** `applyBundle` already computes
   `final fullMode = meta['mode'] == 'full';`. Change the unconditional skip to
   only skip the owner card on a **selective (incremental)** sync:

   ```dart
   // On a selective sync, keep skipping the sender's owner card. On a Full
   // Sync, let it through and store it as a normal contact (below).
   if (_asInt(raw['is_self']) == 1 && !fullMode) continue;
   ```

   On a Full Sync the incoming owner card then goes through the normal add/skip
   decision (name + shared-phone duplicate check), so if the receiver already
   has this person as a contact it is merged, not duplicated.

2. **Force `is_self = 0`** on the inserted row, right where the row is built for
   insert (alongside the existing `device_id = null`, photo-path resolve, and
   `ringtone_path = null` overrides):

   ```dart
   final row = Map<String, Object?>.from(raw)
     ..remove('id')
     ..['is_self'] = 0            // sender's owner card lands as a normal contact
     ..['device_id'] = null
     ..['photo_path'] = _resolveMedia(raw['photo_path'], refToPath)
     ..['card_photo_path'] = _resolveMedia(raw['card_photo_path'], refToPath)
     ..['ringtone_path'] = null;
   ```

   This is safe for the ordinary contacts too — their `is_self` is already 0, so
   forcing 0 is a no-op for them and only matters for the incoming Self card.

3. **Update the guiding comment** (the "Never merge the sender's owner card"
   block) to describe the new behavior: the owner card is merged as a normal
   contact so it does not overwrite the receiver's own identity.

### Knock-on effects (reviewed, no extra code needed)

- **Its children follow it.** The Self card's phone numbers, emails, etc. are in
  the bundle keyed by the sender's self contact id. Because the card is now in
  `addedSenderIds`, step 5 (`_perContactChildTables`) inserts them with the
  remapped `contact_id`, exactly like any other new contact. Its phones also feed
  the natural-key match, so a receiver that already has this person is correctly
  detected as a duplicate and skipped.
- **Counts.** The added card now counts in `SyncSummary.contactsAdded`
  (or `contactsSkipped` if it was a duplicate) — which is the correct, visible
  outcome on the completion screen.
- **Relationships.** Sender relationships that point at the sender's self id will
  now resolve (the endpoint exists on the receiver) and be added. This is
  harmless and arguably desirable; no change required.
- **Photo / calling card.** Already staged on export and resolved on import via
  the generic media path — nothing special for the Self card.
- **Protocol / schema.** No wire-format change; both phones stay on the same
  `_protocol`. No migration needed.

## Tests

Add/adjust a `SyncBundleService` merge test (the existing bundle/merge tests
live in the `test/` folder — I will place it next to them, e.g.
`test/sync_bundle_service_test.dart`, creating it if it does not exist):

- Build a bundle whose `contacts` table contains a row with `is_self = 1` plus a
  phone number.
- Apply it with **`mode: 'full'`** to an empty receiver DB. Assert the contact
  **exists** on the receiver, stored with `is_self = 0` (so `getSelfSummary()`
  still returns null / the receiver's own self is untouched), and its phone
  number came across.
- Apply the **same bundle with `mode: 'incremental'`** to an empty receiver DB
  and assert the owner card is **not** added (still skipped on selective sync).
- Apply the full-mode bundle to a receiver that already has that person (same
  name + shared phone) and assert the result is **skipped**, not a duplicate.

## Verification

- `flutter test` for the sync bundle test (run the single sqlite-backed file on
  its own, per the known native-assets test constraint).
- `flutter analyze` clean for the touched file.
- Manual: two devices, send Full Sync from A to B, confirm A's "YOU" card now
  appears in B's list as a normal contact and B's own "YOU" card is unchanged.
