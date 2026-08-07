# Recents now refreshes when an incoming call ends while the tab is open

Implements [plans/20260704_192020_recents-refresh-on-incoming-call.md](../plans/20260704_192020_recents-refresh-on-incoming-call.md).

## Problem

Sitting on the Recents tab during an incoming call, the completed call didn't appear
until the user switched tabs and came back. `CallEventLogger` wrote the `call_logs`
row fire-and-forget, but nothing told `CallHistoryScreen` to re-query; its only
refresh triggers were outgoing-call reconciliation and tab re-selection.

## Changes

1. **New `lib/state/call_log_events.dart`** — `CallLogEvents`, a singleton
   `ChangeNotifier` signalling "a call_logs row was just written".
2. **`lib/services/call_event_logger.dart`** — `_logIncoming` now calls
   `CallLogEvents.instance.notifyCallLogged()` immediately after the
   `call_logs` insert succeeds (before the interaction/scoring writes, which
   don't affect Recents). Notifying after the write avoids the race a raw
   Telecom call-end listener would have with the async insert.
3. **`lib/screens/call_history_screen.dart`** — subscribes to `CallLogEvents`
   in `initState`, unsubscribes in a new `dispose` override, and reloads the
   list when notified.

Unchanged: `HomeShell`'s reload-on-tab-select and the outgoing-call
reconciliation path in `CallLifecycleMixin`.

## Verification

- `flutter analyze` on the three touched files: no issues.
- Manual check (requires a device with ContactSphere as default dialer): stay on
  Recents, receive/hang up a call → the row appears without leaving the tab.
