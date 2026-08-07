# Add "Alarms & reminders" to the app's Permissions screen

**Status:** completed

## The issue

The new `SCHEDULE_EXACT_ALARM` permission Smart Redial needs isn't listed on
the app's own Permissions screen (`lib/core/constants/app_permissions.dart`
→ `permissions_screen.dart`) — the only place to grant it right now is the
one-off prompt added to the Smart Redial sheet when scheduling a reminder.

## Fix

Add one row to `kAppPermissions`, in the `explicit` group, using
`permission_handler`'s existing `Permission.scheduleExactAlarm` — the same
mechanism already used for every other row (Contacts, Notifications, etc.),
so it gets live Granted/Denied status and the existing generic tap handler
(request if undecided, else open settings) for free. No new plumbing needed.

## Files to change

- `lib/core/constants/app_permissions.dart`

## Verification

- `flutter analyze`.
- On your device: open Settings → Permissions and confirm the new
  "Alarms & reminders" row appears and its status matches whatever you set
  earlier via the Smart Redial prompt.
