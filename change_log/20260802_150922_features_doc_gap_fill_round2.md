# Change log — Second independent gap-fill pass on docs/features.md

Implements: `plans/20260802_150922_features_doc_gap_fill_round2.md`

## What changed

Edited `docs/features.md` only. No code files were touched.

- **Section 2 (Dialer / calling), Multi-SIM bullet:** added that each SIM
  can be given its own display color, shown on the in-call screen.
- **Section 2, post-call feedback bullet:** reworded to make clear this is
  an opt-in setting (off by default), not something that happens after
  every call automatically.
- **Section 8 (Security / privacy), emergency-info bullet:** added "organ
  donor status" to the list of ICE card fields.
- **Section 10 (Appearance / theming):** added a bullet for the text-size
  picker (Small/Default/Large/Larger).
- **Section 12 (Settings screen), SIM & calling settings list:** added the
  per-SIM color picker and the post-call-feedback toggle to the list.

## Why

The user asked for a critical re-analysis of `docs/features.md` to confirm
all features are listed and the app description is inclusive. Rather than
trust the file's two earlier same-day self-reviews, an independent sweep
was done across every screen, service, model, native Kotlin file, and
`AndroidManifest.xml`, with each candidate finding verified directly
against the source line before being accepted. Four small, real gaps were
found and fixed; everything else in the document already matched the code,
including the intro "What this app is" paragraph, which already named the
app's major pillars from the prior review round.
