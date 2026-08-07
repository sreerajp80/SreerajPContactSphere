# Device contacts: live merge, two-way sync, secret-aware delete propagation

**Status:** completed

## What the user asked for

1. **Show device contacts in the app** — currently `flutter_contacts` is a dependency but
   completely unwired, so only app-DB contacts appear. Decision (confirmed): **live merge
   display** — device contacts are read live and shown alongside app contacts, not bulk-copied
   into SQLite.
2. **Delete propagation** — deleting a contact in the app must also delete it from the device
   address book when that contact exists there.
3. **Full two-way write-back** (confirmed) — adding/editing a contact in the app also
   creates/updates the matching device contact.
4. **Secret contacts are app-only** — never write a secret contact to the device, and when a
   contact is *made* secret, remove it from the device if it currently exists there (and drop
   the link).
5. **All contact details synced both ways** — every field the device contact model supports
   (name parts, phones, emails, addresses, organization/official details, DOB & anniversary
   events, photo, websites/social) is mapped in *both* directions, not just name/phone/email.
   App-only fields with no device equivalent are listed below.
6. **Sync on permission grant** — the moment the user grants the contacts permission, the app
   pulls the device book into the app (imports/links device contacts), so they appear without a
   manual step.

## Current state (verified)

- `ContactRepository.deleteContact(int)` exists but is **called by no screen** — there is no
  delete UI anywhere today. `contact_detail_screen.dart` app bar only has an Edit action.
- Add/Edit screen saves via `_repository.insertContact` / `updateContact` directly.
- `contact_list_screen.dart` loads via `_repository.getAllContacts(includeSecret:)`; cards key
  enrichment (`_lastInteraction`, `_recentCounts`, `_expanded`) off the **int** `contact.id`.
- The list overflow already has an "Import Contacts" item, but it imports **CSV**
  (`ExportImportService.importContacts`) — unrelated to the device book.
- DB is version 4; `contacts` has no device-link column. FKs/cascade are ON.
- Android manifest already declares `READ_CONTACTS` + `WRITE_CONTACTS`.
- `flutter_contacts: ^2.1.0` is already in `pubspec.yaml`.

## Design

Keep `ContactRepository` pure SQLite. Add a thin **`DeviceContactService`** wrapping
`flutter_contacts`, and a **`ContactSyncService`** that orchestrates the two sources
(SQLite + device) for the three cross-cutting operations the screens need: **merged read**,
**save**, **delete**. Screens call the sync service for those; everything else is unchanged.

The link between an app row and a device contact is a new **`device_id TEXT`** column on
`contacts`. Rules:

- App contact with `device_id == null` → app-only (not in device book).
- App contact with `device_id != null` → linked; mirrors a device contact.
- A **device-only** contact (in the phone book, not yet in app DB) is surfaced as a transient
  `Contact` with `id == null` and `deviceId` set. It is *not* persisted until the user acts on
  it (adopt-on-edit).

### Sync on permission grant (pull device → app)

`ContactSyncService.syncFromDevice()`:
1. Ensure the contacts permission (`DeviceContactService.ensurePermission()`); bail out
   (no-op) if not granted.
2. `fetchDeviceContacts()` (full details).
3. For each device contact: if an app row is already linked by `device_id`, **update** that row
   from the device fields; otherwise **insert** a new linked app row. Secret app rows are never
   touched/overwritten by a device pull. Runs as upserts so re-running is idempotent.

Triggered from:
- **`contact_list_screen.dart`** on load and on app resume — when permission is granted, run
  `syncFromDevice()` (best-effort) before the merged read.
- **`permissions_screen.dart`** — immediately after the user grants the contacts permission.
- **`main.dart`** (optional) — fire-and-forget after the startup permission request if granted.

Because every device contact is imported and linked, the merged read below mainly catches
contacts added on the device *after* the last sync; the two compose without producing duplicates
(dedup by `device_id`).

### Field mapping (bidirectional)

Map between the app `Contact` aggregate and `fc.Contact` in **both** directions:

