# Recents doesn't refresh after an incoming call ends while the Recents tab is open

**Status:** completed

## Issue

When the user is sitting on the Recents tab and receives a call, the completed call does
not appear in the list after the call ends. It only shows up after switching to another
tab and back (which triggers `HomeShell._onSelect` → `CallHistoryScreenState.reload()`).

### Root cause

Incoming/missed calls are written to `call_logs` by `CallEventLogger` (a global listener
started in `main.dart`), fire-and-forget, when the call ends. Nothing tells
`CallHistoryScreen` that a new row exists. The screen currently re-queries only on:

1. `onCallReconciled()` from `CallLifecycleMixin` — fires only for **outgoing** calls
   placed from that screen via `startCall()`. For incoming calls the mixin's
   `_onCallEvent` returns immediately because `_pendingCall == null`
   (`lib/widgets/call_lifecycle_mixin.dart:99`).
2. `reload()` from `HomeShell` — fires only when the Recents tab is (re)selected
   (`lib/screens/home_shell.dart:48-57`). The `IndexedStack` keeps the tab alive, so
   staying on Recents never re-triggers it.

Listening to raw Telecom call-end events on the screen would not be a correct fix either:
`CallEventLogger._logIncoming` runs async after the end event, so a reload racing it could
still read the DB before the row is inserted. The notification must fire **after** the DB
write completes.

## Fix

Introduce a tiny app-wide notifier that `CallEventLogger` pings after it has finished
writing an incoming/missed call row, and have `CallHistoryScreen` listen to it and reload.

## Files to change

1. **New: `lib/state/call_log_events.dart`**
   A minimal singleton `ChangeNotifier`:
   ```dart
   /// App-wide "a call_logs row was just written" signal, so screens showing
   /// call history can refresh without polling.
   class CallLogEvents extends ChangeNotifier {
     CallLogEvents._();
     static final CallLogEvents instance = CallLogEvents._();
     void notifyCallLogged() => notifyListeners();
   }
   ```

2. **`lib/services/call_event_logger.dart`**
   In `_logIncoming`, after `await _interactions.logCall(...)` succeeds, call
   `CallLogEvents.instance.notifyCallLogged()` — before the interaction/scoring writes,
   since only the `call_logs` row matters for Recents. (Stays inside the existing `try`,
   so a failed write still notifies nothing.)

3. **`lib/screens/call_history_screen.dart`**
   - `initState`: `CallLogEvents.instance.addListener(_onCallLogged)`.
   - `dispose` (new override): remove the listener.
   - `_onCallLogged()` → `_load()` (same silent re-query the tab-select `reload()` uses).

## Not changing

- `HomeShell`'s reload-on-tab-select stays — it still covers outgoing calls reconciled on
  other tabs.
- Outgoing-call reconciliation (`CallLifecycleMixin`) is untouched; it already refreshes
  the screen it ran on via `onCallReconciled()`.

## Verification

- `flutter analyze` (no new issues in the touched files; pre-existing errors per
  docs/known-gaps.md are unrelated).
- Manual: with ContactSphere as default dialer, stay on Recents, receive a call, hang up →
  the row appears without leaving the tab. Same for a missed (unanswered) call.
