# Plan: Default Phone (ROLE_DIALER) app with in-call UI + contact intent-filters

**Status:** completed

## Issue / goal

ContactSphere currently behaves as an ordinary app: it places calls through
`flutter_phone_direct_caller` (an `ACTION_CALL` to the *system* dialer) and reads/writes
the shared Contacts Provider via runtime permissions. It is **not eligible** to be
Android's default phone app, so the OS never offers "set as default", and there is no
in-app affordance to request it.

The user wants:
1. **Full `ROLE_DIALER`** — the app should appear in the system "Default phone app" list
   and, once chosen, own the calling experience with its **own in-call UI**
   (answer / reject / mute / speaker / hold / end + duration + caller identity).
2. **Contact intent-filters** — since Android has no formal "default contacts app" role,
   register `VIEW`/`EDIT`/`INSERT` intent-filters so ContactSphere shows up in the
   "Open with" chooser when viewing/editing a contact (the closest achievable equivalent).

### Why this is large
To be *offered* as the default phone app, an app MUST declare an `InCallService` plus the
dialer intent-filters. Once it becomes the default, **the system routes all calls to our
`InCallService`** — if our in-call UI is incomplete, calling is broken system-wide while
we're the default. So this is a genuine feature with native (Kotlin/Telecom) + Flutter
(platform channels + UI) parts, not a manifest tweak.

## Constraints & prerequisites

- **minSdk**: `InCallService` needs API 23; `ANSWER_PHONE_CALLS` needs API 26; `RoleManager`
  needs API 29. Plan pins `minSdk = 24` and guards API 26/29 features with
  `Build.VERSION` checks (fallback to `TelecomManager.ACTION_CHANGE_DEFAULT_DIALER` on 24–28).
- **Play Store policy**: default-dialer apps using `CALL_LOG`/phone permissions face
  Google Play Core-Functionality review. Out of scope for this plan (dev/sideload build),
  but noted.
- Existing outgoing-call reconciliation (`CallService` + `call_log`) stays; when we are the
  default dialer, outgoing calls will additionally surface through our own `InCallService`.

## Files to change / add

### Native (Android / Kotlin)
1. **`android/app/src/main/AndroidManifest.xml`** — add:
   - permissions `READ_PHONE_STATE`, `ANSWER_PHONE_CALLS`, `MANAGE_OWN_CALLS`
     (and keep existing `CALL_PHONE`, `READ_CALL_LOG`);
   - dialer intent-filters on `MainActivity`: `ACTION_DIAL` (with `tel:` and no data),
     `ACTION_VIEW` (`tel:`), `ACTION_CALL_BUTTON`;
   - the `InCallService` `<service>` declaration guarded by `BIND_INCALL_SERVICE` with
     `<meta-data android:name="android.telecom.IN_CALL_SERVICE_UI" android:value="true"/>`
     and the `android.telecom.InCallService` intent-filter;
   - contact intent-filters on `MainActivity`: `VIEW`/`EDIT` for
     `vnd.android.cursor.item/contact` (+ `raw_contact`) and `INSERT` for
     `vnd.android.cursor.dir/contact`;
   - `<queries>` / package-visibility entries needed to check the current default dialer.
2. **`.../kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`** (new) —
   `extends InCallService`; `onCallAdded`/`onCallRemoved` register/unregister
   `android.telecom.Call` objects in a shared `CallRegistry`, push state to Flutter, and
   bring `MainActivity` to front on the in-call route.
3. **`.../kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`** (new) — singleton holding the
   active `Call`(s) + `Call.Callback` state, and the `InCallService` reference (needed for
   `setMuted`/`setAudioRoute`). Bridges Telecom ⇄ platform channel.
