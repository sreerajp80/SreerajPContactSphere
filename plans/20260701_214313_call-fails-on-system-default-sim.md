# Calls don't start with "System Default" SIM + "Ask" off (multi-SIM, default dialer)

**Status:** completed

## Issue

Tapping the call button from the Contacts list or Recents (and in fact anywhere,
including the dialer) places **no call** when **both**:

- **Default SIM = "System Default"** (`AppSettings.defaultSimId == null`), and
- **"Ask which SIM before each call" = off** (`askSimBeforeCall == false`).

Any other combination works (a specific default SIM, or the per-call picker),
because those attach a `PhoneAccountHandle` up front.

### Root cause (traced end to end)

This is the *only* configuration where a call is placed with **no SIM handle**:

1. `CallLifecycleMixin._resolveSim()` returns `null`
   ([lib/widgets/call_lifecycle_mixin.dart:117](../lib/widgets/call_lifecycle_mixin.dart#L117)).
2. `CallService.placeCall(sim: null)` calls `_telecom.placeCall(number, sim: null)`
   ([lib/services/call_service.dart:88](../lib/services/call_service.dart#L88)).
3. Because we **are** the default dialer, `MainActivity.placeCall` runs
   `telecom().placeCall(uri, extras)` with **empty extras** — no
   `EXTRA_PHONE_ACCOUNT_HANDLE`
   ([android/.../MainActivity.kt:181](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt#L181)).

On a **dual-SIM device whose OS "SIM for calls" preference is "Ask every time"**
(i.e. no OS default outgoing account), Telecom does **not** dial. It puts the call
into `Call.STATE_SELECT_PHONE_ACCOUNT` and expects the default dialer (us) to
present a phone-account picker and call `Call.phoneAccountSelected(handle, …)`.

**We never respond to that state.** `CallRegistry` maps it to `"selecting"`
([CallRegistry.kt:156](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt#L156))
and `CallState` parses it to `CallPhase.selecting`
([call_state.dart:33](../lib/models/call_state.dart#L33)), but:
- nothing anywhere calls `phoneAccountSelected`, and
- `CallPhase.selecting` is not in `isOngoing`, so `main.dart` never even shows the
  in-call screen ([main.dart:72](../lib/main.dart#L72)).

The call silently hangs in "selecting" and never dials → **"no call happens."**
Picking a specific SIM (or enabling "Ask") supplies the handle up front, skips
`SELECT_PHONE_ACCOUNT`, and dials normally — which is why those paths work.

Note: this only bites while we are the **default dialer**. If we weren't,
`CallService.placeCall` falls back to `FlutterPhoneDirectCaller` (`ACTION_CALL`) and
the *system* shows its own SIM chooser.

## Fix

Approved behavior (per user): **when a call enters `SELECT_PHONE_ACCOUNT`, use the
OS-designated default outgoing SIM if one exists; otherwise show the app's own SIM
picker for that call and select the chosen account.**

### Native — `android/.../CallRegistry.kt`
- Add a helper `maybeResolvePhoneAccount(call)` invoked when a call is (or becomes)
  `STATE_SELECT_PHONE_ACCOUNT` — from both `onCallAdded` and the callback's
  `onStateChanged`:
  - Get `TelecomManager` from the bound `service` (an `InCallService` is a `Context`).
  - Try `tm.getDefaultOutgoingPhoneAccount("tel")` (public API; the user-selected
    default outgoing account, or `null` when set to "ask"). If non-null →
    `call.phoneAccountSelected(handle, false)` and stop (call proceeds to DIALING; no
    UI needed).
  - Otherwise leave the call in `selecting` so Flutter shows the picker. All wrapped
    in try/catch; failure just leaves it selecting.
  - Guard so `phoneAccountSelected` is only attempted while the call is still in the
    select state (avoid double-selection).
- Add `fun selectPhoneAccount(phoneAccountId: String?, componentName: String?)`:
  reconstruct a `PhoneAccountHandle` from the args and call
  `call?.phoneAccountSelected(handle, false)` (try/catch).

### Native — `android/.../MainActivity.kt`
- Add a method-channel case `"selectPhoneAccount"` →
  `CallRegistry.selectPhoneAccount(call.argument("phoneAccountId"),
  call.argument("componentName")); result.success(null)`.

### Flutter — `lib/services/telecom_service.dart`
- Add `Future<void> selectPhoneAccount(SimAccount sim)` →
  `_invokeVoid('selectPhoneAccount', {'phoneAccountId': sim.phoneAccountId,
  'componentName': sim.componentName})` (no-ops off Android).

### Flutter — `lib/main.dart`
- In `_onCall`, handle `state.phase == CallPhase.selecting` (guarded by a
  `_selectingHandled` flag so we prompt once per call, reset when the phase leaves
  `selecting`):
  - Load SIMs via `SimService().list()`.
  - If ≥1 SIM, show `showSimPickerSheet(_navKey.currentContext!, sims: sims)`:
    - chosen → `TelecomService().selectPhoneAccount(chosen)`.
    - cancelled → `TelecomService().disconnect()` (abort the stuck call).
  - If no SIMs can be enumerated (permission missing), `disconnect()` so the call
    doesn't hang. (Edge case; documented below.)

### Docs
- `docs/architecture.md` — one line: the default dialer handles
  `SELECT_PHONE_ACCOUNT` (OS default outgoing account, else in-app SIM picker).
- `docs/known-gaps.md` — note this fix under the multi-SIM section.

## Files to change
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
- `lib/services/telecom_service.dart`
- `lib/main.dart`
- `docs/architecture.md`, `docs/known-gaps.md`

## Notes / limitations
- When the OS default outgoing SIM *is* set, Telecom never enters
  `SELECT_PHONE_ACCOUNT`, so the native auto-select branch is mostly a safety net —
  the common real case (OS = "ask every time") goes straight to the in-app picker.
- The provisional `call_logs` row written by `CallService.placeCall` still gets
  created even if the user cancels the picker; it stays as a null-duration
  provisional row (unchanged behavior for calls that never connect).
- Single-SIM devices are unaffected (Telecom uses the sole account, no select state).

## Test / verify
- `flutter analyze` clean; `flutter test` passes (native/telecom no-op off Android,
  so tests are unaffected).
- Manual (dual-SIM device, app set as default dialer, OS "SIM for calls" = ask,
  in-app Default SIM = System Default, Ask = off): tapping call from Contacts and
  Recents now shows the app SIM picker and dials on the chosen SIM.
