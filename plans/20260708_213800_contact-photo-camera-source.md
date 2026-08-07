# Add camera as a source for the contact profile photo

**Status:** completed

## The issue

On the Add / Edit contact screen, tapping the round avatar ("Add photo for
contacts") only ever opens the gallery. There is no way to take a new photo
with the camera.

Root cause is in [lib/screens/add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart):

- `_pickPhoto()` (line 463) hard-codes `_picker.pickImage(source: ImageSource.gallery)`.
  It never offers the camera. So gallery works, camera is simply not an option.
- The calling-card picker `_pickCardPhoto()` (line 477) *does* offer a
  Camera / Gallery bottom sheet, but it launches the camera **without first
  requesting the runtime CAMERA permission**. Because `android.permission.CAMERA`
  is declared in the manifest (AndroidManifest.xml line 32), Android's
  `image_picker` requires that runtime permission to be granted before it will
  open the camera. Without an explicit request the capture can silently fail or
  throw. So the same camera gap affects the calling card too.

## Files to change

1. **lib/screens/add_edit_contact_screen.dart** — main fix.
2. **lib/services/permission_service.dart** — add a small `ensureCamera()` helper.
3. **lib/constants/app_permissions.dart** — add a "Camera" row so the Permissions
   screen honestly lists the already-declared CAMERA permission.

## The plan for the fix

### 1. add_edit_contact_screen.dart

- Add imports:
  - `package:permission_handler/permission_handler.dart` (for `Permission.camera`)
  - `../services/permission_service.dart`
- Extract the Camera / Gallery chooser bottom sheet (currently inline in
  `_pickCardPhoto`) into a shared helper:
  `Future<ImageSource?> _chooseImageSource()`.
- Rewrite `_pickPhoto()` to:
  1. call `_chooseImageSource()`;
  2. if the user picks Camera, request the CAMERA runtime permission via
     `PermissionService().ensureCamera()`; if denied, show a short message and
     stop;
  3. `pickImage(source: chosen)`;
  4. persist the picked/captured file into `<appDocuments>/contact_photos/`
     (camera captures land in an evictable cache, so copy it to a stable path,
     mirroring the calling-card handling), then set `_photoPath`.
- Generalise the existing `_persistCardPhoto(sourcePath)` into
  `_persistPhoto(sourcePath, subDir, prefix)` (or add a sibling
  `_persistContactPhoto`) so both the contact photo (`contact_photos/`, prefix
  `photo_`) and calling card (`card_photos/`, prefix `card_`) reuse one copy
  routine. Keep the best-effort fallback to the original path on copy failure.
- Update `_pickCardPhoto()` to use `_chooseImageSource()` and to request the
  CAMERA permission before a camera capture (same gate as above), fixing the
  latent camera bug there too.

### 2. permission_service.dart

- Add `Future<bool> ensureCamera() => ensure(Permission.camera);` next to the
  existing `ensureMicrophone()` / `ensureLocation()` helpers.

### 3. app_permissions.dart

- Add an explicit-group `AppPermission` row for Camera
  (`Permission.camera`, `Icons.photo_camera_outlined`, reason: "Take a new photo
  for a contact or calling card.") so the Permissions screen reflects the
  CAMERA permission that is already in the manifest.

## Testing

- `flutter analyze` on the changed files.
- Manual: open Add contact → tap avatar → choose Camera → grant permission →
  capture → photo shows and saves. Repeat with Gallery to confirm no
  regression. Repeat the calling-card picker.

## Notes

- No schema, model, or DB change — `_photoPath` continues to hold a file path.
- No new dependency; `permission_handler` and `image_picker` are already used.
