# Plan — Robust full build-out of ContactSphere (smart_contacts_dialer)

**Status:** completed

Date: 2026-06-25 07:37:30 (local)
Scope chosen by user: **Full build-out** — make it compile cleanly, fix all
correctness/robustness bugs, AND add the missing feature screens, biometric gating,
and Android permissions wiring.

This is large, so it is split into phases. Each phase leaves the project in a
better, still-compiling state. I will implement phase-by-phase.

---

## The issue (summary of analysis)

The project is an early scaffold that **does not compile or analyze**. Two tiers of
problems plus missing features:

**Tier 1 — compile blockers**
- `lib/services/permission_service.dart` imported by `main.dart` but missing.
- Models `Address` and `OfficialDetails` referenced but undefined.
- Missing imports across `contact.dart`, `contact_repository.dart`, both services,
  and `export_import_service.dart`.
- `CallSummary` class undefined (returned by `PreCallSummaryService`).
- `file_picker` imported but not in `pubspec.yaml`.
- `pubspec.yaml` has no `dev_dependencies` (no `flutter_test`, `flutter_lints`) and
  no `flutter:` section.
- `test/widget_test.dart` is the default counter template (references `MyApp`).

**Tier 2 — correctness / robustness bugs**
- Foreign keys silently OFF (no `PRAGMA foreign_keys = ON`) → cascades ignored.
- `mergeContacts` only re-points phone_numbers + emails → data loss for all other
  child tables; `official_details` UNIQUE(contact_id) can collide on merge.
- `relationship_scoring_service` uses `interactions.last` on an unordered query.
- `pre_call_summary_service` null-casts (`duration as int`, `contact.first`) crash.
- `contact_list_screen` uses `AssetImage` for file-path photos (should be `FileImage`).
- No repository `getById`/`update`/`delete`; no FK indexes; unparameterized `IN (...)`.
- `AndroidManifest.xml` declares no runtime permissions.

**Missing features (build-out)**
- Add/Edit contact screen, Groups screen, Duplicate-finder screen, Contact-detail
  screen. Biometric gating for secret contacts. Wiring import/export + dialer.

---

## Files to be changed / created

### Phase 0 — Project config (make tooling work)
- `pubspec.yaml` — add `dev_dependencies` (`flutter_test`, `flutter_lints`),
  add `file_picker`, add `flutter:` section (`uses-material-design: true`).
- `test/widget_test.dart` — replace counter template with a real smoke test for
  `SmartContactsApp` (pump app, expect the AppBar title). DB-free.

### Phase 1 — Models & compile blockers
- **NEW** `lib/models/address.dart` — `Address` model (`toMap`/`fromMap`) mirroring the
  `addresses` table columns (house_name, company_name, street, post_office, city_town,
  village_municipality, postal_code, state, country, type, contact_id).
- **NEW** `lib/models/official_details.dart` — `OfficialDetails` model mirroring
  `official_details` (designation, department, contact_id).
- **NEW** `lib/models/call_summary.dart` — `CallSummary` value class with the fields
  `PreCallSummaryService` constructs (recentInteractions, lastCallDuration,
  upcomingBirthday, currentTimeInContactTimezone).
- `lib/models/contact.dart` — add imports for phone_number, email, address,
  official_details.
- **NEW** `lib/services/permission_service.dart` — `PermissionService.requestPermissions()`
  using `permission_handler` (phone, contacts, location, microphone, bluetooth as
  applicable), defensive (try/catch, never throws into `main`).
- `lib/main.dart` — import permission_service correctly; wrap permission request in
  try/catch; drop unused `provider` import (or wire it in Phase 4); add `const`/keys.

### Phase 2 — Data layer robustness
- `lib/database/database_helper.dart`
  - Add `onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON')`.
  - Bump `version` to 2 and add index creation (`contact_id` on child tables) in
    `_onCreate` + `_onUpgrade` (create indexes if upgrading from v1).
  - Add a `close()` for testability.
