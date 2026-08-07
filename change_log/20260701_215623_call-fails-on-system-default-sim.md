# Fix: calls not placed with "System Default" SIM + "Ask" off

Implements [plans/20260701_214313_call-fails-on-system-default-sim.md](../plans/20260701_214313_call-fails-on-system-default-sim.md).

## Problem

As the default dialer, tapping call (Contacts / Recents / dialer) placed **no call**
when Default SIM = "System Default" **and** "Ask which SIM" = off. That is the only
config where a call is placed with no `PhoneAccountHandle`; on a multi-SIM device with
the OS "SIM for calls" preference set to "ask every time", Telecom parked the call in
`Call.STATE_SELECT_PHONE_ACCOUNT` waiting for the default dialer to pick an account —
which the app never did, so the call silently hung.

## Changes

### Native (Kotlin)
- **`android/.../CallRegistry.kt`**
  - Added `maybeResolvePhoneAccount(call)`, invoked from `onCallAdded` and the call
    callback's `onStateChanged` when the call is in `STATE_SELECT_PHONE_ACCOUNT`. It
    selects the OS default outgoing account (`TelecomManager.getDefaultOutgoingPhoneAccount("tel")`)
    via `Call.phoneAccountSelected(handle, false)` when one exists; otherwise leaves
    the call selecting for the Flutter picker. Best-effort (try/catch).
  - Added `selectPhoneAccount(phoneAccountId, componentName)` which reconstructs a
    `PhoneAccountHandle` and calls `Call.phoneAccountSelected(...)`.
  - Added imports: `ComponentName`, `Context`, `PhoneAccountHandle`, `TelecomManager`.
- **`android/.../MainActivity.kt`** — new method-channel case `selectPhoneAccount`
  forwarding to `CallRegistry.selectPhoneAccount`.

### Flutter
- **`lib/services/telecom_service.dart`** — added
  `selectPhoneAccount(SimAccount)` over the method channel (no-op off Android).
- **`lib/main.dart`** — `_onCall` now handles `CallPhase.selecting`: guarded by a
  `_selectingHandled` flag, it calls new `_promptForSim()`, which lists SIMs
  (`SimService`), shows `showSimPickerSheet`, and resolves the call via
  `TelecomService.selectPhoneAccount` (cancel, no SIMs, or any error → `disconnect()`
  so the call never hangs). Added `sim_service` + `sim_picker_sheet` imports.

### Docs
- **`docs/architecture.md`** — noted the `SELECT_PHONE_ACCOUNT` handling in Multi-SIM.
- **`docs/known-gaps.md`** — added a resolved entry describing the stall + fix.

## Verification
- `flutter analyze` — no issues.
- `flutter test` — all 27 tests pass.
- Native Gradle compile could not be run here: project configuration fails on an
  unrelated pre-existing plugin issue (`audioplayers_android:testDebugUnitTest` task
  creation under this Gradle version), before any app Kotlin is compiled. The native
  changes use only long-standing public Telecom APIs.
- Manual device verification (dual-SIM, default dialer, OS "ask every time", in-app
  System Default + Ask off) still pending on a physical device.
