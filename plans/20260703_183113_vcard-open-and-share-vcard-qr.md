# Plan: vCard open/import + share contact as vCard + share contact as QR code

**Status:** completed

## Background / current state (answers to the questions asked)

1. **Can the app open a vCard today?** No. Import is CSV-only
   (`lib/services/export_import_service.dart`), and `AndroidManifest.xml` has no
   intent filter for `.vcf` / `text/x-vcard`, so the app never appears in the
   "Open with" chooser for vCard files.
2. **Is a contact created in the app synced to Android contacts?** Yes, already.
   `ContactSyncService.saveContact()` pushes every save to the device address book
   via `DeviceContactService.upsertDeviceContact()` (except *secret* and *self*
   contacts, which are app-only by design), and `syncFromDevice()` pulls the device
   book into the app DB. So any contact imported from a vCard through the normal
   save path will land in both the app DB **and** the phone's contacts.
3. **Share as vCard / share as QR:** not implemented anywhere yet.

Useful lever: `flutter_contacts` (already a dependency) ships `Contact.toVCard()` and
`Contact.fromVCard()` (vCard 3.0, incl. photo), and `DeviceContactService` already has
full mappers between the app `Contact` model and `fc.Contact` (`_toDevice` / `_toApp`).
We reuse those instead of hand-writing a vCard serializer/parser.

## Features to implement

### A. Open / import a vCard (adds to app DB and phone contacts)

- Register the app for vCard files: add an intent filter to `MainActivity` for
  `ACTION_VIEW` / `ACTION_SEND` with mime types `text/x-vcard`, `text/vcard`
  (and `text/directory`), so tapping a `.vcf` in a file manager / WhatsApp / mail
  offers ContactSphere.
- In `MainActivity.kt`, read the incoming `content://` / `file://` stream, and hand
  the raw vCard text to Flutter over a small MethodChannel
  (`contactsphere/vcard_intent`), covering both cold start (initial intent) and
  warm delivery (`onNewIntent`).
- On the Dart side, parse with `fc.Contact.fromVCard()` (a `.vcf` may contain
  multiple `BEGIN:VCARD` blocks — split and parse each), map to the app `Contact`
  via a mapper exposed from `DeviceContactService`, then open the existing
  **Add/Edit Contact screen pre-filled** so the user can review and press Save.
  Saving goes through `ContactSyncService.saveContact()`, which already writes to
  both the app DB and the Android contact book — satisfying "add to app's contacts
  and phone contacts".
- Also add a manual **"Import vCard (.vcf)"** entry next to the existing CSV import
  (uses `file_selector`, already a dependency) for files not opened via intent.

### B. Share contact as vCard (through any app)

- New `VCardService` (`lib/services/vcard_service.dart`):
  `String toVCard(Contact c)` / `List<Contact> fromVCard(String text)` built on the
  `DeviceContactService` mappers + `fc.Contact.toVCard()/fromVCard()`.
- Write `<FirstName_LastName>.vcf` to the temp dir and share via
  `SharePlus.instance.share(ShareParams(files: [...]))` (same pattern as the CSV
  export) — the system share sheet lets the user pick WhatsApp, mail, Bluetooth, etc.
- Entry point: a **Share** action on `ContactDetailScreen` (app-bar/menu) offering
  "Share as vCard" and "Share as QR code".

### C. Bulk import/export of ALL contacts as vCard (alongside existing CSV)

- Extend `ExportImportService` with vCard siblings of the CSV methods:
  - `exportContactsVcf()` — serialize **all** contacts (same
    `getAllContacts(includeSecret: true)` set as the CSV export) into a single
    `contacts_export_<timestamp>.vcf` (one `BEGIN:VCARD…END:VCARD` block per
    contact, photos included), written to temp and shared via the system share
    sheet — identical pattern to `exportContacts()` (CSV).
  - `importContactsVcf()` — `file_selector` pick of a `.vcf`, split into blocks,
    parse each via `VCardService.fromVCard()`, and save each through
    `ContactSyncService.saveContact()` so imported contacts land in **both** the
    app DB and the Android contact book (unlike the CSV import, which currently
    writes only to the app DB). Returns the imported count.
- UI: wherever the current "Export CSV" / "Import CSV" actions live, add
  "Export vCard (.vcf)" / "Import vCard (.vcf)" next to them. (This subsumes the
  single-file manual import mentioned in section A.)

### D. Share contact as QR code (through any app)

- New dependency: `qr_flutter` (pure-Dart QR rendering, no network/native code).
- New `QrShareService` + a small dialog/screen: encode the contact's **vCard text**
  as the QR payload (the standard any phone camera / contacts app understands),
  render with `QrImageView` for on-screen scanning, plus a "Share" button that
  rasterizes the QR via `QrPainter.toImageData()` to a PNG in the temp dir and
  shares it with `share_plus`.
- Guard: QR capacity is ~2.9 KB — build the QR payload from a trimmed vCard (name,
  phones, emails, org/title, addresses; **no photo**) to keep it scannable.

## Files to change / create

| File | Change |
| --- | --- |
| `pubspec.yaml` | add `qr_flutter` |
| `android/app/src/main/AndroidManifest.xml` | intent filters for vCard VIEW/SEND |
| `android/app/src/main/kotlin/.../MainActivity.kt` | read vCard intent stream, MethodChannel to Flutter |
| `lib/services/vcard_service.dart` (new) | vCard build/parse via flutter_contacts + mappers |
| `lib/services/device_contact_service.dart` | expose the app↔fc.Contact mappers for reuse |
| `lib/services/qr_share_service.dart` (new) | QR payload build + PNG rasterize + share |
| `lib/widgets/qr_share_dialog.dart` (new) | on-screen QR view with Share button (app design system) |
| `lib/screens/contact_detail_screen.dart` | Share menu: "Share as vCard", "Share as QR code" |
| `lib/services/export_import_service.dart` | add `exportContactsVcf()` / `importContactsVcf()` (all contacts) |
| `lib/screens/contacts_settings_screen.dart` (or wherever CSV import/export lives) | add "Export vCard" / "Import vCard" actions beside the CSV ones |
| `lib/main.dart` | listen on the vCard MethodChannel, route to pre-filled Add/Edit screen |
| `test/` | unit tests for VCardService round-trip and QR payload trimming |

## Notes / decisions

- vCard version: 3.0 (what `flutter_contacts` emits; most interoperable on Android).
- Duplicate handling on import: reuse the existing phone-number dedup in
  `ContactSyncService` by saving through the normal path; the Add/Edit review step
  keeps the user in control.
- Secret contacts: sharing is user-initiated so it is allowed, but the QR/vCard of a
  secret contact is generated the same way — no special casing beyond what exists.

## Out of scope

- iOS (project is Android-only).
- Scanning QR codes to *receive* a contact (camera scanner) — can be a follow-up.
