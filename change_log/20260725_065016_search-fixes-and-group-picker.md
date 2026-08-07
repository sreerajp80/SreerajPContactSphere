# Search fixes (Malayalam names, Recents search) and Group field picker

Implements [plans/20260725_061214_search-fixes-and-group-picker.md](../plans/20260725_061214_search-fixes-and-group-picker.md).

Three reported problems: an English-typed name did not find a Malayalam-spelled
contact, Recents had no search, and the Contact Edit screen dumped a list of
groups on screen before the user typed anything.

## 1. Malayalam name search

### What was wrong

Search compares two keys built from the name, not the names themselves. Running
the old key builder on the affected names showed why they never met:

| Typed | key | Malayalam | key |
|---|---|---|---|
| Michael | `micael` | മൈക്കിൾ | `maikil` |
| Suresh | `sures` | സുരേഷ് | `sures` |

* `Michael` was a real code bug — the key kept vowels, and English and Malayalam
  spellings never agree on them.
* `Suresh` was a **different** bug — the two keys already agreed, so the stored
  `name_translit` on the device had drifted from the contact's current name.

### What changed

A new **sound-only key**, `phoneticCode`, in
[lib/utils/malayalam_transliterator.dart](../lib/utils/malayalam_transliterator.dart).
It is general — three rules, no per-name knowledge:

1. drop every vowel, plus `y` and `h` (unreliable: silent, or the aspiration
   half of th/kh/bh),
2. fold each remaining letter to its **sound class** — `k`←k,c,q,g ·
   `t`←t,d · `p`←p,f,b · `s`←s,z · `v`←v,w, with `j n m r l` on their own,
3. collapse repeated letters.

Result: `Michael` and മൈക്കിൾ both give `mkl`; `Suresh`, സുരേഷ് and സുരേശ് all
give `srs`; `Thomas` and തോമസ് both give `tms`.

Letters are kept apart where Malayalam speakers keep them apart — `v` is not
folded into `b` (Vinu ≠ Binu), `n` not into `m`, and `r`/`l`, `j`/`s` stay
separate. `zh` (ഴ) survives the vowel strip intact instead of decaying to `z`.

The code is **added alongside** the existing `name_translit` match, never
replacing it, and it is deliberately guarded: a match must start at a word and
the code must be at least 2 characters (`phoneticCodeMinLen`), so a short query
cannot list the whole address book.

Also new: `nameMatches(query, name)` — one shared "does this match" test, so the
in-memory searches and the SQL-backed ones cannot drift apart.

### Where it is stored and kept fresh

* `contacts.name_phonetic`, added in [database_helper.dart](../lib/database/database_helper.dart)
  (schema **v20 → v21**). The migration adds the column behind a
  `PRAGMA table_info` existence check, not just the version gate, so a DB that
  was version-bumped during development still self-heals.
* Adding the column also **rebuilds `name_translit`** for every row, which
  repairs the stale-key half of the bug.
* `contactSearchName()` now lives in `DatabaseHelper` and is the single source
  of the text both keys are built from. Previously the migrations built it from
  four name parts and the repository from five (it included `formal_name`) —
  the two disagreed, which is itself a way for stored keys to look permanently
  stale.
* `ContactRepository` writes both keys on insert and update.
* Both P2P sync paths now recompute the keys instead of trusting the sender's:
  the full restore rebuilds them after loading, and the merge path recomputes
  per incoming contact (an older peer sends no key at all).

### New: Search index card in Settings → Contacts

Because a derived column can always drift again, drift is now visible and
fixable in the app:

* Reads **"Search index is up to date"** or **"N contacts have out-of-date
  search keys"** — it recomputes each name's keys and compares, so it detects
  real drift rather than guessing.
* A **Rebuild** button rewrites both keys and reports how many rows actually
  changed ("Search index rebuilt — 3 contacts updated").
* Re-checks on open and after any sync or restore.

