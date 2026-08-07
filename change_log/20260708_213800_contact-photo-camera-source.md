# Contact profile photo can now be taken with the camera

Implements [plans/20260708_213800_contact-photo-camera-source.md](../plans/20260708_213800_contact-photo-camera-source.md).

## Problem

On the Add / Edit contact screen, tapping the avatar to add a photo only opened
the gallery. `_pickPhoto()` hard-coded `ImageSource.gallery`, so the camera was
never offered. The calling-card picker did offer the camera but launched it
without first requesting the runtime CAMERA permission (declared in the
manifest), so that capture could fail too.

## Changes

### lib/screens/add_edit_contact_screen.dart
- `_pickPhoto()` now shows a Camera / Gallery chooser, requests the CAMERA
  runtime permission when Camera is picked, and copies the picked/captured file
  into `<appDocuments>/contact_photos/` for a stable path.
- Extracted the shared chooser sheet into `_chooseImageSource()` and a camera
  permission gate into `_ensureCamera()`; both `_pickPhoto()` and
  `_pickCardPhoto()` use them, fixing the missing camera-permission request in
  the calling-card flow.
- Generalised `_persistCardPhoto()` into `_persistPhoto(sourcePath, subDir,
  prefix)`, reused for both the contact photo (`contact_photos/`, `photo_`) and
  the calling card (`card_photos/`, `card_`).

### lib/services/permission_service.dart
- Added `ensureCamera()` helper.

### lib/constants/app_permissions.dart
- Added a "Camera" row to the Permissions screen catalogue, reflecting the
  already-declared `android.permission.CAMERA`.

## Verification
- `flutter analyze` on the three changed files: no issues.

## Notes
- No schema, model, DB, or dependency change; `_photoPath` still holds a file
  path.
