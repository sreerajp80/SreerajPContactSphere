# Stop T9 name matches across word breaks

**Status:** completed

## Files to change

- `lib/utils/t9_utils.dart`
- `test/t9_utils_test.dart`

## The issue

On the dialer, typing `2662` shows contacts like "SBI Chungam Manager" and
"Somashekharan Nair". Their names do not have a word that contains `2662`.

The cause is the "anywhere in the name" rule in `T9Utils`. It turns the whole
name into digits, **removes the spaces**, and then looks for the typed digits
anywhere in that string. So letters from the end of one word and the start of
the next word join up:

- "Chunga**m Ma**nager" → `2662`
- "Somashekhar**an Na**ir" → `2662`

The same rule exists in four places:

- `isT9Match`: Latin step (`fullT9` with spaces removed) and direct Malayalam
  step (`mlT9Text` with spaces removed).
- `scoreMatch`: Latin step and direct Malayalam step (the score 65 branch).

## The fix

Keep the "anywhere in a word" match (score 65), but check it **one word at a
time**, not on the joined name. A match must sit fully inside one word.

- In each of the four places, replace the joined `fullT9.contains(...)` check
  with a loop over the words: match if any single word's T9 digits contain the
  typed digits.
- Word-start matches (score 100 / 95) and phone-number matches do not change.
- "Kannan" (കണ്ണൻ) still matches `2662`, because "anna" is inside the one word
  "kannan".

## Tests

Add tests to `test/t9_utils_test.dart`:

- `isT9Match('SBI Chungam Manager', '2662')` is false, and `scoreMatch(...)`
  with a number that does not contain the digits returns 0.
- `isT9Match('Somashekharan Nair', '2662')` is false.
- `isT9Match('Kannan', '2662')` is still true (inside one word), and its
  score is 65.

Then run `flutter analyze` and `flutter test test/t9_utils_test.dart`.
