# Re-analyse and rewrite `docs/feature_analysis_and_roadmap.md`

**Status:** completed

## Files to be changed

- `docs/feature_analysis_and_roadmap.md` — full rewrite (the only file changed).
- `change_log/20260806_<time>_roadmap-doc-reanalysis.md` — new change log, written after the edit.

No code files change. This is a documentation-only change.

## What is wrong with the document today

I checked the roadmap doc against the actual code (`lib/`, `android/.../kotlin/`) and against
`docs/features.md`, and I read the 18 app feature docs listed in `L:\Android\MyFlutterApps\myapps.md`.
Problems found:

1. **Stale "existing capabilities" section.** It describes Smart Redial as a reminder, but the
   code now auto-dials natively (`SmartRedialManager.kt`, `smart_redial_service.dart`). It also
   still credits phonetic (Double Metaphone / Soundex) duplicate matching as a completed win,
   but that step was **removed** from the merge flow because of false positives — the table row
   marked "✅ Completed" is now wrong.
2. **No status re-verification.** Of the 7 "industry-first" ideas, only 2 are marked done.
   I verified in code that the other 5 (BLE emergency mesh, relationship-decay nudges,
   multi-persona, decoy vault, in-call scratchpad) have **zero** implementation — no service,
   no screen, no permission, no native code. The doc should say so plainly with the evidence.
3. **The real blocker is not named.** Two of the five (decay nudges, per-persona reminders) and
   the existing "reminder rows are stored but never fire" gap all wait on the same missing piece:
   **there is no notification scheduler in the app.** Every notification today is built ad-hoc in
   Kotlin. The roadmap does not show this as a prerequisite, so the Gantt chart is misleading.
4. **The Gantt chart has already expired.** Phase 2 starts 2026-08-20 with items that have no
   groundwork; the "done" bars are not in the order the work actually happened.
5. **No ecosystem awareness.** The user has 18 other Flutter/Kotlin apps. The doc proposes
   nothing that reuses their proven parts, and does not warn against re-building what a sibling
   app already does well.

## What I learned from the 18 sibling apps (this shapes the new content)

Reusable, already-proven building blocks:

- **Exact alarm + boot-restore scheduler** — SMS Sentry (`ReminderAlarmScheduler`,
  `ScheduledSmsScheduler`, `BootReceiver`) and ChronoTune both ship this. ContactSphere already
  has `EmergencyBootReceiver` and a native Smart Redial alarm, so the pattern is half-present.
- **Optical "air-gap" QR transfer** — SreerajP Authenticator and Sreeraj P QR Reader both ship
  camera-only, multi-frame optical sync.
- **Malicious/tampered QR checks** — QR Reader's layered link/tamper check.
- **RRULE recurrence engine** — SreerajP ToDo (RFC 5545).
- **Offline Malayalam natural-language parsing** — ChronoTune (`ml-IN`, numerals, relative time).
- **Encrypted P2P LAN sync with QR pairing** — SMS Sentry, TextData, Authenticator; ContactSphere
  already has its own version of this.

Things ContactSphere must **not** grow into, because a sibling app owns them:

- SMS inbox / OTP / finance parsing → **SMS Sentry**
- Notes, journals, rich text, voice notes → **SreerajP Journal Vault**
- Task lists and time tracking → **SreerajP ToDo**
- 2FA codes → **SreerajP Authenticator**
- File hiding / storage vault → **Vault Files**
- PDF generation and viewing → **SreerajP PDF App** (share out to it instead)

## The plan for the rewrite

Rewrite `docs/feature_analysis_and_roadmap.md` with this structure:

1. **Header + how to read this doc.** State that "implemented" claims are code-verified on
   2026-08-06, and that `docs/features.md` is the ground truth for shipped behaviour.
2. **Section 1 — Ecosystem context (new).** Short table of the sibling apps, what to reuse from
   them, and the "do not rebuild this here" list above.
3. **Section 2 — Current foundation (corrected).** Refresh the capability list; fix the Smart
   Redial description; drop the phonetic-matching claim.
4. **Section 3 — Status of the 7 original concepts.** One block each with a verified status
   (`Shipped` / `Not started`), the evidence, and — for the not-started ones — what is actually
   blocking them.
5. **Section 4 — The missing foundation.** One short section on the notification scheduler:
   why it gates three separate features, and which sibling app to copy the pattern from.
6. **Section 5 — New proposed features (new).** Each with concept, why it fits a contacts/dialer
   app specifically, and a no-overlap note. Planned list:
   - **Unified reminder & nudge scheduler** (foundation; unblocks relationship nudges, stored
     reminder rows, birthday/anniversary/meetiversary alerts).
   - **Best-time-to-reach windows** — computed offline from the app's own call history, per
     contact; shown before dialing and used to rank the dialer strip. This is the honest,
     data-backed version of the old "time-of-day ranking" row.
   - **Number-change detection** — an unknown number that behaves like a known contact
     (same name in system contacts, or repeated two-way calls right after an old number goes
     silent) offers a one-tap "is this <name>'s new number?" merge.
   - **Relationship-tier quiet hours** — night-time silencing where only chosen tiers
     (immediate family, emergency contacts) ring through. Uses the existing native screening
     service, so it works with the app closed.
   - **Optical air-gap contact transfer** — animated QR frames, camera-only; a fallback for
     when BLE pairing fails, reusing the Authenticator/QR Reader approach.
   - **Safety check on scanned contact QR codes** — validate/flag payloads before import,
     reusing QR Reader's checks.
   - **Spoken caller announcement (English/Malayalam)** — TTS "Amma calling" before answering;
     an accessibility feature matching the ecosystem's inclusive-design pillar.
   - **Senior / large-touch dialer mode** — bigger targets, fewer controls, same code paths.
   - **Emergency card hand-off to siblings** — export the ICE card through the system share
     sheet instead of building any viewer here.
   Each entry gets a rough size (S/M/L) and its dependencies.
7. **Section 6 — Technical improvements table (corrected).** Fix the phonetic row to say
   "reverted, and why"; mark BLE batch sharing as **partly done** ("send all" exists; the
   PIN/biometric handshake for unsolicited incoming transfers does not); keep the pre-call
   overlay HUD row and note it needs `SYSTEM_ALERT_WINDOW`, which the app does not request today.
8. **Section 7 — Revised roadmap.** A new Gantt chart, foundation-first: scheduler → nudges +
   date reminders → best-time-to-reach → quiet hours → number-change detection → the bigger
   items (persona, decoy vault, in-call scratchpad, BLE mesh) last, since they are the largest
   and least certain.

## Not in scope

- No code changes, no new dependencies, no `pubspec.yaml` edits.
- `docs/features.md` is not edited. Its "Roadmap / aspirational" list already matches what I
  verified, so it stays as is.

## Approval

Do you approve this plan?
