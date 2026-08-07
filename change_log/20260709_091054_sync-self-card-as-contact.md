# Change log: Sync the sender's Self card on a Full Sync

Implements plan
[plans/20260709_084453_sync-self-card-as-contact.md](../plans/20260709_084453_sync-self-card-as-contact.md).

## Problem

During P2P sync the sender's own "Self" / "YOU" card never reached the other
phone. It was not a UI issue — the receiver's merge dropped the card before any
insert (`if (_asInt(raw['is_self']) == 1) continue;` in `applyBundle`), so it was
never written into the client database.

## What changed

`lib/services/sync_bundle_service.dart` — `applyBundle`, the contacts add/skip
loop:

1. The unconditional Self-card skip is now gated on sync mode:
   `if (_asInt(raw['is_self']) == 1 && !fullMode) continue;`. The owner card is
   still skipped on a selective (incremental) sync, but on a **Full Sync** it is
   allowed through.
2. The inserted contact row now forces `..['is_self'] = 0`, so the incoming
   owner card lands on the receiver as an **ordinary contact**. This keeps the
   receiver's own Self card as the single owner (no identity hijack), and is a
   no-op for ordinary contacts (whose `is_self` is already 0).
3. Updated the guiding comments to describe the new behavior.

No wire-format, protocol, or schema change. The card's phone numbers, emails and
other children follow it automatically (it now joins `addedSenderIds`), it counts
in `SyncSummary.contactsAdded`, and a receiver that already has that person still
de-dupes by name + shared phone.

## Tests

`test/p2p_bundle_test.dart`:

- `seedSender()` now also inserts a Self card ("Me", `is_self = 1`) with a phone
  number. Existing incremental tests are unaffected (the card stays skipped in
  incremental mode).
- New: **Full Sync adds the sender Self card as a normal contact** — asserts "Me"
  exists with `is_self = 0`, its phone travelled, and the receiver's own Self
  card ("Owner") remains the only `is_self = 1` row.
- New: **selective sync does not add the Self card** — asserts "Me" is absent and
  no Self card leaked onto the receiver.

## Verification

- `flutter test test/p2p_bundle_test.dart` — all 9 tests pass (run on its own per
  the known sqlite native-assets test constraint).
- `flutter analyze lib/services/sync_bundle_service.dart test/p2p_bundle_test.dart`
  — no issues found.
