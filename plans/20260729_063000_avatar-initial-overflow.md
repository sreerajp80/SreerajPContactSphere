# Avatar initial breaks for Malayalam names

**Status:** completed

## The issue

On the in-call screen for a contact whose name begins `കൊ` (for example the word
`കൊച്ചി`), the avatar circle shows a large `കെ` with a stray `ാ` pushed onto a
second line, half outside the circle.

Two separate causes:

1. **`initialFor` keeps the vowel sign.** It returns the first *grapheme cluster*.
   For `കൊ` that is the consonant `ക` plus the vowel sign `ൊ`. In Malayalam `ൊ`
   is a **split** vowel: it renders as a left part `െ` and a right part `ാ`
   around the consonant. So one "letter" is about three glyphs wide — far wider
   than an English `R`.

2. **No avatar guards against overflow.** The initial is drawn with a plain
   `Text` at a fixed font size inside a fixed-size circle. Nothing stops it from
   wrapping to a second line or spilling past the circle, so the wide Malayalam
   letter breaks apart exactly as seen in the screenshot.

Cause 1 alone would still look cramped in the small 44px list avatars; cause 2
alone would shrink the text to an unreadable size. Both need fixing.

## The fix

### 1. Strip combining marks from the initial

In `lib/utils/malayalam_transliterator.dart`, change `initialFor` so that after
taking the first grapheme cluster it drops any trailing combining marks
(Unicode category Mn — the Malayalam vowel signs `ാ ി ീ ു ൂ െ േ ൊ ോ ്` and the
same class of marks in Devanagari, Tamil, Arabic, and accented Latin that is
already decomposed). What is left is the base consonant, e.g. `കൊ` → `ക`,
`ചി` → `ച`, `രമേഷ്` → `ര`.

Rules to keep it safe:

- Only drop marks. Never return an empty string — if removing marks leaves
  nothing (a name that starts with a bare combining mark), keep the original
  grapheme cluster.
- Latin, digits and emoji are unaffected (they have no trailing Mn marks in
  practice), so English initials keep working exactly as now.
- Chillu letters (`ൻ ർ ൽ ൾ ൺ`) are their own base characters, not marks, so they
  survive untouched.

The range check is a small explicit list of combining-mark blocks rather than a
full Unicode table, so no new dependency is needed:
Malayalam/Indic vowel signs and viramas (`U+0900–U+0DFF` mark sub-ranges),
combining diacritics (`U+0300–U+036F`), and the general marks block
`U+FE00–U+FE0F` (variation selectors). Keep this documented in the doc comment.

### 2. Make every avatar initial overflow-proof

Add a small shared widget so all avatars behave the same instead of each screen
re-styling a `Text`. New file `lib/widgets/avatar_initial.dart` with
`AvatarInitial` — a `Text` that is:

- `maxLines: 1`, `softWrap: false`, `textAlign: TextAlign.center`,
- wrapped in a `FittedBox(fit: BoxFit.scaleDown)` inside a padded box, so a
  letter that is still too wide shrinks instead of wrapping or clipping.

Then use it at every place that draws an initial today.

## Files to change

| File | Change |
| --- | --- |
| `lib/utils/malayalam_transliterator.dart` | `initialFor` drops trailing combining marks; update the doc comment |
| `lib/widgets/avatar_initial.dart` | **new** — `AvatarInitial` overflow-proof text widget |
| `lib/screens/in_call_screen.dart` | use `AvatarInitial` in `_identity` (the screen in the report) |
| `lib/screens/contact_list_screen.dart` | use `AvatarInitial` |
| `lib/screens/contact_detail_screen.dart` | use `AvatarInitial` |
| `lib/screens/call_history_screen.dart` | use `AvatarInitial` |
| `lib/screens/dialer_screen.dart` | use `AvatarInitial` |
| `lib/screens/tag_contacts_screen.dart` | use `AvatarInitial` |
| `lib/screens/relation_status_screen.dart` | use `AvatarInitial` |
| `lib/screens/relationship_screen.dart` | use `AvatarInitial` in `_NodeAvatar` |
| `lib/widgets/relationship_editor.dart` | use `AvatarInitial` |
| `test/malayalam_transliterator_test.dart` | new cases for the mark-stripping |

Nothing else changes: `sectionLetterFor` keeps using the romanized sort key, so
A–Z section headers are untouched. Stored data is untouched — the initial is
computed at draw time only.

## Tests

Add to `test/malayalam_transliterator_test.dart`:

- `initialFor('കൊച്ചി')` → `'ക'` (the split vowel sign is gone).
- `initialFor('രമേഷ്')` → `'ര'` (virama gone, still one character).
- `initialFor('ചിന്നു')` → `'ച'`.
- `initialFor('ൻസി')` → `'ൻ'` (chillu is a base letter, kept).
- Existing English and empty-name cases keep passing.

Run `flutter test test/malayalam_transliterator_test.dart` and `flutter analyze`.

## Manual check

On device, the in-call screen for a `കൊ`-initial contact should show a single
clean `ക` centred in the circle, and the contact list row for the same contact
should match.
