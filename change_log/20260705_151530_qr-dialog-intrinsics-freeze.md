# Change log: fix "Share as QR code" showing nothing (and freezing the app)

Implements [plans/20260705_150948_qr-dialog-intrinsics-freeze.md](../plans/20260705_150948_qr-dialog-intrinsics-freeze.md).

## What changed

- `lib/widgets/qr_share_dialog.dart` — wrapped the `QrImageView` in a tight
  `SizedBox.square(dimension: 240)` (with a comment explaining why the box is
  load-bearing). The `errorStateBuilder` fallback lost its own fixed-size
  `SizedBox` since the tight parent now provides the 240×240 bounds.

## Why

`AlertDialog` measures its content with `IntrinsicWidth`; `qr_flutter`'s
`QrImageView` (4.1.0) is built around a `LayoutBuilder`, which asserts with
"LayoutBuilder does not support returning intrinsic dimensions" when asked for
intrinsics. The assert fired during `performLayout()` on **every frame**, so in
debug/profile builds the frame aborted before paint each time: the dialog route
was up (its transparent barrier ate all taps — the app appeared frozen until
Back), but neither the dialog nor the barrier dim ever painted, and nothing was
written to logcat (the error only surfaced on the VM-service `Flutter.Error`
extension stream). A tight `SizedBox` answers the intrinsic query itself
(`RenderConstrainedBox` short-circuits on tight constraints), so the
`LayoutBuilder` is never asked.

Diagnosed live on a moto g54 5G (Android 15): drove the UI over adb, attached to
the Dart VM service while frozen, and pulled the widget/render trees (dialog
subtree stuck at `size: MISSING` / `NEEDS-LAYOUT`) plus the structured error
event.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 68 tests pass (pre-existing `MissingPluginException`
  host-test noise unchanged).
- On-device (dev-flavor debug build): contact → Share → "Share as QR code" now
  shows the scannable QR on its white card with the dimmed barrier; Close
  dismisses and the app stays responsive.

## Note

Diagnosis and verification installed a locally built **dev-flavor debug** APK
over the installed `in.sreerajp.contact_sphere.dev` (app data preserved).
