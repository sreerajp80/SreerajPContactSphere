# Implementation Plan: Group Settings Sections into Cards and Sub-Pages

**Date/Time:** 2026-08-07 20:29:12
**Plan File:** `plans/20260807_202912_group_settings_into_cards_and_subpages.md`

## Issue Description
Currently, several settings screens (most notably `SIM & calling`, `Contacts`, `Ringtone`, `Appearance`, and `Security`) club multiple inline controls (switches, text fields, lists, color pickers, and range pickers) directly onto a single long page. This creates a cluttered visual layout and poor visual hierarchy.

## Proposed Fix
Restructure each major Settings hub screen so that settings options are grouped into clean, modern **Section Cards** with icons, titles, subtitles, and chevron indicators. Tapping on a Section Card opens a dedicated, uncluttered **Sub-Page** for that specific group of settings.

---

## Detailed Plan by Component

### 1. SIM & Calling Settings (`lib/screens/sim_settings_screen.dart`)
Transform `SimSettingsScreen` into a clean card hub with the following section cards:
- **Default Phone App Card**: System default dialer card.
- **SIM Cards & Accounts Card** → Navigates to `SimPreferencesScreen` (Default SIM selector, Ask before each call toggle, per-SIM colour picker).
- **Caller Identification & Spam Card** → Navigates to `IdentificationSettingsScreen`.
- **Spoken Caller Announcements Card** → Navigates to `SpokenAnnouncementsScreen` (Spoken announcement toggle, quiet-hours exception toggle & range picker, announcement voice test dialog).
- **Relationship Quiet Hours Card** → Navigates to `RelationshipQuietHoursScreen` (Relationship quiet hours toggle, time range picker, allowed relationship tiers filter chips, allowed numbers counter).
- **Quick Replies Card** → Navigates to `QuickRepliesScreen`.
- **Post-Call Feedback Card** → Navigates to `PostCallFeedbackScreen` (Ask after calls toggle).
- **Smart Redial & "Reach Me" Card** → Navigates to `SmartRedialSettingsScreen` (Smart Redial toggle, default retry delay picker, preset reach-me message editor, active scheduled redials launcher).

### 2. Contacts Settings (`lib/screens/contacts_settings_screen.dart`)
Transform `ContactsSettingsScreen` into a clean card hub:
- **Contact Overview & Index Health Card** → Navigates to `ContactIndexHealthScreen` (Device vs App counts summary, search index health status, and 1-tap search index rebuild button).
- **My Profile ("Add Me") Card** → Navigates to `AddEditContactScreen` (self contact mode).
- **Display & Formatting Card** → Navigates to `ContactDisplaySettingsScreen` (Sort order choice, Name display format, Hide contacts without phone numbers toggle).
- **Device & Cloud Sync Card** → Navigates to `ContactSyncSettingsScreen`.
- **Custom Relationship Labels Card** → Navigates to `RelationshipNamesScreen`.
- **Blocked Numbers Card** → Navigates to `BlockedNumbersScreen`.
- **Secret Contacts & Export Card** → Navigates to `SecretContactsExportScreen` (Include secret contacts in export toggle, export secret contacts trigger).

### 3. Ringtone Settings (`lib/screens/ringtone_settings_screen.dart`)
Transform `RingtoneSettingsScreen` into a clean card hub:
- **Volume & Vibration Card** → Navigates to `RingtoneVolumeVibrationScreen` (Ringtone volume slider, vibrate on incoming calls toggle).
- **Per-SIM Ringtones Card** → Navigates to `PerSimRingtoneScreen` (Per-SIM ringer picker, sound preview controls, default ringtone status).

### 4. Appearance Settings (`lib/screens/appearance_screen.dart`)
Transform `AppearanceScreen` into a clean card hub:
- **Theme Mode Card** → Navigates to `ThemeModeSettingsScreen` (Light / Dark / System mode selection with live theme preview).
- **Typography & Scale Card** → Navigates to `TypographySettingsScreen` (Font family selection cards, text scale size buttons).
- **Accent Color Card** → Navigates to `AccentColorSettingsScreen` (Accent color live preview pill, preset color swatches, full HSV hue wheel, brightness slider, reset button).

### 5. Security Settings (`lib/screens/security_screen.dart`)
Transform `SecurityScreen` into a clean card hub:
- **App Lock Card** → Navigates to `AppLockSetupScreen` or lock mode sheet.
- **Screenshot Guard Card** → Navigates to `ScreenshotGuardSettingsScreen` (Block screenshots toggle with privacy explanation).
- **Audit Log Card** → Navigates to `AuditLogScreen`.

---

## Files to Modify / Create

### Files to Modify:
- [lib/screens/sim_settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/sim_settings_screen.dart)
- [lib/screens/contacts_settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/contacts_settings_screen.dart)
- [lib/screens/ringtone_settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/ringtone_settings_screen.dart)
- [lib/screens/appearance_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/appearance_screen.dart)
- [lib/screens/security_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/security_screen.dart)

### Files to Create:
- `lib/screens/sim_preferences_screen.dart`
- `lib/screens/spoken_announcements_screen.dart`
- `lib/screens/relationship_quiet_hours_screen.dart`
- `lib/screens/post_call_feedback_screen.dart`
- `lib/screens/smart_redial_settings_screen.dart`
- `lib/screens/contact_index_health_screen.dart`
- `lib/screens/contact_display_settings_screen.dart`
- `lib/screens/secret_contacts_export_screen.dart`
- `lib/screens/ringtone_volume_vibration_screen.dart`
- `lib/screens/per_sim_ringtone_screen.dart`
- `lib/screens/theme_mode_settings_screen.dart`
- `lib/screens/typography_settings_screen.dart`
- `lib/screens/accent_color_settings_screen.dart`
- `lib/screens/screenshot_guard_settings_screen.dart`

---

## Verification Plan
1. Run `flutter analyze` to ensure zero compilation or lint errors.
2. Run `flutter test` to verify all test suites pass.
3. Build the APK (`flutter build apk --flavor prod --release`) to verify release build integrity.
