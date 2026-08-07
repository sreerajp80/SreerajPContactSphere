# Roadmap document — mark implemented features

Implements [plans/20260806_080252_roadmap_mark_implemented.md](../plans/20260806_080252_roadmap_mark_implemented.md).

Documentation only. No code changed.

## What changed in [docs/feature_analysis_and_roadmap.md](../docs/feature_analysis_and_roadmap.md)

1. **"How to read this document"** — added a line saying that "Not started" claims are
   re-searched on every pass, not carried over on trust.
2. **Section 2, Current foundation** — best-time-to-reach
   ([`reach_window_service.dart`](../lib/services/reach_window_service.dart)) added to the
   contextual-intelligence bullet, with the note that none of those services place a call.
3. **Section 5 intro** — "None of these exist today" sat directly above a shipped item. Replaced
   with wording that survives items shipping one at a time: each carries its own status heading,
   and anything unmarked does not exist yet.
4. **5.2** — retitled to `— **Shipped**`, matching section 3's style, and rewritten to describe
   what actually shipped (day parts, 180-day lookback, the evidence thresholds, both surfaces).
   The trailing "Status: shipped" paragraph was folded into this. Two caveats kept: it never
   dials, and the "nudge now" case still waits on 5.1.
5. **Section 6 table** — the Smart dialing row now says 5.2 is "now shipped".
6. **Section 7 gantt** — Best-Time-To-Reach moved from Phase 2 into the Shipped section as
   `:done` (`s5`).

## Nothing else changed status

Before editing, I re-checked all 13 remaining "Not started" claims against the code. Every one
still holds, so the edit stayed narrow — 5.2 is the only item whose status moved.

The keyword searches that did return hits were all false positives, worth recording so the next
pass doesn't re-investigate them:

- `persona` → the word "personal" (phone and address types), not a persona model.
- `mesh` → `HomeShell` matching the letters.
- `overlay` → Flutter's own `Overlay` widget; `SYSTEM_ALERT_WINDOW` is genuinely absent from
  `AndroidManifest.xml`.
- 5.7 also has no TTS dependency in `pubspec.yaml`.

## Verification

The gantt edit removed task id `p2_1`, which Number-Change Detection was anchored to with
`after p2_1` — left alone, that dangling reference would have broken the chart. Number-Change
Detection is now the Phase 2 head, anchored `after p1_3`.

Cross-checked the mermaid block after editing: every `after <id>` reference resolves to a
defined task, and no task references the removed `p2_1`.
