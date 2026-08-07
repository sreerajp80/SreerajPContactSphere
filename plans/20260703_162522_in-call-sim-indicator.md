# In-call screen: show which SIM the call is on

**Status:** completed

## Issue

The full-screen in-call UI ([lib/screens/in_call_screen.dart](../lib/screens/in_call_screen.dart))
shows the caller name, status, and controls, but never indicates **which SIM** the
call is using. On a dual-SIM device the user can't tell which line an incoming or
outgoing call is on. This info should be visible for both incoming and outgoing
calls.

The data is already available: `CallState.phoneAccountId` is populated by the native
bridge for every call (`CallRegistry.kt:386`, `details?.accountHandle?.id`), and
`SimService.labelFor(phoneAccountId)` already maps that id to a human SIM label
(carrier / display name / "SIM 1"). So this is purely a UI addition on the Flutter
side — no native or model changes.

## Files to change

- `lib/screens/in_call_screen.dart` — resolve the SIM label from
  `_state.phoneAccountId` and render it in the identity block for all call phases.

## Plan for the fix

1. **Resolve the SIM label.**
   - Add `final SimService _sim = SimService();` and a `String? _resolvedSimLabel;`
     field, plus a `String? _resolvedSimFor;` guard (the phoneAccountId we last
     resolved, to avoid re-querying every rebuild — mirrors the existing
     `_resolvedFor` pattern for names).
   - Add `Future<void> _resolveSim(String? phoneAccountId)` that returns early if the
     id is unchanged/empty, then calls `_sim.labelFor(phoneAccountId)` and
     `setState`s `_resolvedSimLabel`. Best-effort in a try/catch like `_resolveName`.
   - Call `_resolveSim(_state.phoneAccountId)` from `initState` and from the
     `callEvents` listener (alongside the existing `_resolveName` calls), so it stays
     correct as the call transitions.

2. **Render the SIM chip.** In `_identity`, below the `_statusLabel` `Text`, add a
   small pill showing a SIM-card icon + the resolved label (e.g. `SIM 1` / carrier
   name), styled to match the existing `_heldBanner` chip (rounded `999` radius,
   `fg.withValues(alpha: 0.14)` fill, `fg` foreground) so it fits the app's own
   design over both the photo backdrop and the brand gradient. Only shown when
   `_resolvedSimLabel` is non-null, so single-SIM/unknown cases add no clutter.

   This lives in the identity block which renders in every phase (ringing / dialing /
   active / holding), so it covers incoming and outgoing calls uniformly.

## Notes / decisions

- **Show always vs. only on multi-SIM:** the chip appears whenever a SIM label
  resolves. On a single-SIM device this still shows the one SIM's label. If you'd
  rather hide it on single-SIM devices (only show when `SimService.hasMultiple`), say
  so and I'll gate it — but the request was to always show which SIM, so the default
  here is always-on when a label is known.
- No changes to `CallState`, native code, or `SimService` — all inputs already exist.
