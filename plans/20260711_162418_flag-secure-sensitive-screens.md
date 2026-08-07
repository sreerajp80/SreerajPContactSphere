# Add FLAG_SECURE to sensitive screens

**Status:** completed

## The issue

The app never sets Android's `WindowManager.LayoutParams.FLAG_SECURE`. The only
screen-capture guard today is `setRecentsScreenshotEnabled(...)`, and it is toggled
**only during calls** ([MainActivity.kt:415](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt#L415)).

That leaves sensitive UI unprotected:

- **Secret contacts** — when the user unlocks the secret list (the ★/lock toggle,
  `_showSecretContacts == true` in [contact_list_screen.dart](../lib/screens/contact_list_screen.dart)),
  those names/numbers can be screenshotted and show up as a live Recents / task-switcher
  thumbnail.
- **App-lock screen** — the lock overlay ([app_lock_screen.dart](../lib/screens/app_lock_screen.dart))
  can be screenshotted / captured in Recents too.

`FLAG_SECURE` is the right primitive: a window with it set is excluded from screenshots,
screen recording, and the Recents thumbnail, and blocks non-secure displays. It is a
**window-level** flag (one per Activity), so we manage it with a reason set, not a raw
on/off, because two independent screens can each want it.

## The plan

### 1. Native — expose a `setSecureFlag` method (MainActivity.kt)

Add one case to the existing `telecom` MethodChannel handler
([MainActivity.kt:124](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt#L124)):

```kotlin
"setSecureFlag" -> {
    val enabled = call.argument<Boolean>("enabled") ?: false
    runOnUiThread {
        if (enabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
    result.success(null)
}
```

Window flag changes must run on the UI thread, hence `runOnUiThread`. This is independent
of the existing in-call `setRecentsScreenshotEnabled` logic (no conflict — FLAG_SECURE
covers screenshots *and* Recents on its own).

### 2. Flutter — a small reason-counted secure-flag helper (new file)

New file `lib/services/screen_security_service.dart`:

```dart
import 'package:flutter/services.dart';

/// Toggles the Android window FLAG_SECURE (blocks screenshots, screen
/// recording and the Recents thumbnail). FLAG_SECURE is one flag for the whole
/// Activity window, so callers acquire/release it by a named reason; the flag
/// stays on until every reason is released.
class ScreenSecurity {
  ScreenSecurity._();

  static const MethodChannel _channel =
      MethodChannel('contact_sphere/telecom');
  static final Set<String> _reasons = <String>{};

  static Future<void> acquire(String reason) {
    _reasons.add(reason);
    return _apply();
  }

  static Future<void> release(String reason) {
    _reasons.remove(reason);
    return _apply();
  }

  static Future<void> _apply() async {
    try {
      await _channel.invokeMethod('setSecureFlag', {'enabled': _reasons.isNotEmpty});
    } on PlatformException {
      // Best-effort: never crash the UI over a window-flag toggle.
    }
  }
}
```

Reuses the existing `contact_sphere/telecom` channel (no new channel to register).

### 3. Flutter — protect the app-lock screen (app_lock_screen.dart)

Convert `AppLockScreen` from `StatelessWidget` to `StatefulWidget` so it can hold the
flag for its whole lifetime:

- `initState`: `ScreenSecurity.acquire('app_lock')`.
- `dispose`: `ScreenSecurity.release('app_lock')`.

Build output is unchanged (same `PopScope` + `Scaffold` + mode switch).

### 4. Flutter — protect the secret-contacts view (contact_list_screen.dart)

In `_toggleSecret()`:
- when turning the secret view **on** (after successful auth):
  `await ScreenSecurity.acquire('secret_contacts');`
- when turning it **off**: `await ScreenSecurity.release('secret_contacts');`

In `dispose()` add `ScreenSecurity.release('secret_contacts');` so leaving the screen
while secret contacts are shown does not leave the flag stuck on.

## Files to change

1. `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` — add the
   `setSecureFlag` channel case.
2. `lib/services/screen_security_service.dart` — **new** reason-counted helper.
3. `lib/screens/app_lock_screen.dart` — stateful; acquire/release `app_lock`.
4. `lib/screens/contact_list_screen.dart` — acquire/release `secret_contacts` in
   `_toggleSecret` and release in `dispose`.

## Notes / scope

- Scope is exactly what was asked: secret contacts view + app-lock screen. The general
  contact list (no secret contacts shown) is intentionally **not** made secure, so normal
  screenshots/Recents keep working.
- `WindowManager` is already imported in MainActivity.kt (used by `applyShowWhenLocked`).
- No behavior change to the existing in-call Recents logic.

## Verification

- `flutter analyze` clean on the changed Dart files.
- Manual: unlock secret contacts → try a screenshot / check Recents thumbnail (should be
  blocked/blank); toggle secret off → screenshots work again. Same check on the app-lock
  overlay.
