# Change log — Fix gaps in docs/features.md

Implements: `plans/20260802_145357_fix_features_doc_gaps.md`

## What changed

Edited `docs/features.md` only. No code files were touched.

- **Intro:** noted the in-call UI supports call waiting and merging a
  second call, and that T9 dialpad input covers more than English/Malayalam.
- **Section 2 (Dialer / calling):** added call waiting, hold+swap between
  two calls, adding a second call mid-call, conference merge, and the
  in-call DTMF keypad. Reworded the T9 bullet from "dual-script" to
  "multi-script" so it's not contradicted by section 9.
- **Section 9 (Localization):** listed all 7 supported T9 dialpad scripts
  (auto-detect, Malayalam, Devanagari, Cyrillic, Arabic, Greek, none)
  instead of just "English or Malayalam."
- **Section 10 (Appearance):** pointed the dialpad-script bullet at section
  9 instead of repeating the old two-script claim.
- **Section 6 (P2P sync):** added that app settings (not SIM-specific ones)
  are part of the sync payload, with the full-sync-overwrites /
  incremental-fills-only distinction.
- **Section 12 (Settings screen):** dropped the false "full list" claim
  from the header, added a caveat that the in-app Features showcase screen
  has some marketing copy not backed by code, and added a new "Contacts
  settings" sub-list covering: sort order vs. name display format,
  hide-without-phone toggle, search-index rebuild tool, secret-contacts
  export path, contact counts card, and the "Add Me" shortcut.

## Why

A critical review against the actual `lib/` and `android/` source found the
doc was missing a whole functional area (call waiting / multi-call / DTMF),
understated T9 script support, and left several real Settings → Contacts
features undocumented while still claiming to be a "full list." Since this
file's stated purpose is to be trustworthy ground truth for another LLM,
these gaps were fixed so nothing gets duplicated or missed by mistake.

## Out of scope

- `docs/dependencies.md`'s apparently-unused `geolocator` dependency was
  flagged during review but left alone — it's a code/dependency question,
  not a features.md accuracy issue.
