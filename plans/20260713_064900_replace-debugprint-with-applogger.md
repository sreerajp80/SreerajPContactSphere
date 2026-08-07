# Replace `debugPrint` with `AppLogger` in committed code

**Status:** completed

## The issue

The engineering standard (`flutter_project_engineering_standard.md`) bans `print` and
`debugPrint` in committed code:

- §14.3: "`debugPrint` MAY be used for quick investigative logging but MUST NOT be committed.
  Use `AppLogger.debug()` for committed debug logs. The `avoid_print` lint catches `print`
  but NOT `debugPrint`; treat both as banned in committed code."
- §22.2: "Always use `AppLogger` (or the project's logging service), never `print` or `debugPrint`."

A scan of `lib/` finds **36 `debugPrint` calls across 10 files** (0 bare `print`). All of them
are failure logs inside `catch` blocks, except one version-drift diagnostic. The project already
has a complete `AppLogger` at `lib/core/logging/app_logger.dart` (with the §14 level taxonomy,
flavor-gated output, and file rotation), so this is a mechanical migration to the existing
logger — no new abstraction is introduced.

## Files to change (10)

Each service adds `import '../core/logging/app_logger.dart';` (config_service uses
`'../logging/app_logger.dart';`). Where `flutter/foundation.dart` was imported **only** for
`debugPrint`, that import is removed; where it also supplies other symbols it stays.

| File | Calls | Maps to | `foundation` import |
|---|---|---|---|
| `lib/core/config/config_service.dart` | 1 | `AppLogger.warning` (version/build drift note) | keep (`kDebugMode`) |
| `lib/services/app_pin_service.dart` | 3 | `AppLogger.error(error: e)` | remove (debugPrint only) |
| `lib/services/auth_service.dart` | 2 | `AppLogger.error(error: e)` | remove (debugPrint only) |
| `lib/services/call_log_import_service.dart` | 1 | `AppLogger.error(error: e, stackTrace: st)` | remove (debugPrint only) |
| `lib/services/permission_service.dart` | 2 | `AppLogger.error(error: e, stackTrace: st)` | remove (debugPrint only) |
| `lib/services/connected_apps_service.dart` | 2 | `AppLogger.error(error: e, stackTrace: st)` | keep (`Uint8List`) |
| `lib/services/device_contact_service.dart` | 11 | `AppLogger.error(error: e, stackTrace: st)` | keep (`Uint8List`) |
| `lib/services/telecom_service.dart` | 11 | `AppLogger.error(error: e, stackTrace: st)` | keep (`TargetPlatform`, `@visibleForTesting`, `kIsWeb`) |
| `lib/services/contact_sync_service.dart` | 1 | `AppLogger.error(error: e, stackTrace: st)` | keep (`@visibleForTesting`) |
| `lib/services/speech_service.dart` | 2 | `AppLogger.error(error: e, stackTrace: st)` | keep (`VoidCallback`) |

## The plan for the fix

1. **Conversion pattern.** Each call keeps its human-readable operation label as the message and
   moves the exception/stack out of string interpolation into structured arguments, satisfying
   §14.3 ("All `error`/`fatal` logs MUST include an `error` object and a `stackTrace` when
   available"):
   - `catch (e) { debugPrint('X failed: $e'); }` → `AppLogger.error('X failed', error: e);`
   - `catch (e, st) { debugPrint('X failed: $e\n$st'); }`
     → `AppLogger.error('X failed', error: e, stackTrace: st);`
   - The one drift note in `config_service.dart` (`if (mismatch && kDebugMode)`) becomes
     `AppLogger.warning('...')`. It stays inside the existing `kDebugMode` guard (leaving that
     guard untouched keeps the change minimal; it is not part of this task's scope).

   All caught failures map to `error` level: they carry an exception object (and usually a stack),
   which is the level §14.5 expects for "full error class, message, and stack".

2. **Imports.** Add the `AppLogger` import to each file. Remove `flutter/foundation.dart` from the
   four files where it was there solely for `debugPrint` (app_pin, auth, call_log_import,
   permission). Keep it in the rest per the table above.

3. **Verify.** Run `flutter analyze` to confirm: zero remaining `debugPrint`/`print`, no unused or
   unnecessary imports, no new warnings. (If analyze flags `unnecessary_import` on a kept
   `foundation` line because `services.dart` already re-exports `Uint8List`, drop that import too.)
   Then `grep` the tree to confirm no `debugPrint(`/`print(` remain in `lib/`.

## Out of scope

- No changes to the native/Kotlin `println`/`Log` calls (this task is the Dart standard §14.3).
- No re-leveling of individual catches into `warning` vs `error` beyond the single drift note; a
  uniform `error` mapping is the defensible default and avoids subjective per-site judgement.
- No changes to `AppLogger` itself (already complete) or to the `main()` init sequence.
