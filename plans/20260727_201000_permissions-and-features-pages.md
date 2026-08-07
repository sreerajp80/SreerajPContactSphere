# Plan: Reorganize Permissions Page into Explicit/Implicit Groups & Create Settings -> Features Page

## Context & Goal
The user requested two specific updates to Settings:
1. Ensure the **Settings -> Permissions** page lists all app permissions grouped into **Explicit** (runtime prompted / system role) and **Implicit** (manifest declared / auto-granted at install) permissions.
2. Create a new **Settings -> Features** page. Add a Features card on the Settings screen that navigates to this page, which lists all features of ContactSphere.

---

## 1. Files to Change / Create

### A. [lib/core/constants/app_permissions.dart](file:///l:/Android/SreerajPContactSphere/lib/core/constants/app_permissions.dart)
- Simplify `PermissionGroup` enum to `explicit` and `implicit`.
- Categorize `Default phone app` under `PermissionGroup.explicit` (since it requires runtime user selection/prompt).
- Add any missing manifest implicit permission entries (e.g. `Foreground Service & Audio/Vibration` covering `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_PHONE_CALL`, `VIBRATE`, `USE_FULL_SCREEN_INTENT`).
- Ensure all permissions declared in `AndroidManifest.xml` are accurately represented.

### B. [lib/screens/permissions_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/permissions_screen.dart)
- Update grouping logic to group `kAppPermissions` strictly into `Explicit` and `Implicit`.
- Render section headers for `Explicit` ("Runtime permissions and system roles requiring user interaction") and `Implicit` ("Declared in manifest; granted automatically by system at install").

### C. [lib/screens/features_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/features_screen.dart) [NEW]
- Implement `FeaturesScreen` widget with rich styling matching the app theme design.
- Structure features into comprehensive categories:
  1. **Smart T9 Dialer & In-Call Experience** (T9 search, default dialer controls, top contacts).
  2. **Relationship Context & Notes** (In-call caller context, relationship tagging, notes & callbacks).
  3. **Contact Management & Privacy** (Device sync, secret contacts with biometric/PIN protection).
  4. **P2P Sync & Offline Backup** (Encrypted local Wi-Fi transfer, offline backup & restore).
  5. **Call Screening & Spam Protection** (Native call screening service, spam & unknown caller filtering).
  6. **QR & Bluetooth Contact Exchange** (vCard QR generation/scanning, nearby BLE discovery).
  7. **Personalization & SIM Settings** (Light/dark themes, multi-SIM handling, custom ringtones & vibration).

### D. [lib/screens/settings_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/settings_screen.dart)
- Import `FeaturesScreen`.
- Add a `_SettingsCard` for **Features** in the list view (with `Icons.stars_outlined` icon, title "Features", and subtitle "Explore all features of ContactSphere").

---

## 2. Verification Plan
- Run `flutter analyze` to ensure zero static errors or warnings.
- Run `flutter test` to ensure existing tests pass cleanly.
