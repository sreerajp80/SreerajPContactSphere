# Add FLAG_SECURE to sensitive screens

Implements plan [20260711_162418_flag-secure-sensitive-screens.md](../plans/20260711_162418_flag-secure-sensitive-screens.md).

## What changed

Sensitive UI is now excluded from screenshots, screen recording and the Recents /
task-switcher thumbnail via Android's window `FLAG_SECURE`. Previously the only
capture guard was `setRecentsScreenshotEnabled`, toggled only during calls.

### Native

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
  - Added a `setSecureFlag` case to the `contact_sphere/telecom` MethodChannel handler.
    It adds/clears `WindowManager.LayoutParams.FLAG_SECURE` on the UI thread
    (`runOnUiThread`) based on an `enabled` argument. Independent of the existing
    in-call Recents logic.

### Flutter

- `lib/services/screen_security_service.dart` (new)
  - `ScreenSecurity` helper with `acquire(reason)` / `release(reason)`. FLAG_SECURE is
    one flag for the whole Activity window, so it is reason-counted: the flag stays on
    until every reason is released. Reuses the existing `contact_sphere/telecom` channel;
    swallows `PlatformException` so a flag toggle can never crash the UI.

- `lib/screens/app_lock_screen.dart`
  - Converted `AppLockScreen` from `StatelessWidget` to `StatefulWidget`. Acquires the
    `app_lock` secure reason in `initState` and releases it in `dispose`, so the lock
    overlay is protected for its whole lifetime. Build output unchanged (now reads
    `widget.mode`).

- `lib/screens/contact_list_screen.dart`
  - `_toggleSecret()` acquires the `secret_contacts` reason when the secret view is
    turned on (after successful auth) and releases it when turned off.
  - `dispose()` releases `secret_contacts` if still held, so leaving the screen while
    secret contacts are shown never leaves the flag stuck on.

## Scope

Only the secret-contacts view and the app-lock screen are made secure. The normal
contact list (no secret contacts shown) stays capturable so ordinary screenshots keep
working.

## Verification

- `flutter analyze` on the three changed/added Dart files: **No issues found.**
- Manual on-device screenshot / Recents check of the two protected states is recommended
  (not run here).
