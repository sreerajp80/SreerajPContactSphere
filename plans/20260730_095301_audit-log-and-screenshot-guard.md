# Local audit log + screenshot guard

**Status:** completed

## What the user asked for

1. A **local audit log** — "what changed and when" for all contacts, so accidental edits and
   deletes are traceable and can be undone.
2. A **screenshot guard** on the contact detail screen and the in-call screen.
3. The audit log is opened from **Settings → Audit Log**.

## The issue today

- Nothing records contact changes. If a contact is edited badly, deleted by accident, or
  changed by a device sync / restore, there is no way to see what happened or get it back.
  The only history is `contacts.updated_at`, which says "something changed" and nothing more.
- `FLAG_SECURE` support already exists (`ScreenSecurity` + the native `setSecureFlag` handler),
  but it is only used on the app-lock screen and the secret-contacts list. Contact detail (full
  name, numbers, addresses, notes) and the in-call screen (who is calling) are not protected —
  they show in screenshots, screen recordings and the Recents thumbnail.

## Design

### Audit log

**Where the hooks go.** Every contact write in the app already funnels through
`ContactRepository.insertContact / updateContact / deleteContact / mergeContacts` — device
sync, restore, P2P sync and vCard import all call these. So the audit rows are written inside
those same methods, in the same transaction. Nothing can change a contact and skip the log.

**What each row holds.**

| column | meaning |
| --- | --- |
| `id` | row id |
| `contact_id` | the contact the change was about (may now be deleted) |
| `contact_name` | name at the time, so a deleted contact still reads well |
| `action` | `create` / `update` / `delete` |
| `source` | who did it: `manual`, `device_sync`, `merge`, `restore`, `p2p_sync`, `import` |
| `changed_at` | ISO timestamp |
| `summary` | short plain text, e.g. "Phone numbers, Last name" |
| `before_json` | full snapshot of the contact **before** the change (update / delete) |
| `after_json` | full snapshot **after** the change (create / update) |

The snapshot is the contact row plus its children (phones, emails, addresses, social links,
tags, groups, official details, relationships), encoded as JSON. Because both sides are kept,
the detail screen can show a real field-by-field "before → after" list.

**Undo.** From an entry's detail screen:

- `create` → delete the contact again.
- `update` → write the `before_json` snapshot back over the contact.
- `delete` → re-insert the contact with its children.

Two honest limits, shown in the UI, not hidden:

- Undoing a **delete** creates the contact with a **new id**. Relationships are restored only
  where the other person still exists, and old call-log rows stay unlinked (the database drops
  that link on delete).
- **Merge** is not a single undo. A merge is logged as an `update` on the kept contact plus one
  `delete` per absorbed contact, so the absorbed contacts can be brought back one by one, but
  data already copied into the kept contact is not stripped back out.

Undo itself is logged (source `undo`), so the log never lies about how the data got there.

**Privacy and size.** The table lives in the existing SQLCipher-encrypted database, and is
**not** included in backup or P2P sync (a local record of local activity — it is not added to
`SyncBundleService`'s table lists). Old rows are pruned to keep the log small: entries older
than **90 days**, and beyond a cap of **5000** rows, are deleted. Pruning runs when the Audit
Log screen opens.

**Screen.** `Settings → Audit Log` lists entries newest first, grouped by day, with an icon and
colour per action and a filter chip row (All / Created / Edited / Deleted). Tapping an entry
opens a detail page: what changed, who changed it, when, the before → after field list, and an
**Undo** button with a confirmation dialog. A ⋮ menu offers "Clear log" (with confirmation).
Entries for **secret** contacts are only listed while secret contacts are unlocked, matching how
the contact list treats them.

### Screenshot guard

- `ContactDetailScreen` and `InCallScreen` acquire `ScreenSecurity` on `initState` and release
  it on `dispose`, using their own reason names (`contact_detail`, `in_call`). The existing
  reason-counting in `ScreenSecurity` means these nest safely with the app-lock and
  secret-contact holders already using the flag.
- A user-facing switch, **Settings → Privacy → Block screenshots**, defaults to **on**. With it
  off, the two new holders are not acquired; the app-lock and secret-contact holders stay
  unconditional, because those protect data the user explicitly asked to hide.

## Files

**New**

- `lib/models/audit_entry.dart` — the entry model, action/source enums, snapshot encode/decode,
  and the field-diff helper used by the detail screen.
- `lib/repositories/audit_repository.dart` — write/read/prune/clear, and the undo operations.
- `lib/screens/audit_log_screen.dart` — the list, filters, clear.
- `lib/screens/audit_entry_detail_screen.dart` — one entry, the diff, the Undo button.
- `test/audit_log_test.dart` — create/edit/delete each write the right entry; undo of each
  action restores the expected state; prune keeps the newest rows.

**Changed**

- `lib/database/database_helper.dart` — DB version 22 → 23; `_ensureAuditTable` (a
  `CREATE TABLE IF NOT EXISTS`, existence-checked and also called from `_onOpen`, following the
  pattern used by the emergency tables) plus its index on `changed_at`.
- `lib/repositories/contact_repository.dart` — snapshot helpers, audit writes inside the
  existing transactions of `insertContact` / `updateContact` / `deleteContact` /
  `mergeContacts`, and an optional `source` argument on those methods (default `manual`).
- `lib/services/contact_sync_service.dart` — pass the right `source` for device-sync writes,
  merges and deletes.
- `lib/services/export_import_service.dart` — pass `source: import`.
- `lib/services/sync_bundle_service.dart` — pass `source: p2p_sync` / `restore` where it writes
  contacts through the repository (rows written table-wise by a full restore are logged as one
  summary entry, not one per contact).
- `lib/screens/settings_screen.dart` — the "Audit Log" card, and the "Block screenshots" switch.
- `lib/screens/contact_detail_screen.dart` — acquire / release the secure flag.
- `lib/screens/in_call_screen.dart` — acquire / release the secure flag.
- `lib/state/app_settings.dart` — `screenshotGuardEnabled` (default true) with its setter and
  SharedPreferences key.
- `docs/architecture.md` — the `audit_log` table and where the hooks live.
- `docs/security.md` — what the log stores, that it stays local and encrypted, and the widened
  screenshot guard.

## Order of work

1. Schema + model.
2. Repository writes and undo, with tests.
3. Sources threaded through the services.
4. Audit Log screens + the Settings entry.
5. Screenshot guard + its setting.
6. Docs, `flutter analyze`, `flutter test`.

## Risks

- **DB version bump.** Uses the existing existence-checked (`IF NOT EXISTS`) pattern called from
  `_onOpen`, so a development database whose version already ran ahead still gets the table.
- **Log noise from device sync.** A first sync of a large address book writes one `create` entry
  per contact. The 90-day / 5000-row prune caps this, and the filter chips keep the screen
  readable.
- **Snapshot size.** Snapshots are text only — photo *paths*, never image bytes.

Do you approve this plan?
