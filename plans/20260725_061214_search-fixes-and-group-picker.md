# Search fixes (Malayalam names, Recents search) and Group field picker

**Status:** completed

## The three issues

### 1. Malayalam names do not match their English spelling

Typing `Michael` does not list `മൈക്കിൾ`. Typing `Suresh` does not list `സുരേഷ്`.

I ran the current key builder on the affected names. This is what it produces:

| Typed | key | Malayalam | key |
|---|---|---|---|
| Michael | `micael` | മൈക്കിൾ | `maikil` |
| Suresh | `sures` | സുരേഷ് | `sures` |
| Thomas | `tomas` | തോമസ് | `tomas` |

Two separate problems:

* **The keys keep too much detail.** English spelling and Malayalam spelling
  never agree on vowels (`Mi`chael vs `മൈ` = "mai"), so `micael` and `maikil`
  can never meet.
* **Stale stored keys.** For `Suresh` the two keys *do* agree today, so the
  live code should already match it. That points at the stored
  `contacts.name_translit` value on the device being stale — a known problem
  this project has hit before (there is already a v14→v15 repair migration for
  exactly this).

#### The general fix — a phonetic class code

Rather than patch individual letter pairs (`c`→`k` and so on), the mismatches
all fall into three rules that hold for **every** name, so no per-name
knowledge is ever needed:

1. **Vowels are unreliable.** Which vowel is written, and whether one is
   written at all, is a typist's guess.
2. **Consonant detail is unreliable** — aspiration (`th`/`t`), voicing
   (`d`/`t`), silent `h`, and which letter was picked for a sound
   (`c`/`k`/`q`, `f`/`ph`, `sh`/`s`).
3. **Doubling is unreliable** — `ക്ക` is typed `kk` or `k`.

So the new key drops every vowel and maps each remaining letter to a **sound
class**, then collapses repeats:

| step | folds | Michael | മൈക്കിൾ |
|---|---|---|---|
| drop vowels, `y`, `h` | a e i o u y h | `mcl` | `mkkl` |
| class fold | K←k,c,q,g · T←t,d · P←p,f,b · S←s,z · J←j · N←n · M←m · R←r · L←l · V←v,w · Z←zh | `MKL` | `MKKL` |
| collapse doubles | | `MKL` | `MKL` ✓ |

The same machinery, unchanged, gives:

| Name | code | Malayalam | code |
|---|---|---|---|
| Michael | `mkl` | മൈക്കിൾ | `mkl` |
| Suresh | `srs` | സുരേഷ് / സുരേശ് | `srs` |
| Thomas | `tms` | തോമസ് | `tms` |

Classes are kept apart where Malayalam speakers genuinely keep them apart:
`v` is not folded into `b` (Vinu ≠ Binu), `n` is not folded into `m`, and
`r`/`l` and `j`/`s` stay separate. Only the confusions that actually happen
are folded.

The existing `name_translit` match stays exactly as it is — the class code is
an **extra** way to match, so nothing that works today stops working.

**Conservative anchoring** (your choice): the class code is only used when the
query code is at least 2 characters, and it must match at the **start of a
word** in the stored code (`jkp%` or `% jkp%`), never in the middle of one.

**Chosen engine** (your choice): the code is stored in a `contacts` column and
matched with SQL `LIKE`, alongside the existing `name_translit` clause. Known
trade-off, stated plainly: a stored derived column can go stale again, which
is half of this very bug. Mitigations are in the plan — the column is rewritten
on every insert/update, backfilled by the migration, and rebuilt after a
restore. There is no edit-distance/fuzzy tier, because SQL `LIKE` cannot
express one.

### 2. No search in the Recents screen

Recents has no way to find a call. It needs a search box like the one on the
Contacts screen, matching by contact name (English or Malayalam) and by number.

### 3. Group field in the Contact Edit screen lists all groups up front

`_groupsSection()` in the edit screen shows the first 6 existing groups as
chips before the user types anything. The user wants the field to stay quiet
until they type: typing filters the groups, and typing `*` lists all of them.

## Files to change

