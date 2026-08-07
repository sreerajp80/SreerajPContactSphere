# Plan — Fix incoming calls: no ringtone, quick disconnect, double Recents entry

**Status:** completed

## The issue (as reported)

On an **incoming** call:
1. **No ringtone sound.**
2. **The call is disconnected quickly** (before it can be answered).
3. **Two entries appear in Recents** for the one call instead of one.

## Root cause

The manifest declares that ContactSphere owns the incoming-call ringing experience:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<meta-data android:name="android.telecom.IN_CALL_SERVICE_RINGING" android:value="true"/>
```

Declaring `IN_CALL_SERVICE_RINGING="true"` makes the Telecom framework hand the **entire** ringing
experience to our app: the platform no longer plays the ringtone, vibrates, or posts an incoming-call
notification. In return the default dialer MUST itself:

1. Play the ringtone (with audio focus, honoring silent / vibrate / DND),
2. Vibrate,
3. Post a high-priority notification with a **full-screen intent** (so the call UI can appear from
   background / over the lock screen on Android 10+), and
4. Keep the `InCallService` alive as a `phoneCall` **foreground service**.

`ContactSphereInCallService.onCallAdded` currently does none of these — it only calls
`startActivity(...)`. Consequences, matching all three symptoms:

- **No ringtone** — we claimed the ringing role, so the system stays silent and we never play a tone.
- **Quick disconnect** — on our `targetSdk` (34/35), `startActivity` from a background service is
  blocked, and an owner-of-ringing that posts no full-screen-intent notification / foreground service
  is treated as "not handling" the call, so Telecom tears the ringing call down after a short timeout.
- **Two Recents entries** — `CallEventLogger` accumulates call state and writes one `call_logs` row
  when the call "ends"; it has **no call-identity dedupe**. A ringing call that flaps
  (added → torn down → state change) passes through more than one end cycle, so one physical call
  writes multiple rows.

## Chosen direction

**App owns ringing (full implementation)** — confirmed by the user. This preserves the per-contact
ringtone feature (`contacts.ringtone_path`, currently metadata-only) by letting us play a contact's
custom tone on incoming calls. We therefore *keep* `IN_CALL_SERVICE_RINGING="true"` and implement the
four responsibilities above, plus fix the double-log.

### Ringtone resolution strategy

The per-contact tone lives in the app's SQLite DB (Flutter side), and the Flutter engine may not be
running the instant a call arrives. So:

- **Native starts the default ringtone immediately** on `onCallAdded` (instant ringing — fixes the
  core bug even from a cold start).
- **Flutter overrides** with the contact's custom tone once it resolves the caller by number, via a
  new `setIncomingRingtone(path)` method channel. Native swaps the playing tone. If the contact has
  no custom tone (or resolution fails), the default keeps playing.

Ringer-mode respect: `SILENT` → no sound, no vibrate; `VIBRATE` → vibrate only; `NORMAL` → sound +
vibrate. (No custom DND override — we defer to ringer mode, which the OS already derives from DND.)

## Files to change

### Native (Android / Kotlin)

1. **`android/app/src/main/AndroidManifest.xml`**
   - Add `<uses-permission android:name="android.permission.VIBRATE"/>`.
   - (Keep `IN_CALL_SERVICE_RINGING="true"`; `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE`,
     `FOREGROUND_SERVICE_PHONE_CALL` are already declared.)

2. **New `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`**
   - Encapsulates: notification channel creation (`incoming_calls`, IMPORTANCE_HIGH), a full-screen
     -intent CALL-category notification that launches `MainActivity`, ringtone playback (MediaPlayer
     with `AudioAttributes` `USAGE_NOTIFICATION_RINGTONE`, looping; default via
     `RingtoneManager.getActualDefaultRingtoneUri`), custom-tone swap from a file/content path,
     vibration (repeating pattern; `VibratorManager` on API 31+, legacy `Vibrator` below), audio-focus
     request/abandon (`AudioFocusRequest` on API 26+, legacy below), and ringer-mode gating.
   - `start(context)` → default tone + vibrate + focus; `setCustomTone(path)` → swap; `stop()` →
     stop tone/vibrate, abandon focus.

3. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`**
   - On `onCallAdded`: if the call is (or becomes) `STATE_RINGING`, `startForeground(...)` with the
     full-screen-intent call notification and start `IncomingCallRinger`. Keep launching the in-call
     UI, but rely on the full-screen intent for the background/lock-screen case.
   - Stop the ringer + `stopForeground(...)`/cancel notification when the call leaves ringing
     (answered → active) or is removed. (Driven via a state-change hook from `CallRegistry`.)

4. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`**
   - Assign a monotonically increasing **`callId`** in `onCallAdded`; include `"callId"` in
     `snapshot()`.
   - Add a hook so the service is notified on ring-start / ring-stop transitions (e.g. expose the
     current phase or a small callback the service registers) so the ringer starts/stops in step with
     `STATE_RINGING` ↔ active/removed.
   - Add `setIncomingRingtone(path)` that forwards to the active `IncomingCallRinger`.

5. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - Add method-channel case `setIncomingRingtone` → `CallRegistry.setIncomingRingtone(path)`.
   - Make the call UI show over the lock screen: `setShowWhenLocked(true)` / `setTurnScreenOn(true)`
     (API 27+; legacy window flags below) while a call is active.

### Flutter (Dart)

6. **`lib/services/telecom_service.dart`**
   - Add `Future<void> setIncomingRingtone(String path)` → `_invokeVoid('setIncomingRingtone',
     {'path': path})`.

7. **`lib/models/call_state.dart`**
   - Add `final int callId;` parsed from the snapshot (`map['callId']`), default `0`.

8. **`lib/services/call_event_logger.dart`**
   - Dedupe by `callId`: track the id of the call currently being accumulated; when a new id arrives,
     reset accumulation; log at most **once per id**. This makes logging robust to flapping and to a
     future second call.

9. **`lib/screens/in_call_screen.dart`**
   - When the phase is ringing and the resolved contact has a `ringtonePath`, call
     `telecom.setIncomingRingtone(path)` (piggy-backing on the existing `_resolveName` contact load,
     which already fetches the full contact). Best-effort; failures leave the default tone playing.

### Docs

10. **`docs/known-gaps.md`** — update the per-contact-ringtone "Partially integrated" note to reflect
    that the tone now plays on incoming calls.

## Explicitly NOT in scope

- Multi-call / call-waiting UI (single active call remains the model).
- Reprogramming the OS ringer for non-dialer scenarios.
- Changing outgoing-call logging (already handled by `CallService` / `CallLifecycleMixin`).

## Verification plan

- `flutter analyze` clean; `flutter test` (all existing tests pass; `call_state.dart` gains a field
  with a default so `fromMap` stays backward-compatible).
- Manual on a device where ContactSphere is the default dialer:
  - Incoming call → default ringtone plays immediately, phone vibrates, full-screen UI appears (incl.
    from locked/backgrounded).
  - Contact with a custom tone → tone swaps to the custom one shortly after ring start.
  - Ringer set to silent → no sound; vibrate → vibrate only.
  - Call is NOT auto-disconnected; can be answered and rejected.
  - Exactly **one** Recents entry per incoming call (answered → `incoming`, unanswered → `missed`).

## Rollback

All changes are additive/localized; reverting the listed files restores current behavior.
