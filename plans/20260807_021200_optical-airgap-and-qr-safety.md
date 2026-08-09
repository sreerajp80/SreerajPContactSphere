# Implementation Plan: 5.5 Optical Air-Gap Contact Transfer & 5.6 Contact QR Safety Check

This plan outlines the architecture, data flow, services, and UI components required to implement features 5.5 (Optical air-gap multi-frame QR streaming) and 5.6 (Safety check on scanned contact QR codes) in `smart_contacts_dialer` (ContactSphere), leveraging established patterns from sibling application `sreeraj_qr_reader`.

---

## 1. Overview & Context

### 5.5 Optical Air-Gap Contact Transfer (Size M)
- **Problem**: Single static QR codes (`QrShareDialog`) are capped at ~1200 characters (`qrMaxChars`). Large vCards (with avatars, social links, addresses, multiple numbers) or multi-contact batches cannot fit into a single readable QR code. P2P Bluetooth/BLE exchange requires hardware permissions, pairing, and enabled Bluetooth.
- **Solution**: High-throughput multi-frame animated QR streaming (AirQR).
  - **Transmitter**: Encodes full vCard(s) into systematic chunks + LT Fountain parity frames (`AIRQR|v1|...` / `AIRQR|LT1|...`) and cycles them at 10-12 FPS on screen.
  - **Receiver**: Scans animated QR frames via camera (`QrScanScreen`), decodes and reassembles blocks in real time with progress feedback, verifies CRC32 checksums, and yields complete vCard text without Bluetooth or network connectivity.

### 5.6 Safety Check on Scanned Contact QR Codes (Size S)
- **Problem**: `QrScanScreen` currently trusts whatever text it decodes and directly parses it into `Contact` models, creating vulnerabilities to over-long fields (DoS/UI lag), suspicious embedded URLs, or script/malware injection.
- **Solution**: On-device QR safety & quishing validation engine.
  - **Validation**: Scans payload for over-long field boundaries, suspicious embedded URLs (in `URL`, `NOTE`, `X-` properties), and binary/HTML injection signals.
  - **Import Preview**: Displays a Safety Status & Field Preview dialog before saving or editing, allowing users to sanitize, review, or filter out unsafe fields.

---

## 2. Component Architecture & Proposed Files

### A. New Models & Services

#### `lib/models/air_qr_frame.dart`
- Model representing single stream frame: `streamId`, `totalBlocks`, `sequenceIndex`, `isParity`, `degree`, `indices`, `checksum`, `payloadBytes`.
- Parsers for `AIRQR|v1|...` (systematic) and `AIRQR|LT1|...` (fountain parity) strings.

#### `lib/services/air_qr_service.dart`
- **Encoder**: Chunks raw UTF-8 payload into 180-byte blocks, generates systematic frames + LT fountain parity frames with CRC32 checksums.
- **Decoder**: Receives scanned frames, places systematic blocks, applies XOR reduction for parity frames, tracks completion percentage, and reassembles full string.

#### `lib/services/contact_qr_safety_service.dart`
- Inspects raw scanned payload / parsed contact fields.
- Checks:
  - **Field Length Caps**: `FN`/`N` <= 256 chars, `NOTE` <= 4096 chars, total payload <= 1 MB.
  - **URL Scanner**: Flags embedded URLs, raw IP links, executable extensions (`.apk`, `.exe`).
  - **Injection Checks**: Detects HTML/script tags (`<script>`, `javascript:`), binary control characters.
- Outputs `ContactQrSafetyReport` with risk classification (`safe`, `warning`, `highRisk`) and clean/sanitized contact instance.

### B. UI Extensions & New Widgets

#### `lib/widgets/air_qr_share_dialog.dart`
- Animated QR code dialog displaying dynamic AirQR stream.
- Controls: Play/Pause, Frame Rate slider (5-15 FPS), Block Progress indicator ("Streaming block 4/12").
- Linked from standard `QrShareDialog` as an "Air-Gap Stream (Full Card)" option.

#### `lib/widgets/contact_qr_preview_dialog.dart`
- Safety & Import Preview Dialog shown when QR code is scanned in `QrScanScreen`.
- Shows safety badge (Green / Yellow / Red), detected alerts, and full breakdown of fields (Name, Phone, Email, Note, URLs).
- Action buttons: "Import Safe Fields Only", "Review & Edit", "Cancel".

#### `lib/screens/qr_scan_screen.dart` (Modify)
- Integrated frame receiver: detects `AIRQR|` stream vs static `BEGIN:VCARD`.
- Renders live progress overlay when AirQR stream is in progress.
- Runs decoded payload through `ContactQrSafetyService` and presents `ContactQrImportPreviewDialog`.

---

## 3. Detailed Data Flow

```
+-------------------------------------------------------------------+
|                            SENDER                                 |
|  Contact / Batch -> VCardService -> AirQrService.encodePayload()  |
|                       v                                           |
|       AirQrShareDialog (Cycles frames @ 10-12 FPS)                |
+-------------------------------------------------------------------+
                                 |
                     (Camera-only Air-Gap Stream)
                                 v
+-------------------------------------------------------------------+
|                           RECEIVER                                |
|  QrScanScreen (Camera) -> AirQrService.processFrameString()       |
|                       v                                           |
|       Reassembled Payload String (CRC32 Verified)                 |
|                       v                                           |
|       ContactQrSafetyService.analyzePayload()                     |
|                       v                                           |
|  ContactQrImportPreviewDialog (Safety Badge + Field Preview)      |
|                       v                                           |
|         AddEditContactScreen / ContactSyncService                 |
+-------------------------------------------------------------------+
```

---

## 4. Verification Plan

### Automated Unit Tests
- `test/air_qr_service_test.dart`:
  - Test encoding large payload into systematic + LT parity frames.
  - Test out-of-order frame reception and XOR fountain decoding.
  - Test CRC32 validation and corrupted frame rejection.
- `test/contact_qr_safety_service_test.dart`:
  - Test detection of over-long fields (e.g. 50,000 char note).
  - Test detection of malicious URLs (`http://192.168.1.1/malware.apk`, `<script>alert(1)</script>`).
  - Test sanitization and clean field extraction.

### Manual Verification
- Render full contact with high-res photo via `AirQrShareDialog` on one test device.
- Scan dynamic stream with `QrScanScreen` on target device, verify live progress indicator, complete reassembly, safety preview display, and successful contact import.
