# Fix: exported vCard names become mojibake on other phones (Unicode/Devanagari)

**Status:** completed

## The issue

Contacts exported by this app as a `.vcf` file and then imported on another phone show
garbled names (e.g. `à¤•à¤ª...` instead of Devanagari text). This is classic **mojibake**:

- The name is Unicode (Devanagari). Example: क = `U+0915`, UTF-8 bytes `E0 A4 95`.
- The exported file is valid UTF-8, but the **receiving** phone's contacts importer reads
  the bytes as Latin-1/Windows-1252, so `E0 A4 95` becomes `à ¤ •` → `à¤•`.

### Root cause

`ExportImportService` writes the shared `.vcf` using `VCardService`, which calls
`flutter_contacts` at its **default vCard version 3.0**. In v3.0 the package's writer emits
text values as raw UTF-8 **with no charset declaration** (its quoted-printable/charset path
runs only for vCard 2.1 — see `needsQuotedPrintable`, which returns false for v3.0). With no
charset hint in the file, many phone contact apps default to Latin-1 and mis-decode non-ASCII
names.

### The fix (why vCard 2.1)

When `flutter_contacts` writes **vCard 2.1**, any value with non-ASCII characters is emitted as:

```
N;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:...=E0=A4=95...
```

i.e. the UTF-8 bytes are quoted-printable-encoded **and** the charset is declared inline.
(Confirmed by reading the package: `QuotedPrintable.encode` does `utf8.encode` then byte-level
`=XX`.) This is the same encoding Android's stock contacts exporter uses for non-Latin names,
and essentially every phone imports it correctly. So: export the **shared/exported** `.vcf`
(the cross-device path) as vCard 2.1.

In-app, app-to-app paths (QR code, BLE) are left on v3.0 on purpose:
- They round-trip only between installs of *this* app, whose reader auto-detects the version.
- v2.1 quoted-printable roughly triples the size of each non-ASCII character, which matters for
  the QR density budget (`qrMaxChars`) and BLE payload size. No mojibake risk there because the
  same app reads them back.

## Files to change

1. **`lib/services/vcard_service.dart`**
   - Import `VCardVersion` (already available via the `flutter_contacts` import, alias `fc`).
   - Add an optional `version` parameter to `toVCard(...)` and `toVCardAll(...)`, defaulting to
     `fc.VCardVersion.v3` (keeps QR/BLE unchanged), and forward it to
     `fc.FlutterContacts.vCard.export/exportAll`.
   - Update the doc comments to note that external `.vcf` files should be exported as 2.1 for
     cross-phone Unicode compatibility.

2. **`lib/services/export_import_service.dart`**
   - In `_writeAndShareVcf(...)` call `VCardService().toVCardAll(contacts, version: fc.VCardVersion.v21)`
     (add the `flutter_contacts` import with the `fc` alias, or expose a small constant/wrapper
     from `VCardService` to avoid leaking the dependency — see "Design note").

3. **`lib/screens/contact_detail_screen.dart`**
   - The single-contact "Share as vCard (.vcf)" path (around line 147) also produces a file for
     other phones; export it as vCard 2.1 the same way.

4. **`test/vcard_service_test.dart`**
   - Add a test: a contact with a non-ASCII (Devanagari) name exported with `version: v21`
     contains `CHARSET=UTF-8` and `ENCODING=QUOTED-PRINTABLE` and the expected `=E0=A4=95`
     bytes, and that `fromVCard` round-trips the name back unchanged.
   - Keep/verify existing v3.0 tests (QR/BLE default) still pass.

## Design note (keep the dependency contained)

To avoid spreading the `flutter_contacts` `VCardVersion` type across screens/services, prefer
adding a boolean like `externalShare: true` (or a named factory) on `VCardService.toVCard/
toVCardAll` that internally selects v2.1, instead of passing the enum in from callers. Final
shape to be decided during implementation; behavior (2.1 for exported files, 3.0 for QR/BLE) is
fixed.

## Out of scope / not changed

- Direct device writes (`DeviceContactService.upsertDeviceContact` via the platform channel) —
  those are not affected by this bug.
- CSV export/import.
- The app's vCard **reader** — it already auto-detects 2.1/3.0/4.0, so importing a 2.1 file
  (ours or a phone's) keeps working.

## Verification

- `flutter test test/vcard_service_test.dart`
- Manual: export a contact whose name has Devanagari text, import the `.vcf` on another phone,
  confirm the name shows correctly.
