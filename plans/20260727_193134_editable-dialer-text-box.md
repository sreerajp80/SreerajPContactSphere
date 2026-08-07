# Editable Dialer Text Box with Inline Editing and Long-Press Copy/Paste

## Problem Statement
The dialer currently uses a static `Text` widget inside a `GestureDetector`. Users cannot:
- Place a cursor between digits to edit numbers in the middle.
- Long-press to open the native copy/paste context menu directly on the text.
- Select specific ranges of digits to copy or replace.

## Target Audience & Use Case
Users who dial or edit long phone numbers (e.g. inserting country codes, fixing typos in middle digits, or copying/pasting partial phone numbers).

## Proposed Solution
Replace the static `Text` display in `DialerScreen` with an interactive `TextField`:
1. Use `TextEditingController` and `FocusNode` in `DialerScreenState`.
2. Configure `TextField` with `keyboardType: TextInputType.none` and `showCursor: true` so the system QWERTY keyboard never pops up over the dialpad.
3. Update dialpad button presses (`_press`) and backspace (`_backspace`) to perform cursor-aware insertions and deletions instead of appending/deleting strictly at the end.
4. Support native context menu (Copy, Paste, Cut, Select All) on long-press/double-tap.
5. Clean up pasted text to ensure only dial-safe characters (`0-9+*#,;`) are inserted.

## Files to Modify
- `lib/screens/dialer_screen.dart`:
  - Add `_numberController` and `_numberFocusNode`.
  - Update `_press()` to insert digits at cursor/selection.
  - Update `_backspace()` to delete text at cursor/selection.
  - Update `_clear()`, `_pasteNumber()`, and `_selectSuggestion()` for controller sync.
  - Replace `GestureDetector(child: Text(_number))` in `_numberDisplay` with `TextField`.

## Verification Plan
1. Run `flutter analyze` to ensure zero static lints or syntax errors.
2. Run `flutter test` to verify existing tests pass.
3. Verify manually on device/emulator:
   - Tap between digits: cursor positions correctly.
   - Tap dialpad keys: digits insert at cursor position.
   - Tap backspace: deletes digit before cursor or clears active selection.
   - Long-press field: opens native context menu with Copy and Paste.
   - System soft keyboard does not pop up when tapping text box.
