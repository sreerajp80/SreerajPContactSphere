# Blocked numbers + Caller/Spam identification

Implements [plans/20260705_122758_blocked-numbers-and-identification.md](../plans/20260705_122758_blocked-numbers-and-identification.md).

## What was added

### Blocked numbers (Settings → Contacts → Blocked numbers)
- `lib/screens/blocked_numbers_screen.dart` (new): "Block unknown callers"
  toggle, "Add a number" dialog, and the blocked list with per-row unblock.
- `lib/screens/contacts_settings_screen.dart`: "Blocked numbers" card.
- Blocked callers are rejected **before ringing** by a new native
  `CallScreeningService`; the call is journalled and appears in Recents as a
  red "Blocked" entry.

### Identification (Settings → SIM & calling → Identification)
- `lib/screens/identification_settings_screen.dart` (new): two toggles —
  **Caller identification** (default on) and **Filter suspected spam**
  (default off) — plus an honest "how it works" card (local-only; no external
  spam database exists to query).
- `lib/screens/sim_settings_screen.dart`: "Identification" card.
- `lib/services/caller_id_service.dart` (new): local identification — user
  spam marks, TRAI `140…` (Telemarketing, spam) / `160…` (Service call)
  series. The service is the seam for a future online reputation API.
- In-call / ringing UI (`lib/screens/in_call_screen.dart`): red "Suspected
  spam" / amber "Telemarketing" / "Service call" chips for non-contacts, and
  an amber "Caller ID not verified" chip when the network reports a failed
  STIR/SHAKEN verification. Labels are also pushed to the call notification
  (CallStyle verification text on API 31+, content text below).

### Data & persistence
- `lib/database/database_helper.dart`: **DB v12 → v13** — new
  `flagged_numbers` table (`kind` = 'blocked' | 'spam', unique per
  `number_e164`+kind); `call_logs` rebuilt so its CHECK admits the new
  `'blocked'` call type (rename → recreate → copy).
- `lib/repositories/flagged_number_repository.dart` (new): CRUD with E.164
  normalization (short codes < 7 digits keep their bare digits so the native
  matcher agrees), plus the screening-mirror push.
- `lib/repositories/interaction_repository.dart`: `logCall` gained an optional
  `timestamp` so drained blocked calls are logged at their original time.
- `lib/state/app_settings.dart`: `blockUnknownCallers`, `callerIdEnabled`,
  `spamFilterEnabled` (persisted; toggles mirrored natively on change/load).

### Native (Android)
- `ContactSphereCallScreeningService.kt` (new): pre-ring screening from the
  mirrored SharedPreferences — reject blocked / unknown (when enabled),
  silence spam (API 29+), journal blocked calls (capped at 200). Registered in
  `AndroidManifest.xml` with `BIND_SCREENING_SERVICE`; bound automatically
  while ContactSphere is the default dialer.
- `MainActivity.kt`: `setScreeningMirror`, `getBlockedCallEvents` (one-shot
  drain), `setCallerLabel` channel methods.
- `CallRegistry.kt`: snapshot now carries `verificationStatus` (API 30+
  STIR/SHAKEN) and forwards the caller label.
- `ContactSphereInCallService.kt`: call notification shows the identification
  label (CallStyle `setVerificationText` / legacy content text).

### Call flow & Recents
- `lib/services/telecom_service.dart`: `setScreeningMirror`, `setCallerLabel`,
  `drainBlockedCallEvents`.
- `lib/models/call_state.dart`: `verificationStatus` field.
- `lib/services/call_event_logger.dart`: `drainBlockedCalls()` — runs at app
  start and on Recents load; writes 'blocked' rows and notifies the screen.
- `lib/screens/call_history_screen.dart`: blocked entries (block icon +
  "Blocked" subtitle), and long-press actions — Block/Unblock, Mark as
  spam/Not spam, Remove from history.
- `lib/screens/settings_screen.dart`: SIM & calling card subtitle updated.

### Tests
- `test/flagged_number_repository_test.dart` (new): normalization/idempotency,
  kind independence, removal, short-code fallback, and the TRAI series rules.

## Deviation from the plan (disclosed)
- `test/widget_test.dart` had a **pre-existing** failure unrelated to this
  change: it asserted the Material `NavigationBar`, which `HomeShell`
  deliberately replaced with a custom bottom bar (see the comment in
  `home_shell.dart`). The stale assertion was updated to check the tab labels
  instead so the suite runs green.

## Verification
- `flutter analyze`: no issues.
- `flutter test`: all 68 tests pass.
- On-device checks still pending (need real calls): blocked number doesn't
  ring and shows as Blocked in Recents; spam-marked number rings silently
  with the "Suspected spam" chip; toggles off restore normal behaviour.
