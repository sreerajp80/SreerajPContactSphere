# Ringer policy, bottom-nav inset, and first native tests

**Status:** completed

Implemented on 2026-08-29 — see
[change_log/20260829_212038_ringer-policy-navbar-inset-and-native-tests.md](../change_log/20260829_212038_ringer-policy-navbar-inset-and-native-tests.md).
All six issues done. The on-device manual checks in Verification step 5 still need a phone.

Covers everything found in the 2026-08-29 critical review: the incoming-call ringer
ignoring the phone's own sound rules, the bottom navigation bar sometimes hiding under
the phone's navigation bar, the complete absence of Kotlin tests, and one feature the
app claims but does not have.

---

## Summary of the issues

| #   | Issue                                                                                               | Severity                                 |
| --- | --------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| 1   | App vibrates on an incoming call even when the phone's "Vibrate for calls" is off                   | High — wrong behaviour the user can feel |
| 2   | App rings at full volume through Do Not Disturb                                                     | High — wrong behaviour                   |
| 3   | Vibration is fired with no usage attributes, so the phone's ring-vibration intensity does not apply | Medium                                   |
| 4   | Bottom navigation bar can sit under the phone's navigation bar                                      | Medium — reported by the user            |
| 5   | No Kotlin tests at all; the whole call layer is untested                                            | Medium — structural                      |
| 6   | Features screen claims per-SIM "vibration patterns" that do not exist                               | Low — wrong copy                         |

Baseline before any change: `flutter analyze` clean, `flutter test` 452 passed / 1 skipped
/ 0 failed. Both must still hold at the end.

---

## Files to be changed

**New files**

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/RingerPolicy.kt`
- `android/app/src/test/kotlin/in/sreerajp/contact_sphere/RingerPolicyTest.kt`
- `android/app/src/test/kotlin/in/sreerajp/contact_sphere/MatchKeyTest.kt`
- `android/app/src/test/kotlin/in/sreerajp/contact_sphere/QuietHoursTest.kt`

**Changed files**

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`
- `android/app/build.gradle.kts`
- `lib/screens/home_shell.dart`
- `lib/screens/ringtone_volume_vibration_screen.dart`
- `lib/screens/features_screen.dart`
- `docs/known-gaps.md`
- `docs/features.md` (only if the wording there needs to follow the screen copy)

---

## Issue 1 — the app vibrates when the phone says not to

### What is wrong

Because the manifest declares `IN_CALL_SERVICE_RINGING`, Android does **not** ring for
this app. The app rings and vibrates itself, so it is also responsible for obeying every
system sound rule. It obeys some and ignores others.

`IncomingCallRinger.startVibration()` only checks the app's own switch:

```kotlin
private fun startVibration() {
    if (!vibrateEnabled) return          // app's own toggle, defaults to true
    ...
}
```

Nothing anywhere in the Kotlin sources reads `Settings.System.VIBRATE_WHEN_RINGING`
(verified by grep across every `.kt` file). So with the phone in normal ring mode and the
system setting "Vibrate for calls" turned **off**, this app still vibrates.

### The fix

Read the system setting and treat it as a veto **only in normal ring mode**. In
`RINGER_MODE_VIBRATE` the phone must still buzz — that is the whole point of that mode —
so the system setting is not consulted there.

Reading `Settings.System` needs no permission. If the key is missing or the read throws,
default to `true` (vibrate), so an unusual phone never goes silently un-buzzing.

---

## Issue 2 — the app rings through Do Not Disturb

### What is wrong

`start()` branches only on `audioManager.ringerMode`. Nothing reads
`NotificationManager.currentInterruptionFilter`. `RINGER_MODE_SILENT` catches full
silence, but Do Not Disturb in **"Alarms only"** and **"Priority only"** leaves the ringer
mode at `NORMAL` on most phones. The result is that the app rings at full volume for every
caller while Do Not Disturb is on.

### The fix

