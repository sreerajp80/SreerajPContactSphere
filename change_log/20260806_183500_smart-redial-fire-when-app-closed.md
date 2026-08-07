# Smart Redial now fires with the app closed

Implements [plans/20260806_180650_smart-redial-fire-when-app-closed.md](../plans/20260806_180650_smart-redial-fire-when-app-closed.md).

## The problem

A scheduled auto-retry did nothing at its scheduled time while the app was closed. The
call only went out when the user next opened the app, where the SIM chooser was waiting.

Cause: the alarm only parked the number and asked Flutter to dial. On a cold start Flutter
picks a parked number up only after its first frame and after App lock, neither of which
happens while the app is closed. On top of that, the fire path asked which SIM to use —
the SIM picked at schedule time was never sent to the native side.

## What changed

### Native (Kotlin)

- **New `TelecomCaller.kt`** — places calls through `TelecomManager` from any `Context`.
  `MainActivity.placeCall` now delegates to it, so UI-placed and alarm-placed calls share
  one implementation (SIM routing included).
- **New `SmartRedialReceiver.kt`** — the alarm's new target. It checks the task's one-shot
  token, then places the call itself. No activity, no Flutter engine. Once Telecom has the
  call, `ContactSphereInCallService` brings up the in-call screen as it always did.
  If the call can't be placed (not the default dialer any more, permission revoked), it
  posts a high-priority "Time to call X / tap to call" notification that opens our dialer
  pre-filled, so a reminder is never silently dropped.
- **`SmartRedialManager.kt`** — tasks now also store the SIM (`phoneAccountId`,
  `componentName`); `consume` returns a `Task` (number, name, SIM) instead of just the
  number; the alarm's `PendingIntent` is now a broadcast to `SmartRedialReceiver` instead
  of an activity launch, which removes the background-activity-launch problem the old code
  had to work around. `setAlarmClock` is kept for exact, Doze-proof timing.
- **`MainActivity.kt`** — passes the SIM through on `scheduleSmartRedial`; its
  `ACTION_SMART_REDIAL_FIRE` handler stays as the path for alarms armed by an older build
  and now dials natively too (falling back to the old Flutter path).
- **`AndroidManifest.xml`** — registers `SmartRedialReceiver` (not exported).

### Flutter (Dart)

- `telecom_service.dart` — `scheduleSmartRedial` sends `phoneAccountId` / `componentName`.
- `smart_redial_service.dart` — resolves the SIM when scheduling: the SIM of the call that
  went unanswered when it is still active, else the user's default SIM, else the system
  default.
- `app_settings.dart` — new `readDefaultSimId()` static reader (services have no
  `BuildContext`).
- `call_lifecycle_mixin.dart` — remembers the SIM the call went out on and passes it to the
  Smart Redial sheet.
- `call_history_screen.dart` — passes the call's recorded SIM to the sheet.

### Docs

- `docs/features.md` and `docs/feature_analysis_and_roadmap.md` describe the new fire path.

## Checks run

- `flutter analyze` — no issues.
- `flutter build apk --debug --flavor dev` — builds (Kotlin compiles).

## Verified on the device (2026-08-06, moto / Android 16)

A 1-minute retry was scheduled and the app was cleared from recents. From the system logs:

- alarm armed for `18:27:40.457`, fired at `18:27:40.459` — 2 ms late, `RTC_WAKEUP`,
  `exactAllowReason=permission`, and the phone's "next wake from idle" (Doze did not defer it);
- `18:27:40.474` the receiver placed the call (Telecom `TC@666`) on the expected SIM, with
  the app process still fully background (`cch-empty`, unfrozen for the broadcast);
- `18:27:40.486` the system bound `ContactSphereInCallService`;
- `18:27:40.516` the in-call screen launched — `BAL_ALLOW_TOKEN`, no background-launch block;
- `18:28:36` the call disconnected normally (the other side had stopped ringing; the network
  keeps ringing until it gives up, which is carrier behaviour, not the app).

No errors, no `SecurityException`, no fallback notification needed.

Still worth checking some time: the same run with the screen off and locked, and that a
reminder still auto-cancels when the contact calls back first.

Note: battery savers / OEM "restricted" settings can still hold an exact alarm back on
some phones. That is a device setting, not something the app can override.
