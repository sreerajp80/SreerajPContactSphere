# Fill gap in features.md app description paragraph

**Status:** completed

## Files to change

- `docs/features.md` (only the "What this app is" paragraph, lines 8–25)

## The issue

I did a full cross-check of `docs/features.md` against the actual code (every screen,
service, repository, and native Kotlin file). The doc itself is accurate and complete —
no missing features, no wrong facts.

The one gap is in the short summary paragraph at the top ("What this app is"). It
describes the app's main abilities, but it never mentions two things that each have
their own full section further down in the same file:

- **Sharing / interoperability** (section 4): vCard and CSV export/import, sharing a
  contact as a QR code, Bluetooth contact exchange between two phones, and reading a
  contact's linked WhatsApp/Telegram from the system contacts ("Connected apps").
- **Multi-SIM support** (section 2): picking a default SIM, per-SIM colors, and
  per-SIM call history, which is its own subsystem in the code.

A reader who only skims the top paragraph would not know the app does either of these
things.

## The fix

Add one short sentence to the "What this app is" paragraph (lines 8–25) covering:
1. Sharing a contact via vCard, CSV, QR code, or Bluetooth, and reading a contact's
   linked messaging apps.
2. Multi-SIM support (choosing a default SIM, per-SIM colors).

No other part of the file changes. No code changes — this is a documentation-only edit.

## Side note (not part of this plan)

`docs/architecture.md` still says the database schema is "version 2", but the real
schema (and `docs/known-gaps.md`) is well past version 20. This is a separate file and
a separate issue — flagging it here in case you want a follow-up plan for it, but it is
out of scope for this change.
