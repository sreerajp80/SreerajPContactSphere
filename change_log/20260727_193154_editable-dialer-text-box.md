# Editable Dialer Text Box with Cursor Placement & Native Copy/Paste

Implements [plans/20260727_193134_editable-dialer-text-box.md](../plans/20260727_193134_editable-dialer-text-box.md).

## Key Changes

### Dialer Screen (`lib/screens/dialer_screen.dart`)
- **Interactive `TextField` Display**: Replaced static `GestureDetector` + `Text` widget with a cursor-enabled `TextField` configured with `keyboardType: TextInputType.none` and `showCursor: true`.
- **System Keyboard Suppressed**: The system QWERTY keyboard never pops up over the T9 dialpad when the number display is tapped or focused.
- **Cursor Placement & Mid-String Editing**:
  - Users can tap anywhere within a typed number to place the cursor.
  - T9 keypresses (`_press`) insert digits at the active cursor position or replace an active selection range.
  - Backspace (`_backspace`) deletes the digit preceding the cursor or removes highlighted text.
- **Native Context Menu & Sanitized Input**:
  - Long-pressing the text box opens native system context menus for Copy, Paste, Cut, and Select All.
  - Added `FilteringTextInputFormatter.allow(RegExp(r'[0-9+*#,;]'))` to automatically sanitize pasted content to dial-safe characters.
- **Controller Lifecycle**: Integrated `TextEditingController` and `FocusNode` into state management with proper listener cleanup on `dispose()`.

## Verification Passed
- `flutter analyze`: 0 lints, 0 warnings.
- `flutter test`: 230/230 tests passed cleanly.
