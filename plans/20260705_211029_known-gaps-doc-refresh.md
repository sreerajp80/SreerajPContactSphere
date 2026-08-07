# Refresh docs/known-gaps.md — remove stale entries, reframe state management

**Status:** completed

## Files to change

- `docs/known-gaps.md` (only file)

## The issue

The "Still not integrated (intentional, out of current scope)" section lists things that
are in fact done, plus one item that is not a feature gap at all:

1. **Timezone lookup** (lines 164–165) — the doc says
   `PreCallSummaryService._getTimezoneForLocation` returns null and "real lookup not
   implemented". This is stale: the method is implemented
   (`lib/services/pre_call_summary_service.dart:87`) with an offline city/country →
   IANA-zone map plus the bundled `timezone` database, and returns e.g.
   `5:30 PM (Asia/Kolkata)`.
2. **QR** (lines 144–148) and other "*now wired*" entries (**BLE**, **Speech to text**,
   **Device-contacts sync**) — their text is already updated to say they are wired, but
   they still sit under the "Still not integrated" heading. A reader scanning headings
   still sees QR sharing (and the rest) listed as a gap. Also, the device-sync entry says
   "See the Resolved entry **below**" when that entry is above it.
3. **State management** (lines 171–174) — screens being `setState`-based with `provider`
   only for appearance settings is an architectural choice/limitation, not a
   declared-but-unintegrated feature. It reads wrong under "Still not integrated".

## The fix

All edits are within `docs/known-gaps.md`; no code changes.

1. **Timezone lookup** — delete the stale bullet from "Still not integrated" and add a
   short bullet to a Resolved section (under "Resolved (2026-07-05 ...)" as its own line
   or a new dated line): implemented offline in `PreCallSummaryService`
   (`_getTimezoneForLocation`, city/country → IANA-zone map + bundled tz DB); unmapped
   locations still yield null so the summary omits the line.
2. **Move the "now wired" entries out of "Still not integrated"** — relocate the QR, BLE,
   speech-to-text pointer, and device-contacts-sync pointer bullets into the Resolved
   area (QR and BLE become a new "Resolved (2026-07-05 sharing build-out)" style
   subsection, keeping their text as-is; the two one-line pointer bullets that just say
   "see the Resolved entry" are deleted since the Resolved entries already exist). Fix
   the wrong "below"/"above" direction as part of this.
3. **State management** — remove it from "Still not integrated" and add a new short
   section at the end, e.g. "## Architectural notes (not feature gaps)", holding the
   same content: screens use local `setState`; `provider` is wired only for app-wide
   appearance settings (`AppSettings` in `main.dart`).
4. After these moves, "Still not integrated (intentional, out of current scope)" keeps
   only the genuinely open item: **Notifications / reminders** (rows written, nothing
   scheduled).

## Not in scope

- No changes to `docs/architecture.md`, `docs/dependencies.md`, or any code.
