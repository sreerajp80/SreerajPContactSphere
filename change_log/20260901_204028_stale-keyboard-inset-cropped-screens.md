# Fix: screens cropped after a call interrupts the keyboard

Implements `plans/20260901_203057_stale-keyboard-inset-cropped-screens.md`.

## Problem

After searching in Contacts with the keyboard up and being interrupted (an incoming
call, the in-call screen, the app going to the background), every tab was drawn short:
a truncated list, a blank band about one keyboard high, and the bottom bar still at the
true bottom — with the FAB and the dialer's Favorites card overlapping the content.
Restarting the app cleared it.

The cause is a stale `MediaQuery.viewInsets.bottom`: the IME is dismissed by the system
while the activity is paused and relayouting (show-when-locked flags flip, the call can
come up over the keyguard, the task is moved to the back when it ends), and that inset
update never reaches the engine. Every `Scaffold` then shrinks its body by a keyboard
that is not there, while leaving the bottom bar pinned at the bottom.

## What changed

**`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**

- Added `requestInsetRefresh()`: posts `window.decorView.requestApplyInsets()` so Android
  dispatches the current insets again. Fully guarded — it can never disturb call handling.
- Called from `onResume()` and from `onCallChanged()` right after `applyShowWhenLocked(...)`,
  the two moments the window is known to change underneath the IME.

**`lib/widgets/keyboard_inset_guard.dart` (new)**

- `KeyboardInsetGuard`: ignores a bottom view-inset that no text field asked for, and
  hands the swallowed system-bar padding back. It watches `FocusManager` and only clamps
  while there is clearly no text focus; the focus test walks *up* from the focused node
  looking for an `EditableText` (walking down would match everything, because with
  nothing focused the primary focus is the root scope). When the focus cannot be
  inspected it passes the inset through unchanged.

**`lib/main.dart`**

- Wrapped the app in `KeyboardInsetGuard` inside `MaterialApp.builder`, above the
  `Navigator`, so every route is covered. This is the self-heal: even if an inset update
  is lost again, the next frame is correct instead of staying broken until a restart.
- Added `_dismissKeyboard()`, called at the top of `_onCall` (a call must not leave a
  search field holding the keyboard open behind it) and whenever the app leaves the
  foreground in `didChangeAppLifecycleState`. This removes the situation that strands the
  inset in the first place.

**`test/keyboard_inset_guard_test.dart` (new)**

Three widget tests against a window that reports a 300px keyboard inset:
a stale inset with nothing focused is ignored (body keeps the full height), a real
keyboard still shrinks the body while a field is focused, and the inset comes back when
the field is unfocused.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/keyboard_inset_guard_test.dart` — 3 passed.
- `flutter test test/widget_test.dart` — passed.
- `flutter build apk --flavor dev --debug` — built (the Kotlin change compiles).

**Not yet verified on the device.** Reproducing needs a real incoming call while the
Contacts search keyboard is open. Step 0 of the plan (reading the live
`viewInsets.bottom` while the screen is wrong) was not run for the same reason, so the
diagnosis remains inferred from the screenshots and the code — though the Dart guard
corrects the symptom whatever set the inset.
