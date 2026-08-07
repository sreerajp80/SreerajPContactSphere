# App lock: app PIN option and device-lock-removal handling

Implements plan
[plans/20260711_160627_app-lock-pin-and-device-lock-loss.md](../plans/20260711_160627_app-lock-pin-and-device-lock-loss.md).

## What changed

App lock used to be a single on/off switch that could only use the **device lock**
(fingerprint / face / device PIN). It now offers a choice of two protections and
handles the device lock going away.

### 1. Two lock modes
- Introduced `enum LockMode { none, deviceLock, appPin }` and replaced the old
  `appLockEnabled` boolean throughout `AppSettings`.
- **Device lock** — the original behavior (unchanged): unlock with the device
  credential via `local_auth`.
- **App PIN** — a new, separate 4–6 digit PIN kept by the app. It works even when
  the device has **no** screen lock, closing the gap where such users couldn't
  protect the app at all.

### 2. App PIN storage and recovery
- New `AppPinService` stores the PIN **only as a salted SHA‑256 hash** in the
  Keystore-backed `flutter_secure_storage` (same store as the DB key) — the raw
  PIN is never persisted. Verification is a length-guarded constant-time compare.
- At setup the app generates a **10-character recovery code** (from an
  unambiguous alphabet), shown once for the user to save. Its salted hash is
  stored alongside the PIN. On the lock screen, **"Forgot PIN?"** accepts the
  recovery code, clears the PIN, turns App lock off, and lets the user in so they
  can set a new PIN.

### 3. Device lock removed after being chosen
- The launch/resume gate in `main.dart` now reads the `LockMode`. If mode is
  `deviceLock` but the device can no longer authenticate (the user removed their
  screen lock), the app **does not trap the user**: it turns App lock off
  (`setLockMode(none)`) and shows a one-time warning dialog explaining the app is
  now unprotected. App-PIN mode does not depend on device auth, so it is unaffected.

### 4. Backward compatibility
- On load and in the static launch-gate reader, an old install's legacy
  `app_lock_enabled == true` is migrated to `LockMode.deviceLock`, so existing
  users stay locked with no action needed.

### 5. UI
- The Settings "App lock" card is now a chooser (bottom sheet: Off / Device lock /
  App PIN) instead of a switch; the subtitle shows the current mode. "Device lock"
  is disabled when no device screen lock exists; "App PIN" is always available and
  launches PIN setup the first time it's picked. All new UI (numeric keypad, PIN
  dots, setup screen) is built from the app's own `AppColors` design tokens.

## Files

- `lib/state/app_settings.dart` — `LockMode` enum; `_lockMode` field, `lockMode`
  getter, `appLockEnabled` convenience getter; `setLockMode` / static `readLockMode`;
  load-time migration from the legacy boolean.
- `lib/services/app_pin_service.dart` — **new**: PIN + recovery-code hashing,
  verify, clear.
- `lib/widgets/pin_keypad.dart` — **new**: reusable `PinDots` + `PinKeypad`.
- `lib/screens/app_pin_setup_screen.dart` — **new**: enter/confirm PIN, then show
  the recovery code.
- `lib/screens/app_lock_screen.dart` — split into device-credential unlock (as
  before) and app-PIN unlock (keypad + recovery-code dialog); takes a `LockMode`.
- `lib/screens/settings_screen.dart` — `_AppLockCard` reworked into the mode
  chooser (`_LockModeSheet`).
- `lib/main.dart` — mode-aware `_maybeLock`; new `_disableLockAndWarn` for the
  device-lock-removed case.
- `test/app_pin_service_test.dart` — **new**: 5 tests (set/verify, no-plaintext,
  recovery-code normalization, clear, re-setup) with an in-memory fake of the
  secure-storage channel.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/app_pin_service_test.dart` — all 5 tests pass.
- Manual on-device check still recommended: (a) set an App PIN with no device lock,
  relaunch, unlock; (b) enable Device lock, remove the device screen lock, relaunch
  → app opens, App lock shows Off, warning appears once; (c) Forgot PIN → recovery
  code path.
