# Change log — Fix incoming calls: no ringtone, quick disconnect, double Recents entry

Implements [plans/20260702_105905_incoming-call-ringing-fix.md](../plans/20260702_105905_incoming-call-ringing-fix.md)
(chosen direction: **app owns ringing, full implementation**, to preserve per-contact ringtones).

## Problem

On an incoming call: (1) no ringtone played, (2) the call was disconnected quickly, and (3) two rows
appeared in Recents for one call. Root cause: the manifest declares `IN_CALL_SERVICE_RINGING="true"`
(the app owns the ringing experience), but the native code fulfilled none of the duties that entails —
no ringtone/vibration, no full-screen-intent notification, no foreground service — so the platform
stayed silent, Telecom tore the un-handled ringing call down, and `CallEventLogger` (which lacked a
per-call dedupe) logged the flapping call more than once.

## What changed

### Native (Android / Kotlin)

- **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`** (new)
  - Plays the incoming ringtone via `MediaPlayer` (`USAGE_NOTIFICATION_RINGTONE`, looping) and drives
    vibration, gated by ringer mode (silent → nothing, vibrate → vibrate only, normal → sound +
    vibrate). `start()` plays the system default tone; `setCustomTone(path)` swaps in a contact tone
    (file path or content URI); `stop()` releases everything. Requests/abandons transient audio focus
    (`AudioFocusRequest` on API 26+, legacy below) and uses `VibratorManager` on API 31+ (legacy
    `Vibrator` below). All best-effort — a tone failure never crashes call handling.

- **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`**
  - Now implements `CallRegistry.RingController`. On ring start it promotes the service to a
    `phoneCall` foreground service with a full-screen-intent call notification (channel
    `incoming_calls`, silent channel since we ring ourselves) so the UI shows from background / over
    the lock screen, and starts `IncomingCallRinger`. On ring stop / removal / destroy it stops the
    ringer and drops the foreground state. Uses platform `Notification.Builder` (no `androidx`
    dependency). Registers/clears itself as the ring controller around the call.

- **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`**
  - Added the `RingController` interface plus `setRingController` / `clearRingController` and
    `startRingingIfNeeded` / `stopRingingIfNeeded` (fire exactly once), driven from `onCallAdded`, the
    state-change callback, and `onCallRemoved`.
  - Added `setIncomingRingtone(path)` that forwards a contact tone to the ringer.
  - Assigns a monotonic `callId` per `onCallAdded` and includes it in `snapshot()`.

- **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
  - New method-channel case `setIncomingRingtone` → `CallRegistry.setIncomingRingtone(path)`.
  - Shows the in-call UI over the lock screen while a call is present (`setShowWhenLocked` /
    `setTurnScreenOn` on API 27+, window flags below), cleared when no call — via a new
    `applyShowWhenLocked` helper called from `onCallChanged`.

- **`android/app/src/main/AndroidManifest.xml`**
  - Added `VIBRATE` and `USE_FULL_SCREEN_INTENT` permissions.

### Flutter (Dart)

- **`lib/services/telecom_service.dart`** — added `setIncomingRingtone(path)` (no-op off Android).
- **`lib/models/call_state.dart`** — added `callId` (parsed from the snapshot, default `0`).
- **`lib/services/call_event_logger.dart`** — dedupe by `callId`: accumulation resets when a new call
  id arrives, and a Recents row is written at most once per id (`_lastLoggedId` guard). Removed the
  old `_logged` flag.
- **`lib/screens/in_call_screen.dart`** — when the resolved caller has a `ringtonePath` and the call
  is still ringing, calls `setIncomingRingtone` to swap the native default tone for theirs.

### Docs

- **`docs/known-gaps.md`** — updated the per-contact-ringtone notes to reflect that the tone now
  plays on incoming calls (via the ringing InCallService), with the remaining limits.

## Verification

- `flutter analyze` — No issues found.
- `flutter test` — all 33 tests pass.
- `flutter build apk --debug --flavor dev` — builds successfully (native Kotlin compiles).
- **Not verified here (requires a physical device with ContactSphere as default dialer):** ringtone
  playback, per-contact tone swap, vibration/ringer-mode behavior, lock-screen full-screen UI,
  no premature disconnect, and exactly one Recents entry per call. These need on-device testing.

Note: a raw `gradlew :app:compileDevDebugKotlin` invocation fails during configuration of
`:audioplayers_android:testDebugUnitTest` ("Type T not present") — a pre-existing Gradle/plugin
toolchain incompatibility unrelated to this change; the standard `flutter build apk` path is
unaffected.
