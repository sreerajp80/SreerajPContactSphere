# Stale in-call screen flashes when reopening the app after a call ended in background

**Status:** completed

## Issue

Repro (confirmed live on the Moto G54, 2026-07-04, calls TC@13/TC@14 in logcat):

1. Place (or receive) a call — the app shows `InCallScreen`.
2. Switch to another app / home screen while the call is up.
3. The other party disconnects while our app is backgrounded.
4. Reopen the app → the old calling screen is visible for a short moment, then the
   normal screen appears.

## Root cause (verified from logcat `scratchpad/repro_logcat.txt`)

The call-end **is** delivered and processed while the app is backgrounded — the
`flutter/CALL_LOG` plugin traffic (call-log reconciliation) fires within ~200 ms of
Telecom's `SET_DISCONNECTED`, while the launcher is foreground. So `_onCall` in
[lib/main.dart](../lib/main.dart) runs `nav.popUntil((r) => r.isFirst)` in the background.
The route stack is correct; what the user sees on reopen is stale *pixels*:

1. **Task snapshot.** Android takes a screenshot of the activity when the user leaves it
   (mid-call → it shows `InCallScreen`) and replays that snapshot as the starting window
   during the reopen transition, before Flutter draws its first frame. This is the bulk
   of the visible "calling screen for a short time".
2. **Pop animation replay.** While paused, Flutter renders no frames, so the
   `MaterialPageRoute` exit transition started by `popUntil` cannot tick. Its ticker's
   clock starts on the first frame *after resume*, so the ~300 ms reverse transition
   (in-call screen sliding/fading away) plays right in front of the user on reopen.

**Incoming calls are affected identically** — `_onCall` pushes/pops the same route for
every direction (`CallPhase.isOngoing` covers ringing/active alike), and the background
event delivery proven above is direction-agnostic. (Live repro was outgoing; the incoming
code path is byte-for-byte the same handler.)

## Files to change

- `lib/main.dart`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`

## Fix

### 1. `lib/main.dart` — remove the route without animation when backgrounded

- Keep a reference to the pushed in-call `Route`.
- In `_onCall`, when the call ends and
  `WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed`, call
  `nav.removeRoute(inCallRoute)` (immediate, no exit transition) instead of the animated
  `popUntil`. When the app is foreground, keep the current animated `popUntil` behaviour.
- This kills the pop-animation replay: the first frame rendered after resume is already
  the underlying screen.

### 2. `MainActivity.kt` — don't let the OS snapshot the in-call screen

- In `onCallChanged` (next to the existing `applyShowWhenLocked(snapshot != null)`),
  call `setRecentsScreenshotEnabled(snapshot == null)` on API 33+.
- While a call is up, the system then takes no task snapshot; leaving the app mid-call
  stores nothing, so reopening shows the normal splash/blank starting window instead of
  the stale calling screen. Re-enabled as soon as no call remains, restoring normal
  Recents thumbnails.
- Below API 33 this is a no-op (the snapshot flash may remain there; the animation fix
  above still applies).

## Verification plan

Re-run the live repro (outgoing and, if a second phone is at hand, incoming): call,
background, remote disconnect, reopen while running a screenshot burst — the calling
screen must not appear. Also sanity-check: normal Recents thumbnail returns after the
call ends, and lock-screen `showWhenLocked` behaviour is unchanged.
