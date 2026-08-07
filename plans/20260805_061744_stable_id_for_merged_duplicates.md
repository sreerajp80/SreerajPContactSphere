# Fix: merged duplicate contact keeps reappearing

**Status:** completed

## The problem

The user has merged the same duplicate contact
about 50 times. Every so often the same "Same name & number" duplicate group comes
back after a merge, even though the merge worked correctly at the time.

## What I found (verified on the connected device)

On the phone, this contact is really **one Android contact** made of two raw contacts:

- one from the app's own local account (no sync account, this is normal for
  contacts we sync back to the phone — see [[sync-to-device-local-account]])
- one from **WhatsApp**, which also keeps its own copy of the same phone number
  and pushes name/data updates into the Android contacts database on its own.

Android's contacts database periodically re-links and re-splits raw contacts
like these into a single "aggregate" contact. Each time it does that, it can
assign a **new internal ID** to the aggregate. We confirmed this aggregate was
last re-linked on 2026-07-31, just 5 days before this report — the timing lines
up with the recurring duplicates.

The app's merge code remembers "this phone-side contact was already merged" by
saving that internal Android ID (`lib/services/device_contact_service.dart:280`,
used in `lib/services/contact_sync_service.dart:669-775`). That ID is not
permanent. When Android reassigns it:

1. The app's saved "already merged" note no longer matches, so the safety
   check that's supposed to stop the duplicate from reappearing
   (`contact_sync_service.dart:723-729`) never applies.
2. The app then tries a fallback: match by phone number and check if the name
   is the same. But the fallback comparison
   (`contact_sync_service.dart:788-794`) requires the name text to match
   *exactly* (after simple case/space cleanup). "Dr. [name]" (with a
   period) and "Dr [name]" (without) don't match here.
3. Because neither check passes, the app treats the phone contact as brand
   new and adds it again — recreating the exact duplicate that was just
   merged.

## Files to change

- `lib/services/contact_sync_service.dart` — the sync logic that decides
  "already merged" vs. "brand new" (around lines 669-794).
- `lib/services/device_contact_service.dart` — where the Android contact ID
  is read and stored (around line 280).
- `lib/repositories/contact_repository.dart` — where merges are recorded
  (`mergeContacts`, around lines 2109-2238) and where device IDs for a
  contact are looked up (`deviceIdsForContacts`, around lines 1711-1721).
- Matching test file(s) under `test/` that cover merge/sync behaviour, so the
  fix has a regression test.

## The fix

1. **Stop relying only on the unstable Android contact ID to remember "this
   was already merged."** Instead, also record the phone number(s) involved
   in a confirmed merge. When sync sees an "unrecognized" phone contact, it
   should first check: does this phone number already belong to a contact
   with a confirmed merge on record? If yes, treat it as the same contact
   instead of creating a new one — regardless of whether the Android ID or
   the exact name text matches.

2. **Loosen the name-matching fallback** so small punctuation-only
   differences (like a period after "Dr", or extra spaces) don't cause a
   phone-number match to be rejected. This is a smaller safety net for cases
   where the phone-number check above doesn't apply (e.g. multiple contacts
   truly do share a number).

3. **Clean up already-absorbed native duplicates**, so that merged copies
   don't keep piling up on the phone itself: when merging, also delete any
   native contacts already recorded as absorbed into either duplicate (not
   just the ones currently pointed to by `contacts.device_id`), using
   `merged_device_ids` records from `contact_repository.dart`.

This does not change how duplicates are detected or displayed — only how the
sync process avoids recreating a contact that the user already confirmed
merging.

## What I will not change

- The "Same name & number" duplicate detection UI/logic itself — that part is
  working correctly (it's supposed to catch these two before merge).
- WhatsApp's own contact sync behaviour — out of the app's control.

## Testing plan

- Add/extend a test in `test/` that simulates: a confirmed merge recorded for
  a phone number, then a sync event presenting a "new" device contact with
  that same number but a different Android ID and a slightly different name
  — expect no new duplicate contact to be created.
- Run `flutter test` for the sync/repository/duplicate test files.
- Manually re-test on the connected device: confirm the merge holds after
  forcing a resync (if practical without waiting for another natural
  WhatsApp-triggered re-link).
