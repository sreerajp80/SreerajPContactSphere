# Emergency card now travels in backups and device-to-device sync

Implements [plans/20260730_094425_emergency-card-in-backup-and-sync.md](../plans/20260730_094425_emergency-card-in-backup-and-sync.md).

## What was wrong

The emergency info card (`emergency_info` + `emergency_contacts`) lived only in the
phone's encrypted database. A backup file never held it and it never travelled on a
device-to-device sync, so a new phone started with an empty card.

## What changed

**`lib/services/sync_bundle_service.dart`**

- New `SyncCategory.emergencyCard`, mapped to the two emergency tables.
- **Backup / restore.** The tables now go in the full bundle. On restore they are
  wiped and reloaded verbatim, so the card comes back exactly as it was — and
  because a full replace keeps the original contact ids,
  `emergency_contacts.contact_id` stays valid without any remapping.
- **Old backup files are safe.** The two tables are listed in a new
  `_optionalManagedTables` and are wiped **only when the incoming bundle actually
  carries them**. A backup written before this change (it passes the DB-version
  gate, because the tables already existed at v22) leaves the phone's card alone
  instead of erasing it.
- **P2P sync.** New `_applyEmergencyCard` step: the incoming card is installed only
  when the receiving phone has no card at all (no info row and no contact rows).
  A phone that already has one keeps it — one person's medical data never
  overwrites another's. Each entry's `contact_id` is remapped through the merge's
  sender→receiver map (covering both added and matched contacts) and set to `NULL`
  when the referenced contact did not travel; the name and number are snapshotted
  in the entry, so the card still shows and dials.
- Both `replaceAllFromBundle` and `applyBundle` now call
  `EmergencyInfoRepository.pushMirror()` afterwards, so the lock-screen card is
  rebuilt from the new rows instead of showing the old one until the next app
  start. The push is best-effort and already swallows failures.

**`lib/screens/sync/send_to_device_screen.dart`** — "Emergency info card" added to
the share tick list, deliberately **off by default**.

**Help and docs**

- `lib/screens/help/emergency_info_help_screen.dart` — replaced the "the card stays
  on this phone" bullet: it is in a password-protected backup, and travels on a
  Full Sync or when ticked, and the other phone only takes it if it has no card.
- `lib/screens/help/backup_help_screen.dart` — the card is in the "what the backup
  holds" list.
- `lib/screens/help/p2p_sync_help_screen.dart` — the card is in "what gets synced",
  with the never-overwrite rule spelled out.
- `docs/security.md` — notes that only the master record is transportable (inside
  the already-encrypted backup / sync payload). The plaintext lock-screen copy is
  never transported; the receiving phone rebuilds it through the same
  `toMirrorJson` choke point, so its own per-field switches still decide what is
  published.

No DB schema or sync-protocol version bump was needed: the tables already exist at
DB v22, and mismatched app versions are already refused by the existing
`dbVersion` gate.

## Tests

- `test/backup_service_test.dart` — the round-trip test now seeds a card (with a
  linked entry, a hand-typed entry, and a switched-off field) and asserts it is
  restored verbatim with `contact_id` intact. New test: a payload without the
  emergency tables replaces the contacts but leaves the phone's card untouched.
- `test/p2p_bundle_test.dart` — new tests: the card installs onto a phone with none,
  with `contact_id` remapped to an added contact's new id, to a matched contact's
  existing id, and to `NULL` for a contact that did not travel; a phone that
  already has a card keeps its own.

## Verified

- `flutter analyze` — no issues.
- `flutter test test/backup_service_test.dart` — 5 passed.
- `flutter test test/p2p_bundle_test.dart` — 11 passed.
- `flutter test test/emergency_info_test.dart` — 13 passed.
