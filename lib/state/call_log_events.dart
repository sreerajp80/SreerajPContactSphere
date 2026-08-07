// lib/state/call_log_events.dart
import 'package:flutter/foundation.dart';

/// App-wide "a call_logs row was just written" signal, so screens showing call
/// history can refresh without polling.
///
/// [CallEventLogger] notifies after it finishes inserting an incoming/missed
/// call row; [CallHistoryScreen] listens and re-queries. Notifying only after
/// the write completes is the point — reloading off the raw Telecom call-end
/// event would race the async insert.
class CallLogEvents extends ChangeNotifier {
  CallLogEvents._();
  static final CallLogEvents instance = CallLogEvents._();
  void notifyCallLogged() => notifyListeners();
}
