# Plan: Gate auto-call on a trusted caller (fix confused-deputy)

**Status:** dropped

Superseded by `20260711_163724_app-posted-missed-call-notification.md` — the user
chose the "app posts its own missed-call notification" approach instead of gating
the system notification's `ACTION_CALL`.

## Issue

`MainActivity` exports an `ACTION_CALL` (`tel:`) intent-filter so the Android
system's missed-call notification "Call Back" button reaches ContactSphere and it
places the call immediately (`pendingDialAutoCall = true` →
`main.dart` `_placeCallback`).

Because the activity is exported, **any** app can send an explicit `ACTION_CALL`
intent to `MainActivity`. ContactSphere then places the call using its own
`CALL_PHONE` permission — a "confused deputy": an app with no call permission
borrows ours to dial a number it chose (e.g. a premium-rate number). This is
security-review finding #6 (Low).

The intended, legitimate auto-call is the **system** missed-call callback. The fix
must keep that working (auto-place, no confirmation) while refusing to silently
auto-call for intents we cannot trace to a trusted system source. Multi-SIM must
behave like the dialer: when the user enabled "ask which SIM" and there are 2+
SIMs, show the SIM picker before placing.

## Root cause

`handleDialIntent` sets `autoCall = (intent.action == ACTION_CALL)` with no check
of **who** sent the intent. The system missed-call notifier and a malicious app
look identical at this point.

## Fix approach

**1. Native: only mark `autoCall = true` when the caller is a trusted system UID.**

The system's missed-call callback is launched by a PendingIntent owned by the
platform (Telecom / phone process), whose UID is below
`Process.FIRST_APPLICATION_UID` (10000) — i.e. a system UID (1000 = SYSTEM,
1001 = RADIO/phone, etc.). Third-party apps always have UID ≥ 10000. So:

- If the launching caller's UID is a **system UID** → keep `autoCall = true`.
- Otherwise → downgrade to `autoCall = false` (park the number as a normal DIAL:
  the dialer opens **pre-filled**, and the user taps to call). The number is never
  silently dialed for an untrusted caller. `ACTION_DIAL` / `ACTION_VIEW` are
  unaffected (already `autoCall = false`).

Determining the caller UID (all checks are best-effort; on failure we fall back to
the safe `autoCall = false`):

- **`onCreate` (cold start — the common missed-call case):** on **API 34+**
  (Android 14) use the public `getLaunchedFromUid()`; a system UID → trusted.
- **`onNewIntent` (warm, app already foreground — `singleTop`):** on **API 35+**
  (Android 15) use the per-intent caller (`onNewIntent(Intent, ComponentCaller)` /
  the intent's `ComponentCaller.getUid()`) so we check the sender of *this*
  intent, not the original launcher.
- **Anything we can't verify** (API < 34, warm intent on API 34, or any lookup
  failure) → **not trusted** → `autoCall = false` (open dialer pre-filled).

Rationale for the strict fallback: the target device (moto g54) runs Android
14/15, so the real missed-call callback stays auto-call. On older/unverifiable
paths the callback degrades safely to "dialer opens pre-filled with the number"
— one extra tap, no security hole. (This is my recommendation; the alternative —
a spoofable `getReferrer()` package allowlist to keep auto-call on old devices —
is weaker and I do not recommend it. Say so if you'd prefer it.)

**2. Dart: honor the multi-SIM setting on the auto-call path.**

`_placeCallback` currently calls `CallService().placeCall(number: number)` with no
SIM. Change it to resolve the SIM the same way the dialer does
(`CallLifecycleMixin._resolveSim`): read `AppSettings`; if `askSimBeforeCall` and
`SimService.list()` returns 2+ SIMs, show `showSimPickerSheet` and place on the
chosen SIM (abort if dismissed); otherwise place on the configured default SIM
(`SimService.defaultSim(defaultSimId)`), which may be null = system default. The
existing `SELECT_PHONE_ACCOUNT` fallback in `_onCall` still covers the "no default
outgoing account" case. AppSettings is reachable via the navigator context /
provider; if not cleanly reachable there, read it through the existing
`AppSettings` instance used at startup.

## Files to change

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - Add a `callerIsTrustedSystem(...)` helper (UID < `FIRST_APPLICATION_UID`),
     with the API-gated cold/warm lookups above.
   - Override `onNewIntent(Intent, ComponentCaller)` on API 35+ so the warm path
     can see the per-intent caller (keep the existing `onNewIntent(Intent)` for
     older APIs).
   - In `handleDialIntent`, compute `autoCall` as
     `action == ACTION_CALL && callerIsTrustedSystem(...)`.

2. **`lib/main.dart`**
   - `_placeCallback`: resolve the SIM (picker when enabled + 2+ SIMs, else
     default) and pass it to `CallService().placeCall(number:, sim:)`; on picker
     dismissal, do not place the call.

3. **`android/app/src/main/AndroidManifest.xml`**
   - Update the comment on the `ACTION_CALL` filter to note that auto-call is now
     gated on a trusted system caller (behavior comment only; the filter stays so
     the system callback still resolves to us).

4. **`docs/architecture.md`** / **`docs/known-gaps.md`** *(if they describe the
   dial-intent flow)* — note the trusted-caller gate on auto-call.

## Testing

- `flutter analyze`, `flutter test` (Dart change is SIM-resolution reuse; native
  change isn't covered by Dart tests).
- Manual on device (moto g54, Android 14/15), ContactSphere as default dialer:
  - Get a missed call → tap **Call Back** on the system notification → call is
    placed automatically. With 2+ SIMs and "ask which SIM" on → SIM picker shows
    first, then it dials on the chosen SIM.
  - Tap a `tel:` link / dialer intent from another app → dialer opens pre-filled
    (unchanged).
  - (If testable) an explicit `ACTION_CALL` from a test app → dialer opens
    pre-filled, **no** silent call.

## Risks / rollback

- If the UID lookup is wrong on some OEM build, the worst case is the missed-call
  callback opens the dialer pre-filled instead of auto-dialing (safe degradation,
  not a call to the wrong number). Rollback = restore
  `autoCall = (action == ACTION_CALL)` and the old `_placeCallback`.
