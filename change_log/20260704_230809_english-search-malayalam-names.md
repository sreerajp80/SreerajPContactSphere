# English search matching Malayalam contact names

Implements [plans/20260704_225549_english-search-malayalam-names.md](../plans/20260704_225549_english-search-malayalam-names.md).

Typing an English/Latin query in Contacts search (e.g. `ramesh`) now matches contacts whose
names are stored in Malayalam script (e.g. `രമേഷ്`), including common Manglish spelling
variants (`sreeraj` / `sriraj` both find `ശ്രീരാജ്`).

## Changes

- **`lib/utils/malayalam_transliterator.dart` (new)** — pure-Dart Malayalam → practical Latin
  ("Manglish") transliterator: consonants + vowel signs, virama/conjuncts, both atomic and
  legacy (consonant+virama+ZWJ) chillus, anusvara/visarga, Malayalam digits; non-Malayalam
  text passes through. `searchKey()` adds the loose normalization applied to both the stored
  name and the query (lowercase; aspirate digraphs th/sh/kh… → base letter, zh preserved;
  w→v, y→i; ee→i, oo→u; doubled letters collapsed; whitespace collapsed).
- **`lib/database/database_helper.dart`** — DB version 11 → 12: new `name_translit TEXT`
  column on `contacts` (also in `_onCreate`), with a v12 migration that backfills the key for
  all existing rows in one batch.
- **`lib/repositories/contact_repository.dart`** — new `_nameSearchKey()` helper;
  `insertContact`/`updateContact` (the only two contact-row write paths) store the key;
  `searchContactSummaries` gains an `OR LOWER(COALESCE(c.name_translit,'')) LIKE ?` clause
  bound to the normalized query.
- **`test/malayalam_transliterator_test.dart` (new)** — 13 unit tests: names, conjuncts,
  chillus, ഴ, anusvara, mixed/pure-Latin passthrough, variant convergence, multi-word
  substring matching.

## Notes

- The plan's encoding warning turned out to be moot: `contact_repository.dart` is plain UTF-8;
  the "binary" grep hits are **two intentional NUL characters inside string literals** (a
  never-match LIKE pattern and a name-key separator). Verified both survived the edits.
- Pre-existing, unrelated test failure: `test/widget_test.dart` expects a Material
  `NavigationBar`, but `home_shell.dart` deliberately uses a custom bottom bar (earlier nav
  redesign) — failing before this change. All other 59 tests + the 13 new ones pass;
  `flutter analyze` is clean.
- Out of scope (per plan): dialer-screen search, Malayalam-query → English-name reverse
  matching, device-only (unsaved) contacts.
