# Add Contact, Call, Tag and Phone number to the standard UI glossary

**Status:** done in this repo — see `change_log/20260921_121000_glossary-contact-call-tag-phone-number.md`.
Submodule branch pushed; waiting for merge in the shared guidelines repository.

Follow-up to `change_log/20260921_110000_item2b-app-chrome-and-shared-widgets.md` ("Translations —
needs native-reader review"). The user chose to add these four terms to the glossary once a fluent
reader has approved them.

## The issue

Engineering standard §8.5.4 fixes one Malayalam and one Sanskrit word for each common UI term, so
every app says the same thing. When a needed term is missing, the standard says to add it to the
glossary instead of each app choosing its own.

This app uses four terms constantly that the glossary does not have. Phases 2a and 2b chose these:

| English | Malayalam | Sanskrit |
|---|---|---|
| Contact / Contacts | കോൺടാക്റ്റ് / കോൺടാക്റ്റുകൾ | सम्पर्कः / सम्पर्काः |
| Call (noun) | കോൾ | आह्वानम् |
| Tag / Tags | ടാഗ് / ടാഗുകൾ | चिह्नम् / चिह्नानि |
| Phone number | ഫോൺ നമ്പർ | दूरभाषसङ्ख्या |

"Phone number" also needs a note, because the glossary already says Number is `സംഖ്യ`, never
`നമ്പർ`. `സംഖ്യ` reads as "numeral", which does not fit a telephone number, so the everyday
`നമ്പർ` was used. Adding "Phone number" as its own row makes that exception official, and `സംഖ്യ`
stays correct for a plain number.

## Reader decision

A fluent reader reviewed the terms and the user approved this plan with these corrections:

| English | Malayalam | Sanskrit | Change from the app today |
|---|---|---|---|
| Contact | വിലാസവിവരങ്ങൾ | सम्पर्काः | Malayalam changes from the loanword `കോൺടാക്റ്റ്` |
| Call | ഫോൺ വിളി | आह्वानम् | Malayalam changes from the loanword `കോൾ` |
| Tag | അടയാളം | चिह्नम् | Malayalam changes from the loanword `ടാഗ്` |

Sanskrit is unchanged for all three.

In `lib/l10n/app_ml.arb` this touches about 40 strings: 24 that use "contact", 9 that use
"call" and 8 that use "tag". Each needs its sentence re-inflected, not a plain word swap: for
example `കോളിലേക്ക്` ("to the call") becomes `ഫോൺ വിളിയിലേക്ക്`.

### Open questions (answered: singular വിലാസവിവരം / सम्पर्कः; Phone number added as proposed)

1. **Singular "contact" in Malayalam.** The reader gave the plural `വിലാസവിവരങ്ങൾ`. Ten strings
   need a singular form: "1 contact", "a contact", "Unnamed contact", "Choose a contact",
   "Scanned contact", and so on. Is it `വിലാസവിവരം`? The same question applies to Sanskrit, where
   the reader gave the plural `सम्पर्काः`. The app uses the singular `सम्पर्कः`.
2. **Phone number.** The reader's table has no row for it. Should `ഫോൺ നമ്പർ` /
   `दूरभाषसङ्ख्या` go into the glossary as proposed, or stay out until reviewed?

## Gate before any edit

The standard's review rule (§8.5.4) says a new Malayalam or Sanskrit glossary term MUST be reviewed
by a fluent reader before any app uses it. **No file in this plan changes until that reader has
approved, or corrected, the four rows above.** If the reader changes a word, the new word goes into
the glossary *and* replaces the old one in `lib/l10n/app_ml.arb` / `app_sa.arb`, and this plan is
updated before it is approved.

## Files to be changed

| File | Change |
|---|---|
| `docs/guidelines/flutter_project_engineering_standard.md` (submodule) | Add the four terms to §8.5.4: Contact, Phone number and Tag under "Content and fields", and Call (noun) under "Content and fields" too, next to the existing Number row. Add one line under the table saying Phone number uses `നമ്പർ` while Number stays `സംഖ്യ`. All four fit the §8.6 budget. |
| `docs/guidelines` submodule pointer in this repo | Bumped to the new submodule commit. |
| `lib/l10n/app_ml.arb`, `app_sa.arb` | Only if the reader corrects a word. Then `flutter gen-l10n`. |

## How the submodule change is made

`docs/guidelines` is a shared repository used by other apps, not a folder of this app. So the
glossary edit is:

1. Committed inside the submodule, on its own branch, and pushed to the shared guidelines
   repository.
2. Merged there (it changes the standard for every app, so it goes through that repository's own
   review).
3. Then this repo's submodule pointer is bumped to the merged commit.

Note: at planning time the working tree already had a submodule pointer change staged
(`docs/guidelines`). That existing change is left untouched; this plan's bump happens after it.

## The plan for the fix

1. Get the fluent reader's decision on the four rows. Record who reviewed and the date in the
   change log (name only if they agree to be named).
2. Edit §8.5.4 in the submodule and push it as above.
3. Bump the submodule pointer here.
4. If any word changed, update the two ARB files, regenerate, and run `flutter analyze`,
   `flutter test` and the §8.5.1 Sanskrit gate.
5. Write the change log, and remove these four rows from the "needs native-reader review" list
   going forward.

## Risk

Low for this app. The main effect is on other apps that follow the standard: from then on they
must use these words too. That is the point, but it is why the reader's approval comes first.

## Explicitly out of scope

- The other not-yet-glossary terms listed in the phase 2b change log (Merge, Rename, Dialer,
  Recents, and so on). They can follow the same route later.
