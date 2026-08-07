# Change log: Default phone app (ROLE_DIALER) + in-call UI + contact intent-filters

Implements plan
[`plans/20260701_084634_default-dialer-and-contacts.md`](../plans/20260701_084634_default-dialer-and-contacts.md).

## Summary
ContactSphere can now be set as Android's **default phone app** (`ROLE_DIALER`) and shows
its own in-call UI, and registers **contact intent-filters** so it appears in the "Open
with" chooser for contacts. Built as the 4 phases in the plan.

## Native (Android / Kotlin)
- **`android/app/src/main/AndroidManifest.xml`**
  - Added permissions: `READ_PHONE_STATE`, `ANSWER_PHONE_CALLS`, `FOREGROUND_SERVICE`,
    `FOREGROUND_SERVICE_PHONE_CALL`.
  - Added dialer intent-filters on `MainActivity` (`DIAL` with/without `tel:`,
    `VIEW tel:`, `CALL_BUTTON`) and contact intent-filters (`VIEW`/`EDIT` for
    contact/person/raw_contact items, `INSERT` for the contact/person dirs).
  - Declared `ContactSphereInCallService` (`BIND_INCALL_SERVICE`,
    `foregroundServiceType="phoneCall"`, `IN_CALL_SERVICE_UI` + `IN_CALL_SERVICE_RINGING`).
  - Added a `DIAL` `<queries>` entry.
- **`ContactSphereInCallService.kt`** (new) — the `InCallService`; forwards call/audio state
  to `CallRegistry` and brings `MainActivity` to front.
- **`CallRegistry.kt`** (new) — `object` bridging Telecom ⇄ Flutter: holds the active `Call`
  + service, exposes answer/disconnect/hold/unhold/setMuted/setSpeaker, and emits plain-map
  snapshots to a listener.
- **`MainActivity.kt`** — added `MethodChannel` (`contact_sphere/telecom`) and `EventChannel`
  (`contact_sphere/call_events`); role request via `RoleManager` (API 29+) with a
  `TelecomManager.ACTION_CHANGE_DEFAULT_DIALER` fallback (API 24–28); `placeCall` via
  `TelecomManager`.
- **`android/app/build.gradle.kts`** — `minSdk = maxOf(24, flutter.minSdkVersion)`.

## Flutter
- **`lib/models/call_state.dart`** (new) — `CallPhase` enum + immutable `CallState` snapshot.
- **`lib/services/telecom_service.dart`** (new) — channel wrapper; **no-ops off Android** so
  tests/other platforms are unaffected. Exposes `callEvents` stream, role status/request, and
  in-call controls.
- **`lib/screens/in_call_screen.dart`** (new) — in-call UI: caller identity (resolved via
  `ContactRepository`), live duration, answer/reject/mute/speaker/hold/end.
- **`lib/main.dart`** — `SmartContactsApp` is now stateful with a `navigatorKey`; listens to
  `TelecomService.callEvents` and pushes/pops the in-call screen.
- **`lib/services/call_service.dart`** — `placeCall` routes through `TelecomService.placeCall`
  when default (falls back to `flutter_phone_direct_caller`); added injectable `TelecomService`.
- **`lib/screens/settings_screen.dart`** — new stateful "Default phone app" card showing live
  status and requesting the role.
- **`lib/constants/app_permissions.dart`** — reworded the Phone entry; added a "Default phone
  app" implicit row.

## Docs
- **`docs/architecture.md`** — new "Default phone app (Telecom / in-call UI)" section.
- **`docs/known-gaps.md`** — added a 2026-07-01 Resolved entry; updated the call-recording
  deferral note now that the default-dialer role is available.

## Verification
- `flutter analyze` — **No issues found**.
- `flutter test` — **all 27 tests pass** (the in-call/telecom layer no-ops under the test VM;
  the existing suites, including the widget smoke test, are green).

## Not covered (per plan scope / follow-ups)
- On-device manual verification (emulator/device across API 24/29/34) — not run in this
  environment; steps are in the plan's Testing section.
- Google Play Core-Functionality policy review for default-dialer apps — out of scope (dev
  build).
- Call recording and programming the OS ringer (per-contact/group ringtone) are now
  technically permissible as the default dialer but remain unimplemented (see known-gaps).
