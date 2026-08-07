# Add a Permissions-screen row for the proximity wake lock

**Status:** completed

## Issue
The previous change added the `WAKE_LOCK` permission to the AndroidManifest (for
the in-call proximity screen-off), but the in-app Permissions screen catalogue in
`lib/constants/app_permissions.dart` was not updated. For transparency the user
wants this behavior listed.

## Fix
Add one new `AppPermission` row to the `kAppPermissions` list in
`lib/constants/app_permissions.dart`, in the **Implicit** section (it is a normal
Android permission — auto-granted at install, no runtime prompt, so `handle` is
left null like the other implicit rows).

Proposed row:
- **title:** "Screen off near ear"
- **reason:** "Turns the screen off while you hold the phone to your ear during a
  call, so your cheek can't tap the controls."
- **icon:** `Icons.screen_lock_portrait_outlined` (a screen-related icon already
  in Material; will confirm it resolves, else fall back to `Icons.phone_in_talk_outlined`).
- **group:** `PermissionGroup.implicit`
- **handle:** none

## Files to change
- `lib/constants/app_permissions.dart` — add the one row (placed with the other
  implicit rows, after "Default phone app").

## Notes
- No manifest change (already done in the prior plan).
- No behavior change — display only.

## Testing
- `flutter analyze` stays clean.
- The row appears under Settings → Permissions in the implicit group.
