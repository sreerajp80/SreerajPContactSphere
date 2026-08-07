// lib/core/utils/call_log_write_lock.dart
import 'dart:async';

/// Serialises the two paths that write Recents rows: the live logger
/// ([CallEventLogger], which writes when a call ends) and the device import
/// ([CallLogImportService], which pulls the system call log).
///
/// Both describe the same physical calls, so when they interleave each can miss
/// the row the other is about to write and Recents ends up with two rows for one
/// call. The real guarantee against that is the match-or-insert transaction in
/// [InteractionRepository.logCallIfNew]; this lock keeps the two passes from
/// racing in the first place, which also saves the redundant work.
///
/// Deliberately tiny: a single chained [Future], not a package. Holding it is
/// never long — a handful of local SQLite statements.
class CallLogWriteLock {
  CallLogWriteLock._();

  static Future<void> _tail = Future<void>.value();

  /// Runs [action] once every earlier holder has finished, and returns its
  /// result. A failure in [action] is passed to the caller but never poisons the
  /// queue — the next waiter still runs.
  static Future<T> run<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}
