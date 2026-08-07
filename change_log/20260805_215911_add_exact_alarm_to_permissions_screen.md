# Add "Alarms & reminders" to the app's Permissions screen

Implements [plans/20260805_215821_add_exact_alarm_to_permissions_screen.md](../plans/20260805_215821_add_exact_alarm_to_permissions_screen.md).

## What changed

`lib/core/constants/app_permissions.dart`: added an "Alarms & reminders" row
to `kAppPermissions` (explicit group), using `permission_handler`'s
`Permission.scheduleExactAlarm` — the same mechanism every other row already
uses, so it gets live Granted/Denied status and the existing generic tap
handler (request if undecided, else open the settings screen) with no new
code in `permissions_screen.dart`.

## Verification

- `flutter analyze` — no issues.
- Not verified on-device in this session (user builds/installs themselves):
  please confirm the new row appears on Settings → Permissions and its
  status matches what you set via the Smart Redial prompt.
