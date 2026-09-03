# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app (`smart_contacts_dialer`, a.k.a. ContactSphere): an advanced contacts + dialer app
backed by local SQLite. Android is the only platform configured (`android/` exists; no `ios/`,
`web/`, etc.). Dart SDK constraint is `^3.12.0`. This is an **early scaffold** — see
[docs/known-gaps.md](docs/known-gaps.md) before assuming missing symbols are bugs.

Follow the guidelines listed in [docs/GUIDELINES_MANIFEST.md](docs/GUIDELINES_MANIFEST.md)
(shared Flutter conventions, engineering standard, security and release process).

## Commands

```bash
flutter pub get                      # install dependencies (run after editing pubspec.yaml)
flutter run                          # run on a connected device/emulator
flutter analyze                      # static analysis / lint (stock flutter_lints)
flutter test                         # run all tests
flutter test test/widget_test.dart   # run a single test file
flutter test --plain-name "name"     # run tests matching a name
flutter build apk --flavor prod --release --obfuscate --split-debug-info=build/app/outputs/symbols  # production release APK
flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/app/outputs/symbols  # production release AAB
```

Everything goes through the `flutter` CLI — no separate package manager or Makefile.

## Architecture at a glance

Layered, dependency direction **screens → repositories/services → database → models**.
`DatabaseHelper` is a singleton over `sqflite` owning the whole schema; `ContactRepository`
assembles/persists the `Contact` aggregate in transactions; services read/write the DB directly.
Full detail and the table layout are in [docs/architecture.md](docs/architecture.md).

## Detailed docs (read on demand)

- [docs/architecture.md](docs/architecture.md) — layers, responsibilities, and the SQLite schema.
- [docs/known-gaps.md](docs/known-gaps.md) — missing files/classes and why `flutter analyze`
  currently errors. **Read this before debugging "undefined" references.**
- [docs/dependencies.md](docs/dependencies.md) — what each heavy `pubspec` dependency is for.

## Project workflow rules (mandatory)

1. **Plan before changing.** For any change to this project, first write a full plan to `plans/`
   named `yyyymmdd_hhMMss_<short-slug>.md` (local-time prefix). The plan lists the files to change,
   the issue, and the fix. Then **STOP and get explicit approval** before editing/creating/deleting
   any project file (other than the plan itself). Proceed only on an affirmative "yes/approved/go
   ahead" — a question or ambiguous reply is not approval. Re-present and re-approve if the plan
   changes. The only exception is when the user explicitly says to skip the plan for that change.
2. **Log after changing.** After implementing, write a change log to `change_log/` named
   `yyyymmdd_hhMMss_<short-slug>.md`, describing what changed and referencing the plan it implements.

Create `plans/` and `change_log/` if they don't exist.
