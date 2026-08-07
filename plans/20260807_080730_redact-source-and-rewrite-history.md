# Redact PII from source and tests, then replace the GitHub history

**Status:** in_progress

## The issue

Two problems, in order.

1. **Source code and tests still contain real contact data.** The docs pass
   ([20260807_074611](20260807_074611_redact-pii-from-docs.md)) only covered `plans/`
   and `change_log/`. A repo-wide scan finds the same real names and phone numbers in
   Dart source, Kotlin source, and test fixtures.
2. **The GitHub history holds every original value.** Cleaning the working tree does
   nothing about the 15 commits already pushed to
   `github.com/sreerajp80/SreerajPContactSphere`. Anyone can read the old text from any
   commit.

Order matters: if we rewrote history first, the new history would still carry the
uncleaned source.

## Part 1 — Redact source, tests, and Kotlin

### 1a. Phone numbers

Most numbers in tests are obviously synthetic and stay. Only irregular, real-looking
numbers are replaced. Each is swapped for a synthetic number **of the same length and
leading digit**, so length checks, `+91` handling and trailing-digit matching keep
working.

| Where | Replace with |
| --- | --- |
| `android/.../ContactSphereCallScreeningService.kt:31`, `lib/repositories/contact_repository.dart:195-196`, `lib/repositories/flagged_number_repository.dart:51`, `lib/utils/phone_normalizer.dart:7,8,60`, `test/flagged_number_repository_test.dart`, `test/group_ringtone_test.dart`, `test/phone_normalizer_test.dart` | number A (the one already redacted from the docs) → `9876543210` |
| `android/.../IncomingCallRinger.kt:369`, `lib/repositories/contact_repository.dart:789` | the 7-digit collision pair → `9000123456` / `9111123456` (same trailing-7 collision, so the comment still holds) |
| `test/outgoing_outcome_journal_test.dart` | call-log number → `9876543210` |
| `test/call_log_dedupe_test.dart`, `test/call_outcome_test.dart` | the repeated dedupe fixture number → `9000000010` |
| `test/call_log_dedupe_test.dart` | its second dedupe number → `9000000011` |
| `test/contact_sync_service_test.dart` | the normalized-lookup number → `9000000012`; the merge-fixture number → `9000000013` |
| `test/vcard_service_test.dart` | the landline → `+914840000001`; the mobile → `9000000015` |
| `test/phonetic_duplicate_test.dart` | three duplicate-group fixture numbers → `9000000016`, `9000000017`, `9000000019` |

As with the docs plan, the values being removed are **not** repeated here.

Left alone as clearly synthetic: `9876543210`, `9999999999`, `8888888888`, the
`9000000001-3` / `911111111x` / `9122222222` / `9133333333` / `9144444444` /
`9155555555` / `9188888888` / `9199999999` series, `9995550001-6`, `9995551234`,
`9847000000-2`, `9847012345`, `9876500001-2`, `9988776655`, `9116098765`, `9123400005`,
`9155512345`, `9812345678`, `9956460000`, `9447123456`, and `+15551234567`.

### 1b. Contact names

The same names already removed from the docs, using the **same stand-ins** so the two
sets stay consistent and the recomputed keys are reusable:

