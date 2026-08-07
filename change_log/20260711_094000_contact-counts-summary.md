# Show device and app contact counts on the Contacts settings screen

Implements plan
[plans/20260711_093518_contact-counts-summary.md](../plans/20260711_093518_contact-counts-summary.md).

## What changed

Added a read-only summary at the top of the Contacts settings screen showing how
many contacts are on the phone versus in the app.

- **Changed** `lib/services/device_contact_service.dart`: added
  `deviceContactCount()` — returns the number of device contacts via the light
  (no-photo) fetch, or `null` when the contacts permission is missing or the read
  fails (so the UI can tell "unknown" from a real zero). Never throws.
- **Changed** `lib/screens/contacts_settings_screen.dart`: added a
  `_ContactCountsCard` placed at the top of the list (above "Add Me"). It shows
  `Device: N · App: M`, where:
  - Device count comes from `DeviceContactService.deviceContactCount()`.
  - App count comes from `ContactSyncService.contactCount(includeSecret: true)`
    (every stored contact, including secret and Self).
  - A spinner shows while loading; a count reads "—" when unknown.
  - When the contacts permission is missing, the card shows "Grant contacts
    permission to count device contacts" and requests it on tap.
  - It reloads on tap (refresh icon) and automatically after any
    sync/mirror/restore, by listening to `ContactSyncService.onSyncCompleted`.
  - Re-added the `dart:async` and `device_contact_service` imports the card uses.

## Testing

- `flutter analyze` on both changed files: **No issues found.**
- Manual verification (Settings → Contacts) pending on device.