| File | Change |
|---|---|
| `lib/utils/malayalam_transliterator.dart` | New `phoneticCode()` (drop vowels → class fold → collapse doubles); new shared `nameMatches(query, name)` used by the in-memory searches |
| `lib/database/database_helper.dart` | Bump schema version 20 → 21; add `name_phonetic` column to `contacts` (in `CREATE TABLE` and as a migration); backfill `name_phonetic` **and** rebuild `name_translit` for every row |
| `lib/repositories/contact_repository.dart` | Write `name_phonetic` on insert and update; add the anchored class-code clause to `searchContactSummaries` |
| `lib/repositories/call_log_repository.dart` | New `searchCalls(query, {limit})` — call history filtered by name / number / translit / class code |
| `lib/screens/call_history_screen.dart` | Add the search bar (same look as Contacts, with the voice button) and run the search when the box is non-empty |
| `lib/screens/add_edit_contact_screen.dart` | `_groupsSection()`: show nothing when the box is empty, filter as the user types, show all on `*`; update the hint text |
| `lib/screens/groups_screen.dart` | Use the shared `nameMatches` so its member search behaves the same |
| `lib/widgets/relationship_editor.dart` | Same |
| `lib/services/sync_bundle_service.dart` | After a full restore, rebuild `name_translit` + `name_phonetic` (restored rows come from the backup verbatim and an old backup has neither) |
| `lib/screens/contacts_settings_screen.dart` | New "Search index" card: shows how many contacts have out-of-date keys, and a button to rebuild them |
| `test/name_search_key_test.dart` (new) | Cover the pairs above, plus "must NOT match" cases guarding against over-matching |

## Plan of work

1. **`phoneticCode(String)`** in the transliterator: transliterate → lowercase →
   delete `[aeiouyh]` → map each remaining letter through the class table →
   collapse repeated letters → collapse spaces. `zh` is folded to its own class
   before `h` is dropped, so it stays distinct from `z`. Add
   `nameMatches(query, name)` returning true on either the existing `searchKey`
   substring match or the anchored class-code match, so the in-memory searches
   and the SQL searches agree on what "matches" means.

2. **Migration v21.** Add `name_phonetic TEXT` to the `contacts` create
   statement, and in `_onUpgrade` add the column guarded by a
   `PRAGMA table_info(contacts)` existence check (not just the version gate —
   this project has already been bitten by a dev version bump running ahead of
   its migration). Then backfill `name_phonetic` for every row and rebuild
   `name_translit` at the same time, which heals the stale-key half of issue 1.

3. **Contact repository.** `_nameSearchKey` gets a sibling `_namePhonetic`;
   both are written in `insertContact` and `updateContact`.
   `searchContactSummaries` gains
   `OR (:code <> '' AND (c.name_phonetic LIKE 'code%' OR c.name_phonetic LIKE '% code%'))`,
   skipped entirely when the query code is under 2 characters.

4. **Call log repository.** `searchCalls` runs the same joined query as
   `recentCalls` with a WHERE over: joined contact name LIKE, digits-only
   phone number LIKE, `c.name_translit` LIKE, and the anchored
   `c.name_phonetic` clause. Same ordering (newest first) and the same row
   mapping, so the screen can treat the results identically.

5. **Recents screen.** Add `_searchController` / `_searchFocusNode` /
   `_searchQuery`, a `_buildSearch` widget copied in style from
   `contact_list_screen.dart` (rounded fill, search icon, voice button when
   empty, clear button when not), and route `_load()` through `searchCalls`
   when the query is non-empty. While searching: paging is off (a single
   larger limit), the day grouping still applies, and the empty state reads
   "No calls match that search." The clear button restores the normal paged
   list.

6. **Group field.** In `_groupsSection()`: empty box → no suggestion chips;
   `*` → every unselected group; anything else → case-insensitive "contains"
   filter over unselected groups (cap 20). Hint text becomes
   `Type to search, * for all, or add new`. The `+` button and Enter still
   create a new group exactly as they do now.

7. **Search index card in Settings → Contacts** (handles the stale-column
   risk without needing a new migration each time). Two repository methods:

   * `staleSearchKeyCount()` — reads every contact's name and its two stored
     keys, recomputes both, and counts the rows that disagree. Read-only.
   * `rebuildSearchKeys()` — rewrites both keys for every contact in one
     batch, and returns how many rows it actually changed.

   The card sits under the existing counts card and reads either
   "Search index is up to date" or "N contacts have out-of-date search keys",
   with a **Rebuild** button. After a rebuild it shows a snackbar
   ("Search index rebuilt — N contacts updated") and re-checks, so the user
   gets confirmation rather than a silent action. The check runs when the
   screen opens and after any sync/restore, reusing the same
   `ContactSyncService().onSyncCompleted` listener the counts card already
   uses.

   This means a future stale-key bug is a button press, not an app update.

8. **Tests + checks.** New key test file, then `flutter analyze` and
   `flutter test`. Note: this project's sqlite-backed tests must be run one
   file per invocation.

## Risks

* The class code is deliberately loose — a 2-letter code such as `sr` will
  list Suresh, Surya and Sridevi together. Those results sit alongside the exact
  matches, never replacing them, and word-start anchoring keeps the list from
  growing beyond names that really do start with that sound.
* `name_phonetic` is a derived column and can therefore go stale, the same way
  `name_translit` did. The mitigations above cover the write paths I know of
  (insert, update, restore); a future write path that bypasses the repository
  would reintroduce the problem. The Settings card is the safety net for that
  case — it detects the drift and repairs it on demand, so a stale index is no
  longer a bug that has to wait for a migration.
