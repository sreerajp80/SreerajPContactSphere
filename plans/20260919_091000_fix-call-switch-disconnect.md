# Fix ongoing call disappearing and voice cross-talk when switching calls

**Status:** completed

## The issue

When a user is on an active call and switches to another call (such as answering an incoming call-waiting call, switching back and forth between active and held calls with "Swap", or making a second outgoing call):
1. The previous call appears to be disconnected in the app user interface. The held call banner disappears, making it look like the ongoing call was dropped.
2. The user can still hear the voice from the ongoing call in the current call (audio from both calls is heard together).

### Root Cause

In `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`, inside `onStateChanged`:
```kotlin
if (state == Call.STATE_ACTIVE) {
    sawActiveCalls.add(c)
    if (topLevel().size >= 2) {
        merge()
    }
}
```
Whenever any call became active while another call existed (`topLevel().size >= 2`), the code automatically called `merge()`.

Calling `merge()` forced Android Telecom to conference the two calls together (`Call.conference` / `mergeConference`). This caused:
- In Android Telecom, conferenced calls become child calls attached to a conference parent.
- In `CallRegistry.kt`, `topLevel()` filters out calls that have a parent (`calls.filter { it.parent == null }`).
- Because the held call became a conference child, it vanished from `topLevel()`. `secondaryCall()` returned null, and `heldNumber` in the UI snapshot became null.
- The in-call screen stopped showing the held call, making it look like the ongoing call was disconnected.
- Because the calls were merged into a conference, audio streams were bridged, causing the user to hear the other caller's voice in the current call.
- The user never chose to merge the calls. Merging should only occur when the user explicitly taps the "Merge" button.

In addition, in `lib/screens/in_call_screen.dart`:
- The held call banner (`_heldBanner`) was static and not tappable.
- The held call banner displayed the raw phone number rather than the resolved contact name (`_resolvedHeldName`).

## Files to change

1. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`
   - Remove automatic `merge()` when a call becomes active (`state == Call.STATE_ACTIVE`). Calls must only be merged when the user explicitly triggers `merge()`.

2. `lib/screens/in_call_screen.dart`
   - In `_heldBanner`, use the resolved contact name `_resolvedHeldName` (falling back to phone number).
   - Make `_heldBanner` interactive: when `_state.canSwap` is true, tapping the banner switches between the active call and held call by calling `_telecom.swapCalls`.

## The plan for the fix

1. **Remove automatic merge in `CallRegistry.kt`**:
   In `CallRegistry.kt`, remove the `if (topLevel().size >= 2) { merge() }` block in `onStateChanged`. Keep `sawActiveCalls.add(c)`.
   When a call becomes active (e.g. Answering call-waiting, swapping calls, or adding a call), Telecom keeps the other call held (`STATE_HOLDING`). The held call remains visible in `secondaryCall()`, `heldNumber` is sent in `snapshot()`, and both calls stay distinct and isolated.

2. **Enhance held call banner in `in_call_screen.dart`**:
   - Display `_resolvedHeldName` if available so the banner reads "John Doe — on hold" instead of showing just the digits.
   - Wrap the chip in an `InkWell` calling `_telecom.swapCalls` when `_state.canSwap` is true, so users can tap the held banner to switch calls easily.

## Testing

1. Run `flutter analyze` to ensure zero static analysis warnings.
2. Run `flutter test` to ensure all unit and widget tests continue to pass.
3. Build the native Android debug compilation (`powershell -Command "cd android; ./gradlew :app:compileDevDebugKotlin"`) to confirm Kotlin compiles without errors.
4. Verify on-device behavior:
   - Answering a waiting call puts the first call on hold without merging audio streams.
   - The ongoing call remains visible on the screen in the "on hold" banner.
   - Swapping between calls switches audio cleanly between the two callers without cross-talk or automatic conference merge.
   - Merging calls into a conference happens only when the user explicitly taps the "Merge" button.

## Risk

Low. Removing unwanted automatic conference merging restores standard Android Telecom call handling, preventing accidental bridging of call audio and keeping held calls properly tracked and visible in the user interface.
