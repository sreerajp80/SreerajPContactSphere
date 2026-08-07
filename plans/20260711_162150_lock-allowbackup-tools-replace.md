# Lock android:allowBackup=false against manifest-merger overrides

**Status:** completed

## Issue

`android/app/src/main/AndroidManifest.xml` sets `android:allowBackup="false"` on the
`<application>` tag. Today this value survives the merge in every build variant (verified
in the merged manifests). But if a future dependency ships a manifest that sets
`android:allowBackup="true"`, the manifest merger could raise a conflict or override our
value. We want our `false` to always win the merge, permanently.

## Fix

Use the manifest merger's `tools:replace` marker so our attribute wins unconditionally.

Files to change (1):

- `android/app/src/main/AndroidManifest.xml`
  1. Add the tools namespace to the root `<manifest>` tag:
     `xmlns:tools="http://schemas.android.com/tools"` (currently only `xmlns:android`
     is declared).
  2. Add `tools:replace="android:allowBackup"` to the `<application>` tag, alongside the
     existing `android:allowBackup="false"`.

No Dart/Kotlin/Gradle changes. No behavior change beyond making the backup setting
override-proof at merge time.

## Verification

- `flutter build apk --flavor prod` (or the dev flavor) so the manifest is re-merged.
- Grep the merged manifests under
  `build/app/intermediates/merged_manifests/**/AndroidManifest.xml` to confirm
  `android:allowBackup="false"` is still present in every variant and the build did not
  fail on a merge error.
