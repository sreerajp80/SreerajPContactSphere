# Change log — Permissions-screen row for the proximity wake lock

Implements plan
[plans/20260710_221658_permissions-screen-wakelock-row.md](../plans/20260710_221658_permissions-screen-wakelock-row.md).

## What was changed

### `lib/constants/app_permissions.dart`
- Added one `AppPermission` row to `kAppPermissions`, in the **Implicit**
  section (after "Default phone app"):
  - **title:** "Screen off near ear"
  - **reason:** "Turns the screen off while you hold the phone to your ear during
    a call, so your cheek can't tap the controls."
  - **icon:** `Icons.screen_lock_portrait_outlined`
  - **group:** `PermissionGroup.implicit`
  - **handle:** none (normal permission, auto-granted at install, no runtime prompt)

This surfaces the previously-added `WAKE_LOCK` manifest permission on the in-app
Settings → Permissions screen for transparency. Display only — no behavior change.

## Verification done
- `flutter analyze lib/constants/app_permissions.dart` → No issues found
  (confirms the icon name resolves and the file is clean).
