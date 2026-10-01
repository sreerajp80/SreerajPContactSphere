# Item 5 — Disable App Bundle language splitting

**Status:** completed

Part of a five-plan set that brings this project in line with the updated
`docs/guidelines` submodule (commit `eb4b462`). Run order: 1st. It has no dependency on the other
four and can land on its own.

## The issue

Engineering standard §8.1 and the updated `flutter_build_flavors_guide.md` both now require:

```kotlin
// android/app/build.gradle.kts
android {
    bundle {
        language {
            enableSplit = false
        }
    }
}
```

Google Play defaults to splitting Android App Bundles by language. A user on an English phone would
be served English resources only. If they then switch the app to Malayalam or Sanskrit with the
in-app picker (item 4), the strings would be missing on the device.

`android/app/build.gradle.kts` has no `bundle` block. The `android { }` block starts at line 85 and
contains `compileOptions` (90), `kotlinOptions` (98), `defaultConfig` (102), `signingConfigs` (115),
`buildTypes` (127), `flavorDimensions` (160) and `productFlavors` (162).

This is worth doing first and separately because it affects the release artifact, it is independent
of the Dart work, and it is the kind of setting that is easy to forget once the bigger localization
work starts.

## Files to be changed

| File | Change |
|---|---|
| `android/app/build.gradle.kts` | Add a `bundle { language { enableSplit = false } }` block inside `android { }` |
| `docs/release_process.md` | Note the setting in the release checklist, so a future edit does not silently drop it |

No Dart file changes.

## The plan for the fix

1. Add the `bundle` block inside `android { }` in `android/app/build.gradle.kts`, placed after
   `buildTypes` and before `flavorDimensions`, with a short comment naming the reason and the
   standard section, matching the commenting style already used in that file.
2. Add a line to the release checklist in `docs/release_process.md`.
3. Verify the Gradle file still parses: `cd android && ./gradlew :app:tasks --dry-run` (or a
   `flutter build appbundle --flavor prod --release` if you want the full check — that is slower).
4. Run `flutter analyze` and `flutter test` for completeness, though no Dart changed.

## Tests

None automated. Gradle configuration is not unit-testable here.

Verification is a build check: the Gradle file configures without error, and a `prod` App Bundle
still builds. The real effect — that all language resources stay on the device — is only observable
through a Play internal-test install, which goes on the release checklist rather than into CI.

## Risk

Very low. One additive configuration block with no behavioural effect on debug or APK builds.

The only cost is a slightly larger download for users, because every language ships to every device.
With three languages and text-only resources this is negligible. Note that once item 1 bundles a
Devanagari font, that font is part of the base APK anyway and is not affected by language splitting.

## Explicitly out of scope

- Any Dart or localization work (items 1 to 4).
- Other App Bundle split settings (`density`, `abi`). The project already uses `--split-per-abi` for
  APK releases; the standard does not ask for changes there.
