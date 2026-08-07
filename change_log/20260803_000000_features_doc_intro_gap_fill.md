# Change log: features.md app description gap fill

Implements: `plans/20260803_000000_features_doc_intro_gap_fill.md`

## What changed

Added two sentences to the "What this app is" paragraph in `docs/features.md`:

1. Contacts can be shared/exchanged as a vCard, CSV, QR code, or over Bluetooth, and
   the app can show a contact's linked WhatsApp/Telegram from the system contacts.
2. The app supports multiple SIMs, with a chosen default SIM and a distinct color
   per SIM.

## Why

A full cross-check of `docs/features.md` against the code found no missing features
and no factual errors in the body of the document. The only gap was that the short
summary paragraph at the top omitted two subsystems (Sharing/interoperability and
Multi-SIM support) that already have their own full sections later in the same file,
so a reader skimming only the intro would miss that the app does either of these
things.

## Not changed

No code was changed. `docs/architecture.md`'s stale "DB schema version 2" note was
flagged separately as a possible follow-up but is out of scope for this change.
