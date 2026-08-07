# Conference calls + in-call keypad (DTMF)

**Status:** completed

## The issue

The in-call screen ([lib/screens/in_call_screen.dart](../lib/screens/in_call_screen.dart))
exposes only **Mute / Speaker / Hold** plus answer/reject/end. There is no way to:

- send DTMF touch-tones during a call (needed for IVR menus and **dial-in conference
  bridges** — call a number, then punch a meeting PIN), and
- create a **multi-party conference** (add a second person and merge).

The blocker is not just missing buttons — the native layer cannot represent more than one
call. [CallRegistry.kt](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt)
keeps a single `call` field and **overwrites** it on every `onCallAdded`
([CallRegistry.kt:117](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt#L117)).
A conference requires tracking multiple `Call` objects and driving Telecom's
`conference()` / `mergeConference()` / `swapConference()` APIs. There is also no
`playDtmfTone` bridge for the keypad.

The user chose **Full conference + keypad**.

## Goal

While on an active cellular call, the user can:

1. Open an **in-call keypad** and send DTMF tones (works for a single call and a bridge).
2. Tap **Add call** to dial a second number (Telecom auto-holds the first).
3. Tap **Merge** to conference the two calls, when the carrier/call supports it.
4. Tap **Swap** to toggle which call is foreground when two independent calls exist.
5. See a small banner for the held / background call.

All new behaviour degrades to a safe no-op off Android and in tests, matching the
existing `TelecomService` contract. Conference/merge/swap buttons appear **only when
Telecom reports the corresponding capability**, so devices/carriers that don't support
network conferencing simply won't show them.

## Files to change

### Native (Kotlin)

1. **`android/.../CallRegistry.kt`** — the core rework.
   - Replace the single `call: Call?` with a tracked **list** of calls plus a
     `primaryCall` (the foreground/active one) and `secondaryCall` (held/background).
   - Register/unregister the `Call.Callback` per call in `onCallAdded`/`onCallRemoved`
     (keep the existing ringing bookkeeping, which should key off the incoming call).
   - Reconcile "primary" on every state change: the `ACTIVE` call is primary; a `HOLDING`
     call is secondary; a conference `Call` (has children / `PROPERTY_CONFERENCE`) is
     primary when active.
   - New controls (all guarded, best-effort, matching existing style):
     - `playDtmf(digit: Char)` → `primaryCall?.playDtmfTone(digit)`.
     - `stopDtmf()` → `primaryCall?.stopDtmfTone()`.
     - `merge()` → if primary has `CAPABILITY_MERGE_CONFERENCE` use
       `primaryCall.conference(secondaryCall)`; if it's already a conference use
       `mergeConference()`.
     - `swap()` → if a conference supports it, `swapConference()`; else unhold the held
       call (Telecom auto-holds the other).
   - `answer/disconnect/hold/unhold` retarget from the single field to `primaryCall`
     (disconnect the primary; when a conference, disconnecting it ends the conference).
   - Extend `snapshot()` to add (all backward-compatible additions):
     - `canAddCall`  — a call is active/held and none is ringing/dialing.
     - `canMerge`    — `CAPABILITY_MERGE_CONFERENCE` present, or two mergeable calls.
     - `canSwap`     — two independent calls, or `CAPABILITY_SWAP_CONFERENCE`.
     - `canDtmf`     — `Call.Details.CAPABILITY_RESPOND_VIA_TEXT`? No — use presence of an
       active call; DTMF is always allowed on an active call, so `canDtmf = primary active`.
     - `isConference`— primary is a conference call.
     - `heldNumber` / `heldState` — the secondary call's number + state for the banner.
   - The **primary** call's existing fields (`number`, `state`, `canHold`,
     `connectTimeMillis`, `phoneAccountId`, `direction`, `callId`) keep their current
     meaning, so `CallEventLogger` and everything else consuming the snapshot are
     unaffected.

2. **`android/.../MainActivity.kt`** — add method-channel cases: `playDtmf`
   (reads `digit`), `stopDtmf`, `merge`, `swap`. (Existing `placeCall` is reused for
   "Add call" — no new native method needed; placing a call while one is active makes
   Telecom hold the first.)

3. **`android/.../ContactSphereInCallService.kt`** — `onCallAdded`/`onCallRemoved`
   already forward to `CallRegistry`; verify they still call the (now multi-call)
   registry correctly. The ringing/foreground path keys off the incoming call only, so a
   second *outgoing* call must not restart ringing — confirm `startRinging` stays gated on
   `STATE_RINGING`.

### Dart

4. **`lib/models/call_state.dart`** — add fields to `CallState`, all optional/defaulted so
   `none` and existing call sites are unaffected: `canAddCall`, `canMerge`, `canSwap`,
   `isConference` (bools, default false), and `heldNumber` (String?) + `heldPhase`
   (`CallPhase`, default none). Parse them in `fromMap`.

5. **`lib/services/telecom_service.dart`** — add wrappers mirroring the native methods:
   `playDtmf(String digit)`, `stopDtmf()`, `mergeCalls()`, `swapCalls()`. `addCall` is
   just the existing `placeCall` reused. All no-op off Android via the existing `_supported`
   guard.

6. **`lib/screens/in_call_screen.dart`** — UI:
   - **Speaker while ringing.** `_controls` currently returns an empty box unless the
     phase is `active`/`holding` ([in_call_screen.dart:281](../lib/screens/in_call_screen.dart#L281)).
     Change it so that during `ringing` it shows the **Speaker** toggle (only). Mute /
     Hold / Keypad / Add-call / Merge / Swap remain hidden until the call is connected —
     they have no meaning before answer. Tapping Speaker while ringing calls
     `setSpeaker(true)`; the app-owned ringtone still plays on the ring stream (it is not
     rerouted), so the effect is that the call is already on speaker the instant it is
     answered ("answer on speaker"). Best-effort — Telecom may defer the route change until
     the call is active. The Speaker toggle's on/off state must reflect `_state.speaker` so
     it survives the ringing→active transition.
   - Add a secondary-actions row (below Mute/Speaker/Hold) with **Keypad**, **Add call**,
     and conditionally **Merge** / **Swap**, each gated on the matching capability flag.
     Reuse the existing `_toggle` styling for visual consistency (own design system, per
     project guidance — not a Google clone).
   - **Keypad**: an in-call DTMF pad (0-9, \*, #) shown as an overlay/bottom sheet over the
     call background; each key press calls `playDtmf` (and `stopDtmf` on release), appends
     to a small entered-digits display, and a Hide button dismisses it.
   - **Add call**: navigate to the existing dialer entry point to place a second call
     (auto-holds the first). Needs a check of how the dialer screen is launched/routed.
   - **Held-call banner**: when `heldNumber != null`, show a compact "<name/number> — on
     hold" chip; resolve the name via the existing `_resolveName` path if cheap, else show
     the number.

### Tests

7. **`test/call_feature_test.dart`** (and/or a new test file) — cover
   `CallState.fromMap` parsing of the new flags, and that `TelecomService`'s new methods
   no-op off Android. Native Kotlin is not unit-tested in this repo, matching the existing
   pattern.

## Notes / risks

- **Carrier dependence.** True network conferencing (merge) only works when the carrier /
  VoLTE stack reports `CAPABILITY_MERGE_CONFERENCE`. On unsupported networks the Merge
  button stays hidden by design; Add-call + Swap (two independent calls) may still work.
- **Emulator.** Multi-call/merge generally can't be exercised on the stock emulator; DTHM
  and add-call/hold can be partially tested, full conference needs a real device + SIM.
- **Single-call regression surface.** The CallRegistry rework touches the hottest path in
  the telephony bridge. Primary-call snapshot semantics are kept identical to avoid
  regressing the existing in-call screen, logging, and ringing.
- Follow-up (out of scope unless requested): per-participant conference management UI
  (list participants, drop one), and reflecting a conference in the Recents log.

## Add-call UX (decided)

**Option A** — "Add call" reuses the existing dialer screen to pick/dial the second
number. Placing the second call while one is active makes Telecom auto-hold the first.
(Implementation needs the dialer's launch/route entry point, wired so returning from the
dialer leaves the in-call UI reachable.)
