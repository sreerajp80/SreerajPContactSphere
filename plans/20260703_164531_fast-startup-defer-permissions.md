# Fast startup — stop blocking `runApp()` on permissions

**Status:** completed

## The issue

The app shows the native launch screen (the white Flutter logo) for several seconds
before any UI appears. For a dialer, that delay defeats the purpose — users open it to
call someone quickly.

The native launch screen stays up until Flutter paints its **first frame**. In
`lib/main.dart`, `main()` is `async` and `runApp()` is the *last* statement, sitting
behind:

```dart
await PermissionService().requestPermissions();   // line 25 — BLOCKS the first frame
unawaitedSyncFromDevice();                         // line 33
runApp(const SmartContactsApp());                  // line 35
```

`requestPermissions()` awaits a `permission_handler` platform-channel round trip for
`contacts` + `phone`. Until it returns (and on first run, until the user answers the OS
prompt), Flutter never renders — so the launch screen lingers. Everything the user needs
to place a call (the dialer UI) is already independent of that call; it just never gets a
chance to draw.

## The fix

Render the UI first, then request permissions and kick off the device sync **after** the
first frame, off the launch critical path.

- `main()` becomes synchronous work only: `ensureInitialized()` → `runApp()`.
- Move the permission request + `unawaitedSyncFromDevice()` into a post-first-frame
  bootstrap so they run once the UI is already visible. Requesting permissions after the
  UI is up is also better UX (the prompt appears over the app, not over a blank screen).
- Keep the existing safety: the permission request stays wrapped so it never throws, and
  the sync stays fire-and-forget (it already no-ops when permission is absent and re-checks
  the grant itself).

Behavior preserved: permissions are still requested at startup (just a beat later), and
the device sync still runs. No change to what gets requested or synced — only *when*,
relative to the first frame.

## Files to change

- `lib/main.dart` — make `main()` non-blocking; move permission request + sync into a
  post-first-frame bootstrap (e.g. `WidgetsBinding.instance.addPostFrameCallback` in the
  app's `initState`, or an un-awaited bootstrap call after `runApp`).

## Out of scope / notes

- Not changing `PermissionService` or `ContactSyncService` internals.
- The contact list already reads local summaries and will populate from the DB; a
  first-run empty-until-synced window is unchanged by this fix (it exists today too).
- No dependency or Gradle changes.

## Verification

- `flutter analyze` stays clean for `main.dart`.
- Launch on device: the app UI (HomeShell / dialer) appears effectively immediately;
  the permission prompt (first run) or a silent grant check follows over the visible UI.
