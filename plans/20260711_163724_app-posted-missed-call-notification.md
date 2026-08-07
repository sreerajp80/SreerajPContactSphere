# Plan: App-posted missed-call notification + close the auto-call hole

**Status:** completed

## Issue

Security-review finding #6 (Low): `MainActivity` exports an `ACTION_CALL` (`tel:`)
intent-filter and auto-places the call for any `ACTION_CALL` intent
(`pendingDialAutoCall = true` → `main.dart` `_placeCallback`). Because the
activity is exported, a malicious app with no `CALL_PHONE` permission can send an
explicit `ACTION_CALL` intent and make ContactSphere dial for it (confused
deputy).

The only *legitimate* auto-call today is the **system's** missed-call "Call Back"
notification — and the system intent is indistinguishable from a forged one at the
point we handle it.

**Chosen approach (user decision):** ContactSphere posts its **own** missed-call
notification. Its "Call Back" button is a `PendingIntent` we create that targets a
**non-exported** component, so no other app can trigger it — auto-call becomes
trusted by construction on every Android version, with no caller-UID guessing.
Then every *external* `ACTION_CALL` is downgraded to "open the dialer pre-filled"
(no silent dial), which closes the hole.

## Why this is secure

`CallActionReceiver` is already `android:exported="false"` ("only our own
PendingIntents trigger it" — AndroidManifest.xml:207-209). A `PendingIntent`
pointing at a non-exported receiver can only be fired by us. External apps can
neither send to the receiver nor run our in-process code, so they cannot set the
"auto-call" state. The exported `ACTION_CALL` filter stays (so `tel:` links and
the system callback still resolve to us) but it will only ever **pre-fill** the
dialer now.

## Design

### A. Detect a missed call natively (works when the app/Flutter is closed)

The system binds `ContactSphereInCallService` for every incoming call while we are
the default dialer, regardless of whether our Activity or the Flutter engine is
running. So detection lives natively:

- Track, per call, whether it was **incoming** and whether it **ever went active**
  (answered). `CallRegistry` already tracks `sawRingingCalls` (incoming) and knows
  each `Call`; add a `sawActiveCalls` set (mark on `STATE_ACTIVE`).
- On `onCallRemoved`, a call is a **missed call** when it was incoming, never went
  active, and its `DisconnectCause` is *not* a local user action (i.e. not
  user-declined). Use `Call.Details.getDisconnectCause()`: post for
  `MISSED` / `REMOTE` / `REJECTED-by-remote`; skip `LOCAL` (the user declined) so
  a decline doesn't nag with a call-back. Blocked/screened calls never reach the
  InCallService, so they never produce this notification (they stay on the
  existing "blocked" journal path).

### B. Post our own missed-call notification (native)

In `ContactSphereInCallService` (reuses its existing notification machinery):

- A new **"Missed calls"** notification channel (default importance; its own id,
  separate from the call channels), and a distinct notification id per missed call
  (so several stack rather than replace each other).
- Content: title = caller (see "name" note below), text = "Missed call", a
  **Call Back** action, tap opens the app (call history). Uses `CATEGORY_MISSED_CALL`.
- Requires `POST_NOTIFICATIONS` on API 33+ — already declared
  (AndroidManifest.xml:50) and requested (`app_permissions.dart`). If the user
  denied it, the notification silently no-ops (safe degradation).

**Caller name:** native has no access to the contact DB (the same reason the
in-call notification gets its name *pushed* from Flutter). For v1 the missed-call
notification shows the **number**; when the Flutter engine is alive it resolves the
contact and re-posts with the name. Showing the saved name while the app is fully
closed would need a digits→name mirror (like the existing ringtone/screening
mirrors) — I've left that as a **follow-up**, not in this plan, to bound scope.
(Say if you'd rather include the name-mirror now.)

### C. Trusted "Call Back" → auto-call (native + Dart)

- The **Call Back** action is a `PendingIntent.getBroadcast` to `CallActionReceiver`
  (non-exported) with a new `ACTION_CALL_BACK` and the number as an extra.
- On receipt, the receiver records the number in a small in-process holder
  (a Kotlin `object`, e.g. `PendingCallback.number`, mirroring how `CallRegistry`
  is shared), cancels the missed-call notification, and launches `MainActivity`.
- `MainActivity` delivers a **trusted** auto-call to Dart **only** from
  `PendingCallback` (set exclusively by the non-exported receiver) — never from a
  raw intent action. It reuses the existing `getPendingDial` channel shape but with
  `autoCall = true` for this trusted source, then clears the holder (one-shot).

### D. Close the external hole (native)

- In `handleDialIntent`, external `ACTION_CALL` / `ACTION_DIAL` / `ACTION_VIEW`
  (`tel:`) now **always** park with `autoCall = false` → the dialer opens
  pre-filled and the user taps to call. No external intent can auto-dial.

### E. Suppress the system's missed-call notification (native)

- After posting ours, call `TelecomManager.cancelMissedCallsNotification()` (valid
  for the default dialer) so the user doesn't see two. **This is the main risk:**
  reliability varies by OEM (Motorola build on the moto g54), so it needs on-device
  verification; if a duplicate still shows, we adjust (timing, or accept the system
  one and only add our Call-Back-capable actions). Documented under Testing/Risks.

### F. Multi-SIM on the auto-call path (Dart)

`_placeCallback` currently dials with no SIM. Change it to resolve the SIM exactly
like the dialer (`CallLifecycleMixin._resolveSim`): read `AppSettings`; if
`askSimBeforeCall` and `SimService.list()` has 2+ SIMs → show `showSimPickerSheet`
and place on the chosen SIM (abort on dismiss); else place on the default SIM
(`SimService.defaultSim(defaultSimId)`, null = system default). The existing
`SELECT_PHONE_ACCOUNT` fallback in `_onCall` still covers the "ask every time /
no default outgoing account" case. Outgoing-call logging/reconciliation stays
intact because we keep placing through `CallService.placeCall`.

## Files to change

**Native (Android / Kotlin)**
1. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`
   — add `sawActiveCalls` tracking + a helper to classify a removed call as missed
   (incoming, never active, non-local disconnect) and expose its number.
2. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`
   — on missed call: build/post the missed-call notification (new channel + id,
   Call Back action) and call `cancelMissedCallsNotification()`.
3. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallActionReceiver.kt`
   — add `ACTION_CALL_BACK`: store number in the new `PendingCallback` holder,
   cancel the notification, launch `MainActivity`.
4. New `.../PendingCallback.kt` — tiny in-process holder (`object`) for the trusted
   call-back number.
5. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
   — `handleDialIntent`: external `ACTION_CALL` → `autoCall = false` (pre-fill).
     Deliver a trusted auto-call to Dart from `PendingCallback` (via the existing
     `getPendingDial`/`dialReceived` channel), clearing it after read.

**Flutter (Dart)**
6. `lib/main.dart` — `_placeCallback`: resolve SIM (picker when enabled + 2+ SIMs,
   else default) and pass to `CallService().placeCall`; abort on picker dismiss.

**Manifest / docs**
7. `android/app/src/main/AndroidManifest.xml` — update the `ACTION_CALL` filter
   comment (now pre-fill only; auto-call comes from our own notification).
8. `docs/architecture.md` / `docs/known-gaps.md` — document the app-posted
   missed-call notification and the trusted call-back path.

## Testing

- `flutter analyze`, `flutter test` (Dart change is SIM-resolution reuse; native
  changes aren't covered by Dart tests).
- Manual on device (moto g54), ContactSphere as default dialer:
  1. Miss an incoming call (don't answer) → **our** missed-call notification
     appears; the **system's** does not (verify no duplicate).
  2. Tap **Call Back** → the call is placed automatically; with 2+ SIMs and "ask
     which SIM" on, the SIM picker shows first, then it dials on the chosen SIM.
  3. Decline an incoming call → no call-back notification (declines aren't
     "missed").
  4. From another app, tap a `tel:` link / send `ACTION_CALL` → dialer opens
     pre-filled, **no** silent call.
  5. Deny notifications → no missed-call notification, app otherwise fine.

## Risks / rollback

- **Duplicate notification** if `cancelMissedCallsNotification()` is unreliable on
  this OEM — the key thing to verify on device; fallback is to tune timing or drop
  suppression and revisit.
- Missed-call classification edge cases (call-waiting second leg, quick flaps) —
  reuse `CallRegistry`'s existing per-call id/state tracking to stay consistent
  with the Recents logger.
- Rollback: remove the missed-call notification + `ACTION_CALL_BACK` path and the
  `PendingCallback` holder; the pre-fill-only `handleDialIntent` change can stay on
  its own as the minimal security fix if desired.
