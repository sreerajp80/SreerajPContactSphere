# In-call screen: no more dark screen instead of the calling card

Implements plan: `plans/20260929_213349_in-call-backdrop-dark-screen.md`

## Problem

Sometimes the calling screen showed only a dark overlay, with no calling card
or profile photo. It happened mostly when a call came in while another app was
open. The screen switched to "photo mode" (dark scrim, no avatar, no gradient)
as soon as the photo file existed. If the photo then failed to decode, or was
slow, nothing was painted under the scrim, and nothing tried again.

## What changed

`lib/screens/in_call_screen.dart`:

- The photo is now decoded **before** the screen switches to photo mode
  (new `_loadBackdrop` + `_decode`). Until it is ready, and for good if it
  fails, the screen shows the gradient and avatar.
- The photo is decoded at screen size (`ResizeImage`, fit to the screen's
  longer side) instead of full camera size. This is much faster and uses far
  less memory. If the screen size reads as zero (app in background), 2400 px is
  used.
- A failed decode is remembered (`_failedBackdrop`) and retried when the app
  comes to the front. The screen is now a `WidgetsBindingObserver` for this.
- The relationship mood gradient is now resolved for every saved contact, so it
  shows while a photo is loading too (before, only for contacts with no photo).
- The `Image` widget has an `errorBuilder` that paints the gradient instead of
  nothing, as a safety net.
- `_resolvedImagePath` (a path) was replaced by `_backdropImage` (the decoded
  image provider). The number-change and conference guards are unchanged.

## Checks

- `dart format`: no changes needed.
- `flutter analyze`: no issues.
- `flutter test`: all 750 tests passed.
- No widget test added: there is no in-call screen test setup (it needs the
  Telecom stream and the database). The fix still needs to be checked on a
  device.
