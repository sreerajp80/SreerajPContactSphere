# Plan: thirteenth gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md` only (one small addition, section 2's "Ringtone
  settings" bullet; no change needed elsewhere)

## What the issue is

The user asked again to critically check `docs/features.md` for missing
features and an inclusive app description. This doc has already been
through twelve independent gap-fill passes. I ran a thirteenth pass (a
fresh code sweep via a research agent, plus my own spot-check), covering
screens, services, widgets, `app_settings.dart`, the native Kotlin side,
and `pubspec.yaml`.

Result: the document is essentially complete. The intro "What this app is"
paragraph is still accurate and inclusive — no change needed. Only one
small, genuinely new gap was found:

- **Ringtone pickers aren't limited to the phone's built-in ringtone
  list** — for a contact, a group, and the default/SIM ringtone, the
  picker offers a choice between "Phone ringtones" and "Audio file" (pick
  any audio file from device storage), backed by a native
  `pickAudioDocument` method-channel call. The doc's "Ringtone settings"
  bullet in section 2 only says "with in-app preview," which reads as if
  the only source is the phone's system ringtone list.
  - Evidence: `lib/screens/add_edit_contact_screen.dart:675-731`,
    `lib/screens/groups_screen.dart:104-148`,
    `lib/screens/ringtone_settings_screen.dart:338-352`,
    `lib/services/telecom_service.dart:354-366` (`pickAudioDocument`),
    `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt:196`.

Everything else checked came back clean and already matches the doc:
`app_settings.dart`'s persisted settings, native platform features
(no undocumented widgets/tiles/shortcuts), notification channels,
identification/sync/permissions/duplicates/relation-status screens, and
the "Known gaps"/"Roadmap" sections (still accurate, nothing secretly
implemented since).

## The fix

One small edit to `docs/features.md`, section 2, the "Ringtone settings"
bullet — add that the picker lets you choose between the phone's built-in
ringtones or any audio file from device storage, for the default/SIM,
per-contact, and per-group ringtone.

No other changes. No structural changes, no new sections, no change to
the intro paragraph.
