# Change log — Ringer policy, bottom-nav inset, and first native tests

Implements [plans/20260829_210124_ringer-policy-navbar-inset-and-native-tests.md](../plans/202608292_210124_ringer-policy-navbar-inset-and-native-tests.md).

All six issues in the plan were implemented. Nothing was dropped.

---

## 1–3. The ringer now obeys the phone's sound rules

### New: `android/app/src/main/kotlin/in/sreerajp/contact_sphere/RingerPolicy.kt`

A pure object — no Android imports, no context, no I/O — that turns four inputs into one
`Decision(playSound, vibrate)`:

1. Do Not Disturb is "Total silence" or "Alarms only" → neither sound nor vibration.
   Checked **first**, because these filters leave the ringer mode at NORMAL, which is
   exactly why the old code rang straight through them.
2. Ringer mode silent → nothing.
3. Ringer mode vibrate → vibrate only, honouring the app toggle but **not** the system
   "Vibrate for calls" setting (the phone is in vibrate mode; it must buzz).
4. Otherwise → ring, and vibrate only if both the app toggle and the system setting agree.

Being Android-free is what makes the whole policy unit-testable on the plain JVM. The
platform constants it compares against are mirrored as local `const val`s (documented with
their platform names) so the file needs no `android.*` import; a test pins those values.

### Changed: `IncomingCallRinger.kt`

- `start()` no longer switches on `ringerMode` directly. It reads the three platform
  inputs, calls `RingerPolicy.decide` once, stores the result in a new `decision` field,
  and acts on it.
- Two new best-effort readers, each falling back to the **permissive** value so an
  unreadable setting rings rather than silently swallowing a call:
  - `currentInterruptionFilter()` → `NotificationManager.getCurrentInterruptionFilter()`,
    falling back to `FILTER_ALL`. Needs no permission.
  - `vibrateWhenRinging()` → `Settings.System.VIBRATE_WHEN_RINGING`, falling back to
    `true` (some OEMs never populate the key, and `true` is this app's long-standing
    behaviour). Needs no permission.
- `setCustomTone()` now gates on `decision.playSound` instead of re-reading
  `ringerMode != RINGER_MODE_NORMAL`. A late tone push can no longer start a tone that Do
  Not Disturb had already ruled out.
- `stop()` resets `decision` to fully suppressed, so a push arriving after a call ends
  cannot ring.
- `startVibration()` lost its own `if (!vibrateEnabled) return` (the policy owns that now)
  and gained ringtone usage attributes on every supported API level:
  - API 33+ — `VibrationAttributes.createForUsage(USAGE_RINGTONE)`
  - API 26–32 — the existing `ringtoneAttributes` (`USAGE_NOTIFICATION_RINGTONE`)
  - API 24–25 — the legacy `vibrate(pattern, repeat, AudioAttributes)` overload

  Without attributes Android treated the buzz as `USAGE_UNKNOWN`, so many devices scaled
  it by the touch-feedback intensity slider instead of the ring-vibration one. The pattern
  itself (`[0, 1000, 1000]`) is unchanged.
- `CallerAnnouncer.isInQuietHours` was split into the existing "now" version plus an
  overload taking the clock as minutes-since-midnight, so the window logic (especially the
  default 22:00→07:00 wrap past midnight) can be tested without depending on the time the
  test runs. Behaviour is unchanged.
- Class doc updated to describe the policy instead of the old ringer-mode gate.

**Not changed** (reviewed, working as designed): the call-waiting beep still bypasses the
ringer mode — it is an in-ear supervisory tone, like other dialers. `onSilenceRinger()`
(power button / flip-to-silence) was already correct and is untouched.

## 4. Bottom navigation bar inset

### Changed: `lib/screens/home_shell.dart`

The `bottomNavigationBar`'s `SafeArea` gained `maintainBottomViewPadding: true` and
`minimum: EdgeInsets.only(bottom: 8)`. The first keeps the system inset reserved while the
keyboard is up and `MediaQuery.padding.bottom` drops to zero; the second stops the labels
sitting flush on the screen edge if the inset is ever reported as zero.

**This is hardening, not a proven fix**, and it is recorded as such in the plan. The cause
could not be reproduced from source — the existing `SafeArea` reads as correct, the
manifest sets `adjustResize`, nothing calls `SystemChrome` or sets immersive/no-limits
window flags, and the in-app text scale caps at 1.30×. No device was attached during the
work (`adb devices` was empty). Confirming the real cause still needs, from the affected
phone: the navigation mode (gesture vs 3-button), whether it happens after typing in
contact search or after returning from a call, and a screenshot. If those point elsewhere,
that gets its own plan.

