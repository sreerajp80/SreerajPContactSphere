# Fill remaining gaps in docs/features.md (second independent review)

**Status:** completed

## What the issue is

`docs/features.md` has already been through two review-and-fix passes today
(see `plans/20260802_144831_docs_features_file.md`,
`plans/20260802_145357_fix_features_doc_gaps.md`,
`plans/20260802_153000_features_doc_critical_review.md`). Per the user's
request to critically re-analyze the file, I did a fresh, independent sweep
of every screen, service, model, native Kotlin file, and the Android
manifest (not trusting the earlier self-reviews), and verified the findings
directly against the code.

The document is accurate on substance overall — no fabricated features, no
missing screens/services, and the intro paragraph already names the app's
major pillars. But four small, real gaps survived scrutiny:

1. **Text size / font-scale picker is missing from Section 10.**
   `lib/state/app_settings.dart:166-211,411` defines an `AppTextScale` enum
   (Small/Default/Large/Larger, confirmed at line 188 `'Small'`) with a
   persisted setting and a `textScaleFactor` getter; it's exposed as a
   picker on the Appearance screen. Section 10 ("Appearance / theming")
   currently only mentions theme, accent color, and font — not text size.

2. **Per-SIM in-call chip color is missing from Section 2 / Section 12.**
   `lib/screens/sim_settings_screen.dart:340-380,457` shows a per-SIM color
   picker (`AppTheme.simColorChoices`) backed by
   `lib/state/app_settings.dart:263-266,447-455`, controlling the color
   shown on the in-call screen per SIM. Section 2's Multi-SIM bullet and
   Section 12's SIM & calling settings bullet don't mention it.

3. **Emergency card "Organ donor" field is missing from Section 8's field
   list.** `lib/models/emergency_info.dart:92-93,113-114,126,193-194`
   defines `organDonor`/`showOrganDonor` fields, included in the emergency
   card when set. Section 8 lists the ICE card's fields (blood group,
   allergies, medicines, conditions, notes, address, emergency contacts) but
   omits organ-donor status.

4. **Post-call feedback is opt-in (default off), not automatic — and the
   toggle itself isn't documented.** `lib/screens/sim_settings_screen.dart:
   87,517-528` shows a toggle (`postCallFeedbackEnabled` in
   `app_settings.dart:349,537`) controlling whether the feedback sheet
   appears at all. Section 2 currently describes it as "a sheet after each
   call," implying it always happens, and Section 12 doesn't list the
   toggle among the SIM & calling settings.

## Files to be changed

- `docs/features.md` only. No code changes.

## The plan for the fix

1. **Section 10 (Appearance / theming):** add a bullet for the text-size
   picker (Small/Default/Large/Larger), alongside the theme/accent/font
   bullets.

2. **Section 2 (Dialer / calling), Multi-SIM bullet:** add a clause noting
   each SIM can be given its own display color, shown on the in-call
   screen.

3. **Section 8 (Security / privacy), emergency-info bullet:** add "organ
   donor status" to the parenthetical list of ICE card fields.

4. **Section 2, post-call feedback bullet:** reword to make clear this is
   an opt-in toggle (default off), not something that happens after every
   call automatically.

5. **Section 12 (Settings screen), SIM & calling settings list:** add the
   per-SIM color picker and the post-call-feedback toggle to the existing
   parenthetical list ("default SIM, caller ID, spam filter, quick
   replies").

No other section changes — the rest of the document was checked against
`lib/screens/`, `lib/services/`, `lib/repositories/`, `lib/models/`,
`lib/state/`, the Kotlin native sources, and `AndroidManifest.xml`, and
already matches the code.

## Why this shape

This keeps the same documentation-only, precision-pass approach as the
prior rounds, but is based on an independent re-verification rather than
trusting the earlier self-review's conclusion that nothing remained. Each
finding was checked against the actual file and line before being included
here.
