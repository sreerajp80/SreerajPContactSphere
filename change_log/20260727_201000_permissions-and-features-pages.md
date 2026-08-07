# Change Log: Group Permissions into Explicit/Implicit & Add Settings -> Features Page

**Date:** 2026-07-27
**Plan Implemented:** `plans/20260727_201000_permissions-and-features-pages.md`

## Summary of Changes

1. **Permission Grouping Update**:
   - Simplified `PermissionGroup` enum in `lib/core/constants/app_permissions.dart` to `explicit` and `implicit`.
   - Moved `Default phone app` into `PermissionGroup.explicit` (since setting/granting the default dialer role involves runtime OS dialog/setting user flow).
   - Added an implicit permission entry for `Foreground Call Service & Ringing` (`FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_PHONE_CALL`, `VIBRATE`, `USE_FULL_SCREEN_INTENT`) to cover all AndroidManifest.xml declared permissions.
   - Updated `lib/screens/permissions_screen.dart` to group and display permissions strictly in two sections: **Explicit** and **Implicit**.

2. **New Features Screen**:
   - Created `lib/screens/features_screen.dart` featuring dynamic, categorized cards detailing ContactSphere capabilities:
     - Smart Dialer & Call Management
     - Caller Context & Notes
     - Contact Sync & Privacy (Biometrics & PIN lock)
     - Sync & Backup (Wi-Fi P2P & encrypted JSON backups)
     - Call Screening & Defense (Spam/Unknown call blocking)
     - Contact Exchange (vCard QR codes & Bluetooth LE discovery)
     - Personalization & Audio (Themes, Dual-SIM routing & ringtones)

3. **Settings Screen Integration**:
   - Updated `lib/screens/settings_screen.dart` to include a **Features** settings card (`Icons.stars_outlined`) that navigates to `FeaturesScreen`.

## Verification
- `flutter analyze` completed with 0 errors/warnings.
- `flutter test` launched and verified.
