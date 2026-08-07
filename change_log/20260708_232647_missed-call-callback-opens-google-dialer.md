# Change log: Missed-call "Call back" now opens ContactSphere, not Google Dialer

Implements plan
`plans/20260708_231638_missed-call-callback-opens-google-dialer.md`.

## Problem

Tapping **Call back** on a missed-call notification opened the Google Dialer instead
of ContactSphere. The button fires an `ACTION_CALL` intent with a `tel:` URI, but the
app registered only `ACTION_DIAL`, `ACTION_VIEW` (`tel:`) and `ACTION_CALL_BUTTON` — not
`ACTION_CALL` — so Android routed the callback to Google Dialer, which does register it.
Separately, the app never read a `tel:` number from a launch intent, so even the
dial/view intents it already advertised were dropped.

## What changed

### Native (Android)
- **`android/app/src/main/AndroidManifest.xml`** — added a new intent-filter for
  `android.intent.action.CALL` on the `tel:` scheme (with `category.DEFAULT` only, and
  deliberately **without** `category.BROWSABLE` so a web page cannot place a call
  without user action). The existing DIAL/VIEW/CALL_BUTTON filters are unchanged.
- **`.../MainActivity.kt`** —
  - Added `handleDialIntent()` (called from `onCreate` and `onNewIntent` next to
    `handleVCardIntent`). It matches `ACTION_CALL` / `ACTION_DIAL` / `ACTION_VIEW`
    with a `tel:` URI, decodes the number (`telNumber()` helper, URL-decoded from the
    URI scheme-specific part), and parks it in `pendingDial` with a
    `pendingDialAutoCall` flag (true only for `ACTION_CALL`).
  - Kept a reference to the `contact_sphere/telecom` channel (`telecomChannel`) so a
    warm dial intent can nudge Dart via `dialReceived`.
  - Added a `getPendingDial` method-channel case that returns `{number, autoCall}` and
    clears it (one-shot, so a re-poll can't dial twice) — the same pattern as
    `getPendingVCard`.

### Flutter (Dart)
- **`lib/services/telecom_service.dart`** — added `getPendingDial()` returning
  `({String number, bool autoCall})?` (null off Android / when nothing is parked).
- **`lib/main.dart`** —
  - Listens on the telecom channel for the `dialReceived` nudge and, on cold start
    (in `_bootstrap`), collects any parked number via `_collectPendingDial()`.
  - `autoCall` (a "Call back") → `_placeCallback()` places the call immediately
    through `CallService.placeCall` (flows through our in-call UI when we are the
    default dialer, and logs a Recents row). A call that parks on a SIM choice is
    handled by the existing `SELECT_PHONE_ACCOUNT` path in `_onCall`.
  - Not `autoCall` (a tapped `tel:` link) → pushes `DialerScreen` pre-filled so the
    user reviews the number before calling.
  - Added `_reconcileCallbackIfEnded()` (called from `_onCall`) that back-fills the
    real duration/type from the device call log when the callback ends — mirroring
    `CallLifecycleMixin`'s end-detection, but without the post-call feedback sheet
    (a notification-initiated callback has no screen to host it).
- **`lib/screens/dialer_screen.dart`** — added an optional `initialNumber` parameter;
  `initState` pre-fills the dialpad (dial-safe filtered) and refreshes the contact
  suggestion strip.

## Behaviour after the change
- Missed-call **Call back** → ContactSphere places the call (its own in-call UI when it
  is the default phone app), and the call is reconciled into Recents.
- A tapped `tel:` link elsewhere → ContactSphere opens on the dialer pre-filled.

## Verification
- `flutter analyze` — no issues (whole project).
- `gradlew compileDevDebugKotlin` — BUILD SUCCESSFUL (only pre-existing
  `startActivityForResult` deprecation warnings).
- Manual device testing (set ContactSphere as default phone app, trigger a missed call,
  tap Call back; tap a `tel:` link from another app) is recommended to confirm end to end.
