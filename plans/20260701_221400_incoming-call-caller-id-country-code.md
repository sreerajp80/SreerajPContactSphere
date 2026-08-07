# Fix: incoming call doesn't show saved contact name / photo (country-code mismatch)

**Status:** dropped

> Superseded by `20260701_221932_default-country-number-normalization.md`. The user chose a
> Default Country setting + E.164 normalization instead of the trailing-digit heuristic.

## Issue

An incoming call from `+919876543210` shows the raw number and a `#` avatar even though
the contact is saved as `9876543210` (no country code).

Caller-ID resolution in `InCallScreen._resolveName` calls
`ContactRepository.findByPhoneFragment(number, limit: 1)`. That method is built for the
**dialer**: it finds stored numbers that *contain* a typed fragment via

```sql
WHERE <normalized stored number> LIKE '%<incoming digits>%'
```

For an incoming call the incoming number is the *long* form (`919876543210`) and the stored
number is the *short* national form (`9876543210`). The stored value does not contain
`919876543210`, so the query returns zero rows → no name and no photo.

The same wrong-direction prefilter also silently breaks
`CallService._resolveContactId` and `CallEventLogger._resolveContactId`: both already do the
correct trailing-digit check (`candidate.endsWith(target) || target.endsWith(candidate)`),
but that check runs on the result of `findByPhoneFragment`, which has already excluded the
matching row. So incoming calls also fail to link/name the contact in the call log / recents.

## Root cause

`findByPhoneFragment` uses "stored CONTAINS incoming" semantics. Caller-ID needs a
**trailing-digit** match so a stored national number matches an incoming number that carries
a country code (and vice versa).

## Fix

Add a dedicated caller-ID lookup to `ContactRepository` and use it wherever a full inbound/
dialed number is resolved to a contact. Leave `findByPhoneFragment` (dialer suggestions)
unchanged.

New method (mirrors `findByPhoneFragment`'s projection/mapping):

```dart
/// Resolves a full phone number (e.g. an incoming caller ID or a dialed
/// number) to matching contacts by a trailing-digit comparison, so a stored
/// national number (9876543210) still resolves an incoming number that carries
/// a country code (+919876543210), and vice versa. Contrast with
/// [findByPhoneFragment], which finds stored numbers that *contain* a typed
/// fragment for live dialer suggestions.
Future<List<PhoneMatch>> findByFullNumber(String number, {int limit = 1}) async {
  final digits = normalizeDigits(number);
  if (digits.isEmpty) return const <PhoneMatch>[];
  // A short trailing slice is a cheap, selective SQL prefilter; the exact
  // suffix relationship is confirmed in Dart below.
  final tail = digits.length > 7 ? digits.substring(digits.length - 7) : digits;

  final db = await _dbHelper.database;
  final rows = await db.rawQuery(
    // same SELECT (number, label, contact_id, assembled contact_name) and the
    // same REPLACE(...) digit-normalization as findByPhoneFragment
    '''... WHERE <normalized stored number> LIKE ? ORDER BY c.first_name ASC''',
    ['%$tail%'],
  );

  final out = <PhoneMatch>[];
  for (final r in rows) {
    final candidate = normalizeDigits(r['number'] as String);
    if (candidate.isEmpty) continue;
    if (candidate.endsWith(digits) || digits.endsWith(candidate)) {
      out.add(/* map row -> PhoneMatch, same as findByPhoneFragment */);
      if (out.length >= limit) break;
    }
  }
  return out;
}
```

Notes:
- The Dart-side `endsWith` (both directions) is the same trailing-match rule already trusted
  by `CallService`/`CallEventLogger`; it's applied here on a prefilter that actually includes
  the right row.
- No SQL `LIMIT` on the raw query (we cap after verification) so the `tail` prefilter can
  surface the real match even amid other rows; verification then bounds output to `limit`.

## Files to change

1. `lib/repositories/contact_repository.dart`
   - Add `findByFullNumber(...)` as above.

2. `lib/screens/in_call_screen.dart`
   - In `_resolveName`, replace `findByPhoneFragment(number, limit: 1)` with
     `findByFullNumber(number, limit: 1)`. (Name + backdrop image then resolve correctly.)

3. `lib/services/call_service.dart`
   - In `_resolveContactId`, replace `findByPhoneFragment` with `findByFullNumber`. The
     existing `endsWith` guard is now redundant but harmless; keep it as a defensive check.

4. `lib/services/call_event_logger.dart`
   - In `_resolveContactId`, same swap as call_service.

## Out of scope / not changed

- `findByPhoneFragment` and the dialer's live-suggestion behavior (unchanged).
- The intentional `'\0'` sentinel/delimiter string literals in `contact_repository.dart`
  (they are valid Dart, not corruption).

## Verification

- `flutter analyze` clean for the touched files.
- Manual: save a contact as a 10-digit national number, receive a call from the same number
  with a `+91` country code → in-call screen shows the contact name and photo; the call log
  entry links to the contact.
- Reverse case: store a number with `+91`, receive/dial the national form → still resolves.
