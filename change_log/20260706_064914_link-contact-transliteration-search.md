# Change log: Link-a-contact transliteration search

Implements plan
[plans/20260706_064914_link-contact-transliteration-search.md](../plans/20260706_064914_link-contact-transliteration-search.md).

## What changed

The "Link a contact" bottom sheet on the relationship screen now searches names the
same way the Contacts page does, including **transliteration search**. Before, it only
matched the literal characters typed; now an English-script (Manglish) query finds a
Malayalam-script name, and Manglish spelling variants (e.g. `sreeraj` / `sriraj`) match
the same contact.

### File

- `lib/widgets/relationship_editor.dart`
  - Added `import '../utils/malayalam_transliterator.dart';`.
  - Rewrote the `_filtered` getter: a contact now matches if the query is a plain
    lowercase substring of its full name **or** `searchKey(query)` is a substring of
    `searchKey(fullName)`. `searchKey(fullName)` equals the stored `name_translit`
    key the Contacts page's DB search matches against, so behavior is consistent.

## Notes / scope

- Phone and email matching (which the Contacts page also does) was intentionally left
  out — the link picker shows and is about names only.

## Verification

- `flutter analyze lib/widgets/relationship_editor.dart` — No issues found.
