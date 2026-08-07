# Plan: Warn instead of block when device has no screen lock (Sync)

**Status:** completed

## The issue

Tapping **Settings → Sync to Another Device** on a phone with **no screen lock**
(no biometric and no PIN/pattern/password) shows the snackbar
"Authentication required to sync your data" and never opens the Sync hub.

Why: `_openSync` in [settings_screen.dart](../lib/screens/settings_screen.dart)
calls `AuthService().authenticate(...)`. That method first checks
`_auth.isDeviceSupported()` ([auth_service.dart:34](../lib/services/auth_service.dart#L34)),
which returns `false` when the device has no lock at all. The code then "fails
closed": it denies access and shows the snackbar. On a lock-less device there is
**no way past the gate**, so sync is completely unusable.

The gate exists because the sync payload can include secret contacts, so it is
treated like secret-contact access. We want to keep that protection when a lock
exists, but stop trapping users who have no lock.

## The fix (option 3: warn, don't block)

Change `_openSync` so it distinguishes two cases:

1. **Device has a lock** (`AuthService().isAvailable` is `true`) — behave exactly
   as today: call `authenticate(...)`, open the Sync hub on success, show the
   existing snackbar on failure/cancel.
2. **Device has no lock** (`isAvailable` is `false`) — instead of the snackbar,
   show a warning `AlertDialog`:
   - Title: "No screen lock"
   - Body: "Your device has no screen lock, so synced data can't be protected by
     authentication. This may include secret contacts. Continue anyway?"
   - Actions: **Cancel** (default, does nothing) and **Continue** (opens the
     Sync hub).

   Only if the user taps **Continue** do we push `SyncHomeScreen`.

This keeps the authentication requirement intact on secured devices, and gives
lock-less devices an informed way through instead of a dead end.

### Notes on implementation

- Use `AuthService().isAvailable` (already exists,
  [auth_service.dart:16](../lib/services/auth_service.dart#L16)) to detect the
  no-lock case, rather than inferring it from an `authenticate()` failure — a
  `false` from `authenticate()` on a secured device means the user cancelled or
  failed, which should still be denied.
- The dialog follows the app's existing `AlertDialog` + `TextButton` confirm
  pattern (see `_confirmDelete` in
  [contact_list_screen.dart:364](../lib/screens/contact_list_screen.dart#L364)).
- Capture `Navigator`/`ScaffoldMessenger` before the `await`s (as the current
  code already does) to avoid using `BuildContext` across async gaps.
- No change to `AuthService`; its fail-closed default stays correct for the
  secret-contacts caller.

## Files to change

- `lib/screens/settings_screen.dart` — rewrite `_openSync(...)` to add the
  no-lock branch with the warning dialog. (Only this method changes.)

## Testing

- Manual: on a device/emulator with **no** lock, tap Sync → expect the warning
  dialog; Continue opens the hub, Cancel does nothing.
- Manual: on a device **with** a lock, tap Sync → expect the system auth prompt
  as before; success opens the hub, cancel shows the existing snackbar.
- `flutter analyze` clean for the edited file.

## Out of scope

- Any change to what the sync payload contains, or to secret-contact gating
  elsewhere.
