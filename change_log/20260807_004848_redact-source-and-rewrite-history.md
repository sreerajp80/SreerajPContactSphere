# Redacted PII from source and tests, and replaced the GitHub history

Implements [plans/20260807_000730_redact-source-and-rewrite-history.md](../plans/20260807_000730_redact-source-and-rewrite-history.md).

## Part 1 — source, Kotlin and tests

### Phone numbers

Real numbers replaced with synthetic ones of the same length and leading digit, so
length checks, `+91` handling and trailing-digit matching still behave identically.

| Files                                                                                                                                                                                               | Change                                                                                                                                        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `android/.../ContactSphereCallScreeningService.kt`, `lib/repositories/contact_repository.dart`, `lib/repositories/flagged_number_repository.dart`, `lib/utils/phone_normalizer.dart` (doc comments) | the main example number → `9876543210` / `+919876543210` / `+91 98765 43210`                                                                  |
| `android/.../IncomingCallRinger.kt`, `lib/repositories/contact_repository.dart`                                                                                                                     | the 7-digit collision pair → `9000123456` / `9111123456`, which still share their last 7 digits (`0123456`), so the comment's reasoning holds |
| `test/call_log_dedupe_test.dart`, `test/call_outcome_test.dart`                                                                                                                                     | dedupe fixture number → `9000000010`                                                                                                          |
| `test/call_log_dedupe_test.dart`                                                                                                                                                                    | second dedupe number → `9000000011`                                                                                                           |
| `test/contact_sync_service_test.dart`                                                                                                                                                               | normalized-lookup number → `9000000012`; merge-fixture number → `9000000013`                                                                  |
| `test/vcard_service_test.dart`                                                                                                                                                                      | landline → `+914840000001`; mobile → `9000000015`                                                                                             |
| `test/phonetic_duplicate_test.dart`                                                                                                                                                                 | three group fixtures → `9000000016`, `9000000017`, `9000000019`                                                                               |
| `test/outgoing_outcome_journal_test.dart`                                                                                                                                                           | call-log number → `9000000018`                                                                                                                |
| `test/flagged_number_repository_test.dart`, `test/group_ringtone_test.dart`, `test/phone_normalizer_test.dart`                                                                                      | the same main number, including its spaced (`98765 43210`) and `0`-prefixed (`098765-43210`) forms                                            |

**One deviation from the plan.** The plan said the call-log number would become
`9876543210`. It became `9000000018` instead, because `9876543210` is already used
elsewhere in the same test files and reusing it would have made distinct fixtures
collide. Same effect, safer for the tests.

Left alone as clearly synthetic: `9876543210`, `9999999999`, `8888888888`, the
`9000000001-3` / `911111111x` / `9122222222` / `9133333333` / `9144444444` /
`9155555555` / `9188888888` / `9199999999` series, `9995550001-6`, `9995551234`,
`9847000000-2`, `9847012345`, `9876500001-2`, `9988776655`, `9116098765`,
`9123400005`, `9155512345`, `9812345678`, `9956460000`, `9447123456`, `+15551234567`.

### Contact names

Same stand-ins as the docs pass, so both sets stay consistent:

| Stand-in                                                                                                                  | Files                                                                                                                                                                                                                                                                                                                                                             |
| ------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `സീത` + inflections `സീതയെ` / `സീതയോട്` / `സീതയ്ക്ക്` (and `സീതന` for the prefix-only fixture)                                       | `lib/repositories/contact_repository.dart`, `lib/screens/dialer_screen.dart`, `lib/utils/voice_dial_parser.dart`, `test/contact_stem_search_test.dart`, `test/voice_dial_parser_test.dart`                                                                                                                                                                        |
| `Michael` / `മൈക്കിൾ`                                                                                                        | `lib/database/database_helper.dart`, `lib/repositories/contact_repository.dart`, `lib/utils/malayalam_transliterator.dart`, `lib/widgets/relationship_editor.dart`, `test/call_log_search_test.dart`, `test/contact_search_malayalam_test.dart`, `test/contact_search_picker_sheet_test.dart`, `test/db_search_index_test.dart`, `test/name_search_key_test.dart` |
| `Suresh` / `സുരേഷ്` / `സുരേശ്`                                                                                                  | `lib/utils/malayalam_transliterator.dart`, `test/call_log_search_test.dart`, `test/contact_search_malayalam_test.dart`, `test/name_search_key_test.dart`                                                                                                                                                                                                          |
| `അലക്സ് കുമാർ`, bare `ലൂക്കോസ്`, `City Time Gallery`, `Kumar Electrician`                                                         | `test/contact_search_malayalam_test.dart`, `test/malayalam_transliterator_test.dart`                                                                                                                                                                                                                                                                              |
| `Kings Multi Speciality Hospital`, `Kamala`, `Krishnan Uncle`                                                             | `test/phonetic_duplicate_test.dart`                                                                                                                                                                                                                                                                                                                               |
| `Dr. Ramakrishnan` / `Dr Ramakhrishnan` (keeps the period-vs-no-period **and** internal-`h` difference the test is about) | `test/contact_sync_service_test.dart`                                                                                                                                                                                                                                                                                                                             |
| `രമേഷ് ചേട്ടൻ`, `ശ്രീനിവാസ്`, `സുരേഷ് കുമാർ`                                                                                            | `test/vcard_service_test.dart`, `test/affiliation_key_test.dart`, `test/filename_utils_test.dart`                                                                                                                                                                                                                                                                 |

