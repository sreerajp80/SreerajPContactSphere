# Avatar initial fixed for Malayalam names

Implements [plans/20260729_063000_avatar-initial-overflow.md](../plans/20260729_063000_avatar-initial-overflow.md).

## What was wrong

On the in-call screen, a contact whose name begins `കൊ` showed a big `കെ` in
the avatar circle with a stray `ാ` on a second line, half outside the circle.

`initialFor` returned the whole first grapheme cluster, which for `കൊ` is the
consonant `ക` plus the vowel sign `ൊ`. That sign is *split* — it draws as `െ` to
the left and `ാ` to the right of the consonant — so the "single letter" was
about three glyphs wide. Nothing in the avatars stopped an over-wide letter from
wrapping, so it broke in two.

## What changed

### `lib/utils/malayalam_transliterator.dart`

- New private helper `_isCombiningMark(int code)` — tells whether a code point
  is a combining mark: Indic vowel signs / virama / anusvara / visarga
  (`U+0900`–`U+0DFF` mark slots), Latin combining diacritics
  (`U+0300`–`U+036F`), and variation selectors (`U+FE00`–`U+FE0F`).
- `initialFor` now takes the first grapheme cluster and then keeps only the
  leading run of non-mark code points. So `കൊച്ചി` → `ക`, `രമേഷ്` → `ര`,
  `ചിന്നു` → `ച`. Chillu letters (`ൻ ർ ൽ ൾ ൺ`) are base characters, so they are
  kept. Latin, digits and emoji are unchanged. If stripping would leave nothing,
  the whole cluster is returned instead, so the function never returns empty.
- Doc comment rewritten to explain the split-vowel reason.

### `lib/widgets/avatar_initial.dart` (new)

`AvatarInitial` — the shared widget for a letter drawn inside an avatar. It is a
`Text` with `maxLines: 1`, `softWrap: false`, centred, inside a
`FittedBox(fit: BoxFit.scaleDown)` with a small horizontal padding. A letter
that is still too wide shrinks instead of wrapping or spilling out.

### Screens switched to `AvatarInitial`

Every place that drew an initial did it with its own bare `Text` and no
overflow guard. All now use the shared widget:

- `lib/screens/in_call_screen.dart` (`_identity` — the reported screen)
- `lib/screens/contact_list_screen.dart`
- `lib/screens/contact_detail_screen.dart`
- `lib/screens/call_history_screen.dart`
- `lib/screens/dialer_screen.dart`
- `lib/screens/tag_contacts_screen.dart`
- `lib/screens/relation_status_screen.dart`
- `lib/screens/relationship_screen.dart` (`_NodeAvatar` — it already had its own
  `FittedBox`; that is now the shared widget, keeping its 6px padding)
- `lib/widgets/relationship_editor.dart`

### `test/malayalam_transliterator_test.dart`

New cases: vowel signs stripped (`കൊച്ചി` → `ക`, `ചിന്നു` → `ച`, `രമേഷ്` → `ര`,
result is one character), and chillu kept (`ൻസി` → `ൻ`).

## Checks

- `flutter test test/malayalam_transliterator_test.dart` — 23 tests, all pass.
- `flutter analyze` — no issues found.

Nothing stored in the database changed; the initial is worked out at draw time.
Section headers (`sectionLetterFor`) were not touched — they still come from the
romanized sort key.
