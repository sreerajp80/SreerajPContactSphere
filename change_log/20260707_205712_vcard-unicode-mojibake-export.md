# Change log: fix mojibake in exported vCard names (Unicode/Devanagari)

Implements plan `plans/20260707_205712_vcard-unicode-mojibake-export.md`.

## Problem

Contacts exported by the app as a `.vcf` and imported on another phone showed garbled
names (e.g. `à¤•à¤ª...`). The names are Unicode (Devanagari); the file was written as
valid UTF-8 but with **no charset declaration**, because `flutter_contacts` was used at its
default **vCard 3.0**. Many phone contact importers then decoded the bytes as Latin-1 →
mojibake.

## Fix

Export the `.vcf` files that leave the app as **vCard 2.1**. In 2.1 the `flutter_contacts`
writer tags non-ASCII values with `CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE` and encodes the
UTF-8 bytes as `=E0=A4=95`, which phone contact apps decode reliably. In-app-only payloads
(QR, BLE) stay on 3.0 (this app's reader auto-detects the version, and 2.1 quoted-printable
roughly triples the size of every non-ASCII character).

## Files changed

- **`lib/services/vcard_service.dart`**
  - Added `bool externalShare` (default `false`) to `toVCard(...)` and `toVCardAll(...)`.
  - Added `_version(externalShare)` helper: `externalShare` → `VCardVersion.v21`, else
    `VCardVersion.v3`. Forwarded the version to `FlutterContacts.vCard.export/exportAll`.
  - Documented the reasoning on the helper. The `flutter_contacts` enum stays inside this
    service (callers only pass the boolean flag).

- **`lib/services/export_import_service.dart`**
  - `_writeAndShareVcf(...)` now calls `toVCardAll(contacts, externalShare: true)`
    (whole-book / secret-book `.vcf` export).

- **`lib/screens/contact_detail_screen.dart`**
  - `_shareVcf(...)` now calls `toVCard(contact, externalShare: true)`; updated its doc
    comment (was "vCard 3.0").

- **`test/vcard_service_test.dart`**
  - New test: a Devanagari-named contact exported with `externalShare: true` produces
    `VERSION:2.1`, `CHARSET=UTF-8`, `ENCODING=QUOTED-PRINTABLE`, the `=E0=A4` bytes, and no
    bare Unicode; and `fromVCard` round-trips the name back to `परिवार`.
  - New test: the default (in-app) export still emits `VERSION:3.0`.

## Verification

- `flutter test test/vcard_service_test.dart` — all 6 tests pass (incl. the new round-trip).
- `flutter analyze` on the 4 changed files — no issues.
- Not changed: direct device writes, CSV import/export, the vCard reader (already
  auto-detects 2.1/3.0/4.0).
