# Contact detail screen: render all stored fields

Implements [plans/20260705_111843_contact-detail-missing-fields.md](../plans/20260705_111843_contact-detail-missing-fields.md).

## Changed

- `lib/screens/contact_detail_screen.dart` (only file):
  - **Social links** — one tile per `socialLinks` entry (link icon, value as title,
    platform label as subtitle), after the emails block. Previously hydrated but
    never rendered.
  - **Birthday / Anniversary / Meetiversary** — tiles after the addresses block,
    shown when the date is set, formatted as `19 March 1980` via a small local
    `_formatDate` helper (no new dependency).
  - **Gender** and **Blood group** — tiles shown when non-blank.
  - **Tags** — a chip `Wrap` after the groups chips, each tag prefixed `#` to
    distinguish free-text tags from group memberships.
  - **Empty-address guard** — address tiles are now skipped when
    `Address.formatted` is empty, fixing the blank tile that showed only the type
    label (e.g. an all-empty "official" address).

## Verified

- `flutter analyze lib/screens/contact_detail_screen.dart` — no issues.
- Built `flutter build apk --debug --flavor dev` and installed on device
  `ZD222DXJ65` (`in.sreerajp.contact_sphere.dev`). A test contact ([name]) has
  `dob` and `anniversary` stored in `smart_contacts.db`; these now render as
  Birthday / Anniversary tiles.

## Notes

- Every field the add/edit screen can store is now rendered on the detail screen
  when it holds data. Internal fields (`relationshipScore`, `isSecret`,
  `deviceId`, timestamps) remain intentionally unsurfaced.
- The edit screen persisting an all-empty address row (the data-side artifact)
  remains a possible follow-up; the detail screen now hides such rows.
