# Cropped screens after an interrupted keyboard (stale bottom view-inset)

**Status:** completed

## What the user sees

After searching in Contacts (keyboard up) and being interrupted — an incoming call,
the in-call screen, the app going to the background and coming back — every tab is
drawn short:

- Contacts: only ~4 rows, then a blank band, then the bottom bar at the true bottom.
  The FAB sits at the end of the short area, overlapping a contact card.
- Recents: same short list + blank band.
- Dialer: the keypad is squeezed so the Favorites card overlaps the "1" key, then a
  blank band.

Closing and reopening the app clears it.

## What is actually happening

The blank band is roughly one keyboard height. The evidence points to
`MediaQuery.viewInsets.bottom` staying at the keyboard height after the keyboard is
already gone:

- `Scaffold` shrinks its **body** by `viewInsets.bottom`, but leaves
  `bottomNavigationBar` pinned at the true bottom of the window. That is exactly the
  shape of the bug: short content, blank band, bar at the bottom.
- The shell's body is an `IndexedStack` (`lib/screens/home_shell.dart:129`), so **all
  four tabs** inherit the same short height — which is why all three screenshots are
  wrong at once.
- The FAB belongs to the Contacts `Scaffold` (`lib/screens/contact_list_screen.dart:942`),
  so it lands at the bottom of the short body, not the screen — matching the overlap.
- The Dialer's `Column` overflows a too-short box, so its Favorites card paints over
  the keypad.
- A cold start rebuilds the engine's inset state, so restarting heals it.

Why the inset goes stale: when a call arrives, the window is changed underneath the
IME. `MainActivity.onCallChanged` calls `applyShowWhenLocked(true)`
(`android/.../MainActivity.kt:620`, `:661`), which flips `setShowWhenLocked` /
`setTurnScreenOn`; the call may also arrive over the keyguard via a full-screen intent,
and when the call ends `moveTaskToBack(true)` runs. Across that transition the IME is
dismissed by the system while the activity is paused/relayouting, and the fresh
`WindowInsets` (IME height back to 0) is never dispatched to `FlutterView`. Flutter
keeps the last value it was told.

Nothing in Dart currently unfocuses the search field or re-checks the inset on resume:
`didChangeAppLifecycleState` (`lib/main.dart:592`) only handles the app lock and Smart
Redial, and `_onCall` (`lib/main.dart:679`) pushes the in-call route with the text field
still focused.

**Note on certainty:** this is inferred from the screenshots and the code, not yet
observed live. Step 0 below proves it before anything is changed.

## Files to change

1. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` — force a
   fresh inset dispatch.
2. `lib/main.dart` — hide the keyboard when a call takes over / the app is backgrounded,
   and add an app-wide safety net that ignores a bottom inset when nothing is focused.
3. `test/` — a widget test for the safety net.
4. `change_log/` — the log file after implementation.

## Plan

### Step 0 — confirm the cause (no code change yet)

Reproduce on the device: open Contacts, tap search, get a call, end it, reopen the app.
Read `WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom` over the
Dart VM service (see the device-debugging notes) while the screen is wrong. A non-zero
value with no keyboard on screen confirms the diagnosis. If it reads zero, stop and
re-plan — the cause would then be layout, not insets.

### Step 1 — native: ask Android to re-send the insets

In `MainActivity`:

- After `applyShowWhenLocked(...)` in `onCallChanged`, and in `onResume()`, call
  `window.decorView.requestApplyInsets()` (post it to the view so it runs after the
  window settles). This makes the platform dispatch a fresh `WindowInsets` to
  `FlutterView`, which pushes the correct `viewInsets` into Flutter.
- Guard with a try/catch; it must never break call handling.

This attacks the root cause: it does not matter *why* the update was missed, the app
asks for it again at the two moments the window is known to have changed.

### Step 2 — Dart: don't leave the keyboard up when the app is taken over

In `_SmartContactsAppState`:

- At the top of `_onCall`, before pushing `InCallScreen`, drop focus:
  `FocusManager.instance.primaryFocus?.unfocus()`. A search field must not keep the IME
  alive behind a full-screen call.
- In `didChangeAppLifecycleState`, on `paused`/`inactive`, do the same.

This removes the situation that triggers the stale inset in the first place, and is
correct behaviour on its own (returning from a call should not land on a half-open
keyboard).

### Step 3 — Dart: a safety net in `MaterialApp.builder`

The builder already overrides `MediaQuery` for text scaling (`lib/main.dart:855`).
Extend that same override:

- If `media.viewInsets.bottom > 0` **and** no focused node wants the keyboard
  (`FocusManager.instance.primaryFocus?.context == null` or the focus node does not have
  `TextInputClient` — practically: `primaryFocus == null || !primaryFocus!.hasFocus ||
  primaryFocus is! FocusNode with an attached text input`), then clamp
  `viewInsets.bottom` to `0` in the copied `MediaQueryData`.
- Simpler and safer variant to implement: track "is a text field focused" with a
  `FocusManager.instance.addListener` in `initState`, keep it in a field, and clamp the
  inset when that flag is false. Rebuild on change.

This means that even if a future window transition loses an inset update again, the app
self-heals on the next frame instead of staying broken until it is restarted. It never
clamps while a text field is genuinely focused, so a real keyboard still resizes the
body as before.

### Step 4 — tests

Add a widget test that pumps the app shell with `viewInsets.bottom` forced to a large
value and no focused text field, and asserts the body still gets the full height (for
example, the Contacts list viewport height equals the screen height minus the bottom
bar). Existing widget smoke tests must still pass.

### Step 5 — verify on device

Repeat the Step 0 reproduction and confirm the screens are full height right after the
call, without restarting the app. Also check the normal cases still work: keyboard opens
and resizes the list, the dialer search field still scrolls into view, the bottom bar is
still not hidden under the phone's navigation bar (the 2026-08-29 inset fix).

## Risk

Low. Step 1 is an extra platform request with no state of its own. Step 2 only drops
focus at moments where keeping it is never wanted. Step 3 only ever *removes* a bottom
inset that no focused text field asked for; the worst case if the focus check is wrong
is that a real keyboard overlaps content, so the check must be conservative — clamp only
when there is clearly no text focus.
