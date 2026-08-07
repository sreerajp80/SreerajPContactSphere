# Fix intermittent silent ring: late-push restart races + swallowed player errors

**Status:** completed

## Issue

User report: incoming calls sometimes ring with no audible ringtone (ringtone previews are
always audible).

Live logcat capture of two test calls (2026-07-03 ~20:16, device ZD222DXJ65, dev flavor)
plus a dump of the native ringer prefs shows:

- The mirror (`native-ringtone-mirror`, 20260703_181217) works: `IncomingCallRinger.start()`
  resolved the SIM tone and played it on the RING stream at full volume — both test calls
  were audible.
- **But on the first call the ringer was torn down and rebuilt twice within ~1 s** (three
  `NuPlayerDriver` instances at 20:16:40.334, .753 and 41.129; the first was stopped at
  .564 *while still preparing*, before its own track had even started).

The restarts come from [lib/screens/in_call_screen.dart](../lib/screens/in_call_screen.dart):
even though the mirror already starts the correct tone natively, the screen still fires two
independent late pushes per ringing call — `_applySimRingtone()` (per-SIM tone) and the
contact-tone push inside `_resolveName()`. They race each other (the `_contactToneApplied`
flag is checked before the slower contact lookup completes, so a SIM push can land *after*
and override a contact push) and race the mirror (a push whose URI string differs from what
`start()` resolved restarts playback even when it is the same effective tier of tone).

Each restart calls `IncomingCallRinger.playUri()`, which `stop()`s + `release()`s the
current MediaPlayer — possibly mid-`prepareAsync()` — and builds a new one. Two silent
failure modes live in that window:

1. `setOnErrorListener { _, _, _ -> true }` swallows **async** errors (anything thrown
   after `setDataSource`, i.e. during/after `prepareAsync`) with **no fallback to the
   default tone** → the ring dies silently. (The sync-failure path does fall back; the
   async path does not.)
2. `setOnPreparedListener { it.start() }` can fire against a player that has just been
   released by a competing push → `IllegalStateException` inside the listener.

This explains the intermittency: when the race resolves cleanly the call rings (as in the
two captured calls); when a stop lands in the prepare window the ring dies with no sound
and no fallback — and with `vibrate_on_incoming_call=false` there is no cue at all.

## Fix

Make the late push a *tiered, idempotent correction* instead of a blind restart, and make
the native player unable to fail silently.

### 1. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`

- Track the **tier** of the tone currently playing: `TIER_DEFAULT (0) < TIER_SIM (1) <
  TIER_CONTACT (2)`. `start()` records the tier from which map the mirror hit resolved
  (contact map → CONTACT, SIM map → SIM, fallback → DEFAULT).
- Change `setCustomTone(path)` → `setCustomTone(path, tier)`. Apply the push only when:
  - `tier > playingTier` (an upgrade, e.g. contact tone when the mirror missed it), or
  - `tier == playingTier && uri != playingUri` (same tier but the mirror was stale).
  Everything else no-ops. A SIM push can therefore never override a contact tone no matter
  how the Flutter-side resolutions race, and a push matching what already plays never
  restarts the ring.
- Harden `playUri()`:
  - `setOnErrorListener`: if the failing URI is not the default tone, fall back to
    `playUri(defaultRingtoneUri())`; if the default itself fails, give up (no retry loop).
  - Wrap the `setOnPreparedListener` body in a guard: only `start()` if this MediaPlayer
    is still the current `player` (and try/catch the `start()` so a release race cannot
    throw inside the system callback).

### 2. `android/.../CallRegistry.kt`

- `setIncomingRingtone(path)` → `setIncomingRingtone(path, source)` and
  `RingController.setCustomRingtone(path)` → `setCustomRingtone(path, source)` where
  `source` is `"contact"` or `"sim"` (anything else → SIM tier, the weaker one).

### 3. `android/.../ContactSphereInCallService.kt`

- Forward the new `source` argument from `setCustomRingtone` into
  `ringer?.setCustomTone(path, tier)`.

### 4. `android/.../MainActivity.kt`

- `"setIncomingRingtone"` method-channel handler: read the new `source` argument and pass
  it through.

### 5. `lib/services/telecom_service.dart`

- `setIncomingRingtone(String path)` → `setIncomingRingtone(String path, {required String
  source})`, sending `source` over the channel.

### 6. `lib/screens/in_call_screen.dart`

- `_applySimRingtone` passes `source: 'sim'`; the contact push in `_resolveName` passes
  `source: 'contact'`. The existing `_contactToneApplied` / `_simToneApplied` flags stay
  (they now only reduce redundant channel calls; correctness is enforced natively by the
  tier rule).

## Not changing

- The mirror itself (verified working on-device).
- Vibration settings (`vibrate_on_incoming_call=false` is the user's own choice; noted
  only because it removes the last cue when a ring dies silently).
- The notification / heads-up logic from `no-heads-up-over-incall-ui` (verified unrelated:
  channels are all silent by design; the app plays its own tone).

## Verification

- `flutter analyze` — clean.
- `gradlew :app:compileDevDebugKotlin` — Kotlin compiles.
- `flutter test` — existing suite (the known pre-existing `widget_test.dart` failure is
  unrelated).
- On-device (full reinstall — Kotlin changed): incoming call with a SIM tone set rings the
  SIM tone from the first note with **no stutter/restart** (logcat should show exactly one
  `NuPlayerDriver` instance per ringing call); a caller with a contact tone rings their
  tone; repeated test calls stay audible every time.
