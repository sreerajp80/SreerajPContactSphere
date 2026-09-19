# Change log — Fix ongoing call disappearing and voice cross-talk when switching calls

Implements plan `plans/20260919_091000_fix-call-switch-disconnect.md`.

## What was broken

When on an active call and switching to another call (such as answering an incoming call-waiting call, switching back and forth between active and held calls with "Swap", or making a second outgoing call):
1. The previous ongoing call appeared to be disconnected in the app user interface. The held call banner disappeared, making it look as though the call was dropped.
2. The user could still hear the voice from the ongoing call in the current call (audio from both calls was heard together).

This happened because `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt` contained logic in `onStateChanged` that automatically executed `merge()` whenever any call became active while another call was present. Calling `merge()` forced Android Telecom to conference the two calls together. When conferenced, the held call became a child of the conference, which removed it from `topLevel()`, setting `heldNumber` to null in the UI snapshot. Meanwhile, conferencing bridged the audio channels so both callers were heard simultaneously.

## What changed

### Native Android Telecom layer (`CallRegistry.kt`)
- Removed `if (topLevel().size >= 2) { merge() }` from `onStateChanged` when `state == Call.STATE_ACTIVE`.
- Kept `sawActiveCalls.add(c)`.
- Calls are now kept distinct: one active (`STATE_ACTIVE`), one on hold (`STATE_HOLDING`).
- Calls are never automatically merged into a conference; conference merging only happens when the user explicitly taps the "Merge" button.

### In-Call UI (`in_call_screen.dart`)
- Updated `_heldBanner` to display the resolved contact name `_resolvedHeldName` (e.g. "John Doe — on hold") rather than only the raw phone number.
- Made `_heldBanner` interactive: when `_state.canSwap` is true, tapping the banner triggers `_telecom.swapCalls`, allowing users to switch calls directly by tapping the held banner in addition to the "Swap" button.

### Tests (`test/conference_call_test.dart`)
- Expanded platform channel tests to verify forwarding of `answerWaiting` and `rejectWaiting` in addition to `playDtmf`, `stopDtmf`, `merge`, and `swap`.

## Files changed

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`
- `lib/screens/in_call_screen.dart`
- `lib/core/constants/build_date.g.dart`
- `test/conference_call_test.dart`
- `plans/20260919_091000_fix-call-switch-disconnect.md`

## Verification

- Static analysis: `flutter analyze` completed with 0 warnings/errors.
- Unit tests: `flutter test test/conference_call_test.dart` passed all tests.
- Native build: `powershell -Command "cd android; ./gradlew :app:compileDevDebugKotlin"` built clean (`BUILD SUCCESSFUL`).
