# BLE contact exchange (share + receive over Bluetooth LE)

**Status:** completed

## Issue

`flutter_blue_plus` has been a declared dependency since the 2026-06-25 scaffold build-out,
with the Android 12+ split Bluetooth permissions already in the manifest, but nothing uses it:
there is no scan/pair UI and no way to exchange a contact between two phones over Bluetooth.
`docs/known-gaps.md` lists it under "Still not integrated". This plan builds the feature.

## Design

Two phones, two roles:

- **Sender** ("Share via Bluetooth" on the contact detail share sheet) advertises the contact
  and serves its vCard.
- **Receiver** ("Receive via Bluetooth" in the contacts list overflow menu, beside
  "Scan QR code") scans for nearby senders, connects, downloads the vCard, and runs the exact
  same review/import flow the QR scanner and `.vcf`-intent path use.

### Why a native Kotlin peripheral for the send side

`flutter_blue_plus` 2.x implements the **central** role only — it can scan, connect, and read,
but cannot advertise or host a GATT server. One side of a phone-to-phone exchange must be a
peripheral. Rather than adding a second BLE plugin, the sender side is a small native Kotlin
class (`BleShareServer`: `BluetoothLeAdvertiser` + `BluetoothGattServer`) behind a new
method/event channel pair in `MainActivity` — the same bridge pattern the Telecom integration
already uses. The receive side uses `flutter_blue_plus` as intended, finally integrating it.

### GATT protocol (custom, minimal)

Fixed app-specific 128-bit service UUID (advertised, so receivers filter on it — only
ContactSphere senders show up in the scan list). Three characteristics:

| Characteristic | Ops | Meaning |
|---|---|---|
| `size` | read | uint32 (LE): total payload byte length |
| `offset` | write | uint32 (LE): the offset the next `data` read starts from |
| `data` | read | payload bytes from the last written offset, up to min(MTU−3, 480) |

Receiver: connect → request MTU 512 → read `size` → loop (write `offset`, read `data`) →
assemble → disconnect. Explicit-offset reads are stateless and retry-safe (a re-read after a
hiccup can't skip or duplicate bytes). GATT attribute values are capped at 512 bytes by spec,
which is why chunking is needed at all.

**Payload:** the full vCard 3.0 from `VCardService.toVCard(contact, includePhoto: false)` —
same serializer as QR/vcf share, but *untrimmed* (no QR density limit, so social links and
addresses always survive). Photo stays out in v1 to keep transfers sub-second; noted as a
future enhancement.

### Sender UX

Contact detail → Share → **"Share via Bluetooth"** → dialog (styled like `QrShareDialog`):

1. Requests Bluetooth Advertise + Connect runtime permissions; prompts to turn Bluetooth on
   if it's off.
2. Starts advertising (service UUID in the advertisement, contact's display name in the scan
   response, truncated to fit).
3. Live status from the event channel: *Waiting for a nearby device…* → *Sending…* (a
   receiver connected / is reading) → *Sent* (final chunk read).
4. Advertising and the GATT server stop when the dialog closes (dispose) or after a
   2-minute timeout.

### Receiver UX

Contacts list overflow → **"Receive via Bluetooth"** → `BleReceiveScreen`:

1. Requests Bluetooth Scan + Connect (plus Location on Android ≤ 11, where legacy BLE scans
   require it — `neverForLocation` only applies from API 31); offers to turn Bluetooth on
   (`FlutterBluePlus.turnOn`).
2. Scans filtered by the service UUID; results list shows the advertised contact name and
   signal strength, with a scanning indicator and a rescan action.
3. Tap a result → connect and download (progress indicator) → disconnect → import flow:
   - one contact → `AddEditContactScreen` pre-filled (review before save, same as QR),
   - several → confirm dialog + bulk `ContactSyncService.saveContact` (same as multi-vCard),
   - pops `true` when something was saved so the list reloads.
4. Errors (connection drop, unreadable payload) surface as a snackbar + return to scanning.

Screen naming/wording stays neutral and in-app-styled ("Share via Bluetooth", "Receive via
Bluetooth") per the app's own design system — no cloning of Android Nearby Share.

## Files to change

**New**
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/BleShareServer.kt` — advertiser +
  GATT server serving the chunked payload; emits `advertising / connected / reading /
  complete / error` events.
- `lib/services/ble_share_service.dart` — Dart bridge for the sender: method channel
  `contact_sphere/ble_share` (`start(payloadBytes, name)`, `stop`) + event channel
  `contact_sphere/ble_share_events` (status stream).
- `lib/services/ble_receive_service.dart` — receiver logic on `flutter_blue_plus`: adapter
  state, filtered scan stream, and `fetchVCard(device)` implementing the offset/data read
  loop. Chunk-assembly kept as a pure function for unit testing.
- `lib/widgets/ble_share_dialog.dart` — sender dialog (status UI, auto-stop on close).
- `lib/screens/ble_receive_screen.dart` — receiver scan/list/import screen.
- `test/ble_protocol_test.dart` — unit tests for the offset/chunk assembly and the
  size/offset uint32 encoding helpers.

**Modified**
- `android/.../MainActivity.kt` — register the two BLE channels; forward to `BleShareServer`;
  stop the server on activity destroy.
- `android/app/src/main/AndroidManifest.xml` — add `BLUETOOTH_ADVERTISE` (Android 12+ split
  permission for the sender role; scan/connect/legacy entries already present).
- `lib/screens/contact_detail_screen.dart` — third option "Share via Bluetooth" on the
  existing share bottom sheet → `showBleShareDialog(context, contact)`.
- `lib/screens/contact_list_screen.dart` — overflow menu item "Receive via Bluetooth" next to
  "Scan QR code" → pushes `BleReceiveScreen`, reloads on `true` (same as the QR path).
- `lib/constants/app_permissions.dart` — add a "Bluetooth Advertise" row
  (`Permission.bluetoothAdvertise`); update the Scan/Connect reasons to name contact exchange.
- `docs/known-gaps.md` — move BLE from "Still not integrated" to a dated Resolved entry.
- `docs/dependencies.md` — note what `flutter_blue_plus` now does (receive side) and that the
  send side is native.
- `docs/architecture.md` — brief note on the BLE bridge alongside the Telecom bridge.

No `pubspec.yaml` change (flutter_blue_plus already at `^2.3.9`) and no DB schema change
(imported contacts go through the existing save paths).

## Risks / notes

- Runtime permission matrix differs by Android version (12+ split permissions vs legacy +
  location). Handled via `permission_handler`, which the app already uses; degraded gracefully
  with explanatory UI when denied.
- Transfers are unencrypted over GATT (like handing over a QR code in public — the payload is
  the same vCard). Receiver always reviews before saving; sender advertises only while the
  dialog is open. Secret contacts: the share sheet is reachable only after the biometric gate,
  same as QR — no extra handling needed.
- Emulators generally lack BLE; verification needs two physical devices (the moto g54 can be
  one side). `flutter analyze` + unit tests + on-device smoke test of both roles.

## After implementation

Write `change_log/<timestamp>_ble-contact-exchange.md` referencing this plan; flip this
plan's status to `completed`.
