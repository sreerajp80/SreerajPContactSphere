# Block Function Call Screening, Block History, and Immediate Disconnect for Running Calls

**Plan reference:** `plans/20260905_052100_block-call-and-history.md`

## Summary of Changes

Implemented reliable call blocking, complete blocked-call history recording, and instantaneous disconnection of running calls when blocked.

### 1. In-Call UI (`lib/screens/in_call_screen.dart`)
- Updated `_confirmBlock()` to disconnect any running call immediately (`unawaited(_telecom.disconnect())`) when blocking is confirmed while a call is active, dialing, ringing, or holding (`_state.hasCall`).
- Updated confirmation dialog copy to state that any running call will disconnect immediately.

### 2. Flagged Numbers Repository (`lib/repositories/flagged_number_repository.dart`)
- Added `_disconnectIfRunning(key)` into `add()`: when a number is flagged as blocked, checks `_telecom.activeCall()` and automatically disconnects the running call if its number matches. This ensures that blocking triggered from Call History or Blocked Numbers settings also ends an ongoing call immediately.

### 3. Android Native Telecom Bridge (`CallRegistry.kt` & `MainActivity.kt`)
- Updated `CallRegistry.disconnect()`: properly invokes `call.reject(false, null)` when the call is in `STATE_RINGING` (as required by Android Telecom) and `call.disconnect()` otherwise.
- Added `CallRegistry.disconnectBlockedCalls(blockedList, blockUnknown)`: checks top-level live calls and terminates any call whose number matches the blocked list or is an unknown caller when unknown blocking is active.
- Updated `MainActivity.setScreeningMirror()`: invokes `CallRegistry.disconnectBlockedCalls(...)` after updating mirrored preferences.

### 4. Android Call Screening & In-Call Services (`ContactSphereCallScreeningService.kt` & `ContactSphereInCallService.kt`)
- Exposed `readList`, `matchesList`, `sameNumber`, and `recordBlockedCall` in the companion object of `ContactSphereCallScreeningService`.
- In `ContactSphereCallScreeningService.screen()`: added `recordBlockedCall(prefs, number ?: "Unknown")` for blocked unknown callers so they enter the blocked call event journal.
- In `ContactSphereInCallService.onCallAdded()`: added defensive secondary screening against the mirrored blocklist and unknown caller setting. Intercepts, records to block history, and rejects incoming blocked calls immediately without ringing or launching UI.

### 5. Local History Logging (`lib/services/call_event_logger.dart` & `lib/main.dart`)
- In `CallEventLogger._logIncoming()`: checks if the disconnected incoming caller's number is flagged as blocked; if so, sets `callType = 'blocked'`, `callOutcome = AppCallOutcome.noAnswer`, and `duration = 0`.
- In `lib/main.dart`: triggers `CallEventLogger().drainBlockedCalls()` immediately when `onCallLogChanged` is received so newly recorded blocked calls reflect in Recents without delay.

### 6. Verification & Automated Tests
- Added `test/block_call_disconnect_test.dart` testing running call disconnection and blocked call history logging.
- Added native JVM unit test `android/app/src/test/kotlin/in/sreerajp/contact_sphere/CallScreeningMatchingTest.kt` verifying number matching logic.
- Ran `flutter analyze`: passed with zero warnings.
- Ran `./gradlew :app:testDevDebugUnitTest`: all native unit tests passed.
- Ran `flutter test`: all 463 tests passed cleanly.
