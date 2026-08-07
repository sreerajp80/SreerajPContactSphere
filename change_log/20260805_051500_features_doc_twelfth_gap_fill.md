# Change log: twelfth gap-fill pass on docs/features.md

Implements `plans/20260805_051219_features_doc_twelfth_gap_fill.md`.

## What changed

Edited `docs/features.md` only, in four sections:

- **Section 1 (Contacts management)** — the ephemeral-contacts bullet now
  says that scrubbing an ephemeral contact (whether by the timer, "delete
  after 1 call," or the "Scrub Now" button) also deletes its matching
  call-history (Recents) rows, not just the contact record.

- **Section 2 (Dialer / calling)**:
  - The T9 dialer bullet now mentions the "Add to contacts" shortcut shown
    when a typed number matches no existing contact.
  - The in-call screen bullet now mentions its own Block/Unblock button
    (a third place to block a number, besides the Blocked Numbers screen
    and the Recents long-press menu), including that blocking while still
    ringing also hangs up the call.
  - The Quick replies bullet now mentions the "Write your own…" free-text
    option, alongside the preset canned messages.
  - The call-blocking and identification-settings bullets now say the
    "filter suspected spam" toggle silences a call if the number is either
    user-marked spam **or** matches a known Indian telemarketer range
    (e.g. `140…`), not just spam-marked numbers.

- **Section 4 (Sharing / interoperability)** — the vCard and CSV bullets
  now note that vCard import also writes to the Android device address
  book, while CSV import stays app-database only.

- **Section 6 (Phone-to-phone sync)** — corrected the claim that the
  "self" contact is never included in a P2P sync: that only holds for
  incremental/selective syncs. A Full Sync does include it, and it lands
  on the receiving phone as an ordinary (non-self) contact.

No change was needed to the intro "What this app is" paragraph — it was
re-checked and still reads as an accurate, inclusive summary.

## Why

A user-requested critical re-check of `docs/features.md` (the app's
feature reference for other LLMs/developers) for missing features and an
inclusive app description. This is the twelfth independent gap-fill pass
on this file. All findings were verified against the actual source before
being written up (`lib/services/export_import_service.dart`,
`lib/screens/in_call_screen.dart`, `lib/screens/dialer_screen.dart`,
`lib/services/ephemeral_contact_service.dart`,
`android/app/.../ContactSphereCallScreeningService.kt`,
`lib/services/caller_id_service.dart`, `lib/services/sync_bundle_service.dart`).
