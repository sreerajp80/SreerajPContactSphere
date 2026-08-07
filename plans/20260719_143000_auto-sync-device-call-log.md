# Auto-sync the device call log into Recents

**Status:** completed

## The problem

Recents is missing calls.

Today the app builds Recents **forward only**, from its own live call events
(`CallEventLogger`, `CallService`, the blocked/call-waiting drains). The phone's own
call log is pulled in **only** when the user taps a button in
Settings → Contact sync ("Add device call log to app",
[contact_sync_settings_screen.dart:458](lib/screens/contact_sync_settings_screen.dart#L458)).

So any call the app did not see live is simply never in Recents:

- calls placed or received while the app was killed / not the default dialer,
- calls made from another dialer app, from the lock screen, or from a headset,
- calls the OS routed without firing the app's call-event stream (Wi-Fi calling,
  some carrier/VoLTE paths).

On top of that there are five concrete defects in the existing import path:

1. **Wi-Fi / voicemail calls are labelled "outgoing".**
   `_mapCallType` in [call_log_import_service.dart:115](lib/services/call_log_import_service.dart#L115)
   handles `incoming`, `answeredExternally`, `missed`, `rejected`, `blocked`, `outgoing`.
   The `call_log` package also returns `wifiIncoming`, `wifiOutgoing`, `voiceMail` and
   `unknown`. All of those fall into the `default:` branch and are stored as **outgoing** —
   so an incoming Wi-Fi call shows in Recents with an outgoing arrow, and a missed Wi-Fi
   call is not shown as missed at all.

2. **De-dupe is exact-to-the-millisecond, so import creates twins.**
   `CallLogRepository.importKey` ([call_log_repository.dart:68](lib/repositories/call_log_repository.dart#L68))
   keys on `digits|exactEpochMillis`. A call the app logged live and the same call in the
   device log differ by a second or two, so a merge import inserts a second row for a call
   that is already there. The doc comment admits this. Repeated imports keep adding twins.

3. **A failed import reports success.**
   `PermissionService.ensureReadCallLog()`
   ([permission_service.dart:62](lib/services/permission_service.dart#L62)) requests
   `Permission.phone`, which on Android 9+ does **not** cover `READ_CALL_LOG` — that is a
   separate permission group. So the guard returns true, `CallLog.get()` then fails or
   returns nothing, the error is swallowed, and the UI says
   "Call log is already up to date" when in fact nothing could be read.
   (The `call_log` plugin does request `READ_CALL_LOG` itself when called from the
   foreground activity, so the fix is to trust the plugin and report its failure honestly,
   not to keep a guard that lies.)

4. **Recents is capped at 200 rows with no way to see more.**
   `recentCalls({int limit = 200})` ([call_log_repository.dart:16](lib/repositories/call_log_repository.dart#L16)).
   After a full device import the older calls exist in the DB but can never be scrolled to,
   which also reads as "missing".

5. **A full import re-reads the whole device log every time** (`CallLog.get()`), which is
   slow on a phone with years of history — too slow to run automatically.

## The fix

Make the device call log the source of truth for Recents, and sync it **automatically and
incrementally**, instead of asking the user to press a button.

### A. Incremental sync

Add `CallLogImportService.syncFromDevice()`:

- read a stored watermark (`last_call_log_sync_millis`) from `SharedPreferences`;
- query only what is new: `CallLog.query(dateFrom: watermark - 2 days)` — the 2-day
  overlap re-checks recent calls so nothing is lost if a row landed late, and de-dupe
  (below) stops it duplicating;
- on the very first run (no watermark) fall back to `CallLog.get()` — one full import;
- after a successful pass, store the newest timestamp seen as the new watermark;
- fire `CallLogEvents.instance.notifyCallLogged()` only when something actually changed.

Keep the existing `importFromDevice({replace})` for the two manual Settings buttons.

### B. Run the sync automatically

- On app start, after permissions are requested (`main.dart`), fire-and-forget.
- In `CallHistoryScreenState._load()` ([call_history_screen.dart:61](lib/screens/call_history_screen.dart#L61)),
  before reading the history — so opening Recents always shows a current list.
- On app resume (the screen already mixes in `WidgetsBindingObserver`), so a call taken
  outside the app appears when the user comes back.
- Throttle to at most one sync every 15 seconds and guard against a second sync running
  while one is in flight, so tab switching does not hammer the content provider.
- Every failure is logged and swallowed — a sync problem must never leave Recents blank.

### C. Time-window de-dupe (fixes the twins)

Replace exact-millisecond keys with a tolerance match:

- `CallLogRepository.existingCallKeys()` returns, per stored row, `(id, digits10, epochMillis, duration, callType)`
  where `digits10` is the last 10 digits of the number (same rule as the existing native
  number mirror, so `+91…` and `0…` forms of one number match).
- A device row matches an existing row when the digits match **and** the timestamps are
  within ±90 seconds.
- On a match: do **not** insert. Instead back-fill the existing row from the device row
  (real `duration`, corrected `call_type`, `sim_id`/`sim_label` when missing) — the device
  values are authoritative — while keeping app-only fields (`call_intent`, notes, feedback).
- On no match: insert as today.

This needs one new method, `InteractionRepository.backfillFromDeviceLog(...)`, which
updates only the columns listed above and never touches app-only columns.

### D. Correct call-type mapping

Rewrite `_mapCallType` to cover every `CallType` value:

| device type | stored `call_type` |
|---|---|
| `incoming`, `answeredExternally`, `wifiIncoming` | `incoming` |
| `missed`, `rejected` | `missed` |
| `blocked` | `blocked` |
| `outgoing`, `wifiOutgoing` | `outgoing` |
| `voiceMail` | `incoming` |
| `unknown`, `null` | `outgoing` (unchanged fallback) |

Note `rejected` keeps mapping to `missed`, matching today's behaviour.

### E. Show more than 200 rows

Raise the initial page to 300 and load the next page when the user scrolls near the
bottom (`recentCalls(limit:, offset:)` plus a scroll listener in `CallHistoryScreen`).
Recents keeps its day grouping; only the number of rows in memory grows.

### F. Instant population when a call ends (including calls placed from Recents)

Placing a call from Recents goes `_callBack` → `CallLifecycleMixin.startCall` →
`CallService.placeCall`. Five things stop the row appearing straight away:

1. **Nothing refreshes the list at placement.** `placeCall`
   ([call_service.dart:106](lib/services/call_service.dart#L106)) writes a provisional
   `call_logs` row, but no `CallLogEvents` notification follows, and `startCall`
   ([call_lifecycle_mixin.dart:119](lib/widgets/call_lifecycle_mixin.dart#L119)) does not
   call back into the screen. So the call you just placed is not in the list under you.
   → Notify `CallLogEvents` right after the provisional rows are written. Recents already
   listens, so the row appears the moment the call starts.

2. **The refresh is gated on a non-zero duration.** In `_reconcilePendingCall`
   ([call_lifecycle_mixin.dart:187](lib/widgets/call_lifecycle_mixin.dart#L187)),
   `callEnded` requires `duration != null && duration > 0`, and `onCallReconciled()` is
   only reached when that is true. A call that rang unanswered, was cancelled before
   connecting, or was rejected has **duration 0** — so the screen is never told to reload
   and the row stays as it was placed. This is a direct cause of calls looking "missing".
   → Treat "a matching device call-log entry exists" as the end of the call, whatever the
   duration. `CallService.reconcile` returns the matched entry (not just a duration) so a
   0-second call is a real, reconciled end.

3. **The poll window is too short.** `reconcile` polls the device log 4 times, 750 ms
   apart — about 2.25 s ([call_service.dart:187](lib/services/call_service.dart#L187)).
   Android often writes the row later than that. When all 4 tries miss, the row is left
   provisional (no duration, type stuck at `outgoing`) and, because nothing re-arms
   without another resume or call event, it stays that way.
   → Widen to 6 tries with a growing delay (0.5 s → 1 s → 1.5 s → 2 s → 3 s ≈ 8 s total),
   and if it still misses, fall back to the incremental device sync from section A, which
   will pick the call up and back-fill it via the window match in section C.

4. **The list refreshes only after the feedback sheet is closed.** `onCallReconciled()` is
   called after `await showPostCallFeedbackSheet(...)`
   ([call_lifecycle_mixin.dart:199-210](lib/widgets/call_lifecycle_mixin.dart#L199-L210)),
   so the stale list sits behind the sheet.
   → Call `onCallReconciled()` **before** showing the sheet as well as after it, so the row
   is already correct when the sheet appears.

5. **Back-filling a call doesn't tell anyone.** `updateCallOutcome`
   ([interaction_repository.dart:113](lib/repositories/interaction_repository.dart#L113))
   updates the row silently.
   → Notify `CallLogEvents` after the transaction commits, so any open history view updates
   even if it was not the screen that placed the call.

Also, the 15 s sync throttle from section B is **bypassed** on a call-end trigger — a call
ending always syncs immediately.

While here, `CallService._mapCallType`
([call_service.dart:212](lib/services/call_service.dart#L212)) maps `blocked` → `missed`
while the import maps it to `blocked`, and it too ignores the Wi-Fi types. Both mappers
become one shared function so a call reads the same however it was recorded.

### G. Honest permission handling

- Drop the misleading `ensureReadCallLog()` guard from the import path; let the
  `call_log` plugin raise its own `READ_CALL_LOG` prompt.
- Distinguish "the read failed" from "nothing new": `importFromDevice` returns a small
  result object (`imported`, `updated`, `failed`) so the Settings card can say
  "Couldn't read the phone's call log — check the Call logs permission" instead of
  "already up to date".
- Add a short note in the permission doc comment explaining why `Permission.phone` is not
  enough on Android 9+.

## Files to change

| File | Change |
|---|---|
| [lib/services/call_log_import_service.dart](lib/services/call_log_import_service.dart) | add `syncFromDevice()` + watermark; window de-dupe + back-fill; fix `_mapCallType`; return a result object; drop the false permission guard |
| [lib/repositories/call_log_repository.dart](lib/repositories/call_log_repository.dart) | `existingCallKeys()` (id + 10-digit key + millis); `recentCalls` gains `offset`; keep `importKey` only if still used |
| [lib/repositories/interaction_repository.dart](lib/repositories/interaction_repository.dart) | new `backfillFromDeviceLog()` |
| [lib/screens/call_history_screen.dart](lib/screens/call_history_screen.dart) | sync before load; sync on resume; paged scrolling |
| [lib/services/call_service.dart](lib/services/call_service.dart) | notify on provisional insert; return the matched entry (0-second calls count as ended); wider back-off poll; shared type mapper |
| [lib/widgets/call_lifecycle_mixin.dart](lib/widgets/call_lifecycle_mixin.dart) | treat a matched entry (not duration > 0) as call end; refresh before *and* after the feedback sheet; fall back to a device sync when the poll misses |
| [lib/utils/](lib/utils/) (new small file) | the one shared `CallType` → `call_type` mapper |
| [lib/state/app_settings.dart](lib/state/app_settings.dart) | read/write the `last_call_log_sync_millis` watermark |
| [lib/main.dart](lib/main.dart) | kick off one sync at startup |
| [lib/services/permission_service.dart](lib/services/permission_service.dart) | correct the `ensureReadCallLog` doc / behaviour |
| [lib/screens/contact_sync_settings_screen.dart](lib/screens/contact_sync_settings_screen.dart) | accurate result messages for the two manual buttons |
| [lib/screens/help/contact_sync_help_screen.dart](lib/screens/help/contact_sync_help_screen.dart) | describe that the call log now syncs automatically |
| `test/call_log_import_service_test.dart` (new) | cover the type mapping and window de-dupe/back-fill |

No database migration is needed — no new columns.

## How to check it worked

1. `flutter analyze` and `flutter test` are clean.
2. On the device: make a call from another dialer with ContactSphere closed, open
   ContactSphere → the call is in Recents with the right direction and duration.
3. Open and close Recents several times → no duplicate rows appear.
4. A call the app logged live shows one row, with the real duration filled in after sync.
5. **Call from Recents**: the row appears the instant the call starts, and updates with the
   real duration and direction as soon as the call ends — without leaving the screen.
6. **Call from Recents and hang up before it connects** (0 seconds): the row is still there
   and still updates — this is the case that silently did nothing before.
7. Deny the Call logs permission → Settings shows the "couldn't read" message, and Recents
   still lists the app's own calls.

## Risks

- Back-filling an existing row overwrites a live-logged `call_type`/`duration` with the
  device's. That is intended (the device is authoritative), but a wrong ±90 s match on two
  real calls to the same number inside 90 seconds would merge them. The window is a
  deliberate trade-off; 90 s is short enough that back-to-back calls to one number are rare.
- Automatic sync on every Recents open costs a content-provider query; the watermark plus
  the 15 s throttle keeps it small.
