# Show contact name in the call notification for both incoming and outgoing calls

**Status:** completed

## Issue

The call notification (the foreground-service notification posted by
`ContactSphereInCallService`) should show the contact's name when the number matches a
contact. Today it only does so for **incoming** calls, and only while they are ringing:

- The native side is already direction-agnostic: `updateCallerName()` in
  `ContactSphereInCallService.kt` re-posts whichever notification shape is up (ringing
  or ongoing) with the pushed name, and `showOngoingCall()` keeps `currentName` across
  the ringing→ongoing swap.
- The gap is on the Flutter side: `_resolveName()` in `lib/screens/in_call_screen.dart`
  (line ~136) pushes the resolved name to native **only when
  `_state.phase == CallPhase.ringing`**. For outgoing calls (dialing / connecting /
  active) the name is never pushed, so the ongoing-call notification shows the raw
  number. The same happens for an incoming call answered before name resolution
  completes.

A secondary staleness bug in the same path: when the call's number changes mid-session
(add-call / swap between two calls), native `showOngoingCall(number)` updates
`currentNumber` but keeps the previous `currentName`. If the new number resolves to a
contact the pushed name replaces it, but if the new number has **no** matching contact,
Dart never pushes anything (it only pushes non-null names) and native ignores blank
names — so the old contact's name stays on the notification against the wrong number.

## Files to change

1. `lib/screens/in_call_screen.dart`
2. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`
3. `lib/services/telecom_service.dart` (rename only)
4. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` (rename only)
5. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt` (comment only)

## Fix plan

1. **`in_call_screen.dart` — push the name regardless of call phase.** In
   `_resolveName()`, remove the `_state.phase == CallPhase.ringing` condition and push
   the resolved name whenever one is found (native already no-ops after the call ends
   via its `hasCall` guard). When resolution finds **no** contact for a (new) number,
   push an empty string so native clears a stale name (see 2). Update the comment to
   describe the new behavior.

2. **`ContactSphereInCallService.kt` — allow clearing a stale name.** Change
   `updateCallerName(name)` so a blank/empty name **clears** `currentName` and re-posts
   the notification (falling back to the number), instead of being ignored. A null/blank
   push with no active call remains a no-op.

3. **Naming cleanup (mechanical rename, no behavior change).** The channel method is
   named `setIncomingCallerName`, which is now misleading since it serves both
   directions. Rename to `setCallerName`:
   - `telecom_service.dart`: `setIncomingCallerName` → `setCallerName` (method + channel
     method string).
   - `MainActivity.kt`: handle `"setCallerName"` instead of `"setIncomingCallerName"`.
   - `CallRegistry.kt`: update the stale comment on `setCallerDisplayName` ("ongoing
     call notification" wording is fine; drop the "ringer" phrasing).

## Verification

- `flutter analyze` on the touched Dart files (repo has known pre-existing analyzer
  errors per docs/known-gaps.md — only check for new issues).
- Manual: place an outgoing call to a saved contact → the ongoing-call notification
  (visible after backgrounding the app) shows the contact name; incoming ringing
  notification still shows the name as before.
