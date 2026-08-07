# Change log — device contacts: live merge, two-way sync, secret-aware delete

Implements plan [plans/20260630_070732_device-contacts-merge-sync.md](../plans/20260630_070732_device-contacts-merge-sync.md).

## Summary

Wired the previously-unused `flutter_contacts` dependency into a **live merge +
full two-way sync** with the device address book:

- The contact list now shows a de-duplicated union of app-DB contacts and device
  contacts (linked by a new `device_id`).
- Adding/editing a contact in the app creates/updates the matching device contact
  (full detail), and deleting a contact in the app deletes the linked device
  contact too.
- The device book is pulled into the app whenever the contacts permission is
  granted (startup, the permissions screen, and each list load).
- **Secret contacts are app-only:** never written to the device; making a contact
  secret deletes it from the device and clears its link.

## Files changed

### New
- `lib/services/device_contact_service.dart` — defensive wrapper over
  `flutter_contacts` (2.1.0). `isGranted` / `ensurePermission`,
  `fetchDeviceContacts`, `upsertDeviceContact`, `deleteDeviceContact`, plus
  bidirectional `_toApp` / `_toDevice` full-detail mappers (name, phones, emails,
  addresses, organization↔official details, birthday/anniversary events,
  social/websites, photo bytes↔file). Every platform call is try/caught and
  degrades to a safe default.
- `lib/services/contact_sync_service.dart` — orchestrator over
  `ContactRepository` + `DeviceContactService`: `mergedContacts` (de-dup by
  `device_id`), `saveContact` (two-way + secret-unlink rules), `deleteContact`
  (propagates to device), `syncFromDevice` (idempotent device→app upsert, skips
  secret rows). Exposes the fire-and-forget `unawaitedSyncFromDevice()` helper.
- `test/contact_sync_service_test.dart` — host-side tests for the SQLite-facing
  behaviour and the secret-unlink rule (device side is inert on the host VM).

### Changed
- `lib/models/contact.dart` — added `String? deviceId` (ctor + `device_id` in
  `toMap`/`fromMap`).
- `lib/database/database_helper.dart` — `contacts.device_id TEXT`; DB version
  4→5 with an additive `ALTER TABLE … ADD COLUMN device_id` migration;
  `idx_contacts_device_id` index.
- `lib/repositories/contact_repository.dart` — added `getContactByDeviceId`.
- `lib/screens/add_edit_contact_screen.dart` — save now routes through
  `ContactSyncService.saveContact` (handles insert-vs-update incl. adopting a
  device-only contact, plus two-way/secret rules). Dropped the now-unused
  `ContactRepository` field/import.
- `lib/screens/contact_list_screen.dart` — load runs `syncFromDevice` then
  `mergedContacts`; tapping a device-only contact opens the editor to adopt it;
  added a confirm-and-delete path (card long-press + a Delete quick-action that
  replaced the redundant "Message" action) via `ContactSyncService.deleteContact`.
- `lib/screens/contact_detail_screen.dart` — added a Delete app-bar action
  (`ContactSyncService.deleteContact`, pops on success) — the canonical
  delete-from-app entry point.
- `lib/screens/permissions_screen.dart` — fires `unawaitedSyncFromDevice()` when
  a refresh sees the contacts permission granted.
- `lib/main.dart` — fires `unawaitedSyncFromDevice()` after the startup
  permission request.
- `docs/known-gaps.md` — moved device-contacts sync from "not integrated" to a
  Resolved entry describing the new behavior.

### Not changed (already in place)
- `AndroidManifest.xml` — `READ_CONTACTS` / `WRITE_CONTACTS` already declared.
- `pubspec.yaml` — `flutter_contacts: ^2.1.0` already present.

## Field mapping notes

App-only fields with no device equivalent (gender, blood group, meetiversary,
ringtone, tags, groups, relationship score/links, secret flag) are preserved on
the app row and not pushed. The device address model is the limiting factor on
round-trip fidelity (e.g. the app's granular address parts collapse into the
device's `street`/`city`/… shape). Device birthdays without a year are stored
with a 1900 placeholder year.

## Verification

- `flutter analyze` — **No issues found**.
- `flutter test` — **21/21 passing** (16 existing + 5 new sync-service tests).
- Device-side sync (actual reads/writes/deletes against the address book) is
  platform-channel bound and inert on the host VM; it must be verified manually on
  a device/emulator with the contacts permission granted.
