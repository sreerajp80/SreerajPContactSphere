# In-call screen shows dark screen instead of the calling card

**Status:** completed

## Issue

Sometimes the calling screen is dark and the caller's calling card (or profile
photo) is not shown. It happens most when the user is in another app and a call
comes in.

## Cause

In `lib/screens/in_call_screen.dart`, `_resolveName` finds the image path and
checks only that the file exists. It then sets `_resolvedImagePath`, and the
screen switches to "photo mode" right away:

- the gradient is removed,
- the avatar is hidden (`showAvatar: !hasImage`),
- a dark black scrim is drawn,
- `Image.file(...)` is expected to paint the photo under the scrim.

But `Image.file` has no `errorBuilder` and no retry. If decoding the photo fails
or is slow, only the dark scrim is left. That is the dark screen.

Why it fails more when another app is open:

1. The call screen is pushed while our app is still in the background (no
   drawing surface yet). Image decoding and upload to the GPU can fail or stall
   at that moment. A failed image is never tried again for that call.
2. Calling card photos are often full camera photos (e.g. 12 MP). Decoding them
   at full size needs about 48 MB. When another app is using a lot of memory,
   this is slow or can fail.

## Files to change

- `lib/screens/in_call_screen.dart`
- `test/screens/in_call_screen_test.dart` (only if a small widget test fits the
  existing test setup; otherwise skipped and noted in the change log)

## Fix plan

1. **Only enter photo mode after the photo has really loaded.**
   Add a helper `_loadBackdrop(path, number)` that builds the image provider and
   waits for its first frame (resolve the `ImageStream`, listen for image or
   error). Only on success set `_resolvedImagePath`. Until then the screen shows
   the gradient + avatar as it does today for contacts with no photo. So the
   screen is never a dark scrim with nothing behind it.
2. **Decode at screen size, not full camera size.**
   Wrap the file image in `ResizeImage` using the screen width × pixel ratio.
   Use the same provider for loading and for painting, so the cached image is
   reused. This makes decoding much faster and lighter.
3. **Retry when the app comes to the front.**
   Make the screen a `WidgetsBindingObserver`. If loading failed, remember the
   path. On `AppLifecycleState.resumed`, evict that image from the cache and try
   again (only if the call's number has not changed).
4. **Safety net while painting.** Add an `errorBuilder` to the `Image` widget that
   paints the gradient instead of nothing, in case the cached image goes bad
   later.
5. Keep all current guards: the number-change check (`_resolvedFor`), the
   conference rule (no photo), and the mood-gradient fallback when there is no
   photo.

## Not in scope

- No database, native (Kotlin) or settings changes.
- Resizing the stored photo file on save (could be a later improvement).

## Checks

- `dart format`, `flutter analyze` (zero warnings), `flutter test`.
- On device: open another app, get a call from a contact with a calling card —
  the photo should appear (gradient + avatar at most briefly, never a dark screen).
