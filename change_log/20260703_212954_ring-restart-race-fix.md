# Fix intermittent silent ring — tiered late pushes + hardened native player

Implements [plans/20260703_212016_ring-restart-race-fix.md](../plans/20260703_212016_ring-restart-race-fix.md).

## Problem

Incoming calls sometimes rang silently (previews were always audible). Live logcat of two
test calls proved the mirror resolves and plays the right tone, but the in-call screen's
two redundant late pushes (per-SIM tone + contact tone) raced each other and the mirror,
tearing the MediaPlayer down and rebuilding it up to twice in the first second of ringing —
once *mid-prepare*. In that window an async MediaPlayer error was swallowed with no
fallback, killing the ring silently (and vibration is off in the user's settings, so no
cue at all).

## Changes

### Android

- **`IncomingCallRinger.kt`**
  - Tone **tiers**: `TIER_DEFAULT < TIER_SIM < TIER_CONTACT`; `start()` plays contact
    tone → SIM tone → default and records the tier that won (`playingTier`).
  - `setCustomTone(path)` → `setCustomTone(path, source)` (`"contact"` / anything-else =
    SIM tier). The push now no-ops when the URI already plays (just records a stronger
    tier), and when its tier is weaker than what's playing — so a matching push never
    restarts the ring and a racing SIM push can never override a contact tone. Equal tier
    with a different URI still applies (stale-mirror correction).
  - `playUri(uri)` → `playUri(uri, tier)`, hardened:
    - `setOnErrorListener` now falls back to the default tone on an async failure (was:
      swallowed → silence); gives up if the default itself fails (no retry loop).
    - `setOnPreparedListener` only starts the player if it is still the current one, and
      try/catches the `start()` — a competing push releasing it mid-prepare can no longer
      throw inside the system callback.
    - The half-built MediaPlayer is released on a sync setup failure (was leaked).
- **`CallRegistry.kt`** — `setIncomingRingtone(path, source)`;
  `RingController.setCustomRingtone(path, source)`.
- **`ContactSphereInCallService.kt`** — forwards `source` to the ringer.
- **`MainActivity.kt`** — `setIncomingRingtone` channel handler reads the new `source`
  argument.

### Flutter

- **`lib/services/telecom_service.dart`** — `setIncomingRingtone(path, {required source})`.
- **`lib/screens/in_call_screen.dart`** — `_applySimRingtone` pushes with
  `source: 'sim'`; the contact push in `_resolveName` with `source: 'contact'`. The
  existing `_contactToneApplied`/`_simToneApplied` flags stay (they now only trim
  redundant channel calls; correctness is enforced natively by the tier rule).

## Verification

- `flutter analyze` — No issues found.
- `gradlew :app:compileDevDebugKotlin` — compiles (only JDK native-access warnings).
- `flutter test` — 46 pass; 1 failure is the **pre-existing, unrelated**
  `widget_test.dart` "renders the home shell" (expects the Material `NavigationBar` the
  nav redesign replaced — same failure documented in earlier change logs).
- On-device (requires full reinstall — Kotlin changed): incoming calls should ring the
  correct tone from the first note with no stutter; logcat should show exactly one
  `NuPlayerDriver` instance per ringing call.
