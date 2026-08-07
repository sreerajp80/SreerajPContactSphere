# Fix Recents copy/share menu, stale names, and duplicate contacts

**Status:** completed

## Files to change

1. `lib/screens/call_history_screen.dart`
2. `lib/screens/add_edit_contact_screen.dart`
3. `lib/repositories/contact_repository.dart`

## The issues

The user reported four problems in the "Recents" (call log) screen:

1. Long-pressing a call entry shows a menu (Block, Mark as spam, Smart Redial, Remove from
   history) but there is no "Copy number" or "Share number" option.
2. Tapping an unknown number opens "Add contact". After saving, the new contact is not
   reflected back in Recents right away.
3. The same contact can end up saved three times from one "Add contact" attempt (see
   screenshot: the same "[name]" / "[phone]" row appearing 3 times).
4. After adding the contact, Recents keeps showing the raw number instead of the contact's
   name, even after a refresh.

## Root causes found

**1. Missing menu options.** `_showActions()` in `call_history_screen.dart` (around line
593-654) builds a fixed bottom-sheet menu. It has no entries for copying or sharing the
number. The app already uses `Clipboard` and `SharePlus` the same way elsewhere (see
`lib/screens/contact_detail_screen.dart`), so this is just missing UI, not a missing
capability.

**2 & 4. Recents never re-links to a contact added later (same root cause).**
`CallLogRepository.recentCalls()` shows a contact's name via a stored `call_logs.contact_id`
column. That column is set exactly once, at the moment the call is first logged, by
`CallEventLogger._resolveContactId()` — it looks up the number against contacts that already
exist *at that time*. If no contact exists yet, `contact_id` stays `NULL` forever. When the
user later adds a contact for that number, nothing goes back and fills in the old call log
rows' `contact_id`. So even though Recents does reload its list after the "Add contact"
screen closes, the query still returns `NULL` for that row — the raw number keeps showing.

**3. Duplicate contact on save.** `_save()` in `add_edit_contact_screen.dart` (line 968) sets
`_saving = true` and the checkmark button is `onTap: _saving ? null : _save`. But `_save()`
itself has no guard against being re-entered, and disabling the button only takes effect
after the next frame is drawn. Because `_save()` does real async work (writing to the phone's
own contacts app via `ContactSyncService.saveContact()`), a few taps in quick succession can
each start their own `_save()` run before the button visually disables — and
`ContactRepository.insertContact()` always inserts unconditionally, with no check for "this
exact contact was just inserted a moment ago." Three taps -> three contacts.

## The fix

**1. Add "Copy number" and "Share number" to the Recents long-press menu**
(`call_history_screen.dart`):
- Add two more `ListTile`s to the bottom sheet in `_showActions()`, next to the existing
  ones, using the number already available at the top of that method (`call.phoneNumber`).
- "Copy number" writes the number to the clipboard via `Clipboard.setData` (same pattern as
  `contact_detail_screen.dart`) and shows a short confirmation snackbar.
- "Share number" opens the system share sheet via `SharePlus.instance.share(...)` (same
  package/pattern already used elsewhere in the app — `share_plus` is already a dependency).

**2 & 4. Re-link existing call history when a matching contact is saved**
(`contact_repository.dart`, `call_history_screen.dart` needs no change beyond what already
reloads):
- Add a new method `relinkCallLogs(contactId, phoneNumbers)` to `ContactRepository`. For each
  of the contact's phone numbers, it finds `call_logs` rows that are still unlinked
  (`contact_id IS NULL`) and whose stored number matches (using the same digit-normalizing /
  `PhoneNormalizer.sameNumber` comparison `findByFullNumber` already uses, so it's consistent
  with how the rest of the app matches numbers), then sets their `contact_id` to the new
  contact.
- Call `relinkCallLogs()` at the end of `insertContact()` (new contact) and `updateContact()`
  (covers adding a number to an existing contact too), after the transaction commits.
- Once this runs, the existing reload in `CallHistoryScreen` (`_load()`, called right after
  the "Add contact" screen closes) will pick up the now-linked rows immediately — both the
  name and future menu titles will show correctly, with no separate UI change needed for
  items 2 and 4.

**3. Stop duplicate contacts from one save**
(`add_edit_contact_screen.dart`):
- Add a guard at the very top of `_save()`: `if (_saving) return;` before anything else runs.
  This closes the gap where multiple taps before the first frame redraw could each start a
  save. Combined with the existing `_saving` flag and `AbsorbPointer`, this makes `_save()`
  itself reentrancy-safe rather than relying only on the button being disabled.

## What is out of scope

- Not adding a database-level "reject duplicate contact" rule — the reported bug is caused by
  re-entrant taps, not a legitimate need to detect duplicates in general (the app already has
  a separate "Find duplicates" / merge feature for that).
- Not changing how calls are matched to contacts at logging time (`CallEventLogger`) — only
  adding the missing back-fill for contacts added afterward.
