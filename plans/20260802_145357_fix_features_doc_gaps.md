# Fix gaps in docs/features.md

**Status:** completed

## What the issue is

`docs/features.md` was written to be a complete, accurate feature reference
for another LLM to read before adding new features. A critical re-check
against the actual code found it is not fully complete:

1. A whole functional area is missing: call waiting / multi-call handling
   (second incoming call, hold+swap, add-call, merge/conference), and the
   in-call DTMF keypad.
2. The dialpad script support is understated — code supports 7 scripts
   (auto, Malayalam, Devanagari, Cyrillic, Arabic, Greek, none), not just
   "English or Malayalam."
3. Several Contacts-settings items have no home in the doc: search-index
   rebuild tool, name display format (separate from sort order), "hide
   contacts without a phone number," secret-contacts export path, contact
   counts card, "Add Me" shortcut.
4. Section 6 (P2P sync) doesn't mention that app settings are also synced
   (client-wins on full sync, fill-only on incremental).
5. Section 12 claims to be a "full list" of the Settings screen but is not,
   given point 3.
6. The app description intro is single-call-centric and doesn't hint at the
   call-waiting/merge capability.
7. Minor: no caveat that the in-app "Features" showcase screen
   (`features_screen.dart`) contains some aspirational/inaccurate marketing
   copy (e.g. a per-contact notes timeline that doesn't exist) and shouldn't
   be trusted as ground truth on its own.

## Files to be changed

- `docs/features.md` only. No code changes.

## The plan for the fix

In `docs/features.md`:

1. **Intro ("What this app is")** — add a short clause noting the in-call
   experience includes call waiting and merging a second call.
2. **Section 2 (Dialer / calling)** — add bullets for: call waiting
   (answer/reject second call), hold+swap between two calls, adding a
   second outgoing call mid-call, merge/conference calling, and the in-call
   DTMF keypad.
3. **Section 9/10 (Localization, Appearance)** — replace "English or
   Malayalam" dialpad wording with the full list of 7 supported scripts
   (auto-detect, Malayalam, Devanagari, Cyrillic, Arabic, Greek, none).
4. **Section 1 or 12** — add the missing Contacts-settings items: search-
   index health/rebuild, name display format setting, hide-without-phone
   toggle, secret-contacts export (CSV/vCard, biometric-gated), contact
   counts card, "Add Me" shortcut. These will go under section 12 as a
   dedicated "Contacts settings" bullet list, since that's where they live
   in the app (Settings → Contacts).
5. **Section 6 (P2P sync)** — add a bullet noting app settings are also
   synced (client-wins on full sync, fill-only on incremental).
6. **Section 12** — soften "full list of what's there" so it isn't a false
   completeness claim (or just make sure the added detail actually makes it
   complete).
7. **Section 12, "Features" bullet** — add a short caveat that the in-app
   Features showcase screen contains some marketing copy not fully backed
   by the code, so it should not be read as ground truth.
8. Not changing `docs/dependencies.md` — the unused `geolocator` dependency
   is out of scope for this doc fix (separate concern, not part of the
   feature list).

## Why this shape

The doc's stated purpose is to be trustworthy ground truth for another LLM.
The gaps found would cause that LLM to either duplicate an existing feature
(call waiting, DTMF, extra dialpad scripts) or miss that a Settings item
already exists. Fixing these closes that risk without touching any code.
