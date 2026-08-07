# Change log — Ringtone preview no sound (persistable content-URI fix)

Implements plan
[plans/20260703_171128_ringtone-preview-no-sound.md](../plans/20260703_171128_ringtone-preview-no-sound.md).

## Problem

Previewing (and ringing with) an audio-file ringtone picked via "Audio file" produced no
sound. Root cause: `file_selector`'s `openFile()` returns a throwaway **cache copy** path
on Android; the OS evicts it, so the stored path is dead by preview/ring time.
`audioplayers.play()` doesn't throw for a missing file, so the failure was silent.
Affected both the per-SIM ringtone screen and the per-contact ringtone picker.

## Approach

Switched audio-file picks from `file_selector` (copy-to-cache) to a native **Storage
Access Framework** document pick that takes a **persistable read grant** on the file's
`content://` URI. The tone now references the original file and survives restarts with no
copy. Added graceful "revert to default" when a tone's backing file later goes missing.

## Changes

### Native

- **android/.../MainActivity.kt**
  - Added `pickAudioDocument` method-channel handler → launches
    `ACTION_OPEN_DOCUMENT` (`audio/*`, `CATEGORY_OPENABLE`) with read +
    persistable-read grant flags, under new request code `REQ_OPEN_AUDIO`.
  - `onActivityResult` `REQ_OPEN_AUDIO` branch → `persistAudioDocument(uri)`:
    `takePersistableUriPermission` + `{uri, title}` (display name via
    `OpenableColumns.DISPLAY_NAME`); empty map on cancel.
  - Added `pendingAudioResult` field, `displayName()` helper, `OpenableColumns` import.
  - `previewRingtone` now **returns Boolean** (false when the source can't be opened, e.g.
    a deleted file); the channel returns that value instead of `null`.

- **android/.../IncomingCallRinger.kt**
  - `playUri` now returns `Boolean` (false when `setDataSource` throws).
  - `setCustomTone` falls back to the **default ringtone** when the custom tone can't be
    opened, so a missing custom tone still rings audibly instead of going silent.

### Dart

- **lib/services/telecom_service.dart**
  - Added `pickAudioDocument()` → `({path, label})?` (path is a `content://` URI).
  - `previewRingtone` changed from `Future<void>` to `Future<bool>`.

- **lib/screens/ringtone_settings_screen.dart**
  - `_pickForSim` audio branch now uses `_telecom.pickAudioDocument()`.
  - `_togglePreview` uses the preview Boolean; added a legacy-file `existsSync` guard;
    on a missing tone calls new `_revertMissingTone` → message + `setSimRingtone(id, null)`.
  - Removed `file_selector` / `path` imports; added `dart:io`.

- **lib/screens/add_edit_contact_screen.dart**
  - `_pickRingtone` audio branch now uses `_telecom.pickAudioDocument()`.
  - `_toggleRingtonePreview` uses the preview Boolean + legacy `existsSync` guard; added
    `_revertMissingTone` → message + clears `_ringtonePath`/`_ringtoneLabel` (saved on Save).
  - Removed the now-unused `file_selector` import.

## Deviation from the approved plan

The plan included a `releaseAudioDocument` grant-cleanup call on replace/clear. **Dropped
during implementation:** a persisted URI can be shared (same audio file set on two SIMs, or
a SIM and a contact), and releasing on one would revoke the others. `takePersistableUriPermission`
is idempotent, so grants are bounded by the number of *distinct* files ever picked (small,
far below the OS limit) — accumulation isn't a real risk. Auto-release was therefore net
harmful and removed from both the native and Dart sides.

## Verification

- `flutter analyze` on the three changed Dart files: **No issues found**.
- No tests reference the changed methods (`test/conference_call_test.dart` is unaffected).
- Kotlin reviewed manually. A Gradle compile could **not** be run: the environment has
  **JDK 24 + Gradle 8.12**, which fails at configuration time while creating the
  `:audioplayers_android:testDebugUnitTest` task ("Type T not present") — a pre-existing
  toolchain incompatibility unrelated to these changes.
- Device testing still recommended once the toolchain can build: (1) pick an audio tone
  for a SIM and a contact, restart the app, preview → sound; place a call → rings;
  (2) delete the source file → preview shows the message and reverts; call rings on default;
  (3) system `content://` tones still preview and ring.

## Caveats

- Contacts/SIMs that already stored a dead `file_selector` cache path can't be migrated —
  they now show "no longer available" and revert to default on preview, and work once
  re-picked.
