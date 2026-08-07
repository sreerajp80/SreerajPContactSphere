# Plan: Global error boundaries + AppLogger (standard §11.1 + §14)

**Status:** completed

## Issue

The app has **no global error boundaries** (engineering standard §11.1).
[lib/main.dart:28](../lib/main.dart#L28) `main()` calls
`WidgetsFlutterBinding.ensureInitialized()` then goes straight to `runApp(...)`.
There is no `FlutterError.onError`, no `PlatformDispatcher.instance.onError`, and
no `ErrorWidget.builder`. In release, an unhandled framework or async error
crashes silently (grey screen / process death) with nothing logged.

§11.1's required boundaries funnel every error to `AppLogger.error(...)`, but the
project has **no `AppLogger`** — logging today is scattered `dart:developer log`
and `debugPrint` calls. Per the decision taken, we build the full §14 logger
first, then wire the §11.1 boundaries on top.

## Scope (decided)

Full **§14 logging** infrastructure **plus** the **§11.1** global error
boundaries. Adds one dependency (`logger`). `path` and `path_provider` are
already in `pubspec.yaml`.

## Files to change

1. **`pubspec.yaml`** — add `logger: ^2.4.0` under `dependencies`. Run
   `flutter pub get`.

2. **`lib/core/logging/app_logger.dart`** (new) — the §14.2 `AppLogger`, following
   the reference implementation:
   - `static Future<void> init()` — resolves the cache dir
     (`getApplicationCacheDirectory()`), runs a size-based **rotation** check
     (§14.4), then builds the `Logger`.
   - **Level gate uses `AppFlavorConfig.instance.isDev`** (which exists at
     [lib/core/config/app_flavor_config.dart](../lib/core/config/app_flavor_config.dart)
     and already exposes `isDev`/`enableVerboseLogging`) — matching the §14.2
     reference verbatim. Dev → `Level.trace` + `ConsoleOutput`; prod →
     `Level.info` + `MultiOutput([ConsoleOutput, FileOutput])`. `trace`/`debug`
     therefore produce no output in prod (§14.3).
   - Static methods per §14.2: `trace`, `debug`, `info`, `warning`, `error`,
     `fatal` (error/fatal take `error` + `stackTrace`).
   - **Pre-init tolerance:** if a log call happens before `init()` completes (e.g.
     an error thrown *during* init), fall back to `dart:developer log()` instead
     of throwing `LateInitializationError`. This matters because the error
     boundaries are the most likely thing to fire early.
   - **Rotation (§14.4):** max 5 MB per file, keep 3 rotated files
     (`app.log` → `app.1.log` → `app.2.log`, delete `app.3.log`), stored in the
     cache dir. Implemented as a startup rename task (the endorsed approach, since
     `logger`'s `FileOutput` does not rotate).

3. **`lib/core/errors/error_handlers.dart`** (new) — `installGlobalErrorHandlers()`
   wiring the three §11.1 boundaries:
   - `FlutterError.onError` → `AppLogger.error('Flutter framework error', ...)`;
     in debug also `FlutterError.dumpErrorToConsole(details)` (keeps the red
     screen / console dump for developers).
   - `PlatformDispatcher.instance.onError` → `AppLogger.error('Uncaught async
     error', ...)`, `return true` (suppresses the default crash).
   - `ErrorWidget.builder` → in **release**, a neutral, theme-safe fallback widget
     (centered short "Something went wrong" message) instead of the grey/red crash
     box; in **debug**, the default error widget is kept.
   - **Deviation from §11.1's `_showGlobalErrorScreen()`:** the sample shows a
     release error *screen*. Pushing a route from inside `FlutterError.onError`
     has no `BuildContext` and is fragile. The release-safe UI is delivered
     through `ErrorWidget.builder` instead (the correct mechanism for build-phase
     errors). `onError` only logs. Flagged here for your awareness.

4. **`lib/main.dart`** — make `main` async and install boundaries early:
   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     installGlobalErrorHandlers();      // active from the earliest point;
                                        // AppLogger falls back to dev.log pre-init
     try {
       await AppLogger.init();          // §4.5 step 6 — logging init
     } catch (_) {
       // Non-fatal: boundaries still log via the dev.log fallback.
     }
     runApp(const SmartContactsApp());
   }
   ```
   Boundaries are installed **before** `AppLogger.init()` so errors during init
   are also caught; `AppLogger`'s pre-init fallback makes that safe. `main.dart`
   stays thin (§3.2).

5. **`docs/architecture.md`** — add a short note recording the startup sequence
   (logging init → error boundaries → `runApp`) and the log-rotation approach, as
   §14.4 requires the rotation choice be documented.

## Not in scope

- No new crash-reporting SDK (Sentry/Crashlytics). The single `AppLogger.error`
  funnel makes that a later drop-in.
- Not migrating the existing scattered `debugPrint`/`developer.log` calls to
  `AppLogger` — that is a separate cleanup, not part of §11.1.
- No `runZonedGuarded` wrapper: `PlatformDispatcher.instance.onError` is the
  Flutter-recommended replacement and covers uncaught async errors.

## Verification

- `flutter analyze` clean on the new/changed files.
- `flutter pub get` succeeds with `logger` added.
- Manual: throw a test error in a build method (debug shows red box + logs;
  simulated release path shows the fallback widget) — remove the probe after.
