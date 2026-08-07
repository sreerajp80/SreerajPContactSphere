# Send all contacts via Bluetooth (bulk BLE share)

Implements `plans/20260705_202051_ble-send-all-contacts.md`, building on the BLE contact
exchange from `change_log/20260705_201521_ble-contact-exchange.md`.

The contacts list overflow menu gained **"Send all via Bluetooth"**: the whole address
book travels as one multi-contact vCard through the existing BLE share flow. The receiver
needed no import changes — its multi-contact confirm + bulk import path (built with the
original feature) handles the transfer as-is.

## Changes

- `lib/screens/contact_list_screen.dart` — new menu item + handler: loads
  `ContactRepository.getAllContacts(includeSecret: AppSettings.includeSecretInExport)`
  (the same secret-contacts rule as the CSV/.vcf exports), snackbars on an empty book,
  and opens the bulk share dialog.
- `lib/widgets/ble_share_dialog.dart` — generalized from "takes a Contact" to "takes
  title + advertised name + payload bytes". `showBleShareDialog(context, contact)` is
  now a thin wrapper; new `showBleShareAllDialog(context, contacts)` serializes via
  `VCardService.toVCardAll(includePhoto: false)` and advertises as **"N contacts"**
  (what the receiver's scan list shows; ≤13 UTF-8 bytes fits "9999 contacts").
  While sending, the dialog shows a percentage and a determinate progress ring.
  **Timeout behavior changed (single-contact sharing too):** the 2-minute timer is now
  an *idle* timeout, re-armed by every connected/sending event — only genuine
  inactivity ends the session, never a slow in-flight whole-book transfer.
- `android/.../BleShareServer.kt` — `sending` events now fire per data-chunk read and
  carry `sent`/`total` byte counts (~10 events/s at BLE read rates; fine for an
  EventChannel). The old fire-once `sendingSent` flag is gone.
- `lib/services/ble_share_service.dart` — `BleShareEvent` gained optional
  `sent`/`total` and a `progress` getter (clamped 0–1).
- `lib/services/ble_protocol.dart` — `assembleChunks` gained an optional
  `onProgress(received, total)` callback, invoked after every chunk.
- `lib/services/ble_receive_service.dart` — `fetchVCard` forwards an `onProgress`
  callback into the chunk loop.
- `lib/screens/ble_receive_screen.dart` — the fetching state shows a determinate
  progress indicator + "Receiving… N%" once the size is known.
- `test/ble_protocol_test.dart` — new test: progress fires after every chunk, totals
  are constant, counts strictly increase, and the last call equals the payload size.
- `docs/known-gaps.md`, `docs/architecture.md` — bulk send documented.

No schema, manifest, or pubspec changes.

## Notes / limits

- Payload size: photo-less book ≈ 500 B/contact; the receiver's existing 1 MB sanity
  cap (`BleProtocol.maxPayloadBytes`) fits ≈2,000 contacts. Transfer speed is
  ~5–15 KB/s (read-request protocol) — hence the progress UI.
- Verification: `flutter analyze` clean; `flutter test` 80/80 passing (1 new);
  `:app:compileDevDebugKotlin` builds. On-device end-to-end (two physical phones)
  still pending, same as the base feature.
