# Clear Call History Confirmation Plan

## Issue
When clicking the "Clear history" button on the Recents screen, a confirmation dialog appears, but the action buttons currently read "Cancel" and "Clear" without setting the default focused action to "No". The requirement is for the confirmation dialog to present "No" as the default focused button option to prevent accidental history deletion.

## Proposed Changes

### `lib/screens/call_history_screen.dart`

Modify `_clear()` method's `AlertDialog`:
1. Update the action buttons to use "No" (with `autofocus: true`) and "Yes".
2. Setting `autofocus: true` on the "No" `TextButton` ensures it receives default focus when the confirmation dialog is displayed.
3. If dismissed or "No" is selected, `showDialog` returns `false` / `null` and no deletion takes place.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure static analysis passes.
- Run `flutter test` to ensure existing tests pass.

### Manual Verification
- Tap "Clear history" (trash button) on the Recents tab header.
- Confirm the dialog displays "Clear call history?" with buttons "No" (focused by default) and "Yes".
- Selecting "No" or dismissing cancels history deletion.
