# Change log — update `docs/guidelines` submodule pointer

**Plan:** `plans/20260921_063603_update-guidelines-submodule.md`
**Status:** completed (pointer staged, not committed)

## What changed

- `docs/guidelines` submodule moved from `7e664ba` to `eb4b462` (`origin/master`).
- The new pointer is staged in the superproject index (`git add docs/guidelines`).
- No commit was made and nothing was pushed.

No Dart, Gradle, manifest, schema, or asset file was touched. `flutter analyze` and `flutter test`
were not run because no application code changed.

## Commits picked up

`8c4861a`, `7ed5a36`, `eb4b462` — 20 files, about 2200 lines added.

Main documents updated inside the guidelines repository:

- `flutter_project_engineering_standard.md` (+948 lines)
- `guideline.md` (+340 lines)
- `release_process.md` (+142 lines)
- `CLAUDE_MD_GUIDELINE.md`, `AGENTS_MD_GUIDELINE.md`, `GUIDELINES_MANIFEST.md`, `README.md`,
  `flutter_build_flavors_guide.md`, `docs/release_process_README.md`
- New plan and change-log entries inside the guidelines repository itself

New sections in the engineering standard:

- §7.8 Tooltips on icon-only controls (mandatory)
- §8.3 The three mandatory languages, with §8.3.1 Sanskrit fallback delegate,
  §8.3.2 `intl` formatting under Sanskrit, §8.3.3 fonts and script coverage
- §8.4 In-app language selection (mandatory)
- §8.5 Sanskrit and Malayalam quality glossary
- §8.6 Label conciseness, §8.7 per-feature language completeness,
  §8.8 RTL layout support, §8.9 locale-sensitive formatting
- `release_process.md` §9A Google Play Store readiness gate

## Conflicts found between the new guidelines and this project

These are reported only. Nothing was changed to resolve them — each one needs its own plan.

1. **Three mandatory languages.** The updated guidelines require English (`en`), Malayalam (`ml`)
   and Sanskrit (`sa`) in every app. This project's `CLAUDE.md` declares only `en` and `ml`, and
   `lib/main.dart` sets `supportedLocales: const [Locale('en'), Locale('ml')]`. Sanskrit is absent.

2. **No ARB localization at all.** The guidelines require every user-visible string to come from
   `lib/l10n/*.arb` through `AppLocalizations`. This project has no `l10n.yaml`, no `lib/l10n/`
   directory, no `.arb` files, and no `AppLocalizations` usage. Only the three Global delegates are
   registered, so `ml` currently localizes built-in Material widgets alone; app strings stay
   English literals in widgets.

3. **No Sanskrit fallback delegate.** Flutter ships no Sanskrit framework translation, so §8.3.1
   requires a fallback delegate and a `formattingLocale(...)` helper. Neither exists here.

4. **No in-app language picker.** §8.4 requires a persisted, restart-free language choice in
   Settings. This project has no such setting.

5. **App Bundle language split not disabled.** The flavors guide now requires
   `bundle { language { enableSplit = false } }` in the Android app Gradle file. This project's
   `android/app/build.gradle.kts` has no `bundle` block, so a Play App Bundle would strip
   non-matching language resources.

6. **Google Play readiness gate.** `release_process.md` adds a mandatory §9A gate. This project's
   `docs/release_process.md` has not been checked against it.

Items 1 to 5 are code and configuration work. Item 6 is a documentation review. None of them were
started in this task.

## Verification

- Submodule `git status` is clean at `eb4b462`.
- Superproject `git status` shows `M  docs/guidelines` staged, plus the new plan and this change log
  as untracked files.