| App field | Device (`flutter_contacts`) |
|---|---|
| salutation / first / middle / last | `fc.Name` (prefix / first / middle / last) |
| phoneNumbers (label, number) | `fc.Phone` (label/customLabel) |
| emails (label, address) | `fc.Email` |
| addresses (personal/official, all parts) | `fc.Address` (street/city/state/postalCode/country, label) |
| officialDetails (designation, department) + company | `fc.Organization` (title / department / company) |
| dob | `fc.Event` (birthday) |
| anniversary | `fc.Event` (anniversary) |
| socialLinks | `fc.SocialMedia` / `fc.Website` |
| photoPath | `fc.Contact.photo` (bytes ↔ file: read device photo to a file under the app dir; encode app photo file to bytes on push) |

**App-only (no device equivalent, stay in SQLite only):** `gender`, `bloodGroup`, `meetiversary`,
`ringtonePath`/`ringtoneLabel`, `tags`, `groups`, `relationshipScore`, relationships, secret flag.
These are preserved on the app row and simply not pushed to the device.

### Merged read (live merge, de-duplicated)

`ContactSyncService.mergedContacts({includeSecret})`:
1. `app = repository.getAllContacts(includeSecret:)`.
2. `device = deviceContactService.fetchDeviceContacts()` (best-effort; `[]` on
   permission-deny / non-Android / any error).
3. Drop device contacts whose device id is already linked to an app row
   (`app.where(deviceId != null)`), so a linked contact shows **once** (the app row wins).
4. Return `app + remainingDeviceOnly`, sorted by first name.

Device-only entries (`id == null`) render as normal cards but skip id-keyed enrichment and the
expand affordance (guarded on `contact.id != null`). Secret/scoring/relationships simply don't
apply to them.

### Save (two-way, secret-aware)

`ContactSyncService.saveContact(Contact c)` replaces the direct repo calls in Add/Edit:

- **If `c.isSecret`:** persist app-only. Insert/update in SQLite. If `c.deviceId != null`
  (it was a device contact before being secretized), **delete that device contact** and set
  `c.deviceId = null` (clear the link, re-persist). Never push secret data to the device.
- **Else (not secret):** upsert the device contact via `DeviceContactService.upsertDeviceContact`
  (update when `deviceId` set, else create and capture the new id), store the returned id in
  `c.deviceId`, then insert/update in SQLite.
