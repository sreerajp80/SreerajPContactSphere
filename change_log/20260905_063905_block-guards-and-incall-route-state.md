# Block-Disconnect Guards, Suffix-Match Mismatch, and Stale In-Call Route State

**Plan reference:** `plans/20260905_054350_block-guards-and-incall-route-state.md`

Follow-up to `change_log/20260905_053200_block-call-and-history.md`, which added the
block-and-disconnect feature these three fixes correct.

## Summary of Changes

### 1. A settings sync can no longer hang up an outgoing call
`android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`

`disconnectBlockedCalls()` used to loop over every live call, with no check for whether
the call came in or went out. When a call has no handle yet — which is normal for an
outgoing call still in `STATE_CONNECTING` — the "no digits" branch fell back to the
"block unknown callers" setting and hung the call up. Because
`MainActivity.setScreeningMirror()` calls this on **every** mirror push (app load, a
settings change, a quiet-hours sync), a background sync could end a call the user had
just placed.

- Calls that are not incoming are now skipped, using the existing `isIncoming()` helper
  (`Call.Details.getCallDirection` on API 29+, falling back to "was ever seen ringing").
- Calls already in `STATE_DISCONNECTING` or `STATE_DISCONNECTED` are skipped.
- Rejecting a ringing call and disconnecting an established one is unchanged.

Blocking a number while an outgoing call to it is running still ends that call — that
path runs on the Dart side in `FlaggedNumberRepository.add()` and was not touched.

### 2. Dart and native now match numbers the same way
`lib/repositories/flagged_number_repository.dart`

`_disconnectIfRunning()` treated two numbers as the same on a **7**-digit suffix overlap,
while the native `ContactSphereCallScreeningService.sameNumber` requires **9**
(`MIN_SUFFIX_DIGITS`). Real mobile numbers can share their last 7 digits, so the Dart
path could hang up a call to the wrong person.

- Added `_kMinSuffixDigits = 9` with a comment naming the native constant it mirrors.
- Added a private `_sameNumber()` that applies the same shorter/longer suffix rule as
  native, and used it in `_disconnectIfRunning()`.

Matching is now strictly narrower than before, so this cannot cause a new wrong
disconnect.

### 3. The calling screen recovers instead of staying missing
`lib/main.dart`

Reported symptom: a call would connect and show its ongoing notification, but the
full-screen calling screen never appeared; clearing the app from recents fixed it. That
points at state held in the running app, not at the native bridge — the native side had
clearly emitted the event, since the ongoing notification is posted from the same
`notifyChange()` that pushes it.

`_onCall` pushed the calling screen only when `_inCallRouteShown` was false. If that flag
was left true while no calling screen was actually on display — the route still on the
navigator stack but buried under a route pushed above it — every later call took the
"already showing" path and pushed nothing, with no way back except restarting the app.

- `_onCall` now checks the tracked route's real state (`_inCallRoute?.isActive`) before
  believing the flag, and clears both when they disagree, so the next call pushes a fresh
  calling screen.

Normal behaviour is unchanged; this only adds recovery from the stuck state.

### 4. Tests
- `test/block_call_disconnect_test.dart` — two new cases: a live call reported in its
  national form still matches the stored international form and is disconnected; and a
  different number sharing only the last seven digits is **not** disconnected (this case
  failed under the old 7-digit rule).
- `android/app/src/test/kotlin/in/sreerajp/contact_sphere/CallScreeningMatchingTest.kt` —
  a new case pinning the boundary: 7- and 8-digit overlaps do not match, 9 does.

## Verification

- `flutter analyze` — no issues found.
- `flutter test` — 465 tests passed (463 before, plus the 2 new cases); 1 pre-existing
  skip.
- `cd android && ./gradlew :app:testDevDebugUnitTest` — BUILD SUCCESSFUL; the Kotlin
  change compiles and all native unit tests pass.

## Still to check on a device

These were not verified on hardware — no device was attached during this change:

1. Place an outgoing call with "block unknown callers" **on**: the call must connect and
   stay connected, and the calling screen must appear.
2. Receive a call from a blocked number: it must still be rejected and recorded in block
   history.
3. Place several calls in a row without restarting the app: the calling screen must
   appear every time.

Fix 3 is a defensive repair based on the code plus the "killing the process fixes it"
evidence; the stuck state was never reproduced under a debugger. If the calling screen
goes missing again, capture device logs to confirm the cause.
