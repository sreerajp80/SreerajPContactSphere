# Per-SIM & per-contact ringtone: phone-ringtone picker, real tone names

Implements [plans/20260703_163613_sim-ringtone-picker.md](../plans/20260703_163613_sim-ringtone-picker.md).

## Why

On the Ringtone settings screen the SIM rows only ever read "default ringtone" (the actual
default tone's name was never shown), and the only way to set a tone was a file browser — the
phone's built-in ringtones were never offered. The per-SIM store already keys by phone-account
id, but with both SIMs showing "default ringtone" and a files-only picker it didn't read as a
working per-SIM feature.

## What changed

### Native (Android)

- **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
  - New method-channel handlers:
    - `getDefaultRingtone` → `{uri, title}` for the actual system default ringtone
      (`getActualDefaultRingtoneUri` with `getDefaultUri` fallback; title via
      `RingtoneManager.getRingtone(...).getTitle(context)`).
    - `pickRingtone(existingUri)` → launches the system ringtone picker
      (`ACTION_RINGTONE_PICKER`, `TYPE_RINGTONE`, show-default on, show-silent off, existing URI
      pre-selected) via `startActivityForResult`; result delivered through a new
      `pendingRingtoneResult` + request code `REQ_PICK_RINGTONE` in `onActivityResult`, returning
      `{uri, title}` (empty map on cancel / no selection).
    - `previewRingtone(uri)` / `stopRingtonePreview` → looping in-app preview through a dedicated
      `MediaPlayer` (media-usage attributes), so `content://` system tones preview reliably.
  - `onActivityResult` now switches on request code (role-dialer vs ringtone picker); the picked
    URI is read with the API-33 `getParcelableExtra(..., Uri::class)` overload and a pre-33
    fallback.
  - `onDestroy` releases the preview player. New imports: `AudioAttributes`, `MediaPlayer`,
    `RingtoneManager`.

### Flutter

- **`lib/services/telecom_service.dart`** — added `pickRingtone({existingUri})`,
  `defaultRingtone()` (both returning a `(path, label)` record or null), `previewRingtone(uri)`,
  and `stopRingtonePreview()`. All no-op / null off Android, matching the existing `_supported`
  guard.

- **`lib/screens/ringtone_settings_screen.dart`**
  - Loads `defaultRingtone()` on `_load`; SIM rows with no override now show
    "SIM n · Default · <name>" (falls back to "SIM n · default ringtone" if unreadable).
  - The pick icon opens a bottom-sheet chooser: **Phone ringtones** (system picker) or
    **Audio file** (existing `file_selector` flow). `_pickForSim` now takes the current tone so
    the picker pre-selects it.
  - Preview routes `content://` tones through the native preview player and file paths through
    `audioplayers` as before; `dispose`/`_stopPreview` also stop the native preview.
  - Added a private `_RingtoneSource { phone, file }` enum.

- **`lib/screens/add_edit_contact_screen.dart`** — same chooser + native-preview treatment for
  the per-contact ringtone field (`_pickRingtone`, `_toggleRingtonePreview`, `_stopPreview`,
  `dispose`), plus a private `_RingtoneSource` enum.

## Verification

- `flutter analyze` on the three changed Dart files: **no issues**.
- Kotlin reviewed for correctness. A full `flutter build apk` / on-device run could **not** be
  performed in this environment: the only installed JDK is **JDK 24** (`E:\jdk-24`), which the
  project's Gradle 8.12 / AGP can't configure — the build fails at configuration time in the
  `:audioplayers_android` test task (`Type T not present`), before any app code compiles. This is
  a pre-existing environmental limitation (see [docs/known-gaps.md](../docs/known-gaps.md), which
  already flags build fragility on newer Gradle), independent of this change.
- `flutter test`: 42 pass, 1 pre-existing failure (`widget_test.dart` — HomeShell `NavigationBar`
  not found after a single `pump()`). Unrelated to this change: none of the edited files are in
  the home-shell startup path, and a compile error would have failed the whole suite.

## Follow-ups / notes

- On-device smoke test of both pickers (SIM screen + contact edit) is still recommended once a
  JDK compatible with the project's Gradle is available.
- The pre-existing `widget_test.dart` failure (likely needs `pumpAndSettle`) is worth a separate
  fix but was out of scope here.
