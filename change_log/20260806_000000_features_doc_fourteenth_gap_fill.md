# Change log: fourteenth gap-fill pass on docs/features.md

Implements `plans/20260805_070000_features_doc_fourteenth_gap_fill.md`.

## What changed

`docs/features.md`, section 2 ("Dialer / calling"), the "Call blocking /
spam filtering" bullet. Added a clause saying that:

- screening does not need the app to be running — the native
  call-screening service decides from its own mirrored copy of the
  blocked/spam lists and the toggles, kept in sync by the app, so blocking
  and silencing still work on a cold start with no Flutter engine alive;
- a call blocked while the app was closed is parked natively (number +
  time, most recent 200) and drained into Recents the next time the app is
  opened.

## Why

Before this, a reader could wrongly assume call blocking only works while
ContactSphere is running. The doc already documents this "works with the
app closed" pattern for the missed-call name mirror and the ringtone
mirror, but not for blocking itself.

## Verified against

`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereCallScreeningService.kt`
— reads `SCREENING_PREFS` directly (`blocked_numbers`, `spam_numbers`,
`block_unknown`, `spam_filter`) and journals blocked calls to
`blocked_events` with `MAX_EVENTS = 200`.

## Not changed

- `geolocator` is declared in `pubspec.yaml` but unused in `lib/` and the
  native code; it is not described as a feature, so nothing in
  `features.md` needed fixing.
- The in-app Features showcase screen still carries unverified marketing
  copy; `features.md` already has a caveat covering it.