Suppress both sound and vibration when the interruption filter is
`INTERRUPTION_FILTER_NONE` (total silence) or `INTERRUPTION_FILTER_ALARMS` (alarms only).
Neither read needs a permission.

`INTERRUPTION_FILTER_PRIORITY` is deliberately **left ringing** — see Non-goals.

Suppressing the ring does not stop the call arriving: the incoming-call notification and
the full-screen in-call UI are posted separately in `ContactSphereInCallService`, so the
call can still be seen, answered and declined exactly as now.

---

## Issue 3 — vibration has no usage attributes

### What is wrong

```kotlin
v.vibrate(VibrationEffect.createWaveform(pattern, 0))
```

With no attributes attached, Android 10+ treats this as `USAGE_UNKNOWN`. Many phones then
scale it by the *touch feedback* intensity slider instead of the *ring vibration* slider,
and the system cannot apply its ringtone haptic policy to it. This is the second half of
"the app does not adhere to phone vibration settings".

### The fix

Attach the ringtone usage on every API level the app supports (`minSdk` is 24):

- API 33+ — `vibrate(effect, VibrationAttributes)` with `USAGE_RINGTONE`.
- API 26–32 — `vibrate(effect, AudioAttributes)` with `USAGE_NOTIFICATION_RINGTONE`.
- API 24–25 — the legacy `vibrate(pattern, repeat, AudioAttributes)` overload.

The pattern itself (`[0, 1000, 1000]`) is unchanged.

---

## Shared design for issues 1–3: a pure `RingerPolicy`

Rather than scattering three new `if`s through `IncomingCallRinger`, put the whole
decision in one pure Kotlin object with no Android dependencies, so it can be unit tested
(see Issue 5):

```kotlin
object RingerPolicy {
    data class Decision(val playSound: Boolean, val vibrate: Boolean)

    fun decide(
        ringerMode: Int,              // AudioManager.RINGER_MODE_*
        interruptionFilter: Int,      // NotificationManager.INTERRUPTION_FILTER_*
        vibrateWhenRinging: Boolean,  // Settings.System.VIBRATE_WHEN_RINGING
        appVibrateEnabled: Boolean,   // the app's own toggle
    ): Decision
}
```

Rules, in order:

1. Filter is `NONE` or `ALARMS` → `Decision(false, false)`.
2. Ringer mode is `SILENT` → `Decision(false, false)`.
3. Ringer mode is `VIBRATE` → `Decision(false, appVibrateEnabled)`.
   The system "Vibrate for calls" setting is **not** consulted here.
4. Otherwise (normal) → `Decision(true, appVibrateEnabled && vibrateWhenRinging)`.

`IncomingCallRinger.start()` then reads the three inputs, calls `decide` once, and acts on
the result. The existing call-waiting beep path (`startCallWaiting`) is untouched — it is
an in-ear supervisory tone that is intentionally not gated by ringer mode.

`setCustomTone()`'s current early-return (`ringerMode != RINGER_MODE_NORMAL`) is replaced
by a check against the decision recorded at `start()`, so a late tone push cannot start
sound that the policy already suppressed.

---

## Issue 4 — bottom navigation bar hidden under the phone navigation bar

### What is wrong

Being honest about the state of the evidence: **the code reads as correct.**
`lib/screens/home_shell.dart` already wraps the bar in `SafeArea(top: false, …)`, the
manifest sets `adjustResize`, nothing calls `SystemChrome` or sets `FLAG_LAYOUT_NO_LIMITS`
/ immersive mode, and the in-app text scale caps at 1.30× so the bar cannot grow enough to
overflow. The cause could not be reproduced from source, and no device was attached during
the review (`adb devices` was empty).

What can be said:

- The bar has a history of being tuned right up against the gesture pill. See
  `change_log/20260703_100728_compact-bottom-nav-inset.md`, which deliberately clamped the
  bottom inset to at most 8px to reclaim space. That clamp is gone from the current file,
  but it shows how little margin this bar has been given.
