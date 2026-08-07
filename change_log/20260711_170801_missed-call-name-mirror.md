# Change log: Missed-call notification shows the contact name (offline)

Implements plan `plans/20260711_165449_missed-call-name-mirror.md`.

## What changed

The app-posted missed-call notification now shows the **saved contact's name**
even when the app (and its encrypted DB) isn't running, by reusing the existing
ringtone-mirror mechanism. The shared trailing-digit match key was also fixed from
7 to 10 digits to stop real Indian numbers from colliding.

### Fix: mirror match key 7 → 10 digits (all mirrors)

7 trailing digits collide for distinct Indian mobiles (e.g. `9000123456` and
`9111123456` both end `0123456`). India's fixed 10-digit mobile plan makes the
last 10 digits collision-free while still absorbing a leading `+91` / `0`.

- `lib/repositories/contact_repository.dart` — `_mirrorMatchDigits` 7 → 10, and
  `findByFullNumber` now uses `_mirrorMatchDigits` for its SQL prefilter tail (its
  exact E.164 check remains the authority, so no correctness regression).
- `android/.../IncomingCallRinger.kt` — `MATCH_DIGITS` 7 → 10.

### Feature: contact-name mirror (reuses the one mirror)

- `lib/repositories/contact_repository.dart` — new `contactNameMirrorEntries()`
  builds a digit→name map for **every** contact with a number (name composed like
  `Contact.fullName`), keyed by the same 10-digit rule. `_pushRingtoneMirrorNow()`
  now pushes tones **and** names in the same `setRingtoneMirror` call — so it rides
  the same debounce and the same triggers (startup, contact writes, group changes,
  sync).
- `lib/services/telecom_service.dart` — `setRingtoneMirror` gained an optional
  `contactNames` map argument.
- `android/.../IncomingCallRinger.kt` — added `KEY_CONTACT_NAMES` and a shared
  `matchKey(number)` companion helper (the instance method now delegates to it) so
  every native reader keys numbers identically.
- `android/.../MainActivity.kt` — `setRingtoneMirror` accepts and persists the
  `contactNames` map (JSON) under `KEY_CONTACT_NAMES` in the same `RINGER_PREFS`.
- `android/.../ContactSphereInCallService.kt` — `onMissedCall` resolves the caller
  name from that mirror (by the 10-digit key) and uses it as the notification
  title, falling back to the number, then "Unknown". No DB, no Flutter needed.

### Docs / tests

- `docs/architecture.md` — documented the name mirror and the 10-digit key.
- `test/group_ringtone_test.dart` — updated the mirror-key expectations from the
  trailing-7 slice to the full 10-digit numbers.

## Privacy note

The contact-name mirror writes all contact names + numbers into a **plaintext**
`SharedPreferences` file while the SQLite DB itself is encrypted. This is
consistent with the existing tone / screening mirrors and was accepted by the user
for this feature. Encrypting the mirror (needs a native-readable key) was left out
of scope.

## Verification

- `flutter analyze` — No issues found.
- `flutter test` (one file per invocation): the updated `group_ringtone_test`
  mirror tests pass; `phone_normalizer_test` and `contact_stem_search_test`
  (number matching) pass; the only failure is `group_ringtone_test`'s v13→v14
  migration test, which fails identically on pre-change committed code (pre-existing,
  unrelated — confirmed earlier via `git stash`).
- `./gradlew :app:compileDevDebugKotlin` — BUILD SUCCESSFUL.

## Still to verify on device (moto g54), app fully closed

- Missed call from a saved contact → notification title shows the **name**.
- Missed call from an unknown number → shows the number.
- Rename/add a contact, then miss a call from them → name is current.
