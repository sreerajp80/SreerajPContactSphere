# Plan: 5.9 Emergency card hand-off

## Issue
Feature 5.9 ("Emergency card hand-off — size S") in `docs/feature_analysis_and_roadmap.md` is candidate work that is not yet implemented. The ICE (In Case of Emergency) card cannot currently be shared directly to other apps or contacts.

## Proposed Fix
Implement ICE card hand-off using the system share sheet (`share_plus`) supporting both plain-text formatting and PNG image rendering.

1. **Create `lib/services/emergency_share_service.dart`**:
   - `formatAsText(EmergencyInfo info, List<EmergencyContactEntry> contacts)`: Builds a readable text summary of the owner's emergency information and emergency contacts.
   - `renderCardImage(EmergencyInfo info, List<EmergencyContactEntry> contacts)`: Paints a clean red/white styled ICE card onto a PNG canvas using `ui.PictureRecorder` and saves it to a temp file.
   - `shareText(...)`: Invokes `SharePlus.instance.share` with text content.
   - `shareImage(...)`: Invokes `SharePlus.instance.share` with the rendered PNG `XFile`.

2. **Update `lib/screens/emergency_info_screen.dart`**:
   - Add a Share action button to `AppBar` (`IconButton(icon: Icon(Icons.share))`).
   - Tapping Share presents a modal choice sheet: "Share as Text" or "Share as Card Image".

3. **Update `docs/feature_analysis_and_roadmap.md`**:
   - Mark Section 5.9 as `✅ Shipped.` and document the implementation.

## Files to create/modify
- `[NEW]` `lib/services/emergency_share_service.dart`
- `[MODIFY]` `lib/screens/emergency_info_screen.dart`
- `[MODIFY]` `docs/feature_analysis_and_roadmap.md`

## Verification
- Run `flutter analyze` to ensure zero lint errors.
- Run unit/widget tests with `flutter test`.
