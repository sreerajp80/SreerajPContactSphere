# Plan: Ensure App Name is "SreerajP Contacts Sphere" Everywhere

**Timestamp:** 2026-08-20 07:53:30 (IST)  
**Goal:** Ensure the app name is consistently referenced as "SreerajP Contacts Sphere" (and "SreerajP Contacts Sphere Dev" for dev flavor) across UI text, dialogs, settings, help screens, error messages, and tests.

---

## Analysis & Current State

1. **Flavor & Build Configurations (Already set):**
   - `android/app/build.gradle.kts`:
     - prod: `resValue("string", "app_name", "SreerajP Contacts Sphere")`
     - dev: `resValue("string", "app_name", "SreerajP Contacts Sphere Dev")`
   - `lib/core/config/app_flavor_config.dart`:
     - prod: `'SreerajP Contacts Sphere'`
     - dev: `'SreerajP Contacts Sphere Dev'`
   - `assets/config/app_config.json`:
     - `"appName": "SreerajP Contacts Sphere"`
   - `lib/core/config/app_config.dart`:
     - `fallback.appName`: `'SreerajP Contacts Sphere'`

2. **User-Facing UI Strings & Tests referencing shorthand "ContactSphere":**
   The following files contain user-facing UI labels, help descriptions, snackbars, and dialog copy that refer to "ContactSphere" instead of the full app name "SreerajP Contacts Sphere":
   - `lib/widgets/default_dialer_card.dart`
   - `lib/widgets/ble_share_dialog.dart`
   - `lib/screens/sync/send_to_device_screen.dart`
   - `lib/screens/sync/receive_from_device_screen.dart`
   - `lib/screens/settings_screen.dart`
   - `lib/screens/qr_scan_screen.dart`
   - `lib/screens/identification_settings_screen.dart`
   - `lib/screens/help/t9_dialing_help_screen.dart`
   - `lib/screens/help/emergency_info_help_screen.dart`
   - `lib/screens/help/cloud_sync_help_screen.dart`
   - `lib/screens/help/biometrics_help_screen.dart`
   - `lib/screens/features_screen.dart`
   - `lib/screens/call_history_screen.dart`
   - `lib/screens/business_card_scan_screen.dart`
   - `lib/screens/blocked_numbers_screen.dart`
   - `lib/screens/ble_receive_screen.dart`
   - `lib/screens/backup/backup_restore_screen.dart`
   - `lib/screens/app_lock_screen.dart`
   - `lib/main.dart`
   - `lib/core/constants/app_permissions.dart`
   - `lib/services/backup_service.dart`
   - `test/features_screen_test.dart`

---

## Proposed Changes

### 1. Update UI Strings & Descriptions in `lib/`
Replace user-facing references from `ContactSphere` to `SreerajP Contacts Sphere`:

