# Dialer and in-call avatar initials no longer include the salutation

Implements [plans/20260705_120204_dialer-incall-initial-no-salutation.md](../plans/20260705_120204_dialer-incall-initial-no-salutation.md)
(follow-up to the sphere/relation-status fix in
[20260705_115919_avatar-initial-no-salutation.md](20260705_115919_avatar-initial-no-salutation.md)).

The dialer's avatar rows (favorites, top contacts, typed-digit suggestions)
and the in-call screen fallback avatar took their initial from the resolved
display name, which is SQL-concatenated with the salutation — "Mr John"
showed **M**. The initial now comes from the first name, showing **J**.
Displayed name text (and the name pushed to the native call notification) is
unchanged and still includes the salutation.

## Changes

- `lib/repositories/contact_repository.dart`
  - `PhoneMatch` gained a `firstName` field (given name only, defaults to `''`).
  - All three `PhoneMatch` sources now select `c.first_name` and populate it:
    `findByPhoneFragment`, `findByFullNumber`, and `_preDialProjection` /
    `_preDialMatch` (shared by the Favorites and Top-contacts queries).
- `lib/screens/dialer_screen.dart` — `_matchRow` derives the initial from
  `m.firstName`, keeping the `'#'` fallback for empty names.
- `lib/screens/in_call_screen.dart` — new `_resolvedFirstName` state field set
  alongside `_resolvedName` in `_resolveName` (null when no match); `_identity`
  uses it for the avatar initial, keeping the `'#'` fallback.

Not touched: call history (`CallRecord.contactName`) — it shows no avatar
initial.

## Verification

- `flutter analyze` on the three changed files: no issues.
- The two intentional NUL bytes in `contact_repository.dart` string literals
  verified intact after editing (byte count check).
