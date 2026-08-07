# Sync to device contacts

**Status:** completed

## Issue / goal

Settings → Contacts today has one sync action: a card titled **"Sync device
contacts"** that *pulls* the phone's address book into the app
(`ContactSyncService.syncFromDevice`). The direction is not clear from the title,
and there is no way to push the other way.

We need two clearly named actions under Settings → Contacts:

1. **Sync from device contacts** — the existing pull. Only the wording changes.
2. **Sync to device contacts** — a new action that *pushes* the app's contacts
   into the phone's device (local) contacts. If a device contact already exists
   for an app contact, **overwrite** that device contact. A conflict is decided
   by name or phone number.

## How the current code works (for reference)

- `ContactSyncService.saveContact` already does a per-contact two-way write:
  a non-secret, non-self contact is pushed to the device via
  `DeviceContactService.upsertDeviceContact` and its `device_id` is stored.
  Secret and Self contacts are **app-only** — never written to the device.
- `DeviceContactService.upsertDeviceContact(c)` creates a device contact, or,
  when `c.deviceId` is set and still exists, **updates** that device contact in
  place (returns its id). So overwriting an existing device contact just means
  calling this with `c.deviceId` pointing at the target.
- `DeviceContactService.fetchDeviceContacts()` (light: name + phone + email) can
  read the current device book to find conflicts.
- `ContactRepository.getAllContacts(includeSecret: false)` returns fully
  hydrated non-secret app contacts. `ContactRepository.normalizeDigits` gives the
  digit-only phone key used everywhere for phone matching.

There is currently **no bulk "push all app contacts to device"** method — that
is what we add.

## Plan for the fix

### 1. `lib/services/contact_sync_service.dart` (new push operation)

Add a small result type and a `syncToDevice` method:

- `class SyncToDeviceResult { final int created; final int updated; ... int get total; }`
- `Future<SyncToDeviceResult> syncToDevice({void Function(int processed, int total)? onProgress})`:
  1. Return `SyncToDeviceResult(0, 0)` if the contacts permission is not granted
     (no prompt here — the card prompts first, like the pull card).
  2. Load the app contacts to push: `getAllContacts(includeSecret: false)` then
     drop `isSelf` rows. This mirrors the existing app-only rule — **secret and
     self contacts are never written to the device.**
  3. Read the current device book once (`fetchDeviceContacts()`) and build two
     conflict indexes over it: `digits -> deviceId` and `nameKey -> deviceId`
     (first owner wins, reusing the existing `_nameKey` and `normalizeDigits`).
  4. For each pushable app contact:
     - If it is already linked (`deviceId != null`), overwrite that device
       contact.
     - Otherwise resolve a **conflict**: an existing device contact with a
       matching normalized phone number first, then a matching full name. If one
       is found, point the app row at it so it gets overwritten instead of
       duplicated.
     - Call `upsertDeviceContact(c)` (creates or overwrites), store the returned
       `device_id` back on the app row (`updateContact`) so the link persists,
       and update the in-memory indexes so two app rows can't both claim one
       device entry.
     - Count it as `updated` when a device target already existed, else `created`.
     - Report `onProgress(i, total)`.
  5. Return the created/updated counts.

Matching rule (stated explicitly so it can be confirmed): **phone number match
wins; if no number matches, a full-name match counts as a conflict.** This is
looser than the pull side's "same name AND number" rule, matching the request
that a conflict be based on name *or* phone.

### 2. `lib/screens/contacts_settings_screen.dart` (UI)

- Rename the existing `_SyncDeviceContactsCard` title from **"Sync device
  contacts"** to **"Sync from device contacts"** (idle subtitle unchanged:
  "Pull the phone's address book into the app now").
- Add a new `_SyncToDeviceCard` (stateful, styled exactly like the existing
  card):
  - Title **"Sync to device contacts"**, idle subtitle e.g. *"Copy your app
    contacts into the phone's contacts"*, icon `Icons.upload_outlined` (distinct
    from the pull card's `Icons.sync_outlined`).
  - On tap: `DeviceContactService().ensurePermission()`; if denied, snackbar
    "Contacts permission is needed to sync". Otherwise call
    `syncToDevice(onProgress: ...)`, show a busy spinner + "Syncing x of y…"
    while it runs (own local state, no global stream needed since only this card
    starts a push), then a result snackbar (e.g. "Synced to device — N added or
    updated" / "Nothing to sync").
  - Place it directly under the renamed "Sync from device contacts" card in the
    `ListView`.

### 3. `test/contact_sync_service_test.dart` (tests)

Following the file's existing philosophy (device side is platform-bound and inert
on the host VM; full device sync is verified manually on a device), add:

- `syncToDevice is a no-op without device permission` — asserts it returns
  `total == 0` and does not change app rows on the host VM.

The name/phone conflict-resolution and the actual device writes will be verified
manually on a device (as the pull path already is).

## Files to change

- `lib/services/contact_sync_service.dart` — add `SyncToDeviceResult` + `syncToDevice`.
- `lib/screens/contacts_settings_screen.dart` — rename pull card, add push card.
- `test/contact_sync_service_test.dart` — add the no-op test.

## Verification

- `flutter analyze` clean for the touched files.
- `flutter test test/contact_sync_service_test.dart` passes.
- Manual on-device check: tap "Sync to device contacts", confirm app contacts
  appear/overwrite in the phone's contacts app, and that an app contact matching
  an existing device contact by name/number overwrites it rather than duplicating.

## Out of scope / notes

- No deletion on the device for app contacts that were removed (this is a push,
  not a full mirror). Can be a later enhancement.
- Secret and Self contacts stay app-only, consistent with the existing rules.
