# Change log: refresh docs/known-gaps.md

Implements [plans/20260705_211029_known-gaps-doc-refresh.md](../plans/20260705_211029_known-gaps-doc-refresh.md).

Only `docs/known-gaps.md` changed. No code changes.

## What changed

1. **Timezone lookup** — removed the stale "returns null; real lookup not implemented"
   bullet from "Still not integrated". Added a bullet to the first Resolved section
   saying it is implemented offline in `PreCallSummaryService._getTimezoneForLocation`
   (city/country → IANA-zone map + bundled `timezone` database); unmapped locations
   still yield null so the summary omits the line.
2. **QR and BLE** — moved their bullets (text kept, "now wired" phrasing tidied) out of
   "Still not integrated" into a new **"Resolved (2026-07-05 sharing build-out)"**
   section, placed before the "Deferred" section.
3. **Pointer bullets deleted** — the one-line "Speech to text — see the Resolved entry
   above" and "Device-contacts sync — see the Resolved entry below" bullets were
   removed; the real Resolved entries already exist (this also removes the wrong
   "below" direction).
4. **State management** — moved from "Still not integrated" into a new final section,
   **"Architectural notes (not feature gaps)"**, with the same content.
5. "Still not integrated (intentional, out of current scope)" now holds only the
   genuinely open item: **Notifications / reminders** (rows written, nothing scheduled).
