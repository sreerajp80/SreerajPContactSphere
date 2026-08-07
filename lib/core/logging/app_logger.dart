// lib/core/logging/app_logger.dart
//
// The app's single logging entry point. See engineering standard §14 (Logging).
//
// Level taxonomy (§14.1): trace < debug < info < warning < error < fatal.
// - Dev builds log everything (Level.trace) to the console.
// - Prod builds log info and above, to both the console and a rotated file in the
//   cache directory (so a support build can be inspected without a debugger).
// `trace`/`debug` therefore produce no output in prod (§14.3).
//
// Rotation (§14.4): the `logger` package's FileOutput never rotates, so we do it
// as a startup rename task in [init] — cap the active file at 5 MB and keep at
// most 3 rolled-over files (app.1.log … app.3.log) before the oldest is dropped.
//
// Pre-init tolerance: [init] is async (it needs the cache dir), so a log call can
// arrive before it finishes — most likely from the global error boundaries, which
// are installed first (see lib/core/errors/error_handlers.dart). Until the backing
// Logger exists, calls fall back to `dart:developer log` instead of throwing a
// LateInitializationError.

import 'dart:developer' as developer;
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:smart_contacts_dialer/core/config/app_flavor_config.dart';

class AppLogger {
  AppLogger._();

  static Logger? _logger;

  /// Active log file size cap before rotation (§14.4).
  static const int _maxLogBytes = 5 * 1024 * 1024; // 5 MB

  /// How many rolled-over files to keep (app.1.log … app.3.log).
  static const int _keptRotations = 3;

  /// Configure the logger. Call once during `main()` startup (§4.5 step 6),
  /// before app code logs. Safe to call even if the file setup fails: it falls
  /// back to a console-only logger so logging still works.
  static Future<void> init() async {
    final dev = AppFlavorConfig.instance.isDev;
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final logFile = File(p.join(cacheDir.path, 'app.log'));
      await _rotateIfNeeded(logFile);

      _logger = Logger(
        level: dev ? Level.trace : Level.info,
        printer: PrettyPrinter(
          colors: dev,
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
        output: dev
            ? ConsoleOutput()
            : MultiOutput([ConsoleOutput(), FileOutput(file: logFile)]),
      );
    } catch (e, s) {
      // File output unavailable (no cache dir, permissions, etc.): don't lose
      // logging entirely — fall back to console only.
      _logger = Logger(
        level: dev ? Level.trace : Level.info,
        printer: PrettyPrinter(printEmojis: false),
        output: ConsoleOutput(),
      );
      _logger!.e('AppLogger file output setup failed', error: e, stackTrace: s);
    }
  }

  /// Renames the active log to `app.1.log`, shifting older files up and dropping
  /// the oldest beyond [_keptRotations], once the active file passes the size
  /// cap. Best-effort — any failure leaves the current file in place.
  static Future<void> _rotateIfNeeded(File logFile) async {
    if (!await logFile.exists()) return;
    if (await logFile.length() < _maxLogBytes) return;

    final dir = logFile.parent.path;
    // Drop the oldest, then shift app.(n-1).log -> app.n.log downward.
    final oldest = File(p.join(dir, 'app.$_keptRotations.log'));
    if (await oldest.exists()) await oldest.delete();
    for (var i = _keptRotations - 1; i >= 1; i--) {
      final from = File(p.join(dir, 'app.$i.log'));
      if (await from.exists()) {
        await from.rename(p.join(dir, 'app.${i + 1}.log'));
      }
    }
    await logFile.rename(p.join(dir, 'app.1.log'));
  }

  static void trace(String message) {
    final l = _logger;
    l == null ? _fallback(message, level: 500) : l.t(message);
  }

  static void debug(String message) {
    final l = _logger;
    l == null ? _fallback(message, level: 700) : l.d(message);
  }

  static void info(String message) {
    final l = _logger;
    l == null ? _fallback(message, level: 800) : l.i(message);
  }

  static void warning(String message, {Object? error}) {
    final l = _logger;
    l == null
        ? _fallback(message, level: 900, error: error)
        : l.w(message, error: error);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    final l = _logger;
    l == null
        ? _fallback(message, level: 1000, error: error, stackTrace: stackTrace)
        : l.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    final l = _logger;
    l == null
        ? _fallback(message, level: 1200, error: error, stackTrace: stackTrace)
        : l.f(message, error: error, stackTrace: stackTrace);
  }

  /// Used before [init] completes: route to `dart:developer` so nothing is lost
  /// and no LateInitializationError is thrown.
  static void _fallback(
    String message, {
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'AppLogger',
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
