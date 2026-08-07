# Scope the duplicates-screen SnackBar so it doesn't leak into Contacts

Implements [plans/20260703_164330_scope-duplicates-snackbar.md](../plans/20260703_164330_scope-duplicates-snackbar.md).

## Problem

After merging a duplicate set and going back to the Contacts screen, the
"Merged 1 contact" SnackBar kept showing on Contacts. The app uses a single
app-level `ScaffoldMessenger` (no `scaffoldMessengerKey` on `MaterialApp`), so a
SnackBar posted from the duplicates screen kept running its ~4s timer after the
route was popped and painted over the Contacts screen.

## Changes

`lib/screens/duplicates_screen.dart`:

- Added `final _messengerKey = GlobalKey<ScaffoldMessengerState>();` to
  `_DuplicatesScreenState`.
- Wrapped the screen's `Scaffold` in `build()` with
  `ScaffoldMessenger(key: _messengerKey, child: ...)`, giving the route its own
  messenger.
- Rewrote `_showMessage` to post through `_messengerKey.currentState`, calling
  `clearSnackBars()` before `showSnackBar(...)` so repeated merges replace rather
  than queue.

Because the `ScaffoldMessenger` now lives inside the duplicates route's subtree,
popping the route disposes it and any visible SnackBar disappears with it — the
message can no longer bleed onto the Contacts screen. This covers the back
button, the system back gesture, and the hardware back button.

## Verification

- `flutter analyze lib/screens/duplicates_screen.dart` — No issues found.
- `dart format` applied to the file.
