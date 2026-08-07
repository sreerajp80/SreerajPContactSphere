# Fix "Add app contacts to device" — get() throw + choosable destination account (incl. local)

**Status:** completed

## Summary of the problem

Tapping **Sync → "Add app contacts to device"** shows a toast "Synced to device — 289
added or updated", but **no contacts appear on the phone**. The "Contact counts" card
keeps showing **Device: 0**.

I verified the cause on the real device (moto, **Android 16 / SDK 36**) with adb and a
live logcat capture during the sync.

### Root cause A — the real reason nothing is written (the bug)

Every app contact carries a **stale `device_id`** (631, 632, 633 …) from an earlier
device import. The phone's address book is now empty, so those ids no longer exist.

In `DeviceContactService.upsertDeviceContact` (lib/services/device_contact_service.dart,
around lines 117-140):

1. `existingId` is non-null (e.g. "631"), so the code takes the "update existing" branch.
2. It calls `FlutterContacts.get("631")`. In **flutter_contacts 2.1.0 the native side
   THROWS** `PlatformException("Contact with ID 631 not found")` instead of returning
   `null`. (The code assumes `get` returns `null` — see the now-wrong comment
   "The linked device contact was deleted out from under us — recreate.")
3. The throw is caught by the outer `catch`, which returns `c.deviceId` unchanged. **The
   `create()` fallback on line 133 is never reached.** So nothing is created.
4. This happens for all 289 contacts.

Confirmed logcat line:
`DeviceContactService.upsertDeviceContact failed: PlatformException(flutter_contacts_error, Contact with ID 631 not found, null, null)`
with the stack showing `CrudApi.get` → `device_contact_service.dart:123`.

### Root cause B — the false "289 added" toast

In `ContactSyncService.syncToDevice` the loop does `created++` / `updated++` for every
contact regardless of whether the write actually succeeded, and `upsertDeviceContact`
swallows errors and returns a value. So every failed write is still counted. The toast
lies.

### Root cause C — the destination account (why writes still would not land where wanted)

