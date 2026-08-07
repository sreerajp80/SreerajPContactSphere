# Ongoing-call notification in the shade (return to call + call controls)

**Status:** completed

## Issue

During an in-progress call, switching to another app leaves the user with no way back to
the call window, and pulling down the notification shade shows no useful call UI. Other
dialers (see the reference screenshot the user shared) show a rich **call notification**
in the shade: contact photo + name, a live call-duration timer, the SIM/account label,
and **hang-up / speaker / mute** buttons — tapping the notification returns to the call.

Root cause in this app:
- The call notification's lifetime is tied to **ringing only**. `CallRegistry` fires
  `stopRingingIfNeeded()` the moment a call stops ringing — i.e. when it is **answered**
  (`CallRegistry.kt:127-131`) — and `ContactSphereInCallService.stopRinging()` then calls
  `stopForeground(STOP_FOREGROUND_REMOVE)`, removing the notification
  (`ContactSphereInCallService.kt:85-90`).
- `startRinging` only fires on `STATE_RINGING` (incoming), so **outgoing** calls never get
  a notification and never run the required `phoneCall` foreground service.
- Even the ringing notification is plain: static "Incoming call" text, no duration, no
  action buttons (`buildIncomingNotification`, `ContactSphereInCallService.kt:100-133`).

The Flutter `InCallScreen` route stays mounted for the whole call
(`main.dart:92-103`), so no Dart change is needed — the fix is entirely native: keep a
foreground call notification alive for the whole call and make it a rich
`Notification.CallStyle` notification.

## Fix

Keep one `phoneCall` foreground service + call notification alive for the entire life of
any call (incoming or outgoing), reusing a single notification id so it's swapped in place,
never flickered. Build it as `Notification.CallStyle` on API 31+, with a manual fallback
below that.

Notification shapes:
- **Incoming (ringing):** `CallStyle.forIncomingCall(person, declineIntent, answerIntent)`
  on 31+ (answer/decline buttons); keep `setFullScreenIntent` so it still takes over the
  screen / lock screen as today. Fallback <31: current full-screen notification + Answer/
  Decline actions.
- **Ongoing (active / dialing / holding / outgoing):** `CallStyle.forOngoingCall(person,
  hangUpIntent)` on 31+; content intent returns to the call window; live duration via
  `setUsesChronometer(true)` + `setWhen(connectTimeMillis)`; extra **mute** and **speaker**
  toggle actions reflecting current audio state. No full-screen intent (must not hijack the
  screen mid-call). Fallback <31: `Notification.Builder` + chronometer + addAction buttons.

Remove the notification and leave foreground only when **all** calls end.

Caller identity: `Person` built from the name/number the Flutter side already pushes down
(`updateCallerName`); use the contact photo as the person icon when a bitmap is available
(reuse the existing name-push path; a follow-up can add the photo if not trivially
available). SIM label ("via Jio") shown via the account label already in the snapshot.

### Files to change

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`**
   - Extend the `RingController` interface (update its doc — it now owns the whole
     call-notification lifecycle, not just ringing):
     - `fun showOngoingCall(number: String?)` — a non-ringing call is in progress.
     - `fun onCallEnded()` — no calls remain: clear notification + leave foreground.
   - Add `refreshCallNotification()` reading `primaryCall()`: `null` → `onCallEnded()`;
     `ringing` → return (ring path owns it); else → `showOngoingCall(number)`. Call it from
     the single `notifyChange()` choke point so every add/remove/state/audio change
     re-evaluates it (idempotency handled service-side).
   - Add helpers the service reads to render the ongoing notification:
     `currentConnectTimeMillis()`, `isMuted()`, `isSpeakerOn()`, plus `toggleMute()` /
     `toggleSpeaker()` (wrap existing `setMuted`/`setSpeaker`) invoked by the action buttons.

2. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`**
   - Decouple ringtone from foreground: `stopRinging()` stops the *ringer* only (no
     `stopForeground`).
   - Track `currentNumber`/`currentName`/`notifiedOngoing`; add `showOngoingCall(number)`
     (store, `startForeground` with the ongoing notification, idempotent per number, stop
     ringer if running) and `onCallEnded()` (stop ringer, `stopForeground(REMOVE)`, reset).
   - Replace `buildIncomingNotification` with `buildCallNotification(number, name, ongoing)`
     using `Notification.CallStyle` on API 31+ (incoming vs ongoing per above) and a
     `Notification.Builder` + `addAction` fallback below; single channel + single id.
   - `updateCallerName` updates whichever notification is currently posted (ring or ongoing).
   - Rename `RING_NOTIFICATION_ID` → `CALL_NOTIFICATION_ID`.

3. **New: `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallActionReceiver.kt`**
   - A `BroadcastReceiver` handling the notification action buttons — `ACTION_HANGUP`,
     `ACTION_MUTE`, `ACTION_SPEAKER`, `ACTION_ANSWER`, `ACTION_DECLINE` — by calling the
     corresponding `CallRegistry` methods (`disconnect` / `toggleMute` / `toggleSpeaker` /
     `answer` / `disconnect`). PendingIntents for these are built in the service.

4. **`android/app/src/main/AndroidManifest.xml`**
   - Declare `<receiver android:name=".CallActionReceiver" android:exported="false"/>`.

### Not changing
- No Flutter/Dart changes: `InCallScreen` already persists for the call.
- No new permissions: `FOREGROUND_SERVICE_PHONE_CALL`, `USE_FULL_SCREEN_INTENT`,
  `POST_NOTIFICATIONS` are already declared.

## Verification
- Outgoing call → drag down shade → rich call notification with duration + hang-up/mute/
  speaker; tap → returns to the call window; buttons control the call.
- Incoming ring → still full-screen / over lock screen; Answer/Decline work.
- Answer → switch apps → notification persists as ongoing → tap → returns to call.
- Mute/speaker buttons reflect and toggle current audio state.
- Call ends (either side) → notification removed, service leaves foreground.
- Build `flutter build apk` succeeds; behavior verified on a device/emulator.
