# Plan: sixth gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md`

## What the issue is

The user asked for a critical review of `docs/features.md` to check all features
are listed and the app description (intro) is complete. This doc has already
had five gap-fill passes today. A fresh, independent cross-check of the whole
codebase (screens, services, `app_settings.dart`, widgets, models,
repositories, native Kotlin code, and the intro paragraph) against the doc
found the doc is now largely accurate, but two small gaps remain:

1. **Intro paragraph (lines 8–32) is missing ephemeral contacts.** The app has
   a fully-implemented "self-destructing" contact feature (expire after a set
   time or after one call, never synced to device contacts, auto-deleted by a
   background check) — see `lib/models/contact.dart`
   (`isEphemeral`/`ephemeralExpiresAt`/etc.) and
   `lib/services/ephemeral_contact_service.dart`. It already has a full bullet
   in section 1 (lines 73–76), but the intro summary — which is what a
   first-time reader sees first — never mentions it. It's a distinctive
   privacy feature on the same level as the security items already named in
   the intro (app lock, secret contacts, emergency card, audit log), so its
   absence makes the intro less inclusive than it should be.

2. **Section 12 / known-gaps note (line 389) has a stale count.** The doc says
   `AppSettings` "covers around 27 persisted settings." Counting the actual
   `static const String _k...` keys in `lib/state/app_settings.dart` (and
   excluding the two legacy/migration-only keys) gives 30, not ~27. This is
   likely left over from before the Smart Redial toggle/delay/message and
   screenshot-guard settings were added in earlier passes today.

## The fix

1. In the intro paragraph, add a short clause naming ephemeral
   (self-destructing) contacts alongside the other privacy/security features
   already listed there.
2. Change "around 27 persisted settings" to "around 30 persisted settings" in
   section 12's known-gaps note.

No other gaps were found — screens, services, native Kotlin classes, models,
and the Known Gaps / Roadmap sections all still match the code.
