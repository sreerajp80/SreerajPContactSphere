# Change log: vCard open/import + share as vCard + share as QR + bulk vCard export/import

Implements [plans/20260703_183113_vcard-open-and-share-vcard-qr.md](../plans/20260703_183113_vcard-open-and-share-vcard-qr.md).

## What changed

### New files

- `lib/services/vcard_service.dart` — vCard 3.0 build/parse. Maps the app `Contact`
  through the same `DeviceContactService` mappers the device sync uses, then
  serializes with `flutter_contacts`' pure-Dart vCard writer/reader
  (`FlutterContacts.vCard.export/exportAll/import`). Also builds the QR payload:
  a trimmed vCard (never a photo; socials, then street addresses dropped when the
  text would exceed ~1200 chars and scan poorly).
- `lib/services/qr_share_service.dart` — renders the QR payload to a 1024px
  black-on-white PNG (opaque background + quiet zone for scannability) in the temp
  dir and opens the system share sheet.
- `lib/widgets/qr_share_dialog.dart` — dialog showing the scannable QR on-screen
  (white card in both themes) with a Share-as-image button.
- `test/vcard_service_test.dart` — 4 host-side tests: single-contact round-trip,
  whole-book export/re-import, photo exclusion from QR payloads, QR trimming.

### Modified files

- `pubspec.yaml` — added `qr_flutter: ^4.1.0` (pure Dart, no native code).
- `lib/services/device_contact_service.dart` — exposed the private app↔device
  mappers as `mapToDevice()` / `mapToApp()` for VCardService; `_toDevice` gained an
  `includePhoto` flag; `_persistPhoto` now generates a unique filename when the
  source contact has no device id (vCard-parsed contacts).
- `lib/services/export_import_service.dart` — `exportContactsVcf()` (all contacts,
  photos included, single multi-contact `.vcf` → share sheet) and
  `importContactsVcf()` / `importVCardText()` (file pick → parse → save through
  `ContactSyncService`, so imports land in the app DB **and** the device book —
  unlike the CSV import, which is app-DB only).
- `android/app/src/main/AndroidManifest.xml` — intent filters registering the app
  for vCards: `ACTION_VIEW` on `text/x-vcard` / `text/vcard` / `text/directory`,
  and `ACTION_SEND` with a vCard stream.
- `android/.../MainActivity.kt` — `handleVCardIntent()` on create/new-intent reads
  the vCard stream (20 MB cap), parks the text, and nudges Flutter over a new
  `contact_sphere/vcard` MethodChannel; `getPendingVCard` is a one-shot collect.
- `lib/main.dart` — listens on the vCard channel (cold-start poll after first
  frame + warm `vcardReceived` nudge). One contact → Add/Edit screen pre-filled
  for review (Save runs the normal two-way sync); multiple → confirm dialog, then
  bulk import through `ContactSyncService`.
- `lib/screens/contact_detail_screen.dart` — Share action in the app bar: bottom
  sheet offering "Share as vCard (.vcf)" (temp file → system share sheet) and
  "Share as QR code" (the QR dialog).
- `lib/screens/contact_list_screen.dart` — menu now has "Import CSV" /
  "Export CSV" / "Import vCard (.vcf)" / "Export vCard (.vcf)".

## Verification

- `flutter analyze` — no issues.
- `flutter test` — 50 tests: 46 pre-existing + 4 new pass; **1 pre-existing,
  unrelated failure** in `test/widget_test.dart` ("renders the home shell"): it
  asserts `find.byType(NavigationBar)`, but `home_shell.dart` deliberately
  replaced the Material `NavigationBar` with a custom bottom bar (documented in
  that file). The test was stale before this change; not touched, as it is out of
  the approved plan's scope.

## Notes

- Contacts imported from a vCard are saved through the existing two-way sync, so
  they appear in both ContactSphere and the Android contact book automatically.
- Secret/Self contacts keep their app-only rule: sharing is user-initiated and
  allowed, but imports/saves never push secret contacts to the device.
