# Secret-contacts export controls in Settings → Contacts

**Status:** completed

## Issue

Both export actions (`Export CSV`, `Export vCard (.vcf)` in the contact-list overflow menu)
unconditionally export **all** contacts, secret ones included
(`getAllContacts(includeSecret: true)` in `lib/services/export_import_service.dart:42,93`).
The user has no control over whether secret contacts leave the phone as part of a normal
export, and no way to export *only* the secret contacts separately.

## Desired behavior

1. New setting under **Settings → Contacts**: **"Include secret contacts in export"**
   (a persisted on/off switch).
   - **ON** → the regular Export CSV / Export vCard actions include secret contacts
     (today's behavior).
   - **OFF** (default) → regular exports contain non-secret contacts only.
2. New action under **Settings → Contacts**: **"Export secret contacts"** with two
   choices, **CSV** and **vCard (.vcf)** — exports *only* the secret contacts.
   - This action is **disabled (greyed out)** while the include-in-export switch is ON
     (secrets already ride along with the normal export, so a separate secret export is
     redundant and the UI says so).
   - When the switch is OFF, tapping it exports the secret contacts only.
   - Because viewing secret contacts is gated by device authentication
     (`AuthService.authenticate()`, same as the lock icon on the contact list), the
     secret-only export will **prompt for biometric/PIN auth first** and abort if it
     fails. (Without this, the settings screen would be a way to exfiltrate secret
     contacts without ever unlocking them.)

Note the default OFF is a deliberate behavior change: after this lands, the existing
Export CSV/VCF menu items stop including secret contacts until the user turns the new
switch on.

## Files to change

1. **`lib/state/app_settings.dart`**
   - Add persisted key `_kIncludeSecretInExport = 'include_secret_in_export'`.
   - Add field/getter `includeSecretInExport` (default `false`), load it in `load()`,
     and add `setIncludeSecretInExport(bool)` following the existing setter pattern
     (update, `notifyListeners()`, persist, swallow prefs errors).

2. **`lib/repositories/contact_repository.dart`**
   - Extend `getAllContacts` to support a secret-only fetch:
     `getAllContacts({bool includeSecret = false, bool secretOnly = false})` —
     `secretOnly: true` uses `where: 'is_secret = 1'`. (Smallest change; no new enum.)

3. **`lib/services/export_import_service.dart`**
   - `exportContacts()` / `exportContactsVcf()` gain a `{bool includeSecret = false}`
     parameter and pass it through to the repository instead of the hard-coded `true`.
   - New `exportSecretContacts()` and `exportSecretContactsVcf()` — same temp-file +
     share-sheet flow, fetching with `secretOnly: true` and naming the files
     `secret_contacts_export_<timestamp>.csv|.vcf`. If there are no secret contacts,
     throw a friendly message (surfaced by the caller) instead of sharing an empty file.

4. **`lib/screens/contact_list_screen.dart`**
   - In `_handleMenu`, cases `'export'` / `'export_vcf'` read
     `context.read<AppSettings>().includeSecretInExport` and pass it to the export
     service (add the `provider` import).

5. **`lib/screens/contacts_settings_screen.dart`**
   - Add a **"Include secret contacts in export"** switch card bound to
     `AppSettings.includeSecretInExport` via `Consumer<AppSettings>` (styled like the
     existing cards, with a one-line explanatory subtitle).
   - Add an **"Export secret contacts"** card with CSV and vCard actions:
     - greyed out + non-tappable while the switch is ON (subtitle explains why);
     - when enabled: authenticate via `AuthService`, then run the secret-only export,
       showing snackbar feedback on failure/"no secret contacts".
   - Screen stays a `StatelessWidget` where possible; the new tiles rebuild through
     `Consumer<AppSettings>`.

## Not changing

- Import flows, vCard/CSV formats, and the overflow-menu items themselves stay as-is.
- No auth prompt is added to the *regular* export when the include switch is ON — turning
  the switch on is the explicit user consent (can add auth there too if desired).

## Verification

- `flutter analyze` (expect only the pre-existing known-gaps errors, per docs/known-gaps.md).
- Manual: toggle persists across restart; regular export honors the toggle; secret-only
  export disabled state follows the toggle; auth prompt appears before secret export.