## 5. First Kotlin tests

### Changed: `android/app/build.gradle.kts`
Added `testImplementation("junit:junit:4.13.2")`.

### New: `android/app/src/test/kotlin/in/sreerajp/contact_sphere/`
- `RingerPolicyTest.kt` (16 tests) — every policy branch, including the two that are the
  actual bug fixes (normal mode with the system setting off must not vibrate; "Alarms
  only" must neither ring nor vibrate), the fail-open behaviour for unrecognised inputs,
  and the mirrored platform constants.
- `MatchKeyTest.kt` (10 tests) — the trailing-10-digit number key: country code and
  leading zero absorbed, separators stripped, every spelling of one number agreeing, short
  numbers kept whole, and the 10-vs-7 digit collision case that the key length exists to
  prevent.
- `QuietHoursTest.kt` (9 tests) — the announcement window, the midnight wrap, inclusive
  start / exclusive end, malformed input, and Malayalam script detection.

35 tests total, all passing. Pure functions only — no Robolectric, no instrumentation.

## 6. Corrected an overclaimed feature

### Changed: `lib/screens/features_screen.dart`
The "Per-SIM & Group Ringtones" card claimed the app assigns "vibration patterns" per SIM
and offered a "Custom vibration styles" highlight. Neither exists — there is one hardcoded
pattern and a single global on/off switch. The description now says ringtones only, and the
highlight became "Per-contact ringtones", which does ship.

`docs/features.md` lines 204 and 439 were checked and are already accurate; left alone.

## Also changed

### `lib/screens/ringtone_volume_vibration_screen.dart`
- Vibration switch subtitle now names all three overrides: "Your phone comes first: silent
  mode, Do Not Disturb and the phone's own 'Vibrate for calls' setting all override this."
- Volume subtitle now states the real model — "Plays incoming-call ringtones at N% **of
  your phone's ring volume**" — because the app slider is a gain applied inside the ring
  stream and can only attenuate, never exceed, the phone's setting. The muted-state text
  now also notes that the phone still vibrates if vibration is on.

  (This second edit goes slightly beyond the plan's text, which named only the vibration
  subtitle. It was the wording that prompted the original question about whether app volume
  is independent of phone volume, so it is corrected here rather than left misleading.)

### `docs/known-gaps.md`
- New "Resolved (2026-08-29 ringer policy + first native tests)" section.
- Two new entries under "Still not integrated (intentional, out of current scope)": Do Not
  Disturb "Priority only", and per-SIM / per-group vibration patterns.

---

## Verification

All four automated steps from the plan pass:

| Step                                                | Result                                                    |
| --------------------------------------------------- | --------------------------------------------------------- |
| `flutter analyze`                                   | No issues found                                           |
| `flutter test`                                      | 452 passed, 1 skipped, 0 failed (unchanged from baseline) |
| `cd android && ./gradlew :app:testDevDebugUnitTest` | 35 passed, 0 failed, 0 errors                             |
| `flutter build apk --flavor dev`                    | Built `app-dev-release.apk` (123.3MB)                     |

The new `test` source set did not disturb the release build.

## Still outstanding — on-device manual checks

These need a phone and were **not** done (no device attached):

- Normal ring mode, system "Vibrate for calls" **off**, app toggle **on** → must ring,
  must **not** vibrate. This is the headline fix.
- Same with the system setting **on** → rings and vibrates.
- Vibrate mode → buzzes regardless of the system "Vibrate for calls" setting.
- Do Not Disturb "Alarms only" → silent, no vibration, call still visible and answerable.
- Do Not Disturb "Priority only" → still rings (documented non-goal).
- Power button / flip-to-silence during a ring → still stops tone and vibration.
- Per-contact and per-SIM tones still play from the first note.
- Bottom nav bar in both gesture and 3-button navigation, and while the contact search
  keyboard opens and closes.

## Deliberately not done (non-goals from the plan)

Do Not Disturb "Priority only"; building real per-SIM/per-group vibration patterns;
ramping ringer; changing the ringtone volume model (correct as designed — effective
loudness is phone ring volume × app percentage); anything about stereo/mono (correct as
designed — tones are system or user-picked files played through `MediaPlayer`, which
preserves channel count, and equal L/R gain keeps a stereo file stereo); refactoring
`MainActivity.kt`.
