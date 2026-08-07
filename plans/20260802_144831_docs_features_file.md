# Create docs/features.md — full feature list of the app

**Status:** completed

## What is needed

The user wants a new file, `docs/features.md`, that lists every feature of
this app (ContactSphere / smart_contacts_dialer) in one place. The purpose
is to hand this file to another LLM as a reference, so that LLM knows what
the app already does before it is asked to add a new feature. It needs to
be complete and correct in one pass.

## Files to be changed

- **New file:** `docs/features.md`
- No other files are changed. This is a documentation-only addition.

## What will go in the file

1. A short description of what the app is (2-4 sentences): an Android
   Flutter contacts + dialer app, local SQLite (SQLCipher encrypted),
   advanced contact management, calling, sync, backup, security features.

2. A full feature list, grouped by area, written as plain factual bullet
   points (no marketing language), based on reading the actual code
   (screens, services, repositories, native Android Kotlin code) and the
   existing docs (`docs/architecture.md`, `docs/known-gaps.md`,
   `docs/dependencies.md`). Groups will include:
   - Contacts management (add/edit, favorites, groups, tags, duplicate
     merge, relationships, ephemeral contacts, secret contacts, audit log)
   - Dialer / calling (T9 dialer, multi-SIM, default dialer role, in-call
     screen, smart redial, post-call feedback, caller ID, call blocking /
     spam filter, missed-call handling, quick replies, ringtones, recents)
   - Search (text + voice, phonetic/transliteration matching)
   - Sharing / interoperability (vCard, CSV, QR, Bluetooth exchange,
     contact intents, connected apps)
   - Device contacts sync (two-way merge, mirror options)
   - Phone-to-phone LAN sync
   - Backup & restore
   - Security / privacy (encryption, app lock, secret contacts,
     screenshot protection, emergency info card, permissions screen)
   - Localization / accessibility (Malayalam + English)
   - Appearance / theming
   - Navigation / UX gestures
   - Settings surface (full list of settings screens)
   - Native Android platform features (call screening service, BLE
     server, emergency card, etc.)

3. A clearly separated **"Known gaps / not yet implemented"** section
   (call recording, reminder notifications, general state management,
   binary hardening, in-app data purge, iOS/Windows) so the reference
   doesn't overstate what exists.

4. A clearly separated **"Roadmap / aspirational (not implemented)"**
   section for ideas mentioned in `docs/feature_analysis_and_roadmap.md`
   that are not in the code yet, so the other LLM doesn't assume they
   exist.

## Why this shape

The doc must be safe to hand to another LLM as ground truth. Mixing
"implemented" with "planned but not built" would cause that LLM to assume
something exists when it doesn't. Keeping these separate avoids that.

## Sources used

Already gathered by reading: `pubspec.yaml`, `docs/architecture.md`,
`docs/known-gaps.md`, `docs/dependencies.md`, `docs/GUIDELINES_MANIFEST.md`,
the `lib/` directory (screens, services, repositories, models), and the
native Android Kotlin sources under
`android/app/src/main/kotlin/in/sreerajp/contact_sphere/`.

## Out of scope

- No code changes.
- No changes to any existing docs file.
