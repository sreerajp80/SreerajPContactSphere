# Fix: "Authentication required to sync your data" — biometric never prompts

Implements plan `plans/20260708_191054_sync-auth-fragmentactivity.md`.

## What was wrong

Tapping **Settings → Sync to Another Device** showed the snackbar
"Authentication required to sync your data" with no biometric prompt. The Sync hub
is gated by `AuthService().authenticate(...)`, which wraps the `local_auth` plugin
and returns `false` on any error. `local_auth`'s `BiometricPrompt` requires the host
activity to be a `FragmentActivity`, but `MainActivity` extended `FlutterActivity`,
so `authenticate()` threw `PlatformException("no_fragment_activity", ...)` before any
dialog could appear. The caught error became a `false` result and the snackbar. The
same gate also blocked secret-contact access.

## What changed

`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`:

- Import changed from `io.flutter.embedding.android.FlutterActivity` to
  `io.flutter.embedding.android.FlutterFragmentActivity`.
- Class declaration changed from
  `class MainActivity : FlutterActivity(), CallRegistry.Listener` to
  `class MainActivity : FlutterFragmentActivity(), CallRegistry.Listener`.

No other changes. `FlutterFragmentActivity` is a drop-in replacement; the
default-dialer role flow, show-when-locked handling, method/event channels, and
`onActivityResult` are unaffected.

## Effect

On devices with a lock (biometric or PIN) set up, the system authentication prompt
now appears when opening the Sync hub and when accessing secret contacts. On
successful unlock the destination opens. Devices with no lock still fail closed
(the snackbar), which is the intended behavior.
