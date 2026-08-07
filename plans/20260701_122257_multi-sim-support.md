# Multi-SIM support (default SIM, ask-per-call, SIM in Recents)

**Status:** completed

## Issue / goal

The app has no notion of multiple SIMs. Requirements:

1. **Multi-SIM support** — enumerate the device's active SIMs and let calls go out on a
   chosen SIM.
2. **Settings** — a place to pick the **default SIM** and toggle **"ask which SIM before
   each call"**.
3. **Recents** — show, per call: the **SIM** the call came in / went out on, the **duration**,
   and the **number** it was to/from.
4. **Incoming + outgoing** — today Recents only logs calls the app *places* (outgoing). To
   show the SIM a call "came" through, incoming/missed calls must also be logged (approved
   scope: log them via the in-call service while we're the default dialer).

### Current state (what exists)

- `call_logs` table holds only app-placed (outgoing) calls; write path is
  `InteractionRepository.logCall` / `updateCallOutcome`; read path is
  `CallLogRepository.recentCalls` → `CallRecord`.
- Outgoing lifecycle: `CallLifecycleMixin.startCall` → `CallService.placeCall` (provisional
  row) → reconcile on resume from the device call log (`call_log` package) → post-call sheet.
- Native Telecom bridge: `MainActivity` (method channel `contact_sphere/telecom` + event
  channel `contact_sphere/call_events`), `CallRegistry` (snapshot of the active call),
  `ContactSphereInCallService`. `main.dart` listens to `callEvents` and shows `InCallScreen`.
- `READ_PHONE_STATE` is already declared (needed for SIM enumeration).

### Android facts this relies on

- SIMs come from `SubscriptionManager.getActiveSubscriptionInfoList()`; the call-routable
  handles come from `TelecomManager.getCallCapablePhoneAccounts()` (`PhoneAccountHandle`).
  On stock Android a SIM handle's `id` is the subscription id as a string, so we match the
  two by that.
- To place a call on a specific SIM (as default dialer): `TelecomManager.placeCall(uri,
  extras)` with `EXTRA_PHONE_ACCOUNT_HANDLE` set to the chosen handle.
- The device call log's `PHONE_ACCOUNT_ID` == that handle `id`. The `call_log` package
  already exposes `phoneAccountId` and `simDisplayName` on `CallLogEntry`, so reconcile can
  back-fill the SIM for outgoing calls even when the system default was used.
- Incoming/missed calls: while default dialer, `ContactSphereInCallService` sees every call.
  Direction comes from `Call.Details.getCallDirection()` (API 29+) or a "was it ever ringing"
  heuristic below that; the SIM comes from `Call.Details.getAccountHandle().id`; duration from
  `connectTimeMillis`.

## Plan

### Database — `lib/database/database_helper.dart`
- Bump version **8 → 9**.
- Add `sim_id TEXT` and `sim_label TEXT` to the `call_logs` `CREATE TABLE` in `_onCreate`.
- Add a `v8 → v9` migration in `_onUpgrade`: two `ALTER TABLE call_logs ADD COLUMN` statements.

### Native (Kotlin)
- **`CallRegistry.kt`** — snapshot gains `phoneAccountId` (`details.accountHandle?.id`) and
  `direction` (`"incoming"|"outgoing"|"unknown"`, from `getCallDirection()` on API 29+, else a
  `sawRinging` flag tracked per call). Track/reset `sawRinging` in `onCallAdded` /
  `onStateChanged`.
- **`MainActivity.kt`** —
  - New method-channel case `getSimAccounts` → list of maps `{phoneAccountId, componentName,
    label, subscriptionId, slotIndex, displayName, carrierName}` built from
    `callCapablePhoneAccounts` enriched with matching `SubscriptionInfo`. Wrapped in try/catch;
    returns empty when `READ_PHONE_STATE` is missing.
  - Extend `placeCall` to read `phoneAccountId` + `componentName` args and, when present,
    reconstruct a `PhoneAccountHandle` and set `EXTRA_PHONE_ACCOUNT_HANDLE` in the extras.
- **`AndroidManifest.xml`** — no change needed (`READ_PHONE_STATE` already present).

### Flutter models
- **`lib/models/sim_account.dart`** (new) — `SimAccount { phoneAccountId, componentName,
  label, subscriptionId, slotIndex, displayName, carrierName }` with `fromMap` and a
  `displayLabel` getter (`displayName` ?? `label` ?? `carrierName` ?? `"SIM ${slotIndex+1}"`).
- **`lib/models/call_state.dart`** — add `String? phoneAccountId` and `CallDirection direction`
  (new enum `incoming|outgoing|unknown`); parse from the map.
- **`lib/models/call_record.dart`** — add `String? simId`, `String? simLabel`; parse in
  `fromJoinedMap`.

### Flutter services
- **`lib/services/telecom_service.dart`** — add `Future<List<SimAccount>> getSimAccounts()`
  (no-op `[]` off Android); change `placeCall` to
  `placeCall(String number, {String? phoneAccountId, String? componentName})`.
- **`lib/services/sim_service.dart`** (new) — thin wrapper over `TelecomService`: caches the
  SIM list, exposes `list()`, `labelFor(phoneAccountId)`, and `resolveForCall(settings)`
  (picks the default SIM by id, used by the mixin). Degrades to empty off Android / <2 SIMs.
- **`lib/services/call_service.dart`** — `placeCall` gains an optional `SimAccount? sim`;
  passes its handle to `TelecomService.placeCall`; stores `simId`/`simLabel` on the provisional
  row (via `logCall`). `reconcile` back-fills `sim_id`/`sim_label` from the matched
  `CallLogEntry` (`phoneAccountId`/`simDisplayName`) when not already set.
- **`lib/services/call_event_logger.dart`** (new) — subscribes to `TelecomService.callEvents`;
  accumulates the current call's number/SIM/direction/connect-time; on call end logs **only
  incoming/missed** calls to `call_logs` (type `incoming` if it was ever active else `missed`,
  duration from `connectTimeMillis`, SIM label mapped via `SimService`, contact resolved by
  number). Outgoing calls are left to `CallService` (no double-logging). Best-effort; started
  from `main.dart`.

### Flutter repositories
- **`lib/repositories/interaction_repository.dart`** — `logCall` gains `simId`/`simLabel`
  params; `updateCallOutcome` gains optional `simId`/`simLabel` (only written when non-null).
- **`lib/repositories/call_log_repository.dart`** — no change (`SELECT cl.*` already returns
  the new columns).

### Flutter state — `lib/state/app_settings.dart`
- Add `String? defaultSimId` (null = system default) and `bool askSimBeforeCall` (default
  `false`), with `load()` + persisted setters (`shared_preferences`), mirroring the existing
  pattern.

### Flutter UI
- **`lib/screens/sim_settings_screen.dart`** (new) — lists active SIMs; a "Default SIM"
  radio group (System default + each SIM) and an "Ask which SIM before each call" switch.
  Shows an explanatory note when <2 SIMs / not on Android.
- **`lib/widgets/sim_picker_sheet.dart`** (new) — `showSimPickerSheet(context, sims)` bottom
  sheet returning the chosen `SimAccount?` (null = cancel).
- **`lib/screens/settings_screen.dart`** — add a "SIM & calling" card routing to
  `SimSettingsScreen`.
- **`lib/widgets/call_lifecycle_mixin.dart`** — before `CallService.placeCall`, resolve the
  SIM: if `askSimBeforeCall` and ≥2 SIMs → show the picker (cancel aborts the call); else use
  the default SIM (or none → system default). Pass the chosen `SimAccount?` through.
- **`lib/screens/call_history_screen.dart`** — extend the call card: subtitle shows
  `time · duration · SIM label`, and the raw **number** as a second muted line when the row is
  a known contact (title shows the name). Incoming/missed icons already exist.
- **`lib/main.dart`** — instantiate and `start()` a `CallEventLogger` (alongside the existing
  nav listener; the events stream is broadcast so both can listen).

### Docs
- **`docs/known-gaps.md`** — add a "Resolved (2026-07-01 multi-SIM build-out)" entry.
- **`docs/architecture.md`** — one line noting SIM enumeration/selection and incoming-call
  logging in the Telecom section.

## Notes / limitations (to document, not blockers)
- SIM enumeration and incoming-call logging require the app to hold `READ_PHONE_STATE` and (for
  incoming logging) to be the **default dialer**. Both degrade gracefully to "no SIMs / no
  incoming rows" otherwise.
- Matching SIM handle ↔ subscription by `id` is the stock-Android behavior; on OEMs where it
  differs we still show the `PhoneAccount` label and can still place the call.
- Outgoing calls initiated outside our UI (e.g. a third-party `ACTION_CALL`) while we're
  default won't get an app `call_logs` row — unchanged from today.

## Test / verify
- `flutter analyze` clean; `flutter test` (widget smoke test) passes.
- New services no-op off Android so tests are unaffected.

## Files changed/created
- `android/.../CallRegistry.kt`, `android/.../MainActivity.kt` (native)
- `lib/models/sim_account.dart` (new), `lib/models/call_state.dart`, `lib/models/call_record.dart`
- `lib/services/telecom_service.dart`, `lib/services/sim_service.dart` (new),
  `lib/services/call_service.dart`, `lib/services/call_event_logger.dart` (new)
- `lib/repositories/interaction_repository.dart`
- `lib/state/app_settings.dart`
- `lib/screens/sim_settings_screen.dart` (new), `lib/widgets/sim_picker_sheet.dart` (new),
  `lib/screens/settings_screen.dart`, `lib/widgets/call_lifecycle_mixin.dart`,
  `lib/screens/call_history_screen.dart`
- `lib/database/database_helper.dart`, `lib/main.dart`
- `docs/known-gaps.md`, `docs/architecture.md`
