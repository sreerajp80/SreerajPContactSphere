# Change log — re-analysed and rewrote the feature roadmap document

**Date:** 2026-08-06
**Implements plan:** [plans/20260806_065728_roadmap-doc-reanalysis.md](../plans/20260806_065728_roadmap-doc-reanalysis.md)

## Files changed

- `docs/feature_analysis_and_roadmap.md` — full rewrite.
- `change_log/20260806_100500_roadmap-doc-reanalysis.md` — this file.

No code changed. Documentation only.

## Why

The roadmap document had drifted from the code, and it was written without any awareness of the
other 18 apps in the family (listed in `L:\Android\MyFlutterApps\myapps.md`). I re-checked every
claim against `lib/`, `android/app/src/main/kotlin/` and `docs/features.md`, and read the feature
docs of all 18 sibling apps.

## What changed

### Corrections to stale claims

- **Smart Redial** was described as a reminder notification. It now places the call itself, fired
  by a native alarm (`SmartRedialManager.kt`), and survives app death and reboot.
- **Phonetic duplicate matching** was marked "✅ Completed". It was implemented and then removed
  because truncated Double Metaphone / Soundex codes collided on unrelated names. The table row
  now records the removal and warns against re-adding it as-is.
- **BLE batch sharing** was listed as a to-do. "Send all" ships. What is still missing is the
  receiving-side PIN/biometric handshake, so the row now says "partly done" and names the gap.

### Status re-verification

Of the seven original "industry-first" concepts, two are shipped (ephemeral contacts, multi-script
T9 — the latter is wider than planned, covering Devanagari, Cyrillic, Arabic and Greek too). The
other five have no implementation at all: relationship-decay nudges (only the scoring half
exists), multi-persona profiles, decoy vault, in-call scratchpad, BLE emergency mesh. Each now
carries its evidence and its blocker.

### New section: the missing foundation

Three separate features — decay nudges, per-persona reminders, and the reminder rows the app
already writes and never fires — all wait on one absent piece: there is no notification scheduler
in the app. The document now calls this out as the single highest-leverage item and recommends
copying the exact-alarm + boot-receiver pattern SMS Sentry and ChronoTune already use, which
ContactSphere half-implements twice already (`EmergencyBootReceiver`, native Smart Redial alarm).

### New section: ecosystem context

A table of what to reuse from the sibling apps (scheduler pattern, optical air-gap QR transfer,
QR safety checks, RRULE recurrence, offline Malayalam parsing), and an explicit "do not build
these here" list — SMS handling, notes, tasks, 2FA, file vault and PDF each belong to a sibling
app. This bounds two roadmap items: the in-call scratchpad stays call-scoped, and follow-ups stay
contact-scoped reminders rather than a task manager.

### New proposed features

Nine additions, each with a size estimate and a no-overlap note: unified reminder & nudge
scheduler, best-time-to-reach windows computed from the app's own call history, number-change
detection, relationship-tier quiet hours, optical air-gap contact transfer, QR payload safety
checks, spoken caller announcement in English and Malayalam, a senior / large-touch dialer mode,
and emergency-card hand-off through the share sheet.

Best-time-to-reach replaces the old "rank business contacts during office hours" idea, which
guessed at behaviour the app can measure directly.

### Rewritten roadmap chart

The old Gantt chart had already expired and put unblocked work first. The new one is
foundation-first across four phases, ending with the large, uncertain items (persona, decoy
vault, BLE mesh). The BLE mesh is now marked as a research item, with its Android constraints
stated plainly.

## Not changed

`docs/features.md` was left alone. Its "Roadmap / aspirational" list already matched what I
verified in the code.