- The current `SafeArea` has **no `minimum:` floor** and **no `maintainBottomViewPadding`**.
  It trusts `MediaQuery.padding.bottom` completely, with nothing to catch a moment where
  Android reports that inset as zero.
- This class of bug has already been patched by hand twice elsewhere:
  `contact_detail_screen.dart:473` and `duplicates_screen.dart:733` both add
  `MediaQuery.of(context).padding.bottom` manually.

### The fix

Cheap insurance with no visual cost in the normal case:

```dart
child: SafeArea(
  top: false,
  maintainBottomViewPadding: true,
  minimum: const EdgeInsets.only(bottom: 8),
  child: ...
),
```

`maintainBottomViewPadding: true` keeps the inset reserved when the keyboard changes
`MediaQuery.padding.bottom` to zero. `minimum` guarantees the labels never sit flush on
the screen edge even if the inset is reported as zero.

This is hardening, not a proven fix. It cannot make the bar worse, but it may not be the
whole answer. To confirm the real cause the following is still needed from the phone where
it happens, and can be gathered after this plan lands:

- Which navigation mode is in use (gesture vs 3-button).
- Whether it happens right after typing in contact search, or after returning from a call.
- A screenshot showing the overlap.

If those point at something else, that gets its own follow-up plan.

---

## Issue 5 — no Kotlin tests

### What is wrong

`android/app/src/` contains only `debug`, `main` and `profile` — there is no `test` or
`androidTest` source set, and `build.gradle.kts` declares no test dependency. Meanwhile the
Dart side has 57 test files and 452 passing tests.

Everything that decides whether the phone rings, vibrates, or shows a missed call lives in
Kotlin: `IncomingCallRinger.kt`, `ContactSphereInCallService.kt`, and `MainActivity.kt`
(~1700 lines). The riskiest layer in the app has zero automated coverage.

### The fix

Add a JVM unit-test source set and cover the pure logic that already exists, plus the new
policy:

- `android/app/build.gradle.kts` — add `testImplementation("junit:junit:4.13.2")`.
- `RingerPolicyTest.kt` — every branch of `RingerPolicy.decide`, including the two that
  are the actual bug fixes: normal mode with `vibrateWhenRinging = false` must not vibrate,
  and `INTERRUPTION_FILTER_ALARMS` must neither ring nor vibrate.
- `MatchKeyTest.kt` — `IncomingCallRinger.matchKey`: the trailing-10-digit rule, a
  `+91` prefix being absorbed, a short number being kept whole, and null/blank input.
- `QuietHoursTest.kt` — `CallerAnnouncer.isInQuietHours` (including a window that wraps
  past midnight, e.g. 22:00→07:00) and `isMalayalamScript`.

These are chosen because they are pure functions needing no Android framework, so plain
JUnit is enough — no Robolectric, no new heavy tooling.

Run with (the app has `dev`/`prod` flavors, so the task name is flavored):

```
cd android && ./gradlew :app:testDevDebugUnitTest
```

---

## Issue 6 — a feature the app claims but does not have

`lib/screens/features_screen.dart` (the "Per-SIM & Group Ringtones" card) tells the user:

- description: "Assign distinctive ringtones **and vibration patterns** to SIM 1 vs SIM 2…"
- highlight chip: "**Custom vibration styles**"

Per-SIM ringtones and group ringtones are real (`PerSimRingtoneScreen`,
`group_ringtone_test.dart`). Per-SIM or per-group **vibration patterns are not** — grep
finds no `vibrationPattern` / `vibrationStyle` anywhere, and the ringer uses one hardcoded
pattern `[0, 1000, 1000]` with a single global on/off switch.

### The fix

Correct the copy to match reality: drop "and vibration patterns" from the description and
replace the "Custom vibration styles" chip with something true, e.g. "Per-contact
ringtones" (which does exist). Check `docs/features.md` lines 204 and 439 and align them if
needed — as read today they are already accurate.

