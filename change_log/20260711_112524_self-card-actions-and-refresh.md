# Self card: hide Call/Email actions & refresh list after Settings

Implements plan `plans/20260711_112524_self-card-actions-and-refresh.md`.

## What changed

`lib/screens/contact_list_screen.dart`:

1. **Self card action row.** The expanded quick-action row now branches on
   `contact.isSelf`. For the Self ("YOU") card it shows a single full-width
   **Profile** button only — Call, Email, and Delete are removed, since you can't
   call or email yourself. All other contacts keep the unchanged
   Call / Profile / Email / Delete row.

2. **Refresh after Settings.** The overflow-menu `'settings'` case now calls
   `_reload()` (guarded by `mounted`) after returning from `SettingsScreen`. This
   makes a Self record created via **Settings → Contacts → Add Me** appear
   immediately in the list, instead of only after toggling Favorites and back.

## Testing

- `flutter analyze lib/screens/contact_list_screen.dart` — no issues.
