# Remove Paste & Backspace Icons from Dialer

Implements [plans/20260727_194933_remove-dialer-paste-backspace-icons.md](../plans/20260727_194933_remove-dialer-paste-backspace-icons.md).

## Key Changes

### Dialer Screen (`lib/screens/dialer_screen.dart`)
- **Removed Top Icons**: Removed the clipboard paste `IconButton` and backspace `IconButton` from `_numberDisplay`.
- **Removed Bottom Backspace Icons**: Removed the trailing backspace `IconButton`s from `_callRow` in both normal and modal/add-call modes.
- **Code Cleanup**:
  - Deleted `_pasteNumber()` method.
  - Deleted `_backspace()` method.
  - Removed unused `Clipboard` import from `flutter/services.dart`.
- **Layout Alignment**: Maintained symmetric 40px/44px spacers on left and right sides of `_numberDisplay` and `_callRow` to keep the interactive `TextField` and call button centered.

## Verification Passed
- `flutter analyze`: 0 lints, 0 warnings.
- `flutter test`: 230/230 tests passed cleanly.
