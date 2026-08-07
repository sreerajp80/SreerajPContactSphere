# Change log — Make the Permissions screen proper

Implements plan
[plans/20260710_222327_permissions-screen-proper.md](../plans/20260710_222327_permissions-screen-proper.md).

## What was changed

### 1. `lib/constants/app_permissions.dart`
- Added a third group value: `enum PermissionGroup { explicit, manual, implicit }`.
- Added a field `final bool isDefaultDialerRole` (default `false`) to
  `AppPermission`, marking the one row whose live status/action comes from the
  default-dialer role (`TelecomService`) instead of `permission_handler`.
- **Moved "Default phone app"** into the new `manual` group and set
  `isDefaultDialerRole: true`; reworded its reason to say the user sets it in
  Android settings (no pop-up).
- **Moved "Biometrics"** from the explicit group to the implicit group
  (`USE_BIOMETRIC` is granted at install with no runtime prompt). Broadened its
  reason to mention it also guards exporting and syncing secret contacts.
- **Fixed the Internet row**: renamed "Internet (debug only)" →
  "Internet & Wi-Fi" with an accurate reason (local-Wi-Fi device-to-device
  sync; no internet server contacted). It stays in the implicit group.
- Updated the file's top doc comment to describe the three groups.

### 2. `lib/screens/permissions_screen.dart`
- Imported `TelecomService`; added a `_telecom` field and a nullable
  `_isDefaultDialer` state (null = first query still loading).
- `_refresh()` now also reads `TelecomService.isDefaultDialer()` (best-effort,
  false off Android / on error).
- The list is now rendered in three sections in order: **Explicit**,
  **Set in Settings**, **Implicit**, each with an accurate subtitle.
- Every row is now tappable (`onTap`):
  - Default-dialer row: opens the system role prompt
    (`requestDefaultDialer`) when not default, else opens app settings.
  - Explicit row (has a handle): shows the OS dialog when the status is a plain
    "denied" (still promptable), else opens the app's system settings page.
  - Implicit row (no handle): opens the app's system settings page.
  - After any action the screen refreshes so the chips reflect the new state.
- Status chips: the default-dialer row shows a live chip — a spinner while
  loading, then **Default** (green) / **Not set** (rose). Explicit rows keep the
  Granted / Denied / Blocked chip; implicit rows keep the grey "System" chip.
  Chip rendering was factored into a shared `_chip(label, color)` helper.

### 3. `lib/screens/help/biometrics_help_screen.dart` (new)
- New `BiometricsHelpScreen` help article, built with the same
  `_Intro` / `_Section` / `_Bullet` / `_Footer` layout as the P2P sync help
  page. Plain-English content: what the check is, where it is asked (viewing
  secret contacts, exporting them, opening Sync), what counts as "you"
  (fingerprint/face, falling back to the device PIN), the privacy note (handled
  by Android, works offline, biometric never leaves the phone), and a tip to set
  a screen lock.

### 4. `lib/screens/help/help_home_screen.dart`
- Added a second `_HelpTopicCard` ("Biometric lock", `Icons.fingerprint`) that
  opens `BiometricsHelpScreen`, with spacing between the two cards.
- Updated the top doc comment (it no longer holds "a single topic").

## Checked, no change needed
- **Quick replies on the calling screen.** Confirmed already implemented: a
  ringing call shows a **Reply** control (`in_call_screen.dart`,
  `_showReplySheet`) offering the user's quick replies plus "Write your own…",
  which declines the call and texts the caller via
  `TelecomService.rejectWithMessage`. A manager screen
  (`quick_replies_screen.dart`) already exists.

## Verification done
- `flutter analyze` on the four changed/created files: **No issues found**.

## Verification still needed (physical device — cannot be done here)
- Settings → Permissions:
  - "Default phone app" appears under **Set in Settings** and shows **Not set**
    until chosen; tapping opens the system default-dialer prompt; after setting
    it shows **Default**.
  - "Biometrics" now appears under **Implicit**.
  - Tapping an undecided explicit permission shows the OS dialog; tapping a
    granted/blocked one opens the app's system settings page.
- Settings → Help shows the new "Biometric lock" topic and it opens the article.
