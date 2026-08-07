# BLE contact exchange (share + receive over Bluetooth LE)

Implements `plans/20260705_195555_ble-contact-exchange.md`.

`flutter_blue_plus` (a dependency since the 2026-06-25 scaffold) is finally integrated:
contacts can now be exchanged phone-to-phone over Bluetooth LE. Since the plugin is
central-role only, the sender is a native Kotlin BLE peripheral; the receiver uses
`flutter_blue_plus`.

## New files

- `android/.../BleShareServer.kt` — sender peripheral: `BluetoothLeAdvertiser` (service
  UUID in the advertisement, contact name as scan-response service data, ≤13 UTF-8 bytes)
  + `BluetoothGattServer` serving the vCard over a chunked protocol (`size` read /
  `offset` write / `data` read, uint32 LE, chunks capped at min(MTU−3, 480) — GATT
  attributes max out at 512 bytes). Emits advertising/connected/sending/complete/
  disconnected/error events on the main thread; every BT call guarded against
  `SecurityException`.
- `lib/services/ble_protocol.dart` — shared wire protocol: the four fixed UUIDs
  (mirrored in Kotlin), uint32 LE encode/decode, and `assembleChunks` (stall,
  over-serve, runaway-loop, and absurd-size guards).
- `lib/services/ble_share_service.dart` — Dart bridge for the sender: method channel
  `contact_sphere/ble_share` (`start`/`stop`/`getSdkInt`), event channel
  `contact_sphere/ble_share_events` mapped to `BleShareEvent`. No-ops (returns
  `unsupported`) off Android / in host tests.
- `lib/services/ble_receive_service.dart` — receiver: adapter state + `turnOn`,
  UUID-filtered scan, sender display name from scan-response service data, and
  `fetchVCard` (connect with `License.nonprofit` + MTU 512, discover, chunked download,
  always disconnects). Failures throw user-facing `BleReceiveException`s.
- `lib/widgets/ble_share_dialog.dart` — "Share via Bluetooth" dialog: requests
  Advertise+Connect permissions, offers the system turn-on-Bluetooth consent when the
  adapter is off, advertises the photo-less `VCardService` vCard **only while open**,
  shows waiting → sending → sent, stops after a 2-minute no-taker timeout, retry action.
- `lib/screens/ble_receive_screen.dart` — "Receive via Bluetooth" screen: requests
  Scan+Connect (plus Location below Android 12, via `getSdkInt`), scans filtered on the
  share-service UUID, lists senders (advertised contact name + rough proximity), and on
  tap downloads the vCard and reuses the exact QR/.vcf review/import flow (single →
  pre-filled Add/Edit; several → confirm + bulk `ContactSyncService` import; pops `true`
  when something was saved).
- `test/ble_protocol_test.dart` — 8 tests: uint32 LE round-trip/byte order/short-input,
  chunk assembly (small chunks, single read, empty payload) and failure modes (stall,
  over-serve, maxReads, absurd size).

## Modified files

- `android/.../MainActivity.kt` — registers the two BLE channels, lazily creates
  `BleShareServer`, forwards its events, stops it in `onDestroy`.
- `android/app/src/main/AndroidManifest.xml` — added `BLUETOOTH_ADVERTISE` (Android 12+
  sender permission; Scan/Connect/legacy entries already existed).
- `lib/screens/contact_detail_screen.dart` — third share-sheet option
  "Share via Bluetooth" → `showBleShareDialog`.
- `lib/screens/contact_list_screen.dart` — overflow menu item "Receive via Bluetooth"
  (next to "Scan QR code") → `BleReceiveScreen`, reloads the list on import.
- `lib/constants/app_permissions.dart` — new "Bluetooth Advertise" row; Scan/Connect
  reasons now name contact exchange.
- `docs/known-gaps.md` — BLE moved from "Still not integrated" to wired (2026-07-05).
- `docs/dependencies.md`, `docs/architecture.md` — documented the split-role design and
  the `contact_sphere/ble_share` bridge.

## Notes / limits

- Contact **photos are not transferred** (same limit as the QR payload); everything else
  in the vCard — socials and full addresses included — goes across untrimmed.
- Verification: `flutter analyze` clean; `flutter test` 79/79 passing (8 new);
  `:app:compileDevDebugKotlin` builds. End-to-end exchange still needs a smoke test on
  **two physical devices** (emulators lack BLE) — not yet performed.
