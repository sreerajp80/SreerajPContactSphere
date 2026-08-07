# Change log — Global error boundaries + AppLogger (§11.1 + §14)

Implements plan [plans/20260713_060000_global-error-boundaries.md](../plans/20260713_060000_global-error-boundaries.md).

## Why

The app had **no global error boundaries** (engineering standard §11.1): `main()`
went straight to `runApp` with no `FlutterError.onError`,
`PlatformDispatcher.instance.onError`, or `ErrorWidget.builder`. In release an
unhandled framework or async error crashed silently with nothing logged. §11.1's
boundaries must funnel to a logger, and the project had no `AppLogger`, so the
full §14 logging layer was built first and the boundaries wired on top.

## What changed

- **`pubspec.yaml`** — added `logger: ^2.4.0` under `dependencies`
  (`path`/`path_provider` were already present). Ran `flutter pub get`.

- **`lib/core/logging/app_logger.dart`** (new) — the standard §14 `AppLogger`,
  backed by the `logger` package:
  - Level gated by `AppFlavorConfig.instance.isDev` (matching the §14.2
    reference): dev → `Level.trace` + console; prod → `Level.info` + console and
    a file (`app.log`) in the app cache directory. `trace`/`debug` produce no
    output in prod (§14.3).
  - Static methods `trace`/`debug`/`info`/`warning`/`error`/`fatal`
    (`error`/`fatal` take `error` + `stackTrace`).
  - **Log rotation** (§14.4) as a startup task in `init()`: when `app.log` passes
    5 MB it rolls over to `app.1.log`, shifting older files up and keeping at most
    3 rotated files before dropping the oldest.
  - **Pre-init tolerance:** calls before `init()` completes fall back to
    `dart:developer log()` instead of throwing `LateInitializationError`. `init()`
    also degrades to console-only if the cache-dir/file setup fails, so logging is
    never lost.

- **`lib/core/errors/error_handlers.dart`** (new) — `installGlobalErrorHandlers()`
  wiring the three §11.1 boundaries, all funnelling through `AppLogger`:
  - `FlutterError.onError` → `AppLogger.error(...)`; in debug also
    `FlutterError.dumpErrorToConsole` (keeps the console dump / red box for devs).
  - `PlatformDispatcher.instance.onError` → `AppLogger.error(...)`, returns `true`
    to suppress the default crash.
  - `ErrorWidget.builder` → in **release**, a neutral theme-safe `_ErrorFallback`
    widget instead of the raw error box; in debug, the default is kept.

- **`lib/main.dart`** — `main` is now `Future<void> main() async`. It installs the
  boundaries **before** `AppLogger.init()` (so startup errors are captured via the
  pre-init fallback), awaits `AppLogger.init()` inside a `try/catch`, then
  `runApp`. Added imports for the two new files.

- **`docs/architecture.md`** — added a "Startup sequence, logging, and error
  boundaries" section recording the `main()` order and the log-rotation approach
  (§14.4 requires the rotation choice be documented).

## Deviations from the literal §11.1 sample

- Release "safe error screen" is delivered via `ErrorWidget.builder` (a neutral
  fallback widget), **not** a route pushed from inside `FlutterError.onError` —
  that has no `BuildContext` and is fragile. `onError` only logs.
- No `runZonedGuarded` wrapper: `PlatformDispatcher.instance.onError` is the
  Flutter-recommended replacement and covers uncaught async errors.

## Out of scope (not done)

- No crash-reporting SDK (Sentry/Crashlytics) — the single `AppLogger.error`
  funnel makes it a later drop-in.
- Existing scattered `debugPrint`/`developer.log` calls were **not** migrated to
  `AppLogger` — a separate cleanup.

## Verification

- `flutter analyze lib/core/logging/app_logger.dart lib/core/errors/error_handlers.dart lib/main.dart`
  — no issues.
- `flutter pub get` — resolved with `logger` added.
- `flutter test test/widget_test.dart` — app tree still builds (passes).
- Throwaway probe test (created, run, removed): confirmed both hooks are wired,
  the framework-error handler logs + dumps without throwing, the async handler
  returns `true`, and all six `AppLogger` levels are safe before `init()`.
