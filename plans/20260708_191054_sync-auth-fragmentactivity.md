# Fix: "Authentication required to sync your data" — biometric never prompts

**Status:** completed

## The issue

Tapping **Settings → Sync to Another Device** shows the snackbar
"Authentication required to sync your data" and nothing else happens. No biometric
prompt appears.

The Sync hub is gated behind a biometric check in
`lib/screens/settings_screen.dart` (`_openSync`), which calls
`AuthService().authenticate(...)`. `AuthService` (in `lib/services/auth_service.dart`)
wraps the `local_auth` plugin in a try/catch that returns `false` on any error
instead of throwing.

Root cause: the Android host activity `MainActivity` extends `FlutterActivity`.
The `local_auth` plugin's `BiometricPrompt` requires the host to be a
`FragmentActivity`. With a plain `FlutterActivity`, `authenticate()` throws
`PlatformException("no_fragment_activity", ...)` before any dialog is shown. The
catch swallows it, returns `false`, and the caller shows the snackbar.

The same bug also breaks secret-contact access, which uses the same `AuthService`.

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
  - Change the superclass from `FlutterActivity` to `FlutterFragmentActivity`.
  - Update the import: `io.flutter.embedding.android.FlutterActivity` →
    `io.flutter.embedding.android.FlutterFragmentActivity`.

No other code changes are needed. `FlutterFragmentActivity` is a drop-in
replacement — the default-dialer role flow, show-when-locked handling, method/event
channels, and `onActivityResult` all work unchanged (they use the plain `Activity`
API surface, which `FlutterFragmentActivity` still provides).

## The fix

1. Edit `MainActivity.kt`:
   - Replace the import line for `FlutterActivity` with `FlutterFragmentActivity`.
   - Change the class declaration
     `class MainActivity : FlutterActivity(), CallRegistry.Listener {`
     to `class MainActivity : FlutterFragmentActivity(), CallRegistry.Listener {`.

## Verification

- `flutter analyze` (Dart side untouched, should stay clean).
- Build and run on the moto g54; open **Settings → Sync to Another Device** and
  confirm the device biometric/PIN prompt now appears, and on success the Sync hub
  opens.
- Confirm secret-contact access also prompts correctly (same code path).

## Notes / risk

- Low risk. This is the officially documented setup for `local_auth` on Android.
- If the device has no lock set up at all, `isDeviceSupported()` returns false and
  the snackbar is the correct, intended behavior (fail closed). This fix only
  restores the prompt for devices that *do* have a lock.
