# Removed real contact names and phone numbers from `plans/` and `change_log/`

Implements [plans/20260807_074611_redact-pii-from-docs.md](../plans/20260807_074611_redact-pii-from-docs.md).

## What was wrong

Plan and change-log files quoted real data from the user's own address book — real
people's names (Malayalam and Latin script), real business contact names, and real phone
numbers. These files are in git, so the data was readable by anyone with repo access.

## What changed

38 markdown files under `plans/` and `change_log/`. No source code, tests, `docs/`, or
assets were touched.

Two replacement styles were used, as agreed in the plan.

### 1. Redaction markers — where the value carried no technical weight

`[name]`, `[phone]`, numbered (`[name-1]`, `[phone-2]`) when a paragraph had to tell two
apart.

- `plans/20260701_205704`, `change_log/20260701_205704` — duplicate-merge name and the
  KEEP-vs-others number pair.
- `plans/20260701_211428`, `change_log/20260701_211428` — the same-name duplicate case.
- `plans/20260703_091109` — dialer suggestion row (name + number).
- `plans/20260703_091833`, `20260703_092741`, `change_log/20260703_092352` — the two-SIM
  contact; its two numbers were dropped entirely (only "a JIO number and a BSNL number"
  is needed to make the point).
- `plans/20260703_120832` — incoming-call name and caller-ID number.
- `plans/20260703_124905` — the duplicated relationship pair.
- `plans/20260705_111843`, `change_log/20260705_113716` — contact name, **plus** the row
  id and the stored `dob` / `anniversary` values, which identify the same person just as
  well as the name. (This went slightly beyond "names and numbers"; it is called out
  here rather than done silently.)
- `plans/20260717_205448`, `20260805_061744`, `change_log/20260717_213958` — the
  doctor's name; the two Malayalam nicknames became a prose description.
- `plans/20260805_080000` — the triplicated Recents row.

### 2. Generic stand-ins — where the value *was* the technical point

Substituting a marker here would have destroyed the explanation, so stock non-contact
names and clearly-fake numbers were used instead. **Every substituted transliteration or
phonetic key was recomputed by running the project's own `searchKey` / `phoneticCode`**
in a throwaway test, so the tables remain factually correct. The throwaway test was
deleted afterwards.

| File(s) | Old → new | Keys |
| --- | --- | --- |
| `plans/20260701_221400`, `20260701_221932`, `change_log/20260701_222900` | real number → `9876543210` / `+919876543210` | — |
| `plans/20260806_184304` | call-log number → `9876543210` | — |
| `plans/20260711_165449`, `change_log/20260711_170801` | collision pair → `9000123456` / `9111123456` (still share the last 7 digits, so the point holds) | — |
| `plans/20260706_212719`, `change_log/20260706_221327` | Malayalam nickname → `സീത` / `Seetha`; inflections → `സീതയെ`, `സീതയോട്`, `സീതയ്ക്ക്` | `sita`, `sitaie`, `sitaiot` (verified) |
| `plans/20260725_061214`, `change_log/20260725_065016` | transliteration tables → `Michael`/`മൈക്കിൾ`, `Suresh`/`സുരേഷ്`, `Thomas`/`തോമസ്` | keys `micael`/`maikil`, `sures`/`sures`, `tomas`/`tomas`; codes `mkl`, `srs`, `tms` (verified) |
| same files | loose-code example `rn` → `sr` (Suresh, Surya, Sridevi); near-miss example → `Ranjith`/`Ranjit` | — |
| `plans/20260729_063000`, `change_log/20260729_063000` | the business contact → "a contact whose name begins `കൊ`"; the split-vowel mechanics kept unchanged | — |
| `plans/20260730_181113`, `change_log/20260730_181113` | `… Time Gallery` → `City Time Gallery`; `… Electrician` → `Kumar Electrician`; the full Malayalam name + surname → `അലക്സ് കുമാർ`; the full Malayalam surname pair → bare `ലൂക്കോസ്` | — |
| `plans/20260730_102300` | the two named search examples → a prose description | — |
| `plans/20260706_211951`, `change_log/20260706_212800` | the two names in the stale-key example, and the stale key derived from one → prose | — |
| `plans/20260805_040000`, `20260805_075917`, `change_log/20260805_040000` | Soundex-collision names → prose ("a multi-word hospital business name and an unrelated short personal name"); the Malayalam-vs-Latin pair → `സുരേഷ് കുമാർ` / `Suresh Kumar` | both give `sures kumar` (verified) |
| `plans/20260806_160055`, `change_log/20260806_160055` | same pair → `സുരേഷ് കുമാർ` / `Suresh Kumar` | as above |
| `plans/20260806_194300` | four hospital contacts → prose; `സബിത …` → `സബിത കുമാർ`; two business rows → bare `Sabu` / `SBI`; `Seba …` → `Seba Kumar`; the Alex surname → `അലക്സ് കുമാർ`; query `anto` → `kuma`, `sab pre` → `sab kum` | `spt kmr`, `alks kmr` (verified) |