4. **`.../kotlin/in/sreerajp/contact_sphere/MainActivity.kt`** — configure a
   `MethodChannel` (`contact_sphere/telecom`) for control calls
   (`requestDialerRole`, `isDefaultDialer`, `placeCall`, `answer`, `disconnect`, `hold`,
   `unhold`, `setMuted`, `setSpeaker`) and an `EventChannel`
   (`contact_sphere/call_events`) streaming call-state updates; handle the initial
   in-call intent extra to deep-link Flutter to the in-call screen.
5. **`android/app/build.gradle.kts`** — set `minSdk = 24` (override
   `flutter.minSdkVersion` if lower).

### Flutter
6. **`lib/services/telecom_service.dart`** (new) — Dart wrapper over the method/event
   channels: `Stream<CallState>`, `requestDefaultDialer()`, `isDefaultDialer()`, and
   in-call controls. Degrades to no-op on non-Android / when channels are absent (so tests
   and the widget smoke test keep working).
7. **`lib/models/call_state.dart`** (new) — immutable model mirroring the native payload
   (number, name, telecom state enum, mute/speaker/hold flags, connect timestamp).
8. **`lib/screens/in_call_screen.dart`** (new) — the in-call UI: caller identity (resolved
   via `ContactRepository.findByPhoneFragment`), live duration, and answer/reject/mute/
   speaker/hold/end controls wired to `TelecomService`.
9. **`lib/main.dart`** — listen to `TelecomService` call events and navigate to
   `InCallScreen` (via a `navigatorKey`) when a call becomes active; pop on disconnect.
10. **`lib/services/call_service.dart`** — when the app *is* the default dialer, route
    `placeCall` through `TelecomService.placeCall` (TelecomManager) instead of
    `flutter_phone_direct_caller`, so outgoing calls use our in-call UI; keep the existing
    path as fallback and keep all reconciliation logic.
11. **`lib/screens/settings_screen.dart`** — add a "Default phone app" card showing current
    status and a button that calls `TelecomService.requestDefaultDialer()`.
12. **`lib/constants/app_permissions.dart`** — add rows for the new
    `READ_PHONE_STATE` / `ANSWER_PHONE_CALLS` permissions and a "Default phone app" entry.
13. **`lib/screens/permissions_screen.dart`** — no structural change; picks up the new
    catalogue rows automatically (verify rendering).

### Docs
14. **`docs/architecture.md`** and **`docs/known-gaps.md`** — document the new Telecom layer,
    the platform channels, and the in-call route.

## Implementation phases (build order, each independently verifiable)
1. **Manifest + gradle + role request** — app appears in "Default phone app" list; settings
   button opens the role dialog. (No in-call UI yet; do NOT set as default until phase 3.)
2. **Native InCallService + channels** — call registry + state stream, controls stubbed,
   logs verified via `adb`.
3. **Flutter in-call screen + navigation** — end-to-end incoming & outgoing call UI.
4. **Outgoing via TelecomManager + contact intent-filters + docs/catalogue.**

## Testing
- `flutter analyze` and `flutter test` (existing suites — `call_feature_test.dart`,
  `contact_sync_service_test.dart`, etc. must still pass; `TelecomService` no-ops off-device).
- Manual on an emulator/device (API 24, 29, 34):
  - Settings → request default → confirm system dialog and that ContactSphere becomes default.
  - Place an outgoing call → our in-call screen shows, mute/speaker/hold/end work.
  - Receive an incoming call → answer/reject work, duration ticks.
  - Open a contact from another app → ContactSphere appears in the chooser.
  - Revert default phone app afterwards.

## Risks / rollback
- While ContactSphere is the default phone app with an incomplete in-call UI, calling is
  degraded — mitigated by phased build (don't set default until phase 3) and a documented
  "revert to <system dialer>" step.
- `minSdk` bump to 24 drops API 21–23 devices (Flutter's own floor is already ≥21 and
  trending to 24; low practical impact).
- Rollback = revert the manifest `<service>` + intent-filters and the gradle `minSdk`;
  the Flutter additions are inert without the native channels.
