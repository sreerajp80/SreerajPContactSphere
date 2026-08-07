# Plan: Fix Dialer Keypad Jumping When Typing

**File to modify:** `lib/screens/dialer_screen.dart`

## Issue Description
When typing in the dialer (`DialerScreen`), the dialpad (`_dialpad`) jumps up and down.
Currently, `_strip` (which displays Favorites, Top Contacts, search match suggestions, or the "Add to contacts" card) is wrapped in a `ConstrainedBox` with flexible `Spacer(flex: 3)` above `_dialpad` and `Spacer(flex: 2)` below `_callRow`.
Because `_strip` uses `shrinkWrap: true`, its rendered height changes dynamically based on the number of contact matches or cards present for the typed number. This constantly alters the leftover space distributed to `Spacer(flex: 3)`, pushing `_dialpad` up or down on every keystroke.

## Fix
1. Modify `build()` in `lib/screens/dialer_screen.dart`:
   - Replace `LayoutBuilder` and `ConstrainedBox` wrapping `_strip` with `Expanded(child: _strip(colors))`.
   - Remove `Spacer(flex: 3)` above `_dialpad` and `Spacer(flex: 2)` below `_callRow`.
   - Add fixed bottom padding (`const SizedBox(height: 12)`) below `_callRow`.
2. This ensures `_dialpad` and `_callRow` remain in a static, fixed position at the bottom of the screen.
3. The space between `_numberDisplay` and `_dialpad` becomes a fixed-size region managed by `Expanded`, so `_strip` content renders inside it without affecting the dialpad position. Any unused vertical space inside `_strip` remains as empty background space.

## Verification
- Run `flutter analyze` to check for any static lint issues.
- Run `flutter test` to ensure all tests pass.
- Verify layout stability on device/emulator.
