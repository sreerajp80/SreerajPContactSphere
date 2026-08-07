# Recents: automatic device call-log sync + instant post-call update

Implements [plans/20260719_143000_auto-sync-device-call-log.md](../plans/20260719_143000_auto-sync-device-call-log.md).

## What was wrong

Recents was built forward only, from calls the app itself witnessed live. The phone's own
call log came in only when the user pressed a button in Settings, so any call the app did
not see — from another dialer, from the lock screen, while the app was killed — was never
in Recents. On top of that, a call placed from Recents did not appear until it was
reconciled, and several defects stopped that reconciliation from ever finishing.

## What changed

### The device call log now syncs by itself

New `CallLogImportService.syncFromDevice()` reads only what is new: it keeps a watermark
(`call_log_synced_through_millis` in `SharedPreferences`) and asks the phone for calls
after it, minus a 2-day overlap. The first ever run does one full import. It runs at app
start, when Recents opens, when the app resumes, and when a call ends — throttled to one
routine pass every 15 seconds, with `force: true` skipping the throttle on a call end.
It never throws.

### De-duplication now uses a time window instead of an exact timestamp

The old key was `digits|exactEpochMillis`, so a call the app logged live and the same call
in the device log never matched, and every import added a twin. Matching is now by the
last 10 digits of the number within ±90 seconds (`CallLogRepository.matchKey`,
`findMatch`, `storedCallsForMatching`, and the new `StoredCall` record). On a match the
import **fills in** the existing row via the new
`InteractionRepository.backfillFromDeviceLog()` — duration, direction and SIM only, never
the call intent, notes, feedback or contact link.

### A call placed from Recents appears instantly

- `CallService.placeCall` now fires `CallLogEvents` as soon as the provisional row is
  written, so the row shows up the moment the call starts.
- `CallService.reconcile` returns **whether the device logged the call**, not a duration.
  It previously required `duration > 0`, so an unanswered, cancelled or rejected call —
  0 seconds — was treated as "not ended", `onCallReconciled()` was never called, and the
  row stayed provisional forever. This was a direct cause of calls looking missing.
- The reconcile poll went from 4 fixed 750 ms tries (~2.25 s) to 6 backing-off tries
  (~8 s). If it still misses, `CallLifecycleMixin` now falls back to a forced device sync
  instead of leaving the call provisional.
- `CallLifecycleMixin` refreshes the screen **before** the post-call feedback sheet as
  well as after, so the list is not stale behind the sheet.
- `InteractionRepository.updateCallOutcome` notifies `CallLogEvents` after its
  transaction commits, so any open history view updates.

### Call types are mapped in one place, correctly

New `lib/utils/call_type_mapper.dart` replaces two disagreeing copies: `CallService`
stored a blocked call as `missed` while the importer stored it as `blocked`, and both
dropped `wifiIncoming`, `wifiOutgoing`, `voiceMail` and `unknown` into the `outgoing`
fallback — so an incoming Wi-Fi call showed with an outgoing arrow and a missed Wi-Fi call
never read as missed.

### Recents can show more than 200 calls

`recentCalls` takes an `offset` and defaults to 300; the screen loads another page as the
user scrolls near the bottom. The full-screen spinner now shows only when there is nothing
to display, so the frequent refreshes do not flash the list.

### Failures are reported honestly

`PermissionService.ensureReadCallLog()` requested `Permission.phone`, which on Android 9+
does not cover `READ_CALL_LOG` (its own permission group, and permission_handler has no
constant for it). It returned true while the call log was still blocked, the read failed,
and the UI said "already up to date". The guard is gone from the call-log paths — the
`call_log` plugin raises its own prompt — and `importFromDevice` now returns a
`CallLogImportResult` (`inserted` / `updated` / `failed`) so Settings can say
"Couldn't read the phone's call log — allow the Call logs permission in Android settings".
The method was renamed to `ensurePhoneState()` with a comment explaining what it does and
does not cover.

## Files changed

| File | Change |
|---|---|
| `lib/utils/call_type_mapper.dart` | **new** — the one `CallType` → `call_type` mapper |
| `lib/services/call_log_import_service.dart` | rewritten: `syncFromDevice()` + watermark, window de-dupe with back-fill, `CallLogImportResult` |
| `lib/repositories/call_log_repository.dart` | `storedCallsForMatching()`, `matchKey`, `matchWindow`, `findMatch`, `StoredCall`; `recentCalls` paging (replaces `existingKeys`/`importKey`) |
| `lib/repositories/interaction_repository.dart` | `backfillFromDeviceLog()`; `updateCallOutcome` notifies |
| `lib/services/call_service.dart` | notify on placement; `reconcile` returns a bool and accepts 0-second calls; backing-off poll; shared mapper |
| `lib/widgets/call_lifecycle_mixin.dart` | matched-entry call end; refresh before the sheet; device-sync fallback |
| `lib/screens/call_history_screen.dart` | sync on open/resume/tab-select; paged scrolling; spinner only when empty |
| `lib/state/app_settings.dart` | read/write/clear the sync watermark |
| `lib/main.dart` | one sync at startup |
| `lib/services/permission_service.dart` | `ensureReadCallLog` → `ensurePhoneState` with an accurate comment |
| `lib/screens/contact_sync_settings_screen.dart` | result-aware messages for both manual buttons |
| `lib/screens/help/contact_sync_help_screen.dart` | says the call log now syncs automatically |
| `test/call_log_matching_test.dart` | **new** — 15 tests over the type mapping and window matching |

No database migration — no new columns.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/call_log_matching_test.dart` — 15 passed.
- `flutter test test/call_feature_test.dart` — 4 passed.
- `flutter test test/interaction_repository_test.dart` — 3 passed.

Still to check on the device (needs a real phone and real calls):

1. Call from another dialer with ContactSphere closed → it appears in Recents on open,
   with the right direction and duration.
2. Open and close Recents repeatedly → no duplicate rows.
3. Call from Recents → the row appears immediately and updates when the call ends.
4. Call from Recents and hang up before it connects (0 seconds) → the row still updates.
   This is the case that silently did nothing before.
5. Deny the Call logs permission → Settings shows the "couldn't read" message and Recents
   still lists the app's own calls.
