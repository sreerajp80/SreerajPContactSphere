# Emergency info card on the lock screen

Implements [plans/20260730_093000_emergency-lockscreen-card.md](../plans/20260730_093000_emergency-lockscreen-card.md).

## What was added

A new **Settings → Emergency info** screen where the user fills in a small medical card
(blood group, allergies, medicines, conditions, address, notes, organ donor) and a list of
people to call. With the master switch on, a permanent "Emergency info" notification sits on
the lock screen; tapping it opens the card **without unlocking the phone**, and each person on
it has a **Call** button that dials straight away.

Android's own "Emergency information" page (behind the lock screen's Emergency button) belongs
to the system app and cannot be written to by a third-party app, so the feature uses its own
notification plus a `showWhenLocked` activity.

## Files

### New — Dart

- `lib/models/emergency_info.dart` — `EmergencyInfo`, `EmergencyContactEntry`, `EmergencyRow`.
  `toMirrorJson()` is the single choke point that decides what may leave the encrypted DB.
- `lib/repositories/emergency_info_repository.dart` — load/save (one transaction) plus
  `pushMirror` / `disable`.
- `lib/services/emergency_card_service.dart` — `contact_sphere/emergency` method channel
  wrapper (`publish`, `clear`); no-ops off Android.
- `lib/screens/emergency_info_screen.dart` — the edit screen: warning banner, master switch,
  medical fields each with their own "Show on lock screen" toggle, people picker (from contacts
  or typed by hand), and a preview of exactly what a stranger would see.
- `lib/screens/help/emergency_info_help_screen.dart` — plain-English help page.

### New — Android

- `EmergencyCardNotifier.kt` — stores the published card in its own SharedPreferences
  (`contact_sphere_emergency`) and posts/cancels a public, ongoing, LOW-importance notification.
- `EmergencyInfoActivity.kt` — draws the card over the keyguard (`showWhenLocked`,
  `turnScreenOn`, no keyguard dismissal). Reads only the published copy, never the DB. Dials via
  `ACTION_CALL`, falling back to `ACTION_DIAL` if `CALL_PHONE` is missing.
- `EmergencyBootReceiver.kt` — re-posts the notification after a reboot.

### Modified

- `lib/database/database_helper.dart` — schema 21 → 22. New `emergency_info` (single row) and
  `emergency_contacts` tables, created by `_ensureEmergencyTables`, which is both the v21→v22
  migration step and an `_onOpen` self-heal (same pattern as the existing column helpers).
- `lib/state/app_settings.dart` — pushes the mirror once on app load.
- `lib/screens/settings_screen.dart` — "Emergency info" tile.
- `lib/screens/help/help_home_screen.dart` — help topic link.
- `android/.../MainActivity.kt` — `contact_sphere/emergency` channel
  (`setEmergencyMirror`, `clearEmergencyMirror`).
- `android/app/src/main/AndroidManifest.xml` — `RECEIVE_BOOT_COMPLETED`; registers the activity
  (not exported, own task affinity, `excludeFromRecents`, `noHistory`) and the receiver.
- `lib/core/constants/app_permissions.dart` — a "Start after restart" row so the Permissions
  screen still matches the manifest.
- `lib/screens/features_screen.dart` — an "Emergency Info Card" entry.
- `docs/security.md` — two new rows in the sensitive-data inventory and a note explaining the
  plaintext lock-screen copy and the controls around it.
- `docs/architecture.md` — the new tables and an "Emergency card on the lock screen" section.

### New test

- `test/emergency_info_test.dart` — 13 tests over the mirror payload: off → nothing, empty →
  nothing, only switched-on fields published, blank fields skipped, contacts carry
  name/relation/number only (no contact id), hidden/incomplete contacts dropped, sort order
  kept, and map round-trips.

## Security notes

The lock-screen copy is **plaintext** — data readable on a locked phone cannot be protected by
that lock. This follows the already-approved missed-call name mirror pattern. Controls: off by
default, per-field opt-in enforced in one tested method, master record stays in SQLCipher,
turning it off wipes the copy and cancels the notification, file is app-private and still
covered by `allowBackup="false"`, and the edit screen warns the user in plain words. See
`docs/security.md` §4.

## Deviations from the plan

- **No XML layout or `strings.xml`.** The activity builds its views in Kotlin instead. The app
  has no AndroidX theme of its own, and `app_name` is generated per flavor via `resValue`, so a
  new `values/strings.xml` would have collided. Programmatic views keep the card free of theme
  and resource coupling.
- The card is **not included in backups or device-to-device sync** (the plan did not cover it).
  The tables are outside `SyncBundleService._allManagedTables`, so a restore leaves them alone
  rather than wiping them, but a new phone starts with an empty card. This is stated in the help
  page.

## Verification

- `flutter analyze` — no issues.
- `flutter test test/emergency_info_test.dart` — 13 passed.
- `flutter test` for the DB-touching suites, one file per run (`db_formal_name_column_test`,
  `db_sort_columns_test`, `db_search_index_test`, `backup_service_test`) — all passed, so the
  schema bump did not disturb the existing migrations or the backup version check.
- `flutter build apk --flavor dev --debug` — built `app-dev-debug.apk`, so the new Kotlin and
  the manifest entries compile. (One fix was needed on the way: a local named `text` in
  `EmergencyInfoActivity.contactRow` shadowed `Button.text`; renamed to `column`.)
- `flutter test test/widget_test.dart` and `test/features_screen_test.dart` — passed after the
  Settings / Features additions.
- **Not yet tested on a device.** The lock-screen behaviour (notification visibility, the card
  appearing without a PIN, dialling from the keyguard) needs a run on the phone.