Backed by two new `DatabaseHelper` methods: `staleContactSearchKeyCount()`
(read-only) and `rebuildContactSearchKeys()` (returns the number changed).

## 2. Search in Recents

* New `CallLogRepository.searchCalls(query)` — the same joined query as
  `recentCalls`, filtered by contact name, formal name, `name_translit`, the
  anchored `name_phonetic` code, and the digits-only phone number (so `9876`
  finds `+91 98765 43210`). Unknown numbers stay searchable by number.
* [call_history_screen.dart](../lib/screens/call_history_screen.dart) gained a
  search bar styled to match the Contacts one, voice input included. Searching
  covers the **whole** history, not just the pages scrolled into memory.
  While a search is active paging is off, clearing it returns to the first
  page, the empty state reads "No calls match that search.", and the
  Clear-history button is hidden — it wipes everything, not the filtered rows
  on screen, which would have been a nasty surprise.

## 3. Group field in the Contact Edit screen

[add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart):
the suggestion chips no longer appear until the user types. Typing filters the
unselected groups; typing `*` lists them all (capped at 20). `*` is treated as
the wildcard, not a group name, so the `+` button cannot create a group called
"*". Hint text is now "Type to search, * for all, or add new".

## Files changed

| File | Change |
|---|---|
| `lib/utils/malayalam_transliterator.dart` | `phoneticCode`, `phoneticMatches`, `nameMatches`, `phoneticCodeMinLen` |
| `lib/database/database_helper.dart` | v21 schema; `name_phonetic`; `contactSearchName`, `ensurePhoneticColumn`, `rebuildContactSearchKeys`, `staleContactSearchKeyCount` |
| `lib/repositories/contact_repository.dart` | Writes `name_phonetic`; phonetic clause in `searchContactSummaries`; shared `_fullNameOf` |
| `lib/repositories/call_log_repository.dart` | New `searchCalls` |
| `lib/screens/call_history_screen.dart` | Recents search bar + search-aware loading, empty state, header |
| `lib/screens/add_edit_contact_screen.dart` | Group suggestions only on typing; `*` wildcard |
| `lib/screens/contacts_settings_screen.dart` | New "Search index" card |
| `lib/screens/groups_screen.dart` | Uses shared `nameMatches` |
| `lib/widgets/relationship_editor.dart` | Uses shared `nameMatches` |
| `lib/services/sync_bundle_service.dart` | Recomputes search keys on restore and on merge |

## Tests

Four new test files (all passing):

* `test/name_search_key_test.dart` — the reported pairs, vowel/aspiration/
  doubling independence, and the "must stay apart" cases (v≠b, n≠m, r≠l, j≠s,
  zh≠z), plus the word-anchoring and minimum-length guards.
* `test/db_search_index_test.dart` — the v21 migration on a pre-v21 table,
  idempotency, and detect-then-repair of a drifted key.
* `test/contact_search_malayalam_test.dart` — end-to-end through the real
  search SQL: `Michael` finds മൈക്കിൾ, `Suresh` finds സുരേഷ് **and** സുരേശ്,
  plain English search is unchanged, unrelated names are not dragged in, and a
  rename leaves no drift behind.
* `test/call_log_search_test.dart` — Recents search by name, by Malayalam name
  typed in English, by digits, plus blank-query and ordering behaviour.

`flutter analyze` is clean. All 30 test files pass (run one file per
invocation — this project's sqlite tests crash when batched).

## Known limits

* The sound code is intentionally loose: a 2-letter code such as `sr` lists
  Suresh, Surya and Sridevi together. Those sit alongside the exact matches,
  never replacing them.
* There is **no fuzzy / near-miss tier**. `Ranjith` still will not find a
  stored `Ranjit`, because their codes differ by a whole letter and SQL `LIKE`
  cannot express edit distance. Closing that gap needs in-memory matching.
* `name_phonetic` is derived, so it can drift again if a future write path
  bypasses the repository. The Settings card is the safety net: drift is now a
  button press to fix, not an app update.