- [lib/widgets/default_dialer_card.dart](file:///l:/Android/SreerajPContactSphere/lib/widgets/default_dialer_card.dart):
  - `'ContactSphere handles your calls'` -> `'SreerajP Contacts Sphere handles your calls'`
  - `'Set ContactSphere as your default dialer'` -> `'Set SreerajP Contacts Sphere as your default dialer'`
- [lib/widgets/ble_share_dialog.dart](file:///l:/Android/SreerajPContactSphere/lib/widgets/ble_share_dialog.dart):
  - `'On the other phone, open ContactSphere and choose '` -> `'On the other phone, open SreerajP Contacts Sphere and choose '`
  - `'ContactSphere and try again.'` -> `'SreerajP Contacts Sphere and try again.'`
- [lib/screens/sync/send_to_device_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/sync/send_to_device_screen.dart):
  - `'Share this phone\'s ContactSphere data with another phone on '` -> `'Share this phone\'s SreerajP Contacts Sphere data with another phone on '`
- [lib/screens/sync/receive_from_device_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/sync/receive_from_device_screen.dart):
  - `'Not a ContactSphere pairing code'` -> `'Not a SreerajP Contacts Sphere pairing code'`
- [lib/screens/settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/settings_screen.dart):
  - `subtitle: 'Explore all features of ContactSphere'` -> `subtitle: 'Explore all features of SreerajP Contacts Sphere'`
- [lib/screens/qr_scan_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/qr_scan_screen.dart):
  - `'Allow Camera for ContactSphere in system settings '` -> `'Allow Camera for SreerajP Contacts Sphere in system settings '`
- [lib/screens/identification_settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/identification_settings_screen.dart):
  - `'anywhere. ContactSphere recognises registered telemarketing '` -> `'anywhere. SreerajP Contacts Sphere recognises registered telemarketing '`
  - `'Spam filtering needs ContactSphere to be your default phone '` -> `'Spam filtering needs SreerajP Contacts Sphere to be your default phone '`
- [lib/screens/help/t9_dialing_help_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/help/t9_dialing_help_screen.dart):
  - `'ContactSphere features a smart multi-script T9 dialpad. You can '` -> `'SreerajP Contacts Sphere features a smart multi-script T9 dialpad. You can '`
- [lib/screens/help/emergency_info_help_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/help/emergency_info_help_screen.dart):
  - `'ContactSphere uses its own notification instead.'` -> `'SreerajP Contacts Sphere uses its own notification instead.'`
  - `'Also check that notifications for ContactSphere are on, and '` -> `'Also check that notifications for SreerajP Contacts Sphere are on, and '`
  - `'The card is saved inside a password-protected ContactSphere '` -> `'The card is saved inside a password-protected SreerajP Contacts Sphere '`
- [lib/screens/help/cloud_sync_help_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/help/cloud_sync_help_screen.dart):
  - `'ContactSphere connects with Google, Microsoft, and CardDAV/WebDAV '` -> `'SreerajP Contacts Sphere connects with Google, Microsoft, and CardDAV/WebDAV '`
  - `'Secret Vault Contacts: contacts saved as Secret in ContactSphere are app-only and '` -> `'Secret Vault Contacts: contacts saved as Secret in SreerajP Contacts Sphere are app-only and '`
- [lib/screens/help/biometrics_help_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/help/biometrics_help_screen.dart):
  - `'ContactSphere can ask for your fingerprint or face before it shows '` -> `'SreerajP Contacts Sphere can ask for your fingerprint or face before it shows '`
  - `'The check is handled by Android, not by ContactSphere. The '` -> `'The check is handled by Android, not by SreerajP Contacts Sphere. The '`
- [lib/screens/features_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/features_screen.dart):
  - `'Discover nearby ContactSphere devices and send contacts over Bluetooth Low Energy.'` -> `'Discover nearby SreerajP Contacts Sphere devices and send contacts over Bluetooth Low Energy.'`
  - `'ContactSphere Features'` -> `'SreerajP Contacts Sphere Features'`
- [lib/screens/call_history_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/call_history_screen.dart):
  - `'This removes all logged calls from ContactSphere.'` -> `'This removes all logged calls from SreerajP Contacts Sphere.'`
- [lib/screens/business_card_scan_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/business_card_scan_screen.dart):
  - `'ContactSphere in system settings, or pick a photo instead.'` -> `'SreerajP Contacts Sphere in system settings, or pick a photo instead.'`
- [lib/screens/blocked_numbers_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/blocked_numbers_screen.dart):
  - `'ContactSphere is your default phone app and matches the '` -> `'SreerajP Contacts Sphere is your default phone app and matches the '`
- [lib/screens/ble_receive_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/ble_receive_screen.dart):
  - `'into ContactSphere and your phone contacts?'` -> `'into SreerajP Contacts Sphere and your phone contacts?'`
  - `'Nearby devices for ContactSphere and try again.'` -> `'Nearby devices for SreerajP Contacts Sphere and try again.'`
- [lib/screens/backup/backup_restore_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/backup/backup_restore_screen.dart):
  - `label: 'ContactSphere backup'` -> `label: 'SreerajP Contacts Sphere backup'`
- [lib/screens/app_lock_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/app_lock_screen.dart):
  - `reason: 'Unlock ContactSphere'` -> `reason: 'Unlock SreerajP Contacts Sphere'`
  - `'ContactSphere is locked'` -> `'SreerajP Contacts Sphere is locked'`
- [lib/main.dart](file:///l:/Android/SreerajPContactSphere/lib/main.dart):
  - `_showSnack('Contact details not found in ContactSphere.');` -> `_showSnack('Contact details not found in SreerajP Contacts Sphere.');`
  - `'into ContactSphere and your phone contacts?'` -> `'into SreerajP Contacts Sphere and your phone contacts?'`
- [lib/core/constants/app_permissions.dart](file:///l:/Android/SreerajPContactSphere/lib/core/constants/app_permissions.dart):
  - `'Become the system dialer so ContactSphere shows its own in-call '` -> `'Become the system dialer so SreerajP Contacts Sphere shows its own in-call '`
- [lib/services/backup_service.dart](file:///l:/Android/SreerajPContactSphere/lib/services/backup_service.dart):
  - `'This is not a ContactSphere backup file (or it was made by a newer app version).'` -> `'This is not a SreerajP Contacts Sphere backup file (or it was made by a newer app version).'`

### 2. Update Tests
- [test/features_screen_test.dart](file:///l:/Android/SreerajPContactSphere/test/features_screen_test.dart):
  - Update `find.text('ContactSphere Features')` -> `find.text('SreerajP Contacts Sphere Features')`.

---

## Verification Plan

1. Run `flutter analyze` to ensure zero static analysis or lint warnings.
2. Run `flutter test` to verify all unit and widget tests pass with the updated strings.
3. Build the APK to verify release build still succeeds:
   `flutter build apk --flavor prod --release --split-per-abi`
