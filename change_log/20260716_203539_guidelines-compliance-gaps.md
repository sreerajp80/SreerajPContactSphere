# Change log — fix two guideline-compliance gaps

Implements plan `plans/20260716_203539_guidelines-compliance-gaps.md`.

## What changed

1. **`assets/config/app_config.json`** — bumped `version` to `15.8.14` and
   `build` to `35` so the About config matches `pubspec.yaml` (`15.8.14+35`).
   Resolves the version/build drift flagged by guideline.md §1.2. (The version
   value was also touched by the user in the editor during the change; final
   state is `15.8.14` / `35`.)
2. **`CLAUDE.md`** — added a one-line pointer under the Project section telling
   readers to follow the guidelines in `docs/GUIDELINES_MANIFEST.md`, as required
   by the manifest usage step 3.

## Verification

- `flutter analyze` — clean, "No issues found!" (no Dart changes were made).
- No test impact (config JSON and Markdown only).

## Not done (out of scope)

Deep section-by-section audit of the 24 engineering-standard sections across all
110 Dart files. The user scoped this task to the two concrete gaps above.
