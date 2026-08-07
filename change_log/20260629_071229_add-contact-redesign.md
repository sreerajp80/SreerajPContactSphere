# Change log — Add Contact screen full redesign

Implements [plans/20260629_071229_add-contact-redesign.md](../plans/20260629_071229_add-contact-redesign.md).
Redesigns the Add/Edit contact screen to match
[sample/AddContactScreen.dc.html](../sample/AddContactScreen.dc.html), with full
light/dark support and real persistence for every section.

## Data layer

- **`lib/database/database_helper.dart`**
  - Bumped DB version `2 → 3`.
  - Added `social_links` and `tags` child tables (new `_createSocialLinksAndTags`),
    created in both `_onCreate` and the `oldVersion < 3` branch of `_onUpgrade`
    (additive migration; existing rows untouched).
  - Added FK indexes `idx_social_links_contact_id` and `idx_tags_contact_id`.
- **`lib/models/social_link.dart`** *(new)* — `SocialLink {id, contactId, label,
  value, isPrimary}` with `toMap`/`fromMap`.
- **`lib/models/contact.dart`** — added child collections `List<SocialLink>
  socialLinks` and `List<String> tags`; imported `social_link.dart`.
- **`lib/repositories/contact_repository.dart`**
  - `_insertChildren` now also writes `social_links`, `tags` (trimmed,
    de-duplicated via `_insertTags`), and group memberships (`_insertGroupMemberships`
    creates any missing group by name, then inserts into `contact_groups`).
  - `updateContact` adds `social_links`, `tags`, and `contact_groups` to the
    wholesale child-delete list so edits replace them cleanly.
  - `_hydrate` loads `socialLinks` (`_getSocialLinks`) and `tags` (`_getTags`);
    groups were already hydrated.

## UI

- **`lib/screens/add_edit_contact_screen.dart`** — full rewrite to the design:
  - `_Tokens` resolves the design's CSS variables (field/border/caption/
    accentSoft/accentText/avatar gradient + shadow/track) from `Theme` +
    `AppColors`, so the screen follows the Calm (light) and Midnight (dark)
    themes with no hardcoded palette.
  - Custom top bar (back, centered title, accent-soft save check) and sticky
    avatar header (gradient circle, add/change-photo badge) over a scrolling
    sectioned body.
  - Signature label-on-top filled fields (`_shell` / `_inputField` /
    `_bareTextField`), date fields (`_dateField` → `showDatePicker`), and
    menu-button fields (`_menuButton`).
  - Sections: **Name** (salutation, first* , middle, last, blood group),
    **Personal details** (gender chip-picker with custom + DOB / anniversary /
    meetiversary date pickers), **Phone numbers** and **Emails** (preset label
    menu + "+ Custom", value, primary star, add/remove), **Tags** (chips with
    remove, add field/enter, dashed suggestion chips), **Add to group** (toggle
    chips from `GroupRepository` + "+ New group" dialog), **Social links**
    (preset platform menu + custom, no primary star per design), **Personal
    address** (multiple collapsible cards, add/remove), **Work address**
    (company + office address → `type='official'`), **Official details**
    (designation, department), and the styled **Secret contact** toggle.
  - Dashed-border affordances ("+ Custom", "Add …", "+ New group",
    suggestions) drawn via `_DashedChip` / `_DashedBorderPainter`.
  - Mutable row state via `_LabeledEntry` (phones/emails/socials), `_GroupChip`,
    and `_AddressEntry`; all controllers disposed.
  - Full edit-mode prefill: existing phones/emails/socials/tags/groups, gender
    (preset vs custom), all dates, multiple personal addresses, the official
    address, and official details. Save maps primary flags, de-duplicated tags,
    selected groups, and only non-empty addresses; first name is required
    (inline error + snackbar).

## Verification

- `flutter analyze` — **No issues found.**
- `flutter test` — **All tests passed** (interaction repo + widget smoke test).