Building an actual per-SIM / per-group vibration-pattern feature is **not** part of this
plan; see Non-goals.

---

## Also updated

- `lib/screens/ringtone_volume_vibration_screen.dart` — the vibration switch subtitle
  currently reads "Silent mode still overrides this and suppresses vibration". After this
  change it must also say that the phone's own "Vibrate for calls" setting and Do Not
  Disturb override it.
- `docs/known-gaps.md` — record that the native call layer now has its first unit tests,
  and that Do Not Disturb "Priority only" is deliberately not honoured yet.

---

## Non-goals (deliberately out of scope)

- **Do Not Disturb "Priority only"**. Honouring it properly means reading
  `NotificationManager.getNotificationPolicy()` to see whether calls and repeat callers are
  allowed, which throws without the user granting `ACCESS_NOTIFICATION_POLICY`. That means
  a new permission and a new user-facing prompt. The safe behaviour for a dialer is to fail
  open — ring rather than silently miss a call — so "Priority only" keeps ringing for now.
  Worth its own plan later.
- **Building per-SIM / per-group vibration patterns.** Issue 6 fixes the wrong copy only.
  If the real feature is wanted, it is a separate plan (settings model, mirror push to
  native, per-tier pattern resolution, UI).
- **Ramping ringer** (`Settings.System.APPLY_RAMPING_RINGER`).
- **Making the app's ringtone volume independent of the phone's ring volume.** Reviewed and
  found to be working as designed: `mp.setVolume(volume, volume)` is a gain applied inside
  the ring stream, so effective loudness is `phone ring volume × app percentage`. The app
  slider can only make the ring quieter than the phone setting, never louder. That is the
  correct model for a ringtone and is not being changed.
- **Ringtone channel count (stereo vs mono).** Also reviewed, no change needed: there are
  no bundled tone assets, every tone is a system ringtone or a user-picked file played
  through `MediaPlayer`, which preserves the source's channel count, and
  `setVolume(volume, volume)` applies equal left/right gain so a stereo file stays stereo.
  Most phones downmix the ring stream to the single loudspeaker regardless; over Bluetooth
  or wired headphones a stereo tone plays in stereo.
- **Refactoring `MainActivity.kt`** (~1700 lines). Noted as a concern, not touched here.

---

## Verification

1. `flutter analyze` — must stay clean.
2. `flutter test` — must stay at 452 passed / 1 skipped / 0 failed.
3. `cd android && ./gradlew :app:testDevDebugUnitTest` — new Kotlin tests pass.
4. `flutter build apk --flavor dev` — the new test source set must not break the build.
5. On-device manual checks (needs a connected phone; none was attached during the review):
   - Phone in normal ring mode, system "Vibrate for calls" **off**, app toggle **on** →
     rings, does **not** vibrate. (This is the bug being fixed.)
   - Same, system setting **on** → rings and vibrates.
   - Phone in vibrate mode → vibrates regardless of the system "Vibrate for calls" setting.
   - Do Not Disturb "Alarms only" → silent, no vibration, call still visible and answerable.
   - Do Not Disturb "Priority only" → still rings (documented non-goal).
   - Power button / flip-to-silence during a ring → still stops tone and vibration
     (`onSilenceRinger` path must not regress).
   - Per-contact and per-SIM tones still play from the first note.
   - Bottom nav bar in both gesture and 3-button navigation, and while the contact search
     keyboard opens and closes.

## Risks

- The ringer is the highest-consequence code in the app: a mistake means a missed call.
  Every new rule fails **open** (ring) when an input cannot be read.
- `Settings.System.VIBRATE_WHEN_RINGING` is deprecated and some OEMs do not populate it.
  Defaulting a missing/failed read to `true` keeps today's behaviour on those phones.
- Adding a `test` source set changes the Gradle configuration for the first time; step 4 of
  Verification exists to catch a broken release build early.