- `lib/repositories/contact_repository.dart`
  - Add imports for all models.
  - Add `getContactById(int id)`, `updateContact(Contact)` (transactional: update
    row + replace children), `deleteContact(int id)`.
  - Fix `mergeContacts`: re-point ALL child tables (phone_numbers, emails, addresses,
    contact_groups [dedupe on PK], call_logs, relationships, interactions, reminders,
    official_details [keep primary's, drop dup's]) inside the transaction; use
    parameterized placeholders instead of `join(',')`.
  - `set updated_at` on update.

### Phase 3 — Service bug fixes
- `lib/services/relationship_scoring_service.dart` — import DatabaseHelper; order the
  interactions query by `timestamp DESC` and take `.first` for recency (or query
  MAX(timestamp)); clamp scores defensively.
- `lib/services/pre_call_summary_service.dart` — import DatabaseHelper + CallSummary;
  guard empty `contact`/`lastCall`; read nullable `duration` safely (`as int?`).
- `lib/services/export_import_service.dart` — add imports (repository, models,
  `dart:io`); finish address/email parse round-trip enough to not crash; wrap file
  IO in try/catch; write CSV to a temp file via `path_provider` and share the file
  (current `Share.share(csv)` shares the raw string — keep but corrected) — minimal,
  goal is "compiles + safe".

### Phase 4 — UI build-out (new screens + wiring)
- `lib/screens/contact_list_screen.dart`
  - Fix photo: `FileImage(File(photoPath))` (guard existence) instead of `AssetImage`.
  - Wire AppBar menu + FAB to navigate to the new screens; wire import/export to
    `ExportImportService`; wire the lock icon to biometric toggle (Phase 4 auth).
  - Replace deprecated `withOpacity` → `withValues(alpha:)` if SDK supports, else keep.
  - Make state type public-API clean (`State<ContactListScreen>`), add keys/const.
- **NEW** `lib/screens/add_edit_contact_screen.dart` — form to create/update a Contact
  with phone numbers, emails, addresses, official details, groups, photo picker,
  is_secret toggle; persists via `ContactRepository`.
- **NEW** `lib/screens/contact_detail_screen.dart` — read-only detail view with
  call/SMS actions (`flutter_phone_direct_caller`) and pre-call summary.
- **NEW** `lib/screens/groups_screen.dart` — list/create/delete groups (needs small
  group methods in repo or a new `GroupRepository`).
- **NEW** `lib/screens/duplicates_screen.dart` — list `findDuplicates()` results and
  trigger `mergeContacts`.
- **NEW** `lib/services/auth_service.dart` — `local_auth` wrapper to gate secret
  contacts; used by the lock icon.
- Possibly **NEW** `lib/repositories/group_repository.dart` — CRUD for groups +
  contact_groups (keeps ContactRepository focused).

### Phase 5 — Android permissions
- `android/app/src/main/AndroidManifest.xml` — add `<uses-permission>` for
  `CALL_PHONE`, `READ_CONTACTS`, `WRITE_CONTACTS`, `READ_CALL_LOG`,
  `ACCESS_FINE_LOCATION`/`COARSE`, `RECORD_AUDIO`, `USE_BIOMETRIC`,
  `BLUETOOTH_*` (scan/connect for `flutter_blue_plus`), `READ_MEDIA_IMAGES`, and a
  `<queries>` entry for `tel:` dial intents as needed.

### Docs
- `docs/known-gaps.md` — update to reflect what is now implemented.
- `change_log/` — write a change log per phase (or one consolidated at the end),
  referencing this plan.

---

## Out of scope (explicitly not in this pass)
- QR generation/scan, BLE pairing flows, speech-to-text capture, timezone lookup
  implementation, device-contacts sync, notifications/reminders scheduling — these
  remain declared-but-stub. They can be follow-up plans. (Manifest permissions for
  them may still be added so future work doesn't need a manifest change.)
- Migrating from `setState` to `provider` state management — kept as local state for
  now to limit blast radius; can be a follow-up.

---

## Verification per phase
- `flutter pub get` after Phase 0.
- `flutter analyze` after each phase — target zero errors (warnings/infos triaged).
- `flutter test` after Phase 0 and at the end.
- Manual reasoning about transactions/merge correctness (no device build assumed
  unless a device/emulator is available).

---

## Approval
This plan creates ~10 new files and edits ~8 existing ones across 5 phases.
**Do you approve this plan?** On approval I'll proceed phase by phase, pausing to
report after each phase.
