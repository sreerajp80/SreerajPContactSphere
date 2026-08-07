# Conference calls + in-call keypad (DTMF)

Implements plan [plans/20260703_091916_conference-call-and-keypad.md](../plans/20260703_091916_conference-call-and-keypad.md).

## What changed

Added multi-party conference support, an in-call DTMF keypad, and made the
**Speaker** control available while a call is ringing (arms "answer on speaker").

### Native (Kotlin)

- **`android/.../CallRegistry.kt`** — reworked from a single `call` field to a
  tracked **list** of calls with primary/secondary selection:
  - `primaryCall()` picks the foreground call by state priority (active → dialing
    → connecting → ringing → selecting → holding); `secondaryCall()` is the held
    background leg. `topLevel()` filters out conference children (via
    `Call.getParent()`).
  - New controls: `playDtmf(Char)` / `stopDtmf()` (`Call.playDtmfTone` /
    `stopDtmfTone`), `merge()` (`Call.conference` / `mergeConference`, gated on
    `CAPABILITY_MERGE_CONFERENCE`), `swap()` (`swapConference` or unhold the held
    leg). `answer/disconnect/hold/unhold` now target the primary call.
  - `snapshot()` gained backward-compatible fields: `isConference`, `canMerge`,
    `canSwap`, `canAddCall`, `canDtmf`, `heldNumber`, `heldState`. Primary-call
    fields keep their prior meaning, so `CallEventLogger`/logging are unaffected.
  - Ringing/`sawRinging` bookkeeping is now per-call (a `Set<Call>`), and ringing
    starts only on `STATE_RINGING`, so a second **outgoing** add-call never rings.
  - `selectPhoneAccount` now targets the call in `SELECT_PHONE_ACCOUNT` state.
- **`android/.../MainActivity.kt`** — added method-channel cases `playDtmf`
  (reads `digit`), `stopDtmf`, `merge`, `swap`.
- **`android/.../ContactSphereInCallService.kt`** — no change needed; verified its
  forwarding still holds with the multi-call registry.

### Dart

- **`lib/models/call_state.dart`** — added `isConference`, `canAddCall`,
  `canMerge`, `canSwap`, `canDtmf`, `heldNumber`, `heldPhase` (all optional /
  defaulted), parsed in `fromMap`.
- **`lib/services/telecom_service.dart`** — added `playDtmf`, `stopDtmf`,
  `mergeCalls`, `swapCalls` wrappers (no-op off Android via the existing guard).
- **`lib/screens/in_call_screen.dart`**:
  - `_controls` now shows only **Speaker** while ringing; the full
    Mute/Speaker/Hold row appears when connected.
  - New `_secondaryActions` row: **Keypad** (always when connected; disabled when
    not `canDtmf`), plus **Add call** / **Merge** / **Swap** shown only when the
    matching capability flag is set.
  - `_dtmfPad` overlay: 1-9/`*`/0/`#`, sends a tone on key-down and stops on
    release, with a digits readout and a Hide button. Auto-closes when the call
    leaves the active state.
  - `_heldBanner` chip shows the backgrounded call ("<number> — on hold").
  - **Add call** pushes the dialer via `DialerScreen(addCallMode: true)`.
- **`lib/screens/dialer_screen.dart`** — added `addCallMode`; after placing a call
  in that mode the dialer pops itself so the in-call screen (now showing the
  held/active legs) returns to front.

### Tests

- **`test/conference_call_test.dart`** (new) — verifies `CallState.fromMap`
  parses/defaults the new fields, and that `TelecomService`'s new controls forward
  the correct method name and DTMF digit to the platform channel.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 43 tests pass (incl. the new suite).
- **Native NOT compiled here.** `./gradlew` fails at project *configuration* time
  creating the `audioplayers_android:testDebugUnitTest` task ("Type T not present"),
  a pre-existing Gradle 8.12 / JDK toolchain incompatibility unrelated to these
  changes (no Gradle files were touched). The Kotlin was hand-reviewed for
  compile-correctness but needs a real device build to confirm, and the
  conference/merge/swap paths require a physical device + carrier that supports
  network conferencing (the stock emulator can't exercise them).
