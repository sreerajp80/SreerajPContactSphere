# Fast startup — defer permissions off the launch critical path

Implements plan `plans/20260703_164531_fast-startup-defer-permissions.md`.

## Problem

The native launch screen (white Flutter logo) lingered for seconds before any UI
appeared. `main()` was `async` with `runApp()` as its last statement, sitting behind
`await PermissionService().requestPermissions()` — so Flutter never painted its first
frame until the contacts/phone permission platform-channel round trip returned.

## Change

`lib/main.dart`:

- Made `main()` synchronous: `WidgetsFlutterBinding.ensureInitialized()` → `runApp()`.
  Nothing now blocks the first frame.
- Added `_bootstrap()` in `_SmartContactsAppState`, scheduled via
  `WidgetsBinding.instance.addPostFrameCallback` in `initState`. It requests core
  permissions (still guarded, never throws) and then calls `unawaitedSyncFromDevice()` —
  both now run after the UI is visible.

No changes to `PermissionService`, `ContactSyncService`, dependencies, or Gradle. The set
of permissions requested and the sync behavior are unchanged — only *when* they run
relative to the first frame.

## Verification

- `flutter analyze lib/main.dart` → "No issues found!"
- Expected on-device: HomeShell/dialer appears effectively immediately; the permission
  prompt (first run) or a silent grant check now happens over the visible UI.
