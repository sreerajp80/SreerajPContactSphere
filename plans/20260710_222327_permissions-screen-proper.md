# Make the Permissions screen proper (grouping, live status, tap-to-open)

**Status:** completed

## The issues

Looking at the current Permissions screen (`lib/screens/permissions_screen.dart`
driven by `lib/constants/app_permissions.dart`), four things are wrong or missing:

1. **"Default phone app" is in the wrong group and shows the wrong state.**
   It sits under **Implicit** with a grey "System" chip and the note "granted
   without a separate prompt." That is false — the user sets this **manually**
   in Android settings, and it is often *not* set. So the screen says it is
   auto-granted when the user actually has to go and choose it.

2. **"Biometrics" is in the wrong group.** It sits under **Explicit** ("asked at
   runtime") but shows "System". `USE_BIOMETRIC` is a normal permission that is
   granted at install with no runtime prompt (confirmed in the manifest), so it
   belongs under Implicit, not Explicit.

3. **The screen does not reflect the real state of everything.** The permission
   rows read live status from `permission_handler`, but the default-phone-app
   state (are we the default dialer right now?) is never read, so that row can
   never show the truth.

4. **Tapping a permission does nothing.** The rows are plain, non-interactive
   `ListTile`s. The user wants a tap to take them to the matching system page.

5. **Minor: the "Internet (debug only)" row is inaccurate.** The manifest
   declares `INTERNET` for real device-to-device (P2P) sync over local Wi-Fi in
   all builds, not just for debug hot-reload. The row text should say what it is
   actually for.

## Facts used for the grouping (from `AndroidManifest.xml`)

- **Explicit** = runtime "dangerous" permissions the OS prompts for: Contacts,
  Phone & Call Log, Microphone, Location, Notifications, Photos & Media, Camera,
  Bluetooth Scan / Connect / Advertise. (unchanged)
- **Set in Settings (new group)** = the **Default phone app** role. Not a prompt,
  not auto-granted; the user picks it in settings. Has a live yes/no state and a
  request action, both already wired in native code
  (`isDefaultDialer` / `requestDefaultDialer` in `MainActivity.kt`, exposed by
  `TelecomService`).
- **Implicit** = normal permissions granted automatically at install, no prompt:
  Biometrics (`USE_BIOMETRIC`), Screen off near ear (`WAKE_LOCK`),
  Bluetooth legacy (`BLUETOOTH`/`BLUETOOTH_ADMIN`, maxSdk 30), Internet & Wi-Fi
  (`INTERNET` + network/wifi state).

## The plan

No native (Kotlin) or manifest changes are needed — the default-dialer
status/request bridge already exists. All work is on the Dart side.

### 1. `lib/constants/app_permissions.dart`
- Add a third value to the group enum: `enum PermissionGroup { explicit, manual, implicit }`.
- Add one field to `AppPermission`: `final bool isDefaultDialerRole;`
  (default `false`) — marks the row whose live status/action comes from
  `TelecomService` (the default-dialer role) rather than `permission_handler`.
- **Move "Biometrics"** from the explicit block to the implicit block.
- **Move "Default phone app"** into the new `manual` group and set
  `isDefaultDialerRole: true`.
- **Fix the Internet row**: rename to "Internet & Wi-Fi" with a reason that
  describes the real P2P local-network sync (and that no internet server is
  contacted), keeping it in the implicit group.
- Update the file's top doc comment to describe the three groups.

### 2. `lib/screens/permissions_screen.dart`
- Import `../services/telecom_service.dart`.
- Add state `bool? _isDefaultDialer;`. In `_refresh()`, also call
  `TelecomService().isDefaultDialer()` and store it (guarded, best-effort).
- Split the list into three sections and render them in order: **Explicit**,
  **Chosen by you**, **Implicit**, each with a short, accurate subtitle:
  - Explicit: "Asked for at runtime before the feature works."
  - Set in Settings: "You set these yourself in Android settings — there is no
    pop-up prompt."
  - Implicit: "Declared in the manifest; granted automatically at install."
- Make every row tappable (`onTap` on the `ListTile`), with behavior:
  - **Default-dialer row**: if we are not the default dialer, call
    `TelecomService().requestDefaultDialer()` (fires the system role prompt);
    if we already are, call `openAppSettings()`. Then refresh.
  - **Explicit row (has a `permission_handler` handle)**: if the status is a
    plain "denied" (not yet decided / can still prompt), call `handle.request()`
    to show the OS dialog; otherwise (granted, limited, permanently denied,
    restricted) call `openAppSettings()` to open the app's system permission
    page. Then refresh. (Android has no per-permission deep link, so the app's
    system settings page is the correct "corresponding page".)
  - **Implicit row (no handle)**: call `openAppSettings()` (the app info /
    permissions page is the closest system page for an auto-granted permission).
- Status chip changes:
  - Default-dialer row shows a live chip: **"Default"** (green) when set,
    **"Not set"** (amber/red) when not, or a spinner while unknown/loading.
  - Explicit rows keep the existing Granted / Denied / Blocked chip.
  - Implicit rows keep the grey "System" chip.

### 3. Help section — new "Biometrics" topic
The Help hub (`lib/screens/help/help_home_screen.dart`) is a list of topic
cards, each opening a plain-English article screen (the only one today is
`P2PSyncHelpScreen`). Add a second topic that explains what biometrics is used
for in this app.

- **New file `lib/screens/help/biometrics_help_screen.dart`** — a
  `BiometricsHelpScreen` built with the same private `_Intro` / `_Section` /
  `_Bullet` / `_Footer` layout widgets used by `p2p_sync_help_screen.dart`
  (copied into this file, matching the existing style — those helpers are
  private to their file). Plain-English content covering:
  - What it is: the app asks for your fingerprint, face, or device PIN/pattern
    before showing or moving your most private data. It uses the phone's own
    lock — the app never sees or stores your fingerprint or face.
  - Where it is used (mirrors the real call sites in `AuthService`):
    - viewing your **secret contacts**,
    - **exporting** secret contacts,
    - opening the **Sync to Another Device** hub (a sync can include secret
      contacts).
  - If the phone has no fingerprint/face set up, it falls back to the device
    PIN/pattern; if the device has no lock at all, the check cannot protect
    anything.
  - A closing tip: set up a screen lock in Android settings to keep this
    protection working.
- **`lib/screens/help/help_home_screen.dart`** — add a second `_HelpTopicCard`
  (icon `Icons.fingerprint`, title "Biometric lock", subtitle e.g. "What the
  fingerprint / face check protects and where it is used.") that pushes
  `BiometricsHelpScreen`. Also update the file's top doc comment, which
  currently says the hub holds "a single topic".

## Why this approach

- A dedicated **"Set in Settings"** section with an honest subtitle directly fixes
  the user's confusion ("I have to set it manually") instead of hiding the role
  behind a misleading "System / granted without a prompt" label.
- Reading `isDefaultDialer()` on load makes the row finally tell the truth.
- Reusing the existing `requestDefaultDialer()` bridge means the tap actually
  drives the same system role prompt the Settings screen already uses — no new
  native code, no new permissions.
- For runtime permissions, request-when-undecided / open-settings-otherwise is
  the standard Android pattern and matches "take me to the system page" as
  closely as the platform allows (there is no single-permission deep link).

## Files to change
- `lib/constants/app_permissions.dart` — enum + field + regroup 2 rows + fix
  Internet row + doc comment.
- `lib/screens/permissions_screen.dart` — load dialer status, three sections,
  tappable rows, dialer chip.
- `lib/screens/help/biometrics_help_screen.dart` — new help article (created).
- `lib/screens/help/help_home_screen.dart` — add the Biometrics topic card.

## Checked, already present (no work needed)
- **Quick replies on the calling screen.** Verified this facility already
  exists: a ringing incoming call shows a **Reply** control
  (`lib/screens/in_call_screen.dart`, `_showReplySheet`) that lists the user's
  quick replies from *Settings → SIM & calling → Quick replies* plus a
  "Write your own…" option; choosing one declines the call and texts the caller
  via `TelecomService.rejectWithMessage`. A full manager screen
  (`lib/screens/quick_replies_screen.dart`) already exists too. Nothing to add.

## Testing
- `flutter analyze` stays clean.
- On device: open Settings → Permissions.
  - "Default phone app" appears under **Chosen by you** and shows **Not set**
    until chosen; tapping it opens the system default-dialer prompt; after
    setting, it shows **Default**.
  - "Biometrics" now appears under **Implicit**.
  - Tapping a granted explicit permission opens the app's system settings page;
    tapping an undecided one shows the OS permission dialog.
  - The Internet row reads as the P2P Wi-Fi sync permission.
```
