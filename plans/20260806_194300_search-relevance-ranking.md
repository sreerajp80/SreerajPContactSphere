# Contact search: relevance ranking and tighter fuzzy matching

**Status:** approval_pending

## The issue

Typing `seb` (or `seba`) lists four unrelated `ഹോസ്പിറ്റൽ` (hospital) contacts, a
`സബിത`-prefixed personal name, and two business rows starting `Sabu` and `SBI` — while
the contact the user actually wants is buried or missing from the top.

### Why it happens

`searchContactSummaries` in [contact_repository.dart:1258](lib/repositories/contact_repository.dart#L1258)
runs one big `OR` query. One of the OR arms is the phonetic arm:

```sql
OR c.name_phonetic LIKE '<code>%' OR c.name_phonetic LIKE '% <code>%'
```

`phoneticCode` in [malayalam_transliterator.dart:170](lib/utils/malayalam_transliterator.dart#L170)
throws away every vowel, `h` and `y`, and folds `p`/`b`/`f` into one class. So:

| text | phonetic code |
|---|---|
| query `seb` / `seba` | `sp` |
| `hospital` (ഹോസ്പിറ്റൽ) | `sptl` |
| `sabitha` (സബിത) | `spt` |
| `sabu` (സാബു) | `sp` |
| `SBI` | `sp` |

The query code `sp` is only 2 letters and is matched as a **prefix of any word**, so it hits
every one of those. Three separate weaknesses combine:

1. **The fuzzy arm is too loose.** A 2-letter code prefix-matching a 4-letter code
   (`sp` → `sptl`) is not a phonetic match, it is a wildcard.
2. **There is no ranking.** Every OR arm is equal, and results are ordered alphabetically
   (`ORDER BY c.sort_first`). A perfect prefix hit on the real name sorts *below* a garbage
   phonetic hit that happens to start with a earlier letter.
3. **The user cannot tell why a row is there.** Fuzzy hits look like bugs because they are
   mixed into the exact hits with no label.

A fourth, separate gap: the literal arms use a single `LIKE '%query%'` over the whole
joined name, so multi-word queries only match in the stored order. `sab kum` and
`kumar sabitha` both find nothing, though `sabitha kumar` works.

This is also why "for certain words the search is perfect" — when the query's phonetic
code is long (4+ letters), the fuzzy arm is naturally selective and only exact hits survive.

## The plan

Keep the current breadth of matching (nothing that matches today stops matching), but
**score every hit, sort by score, and gate the weakest tier.**

### 1. One shared, ranked search path

Add a `ContactSearchRanker` (new file `lib/utils/contact_search_ranker.dart`) that scores a
candidate contact against a query and returns a tier:

| tier | meaning | example (`seb`) |
|---|---|---|
| 0 `exact` | full name or a phone number equals the query | — |
| 1 `prefix` | name, any name word, or formal name **starts with** the query (literal) | `Seba Kumar` |
| 2 `translitPrefix` | Manglish `searchKey` word-prefix match | സെബ → `seba` |
| 3 `contains` | substring in name / email / tag / phone | `Joseba` |
| 4 `phonetic` | sound-only fuzzy match | `Sabu`, `SBI` |

Sorting: tier ascending, then favourite/recently-contacted (already available on the
summary), then `sort_first` as today. Within tier 1–3, an earlier match position wins.

### 2. Tighten the fuzzy tier — by word position, not by length

The phonetic arm was added on purpose (change log `20260730_181113`) and stays. It is what
makes `Ale` → അലക്സ് work: query code `al`, stored `alks` — the translit key `alaks` does
**not** start with `ale`, so only the phonetic arm finds it.

That means a length-based rule is wrong: `Ale`→`alks` (wanted) and `seb`→`sptl` (unwanted)
are the same shape — a short code prefixing a longer one. What separates them is **which
word matched**:

| name | word codes | `seb` = `sp` matches |
|---|---|---|
| a two-word `… ഹോസ്പിറ്റൽ` name | `…` `sptl` | partial, word 2 |
| a three-word `… … ഹോസ്പിറ്റൽ` name | `…` `…` `sptl` | partial, word 3 |
| other `… ഹോസ്പിറ്റൽ` names | … `sptl` | partial, last word |
| സബിത കുമാർ | `spt` `kmr` | partial, word 1 |
| `Sabu …`, `SBI …` | `sp` … | **full**, word 1 |
| അലക്സ് കുമാർ (`Ale` = `al`) | `alks` `kmr` | partial, word 1 |

**Rule:** a *partial* (prefix) phonetic match counts only on the **first** word; a later word
must match the code **in full**. This drops all four hospitals and keeps every case the
phonetic arm was built for.

Surname prefixes are not lost: `kuma` → അലക്സ് കുമാർ is already caught by the translit arm
(`'% kuma%'` against `alaks kumar`). The phonetic arm only has to cover misspellings.

`phoneticCodeMinLen` stays at **2** — no change to duplicate detection.

#### It is only a LIKE-pattern change — no re-index

`contacts.name_phonetic` already stores **one code per name word, space separated**
(a two-word `… ഹോസ്പിറ്റൽ` name → `… sptl`), so word position is expressible in SQL as
it stands:

```sql
-- now
OR c.name_phonetic LIKE '<code>%'  OR c.name_phonetic LIKE '% <code>%'
-- proposed
OR c.name_phonetic LIKE '<code>%'                                    -- first word, partial OK
OR c.name_phonetic LIKE '% <code>' OR c.name_phonetic LIKE '% <code> %' -- later word, full only
```

No schema change, no stored-key change, so **no migration and no key rebuild** for existing
users. `phoneticMatches` in `malayalam_transliterator.dart` gets the same rule for the Dart
paths that use it.

### 3. Hide or label the fuzzy tier

- If there is at least one tier 0–2 hit, the tier-4 (phonetic) block is collapsed under a
  `Similar sounding` divider row, below the good hits.
- If there are no better hits, the fuzzy block shows as today (that is the case where it
  earns its place — misspelled names).

### 4. Multi-word ("token AND") queries

Split the query on whitespace. A contact matches only if **every** token matches something
(any name word, phone, email, tag). This makes `sab kum`, `kumar sab` and
`sabitha kumar` all find സബിത കുമാർ. Single-token queries behave exactly as today.

### 5. SQL vs Dart

Keep one SQL pass as the *candidate filter* (broad, index-friendly, unchanged breadth),
then score and sort in Dart. Result sets here are tens-to-hundreds of rows, so ranking in
Dart costs nothing and is directly unit-testable — unlike a `CASE`-expression score in SQL.
The SQL filter gains only the tightened phonetic bounds and the per-token clauses.

### 6. Apply everywhere search happens

Route the pickers through the same ranked helper so behaviour is identical:
contact list, contact picker sheet, multi-picker sheet, tag contacts screen, dialer.

## Files to change

| file | change |
|---|---|
| `lib/utils/contact_search_ranker.dart` | **new** — tiers, scoring, token-AND matching |
| `lib/utils/malayalam_transliterator.dart` | `phoneticMatches`: partial match only on the first word, later words need a full code match. `phoneticCodeMinLen` unchanged |
| `lib/repositories/contact_repository.dart` | `searchContactSummaries`: per-token clauses, tightened phonetic arm, rank results through the ranker; return tier with each hit |
| `lib/screens/contact_list_screen.dart` | render the `Similar sounding` divider before the fuzzy block |
| `lib/widgets/contact_search_picker_sheet.dart` | use the shared ranked search |
| `lib/widgets/contact_multi_picker_sheet.dart` | use the shared ranked search |
| `lib/screens/tag_contacts_screen.dart` | use the shared ranked search |
| `lib/screens/dialer_screen.dart` | use the shared ranked search for the name path (T9 digit path untouched) |
| `test/contact_search_ranker_test.dart` | **new** — `seb` must not return hospitals above a real `Seba`; tier order; token-AND cases |
| `test/contact_search_malayalam_test.dart` | extend: existing Malayalam cases must still pass |
| `test/malayalam_transliterator_test.dart` | update for the new code floor and length bound |
| `docs/features.md` | describe the ranked search and the `Similar sounding` section |

## Risks / notes

- The phonetic arm is **kept**, not removed — it is the only thing that finds a misspelled
  or differently-transliterated name. The change is where it is allowed to match partially,
  plus where its hits are ranked.
- Duplicate detection (`phoneticNameMatches` → `phonetic_duplicate_test.dart`) is untouched:
  it compares whole names, not query prefixes, and the floor stays at 2.
- No DB migration and no schema change — `name_translit` / `name_phonetic` stay as they are.
- Stale `name_translit` rows in old prod data are a separate, already-known issue and are
  not addressed here.

## Verification

- `flutter analyze`
- `flutter test` (sqlite-backed files run one file per invocation)
- **First, on device: Settings → Contacts → Search index must read "up to date".** A drifted
  `name_translit` makes a contact silently unfindable, which looks identical to a ranking
  bug — rule it out before judging any search result. The card should stay at 0 stale after
  this change, since no stored key changes.
- Then on device: `seb`, `seba`, `sabitha`, `sab kum`, `ഹോസ്പിറ്റൽ`, `Ale`/`Alex`,
  `kuma`, `sreeraj`/`sriraj`, and a deliberately misspelled name to confirm the fuzzy tier
  still rescues it.