### 3. The plan file itself

`plans/20260807_074611_redact-pii-from-docs.md` originally listed every name and number
being removed — which would simply have moved the leak into a new file. It was rewritten
to describe each item by *what it was and where it appeared*, never by value.

## What was deliberately kept

- Fake documentation numbers already in the docs: `9876543210`, `5551234567`.
- Generic example names the user agreed are not personal data: `Ramesh` / `രമേഷ്`,
  `Anu` / `അനു`, `Amma` / `അമ്മ`, `Ammu`, `Ajay`.
- Bare common given names / words that carry a script mechanic and identify nobody:
  `ചിന്നു`, `ൻസി`, `കൊച്ചി`, `Lukose` / `ലൂക്കോസ്`, `അലക്സ്` / `Alex`, `സബിത`, `സെബ`, `സാബു`.
- Malayalam *language* words used to explain the script: `കോൾ`, `വിളിക്കൂ`, `ഡയൽ`,
  `ഹോസ്പിറ്റൽ`, `മരം`, letters and vowel signs.
- `"Sreeraj P"` / `ശ്രീരാജ്` where it is the **app author**, not a contact
  (`app_config.json` snippets, the Manglish-variant example) — this is already public
  app metadata.
- `ZD222DXJ65` (a device serial) and `1044498166` (a key fingerprint) — neither is
  contact data.

## Verification

Both scans from the plan were re-run over `plans/` and `change_log/`:

1. **Phone scan** (`(\+91[ -]?)?[6-9][0-9]{9}` and `+`-prefixed forms) — 31 hits remain,
   every one of them a documentation number (`9876543210`, `+919876543210`,
   `5551234567`, `98765 43210`, `9000123456`, `9111123456`). Zero real numbers.
2. **Name scan** — grep for each redacted Latin name, and a full Unicode sweep of every
   Malayalam-bearing line (143 lines across both folders, read individually). Every
   remaining Malayalam string is a language explanation, a script letter, or one of the
   generic stand-ins listed above. Zero real contact names.
3. Each edited paragraph and table was re-read; the explanations still hold.

Markdown only — nothing to analyze or test.

## Still outstanding (not part of this change)

- **Source and test files also contain the same data.** A repo-wide scan found real
  numbers and/or the same Malayalam contact names in `lib/database/database_helper.dart`,
  `lib/repositories/contact_repository.dart`, `lib/repositories/flagged_number_repository.dart`,
  `lib/screens/dialer_screen.dart`, `lib/utils/malayalam_transliterator.dart`,
  `lib/utils/phone_normalizer.dart`, `lib/widgets/relationship_editor.dart`,
  `lib/voice_dial_parser.dart`, two Kotlin files, and about nine files under `test/`.
  These need their own plan.
- **Git history still holds every original value.** Redacting the working tree does not
  remove it from GitHub. A history rewrite is being planned separately.
