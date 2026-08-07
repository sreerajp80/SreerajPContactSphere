# Dialer and in-call avatar initials must exclude the salutation

**Status:** completed

Follow-up to [20260705_114822_avatar-initial-no-salutation.md](20260705_114822_avatar-initial-no-salutation.md),
which fixed the relationship sphere and Relation Status list. Two remaining
avatar-initial sites derive the letter from a SQL-resolved display name that
concatenates the salutation, so "Mr John" shows **M**:

1. **Dialer rows** (favorites, top contacts, match-as-you-type suggestions) —
   [lib/screens/dialer_screen.dart](../lib/screens/dialer_screen.dart) line 561
   takes the initial from `PhoneMatch.contactName`, which all three resolver
   queries in `ContactRepository` build as
   `salutation || first_name || middle_name || last_name`.
2. **In-call screen** — [lib/screens/in_call_screen.dart](../lib/screens/in_call_screen.dart)
   line 326 takes the initial from `_resolvedName`, which is set from
   `PhoneMatch.contactName` (via `findByFullNumber`).

Not affected: the call history screen shows no avatar initial, so
`CallRecord.contactName` (also salutation-prefixed) needs no change. Display
name text keeps the salutation everywhere, as before.

## Files to change

| File | Change |
|---|---|
| `lib/repositories/contact_repository.dart` | Select `c.first_name AS first_name` in the three `PhoneMatch` sources (`findByPhoneFragment`, `findByFullNumber`, `_preDialProjection`); add a `firstName` field to `PhoneMatch` and populate it in the three mapping sites (`findByPhoneFragment`, `findByFullNumber`, `_preDialMatch`). |
| `lib/screens/dialer_screen.dart` | `_matchRow`: initial from `m.firstName`, falling back to the existing `'#'` when empty. |
| `lib/screens/in_call_screen.dart` | Add a `_resolvedFirstName` state field set alongside `_resolvedName` in `_resolveName` (and cleared with it for no-match); `_identity` derives the initial from it, keeping the `'#'` fallback. |

## Fix plan

1. `PhoneMatch`: add `final String firstName;` with default `''` (named,
   `this.firstName = ''`) so the model stays constructible without it — three
   constructor sites populate it explicitly.
2. Each of the three queries gains `c.first_name AS first_name`; each mapper
   passes `firstName: ((r['first_name'] as String?) ?? '').trim()`.
3. `dialer_screen.dart` `_matchRow`:
   `final initial = m.firstName.isNotEmpty ? m.firstName[0].toUpperCase() : '#';`
   (a `PhoneMatch` with an empty name today falls back to `'#'`; unchanged).
4. `in_call_screen.dart`: `String? _resolvedFirstName;` set in the same
   `setState` as `_resolvedName` (`match.firstName`, null when empty/no match);
   `_identity` uses it for the initial, `'#'` fallback as today.
5. Run `flutter analyze` on the three touched files.

Note: `contact_repository.dart` contains two intentional NUL bytes in string
literals (see memory / docs) — edits must not disturb encoding; changes are
surgical string replacements away from those literals.
