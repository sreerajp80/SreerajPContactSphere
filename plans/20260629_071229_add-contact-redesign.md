# Add Contact screen — full redesign (light + dark)

**Status:** completed

## Issue / goal

The current `AddEditContactScreen`
([lib/screens/add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart))
is a plain Material `Form` with a handful of fields. The approved design
([sample/AddContactScreen.dc.html](../sample/AddContactScreen.dc.html)) is a far
richer, custom-styled screen with light **and** dark variants. We need to
implement the design **completely**, wiring every section to persistence.

### What the design contains (and current backend status)

| Design section | Backend today |
|---|---|
| Name: salutation, first*, middle, last, blood group | ✅ on `Contact` |
| Personal details: gender (chip picker + custom), DOB, anniversary, meetiversary | ✅ on `Contact` |
| Phone numbers: label (preset menu + custom), value, **primary star**, add/remove | ✅ `PhoneNumber` (label/type/isPrimary) |
| Emails: same shape as phones | ✅ `Email` |
| Tags: chips + add + suggestions | ❌ **no table/model** |
| Add to group: toggle chips + new group | ⚠️ `groups`/`contact_groups` tables exist but repository never writes them |
| Social links: platform (preset menu + custom), value, primary, add/remove | ❌ **no table/model** |
| Personal address (**multiple**, collapsible): street/city/state/postal/country | ⚠️ `Address` supports it but screen only does one |
| Work address: company, office/street, city/state/postal/country | ✅ `Address` (`type='official'`, `company_name`) |
| Official details: designation, department | ✅ `OfficialDetails` |
| Secret contact: toggle | ✅ `Contact.isSecret` |

**Decision (confirmed with user):** add real DB persistence for Tags and
Social links (schema migration v2 → v3), and wire group membership.

### Theme / light-dark approach

The design's two CSS palettes already match the app's existing themes:
- light `--bg #eef4f3`, accent `#0d9488` ≈ **Calm** theme (`AppTheme.calm`)
- dark `--bg #0a0c16`, accent `#7c8aff` = **Midnight** theme (`AppTheme.midnight`)

So we do **not** add new colors. The screen derives the design's tokens
(`field`, `fieldBorder`, `caption`, `accentSoft`, `accentText`, avatar
gradient/shadow) from `Theme.of(context)` + the existing `AppColors`
extension, so light/dark follow the user's selected theme automatically.

## Files to change

### Data layer
1. **`lib/database/database_helper.dart`** — bump version `2 → 3`; add `tags`
   and `social_links` tables in `_onCreate`; create both in `_onUpgrade`
   (`oldVersion < 3`); add FK indexes for them.
2. **`lib/models/social_link.dart`** *(new)* — `SocialLink {id, contactId,
   label, value, isPrimary}` with `toMap`/`fromMap`.
3. **`lib/models/contact.dart`** — add `List<String> tags = []` and
   `List<SocialLink> socialLinks = []` (child collections, not contact columns).
4. **`lib/repositories/contact_repository.dart`**
   - `_insertChildren`: also insert `social_links`, `tags`, and group
     memberships (create missing groups by name, then `contact_groups`).
   - `updateContact`: add `social_links`, `tags`, `contact_groups` to the
     wholesale child-delete list before re-inserting.
   - `_hydrate`: load `socialLinks` and `tags` (groups already loaded).

### Tables (new)
```sql
CREATE TABLE social_links (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  contact_id INTEGER,
  label TEXT,
  value TEXT NOT NULL,
  is_primary INTEGER DEFAULT 0,
  FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
);
CREATE TABLE tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  contact_id INTEGER,
  name TEXT NOT NULL,
  FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
);
```

### UI
5. **`lib/screens/add_edit_contact_screen.dart`** — full rewrite to the design.
   New private widgets / helpers (all in this file to keep the change local):
   - `_DesignTokens` — resolves design CSS vars from theme (light/dark aware).
   - `_FieldShell` — rounded filled container with uppercase caption + a
     borderless `TextField` (the design's signature input). Variants for
     plain text, date (taps a date picker), and a "menu" button (label picker).
   - `_SectionHeader` — accent square + bold title.
   - `_LabeledRepeater` — generic phone/email/social row builder with the
     label-pill menu (preset chips + "+ Custom"), value field, primary star,
     and add/remove. Backed by a small `_LabeledEntry` controller-holder.
   - Gender chip picker (preset chips + custom text), DOB/anniversary/
     meetiversary date fields.
   - Tags: chip list with remove, add field (enter / + button), suggestion
     chips from a pool minus already-added.
   - Groups: toggle chips loaded from `GroupRepository.getAllGroups()`, plus
     "+ New group" (prompt dialog → create).
   - Multiple personal addresses: collapsible cards with add/remove.
   - Work address + official details blocks.
   - Secret toggle styled as the design's pill switch (use Material `Switch`
     themed to match).
   - App bar: back button, centered "Add contact" / "Edit contact", round
     accent-soft check button that saves.
   - Avatar header with gradient circle, add-photo badge, "Add photo" caption
     (keeps existing `image_picker` flow).

## Plan for the fix

1. Add `social_links` + `tags` tables and migration (v3); add FK indexes.
2. Add `SocialLink` model; extend `Contact` with `tags` + `socialLinks`.
3. Extend `ContactRepository` to persist/hydrate socials, tags, and groups.
4. Rewrite the screen to the design with the widgets above, theme-derived
   tokens for light/dark, and full edit-mode prefill (load existing tags,
   socials, groups, both address types, multiple personal addresses).
5. On save: map gender (preset or custom), all dates, primary flags
   (phones/emails/socials), de-duplicated tags, selected groups, non-empty
   personal addresses (`type='personal'`), work address (`type='official'`),
   official details, secret flag. Validation: first name required (matches
   the design's "First name *").
6. `flutter analyze` must be clean; existing `flutter test` smoke test stays
   green.

## Out of scope / notes
- No changes to the contact **detail** screen rendering of tags/socials in
  this plan (data persists; surfacing it elsewhere can follow separately).
- DB bump is additive only; existing rows are untouched by the v3 upgrade.

## Change log
To be written to `change_log/` on completion.
