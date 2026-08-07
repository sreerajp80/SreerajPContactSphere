# Ringtone preview produces no sound (per-SIM & per-contact)

**Status:** completed

## The issue

Previewing a ringtone that was picked via **"Audio file"** produces no sound. This
affects both:

- the **per-SIM ringtone** screen ([lib/screens/ringtone_settings_screen.dart](../lib/screens/ringtone_settings_screen.dart)), and
- the **per-contact ringtone** picker ([lib/screens/add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart)) — user-confirmed.

### Root cause

When the user picks an audio file, both screens store `file.path` returned by
`file_selector`'s `openFile()` **verbatim**:

- `ringtone_settings_screen.dart:360` → `RingtoneRef(path: file.path, ...)`
- `add_edit_contact_screen.dart:565` → `_ringtonePath = file.path`

On Android, `file_selector` does **not** return the real file location. It copies the
SAF-selected file into the app's **cache** directory and returns a path to that
temporary copy (e.g. `.../cache/file_selector/Alaipayuthey_Instru_1.mp3`). The OS may
evict cache files at any time, and they do not reliably survive an app restart.

So by the time the user hits Preview (or when a call actually rings), the stored path
points at a file that no longer exists:

- Preview: `AudioPlayer.play(DeviceFileSource(path))` hands a missing file to
  `MediaPlayer`, which fails silently. The `BLASTBufferQueue` / `cleanDrmObj` lines in
  the log are just release-time noise. audioplayers' `play()` does **not** throw for a
  missing source (it reports asynchronously), so the `try/catch` never fires and no
  error shows — the button flips to "Stop" and stays silent.
- Ring time: `TelecomService.setIncomingRingtone(path)` gets a dead path too.

Phone/system ringtones (`content://` URIs, e.g. the Jio default) are unaffected — they
are stable URIs previewed through the native player.

## Approach chosen: persistable `content://` URI (no file copy)

Instead of copying the audio into app storage, the app will take a **persistable read
permission** on the picked file's `content://` URI
(`ContentResolver.takePersistableUriPermission`). This references the original file —
**near-zero extra storage** — and the grant survives reboots. `file_selector` can't do
this (it copies to cache and hides the URI), so a small native SAF picker is added.

**Breakage handling (revert to default):** a persisted URI breaks only if the source
file is later deleted/moved or its storage is unmounted. In that case:
- the native ringer falls back to the **system default** tone (today it would go
  silent — this is fixed here), and
- preview reports the failure so the UI shows a message and clears the override
  (reverting that SIM/contact to the default).

`content://` system ringtones and the CSV-import use of `file_selector`
([lib/services/export_import_service.dart](../lib/services/export_import_service.dart))
are unchanged. The `file_selector` dependency stays (still used for CSV import).

## Changes

### 1. Native — [android/.../MainActivity.kt](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt)

- Add method-channel handler `pickAudioDocument`: launches
  `Intent(ACTION_OPEN_DOCUMENT)` with `type = "audio/*"`,
  `CATEGORY_OPENABLE`, and flags `FLAG_GRANT_READ_URI_PERMISSION |
  FLAG_GRANT_PERSISTABLE_URI_PERMISSION`, under a new request code `REQ_OPEN_AUDIO`.
- In `onActivityResult` for `REQ_OPEN_AUDIO`: call
  `contentResolver.takePersistableUriPermission(uri, FLAG_GRANT_READ_URI_PERMISSION)`,
  resolve the display name via `OpenableColumns.DISPLAY_NAME`, and return
  `{uri, title}` (empty map on cancel), mirroring the existing `pickRingtone` result
  shape.
- Add `releaseAudioDocument(uri)` handler → best-effort
  `releasePersistableUriPermission` so replaced/cleared tones don't accumulate grants.
- Change `previewRingtone` to **return a Boolean** (true when playback started). The
  missing-file case throws synchronously at `MediaPlayer.setDataSource`, so return
  `false` there; the method-channel handler returns that value instead of `null`.

### 2. Native ringer — [android/.../IncomingCallRinger.kt](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt)

- Make `playUri` return `Boolean` (false when `setDataSource` throws).
- In `setCustomTone`, when `playUri(customUri)` returns false, fall back to
  `playUri(defaultRingtoneUri())` so a missing custom tone still rings on default
  instead of going silent.

### 3. Dart bridge — [lib/services/telecom_service.dart](../lib/services/telecom_service.dart)

- Add `Future<({String path, String label})?> pickAudioDocument()` and
  `Future<void> releaseAudioDocument(String uri)` wrapping the new channels.
- Change `previewRingtone` to return `Future<bool>` (the native result; false/no-op off
  Android).

### 4. Per-SIM screen — [lib/screens/ringtone_settings_screen.dart](../lib/screens/ringtone_settings_screen.dart)

- Replace the `openFile(...)` audio branch in `_pickForSim` with
  `_telecom.pickAudioDocument()`; store the returned `content://` URI + label as the
  `RingtoneRef`. Remove the now-unused `file_selector` import if nothing else needs it.
- When a tone is replaced/cleared, best-effort `releaseAudioDocument` on the old URI
  (only if it was a `content://` picked-document URI, not a system-ringtone URI).
- In `_togglePreview`: the picked tone is now a `content://` URI, so it already routes
  to `_telecom.previewRingtone`. Use its Boolean result — on `false`, show
  "This ringtone is no longer available — reverting to default", and clear that SIM's
  override (`setSimRingtone(id, null)`).

### 5. Per-contact picker — [lib/screens/add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart)

- Replace the `openFile(...)` audio branch in `_pickRingtone` with
  `_telecom.pickAudioDocument()`; store the `content://` URI in `_ringtonePath` and the
  display name in `_ringtoneLabel`.
- In `_toggleRingtonePreview`: use the Boolean result of `previewRingtone`; on `false`,
  show the message and clear `_ringtonePath` / `_ringtoneLabel` (reverting to default;
  persisted on Save).
- Best-effort `releaseAudioDocument` when the contact's tone is replaced/cleared.
- (System-ringtone picks via `pickRingtone` are unchanged.)

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`
- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/IncomingCallRinger.kt`
- `lib/services/telecom_service.dart`
- `lib/screens/ringtone_settings_screen.dart`
- `lib/screens/add_edit_contact_screen.dart`

## Verification

- `flutter analyze` clean; Kotlin compiles (`flutter build apk` / `flutter run`).
- Manual on device:
  1. Pick an audio-file tone for a SIM and a contact, fully close & reopen the app,
     Preview → sound plays; place a test call → the tone rings.
  2. Delete the source audio file, then Preview → message shown, override reverts to
     default; place a call → rings on the **default** tone (not silent).
  3. System (`content://`) ringtone picks still preview and ring.

## Notes / caveats

- Existing contacts/SIMs that already stored a dead `file_selector` cache path can't be
  migrated (the original file reference is gone) — they'll work once re-picked. Called
  out in the change log.
- No new manifest permission is required (`ACTION_OPEN_DOCUMENT` grants access via the
  returned URI). Persisted-URI grants are package-wide, so the ringer (a different
  component) can read them.

## Out of scope

- Changing how `content://` system ringtones are handled (already work).
- CSV import's use of `file_selector` (read-once; unaffected).
