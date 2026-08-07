# Change log — Polish minor wording gaps in docs/features.md

Implements: `plans/20260802_150500_polish_features_doc_wording.md`

## What changed

Edited `docs/features.md` only. No code files were touched.

- **Section 1 (Contacts management):** the "Relationship Health" overview
  screen bullet now also names its UI screen title, "Relation Status," so
  the doc text maps directly onto the running app.
- **Section 4 (Sharing / interoperability):** "Connected apps" now has its
  own bullet (previously folded into a longer sentence), described as a
  dedicated feature rather than a side note.
- **Section 2 (Dialer / calling):** added a bullet clarifying that the
  identification settings screen has two independent toggles — local
  caller-ID heuristics and "filter suspected spam" silent-ring — not one
  combined switch.

## Why

A follow-up critical review (this session) compared the doc against every
screen and service in `lib/` and found no missing features — the earlier
gap-fix pass already covered the substantial gaps. Three small wording
precision issues remained, all about mapping doc text to the actual UI
more clearly. Fixed for reader clarity; no new capabilities were found or
claimed.