- All device writes are **best-effort**: a device failure is logged and never blocks the local
  save (mirrors `PermissionService`'s never-throw philosophy). Permission is requested lazily
  on first device write.
- Adopt-on-edit: a device-only contact (`id == null`, `deviceId` set) opened from the list and
  saved becomes a linked app row (insert + keep/refresh device link), unless secretized (then it
  is pulled from the device per the rule above).

### Delete (propagation)

`ContactSyncService.deleteContact(Contact c)`:
- If `c.deviceId != null` → `DeviceContactService.deleteDeviceContact(c.deviceId)` (best-effort).
- If `c.id != null` → `repository.deleteContact(c.id)`.
- Covers both linked app contacts (delete here + device) and device-only contacts (delete from
  device; nothing in DB to remove).

## Files to change / add

### New
- **`lib/services/device_contact_service.dart`** — wraps `flutter_contacts` (imported
  prefixed, `as fc`, to avoid colliding with the app's own `Contact`). Methods:
  `ensurePermission()` (`fc.FlutterContacts.requestPermission(readonly:false)`, caught),
  `isGranted()`, `fetchDeviceContacts() -> List<Contact>` (full-detail map `fc.Contact`→app
  `Contact` per the field-mapping table; `withProperties:true, withPhoto:true`; set `deviceId`),
  `upsertDeviceContact(Contact) -> String?` (build/update `fc.Contact` from the full field set,
  return id), `deleteDeviceContact(String id)`. Two private mappers (`_toApp`, `_toDevice`) hold
  the bidirectional field mapping. Every platform call wrapped in try/catch → safe default so
  `flutter test` (no platform channel) and permission-denied stay green.
- **`lib/services/contact_sync_service.dart`** — orchestrator described above
  (`mergedContacts`, `saveContact`, `deleteContact`, `syncFromDevice`). Depends on
  `ContactRepository` + `DeviceContactService`.

### Changed
- **`lib/models/contact.dart`** — add `String? deviceId`; include as `device_id` in
  `toMap`/`fromMap`; add to constructor.
- **`lib/database/database_helper.dart`** — add `device_id TEXT` to the `contacts` CREATE; bump
  `version` 4→5; add `_onUpgrade` branch `if (oldVersion < 5) ALTER TABLE contacts ADD COLUMN
  device_id TEXT`; add `idx_contacts_device_id` to `_createIndexes`.
- **`lib/repositories/contact_repository.dart`** — add `getContactByDeviceId(String)` (used by
  merge/dedup and the device-pull upsert); no change to `deleteContact` (propagation lives in the
  sync service). `toMap` already carries the new column, so insert/update persist `device_id` for
  free.
- **`lib/screens/contact_list_screen.dart`** — on load and on app resume, run
  `ContactSyncService.syncFromDevice()` (best-effort, when permission granted), then load via
  `ContactSyncService.mergedContacts` instead of the repository; guard id-keyed enrichment/expand
  on `contact.id != null`; tapping a device-only contact opens Add/Edit prefilled (adopt). Add a
  per-card **delete** path (confirm dialog → `ContactSyncService.deleteContact` → reload) so
  device-only contacts can be removed too. Keep the existing CSV "Import Contacts" item as-is.
- **`lib/screens/contact_detail_screen.dart`** — add a **Delete** action to the app bar
  (confirm dialog → `ContactSyncService.deleteContact` → pop). This is the canonical
  delete-from-app entry point that satisfies requirement #2.
- **`lib/screens/add_edit_contact_screen.dart`** — route save through
  `ContactSyncService.saveContact` (two-way + secret rules) instead of
  `_repository.insertContact`/`updateContact`. Support being opened with a device-only contact
  (adopt). The secret toggle already lives here; no new field needed — the save path enforces the
  secret rules.

- **`lib/screens/permissions_screen.dart`** — after the user grants the contacts permission,
  call `ContactSyncService.syncFromDevice()` so the pull happens immediately on grant
  (requirement #6).
- **`lib/main.dart`** — after the startup `requestPermissions()`, fire-and-forget
  `ContactSyncService.syncFromDevice()` when contacts is already granted (best-effort, never
  blocks launch).

### Possibly touched
- **`lib/services/permission_service.dart`** — optionally add `ensureContactsWrite()` helper;
  not strictly required since `DeviceContactService.ensurePermission()` handles it via
  `flutter_contacts`. Will add only if it reads cleaner.
- **`AndroidManifest.xml`** — no change (permissions already declared).
- **`pubspec.yaml`** — no change (`flutter_contacts` already present).
- **`docs/known-gaps.md`** — move "Device-contacts sync" out of "not integrated" and note the
  live-merge + two-way + secret-aware behavior (doc-only, after implementation).

## Risks / notes

- **Test safety:** `flutter_contacts` needs a platform channel; under `flutter test` every call
  throws. All device calls are caught and return safe defaults, so the widget smoke test and any
  repo tests keep passing. DB v5 migration is a single additive `ALTER` — safe for existing
  installs and the ffi test DB.
- **Secret leak guard:** the *only* code path that writes to the device is
  `saveContact` for a **non-secret** contact; secret contacts are structurally excluded and
  actively pulled from the device when secretized. No other call site writes to the device.
- **Best-effort device writes:** a denied `WRITE_CONTACTS` permission degrades gracefully —
  local save/delete still succeed; the device side is skipped and logged. The user can be shown a
  snackbar when a device write was skipped (nice-to-have).
- **Duplicates:** linking by `device_id` prevents a linked contact from appearing twice. Two
  device contacts with the same name remain distinct (different device ids), consistent with the
  existing `findDuplicates` behavior.
- **Scope boundary:** no background/continuous sync; the merge happens on each list load and on
  save/delete. That matches "show device contacts" + "two-way on edit" without a sync engine.

## Out of scope

- Continuous/background sync or change observers (sync runs on permission grant, on list
  load/resume, and on each save/delete — not via a background service).
- Conflict resolution beyond last-write-wins on the mapped field set.
- App-only fields (`gender`, `bloodGroup`, `meetiversary`, ringtone, `tags`, `groups`,
  relationships, secret flag) — these have no device-contact equivalent and stay in SQLite only.
