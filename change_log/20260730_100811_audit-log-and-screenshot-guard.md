# Local audit log + screenshot guard

Implements [plans/20260730_095301_audit-log-and-screenshot-guard.md](../plans/20260730_095301_audit-log-and-screenshot-guard.md).

## What changed

### Audit log (Settings → Audit Log)

- **New `audit_log` table** (DB version 22 → 23). One row per contact create / edit / delete:
  contact id (no foreign key, so the row outlives the contact), the name at the time, the action,
  the source, the time, a one-line summary, a secret flag, and full JSON snapshots of the contact
  before and after the change. Created by `_ensureAuditTable`, which is existence-checked and runs
  on every open, so a development database whose version ran ahead still gets the table.
- **Writes happen inside the contact transactions.** `ContactRepository.insertContact`,
  `updateContact`, `deleteContact` and `mergeContacts` each take a snapshot and write the audit
  row in the same transaction, so a contact cannot change without being recorded. Every other
  write path in the app already goes through these methods.
- **The source is recorded**: in the app, phone contacts sync, merged duplicates, backup restore,
  sync from another device, file import, or an undo.
- **Undo**, from an entry's detail screen: an added contact is deleted again, an edit is reverted
  by writing the old snapshot back, a deleted contact is re-created with its phones, emails,
  addresses, social links, work details, tags and groups. A restored contact gets a **new id**, so
  old call history stays unlinked and only relationships whose other person still exists come
  back — the screen says this before you confirm. The undo is itself recorded as a new entry.
- **A merge** is logged as what it is: an edit on the kept contact plus one delete per absorbed
  contact, so an absorbed contact can be brought back on its own.
- **Bulk paths log one summary entry**, not one per contact: a P2P sync apply, and a full restore.
  A full restore also **clears the log first** — its snapshots describe the database that was just
  replaced, and their contact ids would otherwise point at the backup's contacts.
- **Local and bounded**: the log sits in the same encrypted database, is never exported to a
  backup or a sync, keeps 90 days up to 5000 rows (pruned when the screen opens), and can be
  cleared from the screen's ⋮ menu. Entries about secret contacts stay hidden until the same
  biometric gate the contact list uses is passed.
- **Screens**: `AuditLogScreen` (day-grouped list, All / Added / Edited / Deleted filters, secret
  toggle, clear) and `AuditEntryDetailScreen` (field-by-field before → after, Undo, open contact).

### Screenshot guard

- New `ScreenshotGuard` mixin holds the window's secure flag from `initState` to `dispose`,
  using a per-instance reason so stacked screens nest correctly with the app-lock and
  secret-contact holders already using `ScreenSecurity`.
- Mixed into `ContactDetailScreen` and `InCallScreen`: no screenshots, no screen recording, and a
  blank Recents thumbnail while they are open.
- New setting **Settings → Block screenshots**, on by default, read when the screen opens. The
  app-lock screen and the secret-contacts list keep the flag regardless of the switch.

## Files

**New**

- `lib/models/audit_entry.dart` — entry + snapshot models, action/source codecs, field diff.
- `lib/repositories/audit_repository.dart` — capture, record, read, prune, clear.
- `lib/screens/audit_log_screen.dart`
- `lib/screens/audit_entry_detail_screen.dart`
- `lib/widgets/screenshot_guard_mixin.dart`
- `test/audit_log_test.dart` — 9 tests.

**Changed**

- `lib/database/database_helper.dart` — v23, `_ensureAuditTable` + index, wired into create,
  upgrade and open.
- `lib/repositories/contact_repository.dart` — snapshots + audit rows on every write, `source:`
  arguments, `undoAudit`, `_writeSnapshot`.
- `lib/services/contact_sync_service.dart` — device-sync and merge sources.
- `lib/services/export_import_service.dart` — import source.
- `lib/services/sync_bundle_service.dart` — summary entries for P2P apply and full restore; the
  restore clears the old log.
- `lib/state/app_settings.dart` — `screenshotGuardEnabled`, its setter and a static reader.
- `lib/screens/settings_screen.dart` — Audit Log card, Block screenshots switch.
- `lib/screens/contact_detail_screen.dart`, `lib/screens/in_call_screen.dart` — the guard mixin.
- `docs/architecture.md` — the `audit_log` table and an "Audit log" section.
- `docs/security.md` — audit log in the sensitive-data inventory and the retention table; the
  widened screenshot guard and its setting.

## Checks

- `flutter analyze` — no issues.
- `flutter test test/audit_log_test.dart` — 9 passed.
- Re-ran the database-backed and widget test files one at a time (backup, P2P bundle, contact
  sync, emergency info, tags, relationships, CSV import, affiliation peers, the four DB/search
  files, call log, interactions, group ringtone, flagged numbers, widget, features, caller
  context) — all passed.

## Notes / limits

- A restored deleted contact has a new id; old call-log rows stay unlinked.
- Merge is undone one absorbed contact at a time; data already copied onto the kept contact is
  not stripped back out.
- The screenshot setting is read when a screen opens, so flipping it applies the next time the
  screen is opened.
