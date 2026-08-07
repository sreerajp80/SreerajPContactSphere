# Features doc — fifteenth gap fill

**Status:** completed

## What the issue is

I did a fresh critical check of `docs/features.md` against the actual code
(screens, services, native Kotlin code, dependencies, settings). Most of the
app is already documented after 14 earlier gap-fill rounds. Two small,
genuine gaps are still missing from the doc:

1. **Number-picker sheet.** When a contact has more than one phone number,
   long-pressing the Call button on their row in the contact list (or on the
   emergency-info screen) opens a bottom sheet to pick which number to dial,
   before the SIM chooser runs. Code: `lib/widgets/number_picker_sheet.dart`
   (`showNumberPickerSheet`), used from `lib/screens/contact_list_screen.dart`
   and `lib/screens/emergency_info_screen.dart`. Section 1's "quick actions on
   each row" list (call/view profile/email/delete) doesn't mention this.

2. **"Copy number" / "Share number" on a Recents entry.** The long-press menu
   on a Recents (call history) row has two more actions than the doc
   currently lists: "Copy number" (copies to clipboard) and "Share number"
   (system share sheet). Code: `lib/screens/call_history_screen.dart` lines
   ~649–658. The doc's Recents paragraph (section 2) only lists
   block/unblock, mark/unmark spam, Smart Redial & Reach Me, and "remove this
   entry."

Everything else was checked and is already correctly covered: all screens,
services, native Kotlin files, `pubspec.yaml` dependencies, and
`AppSettings` fields map to something already in the doc. No other gap was
found, and the App Description intro paragraph does not need further
changes this round (it already mentions the main feature categories these
two items fall under — contact list actions and Recents actions — so only
the detail bullets need updating, not the intro).

## Files to change

- `docs/features.md` — two small bullet additions:
  - Section 1 ("Contacts management"), the "Contact list" bullet: add a
    mention of the number-picker sheet for multi-number contacts.
  - Section 2 ("Dialer / calling"), the "Recents / call history" bullet: add
    "Copy number" and "Share number" to the list of long-press actions.

## Plan for the fix

Add the two facts above as bullet-text additions in their existing
paragraphs, matching the doc's existing plain-English, factual style (no
marketing language). No other section changes.
