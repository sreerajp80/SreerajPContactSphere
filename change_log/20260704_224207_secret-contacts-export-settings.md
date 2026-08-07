# Secret-contacts export controls in Settings → Contacts

Implements [plans/20260704_215550_secret-contacts-export-settings.md](../plans/20260704_215550_secret-contacts-export-settings.md).

## What changed

1. **`lib/state/app_settings.dart`**
   - New persisted setting `includeSecretInExport` (key `include_secret_in_export`,
     default `false`) with getter, loader in `load()`, and
     `setIncludeSecretInExport(bool)` following the existing setter pattern.

2. **`lib/repositories/contact_repository.dart`**
   - `getAllContacts` gained a `secretOnly` parameter (`where: 'is_secret = 1'`,
     overrides `includeSecret`) for the secret-only export.

3. **`lib/services/export_import_service.dart`**
   - `exportContacts()` / `exportContactsVcf()` now take `{bool includeSecret = false}`
     instead of hard-coding `includeSecret: true` — regular exports exclude secret
     contacts unless the new setting is on. **Behavior change:** with the setting at
     its default (off), Export CSV / Export vCard no longer contain secret contacts.
   - New `exportSecretContacts()` / `exportSecretContactsVcf()` export only secret
     contacts (temp file `secret_contacts_export_<timestamp>.csv|.vcf` + share sheet),
     throwing `StateError` when there are none.
   - Shared file-write/share-sheet logic extracted into `_writeAndShareCsv` /
     `_writeAndShareVcf`.

4. **`lib/screens/contact_list_screen.dart`**
   - The `export` / `export_vcf` menu cases read
     `context.read<AppSettings>().includeSecretInExport` and pass it to the service.

5. **`lib/screens/contacts_settings_screen.dart`**
   - New **"Include secret contacts in export"** switch card bound to `AppSettings`
     (tapping the card or the switch toggles it).
   - New **"Export secret contacts"** card with CSV and vCard (.vcf) buttons:
     disabled with an explanatory subtitle while the include switch is on; when
     enabled, requires device authentication (`AuthService`) before exporting, and
     shows snackbar feedback for auth failure, "No secret contacts to export", and
     export errors.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 46 passing; 1 pre-existing, unrelated failure
  (`test/widget_test.dart` expects a Material `NavigationBar`, but `HomeShell`
  intentionally replaced it with a custom bottom bar — stale test, not touched by
  this change).
