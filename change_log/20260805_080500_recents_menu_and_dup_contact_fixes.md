# Fix Recents copy/share menu, stale names, and duplicate contacts

Implements [plans/20260805_080000_recents_menu_and_dup_contact_fixes.md](../plans/20260805_080000_recents_menu_and_dup_contact_fixes.md).

## What changed

1. **`lib/screens/call_history_screen.dart`** — the long-press menu on a Recents entry now
   has "Copy number" and "Share number" options, next to the existing Block/Spam/Smart
   Redial/Remove items. Copy writes the number to the clipboard (same pattern as the contact
   detail screen); Share opens the system share sheet via `share_plus`.

2. **`lib/repositories/contact_repository.dart`** — added `relinkCallLogs(contactId,
   phoneNumbers)`. It finds any `call_logs` rows that are still unlinked
   (`contact_id IS NULL`) whose stored number matches one of the contact's numbers (same
   digit-normalizing / `PhoneNormalizer.sameNumber` check `findByFullNumber` already uses),
   and sets their `contact_id`. This is now called at the end of both `insertContact()` and
   `updateContact()`. This is the fix for two of the reported problems:
   - a contact added *after* a call was logged now gets linked back to that old call, so
     Recents shows the contact's name instead of the raw number, and
   - because Recents already reloads its list right after the "Add contact" screen closes,
     the name now shows up immediately with no extra UI change needed.

3. **`lib/screens/add_edit_contact_screen.dart`** — added `if (_saving) return;` at the very
   top of `_save()`. Previously, disabling the save button relied on a `setState` rebuild that
   only takes effect on the next frame; a few fast taps before that frame could each start
   their own `_save()` run, each writing a new contact — that is what produced the "same
   contact saved 3 times" bug. The guard makes `_save()` itself reentrancy-safe, not just the
   button.

## Verification

- `flutter analyze` on the three changed files: no issues found.
- `flutter test`: 3 pre-existing failures (`widget_test.dart`, and two tests in
  `contact_search_picker_sheet_test.dart`) also fail on `main` before this change (verified by
  stashing and re-running) — unrelated to this change, not introduced by it.
