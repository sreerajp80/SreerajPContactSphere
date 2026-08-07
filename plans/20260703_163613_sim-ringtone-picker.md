# Per-SIM ringtone: show real names, pick from phone ringtones, distinct per SIM

**Status:** completed

## The issue

On the Ringtone settings screen ([lib/screens/ringtone_settings_screen.dart](../lib/screens/ringtone_settings_screen.dart)) three
problems were reported:

1. **No name shown for the ringtone in use.** When a SIM has no override, the row just says
   "SIM 1 · default ringtone". It never shows *which* tone the system default actually is.
2. **Can't tell / can't set a distinct ringtone per SIM.** The per-SIM storage already keys by
   phone-account id (so distinct tones are technically possible), but because both SIMs show
   "default ringtone" and the only picker is a file browser, it doesn't read as a working
   per-SIM feature.
3. **Picker only offers files from folders.** `_pickForSim` uses `file_selector`'s `openFile`,
   which browses audio *files* only. It never surfaces the phone's built-in ringtones (the
   Android system ringtone picker).

Root cause for all three: the screen relies on `file_selector` (arbitrary files → file path +
basename) and has no access to the OS ringtone catalog or the system default tone's title.

## The fix (high level)

Add a native bridge to the Android **system ringtone picker** (`RingtoneManager.ACTION_RINGTONE_PICKER`)
and to the **system default ringtone**, then use them from the settings screen:

- Tapping the pick icon opens a small chooser sheet with **"Phone ringtones"** (system picker,
  which lists built-in ringtones *and* highlights the currently-selected one) and **"Audio file"**
  (the existing `file_selector` flow — kept so custom files still work). This matches the request
  to "show Phone ringtones **also**".
- The system picker returns a `content://` URI **and its title**, which we store in the existing
  `RingtoneRef {path, title}`. The row then shows the real tone name.
- When a SIM has **no** override, the subtitle shows the actual system-default tone name
  (e.g. "Default · Flutey Phone") instead of the bare "default ringtone".
- Preview must work for `content://` URIs (audioplayers' `DeviceFileSource` only handles plain
  file paths), so preview for these rows is routed through a small native preview player.

Distinctness (issue 2) then falls out for free: each SIM row writes to its own phone-account key
and displays its own chosen tone.

Scope note: the **per-contact** ringtone picker
([lib/screens/add_edit_contact_screen.dart](../lib/screens/add_edit_contact_screen.dart)) has the
same "files only" limitation and gets the **same chooser** (Phone ringtones + Audio file) in this
change, per the user's decision.

## Files to change

### Native (Android)

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - Add method-channel handlers:
     - `getDefaultRingtone` → returns `{uri, title}` for the actual default ringtone
       (`RingtoneManager.getActualDefaultRingtoneUri` with `getDefaultUri` fallback; title via
       `RingtoneManager.getRingtone(context, uri).getTitle(context)`). Best-effort; returns null
       fields on failure.
     - `pickRingtone` (args: `existingUri`) → launches `ACTION_RINGTONE_PICKER`
       (`EXTRA_RINGTONE_TYPE = TYPE_RINGTONE`, `SHOW_DEFAULT = true`, `SHOW_SILENT = false`,
       `EXISTING_URI` = the current tone so it's pre-highlighted) via `startActivityForResult`.
       Uses a new request code and a `pendingRingtoneResult`.
     - `previewRingtone` (args: `uri`) / `stopRingtonePreview` → play/stop a `content://` or file
       tone through a dedicated `MediaPlayer` (media-usage attributes; not looping) so the
       settings screen can preview system tones reliably. Released in `onDestroy`.
   - Extend `onActivityResult` to handle the new request code: read
     `EXTRA_RINGTONE_PICKED_URI`, resolve its title, and complete `pendingRingtoneResult` with
     `{uri, title}` (or a null-uri map when the user picked "Silent"/none, or nothing on cancel).
   - Keep all of this best-effort/guarded — never throw into the channel.

### Flutter

2. **`lib/services/telecom_service.dart`**
   - Add `Future<RingtoneRef?> pickRingtone({String? existingUri})` — invokes `pickRingtone`,
     maps `{uri, title}` → `RingtoneRef` (null on cancel).
   - Add `Future<RingtoneRef?> defaultRingtone()` — invokes `getDefaultRingtone`.
   - Add `Future<void> previewRingtone(String uri)` and `Future<void> stopRingtonePreview()`.
   - All no-op / null off Android, matching the existing `_supported` pattern.
   - (`RingtoneRef` lives in `app_settings.dart`; import it here, or return a lightweight
     record/`Map` and let the screen build the `RingtoneRef`. Will use `RingtoneRef` for
     consistency.)

3. **`lib/screens/ringtone_settings_screen.dart`**
   - On load, fetch `defaultRingtone()` and stash the default tone's title; show it in a SIM row's
     subtitle when that SIM has no override ("Default · <name>", falling back to "default
     ringtone" if the name can't be read).
   - Replace `_pickForSim` with a chooser: bottom sheet → **Phone ringtones**
     (`_telecom.pickRingtone(existingUri: currentTone?.path)`) or **Audio file** (existing
     `file_selector` flow). Both end by calling `AppSettings.setSimRingtone(...)`.
   - Preview: if a tone's path is a `content://` URI, preview via the native
     `previewRingtone`/`stopRingtonePreview`; otherwise keep the existing audioplayers
     `DeviceFileSource` path. Keep the single "only one preview at a time" behaviour and reset
     state on completion.
   - Minor: the pick icon tooltip/label stays "Pick / Change ringtone".

4. **`lib/screens/add_edit_contact_screen.dart`**
   - Apply the same chooser to `_pickRingtone`: bottom sheet → **Phone ringtones**
     (`_telecom.pickRingtone(existingUri: _ringtonePath)`) or **Audio file** (existing
     `file_selector` flow). Store the returned `{path/uri, title}` into `_ringtonePath` /
     `_ringtoneLabel` as today.
   - Preview: route `content://` tones through the native `previewRingtone`/`stopRingtonePreview`;
     keep `DeviceFileSource` for plain file paths. Preserve existing preview state handling.

## Behaviour after the change

- Empty SIM row: "SIM 1 · Default · Flutey Phone" (real default name).
- After picking a phone ringtone: row shows that ringtone's name; preview plays it.
- Each SIM can hold a different tone; both are shown and previewable independently.
- File-based custom tones still work via the "Audio file" option.
- Call-time behaviour is unchanged: `content://` URIs already resolve through the native ringer's
  `toUri` (`in_call_screen.dart` → `setIncomingRingtone`).

## Risks / notes

- `audioplayers` can't reliably play `content://` URIs, which is why preview is routed natively
  for those. File-path preview is untouched.
- The ringtone picker and the default-dialer role request now share `onActivityResult`; they use
  distinct request codes and separate pending-result fields, so they don't collide.
- No new pub dependency; no new Android permission (system ringtone URIs are readable without one).
- `flutter analyze` and a manual on-device check of the Ringtone screen after implementation.

## Out of scope

- No changes to the ringer volume/vibration cards or the call-time ringing flow beyond what's
  described above.
