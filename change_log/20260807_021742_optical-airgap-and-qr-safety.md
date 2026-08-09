# Change Log: 5.5 Optical Air-Gap Contact Transfer & 5.6 Contact QR Safety Check

- **Date**: 2026-08-07 02:17:42
- **Plan Reference**: `plans/20260807_021200_optical-airgap-and-qr-safety.md`

## Summary of Changes

Implemented feature 5.5 (Optical Air-Gap Contact Transfer) and feature 5.6 (Safety Check on Scanned Contact QR Codes) in ContactSphere, reusing proven protocols from `sreeraj_qr_reader`.

### Files Created:
1. **`lib/models/air_qr_frame.dart`**: Model and parser for systematic (`v1`) and fountain parity (`LT1`) AirQR frames.
2. **`lib/services/air_qr_service.dart`**: Optical Fountain & Systematic encoding/decoding engine with CRC32 checksum verification and XOR Gaussian elimination reduction.
3. **`lib/services/contact_qr_safety_service.dart`**: Safety and quishing validation engine inspecting overlong field boundaries, raw IP URLs, executable links, code injection, and risk scoring.
4. **`lib/widgets/air_qr_share_dialog.dart`**: Animated QR stream dialog cycling frames at 5/10/15 FPS with Play/Pause controls.
5. **`lib/widgets/contact_qr_preview_dialog.dart`**: Security report & import preview dialog displaying risk badges, detected signals, and field summary.
6. **`test/air_qr_service_test.dart`**: Unit tests for AirQR systematic & fountain parity frame encoding, parsing, CRC32 checksums, and stream reassembly.
7. **`test/contact_qr_safety_service_test.dart`**: Unit tests for overlong field detection, malicious link scanning, script injection flags, and field sanitization.

### Files Modified:
1. **`lib/widgets/qr_share_dialog.dart`**: Added button launching `showAirQrShareDialog` for contactless high-throughput transfer.
2. **`lib/screens/qr_scan_screen.dart`**: Integrated real-time AirQR stream frame collector with progress overlay (percentage, block count, FPS indicator) and routed scanned payloads through `ContactQrSafetyService` and `showContactQrPreviewDialog`.

## Verification Results

- `flutter analyze`: Passed (0 issues found).
- `flutter test test/air_qr_service_test.dart test/contact_qr_safety_service_test.dart`: All 9 tests passed.
