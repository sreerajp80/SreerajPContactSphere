# Glossary: Contact, Call, Tag and Phone number

**Plan:** `plans/20260921_113100_glossary-contact-call-tag-phone-number.md`
**Status:** done in this repo. The glossary edit is pushed to the shared guidelines repository on
branch `glossary-contact-call-tag-phone-number` and is waiting to be merged there. This repo's
`docs/guidelines` submodule pointer is bumped only after that merge.

---

## What changed

A fluent reader reviewed the four terms that phases 2a and 2b had chosen without glossary
guidance. The user approved the plan with the reader's corrections, and confirmed the singular
forms and the Phone number row:

| English | Malayalam before | Malayalam now | Sanskrit |
|---|---|---|---|
| Contact / Contacts | കോൺടാക്റ്റ് / കോൺടാക്റ്റുകൾ | വിലാസവിവരം / വിലാസവിവരങ്ങൾ | सम्पर्कः / सम्पर्काः (unchanged) |
| Call (phone call) | കോൾ | ഫോൺ വിളി | आह्वानम् (unchanged) |
| Tag / Tags | ടാഗ് / ടാഗുകൾ | അടയാളം / അടയാളങ്ങൾ | चिह्नम् / चिह्नानि (unchanged) |
| Phone number | ഫോൺ നമ്പർ | ഫോൺ നമ്പർ (unchanged) | दूरभाषसङ्ख्या (unchanged) |

## Files changed

| File | Change |
|---|---|
| `lib/l10n/app_ml.arb` | 42 Malayalam strings rewritten with the approved words. Each sentence was re-inflected, not word-swapped (for example `കോളിലേക്ക്` → `ഫോൺ വിളിയിലേക്ക്`, `കോൺടാക്റ്റിനായി` → `വിലാസവിവരത്തിനായി`). `labelUsualSimForCall` also became `പതിവ് സിം`, matching the shorter English "Usual SIM". No Malayalam string still uses the old loanwords. |
| `lib/l10n/app_localizations_ml.dart` | Regenerated with `flutter gen-l10n`. |
| `docs/guidelines/flutter_project_engineering_standard.md` (submodule) | §8.5.4 "Content and fields": four new rows after Number, and a note on Phone number vs. Number and on singular/plural forms. Committed in the submodule with its own plan and change log, and pushed on a branch (see Status). |
| `plans/20260921_113100_glossary-contact-call-tag-phone-number.md` | Reader decision recorded; status updated. |

`app_sa.arb` did not change: the reader kept every Sanskrit term.

## Glossary review list

These four terms are no longer on the "needs native-reader review" list from
`change_log/20260921_110000_item2b-app-chrome-and-shared-widgets.md`. The other terms in that list
(Merge, Rename, Dialer, Recents, and so on) still need review.

## Verification

| Check | Result |
|---|---|
| `flutter analyze` | No issues found. |
| `flutter test` (whole suite) | 601 passed, 2 skipped, 0 failed. |
| `test/l10n/` (parity, label budget, widget tests in `en` / `ml` / `sa`) | 46 passed, 1 skipped (phase 2g About-config group). |
| §8.6 label budget | All rewritten Malayalam short labels are within 22 characters. |

## Still to do

1. Merge branch `glossary-contact-call-tag-phone-number` in the shared guidelines repository.
2. Then stage the `docs/guidelines` pointer here at the merged commit. At the time of writing the
   submodule is checked out at the branch commit, so this repo's copy of the standard already
   shows the new rows. The earlier staged pointer change (to `eb4b462`) is untouched.
3. On a device, check that the longer Malayalam bottom-bar label `വിലാസവിവരങ്ങൾ` and the tab
   `അടയാളങ്ങൾ` stay on one line on a small phone (standard §8.3.3 manual check).