Kept: `ശ്രീരാജ്` / `Sreeraj` as app author, the generic examples `രമേഷ്`, `അനു`,
`അമ്മ`, `കുമാർ`, `ചിന്നു`, `ൻസി`, `അക്കു`, `ഉണ്ണിക്കണ്ണൻ`, and every Malayalam language
word and script letter the transliterator tests depend on.

### Keeping the tests honest

A blind find-and-replace left several assertions saying something false. Each was found
by running the tests and fixed properly, not by loosening the assertion:

- `lib/utils/malayalam_transliterator.dart` — the `phoneticCode` doc comment still
  claimed the codes `jkp` / `rns`. Corrected to `mkl` / `srs`.
- `test/name_search_key_test.dart` — four assertions had lost their meaning:
  - the vowel-variation pair became `Suresh` vs `Sirosh` (both `srs`);
  - the doubling/aspiration pair became `Michael` vs `Micchaell` (both `mkl`);
  - the mid-word negative test became `res` inside `Suresh`;
  - the substring test became `chae` inside `Michael`.
- `test/flagged_number_repository_test.dart`, `test/contact_sync_service_test.dart`,
  `test/phone_normalizer_test.dart` — spaced number forms (`88481 06085`,
  `+91 90725 30113`) were missed by the digit-only replacement and made three tests
  fail. Fixed.

Every stand-in key was computed by running the project's own `searchKey` /
`phoneticCode` in a throwaway test, which was deleted afterwards. Verified values:
`സീത`→`sita`, `സീതയെ`→`sitaie`, `സീതയോട്`→`sitaiot`, `സീതയ്ക്ക്`→`sitaik`;
`Michael`/`മൈക്കിൾ`→`micael`/`maikil`, both `mkl`; `Suresh`/`സുരേഷ്`/`സുരേശ്`→`sures`,
`srs`; `Thomas`/`തോമസ്`→`tomas`, `tms`; `സുരേഷ് കുമാർ` = `Suresh Kumar` = `sures kumar`.

### Also fixed

`plans/20260807_000730_...` (this plan itself) originally listed the real numbers and
names in its inventory tables — the same mistake caught in the docs pass. Rewritten to
name each item by what it was and where, never by value.

### Checks

- `flutter analyze` — **No issues found!**
- `flutter test`, one file per invocation, for all 16 touched test files —
  **all passed**: `malayalam_transliterator_test`, `name_search_key_test`,
  `voice_dial_parser_test`, `affiliation_key_test`, `filename_utils_test`,
  `call_log_search_test`, `contact_search_malayalam_test`,
  `contact_search_picker_sheet_test`, `contact_stem_search_test`,
  `db_search_index_test`, `phonetic_duplicate_test`, `contact_sync_service_test`,
  `vcard_service_test`, `phone_normalizer_test`, `flagged_number_repository_test`,
  `group_ringtone_test`.
- Repo-wide sweep (numbers + Latin names + full Malayalam Unicode walk over every file
  outside `.git`, `build/`, `.dart_tool/`) — clean.

## Part 2 — GitHub history replaced

### Backup taken first

`git bundle create ../SreerajPContactSphere-backup-20260807.bundle --all` — 2,136,781
bytes, `git bundle verify` reports *"The bundle records a complete history"*, old HEAD
`b898b34`. **This file is the only copy of the old 15-commit history. Do not delete it
until you are sure you will never need it.**

### What was done

1. Confirmed the working tree was PII-clean (scans above).
2. Reviewed every untracked file before staging — all legitimate source, tests, plans
   and change logs. No databases, keystores, `key.properties`, `.env` or certificates.
   `.gitignore` already excludes `build/`, `.dart_tool/` (where the sqflite test
   databases live) and `*.jks` / `*.keystore`.
3. `git checkout --orphan clean-main`, `git add -A` — 832 files staged.
4. Single commit `2e0c9ca "Features, fixes and documentation"`, with the user-supplied
   list of the 46 original change descriptions as the body, so the record of what was
   built survives even though the individual commits do not.
5. `git branch -D main` (was `b898b34`), `git branch -m main`.
6. `git push --force origin main` → `+ b898b34...2e0c9ca main -> main (forced update)`.

### Verified after the push

Fresh `git clone` of `github.com/sreerajp80/SreerajPContactSphere` into a temp
directory:

- `git rev-list --count --all` → **1**
- `git log` → the single commit `2e0c9ca`
- number scan → no hits
- Latin name scan → no hits
- full Malayalam name scan → **CLONE IS CLEAN**

The temp clone was deleted afterwards.

## Limits you should know about

- **Force-push only, by choice.** GitHub can keep the old commits fetchable by exact
  SHA for a period even though they are unreachable and gone from all normal views.
  The documented way to purge them is a GitHub Support request — say the word and I
  will draft it.
- **Existing clones and forks keep the old data.** Nothing done here can change that.
- **Every commit SHA changed.** Any saved link, note or CI reference to an old SHA is
  now dead.
- If you have this repo checked out anywhere else, that copy still has the old history
  and will conflict on the next pull. It needs a fresh clone, not a merge.
