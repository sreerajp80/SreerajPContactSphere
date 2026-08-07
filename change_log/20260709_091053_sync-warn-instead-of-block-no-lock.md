# Change: Warn instead of block Sync when device has no screen lock

Implements plan `plans/20260709_091053_sync-warn-instead-of-block-no-lock.md`.

## What was wrong

Tapping **Settings → Sync to Another Device** on a phone with **no screen lock**
(no biometric and no PIN/pattern/password) showed the snackbar "Authentication
required to sync your data" and never opened the Sync hub. The gate calls
`AuthService().authenticate(...)`, whose `isDeviceSupported()` check returns
`false` when there is no lock, so the code failed closed. On a lock-less device
there was no way past the gate, making sync completely unusable.

## What changed

`lib/screens/settings_screen.dart` — `_openSync(...)` now splits two cases:

- **Device has a lock** (`AuthService().isAvailable` is `true`): unchanged
  behaviour — call `authenticate(...)`, open the Sync hub on success, show the
  existing snackbar on cancel/failure.
- **Device has no lock** (`isAvailable` is `false`): show a warning
  `AlertDialog` titled "No screen lock" explaining that synced data (which may
  include secret contacts) can't be protected by authentication, with
  **Cancel** and **Continue** actions. The Sync hub opens only if the user taps
  **Continue**.

The no-lock case is detected via `AuthService().isAvailable` rather than by
inferring it from an `authenticate()` failure, so a cancelled/failed unlock on a
secured device is still denied. `AuthService` itself is unchanged; its
fail-closed default remains correct for the secret-contacts caller.

## Effect

- Secured devices: system authentication is still required to open Sync, exactly
  as before.
- Lock-less devices: instead of a dead end, the user gets an informed warning and
  can choose to continue.

## Verification

- `flutter analyze lib/screens/settings_screen.dart` — no issues.
- Manual UI testing of the two paths (with/without a device lock) recommended
  before release.
