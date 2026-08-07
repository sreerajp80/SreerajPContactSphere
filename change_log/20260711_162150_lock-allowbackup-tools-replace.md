# Lock android:allowBackup=false against manifest-merger overrides

Implements plan `plans/20260711_162150_lock-allowbackup-tools-replace.md`.

## What changed

- `android/app/src/main/AndroidManifest.xml`:
  - Added `xmlns:tools="http://schemas.android.com/tools"` to the root `<manifest>`
    tag (previously only `xmlns:android` was declared).
  - Added `tools:replace="android:allowBackup"` to the `<application>` tag, next to the
    existing `android:allowBackup="false"`, with an explaining comment.

This makes our `allowBackup="false"` win the manifest merge unconditionally, so no
future dependency manifest can flip it back to `true`.

No Dart/Kotlin/Gradle changes; no runtime behavior change.

## Verification

- `flutter build apk --debug --flavor dev` — built successfully, no manifest-merge error.
- Merged manifest
  `build/app/intermediates/merged_manifests/devDebug/processDevDebugManifest/AndroidManifest.xml`
  still contains `android:allowBackup="false"` (line 147).
