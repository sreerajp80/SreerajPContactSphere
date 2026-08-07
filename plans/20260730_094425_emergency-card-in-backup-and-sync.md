# Emergency card in backups and device-to-device sync

**Status:** completed

## The issue

The emergency info card (`emergency_info` — one row — plus its `emergency_contacts`
rows) is saved only in this phone's encrypted database. It is left out of both
transport paths:

- **Backup / restore** (`BackupService` → `SyncBundleService.exportBundle(full)` /
  `replaceAllFromBundle`): the two tables are not in `_allManagedTables`, so a
  backup file never carries the card. A restore does not wipe them either, so the
  card on the phone survives a restore — but a new phone starts with an empty card
  and the user has to type everything again.
- **P2P sync** (`applyBundle`): there is no `SyncCategory` for the card, so it
  never travels, not even on a Full Sync to a brand-new phone.

The help page currently tells the user this ("The card stays on this phone…").

Two things make this more than "add a table to the list":

1. `emergency_contacts.contact_id` is a foreign key to `contacts(id)`. The P2P
   merge gives every incoming contact a **new** id, so that column must be
   remapped (or cleared) — this is the id-remapping work the original plan left
   out.
2. Restoring an **old** backup (made by this same DB version but before this
   change) must not wipe the card that is already on the phone. The schema-version
   gate does not protect us here: the emergency tables already exist at DB v22, so
   an existing v22 backup file will pass the gate while carrying no card.

## Design decisions

- **Backup = exact copy.** A backup carries both tables; a restore wipes and
  reloads them verbatim, keeping original ids (contact ids are preserved by a full
  replace, so `contact_id` stays correct with no remapping).
- **Old backups leave the card alone.** The two tables go in a new
  `_optionalManagedTables` list: on restore they are wiped **only when the incoming
  bundle actually carries that table key**. A pre-change backup therefore behaves
  exactly as it does today — the local card is untouched.
- **P2P: never overwrite someone else's medical data.** The card travels as a new
  opt-in `SyncCategory.emergencyCard` (included automatically on a Full Sync, a
  tick box on a selective send, **off by default**). On apply, the incoming card is
  installed only when the receiver has **no** card of its own (no `emergency_info`
  row and no `emergency_contacts` rows). If the receiver already has one, the
  incoming card is skipped. This matches the "client wins" rule the rest of the
  merge follows, and is the fill-only rule already used for settings.
- **`contact_id` remapping on merge.** Each incoming entry's `contact_id` is
  mapped through the merge's `senderToReceiver` map (which covers both newly-added
  and matched contacts). If the referenced contact is not on the receiver at all,
  the column is set to `NULL` — the name and number are snapshotted in the entry,
  so the card still shows and dials correctly.
- **Refresh the lock-screen mirror after a restore or sync.** The native mirror is
  a copy of the card; after replacing the DB rows it must be re-published (or
  cleared). `EmergencyInfoRepository.pushMirror()` already does exactly this and is
  best-effort (swallows failures), so it is safe to call at the end of both
  `replaceAllFromBundle` and `applyBundle`. Without it the phone shows the old
  card until the next app start.
- **No protocol / DB version bump.** No schema change is needed (the tables exist
  at v22). An older receiver on the same DB version simply ignores the extra table
  keys, and mismatched app versions are already refused by the `dbVersion` gate.

## Files to change

1. **`lib/services/sync_bundle_service.dart`** (main change)
   - Add `SyncCategory.emergencyCard`; map it to
     `['emergency_info', 'emergency_contacts']` in `_categoryTables`.
   - Add `_optionalManagedTables = ['emergency_info', 'emergency_contacts']`,
     appended to the wipe/reload passes in `replaceAllFromBundle` but wiped only
     when the bundle carries the key. Order stays PARENT → CHILD (after
     `contacts`).
   - `applyBundle`: new step — install the incoming card only if the receiver has
     none; remap `contact_id` through `senderToReceiver`, else `NULL`; drop the
     incoming `id`s.
   - Both `replaceAllFromBundle` and `applyBundle`: call
     `EmergencyInfoRepository().pushMirror()` after the transaction.
   - Update the file-header comment to describe the card's rules.

2. **`lib/screens/sync/send_to_device_screen.dart`**
   - Add `SyncCategory.emergencyCard: 'Emergency info card'` to `_labels`; leave it
     out of the default `_selected` set (opt-in).

3. **`lib/screens/help/emergency_info_help_screen.dart`**
   - Replace the "The card stays on this phone…" bullet: the card **is** inside a
     password-protected ContactSphere backup, and travels on a Full Sync (or when
     ticked), but is only installed on the other phone if that phone has no card of
     its own. The plaintext lock-screen copy itself is still device-local and still
     out of phone backups.

4. **`lib/screens/help/backup_help_screen.dart`**
   - Add a bullet to the "what's included" list for the emergency info card.

5. **`lib/screens/help/p2p_sync_help_screen.dart`**
   - Add a bullet: the emergency card travels on a Full Sync / when ticked, and is
     not installed over an existing card on the receiving phone.

6. **`docs/security.md`**
   - Note that the card now travels inside the encrypted backup file and the
     encrypted sync payload (both already password/PBKDF2 + AES-GCM protected), and
     that the plaintext mirror is still never transported.

7. **`test/backup_service_test.dart`**
   - Seed an emergency card, and assert the restore reproduces it exactly (row +
     contact entries, original ids, `contact_id` intact).
   - Assert a bundle **without** the emergency tables (simulating an old backup)
     leaves the phone's existing card untouched.

8. **`test/p2p_bundle_test.dart`**
   - Assert a Full Sync into a receiver with **no** card installs it, with
     `contact_id` remapped to the receiver's new contact id (and `NULL` when the
     referenced contact was not transferred).
   - Assert a receiver that already has a card keeps its own.

Both DB-backed test files must still be run one file per `flutter test`
invocation (shared-sqlite3 native-asset crash).

## Verification

- `flutter analyze`
- `flutter test test/backup_service_test.dart`
- `flutter test test/p2p_bundle_test.dart`
- `flutter test test/emergency_info_test.dart`

## Out of scope

- vCard / CSV export-import (`export_import_service.dart`) — the card is not a
  contact and has no vCard representation.
- Any change to what the native plaintext mirror holds.
