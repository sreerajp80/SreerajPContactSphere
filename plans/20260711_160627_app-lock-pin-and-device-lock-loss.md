# App lock: add app PIN option and handle device-lock removal

**Status:** completed

## The issue

Today "App lock" (Settings → App lock) has a single on/off switch and can only use
the **device lock** (fingerprint / face / device PIN) through `local_auth`. Two gaps:

1. There is no way to use a **separate app-only PIN**. If the user has no device
   screen lock, the switch is disabled and they cannot protect the app at all.
2. If the user enabled the lock with the device lock and **later removes the device
   screen lock**, the lock silently fails open (`main.dart:309`) and the setting
   stays "on" forever. The user is never told the app is now unprotected.

### Desired behaviour (from the user)

- App lock offers **two choices**: use the **device lock**, or set a **specific
  app-lock PIN** (works even with no device lock).
- If **device lock** was chosen and the device lock is later removed:
  - the app still opens (does not trap the user), **and**
  - the app-lock setting is **turned off automatically**, **and**
  - a **warning** is shown the next time the app is opened.

## Design decisions (please confirm at approval)

- **Lock mode** replaces the boolean. A `LockMode` enum: `none`, `deviceLock`,
  `appPin`. The two modes are mutually exclusive (a picker, not a fallback chain),
  matching "either… or…".
- **Backward compatibility**: the existing `app_lock_enabled == true` is read once
  and migrated to `deviceLock`; `false`/absent → `none`. The old key is then left
  alone (harmless) and the new `app_lock_mode` key is authoritative.
- **PIN**: 4–6 digit numeric. Stored **only as a salted SHA‑256 hash** (random
  16‑byte salt) via `flutter_secure_storage` (Keystore-backed, same store as the DB
  key) — never in plaintext, never in SharedPreferences. Uses the already-present
  `cryptography` package (`Sha256`) for hashing.
- **App-PIN unlock UI**: in `appPin` mode the lock screen shows an in-app numeric
  keypad instead of the OS auth prompt. Wrong PIN shakes / clears; there is no
  "forgot PIN" reset in this pass (a lost app PIN means turning the lock off from a
  device that is already unlocked is impossible — see Open question below).
- **Design**: new PIN entry / keypad follows this app's own design system
  (`AppColors`, existing card/button styles), not a Google clone.

## Files to change

- **`lib/state/app_settings.dart`**
  - Add `enum LockMode { none, deviceLock, appPin }`.
  - Replace the `_appLockEnabled` bool with `_lockMode` (keep a
    `bool get appLockEnabled => _lockMode != LockMode.none` convenience getter).
  - New key `app_lock_mode`; migrate the old `app_lock_enabled` bool on load.
  - `setLockMode(LockMode)` (persists) replacing `setAppLockEnabled`.
  - Static `readLockMode()` for the launch gate (replaces `readAppLockEnabled`).
  - A transient `lockLostWarning` flag (see main.dart change) surfaced to the shell.

- **`lib/services/app_pin_service.dart`** (new)
  - `setPin(String)`, `verifyPin(String)`, `hasPin()`, `clearPin()`.
  - Salted SHA‑256 hash + salt stored in `flutter_secure_storage`.

- **`lib/screens/app_lock_screen.dart`**
  - Branch on mode: `deviceLock` keeps current `AuthService` flow; `appPin` shows the
    new numeric keypad and verifies via `AppPinService`.

- **`lib/screens/app_pin_setup_screen.dart`** (new)
  - Enter new PIN + confirm; saves via `AppPinService`. Used when choosing App PIN.

- **`lib/screens/settings_screen.dart`** (`_AppLockCard`)
  - Turn the single switch into a mode picker (e.g. tapping opens a small chooser:
    Off / Device lock / App PIN). Choosing App PIN pushes the setup screen; only
    commits `appPin` once a PIN is saved. "Device lock" stays disabled when no device
    lock exists (existing behaviour), but "App PIN" is always available.

- **`lib/main.dart`** (`_maybeLock`, ~285–327)
  - Read `LockMode` instead of the bool.
  - `deviceLock` + `!AuthService().isAvailable` → set mode to `none`, raise the
    `lockLostWarning` flag, and open the app (current fail-open, now recorded).
  - `appPin` → always show the lock (does not depend on device auth availability).

- **`lib/screens/home_shell.dart`** (or wherever the first screen builds)
  - After launch, if `lockLostWarning` is set, show a one-time warning dialog/snackbar
    ("Device lock was removed, so App lock has been turned off") and clear the flag.

- **Help**: brief note in the app-lock / biometrics help screen if one references the
  old single-switch behaviour (`lib/screens/help/biometrics_help_screen.dart`).

## Test / verify plan

- `flutter analyze` clean.
- Unit test for `AppPinService`: set → verify correct/incorrect → clear (host VM;
  may need the secure-storage mock, otherwise gate like other Keystore tests).
- Manual on device: (a) set App PIN with no device lock, relaunch, unlock with PIN;
  (b) enable Device lock, remove device screen lock, relaunch → app opens, setting
  shows Off, warning appears once.

## Forgot-PIN recovery — DECIDED: recovery code (option c)

At App-PIN setup the app generates a **longer random recovery code** (e.g. a
10-char alphanumeric code shown once). Its salted SHA‑256 hash is stored alongside
the PIN hash in `flutter_secure_storage`. On the unlock screen a "Forgot PIN?"
action lets the user enter the recovery code; a correct code clears the PIN (turns
App lock off) and lets them in, so they can set a new PIN from Settings. The user is
told to write the code down at setup.

## Warning delivery (refinement)

The device-lock-removed warning is shown **inline from `main.dart`'s lock gate**
(a dialog via `_navKey`), not through `home_shell` — simpler and self-contained,
so no home_shell change is needed.
