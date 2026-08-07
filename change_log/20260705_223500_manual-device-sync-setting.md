# Settings → Contacts: manual "Sync device contacts" action

Implements `plans/20260705_222250_manual-device-sync-setting.md`.

## What changed

### lib/screens/contacts_settings_screen.dart
- New `_SyncDeviceContactsCard` (a small `StatefulWidget`), placed right after
  the "Add Me" card, styled like the other settings cards
  (`Icons.sync_outlined`, subtitle "Pull the phone's address book into the
  app now").
- On tap it:
  1. Prompts for the contacts permission via
     `DeviceContactService().ensurePermission()` when needed; if denied, shows
     "Contacts permission is needed to sync".
  2. Runs `ContactSyncService().syncFromDevice()`, swapping the icon for a
     spinner and ignoring further taps while it runs.
  3. Reports the outcome in a snackbar: "Contacts synced — N added or
     updated", "Contacts are already up to date", or "Sync failed".

No service or database changes were needed; the sync entry point already
existed. The contact list re-reads the DB on its normal refresh paths, so
manually synced rows appear there without extra wiring.

Note: this button runs the same sync fixed by
`change_log/20260705_223500_missing-contacts-in-list.md` (same date), so a
manual sync also triggers that fix's self-healing of wrongly merged contacts.

## Verification

`flutter analyze`: no issues. `flutter test`: all 109 tests pass.
