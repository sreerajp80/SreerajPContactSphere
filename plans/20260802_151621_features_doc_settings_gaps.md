# Fix remaining gaps in docs/features.md (Settings section)

**Status:** completed

## Files to change

- `docs/features.md` (edit only)

## What the issue is

`docs/features.md` has already been through several rounds of review (see
`change_log/20260802_*` entries). This round compared the doc directly
against the actual settings screens in `lib/screens/` — in particular
`contacts_settings_screen.dart`, `contact_sync_settings_screen.dart`,
`sim_settings_screen.dart`, and `about_screen.dart` — rather than trusting
the doc's own earlier self-review. Three real gaps were found:

1. **Section 12, "Contacts settings" subsection is missing three real
   cards/screens.** `contacts_settings_screen.dart` (reached from
   Settings → Contacts) has cards for:
   - **Sync** — opens a dedicated screen (`contact_sync_settings_screen.dart`)
     with four contact actions (merge device→app, merge app→device with an
     account picker, and destructive "mirror" in both directions) plus two
     call-log actions (merge-import from the device call log, and a
     destructive replace). The doc's Section 5 mentions an automatic
     background two-way sync and a "mirror" option in passing, but never
     says these are also manual, user-triggered actions from a named
     screen under Contacts settings, or that call-log import lives there
     too.
   - **Blocked numbers** — Section 2 already says "a dedicated screen to
     manage the blocked/spam number lists" exists, but Section 12 doesn't
     say it's reached from Settings → Contacts.
   - **Relationship names** — Section 1 already describes "an editable
     list of relationship type names" as a feature, but Section 12 doesn't
     say where to find it (Settings → Contacts → Relationship names).

   These three cards exist in the running app today; the doc's own
   "Settings screen" section, which is supposed to be the map of what's
   where, omits them.

2. **Call log import is described as one-way only.** Section 2's Recents
   bullet says "a manual one-way import from the Android system call log
   is also available." In fact `contact_sync_settings_screen.dart` offers
   two distinct modes: a merge-style import (add/update only) and a
   destructive "replace" that clears the app's call history first. Only
   the first is currently implied.

3. **"About" is undersold.** Section 12 lists "About (app version)."
   `about_screen.dart` actually renders a config-driven list of rows
   (version + build number, plus any other key in `app_config.json`, e.g.
   author/email) — it's not just a version string.

## Plan for the fix

Edit `docs/features.md` only:

- In Section 12's "Contacts settings" list, add three bullets: **Sync**
  (device contact merge/mirror + call log import/replace, opened from
  here), **Blocked numbers** (link to the existing block/spam list
  screen), and **Relationship names** (link to the existing relationship
  type-name editor).
- In Section 2's Recents bullet (and/or Section 5), reword the call-log
  import mention to note both a merge-style import and a destructive
  "replace" mode exist.
- In Section 12's top-level list, reword "About (app version)" to make
  clear it shows version/build plus other config-driven app details, not
  just a bare version number.

No other sections change. No code files are touched.

## Do you approve this plan?
