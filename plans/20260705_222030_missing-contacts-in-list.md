# Fix: app does not show all phone contacts

**Status:** completed

## The issue (as reported)

In the production release, the app's contact list does not show all the
contacts that exist in the phone's address book.

## What I found (root causes, most likely first)

The list is DB-backed: after the first sync, the screen only shows rows from
the app's SQLite store ([contact_list_screen.dart:143](../lib/screens/contact_list_screen.dart#L143)).
So "missing contacts" means device contacts that never became DB rows. I found
four ways that happens:

### 1. Over-aggressive auto-merge by shared phone number (main suspect)

In `syncFromDevice` ([contact_sync_service.dart:230](../lib/services/contact_sync_service.dart#L230)),
a device contact is **absorbed** into an existing contact (never inserted) when
**any one** of its numbers matches **any** existing contact's number
(digit-normalized). Real address books often have different people sharing a
number — family members with the same home/landline number, colleagues with
the same office number. The second person is silently merged into the first
and never appears in the list.

The same dedup also hides these contacts in the first-run quick view
(`mergedContacts`, [contact_sync_service.dart:143](../lib/services/contact_sync_service.dart#L143)).

This behaves the same in debug and release; it likely only became visible in
production because that's where the full, real contact book was tested.

### 2. Contacts with no name are dropped

`DeviceContactService._toApp` ([device_contact_service.dart:156](../lib/services/device_contact_service.dart#L156))
returns `null` when a device contact has no first name and no display name, so
the contact is skipped entirely. The phone's contacts app shows such entries
by their number.

### 3. A failed device fetch still marks the initial sync as done

`fetchDeviceContacts` swallows every error and returns an **empty list**
([device_contact_service.dart:83](../lib/services/device_contact_service.dart#L83)).
`syncFromDevice` then runs its loop over zero contacts and still calls
`_markInitialSyncDone()` ([contact_sync_service.dart:249](../lib/services/contact_sync_service.dart#L249)).
From then on, every launch shows only whatever is already in the DB and the
failure repeats silently. In release there is no console, so this failure mode
is invisible.

### 4. Sorting/paging weaknesses (contacts look missing)

The paged list query orders by `c.first_name ASC` only
([contact_repository.dart:755](../lib/repositories/contact_repository.dart#L755)):

- The sort is case-sensitive (SQLite BINARY collation), so names starting
  with a lowercase letter — and non-Latin (e.g. Malayalam) names — sort
  **after** all `A–Z` names. Users browsing alphabetically perceive them as
  missing.
- `first_name` is not unique and there is no tiebreaker, so `LIMIT/OFFSET`
  paging over ties is not guaranteed stable; a row can be skipped or repeated
  between pages.

## Files to change

1. `lib/services/contact_sync_service.dart`
2. `lib/services/device_contact_service.dart`
3. `lib/repositories/contact_repository.dart`
4. `lib/screens/contact_list_screen.dart` (only if needed for re-sync trigger)

## The fix plan

1. **Make auto-merge safer** (`contact_sync_service.dart`):
   - In `syncFromDevice`, absorb a device contact into a phone-number match
     **only when the names also match** (case-insensitive compare of
     first + last name). Otherwise insert it as its own row even though a
     number is shared.
   - Apply the same rule to the `mergedContacts` phone dedup so the first-run
     view matches.

2. **Keep nameless contacts** (`device_contact_service.dart`):
   - In `_toApp`, when there is no usable name, fall back to the contact's
     first phone number as `firstName` (matching what the OS contacts app
     shows) instead of returning `null`. Drop the contact only when it has
     neither a name nor a number nor an email.

3. **Do not mark initial sync done on a failed fetch**
   (`device_contact_service.dart` + `contact_sync_service.dart`):
   - Change `fetchDeviceContacts` to signal failure (return `null` on error
     instead of an empty list, keeping the never-throw behavior at call
     sites).
   - In `syncFromDevice`, skip the merge loop and **do not** call
     `_markInitialSyncDone()` when the fetch failed, so the next launch
     retries the full sync.

4. **Stable, case-insensitive ordering** (`contact_repository.dart`):
   - Change list/search ordering to
     `ORDER BY c.first_name COLLATE NOCASE ASC, c.id ASC` so paging is stable
     and lowercase/mixed-case names sort where users expect.

5. **Recovery for already-affected installs**: absorbed contacts from cause 1
   were never inserted, and the `merged_device_ids` link records the wrong
   absorption. On the next sync after the fix, a device contact whose
   number-match no longer passes the name check must still get its own row.
   I will make the fixed `syncFromDevice` re-check **absorbed** (merged)
   links — not just insert unlinked ones — so existing production installs
   heal themselves on the next background sync without a reinstall.

6. **Tests**: unit tests for the new merge rule (shared number + different
   name → two rows; shared number + same name → absorbed), the nameless
   fallback, and the failed-fetch path not marking the sync flag.

7. Run `flutter analyze` and `flutter test`, then write the change log.

## Out of scope (noted, not planned)

- vCard/QR/BLE import flows reuse `mapToApp`, so fix 2 benefits them too; no
  separate change planned there.
