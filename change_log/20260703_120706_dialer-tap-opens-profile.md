# Dialer: tap a Favorite / Top contact opens their profile

Implements plan `plans/20260703_114158_dialer-tap-opens-profile.md`.

## What changed

- `lib/screens/dialer_screen.dart` — In `_matchRow(...)`, branched the row's tap
  handlers on the existing `favorite` flag:
  - Favorites / Top-contacts rows (`favorite == true`): `onTap` now opens the
    contact profile via `_openContact(m.contactId)`; `onLongPress` set to `null`
    (previously it also opened the profile, now redundant).
  - Live suggestion rows (`favorite == false`): unchanged — `onTap` fills the
    number field via `_selectSuggestion(m)`, `onLongPress` opens the profile.

The per-row call button is unchanged, so calling still works from these rows.

## Verification

- `flutter analyze lib/screens/dialer_screen.dart` → No issues found.