Even after fix A, the write must go somewhere sensible. The current code passes an empty
`Account(id:'', name:'', type:'')` to `create()`. In flutter_contacts **2.1.0** the Kotlin
`Account.fromJson` **rejects empty name/type and returns null**, so `create()` falls back
to `getDefaultAccount()` (the user's default — here a Google account). The old
"empty account → local device account" trick worked on flutter_contacts **1.1.9** (its
`insert` wrote `ACCOUNT_TYPE = null` by default) but is a **silent no-op on 2.1.0**.

I verified with adb that the provider itself accepts writes fine on Android 16 — a direct
insert into the local NULL "Device" account persists (`deleted=0`), and so does a Google
insert. So Android 16 is **not** blocking or soft-deleting; the plugin simply cannot target
the local account.

**Requirement from the user:** let the user pick the destination account, the picker must
include the local **"Device"** account, and choosing it must actually save the contact into
the device-local storage.

**Constraint:** flutter_contacts 2.1.0 has **no way** to write to the local (NULL/NULL)
account — empty account is discarded and there is no null-account path. So the local write
needs a small **native ContentResolver insert**. Real accounts (Google, Motorola, …) can
still go through the plugin, which accepts a non-empty `Account`.

## The fix (plan)

### 1. Fix the `get()` throw (the core bug) — `lib/services/device_contact_service.dart`

- Wrap the `FlutterContacts.get(existingId, …)` call in its own `try/catch`. Treat a
  `PlatformException` "not found" (and any failure) as **`existing == null`**, so the code
  falls through and **recreates** the device contact. This alone makes contacts get written
  again.

### 2. Make success/failure honest — `device_contact_service.dart` + `contact_sync_service.dart`

- Change `upsertDeviceContact` so callers can tell success from failure. It will return the
  resulting **device id on success and `null` on failure** (instead of echoing the old id on
  failure). Update `ContactSyncService.saveContact` so a `null` result **keeps the previous
  `deviceId`** (a transient device-write failure must not unlink a good contact — preserves
  today's behaviour).
- In `syncToDevice` (and `mirrorToDevice`), count `created` / `updated` **only when the
  write really succeeded**, and track a `failed` count. Extend `SyncToDeviceResult` with a
  `failed` field.

### 3. Destination-account selection with a local option

**Data model (new, small):** add `lib/services/device_account.dart` with a `WritableAccount`
type: `{ String label; Account? account; bool isLocal; }` where `account == null && isLocal`
means the device-local storage.

**Enumerate accounts — `device_contact_service.dart`:**
- `Future<List<WritableAccount>> writableAccounts()`:
  - Always include a local entry: `WritableAccount(label: 'Device (this phone)',
    account: null, isLocal: true)`.
  - Append the real accounts from `FlutterContacts.accounts.getAll()` (Google, Motorola, …),
    each labelled `"<name>" (<type pretty name>)`.

**Write routing — `device_contact_service.dart`:**
- `upsertDeviceContact(Contact c, {WritableAccount? target})`:
  - **Update path** (valid existing id): unchanged — `FlutterContacts.update(...)` works by
    id regardless of account.
  - **Create path:**
    - target is a real account → `FlutterContacts.create(_toDevice(c), account:
      target.account)` (plugin handles it — fromJson accepts the non-empty account).
    - target is local (or null default) → call the **native** local-insert method (below)
      and return the new contact id.
- The native local path only handles **create**. Local **updates/deletes** still go through
  `FlutterContacts.update/delete` by id (they do not move the account).

**Native local insert — `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`:**
- Add a new method channel `contact_sphere/contacts_local` with one method
  `createLocalContact(payload)`.
- `payload` is a compact map built in Dart mirroring `_toDevice`: structured name
  (prefix/first/middle/last), `phones[{number,label}]`, `emails[{address,label}]`,
  `addresses[{street,city,state,postalCode,country,isWork}]`, `organization{company,title,
  department}`, `events[{kind,year,month,day}]`, `socialLinks[{label,value}]`,
  `websites[url]`, and optional `photo` (PNG/JPEG bytes).
- Kotlin builds a `ContentProviderOperation` batch: a `RawContacts` insert with
  **`ACCOUNT_TYPE = null, ACCOUNT_NAME = null`** (the local account, proven to persist on
  this device), then the Data rows, applied with `applyBatch(ContactsContract.AUTHORITY,
  ops)`. It then looks up and returns the **contact _id** as a string (same lookup pattern
  as the plugin's `CreateImpl`). Runs off the platform thread (like `queryConnectedApps`),
  answers on it. Returns `null` on failure.
- Add a tiny Dart wrapper (in `device_contact_service.dart`) that builds the payload from a
  `Contact` (reuse the existing `_toDevice` field logic where practical) and invokes the
  channel.

### 4. Picker UI + honest snackbar — `lib/screens/contact_sync_settings_screen.dart`

- When "Add app contacts to device" is tapped, first ensure permission, then show a
  **modal bottom sheet** listing `writableAccounts()` (Device first, then real accounts),
  styled to the app's own design system (not a Google clone). Cancel aborts silently.
- Remember the last chosen account in `SharedPreferences` and preselect it next time.
- Pass the chosen `WritableAccount` into `syncToDevice(target: …)`.
- Snackbar reports honestly, e.g. `"Synced to Device — 289 added"`, and if any failed,
  `"… (12 failed)"`; `"Nothing to sync"` when there is nothing to push.
- The destructive "Add app contacts to device (destructive)" card (`mirrorToDevice`) gets
  the same account argument, threaded through `ContactSyncService.mirrorToDevice(target:)`.

### 5. Thread the account through the service — `lib/services/contact_sync_service.dart`

- `syncToDevice({WritableAccount? target, void Function(int,int)? onProgress})` and
  `mirrorToDevice({WritableAccount? target})` accept and forward the target to
  `upsertDeviceContact`.
- Regular single-contact `saveContact` (from the editor) keeps writing to the **default
  target** (the user's last choice, or Device) — no UI change there.

## Files to change

- `lib/services/device_contact_service.dart` — fix `get()` throw; success/null return;
  `writableAccounts()`; account-routed create; native local-insert wrapper + payload builder.
- `lib/services/contact_sync_service.dart` — thread `target`; honest counting; `saveContact`
  keeps previous id on failure; `SyncToDeviceResult.failed`.
- `lib/screens/contact_sync_settings_screen.dart` — account picker sheet; remembered choice;
  honest snackbars for both push cards.
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` — new
  `contact_sphere/contacts_local` channel with `createLocalContact`.
- `lib/services/device_account.dart` — **new**, small `WritableAccount` model.

## Verification

- `flutter analyze` clean.
- On the moto (Android 16): tap "Add app contacts to device" → pick **Device** → confirm via
  adb that `raw_contacts` fills with `account_type=NULL` rows (`deleted=0`) and the Google
  Contacts app shows them under **Device**, and the app's "Contact counts" card shows a
  non-zero Device count.
- Repeat picking the **Google** account → rows appear under `account_type=com.google`.
- Re-run the sync → contacts are **updated in place** (no duplicates), and the toast counts
  are honest.
- Edit a single contact in the app → still mirrors to the device (default target), no unlink
  on a transient failure.

## Notes / decisions

- Local **create** is the only thing that needs native code; local update/delete still use
  the plugin by id.
- The stale-`device_id` rows heal automatically: the create fallback stores the fresh device
  id back on the app row.
- We are NOT downgrading flutter_contacts (2.1.0 APIs are used across the app).