| Real value | Stand-in | Files |
| --- | --- | --- |
| the Malayalam nickname + its inflections | `സീത` (`സീതയെ`, `സീതയോട്`, `സീതയ്ക്ക്`) | `lib/repositories/contact_repository.dart`, `lib/screens/dialer_screen.dart`, `lib/utils/voice_dial_parser.dart`, `test/contact_stem_search_test.dart`, `test/voice_dial_parser_test.dart` |
| the English/Malayalam name pair behind the vowel-key bug | `Michael` / `മൈക്കിൾ` | `lib/database/database_helper.dart`, `lib/repositories/contact_repository.dart`, `lib/utils/malayalam_transliterator.dart`, `lib/widgets/relationship_editor.dart`, `test/call_log_search_test.dart`, `test/contact_search_malayalam_test.dart`, `test/contact_search_picker_sheet_test.dart`, `test/db_search_index_test.dart`, `test/name_search_key_test.dart` |
| the name whose two Malayalam spellings already agreed (the stale-key bug) | `Suresh` / `സുരേഷ്` / `സുരേശ്` | `lib/utils/malayalam_transliterator.dart`, `test/call_log_search_test.dart`, `test/contact_search_malayalam_test.dart`, `test/name_search_key_test.dart` |
| a Malayalam given name + surname | `അലക്സ് കുമാർ` | `test/contact_search_malayalam_test.dart` |
| a Malayalam given name + surname (the negative-match fixture) | bare `ലൂക്കോസ്` | `test/contact_search_malayalam_test.dart`, `test/malayalam_transliterator_test.dart` |
| the two Latin trade-name business contacts | `City Time Gallery`, `Kumar Electrician` | `test/contact_search_malayalam_test.dart`, `test/malayalam_transliterator_test.dart` |
| the Soundex-collision fixtures (a hospital business name, an unrelated short personal name, and a relative's nickname) | `Kings Multi Speciality Hospital`, `Kamala`, `Krishnan Uncle` | `test/phonetic_duplicate_test.dart` |
| the doctor's name, in both its spellings | `Dr. Ramakrishnan` / `Dr Ramakhrishnan` | `test/contact_sync_service_test.dart` |
| a relative's nickname, a house name, and a full personal name in one-off fixtures | `രമേഷ് ചേട്ടൻ`, `ശ്രീനിവാസ്`, `സുരേഷ് കുമാർ` | `test/vcard_service_test.dart`, `test/affiliation_key_test.dart`, `test/filename_utils_test.dart` |

Kept as-is: `ശ്രീരാജ്` / `Sreeraj` where it is the **app author** (already public), the
generic examples `രമേഷ്`, `അനു`, `അമ്മ`, `കുമാർ`, and every Malayalam language word and
script letter used to explain the transliterator.

### 1c. Keeping the tests true

Any stand-in that appears in a **transliteration or phonetic assertion** has its expected
key recomputed by running the project's real `searchKey` / `phoneticCode`, exactly as was
done for the docs. Already verified from the docs pass:

- `സീത` → `sita`, `സീതയെ` → `sitaie`, `സീതയോട്` → `sitaiot`, `സീതയ്ക്ക്` → `sitaik`
- `Michael` → `micael` / `mkl`; `മൈക്കിൾ` → `maikil` / `mkl`
- `Suresh`, `സുരേഷ്`, `സുരേശ്` → `sures` / `srs`
- `Thomas`, `തോമസ്` → `tomas` / `tms`
- `സുരേഷ് കുമാർ` and `Suresh Kumar` → both `sures kumar`

Then: `flutter analyze`, and `flutter test` **one file per invocation** (this project's
sqlite-backed tests crash when batched). Every touched test file must pass before Part 2
starts.

## Part 2 — Replace the GitHub history

Chosen approach: **collapse to one fresh commit** and force-push. With 15 commits whose
messages are all variations of "Features and Bug Fixes", nothing of value is lost, and it
cannot leave a missed string behind the way a string-replacement rewrite can.

### Before anything

- **Full backup first.** `git bundle create ../SreerajPContactSphere-backup-<date>.bundle --all`
  plus a copy of the working tree, stored outside the repo. This is the only way back.
- The working tree currently has **198 uncommitted changes**. They will all be part of
  the single new commit. If any of them are not meant to be committed, say so now.
- `.gitignore` is checked so `build/`, `.dart_tool/` and the local `*.db` files (which
  also contain contact data) stay out.

### Steps

1. Verify the tree is clean of PII: re-run the phone scan and the name scan over the
   whole repo, not just `plans/` and `change_log/`.
2. `git checkout --orphan clean-main`
3. `git add -A` — then **review `git status` output** before committing.
4. `git commit -m "Initial commit"` (single commit, no history).
5. `git branch -D main && git branch -m main`
6. `git push --force origin main`

### What this does and does not do

- It **does** replace what anyone sees at that URL: clone, branch view, file history,
  blame — all show only the clean commit.
- It **does not** immediately erase the old commits from GitHub's servers. They become
  unreachable and vanish from normal browsing, but can remain fetchable by exact SHA for
  a period. You chose force-push only, so we stop here. If you later want them purged,
  the documented route is a GitHub Support request; I can draft it.
- Anyone who already cloned or forked the repo keeps the old data. Nothing can change
  that.
- Every commit SHA changes. Any link, note or CI reference to an old SHA breaks.

## Files to be changed

**Part 1 — source (8):** `lib/database/database_helper.dart`,
`lib/repositories/contact_repository.dart`,
`lib/repositories/flagged_number_repository.dart`, `lib/screens/dialer_screen.dart`,
`lib/utils/malayalam_transliterator.dart`, `lib/utils/phone_normalizer.dart`,
`lib/utils/voice_dial_parser.dart`, `lib/widgets/relationship_editor.dart`

**Part 1 — Kotlin (2):**
`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereCallScreeningService.kt`,
`android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`

**Part 1 — tests (~16):** `call_log_dedupe_test.dart`, `call_log_search_test.dart`,
`call_outcome_test.dart`, `contact_search_malayalam_test.dart`,
`contact_search_picker_sheet_test.dart`, `contact_stem_search_test.dart`,
`contact_sync_service_test.dart`, `db_search_index_test.dart`,
`flagged_number_repository_test.dart`, `group_ringtone_test.dart`,
`malayalam_transliterator_test.dart`, `name_search_key_test.dart`,
`outgoing_outcome_journal_test.dart`, `phone_normalizer_test.dart`,
`phonetic_duplicate_test.dart`, `vcard_service_test.dart`, `voice_dial_parser_test.dart`

**Part 2:** no file edits — git operations only.

Plus a change log at `change_log/<timestamp>_redact-source-and-rewrite-history.md`.

## Verification

1. Repo-wide phone scan — only synthetic numbers remain.
2. Repo-wide name scan (Latin list + full Malayalam sweep) — no real contact names.
3. `flutter analyze` clean.
4. `flutter test`, one file per invocation, for every touched test file.
5. After the push: fresh `git clone` into a temp directory, `git log` shows one commit,
   and the two scans come back clean against the clone.

## Risks

- **The force-push is irreversible from the remote's side.** The bundle backup in step 0
  is what makes it recoverable locally. I will not run step 6 until you confirm the
  backup exists.
- Rewriting test fixtures can hide a real regression if a recomputed key is wrong. Every
  key is computed by running the project's own function, not by hand, and every touched
  test must pass.
- The 198 uncommitted files become one commit. If some were experimental, they get
  published.

---

**Do you approve this plan?**
