# Change log — Robust full build-out

Date: 2026-06-26 21:54:37 (local)
Implements plan: `plans/20260625_073730_robust-full-buildout.md`
(Follows the toolchain upgrade: `change_log/20260625_080332_flutter-3.41-upgrade.md`.)

Final state: `flutter analyze` clean (0 issues), `flutter test` passes, and
`flutter build apk --debug` succeeds.

## Phase 0 — Project config
- `pubspec.yaml`: added `dev_dependencies` (`flutter_test` via SDK, `flutter_lints`),
  added a `flutter:` section (`uses-material-design: true`). Added a file picker —
  chose `file_selector` over `file_picker` because modern `file_picker` needs
  `win32 ^5.9.0` which conflicts with `share_plus 13`'s `win32 ^6.0.1`.
- `lib/main.dart`: added a `const` constructor to `SmartContactsApp`.
- `test/widget_test.dart`: replaced the default counter template with a real DB-free
  smoke test that pumps `SmartContactsApp` and asserts the shell renders.

## Phase 1 — Models & compile blockers
- New models: `lib/models/address.dart`, `lib/models/official_details.dart`,
  `lib/models/call_summary.dart` (+ `lib/models/group.dart` for Phase 4).
- `lib/models/contact.dart`: added the missing model imports.
- New `lib/services/permission_service.dart`: requests contacts/phone at startup,
  exposes on-demand `ensure*` helpers; never throws (safe to call from `main`).
- `lib/main.dart`: fixed the import path, wrapped the permission call in try/catch,
  dropped the unused `provider` import.

## Phase 2 — Data layer robustness
- `lib/database/database_helper.dart`: enabled `PRAGMA foreign_keys = ON` via
  `onConfigure` (cascades were previously inert); bumped schema to **v2**, added FK
  indexes on all child tables, with a v1→v2 migration that installs them; added
  `close()`.
- `lib/repositories/contact_repository.dart`: imported all models; added
  `getContactById`, `updateContact` (transactional replace-children), and
  `deleteContact`; rewrote `mergeContacts` to re-point **every** child table
  (phone_numbers, emails, addresses, contact_groups [dedupe], call_logs, relationships
  [both sides], interactions, reminders, official_details [UNIQUE-safe]) using
  parameterized placeholders; `findDuplicates` now hydrates children and orders
  results; inserts strip client-side `id`.

## Phase 3 — Service bug fixes
- `relationship_scoring_service.dart`: imported `DatabaseHelper`; ordered interactions
  `timestamp DESC` so recency uses the true latest; clamped recency to 0–100.
- `pre_call_summary_service.dart`: imported `DatabaseHelper`/`CallSummary`; made the
  contact query `limit: 1`; guarded the empty-result `contact.first`; read nullable
  `duration` as `int?` (was an unconditional `as int` crash).
- `export_import_service.dart`: rewritten for the upgraded stack — `csv 8` `Csv`
  codec (`encode`/`decode`), `share_plus 13` `SharePlus.instance.share(ShareParams…)`,
  `file_selector` for import, writes the export to a temp file via `path_provider`;
  defensive row parsing (bounds-checked, label:value pairs, `DateTime.tryParse`).

## Phase 4 — UI build-out
- New `lib/services/auth_service.dart`: `local_auth 3.x` wrapper, fail-closed, never
  throws — gates secret contacts.
- New `lib/repositories/group_repository.dart`: groups + contact_groups CRUD with
  contact counts.
- New screens: `add_edit_contact_screen.dart` (full form: name, photo via
  `image_picker`→`FileImage`, dynamic phones/emails, personal address, official
  details, secret toggle), `contact_detail_screen.dart` (call via
  `flutter_phone_direct_caller` + pre-call summary), `groups_screen.dart`,
  `duplicates_screen.dart` (select + merge).
- `contact_list_screen.dart`: added a `const` key and public `State` type; guarded
  `_loadContacts` so a DB failure renders an empty list instead of crashing (this also
  makes the widget test pass); fixed contact photos to `FileImage` (was `AssetImage`);
  replaced deprecated `withOpacity` → `withValues`; wired the FAB, card taps, the
  groups/import/export/duplicates menu, and the biometric secret-contacts toggle;
  health card now shows the real average score; added empty/loading states.

## Phase 5 — Android permissions & build fixes
- `android/app/src/main/AndroidManifest.xml`: declared CALL_PHONE, READ_CALL_LOG,
  READ/WRITE_CONTACTS, FINE/COARSE_LOCATION, RECORD_AUDIO, USE_BIOMETRIC,
  POST_NOTIFICATIONS, READ_MEDIA_IMAGES (+ legacy READ_EXTERNAL_STORAGE ≤32), and
  BLUETOOTH_SCAN(neverForLocation)/CONNECT (+ legacy BLUETOOTH/ADMIN ≤30).
- **Removed `qr_code_scanner` and `qr_flutter`** (user-approved): `qr_code_scanner`
  1.0.1 is discontinued and declares no AGP-8 `namespace`, which failed the Gradle
  configuration. QR is out of scope; revisit with `mobile_scanner` if implemented.
- `android/app/build.gradle.kts`: enabled `isCoreLibraryDesugaringEnabled` and added
  `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` — required by
  `flutter_local_notifications 22`.
- `android/settings.gradle.kts`: AGP `8.7.3` → `8.9.1` — required by
  `androidx.core:core(-ktx):1.18.0` (Gradle wrapper 8.12 already satisfies AGP 8.9.1).

## Docs
- `docs/known-gaps.md`: rewritten to mark the former blockers resolved and list what
  remains declared-but-not-integrated (QR removed, BLE/speech/timezone/contacts-sync/
  notifications/state-management still pending).

## Verification
- `flutter analyze` → No issues found.
- `flutter test` → smoke test passes.
- `flutter build apk --debug` → builds successfully (only third-party Kotlin
  deprecation warnings from `speech_to_text`).

## Out of scope (unchanged, intentional)
QR/BLE/speech/timezone-lookup/device-contacts-sync/notification-scheduling remain
declared-but-not-integrated; `provider` stays declared but unused. These are
candidates for follow-up plans.
