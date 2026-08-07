# Blocked numbers + Caller/Spam identification

**Status:** completed

## Goal

Two user-facing features, both following ContactSphere's own design system (cards,
accent-tinted icons, switch cards — not a clone of Google's screens):

1. **Blocked numbers** — managed at *Settings → Contacts → Blocked numbers*:
   a list of exactly-matched numbers that never ring, an "Add a number" flow,
   per-row remove, and a "Block unknown callers" toggle (callers with no /
   hidden number). Blocked callers get no call or ring; the call is rejected
   before ringing and appears in the device call log as Blocked.
2. **Identification** — a new screen at *Settings → SIM & calling →
   Identification* with two independent toggles:
   - **Caller identification** (default ON): for callers not in contacts, show
     what we can determine locally — e.g. "Telemarketing" for India's TRAI
     `140…` telemarketer series, "Service call" for the `160…` series, and a
     "Caller verified / not verified" hint from the network's STIR/SHAKEN
     status (API 30+, carrier-dependent).
   - **Filter suspected spam** (default OFF): calls flagged as spam (user-marked
     numbers + the `140…` heuristic) ring silently instead of loudly; the
     in-call/ringing UI labels them "Suspected spam".

### Honest scope limitation

There is **no public Truecaller/Google spam database API**. Identification is
local-only: the app's own contacts, user-marked spam numbers, TRAI number-series
heuristics, and the network verification flag. The identification service is a
single seam (`CallerIdService`) so a commercial lookup API could be plugged in
later without reworking the UI.

## How it works (architecture)

Enforcement must run **before the phone rings and even when the Flutter engine
is cold**, so it lives in a native `CallScreeningService` — Android's official
pre-ring hook. Because ContactSphere already holds the default-dialer role, the
system binds our screening service automatically (no extra role request).

Screening decisions need synchronous data, so we reuse the app's existing
**native mirror pattern** (same as the ringtone mirror): the Flutter side pushes
the blocklist / spam list / toggles into a native `SharedPreferences` file
whenever they change and on app load; the Kotlin service reads them instantly at
screen time. Numbers are mirrored as normalized digit strings and matched the
same trailing-digits way the ringtone mirror already matches contacts.

Decision table in the screening service:

| Condition | Action |
|---|---|
| Number in blocked list | Reject: disallow call, skip notification (system logs it as Blocked) |
| No/hidden number AND "Block unknown callers" ON | Reject (same as above) |
| Spam filter ON AND (number user-marked spam OR `140…` series) | Allow but **silence** the ring (API 29+; below that, allow and label only) |
| Otherwise | Allow normally |

Display (caller ID labels, "Suspected spam" badge, verified status) happens in
the Flutter ringing/in-call UI, which the app already owns, plus the native call
notification via the existing caller-name push (extended with a label).

## Database

`database_helper.dart` bumps version **12 → 13** with one new table:

```sql
CREATE TABLE flagged_numbers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  number TEXT NOT NULL,            -- as entered/seen
  number_e164 TEXT NOT NULL,       -- normalized via PhoneNormalizer + default country
  kind TEXT NOT NULL,              -- 'blocked' | 'spam'
  created_at TEXT NOT NULL,
  UNIQUE(number_e164, kind)
)
```

One table serves both features ("blocked" powers the Blocked numbers screen,
"spam" powers the filter); a number can be both.

## Files to change

### New files
| File | Purpose |
|---|---|
| `lib/repositories/flagged_number_repository.dart` | CRUD for `flagged_numbers`; normalizes via `PhoneNormalizer`; pushes the native screening mirror after every change (mirrors `ContactRepository.pushRingtoneMirror` pattern) |
| `lib/services/caller_id_service.dart` | Local identification: given a number → `CallerIdInfo` (label, category, isSpam) from the spam list + TRAI `140…`/`160…` series rules |
| `lib/screens/blocked_numbers_screen.dart` | Settings → Contacts → Blocked numbers: "Block unknown callers" switch card, "Add a number" (dialog with number field), list card with per-row remove |
| `lib/screens/identification_settings_screen.dart` | Settings → SIM & calling → Identification: the two switch cards + an info card explaining what identification can and cannot do (local-only, no external database) |
| `android/.../ContactSphereCallScreeningService.kt` | The `CallScreeningService`: reads the mirrored prefs, applies the decision table above |
| `test/flagged_number_repository_test.dart` | Repository unit tests on `sqflite_common_ffi` (add/remove/lookup, normalization, kind separation) |

### Modified files
| File | Change |
|---|---|
| `lib/database/database_helper.dart` | v13 migration + table in `_onCreate` |
| `lib/state/app_settings.dart` | Three new persisted settings: `blockUnknownCallers` (default off), `callerIdEnabled` (default on), `spamFilterEnabled` (default off); each mirrored natively on change and on `load()` |
| `lib/services/telecom_service.dart` | New channel methods: `setScreeningMirror(...)` (number lists + toggles) and `setCallerLabel(...)` (extends the existing caller-name push with an identification label) |
| `lib/screens/contacts_settings_screen.dart` | Add a "Blocked numbers" card routing to the new screen |
| `lib/screens/sim_settings_screen.dart` | Add an "Identification" card routing to the new screen |
| `lib/screens/in_call_screen.dart` | When no contact matches and Caller ID is on: show the `CallerIdService` label under the number; red "Suspected spam" badge for spam; small "not verified" hint when the network reports a failed verification |
| `lib/models/call_state.dart` | New `verificationStatus` field parsed from the snapshot |
| `lib/screens/call_history_screen.dart` | Entry actions: "Block number" / "Unblock", "Mark as spam" / "Not spam"; show the device log's Blocked call type with a Blocked label |
| `android/.../MainActivity.kt` | Handle the two new channel methods; write the screening prefs file |
| `android/.../CallRegistry.kt` | Add `verificationStatus` (API 30+ `getCallerNumberVerificationStatus`) to `snapshot()`; forward the caller label to the notification |
| `android/.../ContactSphereInCallService.kt` | Call notification can show the identification label (e.g. "Suspected spam") beneath/instead of the bare number |
| `android/app/src/main/AndroidManifest.xml` | Register the screening service with `android.permission.BIND_SCREENING_SERVICE` |

## Verification

- `flutter analyze` clean (relative to the pre-existing known-gaps errors).
- `flutter test` — new repository tests plus the existing suite.
- On-device: block a test number → it must not ring and must appear as Blocked
  in call history; enable spam filter and call from a marked number → silent
  ring with "Suspected spam" on the ring screen; toggles off → normal behavior.

## Out of scope (possible follow-ups)

- Online spam-reputation lookup (paid APIs; the `CallerIdService` seam is ready).
- Blocking SMS (the app is not an SMS app).
- Import/export of the blocklist.
