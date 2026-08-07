// lib/core/errors/error_handlers.dart
//
// Global error boundaries (engineering standard §11.1). Without these, an
// unhandled framework or async error in a release build crashes silently — a
// grey screen or a dead process, with nothing logged.
//
// [installGlobalErrorHandlers] wires the three boundaries every app must have:
//   1. FlutterError.onError            — errors inside the framework (build,
//                                        layout, paint, gesture callbacks).
//   2. PlatformDispatcher.onError      — uncaught async errors that escape the
//                                        widget tree (futures, timers, channels).
//   3. ErrorWidget.builder             — the widget shown in place of one that
//                                        failed to build; in release we swap the
//                                        raw red box for a neutral fallback.
//
// All three funnel through AppLogger so there is one place a crash reporter can
// later attach (§11.2). Install this early in main() — before AppLogger.init()
// is fine, since AppLogger tolerates being called before it is configured.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';

/// Wire up the global error boundaries. Call once, early in `main()`, before
/// `runApp`.
void installGlobalErrorHandlers() {
  // 1. Framework errors. In debug, keep Flutter's console dump (and the red
  //    error box via the default ErrorWidget) so developers see the full detail.
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (!kReleaseMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // 2. Uncaught async errors. Returning true tells the engine we handled it, so
  //    it does not tear the app down.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.error('Uncaught async error', error: error, stackTrace: stack);
    return true;
  };

  // 3. Build-phase fallback UI. In release, replace the raw error box (which can
  //    leak exception text and looks like a crash) with a neutral placeholder so
  //    one bad subtree does not hand the user a scary screen. In debug, keep the
  //    default so the red box with the stack stays visible.
  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) =>
        const _ErrorFallback();
  }
}

/// Neutral, theme-aware placeholder shown in release when a widget fails to
/// build. Deliberately minimal: no exception text, no controls that could fail
/// the same way.
class _ErrorFallback extends StatelessWidget {
  const _ErrorFallback();

  @override
  Widget build(BuildContext context) {
    // A ColorScheme may not be resolvable if the failure is high in the tree, so
    // fall back to plain, context-free colors.
    return const Material(
      color: Color(0xFF1C1B1F),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Something went wrong.\nPlease go back and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFE6E1E5), fontSize: 16),
          ),
        ),
      ),
    );
  }
}
