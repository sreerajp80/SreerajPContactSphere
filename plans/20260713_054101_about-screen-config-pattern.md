# About-screen config pattern (guideline.md §1)

**Status:** completed

## The issue

Guideline §1 (master copy at `l:\Android\Flutter_Guidelines\guideline.md`) mandates
the About screen be driven by a JSON config, through an exact set of paths and
class names. My first pass (already on disk) used a **reconstructed** schema that
does NOT match the real spec. This plan corrects it to conform exactly.

## Deltas from what is currently on disk

- JSON: replace `footer` with `description` + `build`; `details` becomes a plain
  `string → string` map (no `icon` keys).
- `AppConfig`: fields become `appName`, `description`, `version`, `build`,
  `Map<String, String> details`; drop the `AppDetail` class. `fromJson` uses
  per-field fallback helpers (never throws).
- `ConfigService`: add injectable asset loader; `loadAndVerify()` compares
  `version`/`build` against `package_info_plus` and logs a non-fatal debug note
  on mismatch (drops the empty-field verification I invented).
- **New dependency:** add `package_info_plus` to `pubspec.yaml`.
- `pubspec.yaml` assets: register the directory `assets/config/` (not the single
  file).
- About screen: loop `config.details.entries` → `ListTile(title: key,
  subtitle: value)`; skip empties; make an `email` key tappable (`mailto:`);
  render `description` and `version`/`build` as fixed top rows; remove the icon
  mapping.

## Files to change / add

1. **Rewrite** `assets/config/app_config.json` to the spec shape:
   ```json
   {
     "appName": "ContactSphere",
     "description": "Advanced contacts and dialer app with SQLite.",
     "version": "15.8.9",
     "build": "1",
     "details": {
       "Author": "Sreeraj P",
       "Email": "sreerajp@zohomail.in",
       "License": "All libraries used are open source.",
       "AI used": "Anthropic Claude",
       "IDE used": "Visual Studio Code"
     }
   }
   ```
   (`version`/`build` should track `pubspec.yaml`; see open question below.)

2. **Rewrite** `lib/core/config/app_config.dart` per §1.4 reference:
   `AppConfig{appName, description, version, build, Map<String,String> details}`,
   `static const fallback`, `factory fromJson` with per-field fallback.

3. **Rewrite** `lib/core/config/config_service.dart` per §1.5 reference:
   `assetPath` constant, injectable `_loadAsset`, `load()` (fallback on any
   error), `loadAndVerify({PackageInfo?})` using `package_info_plus`.

4. **Rewrite** `lib/screens/about_screen.dart` per §1.6: FutureBuilder on
   `loadAndVerify()`, fixed header (`appName` + `description`) and a
   `version`/`build` row, then loop `details.entries` (skip empty, `mailto:` for
   `email`). Remove `_iconFor` and the icon-per-row design.

5. **Edit** `pubspec.yaml`:
   - Add `package_info_plus` under dependencies.
   - Change the assets entry to `- assets/config/`.

6. Old `lib/constants/app_info.dart` is already removed — no action.

## Open questions (please confirm at approval)

- **`build` number.** The guideline wants `build` in `app_config.json` kept in
  sync with `pubspec.yaml`. `pubspec.yaml` here has no `version:` line at all, so
  there is no build number to mirror. I will use `"build": "1"` and
  `"version": "15.8.9"` for now — tell me if you want a `version:` added to
  `pubspec.yaml` instead (out of scope unless you say so).
- **`description` / `Email`.** I filled `description` from the pubspec
  description and used your known email for the `Email` row. Correct these if you
  want different text.

## Verification

- `flutter pub get` (pulls `package_info_plus`).
- `flutter analyze` clean for the changed files.
- Open the About screen: header, version/build, and every `details` row render
  from the JSON; the Email row opens a mail composer.
- Rename the JSON asset to confirm the fallback renders.

## Out of scope

- No visual redesign beyond what §1.6 dictates; matches the app's existing
  About layout/design system.
