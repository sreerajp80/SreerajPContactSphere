# Change log — Create docs/features.md

Implements: `plans/20260802_144831_docs_features_file.md`

## What changed

- Added a new file, `docs/features.md`.
- No code files were touched. No other docs were changed.

## What the file contains

- A short description of what ContactSphere is.
- A full feature list grouped into 13 areas: contacts management, dialer/
  calling, search, sharing/interoperability, device contacts sync,
  phone-to-phone sync, backup & restore, security/privacy, localization/
  accessibility, appearance/theming, navigation/gestures, the settings
  screen, and native Android platform features.
- A "Known gaps / not yet implemented" section (call recording, reminder
  notifications, general state management, release build hardening,
  in-app data wipe, no iOS/desktop support), kept separate from the
  implemented feature list.
- A "Roadmap / aspirational — NOT implemented" section for ideas from
  `docs/feature_analysis_and_roadmap.md` that are not built yet.

## How it was built

Read `pubspec.yaml`, `docs/architecture.md`, `docs/known-gaps.md`,
`docs/dependencies.md`, `docs/GUIDELINES_MANIFEST.md`, the full `lib/`
directory (screens, services, repositories, models), and the native
Android Kotlin sources under
`android/app/src/main/kotlin/in/sreerajp/contact_sphere/`, to make sure
every listed feature is grounded in real code rather than assumed.

## Purpose

The file is meant to be given to another LLM as a reference of what this
app already does, so that LLM does not duplicate existing features or
assume unimplemented ones exist when asked to add something new.
