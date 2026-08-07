# Native ringtone mirror — ring the correct tone from the first note

**Status:** completed

## Issue

On an incoming call from a contact with a custom ringtone, the default SIM ringtone
plays first and then audibly switches to the contact's tone after ~1–3 seconds.

Cause (by design today): the app owns ringing (`IN_CALL_SERVICE_RINGING`), and
`IncomingCallRinger.start()` plays the **system default** tone the instant a call
arrives so ringing works even on a cold start. The contact's tone is only known to
the Flutter side (SQLite `contacts.ringtone_path`), so it arrives late: activity
launch → Flutter engine start → DB query (`findByFullNumber`) → method-channel push
(`setIncomingRingtone`) → native `setCustomTone()` swaps players. The per-SIM tone
path (`AppSettings.readSimRingtone` → same channel) has the same lag.

## Fix approach

Extend the pattern already used for volume/vibrate: mirror the ringtone data into
the native `contact_sphere_ringer` SharedPreferences file so the ringer can resolve
the correct tone **synchronously** at ring time, before Flutter is even running.

Two mirrored maps, stored as JSON strings in the existing prefs file:

- `contact_ringtones`: `{ <last-7-digits-of-number>: <tone path/URI> }` — one entry
  per phone number of every contact that has a `ringtone_path`. Keyed by the same
  trailing-7-digit slice `findByFullNumber` uses as its SQL prefilter, so native
  and Flutter matching agree. On (rare) key collision, last writer wins; Flutter's
  existing exact-match push remains as the corrective safety net.
- `sim_ringtones`: `{ <phoneAccountId>: <tone path/URI> }` — mirror of the
  Flutter-side per-SIM map.

At ring time the native ringer resolves: **contact tone → SIM tone → system
default** (matching the existing Flutter precedence where the contact tone wins).

The existing Flutter push (`setIncomingRingtone`) is kept as a safety net for
stale-mirror cases, but `setCustomTone` becomes a no-op when the requested tone is
the one already playing, so the normal case no longer restarts the tone mid-ring.

## Files to change

### Android (native)

1. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`
   - `start()` takes the caller number + phoneAccountId:
     `start(number: String?, phoneAccountId: String?)`.
   - New private resolution: normalize `number` to digits, take the trailing 7
     (whole string when shorter), look up `contact_ringtones`; else look up
     `sim_ringtones[phoneAccountId]`; else default tone. Unplayable custom tone
     still falls back to the default (existing `playUri` false-return path).
   - Track the currently playing URI; `setCustomTone` no-ops when asked to play
     the same tone again (kills the restart when the Flutter safety-net push
     matches what the mirror already chose).
   - New pref keys `KEY_CONTACT_TONES` / `KEY_SIM_TONES` in the companion.

2. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`
   - `startRinging(call)` passes `call.details?.handle?.schemeSpecificPart` and
     `call.details?.accountHandle?.id` into `ringer.start(...)`.

3. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
   - New method-channel handler `setRingtoneMirror` accepting
     `contactTones: Map<String, String>` and `simTones: Map<String, String>`
     (null leaves that map untouched); persists each as a JSON string into
     `contact_sphere_ringer` prefs.

### Flutter

4. `lib/services/telecom_service.dart`
   - New `setRingtoneMirror({Map<String, String>? contactTones, Map<String, String>? simTones})`
     invoking the channel method. No-op off Android.

5. `lib/repositories/contact_repository.dart`
   - New query `ringtoneMirrorEntries()`: numbers of all contacts with a
     non-empty `ringtone_path`, returned as `{last-7-digits: path}` (digits via
     the existing `normalizeDigits`).
   - `insertContact` / `updateContact` / `deleteContact` trigger a fire-and-forget
     mirror rebuild + push after the write commits (small helper, debounced-by-
     nature since these are single user actions).

6. `lib/services/contact_sync_service.dart`
   - Trigger one mirror rebuild + push after a device-contacts sync completes
     (sync writes many contacts at once).

7. `lib/state/app_settings.dart`
   - `setSimRingtone(...)` additionally pushes the updated per-SIM map via
     `setRingtoneMirror` (same fire-and-forget style as `_mirrorRingerPrefs`).
   - `load()` pushes **both** maps once on startup so existing installs get a
     mirror without waiting for the next edit (contact map via the repository
     query).

## Out of scope / notes

- Group ringtones (`groups.ringtone_path`) are not part of the incoming-call flow
  today; the mirror ignores them (can be added later with the same pattern).
- The in-call screen's late pushes stay unchanged; they are now usually redundant
  no-ops.
- No DB schema change; no new dependencies (`org.json` is in the Android SDK).

## Test / verification

- `flutter analyze` clean (relative to the pre-existing known-gaps errors).
- Manual: set a custom tone on a contact → call from that number → correct tone
  from the first ring, no audible switch (test both app-warm and app-killed cold
  start). Contact without a tone but SIM tone set → SIM tone rings. Neither →
  default tone. Clear the contact's tone → default rings again (mirror updated).
