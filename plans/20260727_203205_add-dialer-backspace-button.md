# Implementation Plan: Add Backspace / Delete Button to Dialer Screen

## Issue Overview
Users currently have to long-press the Call button or select text in the text box to delete numbers in the dialer. There is no dedicated single-tap Backspace (⌫) button on the dialpad to delete digits one-by-one.

## Proposed Changes

### [lib/screens/dialer_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/dialer_screen.dart)

1. **Add `_backspace()` method**:
   - Deletes selected text if there is an active selection in `_numberController`.
   - Otherwise, deletes the character preceding the current cursor position.
   - If cursor is at the end or offset is invalid, deletes the last character of `_number`.
   - Triggers state update and updates cursor position properly.

2. **Update `_callRow(AppColors colors)`**:
   - Replace the static right-hand spacing `SizedBox(width: 44)` with a Backspace `IconButton` (using `Icons.backspace_outlined`).
   - On tap: calls `_backspace()`.
   - On long press: calls `_clear()` to clear all entered digits.
   - When `_number` is empty, render a visually invisible/disabled `SizedBox(width: 44)` or faded disabled icon to maintain layout balance.

## Verification Plan

### Automated Verification
- Run `flutter analyze` to ensure no lint/syntax errors.

### Manual Verification
- Run app on Android device / emulator.
- Type digits using the T9 key pad (e.g. `2662`).
- Tap the Backspace button to delete digits one by one.
- Long-press the Backspace button to clear all digits.
