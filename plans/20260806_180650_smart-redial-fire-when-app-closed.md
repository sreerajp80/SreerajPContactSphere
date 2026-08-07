# Smart Redial does not fire when the app is closed

**Status:** completed

## The issue

A scheduled auto-retry (Smart Redial) does nothing at the scheduled time when the app is
not running. Later, when the user opens the app, the SIM selection sheet appears — the
call was waiting all that time instead of being placed.

## Why it happens

Two separate problems, both on the "fire" path.

### 1. The call is only placed after the Flutter UI paints and the user is past App lock

At fire time the alarm launches `MainActivity` with `ACTION_SMART_REDIAL_FIRE`
(`SmartRedialManager.armAlarm` → `MainActivity.handleSmartRedialIntent`,
[MainActivity.kt:731](android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt#L731)).
Native only parks the number in `pendingDial` and nudges Dart. The actual call is placed
by Dart in `_collectPendingDial` → `_placeCallback`
([main.dart:214](lib/main.dart#L214), [main.dart:438](lib/main.dart#L438)).

On a cold start, Dart reaches that code only through
`WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap())`
([main.dart:150](lib/main.dart#L150)), and `_bootstrap` first `await`s `_maybeLock()`
(App lock) and the permission request before it collects the pending dial
([main.dart:157-188](lib/main.dart#L157-L188)).

So nothing is dialled until (a) the Flutter view really renders its first frame, and
(b) the user has passed App lock. When the app is dead and the alarm fires in the
background, neither happens — the number just sits parked until the user opens the app,
which is exactly the reported symptom.

### 2. The fire path asks for the SIM, which needs a human tap

`_placeCallback` shows the SIM picker whenever "Ask which SIM before calling" is on
([main.dart:448-457](lib/main.dart#L448-L457)). An unattended auto-retry cannot wait for
a tap. The SIM the user already used is captured when scheduling
(`simId` in `SmartRedialService.scheduleAutoRedial`,
[smart_redial_service.dart:182](lib/services/smart_redial_service.dart#L182)) but is
**never sent to native** (`TelecomService.scheduleSmartRedial` sends only id, number,
name, time — [telecom_service.dart:95](lib/services/telecom_service.dart#L95)), so at
fire time the app has forgotten it and asks again.

## The fix

Place the call **natively** when the alarm fires, with the SIM decided at schedule time.
No Flutter engine, no first frame, no App lock in the way. Once the call exists, our
`ContactSphereInCallService` is bound by the system and already brings up the in-call
screen by itself (`launchInCallUi()`,
[ContactSphereInCallService.kt:669](android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt#L669)),
so the user sees the normal calling screen even from a fully closed app.

Detail:

1. **Store the SIM with the task.** `SmartRedialManager.schedule` also takes
   `phoneAccountId` + `componentName` and saves them in its JSON record. `consume`
   returns all three instead of just the number.
2. **Fire into a broadcast, not an activity.** The alarm's `PendingIntent` becomes
   `PendingIntent.getBroadcast` to a new `SmartRedialReceiver`. A broadcast is never
   subject to the background-activity-launch limits that the current activity intent has
   to work around. `setAlarmClock` is kept, so the device still wakes at the exact time.
3. **New `SmartRedialReceiver`**: consumes the token (same one-shot check as today), then
   places the call through `TelecomManager.placeCall` with the stored phone account.
4. **Shared place-call helper.** `MainActivity.placeCall`
   ([MainActivity.kt:1022](android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt#L1022))
   moves into a small `TelecomCaller` object that works with any `Context`, so the
   receiver and the activity use one implementation.
5. **Fallback when we cannot dial** (not the default dialer, or `CALL_PHONE` denied): the
   receiver posts a high-priority "Tap to call <name>" notification whose tap opens the
   app on the existing `ACTION_SMART_REDIAL_FIRE` path. The reminder is then never
   silently lost. The existing activity path stays in place for this.
6. **Dart side:** resolve the SIM when the reminder is scheduled (the SIM of the call that
   just failed, else the configured default SIM) and pass `phoneAccountId` +
   `componentName` down to native. The fire-time SIM picker is then never needed.
7. `main.dart`'s `_placeCallback` stays as it is — it still serves the missed-call
   "Call back" and the notification fallback above.

### Note (not fixed by code)

Battery savers / OEM "restricted" app settings can still delay an exact alarm on some
phones. The plan makes the app do the right thing the moment the alarm arrives; if the
system holds the alarm back, that is a device setting the user has to relax.

## Files to change

| File | Change |
| --- | --- |
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/SmartRedialManager.kt` | store SIM in the task, arm a broadcast PendingIntent, `consume` returns number + SIM |
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/SmartRedialReceiver.kt` (new) | alarm receiver: consume token, place the call, or post the fallback notification |
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/TelecomCaller.kt` (new) | context-based `placeCall`, shared by the activity and the receiver |
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` | accept the SIM args on `scheduleSmartRedial`, use `TelecomCaller`, keep the activity fire path as fallback |
| `android/app/src/main/AndroidManifest.xml` | register `SmartRedialReceiver` (not exported) |
| `lib/services/telecom_service.dart` | send `phoneAccountId` / `componentName` when scheduling |
| `lib/services/smart_redial_service.dart` | resolve the SIM at schedule time and pass it through |
| `lib/widgets/smart_redial_sheet.dart` | pass the resolved SIM (only if the resolution belongs here) |
| `docs/features.md` / `docs/architecture.md` | short note that Smart Redial fires natively |
| `change_log/` | change log after implementation |

## How to verify on the device

1. Schedule a 2-minute retry, then swipe the app away from Recents (fully closed).
2. Wait: the call must be placed at the scheduled minute and the in-call screen must come
   up on its own, with no SIM sheet and no App lock prompt.
3. Repeat with the screen off and locked — same result, screen wakes for the call.
4. Repeat with "Ask which SIM" on: the call must go out on the SIM used for the original
   call, without asking.
5. Cancel path: schedule, then let the contact call back before it fires — the reminder
   must still auto-cancel.
