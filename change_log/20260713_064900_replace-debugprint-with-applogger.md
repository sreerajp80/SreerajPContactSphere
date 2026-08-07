# Change log — Replace `debugPrint` with `AppLogger`

Implements plan
[plans/20260713_064900_replace-debugprint-with-applogger.md](../plans/20260713_064900_replace-debugprint-with-applogger.md).

## What changed

Removed all `debugPrint` from committed Dart code and routed logging through the existing
`AppLogger` (`lib/core/logging/app_logger.dart`), satisfying engineering standard §14.3 and §22.2
("never `print` or `debugPrint`"). A scan found **36 `debugPrint` calls across 10 files** and
**0 bare `print`**.

### Conversion

- 35 catch-block failure logs became `AppLogger.error(...)`, moving the exception and stack out
  of string interpolation into structured `error:` / `stackTrace:` arguments (§14.3: error logs
  MUST carry an error object and a stack trace when available):
  - `catch (e, st) { debugPrint('X failed: $e\n$st'); }`
    → `AppLogger.error('X failed', error: e, stackTrace: st);`
  - `catch (e) { debugPrint('X failed: $e'); }` → `AppLogger.error('X failed', error: e);`
- 1 version/build drift note in `config_service.dart` became `AppLogger.warning(...)`, left inside
  its existing `kDebugMode` guard.

### Files changed (10)

| File | Calls | Import change |
|---|---|---|
| `lib/core/config/config_service.dart` | 1 → `warning` | added AppLogger; kept `foundation` (`kDebugMode`) |
| `lib/services/app_pin_service.dart` | 3 → `error` | added AppLogger; removed `foundation` |
| `lib/services/auth_service.dart` | 2 → `error` | added AppLogger; removed `foundation` |
| `lib/services/call_log_import_service.dart` | 1 → `error` | added AppLogger; removed `foundation` |
| `lib/services/permission_service.dart` | 2 → `error` | added AppLogger; removed `foundation` |
| `lib/services/connected_apps_service.dart` | 2 → `error` | added AppLogger; removed `foundation` (`Uint8List` comes from `services.dart`) |
| `lib/services/device_contact_service.dart` | 11 → `error` | added AppLogger; removed `foundation` (`Uint8List` comes from `services.dart`) |
| `lib/services/telecom_service.dart` | 11 → `error` | added AppLogger; kept `foundation` (`TargetPlatform`, `defaultTargetPlatform`, `kIsWeb`, `@visibleForTesting`) |
| `lib/services/contact_sync_service.dart` | 1 → `error` | added AppLogger; kept `foundation` (`@visibleForTesting`) |
| `lib/services/speech_service.dart` | 2 → `error` | added AppLogger; kept `foundation` (`VoidCallback`) |

`foundation` was dropped from six files: the four that imported it solely for `debugPrint`, plus
connected_apps and device_contact where `package:flutter/services.dart` already re-exports
`Uint8List` (the analyzer flagged the leftover import as unnecessary).

## Verification

- `grep -rn "debugPrint(|[^.]print("` over `lib/` → **NONE**.
- `dart format` applied to all 10 files.
- `flutter analyze lib` → **No issues found**.

## Not done (out of scope)

- Native Kotlin logging (`android/`) untouched — this task was the Dart §14.3 rule only.
- No re-leveling of individual catches beyond the one drift note; a uniform `error` mapping was
  used for all caught failures.
- `AppLogger` itself and the `main()` init sequence were already in place and unchanged.
