# Sync app contacts into the device (local) account, and refresh the counts card

**Status:** completed

## The issue

The "Contact counts" card shows **Device: 0** even right after running
"Add app contacts to device (destructive)". This is not a display glitch — the
device address book really has zero live contacts.

Verified on the connected device (adb / ContactsContract):

- `content://com.android.contacts/raw_contacts` has 328 rows, **every one
  `deleted=1`** (soft-deleted). There are **zero live** raw contacts, so the
  aggregated `contacts` table is empty. The app is reading 0 correctly.
- The app's created contacts went into the **`com.google` account**
  (`tosreerajp@gmail.com`), whose `ungrouped_visible=0` in the contacts
  `settings` table, and they have since been soft-deleted.
- The device's **local account is `NULL`/`NULL` with `ungrouped_visible=1`**
  (visible). A raw contact inserted with a `NULL` (or empty-string, which the
  provider coerces to `NULL`) account is immediately **live (`deleted=0`)** and
  aggregates into a visible contact. Confirmed by inserting and then deleting
  test rows.

### Why contacts land in the Google account

`DeviceContactService.upsertDeviceContact` creates via
`FlutterContacts.create(_toDevice(c))` with **no account**
([device_contact_service.dart:125](../lib/services/device_contact_service.dart#L125)).

In `flutter_contacts` 2.1.0 the native `CreateImpl` does:

```
val account = Account.fromJson(call.argMap("account"))
    ?: AccountUtils.getDefaultAccount(context.contentResolver)
```

So a null account is replaced by the **device default account**, which on this
phone is the Google account. Contacts in that synced account are then removed
(Google sync reconciliation and/or the destructive mirror's delete phase),
leaving `deleted=1` rows and an empty visible book.

We want them in the **local device account** instead, per the requirement that
"when the app syncs contacts to the device it should go to the device account".

Empirically, `create` **can** reach the local account: passing an account with
empty `type`/`name` makes `ContactBuilder` write empty strings, which the
ContactsProvider coerces to `NULL`/`NULL` — the visible local account. No plugin
fork is required.

### Secondary issue — the card does not refresh

Even once contacts persist, the counts card can keep showing the old number:
`syncToDevice` never fires `onSyncCompleted`, and `mirrorToDevice` fires it only
when it deletes something (`deleted > 0`). The `_ContactCountsCard` sits below
the Sync screen in the navigator, so it is not rebuilt on return and never
reloads. The user has to tap it to refresh. We should make the two app→device
operations notify listeners so the count updates on its own.

## Files to change

1. `lib/services/device_contact_service.dart`
   - Add a `static const fc.Account _localAccount = fc.Account(id: '', name: '', type: '')`
     (the device/local account).
   - Pass `account: _localAccount` in the `FlutterContacts.create(...)` call in
     `upsertDeviceContact`, so newly created device contacts go to the local
     account rather than the default (Google) account. Updates of an existing
     linked contact stay in place (no account change) and are unaffected.

2. `lib/services/contact_sync_service.dart`
   - Fire `_syncCompleted.add(...)` at the end of `syncToDevice` (with the
     created+updated total) and unconditionally at the end of `mirrorToDevice`
     (with the deleted count), so the "Contact counts" card and any other
     `onSyncCompleted` listeners refresh after an app→device sync.
   - Keep the existing behavior otherwise (return values unchanged).

## The fix (plan)

- Route created device contacts to the local account via an empty-string
  `Account`, which the provider stores as the `NULL` local account (verified
  live/visible on the device).
- Notify `onSyncCompleted` from both app→device operations so the counts card
  updates without a manual tap.

## Notes / out of scope

- The 328 existing `deleted=1` rows are stale Google-account writes; the sync
  adapter purges them over time. No cleanup code is added.
- App rows still carry `device_id`s pointing at the now-deleted Google
  contacts. On the next push, `upsertDeviceContact` calls `FlutterContacts.get`
  on that id, gets `null` (contact gone), and falls through to create a fresh
  **local** contact — self-healing, so no migration code is needed.
- Alternative considered and rejected: forking/patching the plugin's native
  `CreateImpl` to pass a real `null` account. Not needed — the empty-string
  account already yields the local `NULL` account through the public API.

## Verification

- Rebuild, run "Add app contacts to device", then check on device:
  `adb shell content query --uri content://com.android.contacts/raw_contacts --projection _id:account_type:deleted --sort '_id DESC'`
  → new rows should be `account_type=NULL, deleted=0`.
- The "Contact counts" card should show a non-zero Device count without a manual
  tap after the sync completes.
