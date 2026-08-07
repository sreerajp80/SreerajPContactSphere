# Multi-SIM support — change log

Implements plan `plans/20260701_122257_multi-sim-support.md`.

## Summary

Added multi-SIM support: enumerate the device's SIMs, place outgoing calls over a chosen SIM,
a "SIM & calling" settings screen (default SIM + per-call prompt), and Recents now shows each
call's SIM, duration, and number — including **incoming/missed** calls (logged while we're the
default dialer).

## Changes

### Database
- `lib/database/database_helper.dart` — DB **v8 → v9**: added `sim_id TEXT` and `sim_label TEXT`
  to `call_logs` (in `_onCreate` and a `v8→v9` `ALTER TABLE` migration).

### Native (Kotlin)
- `android/.../CallRegistry.kt` — call snapshot now includes `phoneAccountId`
  (`Call.Details.accountHandle.id`) and `direction` (`getCallDirection` on API 29+, else a
  `sawRinging` heuristic tracked per call).
- `android/.../MainActivity.kt` — new `getSimAccounts` method-channel call (SubscriptionManager +
  TelecomManager, matched by phone-account id); `placeCall` now accepts `phoneAccountId` +
  `componentName` and sets `EXTRA_PHONE_ACCOUNT_HANDLE` to route over the chosen SIM.

### Models
- `lib/models/sim_account.dart` (new) — `SimAccount` (phone-account id, component name, label,
  subscription id, slot, display/carrier name) with `displayLabel`.
- `lib/models/call_state.dart` — added `phoneAccountId` and `CallDirection` (new enum) with parsing.
- `lib/models/call_record.dart` — added `simId` / `simLabel` (parsed from `sim_id`/`sim_label`).

### Services
- `lib/services/telecom_service.dart` — `getSimAccounts()`; `placeCall(number, {sim})`.
- `lib/services/sim_service.dart` (new) — caching wrapper: `list()`, `labelFor(id)`,
  `defaultSim(id)`, `hasMultiple`.
- `lib/services/call_service.dart` — `placeCall` takes an optional `SimAccount`, passes its handle
  to Telecom and stores the SIM on the provisional row; `reconcile` back-fills `sim_id`/`sim_label`
  from the matched device-call-log entry (`phoneAccountId`/`simDisplayName`).
- `lib/services/call_event_logger.dart` (new) — logs **incoming/missed** calls (with SIM +
  duration) from the Telecom call-event stream; skips outgoing (handled by `CallService`).

### Repositories
- `lib/repositories/interaction_repository.dart` — `logCall` gained `simId`/`simLabel`;
  `updateCallOutcome` gained optional `simId`/`simLabel` (written only when non-null).
- `lib/repositories/call_log_repository.dart` — unchanged (`SELECT cl.*` already returns the
  new columns).

### State
- `lib/state/app_settings.dart` — added persisted `defaultSimId` (null = system default) and
  `askSimBeforeCall`, with getters + setters.

### UI
- `lib/screens/sim_settings_screen.dart` (new) — default-SIM chooser + "ask before each call"
  toggle; explains when no SIMs / not multi-SIM.
- `lib/widgets/sim_picker_sheet.dart` (new) — per-call SIM chooser bottom sheet.
- `lib/screens/settings_screen.dart` — added the "SIM & calling" card.
- `lib/widgets/call_lifecycle_mixin.dart` — resolves the SIM before dialing (default, or the
  picker when asking is on with 2+ SIMs; dismissing the picker aborts the call).
- `lib/screens/call_history_screen.dart` — Recents card shows `time · duration · SIM · intent`
  and the raw number as a second line for known contacts.
- `lib/main.dart` — starts/stops `CallEventLogger`.

### Docs
- `docs/known-gaps.md` — added the "2026-07-01 multi-SIM build-out" resolved entry.
- `docs/architecture.md` — added a "Multi-SIM" section.

## Verification
- `flutter analyze` — no issues.
- `flutter test` — all 27 tests pass.

## Notes / limitations
- SIM enumeration needs `READ_PHONE_STATE` (already declared); incoming-call logging needs the
  app to be the **default dialer**. Both degrade gracefully (no SIMs / no incoming rows).
- SIM handle ↔ subscription matching uses the stock-Android `id` convention; on OEMs where it
  differs the `PhoneAccount` label is still shown and the call is still placeable.
- Outgoing calls initiated outside our UI while default (e.g. a third-party `ACTION_CALL`) still
  won't get an app `call_logs` row — unchanged from before.
