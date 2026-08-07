# Scope the duplicates-screen SnackBar so it doesn't leak into Contacts

**Status:** completed

## Issue

After merging a duplicate set and navigating back to the Contacts screen, the
"Merged 1 contact" SnackBar keeps showing on the Contacts screen.

Root cause: `MaterialApp` in [lib/main.dart](../lib/main.dart) does not set a
`scaffoldMessengerKey`, so the whole app shares one default app-level
`ScaffoldMessenger`. `DuplicatesScreen._showMessage`
([lib/screens/duplicates_screen.dart:196-199](../lib/screens/duplicates_screen.dart))
calls `ScaffoldMessenger.of(context).showSnackBar(...)`, which enqueues the
SnackBar on that app-wide messenger. The default SnackBar duration is ~4s, so
when the user taps back before it expires, the same SnackBar is still visible —
now painted over the Contacts screen. It is not re-fired; it simply outlives its
own screen.

## Files to change

- `lib/screens/duplicates_screen.dart` — scope SnackBars to this screen.

## Fix

Give `DuplicatesScreen` its own `ScaffoldMessenger` so its SnackBars are owned by
the route and disappear when the route is popped (covers the back button, the
system back gesture, and the hardware back button uniformly).

1. Add a messenger key to the state:
   `final _messengerKey = GlobalKey<ScaffoldMessengerState>();`
2. Wrap the screen's existing `Scaffold` in `build()` with
   `ScaffoldMessenger(key: _messengerKey, child: Scaffold(...))`.
3. Change `_showMessage` to post via the local messenger and replace any current
   SnackBar (so repeated merges don't queue up):
   ```dart
   void _showMessage(String msg) {
     if (!mounted) return;
     _messengerKey.currentState
       ?..clearSnackBars()
       ..showSnackBar(SnackBar(content: Text(msg)));
   }
   ```

Because the `ScaffoldMessenger` now lives inside `DuplicatesScreen`'s subtree,
popping the route disposes it and any visible SnackBar vanishes with it — nothing
leaks onto the Contacts screen.

## Notes / non-goals

- No behavioural change to merging, loading, or the Contacts screen.
- Other screens keep using the app-level messenger; only the duplicates flow,
  which is the reported leak, is scoped. If desired later, the same pattern can
  be applied app-wide, but that is out of scope here.
- `flutter analyze` and a manual merge-then-back check after the change.
