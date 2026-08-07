# Change log: In-call SIM indicator

Implements [plans/20260703_162522_in-call-sim-indicator.md](../plans/20260703_162522_in-call-sim-indicator.md).

## What changed

The full-screen in-call UI now shows which SIM the call is on, for both incoming and
outgoing calls.

**`lib/screens/in_call_screen.dart`**

- Imported `../services/sim_service.dart` and added a `SimService _sim` instance.
- Added state fields `_resolvedSimLabel` (the human SIM label) and `_resolvedSimFor`
  (the phoneAccountId last resolved, to avoid re-querying on every event — mirrors the
  existing `_resolvedFor` name-caching pattern).
- Added `_resolveSim(String? phoneAccountId)`: returns early when the id is
  empty/unchanged, else maps it to a label via `SimService.labelFor` and `setState`s
  the result. Best-effort (chip stays hidden on failure).
- Called `_resolveSim(_state.phoneAccountId)` from `initState` and from the
  `callEvents` listener, alongside the existing `_resolveName` calls, so it stays
  correct across call transitions.
- Rendered a small SIM chip (`_simChip`) in the identity block below the status label,
  styled like the existing `_heldBanner` pill (rounded pill, `fg.withValues(alpha:
  0.14)` fill, SIM-card icon + label). Shown only when a label resolves, so
  single-SIM/unknown cases add no clutter. Because the identity block renders in every
  phase, it covers ringing/dialing/active/holding uniformly.

## Notes

- No native, `CallState`, or `SimService` changes — `CallState.phoneAccountId` was
  already populated for every call and `SimService.labelFor` already existed.
- `flutter analyze lib/screens/in_call_screen.dart` — no issues.
- Per the plan's open decision, the chip shows whenever a SIM label resolves
  (including single-SIM devices), matching the request to always show which SIM.
