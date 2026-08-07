# Link-a-contact transliteration search

**Status:** completed

## The issue

On the relationship screen, the **"Link a contact"** bottom sheet has a "Search
contacts" box. Its search does **not** behave like the Contacts page search. In
particular, **transliteration search does not work**: an English-script (Manglish)
query does not match a contact whose name is stored in Malayalam script, and Manglish
spelling variants (e.g. `sreeraj` vs `sriraj`) are not absorbed.

### Root cause

- The Contacts page searches through the database via
  `ContactRepository.searchContactSummaries` ([lib/repositories/contact_repository.dart:768](../lib/repositories/contact_repository.dart#L768)).
  That query matches the query's romanized key `searchKey(q)` against the stored
  `contacts.name_translit` column, which is `searchKey(fullName)`. This is what makes
  English-script → Malayalam matching (and Manglish variant folding) work.
- The "Link a contact" sheet (`_RelationshipEditorSheetState._filtered`,
  [lib/widgets/relationship_editor.dart:95-99](../lib/widgets/relationship_editor.dart#L95-L99))
  loads all contacts into memory and filters with a plain
  `c.fullName.toLowerCase().contains(q)`. There is no transliteration step, so it can
  only match on the literal characters typed.

`Contact.fullName` ([lib/models/contact.dart:150](../lib/models/contact.dart#L150))
joins salutation + first + middle + last with spaces — exactly the same composition
`_nameSearchKey` uses to build `name_translit`. So `searchKey(c.fullName)` in memory
equals the stored `name_translit` value, and we can reproduce the DB behavior locally.

## The fix

Update the `_filtered` getter in `relationship_editor.dart` so it matches the Contacts
page's name matching: a hit is either a plain lowercase substring match on the full
name **or** a transliteration-key substring match (`searchKey(query)` inside
`searchKey(fullName)`).

Note: the Contacts page also matches phone and email. The link picker only shows and is
about names, so this change covers name matching (plain + transliteration), which is
what the report is about. Phone/email matching is intentionally out of scope.

Planned new logic (in `relationship_editor.dart`):

```dart
List<Contact> get _filtered {
  final q = _query.trim();
  if (q.isEmpty) return _all;
  final like = q.toLowerCase();
  final key = searchKey(q);
  return _all.where((c) {
    if (c.fullName.toLowerCase().contains(like)) return true;
    return key.isNotEmpty && searchKey(c.fullName).contains(key);
  }).toList();
}
```

Add the import:

```dart
import '../utils/malayalam_transliterator.dart';
```

## Files to change

- `lib/widgets/relationship_editor.dart`
  - Add `import '../utils/malayalam_transliterator.dart';`.
  - Rewrite the `_filtered` getter to also match on the transliteration key.

## Verification

- `flutter analyze` on the changed file — no new errors.
- Manual: open a contact → relationships → "Link a contact"; type a Manglish query for
  a Malayalam-named contact and confirm it now appears; confirm a plain English query
  still filters as before.
