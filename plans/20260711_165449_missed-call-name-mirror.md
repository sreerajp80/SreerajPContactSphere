# Plan: Show the contact name on the missed-call notification (offline)

**Status:** completed

## Issue

The app-posted missed-call notification (from
`plans/20260711_163724_app-posted-missed-call-notification.md`) shows the raw
**number** as its title. When the app is fully closed the Flutter engine isn't
running, and native Kotlin **cannot read the app's (encrypted) SQLite DB**, so it
has no way to turn the number into the saved contact name.

## Approach — reuse the existing ringtone mirror (one mirror, not a new one)

The app already solves "native needs DB-derived data before Flutter is up" with a
**mirror**: Flutter writes small lookups into a native `SharedPreferences` file
that native reads synchronously. We extend that **same** mirror with a
`contactNames` map instead of adding a separate file/mechanism:

- **Same prefs file** — `IncomingCallRinger.RINGER_PREFS` (`contact_sphere_ringer`).
- **Same push** — `ContactRepository.pushRingtoneMirror()` (debounced; already
  called on startup, every contact write, group changes, and after a sync) carries
  the name map along with the tone map in one `setRingtoneMirror` call.
- **Same keying** — trailing **7 digits** (`MATCH_DIGITS = 7`), the same slice the
  tone mirror and the Dart exact-lookup already use, so the maps agree and native
  can reuse `matchKey`.

Why a **new map** rather than reusing `contactTones`: the tone map is deliberately
**sparse** (only contacts who have a custom/group ringtone). Names are needed for
**every** contact, so it's a separate map — but it lives in and reuses the same
mirror plumbing.

### Fix the key length: 7 → 10 digits (all mirrors)

7 trailing digits collide for real Indian mobiles — e.g. `9000123456` and
`9111123456` both key to `0123456`. The tone mirror self-heals in-call (a late
exact `findByFullNumber` correction), but the missed-call name has **no**
correction when the app is closed, so a collision would show the wrong name. India
uses a fixed 10-digit mobile plan, so keying on the **last 10 digits** is
effectively the full national number — collision-free — while still absorbing
`+91` / leading-`0`.

Per the user's decision, bump the **one shared constant** so every mirror keys the
same way:
- Dart `ContactRepository._mirrorMatchDigits` 7 → 10.
- Dart `findByFullNumber` prefilter tail 7 → 10 (kept "in step"; the exact E.164
  check remains the authority, so no correctness regression — it just scans a
  narrower, still-superset candidate set).
- Native `IncomingCallRinger.MATCH_DIGITS` 7 → 10.
- Update the comments that mention "7". Check `test/group_ringtone_test.dart` for
  any hard-coded trailing-7 key expectations and update them.

## Files to change

**Flutter (Dart)**
1. `lib/repositories/contact_repository.dart`
   - `_mirrorMatchDigits` 7 → 10; `findByFullNumber` prefilter tail 7 → 10; update
     the related comments.
   - New `contactNameMirrorEntries()` → `Future<Map<String,String>>`: query all
     `phone_numbers` joined to `contacts`, compose the display name (salutation +
     first + middle + last, same as `Contact.fullName`), key by trailing
     `_mirrorMatchDigits` digits (reuse `normalizeDigits`), skip blank name/number.
     On a trailing-digit collision the later row wins (same rule as the tone map).
   - `_pushRingtoneMirrorNow()`: also build the name map and pass it in the same
     `setRingtoneMirror` call.
2. `lib/services/telecom_service.dart`
   - `setRingtoneMirror(...)`: add an optional `Map<String,String>? contactNames`
     arg, forwarded as `contactNames` on the method channel (null leaves it
     untouched, same contract as the other maps).

**Native (Android / Kotlin)**
3. `android/.../IncomingCallRinger.kt`
   - `MATCH_DIGITS` 7 → 10 (update the comment). Add
     `const val KEY_CONTACT_NAMES = "contact_names"` (same companion as
     `KEY_CONTACT_TONES`). Expose the trailing-digit key helper for reuse (make
     `matchKey` / `MATCH_DIGITS` reachable, or add a small companion helper) so the
     service and ringer key numbers identically.
4. `android/.../MainActivity.kt`
   - `setRingtoneMirror`: accept and persist a `contactNames` map (JSON) under
     `KEY_CONTACT_NAMES` in `RINGER_PREFS`, alongside the existing tone maps. Read
     the new `contactNames` channel argument in the `setRingtoneMirror` case.
5. `android/.../ContactSphereInCallService.kt`
   - In `onMissedCall`, resolve the caller name from `RINGER_PREFS`/
     `KEY_CONTACT_NAMES` by trailing-7-digit key; use it as the notification title,
     falling back to the number (then "Unknown"). No DB, no Flutter needed.

**Docs**
6. `docs/architecture.md` — note the mirror now also carries contact names and the
   missed-call notification uses it.

## Privacy note (decision point)

The DB is encrypted (SQLCipher). This mirror writes **all** contact names +
numbers into a **plaintext** `SharedPreferences` file. The existing mirrors already
store blocked numbers and tone-bearing numbers in plaintext, so there's precedent,
but a full name+number list is a broader exposure of otherwise-encrypted data
(readable only with device/root/backup access to the app's private storage).
I think this is an acceptable, consistent tradeoff for the feature; flagging it so
you can veto. (Encrypting the mirror would need a native-readable key — out of
scope here.)

## Testing

- `flutter analyze`; `flutter test` (add/extend a `ContactRepository` test for
  `contactNameMirrorEntries` keying if the suite has a natural home — otherwise the
  existing mirror tests cover the shape).
- `./gradlew :app:compileDevDebugKotlin`.
- Manual on device (moto g54), app fully closed (swipe from Recents):
  - Missed call from a **saved** contact → notification title shows the **name**.
  - Missed call from an **unknown** number → title shows the number.
  - Edit a contact's name / add a contact, then miss a call from them → name is
    current (mirror refreshed on the write).

## Risks / rollback

- Larger prefs value (all contacts) — fine for typical counts; JSON in one string.
- Name format is `fullName` ("First Middle Last"), not the user's list display
  format; acceptable for a notification title (can be refined later).
- Rollback: stop pushing `contactNames` and drop the native read; the notification
  falls back to the number (today's behavior).
