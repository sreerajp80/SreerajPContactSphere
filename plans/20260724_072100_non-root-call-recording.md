# Implement Non-Root In-Call Audio Recording (Default Dialer Approach)

**Status:** approval_pending

Implement non-root call recording for **SreerajPContactSphere** by leveraging its existing **Default Phone App (`InCallService`)** system role, using Android's native `MediaRecorder` / `AudioRecord` with `AudioSource.VOICE_COMMUNICATION` stream and integrating controls into the Flutter in-call UI.

## User Review Required

> [!IMPORTANT]
> **Hardware/OEM Audio Isolation Constraints (Non-Root)**
> Android 9+ (API 28+) blocks `MediaRecorder.AudioSource.VOICE_CALL` for third-party non-system apps. 
> By running as the system **Default Dialer**, using `AudioSource.VOICE_COMMUNICATION` captures both mic and incoming audio on supported devices without turning on the loudspeaker. However, on certain modern OS implementations (e.g. Android 13/14 on specific Samsung or Pixel models), aggressive hardware echo cancellation may reduce caller audio amplitude. Toggling loudspeaker or boosting software gain serves as the non-root fallback on impacted hardware.

> [!NOTE]
> **Storage & Privacy Notice**
> Recorded audio files will be saved in the app's secure private documents storage directory (`app_flutter/call_recordings/`) and automatically referenced in local interaction history.

## Open Questions

> [!IMPORTANT]
> **Automatic vs. Manual Recording Behavior**
> Would you prefer calls to be recorded **automatically** as soon as an incoming/outgoing call connects (`CallState.active`), or should recording be strictly **manual** when the user taps a "Record" button on the in-call screen?

> [!NOTE]
> **Audio Format Preference**
> Do you prefer recording in standard compressed **AAC/MPEG-4 (`.m4a` / `.mp4`)** for lower file size and high compatibility, or high-fidelity **WAV (`.wav`)** format?

---

## Proposed Changes

### Android Native Layer (Kotlin & Telecom Integration)

#### [NEW] [CallRecorderManager.kt](file:///l:/Android/SreerajPContactSphere/android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRecorderManager.kt)
- Create a dedicated Kotlin manager for audio recording during active telephony calls.
- Initialize `MediaRecorder` (or fallback `AudioRecord`) configured with `AudioSource.VOICE_COMMUNICATION`, `OutputFormat.MPEG_4`, and `AudioEncoder.AAC`.
- Provide methods: `startRecording(filePath: String): Boolean`, `stopRecording(): String?`, and `isRecording(): Boolean`.
- Handle edge cases such as mid-call audio interruption, low storage space, and graceful error teardown.

#### [MODIFY] [MainActivity.kt](file:///l:/Android/SreerajPContactSphere/android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt)
- Register a new `MethodChannel` (`in.sreerajp.contact_sphere/call_recorder`) in `configureFlutterEngine`.
- Wire `startRecording`, `stopRecording`, and `getRecordingStatus` calls from Dart to `CallRecorderManager`.

---

### Flutter Service & State Management

#### [NEW] [call_recorder_service.dart](file:///l:/Android/SreerajPContactSphere/lib/services/call_recorder_service.dart)
- Create Dart service communicating with the native `in.sreerajp.contact_sphere/call_recorder` channel.
- Manage file path generation (`call_YYYYMMDD_HHMMSS_number.mp4`).
- Provide stream/ValueNotifier for active recording state and elapsed recording time.

#### [MODIFY] [telecom_service.dart](file:///l:/Android/SreerajPContactSphere/lib/services/telecom_service.dart)
- Integrate auto-stop hook on call teardown (`onCallEnded` / state changes to idle/disconnected).
- Expose helper methods to bind active call session state to recording state.

---

### UI Layer (In-Call Screen & Call History)

#### [MODIFY] [in_call_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/in_call_screen.dart)
- Add a **Record Call** action button to the in-call action grid alongside Mute, Speaker, Hold, and Keypad.
- Add an animated recording badge (`🔴 00:15`) in the call status header when recording is active.
- Wire button taps to `CallRecorderService.toggleRecording()`.

#### [MODIFY] [call_history_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/call_history_screen.dart)
- Add audio playback indicator / preview button for call log items that have an associated call recording file.

---

## Verification Plan

### Automated Tests
- `flutter test`: Run unit tests for `CallRecorderService` and call log repository bindings.

### Manual Verification
- Deploy APK to a non-rooted Android device (Android 10+).
- Set **SreerajPContactSphere** as the **Default Phone App**.
- Place/receive an active phone call without turning on loudspeaker.
- Tap **Record** on the in-call screen and confirm live recording timer starts.
- Hang up and verify audio file is saved in app documents directory.
- Play back the `.m4a` file to verify both local user mic and incoming caller audio clarity.
