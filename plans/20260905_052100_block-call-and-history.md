# Block Function Call Screening, Block History, and Immediate Disconnect for Running Calls

**Status:** completed

## Goal

Ensure that:
1. The block function properly blocks incoming calls and records them in the block history (call log / Recents with type 'blocked').
2. Blocked unknown callers (hidden or private numbers) are recorded in the blocked call history when "Block unknown callers" is active.
3. If a call is currently running (ringing, active/talking, dialing, connecting, or on hold), blocking the number disconnects the call immediately.
4. Incoming calls that bypass CallScreeningService on certain devices are intercepted and blocked defensively by InCallService before ringing or showing UI, and recorded in history.

## Issue Analysis

1. **Running call not disconnecting when blocked while active:**
   - In `lib/screens/in_call_screen.dart`, `_confirmBlock()` currently only executes `_telecom.disconnect()` if `_state.phase == CallPhase.ringing`. If a call is connected/talking (`CallPhase.active`), dialing, connecting, or holding, `disconnect()` is never called. The user stays on the line until manually hanging up.
   - The confirmation dialog text on `InCallScreen` only mentions declining the call if ringing, ignoring active calls.
   - Blocking from other screens (such as `CallHistoryScreen` long-press actions or `BlockedNumbersScreen` manual add) while a call is running does not disconnect the ongoing call.
   - In native `CallRegistry.kt`, `disconnect()` calls `primaryCall()?.disconnect()`. On Android Telecom, calling `disconnect()` on an incoming ringing call can fail or be ignored on some OEM versions because Android Telecom explicitly specifies `Call.reject(false, null)` for `STATE_RINGING` calls.

2. **Blocked unknown callers missing from block history:**
   - In `android/.../ContactSphereCallScreeningService.kt`, when `digits.isEmpty()` and "Block unknown callers" is enabled, `screen()` returns `reject()` but never calls `recordBlockedCall()`. Thus, blocked unknown calls never enter `KEY_BLOCKED_EVENTS` or the app's call history.

3. **Defensive screening in InCallService:**
   - On some Android OEM builds or timing edge cases where the system `CallScreeningService` is delayed or bypassed, `ContactSphereInCallService.onCallAdded()` unconditionally rings and brings up the in-call UI without checking if the caller is blocked.

4. **Logged call type for calls disconnected by blocking:**
   - In `lib/services/call_event_logger.dart`, `_logIncoming()` marks ended calls as `'incoming'` (if ever active) or `'missed'`. If an incoming call was blocked mid-call or at ring, it should be categorized as `'blocked'` in the local call history.
   - In `lib/main.dart`, when Android Telecom notifies `onCallLogChanged`, `CallEventLogger().drainBlockedCalls()` should be triggered along with device sync so blocked events reflect immediately in Recents.

## Proposed Changes

### 1. In-Call UI
- **`lib/screens/in_call_screen.dart`**:
  - In `_confirmBlock()`, if the user confirms blocking and `_state.hasCall` is true, immediately call `unawaited(_telecom.disconnect())`.
  - Update the dialog confirmation text to indicate that any running call will be disconnected immediately.

### 2. Flagged Number Repository
- **`lib/repositories/flagged_number_repository.dart`**:
  - In `add()`, when `kind == kindBlocked`, check `_telecom.activeCall()`. If an active or running call matches the blocked number, invoke `_telecom.disconnect()`. This guarantees immediate disconnect regardless of where blocking was triggered (in-call screen, history, or settings).

### 3. Native Telecom Bridge & Call Registry
- **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`**:
  - In `disconnect()`: if `stateOf(primaryCall) == Call.STATE_RINGING`, use `call.reject(false, null)`; otherwise `call.disconnect()`.
  - Add `disconnectBlockedCalls(blockedList: List<String>, blockUnknown: Boolean)`: checks all top-level calls and immediately rejects/disconnects any call matching a blocked number or unknown caller.
- **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**:
  - In `setScreeningMirror`, after updating preferences, invoke `CallRegistry.disconnectBlockedCalls(...)`.

### 4. Native Call Screening & In-Call Services
- **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereCallScreeningService.kt`**:
  - Expose `recordBlockedCall`, `readList`, `matchesList`, and `sameNumber` via the companion object.
  - When `digits.isEmpty()` and `KEY_BLOCK_UNKNOWN` is true, invoke `recordBlockedCall(prefs, number ?: "Unknown")` before `reject()`.
- **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`**:
  - In `onCallAdded(call)`: check if the incoming call is in the blocked list or is an unknown caller when `blockUnknown` is true. If blocked, record the event, invoke `call.reject(false, null)`, and exit immediately without ringing or launching UI.

### 5. History Logging & Notification
- **`lib/services/call_event_logger.dart`**:
  - In `_logIncoming()`: check if `number` is flagged as blocked; if so, set `callType = 'blocked'` and `callOutcome = AppCallOutcome.noAnswer`.
- **`lib/main.dart`**:
  - In the `_telecomChannel` handler for `onCallLogChanged`: call `unawaited(CallEventLogger().drainBlockedCalls())` alongside `syncFromDevice(force: true)`.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure all existing tests pass and new unit tests for:
  - Disconnecting running calls when blocking.
  - Correct 'blocked' call logging and outcome mapping.
  - `FlaggedNumberRepository` matching logic.
- Run `flutter analyze` to ensure zero warnings.

### Manual Verification
- Verify blocking a caller from the in-call screen during an active/ringing call disconnects the call immediately.
- Verify the call is recorded in the Recents / Call History screen with the 'Blocked' badge and block icon.
- Verify blocking unknown callers logs the blocked unknown call in call history.
