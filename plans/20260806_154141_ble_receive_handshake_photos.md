# BLE Contact Syncing — Receive Handshake & Photo Inclusion

**Plan approved by user on 2026-08-06.**

## Issue

Two gaps in BLE contact syncing per `docs/feature_analysis_and_roadmap.md`:
1. No PIN/biometric challenge on the receiving side — unsolicited transfers accepted with zero authentication
2. Photos excluded from BLE payloads (`includePhoto: false` hardcoded)

## Files to change

- **[NEW]** `lib/widgets/ble_receive_challenge_dialog.dart` — Authentication gate dialog
- **[MODIFY]** `lib/screens/ble_receive_screen.dart` — Add auth challenge before fetching
- **[MODIFY]** `lib/widgets/ble_share_dialog.dart` — Add photo toggle, default on for single/off for batch
- **[MODIFY]** `lib/services/ble_protocol.dart` — Raise `maxPayloadBytes` from 1 MB to 10 MB

## Fix

1. Create `BleReceiveChallengeDialog` that checks app lock mode and shows the appropriate challenge (biometric, app PIN, or consent dialog)
2. Insert the challenge into `_receiveFrom()` in `ble_receive_screen.dart` before the GATT connection
3. Change `includePhoto: false` to use a stateful toggle in the share dialog
4. Raise the protocol's payload size cap to 10 MB for photo-bearing transfers
