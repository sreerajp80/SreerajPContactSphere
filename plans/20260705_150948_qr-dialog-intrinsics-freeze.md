# Fix: "Share as QR code" shows nothing and freezes the screen

**Status:** completed

## Files to be changed

- `lib/widgets/qr_share_dialog.dart` — the only code change.
- `change_log/` — new entry after implementation (per workflow).

## The issue (diagnosed on-device, moto g54 5G / Android 15, debug dev-flavor build)

Tapping **Share → Share as QR code** on a contact closes the bottom sheet and then
*nothing* appears. Worse, the whole app looks frozen afterwards (taps do nothing)
until Back is pressed.

Root cause, confirmed by attaching to the running app's Dart VM service and pulling
the widget/render trees plus the structured `Flutter.Error` event while frozen:

```
LayoutBuilder does not support returning intrinsic dimensions.
thrown during performLayout()
AlertDialog ← ... ← qr_share_dialog.dart:55
#2 _RenderLayoutBuilder.computeMaxIntrinsicHeight
```

- `AlertDialog` sizes its content with `IntrinsicWidth`, which queries the
  content's intrinsic dimensions during layout.
- `qr_flutter`'s `QrImageView` builds a `LayoutBuilder` internally
  (qr_flutter 4.1.0, `qr_image_view.dart` → `LayoutBuilder`), and a
  `LayoutBuilder` **asserts** when asked for intrinsic dimensions.
- The assertion is thrown during `performLayout()` on **every frame**, so the
  frame aborts before paint each time: the dialog route is pushed (its
  transparent `ModalBarrier` eats all taps → "app frozen"), but neither the
  dialog nor the barrier dim is ever painted, and the screen stops updating.
  The render dump shows the dialog subtree stuck with `size: MISSING` /
  `NEEDS-LAYOUT`.
- Nothing is printed to logcat because the error is reported through the VM
  service `Extension` stream (`Flutter.Error`), which is why this looked like a
  silent no-op.
- Note: in a true release build the assert is compiled out and `LayoutBuilder`
  intrinsics return 0.0, so the dialog would render there — the freeze hits
  debug/profile builds (how the app is normally run from the IDE). The fix below
  is correct for all build modes.

## The fix

In `lib/widgets/qr_share_dialog.dart`, give the `QrImageView` a **tight** box so
the intrinsic-size query never reaches the internal `LayoutBuilder`:

```dart
child: SizedBox.square(
  dimension: 240,
  child: QrImageView( ... unchanged ... ),
),
```

`RenderConstrainedBox` short-circuits intrinsic queries when its constraints are
tight (returns 240 directly, never recursing into the child), which is the
standard fix for `QrImageView` inside `AlertDialog`. Everything else in the
dialog (payload building, error state for oversized contacts, the Share-as-PNG
path through `QrShareService`, which uses `QrPainter` directly and is unaffected)
stays as is.

## Verification plan

1. `flutter analyze` and `flutter test` stay clean.
2. Rebuild the dev-flavor debug APK, install on the attached moto g54, drive the
   UI via adb (contact → Share → Share as QR code) and screenshot: the dialog
   must show the scannable QR on the white card, and Close/Share must work.

## Note on the device state

To diagnose this I installed a freshly built **dev-flavor debug** APK over the
installed `in.sreerajp.contact_sphere.dev` app (data preserved). If the
previously installed binary was something other than a debug build, re-deploy it
after the fix as you prefer.
