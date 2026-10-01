# Stop T9 name matches across word breaks

Implements plan: `plans/20261001_210134_t9-no-cross-word-match.md`

## What changed

### `lib/utils/t9_utils.dart`

- The "anywhere in the name" T9 check (score 65) used to join all words of a
  name, remove the spaces, and search the joined digits. That let letters from
  two words join up, so `2662` matched "Chunga**m Ma**nager" and
  "Somashekhar**an Na**ir".
- Now the check runs on each word on its own. A match must sit fully inside
  one word. Fixed in all four places:
  - `isT9Match`: Latin step and direct Malayalam step.
  - `scoreMatch`: Latin step and direct Malayalam step.
- Word-start matches (score 100 / 95) and phone-number matches are unchanged.
  Mid-word matches inside one word still work ("K**anna**n" still matches
  `2662`).
- Updated the `isT9Match` doc comment.
- Ran `dart format` on the file. This put the character maps one entry per
  line, so the diff is larger than the logic change.

### `test/t9_utils_test.dart`

- New test: names whose match only spans a word break do not match and score 0.
- New test: a mid-word match inside one word still matches with score 65.
- File formatted with `dart format`.

## Checks

- `flutter test test/t9_utils_test.dart`: all 11 tests pass.
- `flutter analyze`: no issues found.
