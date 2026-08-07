# BLE Receive Handshake & Photo Inclusion

**Implements plan:** `plans/20260806_154141_ble_receive_handshake_photos.md`

## What changed

### Issue 1 fixed: Authentication challenge on BLE receive

**New file:** `lib/widgets/ble_receive_challenge_dialog.dart`
- Dialog that gates incoming BLE transfers with authentication
- Adapts to the app's lock mode:
  - `LockMode.appPin` → PIN keypad challenge (reuses `PinKeypad` + `AppPinService`)
  - `LockMode.deviceLock` → biometric/credential challenge (reuses `AuthService`)
  - `LockMode.none` → consent dialog ("Allow transfer from [sender]?")
- Shows sender name and signal strength in all three variants

**Modified:** `lib/screens/ble_receive_screen.dart`
- Added `_Phase.authenticating` enum value
- Inserted authentication gate in `_receiveFrom()` *before* the GATT connection
- On authentication failure or decline, returns to the scan list — no data transferred

### Issue 2 fixed: Photos now included in BLE payloads

**Modified:** `lib/widgets/ble_share_dialog.dart`
- `BleShareDialog` now takes a `contacts` list instead of a pre-built `payload`
- Added `_buildPayload()` that builds the vCard with the current `_includePhoto` setting
- Added user-facing "Include photos" checkbox (visible before transfer starts)
- Single-contact shares default to photos on; batch shares default to photos off
- Toggling the checkbox restarts advertising with the new payload

**Modified:** `lib/services/ble_protocol.dart`
- Raised `maxPayloadBytes` from 1 MB to 10 MB to accommodate base64 photo data

## Verification

- `flutter analyze` on all 4 files: **No issues found**
