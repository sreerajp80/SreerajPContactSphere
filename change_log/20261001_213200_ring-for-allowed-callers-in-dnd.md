# Ring for allowed callers while Do Not Disturb / Driving mode is on

Implements plan: `plans/20261001_212350_ring-for-allowed-callers-in-dnd.md`

## Problem

While driving with Android Auto, Google's "Driving" mode turns on Do Not Disturb
"Priority only". Calls that Do Not Disturb allowed showed on the car display, but no
ringtone played in the car or on the phone.

During "Priority only", Android reports the ringer mode to apps as **silent**, while the
phone's real ringer mode stays **normal**. The app reads `AudioManager.getRingerMode()`
and so stayed silent for every call, even allowed callers. Telecom had already handed
ringing to the app (`SKIP_RINGING (Dialer handles)`), so nothing rang at all.

## What changed

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/RingerPolicy.kt`
  - `decide()` takes two new optional inputs: `callerAllowedByDnd` and
    `internalRingerMode`.
  - During DND "Priority only", when the caller is allowed **and** the real ringer mode
    is known, the real mode is used. So the phone rings (or only vibrates, or stays
    silent, if the user really set that).
  - In every other case the old rule applies. A caller that DND blocks, or an unknown
    check, keeps the app-facing (silent) mode. "Total silence" and "Alarms only" never
    ring.
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`
  - New `callerAllowedByDnd(number)`: uses `NotificationManager.matchesCallFilter(Uri)`
    on Android 13+ (needs READ_CONTACTS, which the app holds). Returns null on older
    Android, with no number, or on error.
  - New `internalRingerMode()`: reads `Settings.Global.MODE_RINGER`. Returns null on
    error.
  - Both are read only during "Priority only" and passed to `RingerPolicy`.
- `android/app/src/test/kotlin/in/sreerajp/contact_sphere/RingerPolicyTest.kt`
  - 8 new tests: allowed caller rings / vibrates / stays silent per the real mode,
    blocked caller stays silent, unknown check or mode keeps the old behaviour, the real
    mode is ignored outside Priority, and an allowed caller can't break "Total silence".
  - Renamed the old "priority-only still rings, by design" test to describe what it now
    checks.

Which tone plays is not changed: contact ringtone, then SIM ringtone, then the phone's
default.

`docs/architecture.md` has no ringer section, so it was not changed.

## Checks

- `./gradlew :app:testDevDebugUnitTest`: passed (RingerPolicyTest: 24 tests, 0 failures).
- `flutter analyze`: no issues.
- `flutter test` not run: no Dart code changed.
- On-device test still to do: turn Driving mode on by hand, call from another phone,
  and confirm the contact's ringtone plays. Then test once in the car with Android Auto.
