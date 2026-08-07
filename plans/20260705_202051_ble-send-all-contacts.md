# Send all contacts via Bluetooth (bulk BLE share)

**Status:** completed

## Issue

BLE contact exchange (plan `20260705_195555`, implemented) shares one contact at a time.
The user wants to send the whole address book over the same in-app Bluetooth flow. The
receiver side already handles multi-contact transfers (confirm dialog + bulk import), and
`VCardService.toVCardAll` already produces the multi-contact payload — what's missing is a
sender entry point, a generalized share dialog, and progress reporting (a whole book takes
seconds-to-minutes at BLE read speeds, so both sides need to show progress and the sender's
idle timeout must not kill a live transfer).

## Design

- **Entry point:** contacts list overflow menu → **"Send all via Bluetooth"** (below
  "Receive via Bluetooth"). Loads contacts with
  `ContactRepository.getAllContacts(includeSecret: AppSettings.includeSecretInExport)` —
  the same secret-contacts rule as the CSV/.vcf exports — builds
  `VCardService().toVCardAll(contacts, includePhoto: false)`, and opens the share dialog.
  Empty book → snackbar, no dialog.
- **Generalized dialog:** `BleShareDialog` gains a payload/title constructor
  (`BleShareDialog.payload({required String title, required String advertisedName,
  required Uint8List payload})` or equivalent); the existing single-contact
  `showBleShareDialog(context, contact)` becomes a thin wrapper. New
  `showBleShareAllDialog(context, contacts)` advertises as **"N contacts"** (≤13 UTF-8
  bytes fits up to "9999 contacts"), which is what the receiver's scan list shows.
- **Sender progress:** `BleShareServer.kt` includes `sent`/`total` byte counts in each
  `sending` event (one per chunk read, ~10/s — fine for an EventChannel; today `sending`
  fires only once). `BleShareEvent` gains optional `sent`/`total`; the dialog shows a
  percentage while sending.
- **Timeout fix (applies to single-contact too):** the dialog's 2-minute timer currently
  fires regardless of activity. Change it to an *idle* timeout: every
  connected/sending event resets it, so only "nobody connected / receiver vanished
  mid-transfer and nothing is happening" ends the session early.
- **Receiver progress:** `BleReceiveService.fetchVCard` gains an optional
  `onProgress(received, total)` callback (driven from the `assembleChunks` loop);
  `BleReceiveScreen`'s fetching state shows a determinate progress bar + percentage
  instead of the bare spinner.
- **Caps:** `BleProtocol.maxPayloadBytes` stays at 1 MB (≈2,000 photo-less contacts).
  The Kotlin `MAX_...` side needs no cap (it only serves what it was given).

## Files to change

**Modified**
- `android/.../BleShareServer.kt` — add `sent`/`total` to `sending` events (emit per
  data-chunk read instead of once).
- `lib/services/ble_share_service.dart` — parse `sent`/`total` into `BleShareEvent`.
- `lib/services/ble_receive_service.dart` — `fetchVCard({onProgress})` wired through the
  chunk loop.
- `lib/widgets/ble_share_dialog.dart` — payload/title generalization, percentage while
  sending, idle-reset timeout; single-contact API preserved.
- `lib/screens/ble_receive_screen.dart` — determinate progress while receiving.
- `lib/screens/contact_list_screen.dart` — "Send all via Bluetooth" menu item + handler
  (loads contacts, respects `includeSecretInExport`, opens the bulk dialog).
- `test/ble_protocol_test.dart` — cover `assembleChunks` progress callbacks if the loop
  changes shape (progress is surfaced from the existing loop; add a test asserting the
  callback sequence).
- `docs/known-gaps.md`, `docs/architecture.md` — note bulk send.

No schema, manifest, or pubspec changes.

## Risks / notes

- Transfer time: ~5–15 KB/s through read requests. 500 contacts ≈ 250 KB ≈ 20 s–1 min.
  Progress UI + idle (not absolute) timeout make this acceptable; no protocol change.
- The receiver's existing bulk-import confirm dialog and `ContactSyncService` loop are
  reused untouched; imports also push to the device book, same as a multi-contact `.vcf`.
- Books beyond ~2,000 contacts would hit the 1 MB receiver cap — out of scope unless the
  user's book is that large.
- On-device verification still requires two physical phones.

## After implementation

Write `change_log/<timestamp>_ble-send-all-contacts.md` referencing this plan; flip this
plan's status to `completed`.
