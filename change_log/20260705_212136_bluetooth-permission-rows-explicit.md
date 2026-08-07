# Bluetooth permission rows moved to the Explicit section

Implements: `plans/20260705_212136_bluetooth-permission-rows-explicit.md`

## What changed

`lib/constants/app_permissions.dart` (only file touched):

- Moved the `Bluetooth Scan`, `Bluetooth Connect`, and `Bluetooth Advertise` entries
  from the Implicit block to the end of the Explicit block, and changed their `group`
  to `PermissionGroup.explicit`. On Android 12+ these are runtime "Nearby devices"
  permissions, so the OS reports them as denied until granted — showing that status
  under a "no separate prompt" header looked like a bug.
- Added a short note to each of the three `reason` texts: the prompt appears the
  first time Bluetooth sharing is used.
- Updated the file-top doc comment, which used "some Bluetooth entries" as an example
  of implicit permissions.

`lib/screens/permissions_screen.dart` needed no change; the grouping and section
subtitles now read correctly. The Implicit section is left with only rows that show
the neutral "System" text (Default phone app, Bluetooth legacy, Internet), so no red
"Denied" badges remain there.

## Verification

- `flutter analyze lib/constants/app_permissions.dart lib/screens/permissions_screen.dart`
  — no issues found.
- Not run on a device in this session; the change is a static catalogue regrouping
  with no logic changes. To confirm visually: open the Permissions screen — the three
  Bluetooth rows now sit under Explicit with their live status chips.
