# Change log — disable App Bundle language splitting

**Plan:** `plans/20260921_064500_item5-bundle-language-split.md`
**Status:** completed

## What changed

### `android/app/build.gradle.kts`

Added a `bundle` block inside `android { }`, placed after `buildTypes` and before
`flavorDimensions`:

```kotlin
bundle {
    language {
        enableSplit = false
    }
}
```

A short comment above it names the reason and the standard section, matching the commenting style
used elsewhere in the file.

Google Play splits an App Bundle by language by default. A device set to English would receive only
the English resources. Once the in-app language picker lands (item 4), a user could switch the app
to Malayalam or Sanskrit and find the strings missing. Turning the split off ships every language to
every device.

### `docs/release_process.md`

Added one item to the Artifact Validation part of the release checklist (section 8). It asks the
release builder to confirm the `bundle` block is still present, says what breaks without it, and
asks for a Play internal-test install check that switching the app language still shows translated
text. This is there so a future edit to the Gradle file does not silently drop the setting.

No Dart file was changed. No schema, manifest, asset, or dependency change.

## Verification

- `cd android && ./gradlew :app:tasks --dry-run` — BUILD SUCCESSFUL. The Gradle file configures
  without error. Three deprecation warnings appeared (lines 63, 67 and 99); all three are
  pre-existing and unrelated to the new block.
- `flutter analyze` — no issues found.
- `flutter test` — 526 tests pass.

Note on the test run: the first full `flutter test` run reported one failure in
`test/contact_search_picker_sheet_test.dart` ("a contact is found by typing digits of its number").
That test passes when run on its own, and the full suite passes on a re-run. No Dart code was
touched in this change, so the failure cannot come from it. It looks like an existing flaky test and
is worth a separate look.

A full `flutter build appbundle --flavor prod --release` was not run — the dry-run configuration
check covers the change, and the real effect is only observable on a Play internal-test install,
which is now on the release checklist.

## Not done here

Items 1 to 4 of the localization set (three mandatory languages, ARB string externalization,
Sanskrit fallback delegates, in-app language picker) are untouched. Their plans stay `pending`.
