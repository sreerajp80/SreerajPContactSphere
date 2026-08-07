# Change log: thirteenth gap-fill pass on docs/features.md

Implements `plans/20260805_060000_features_doc_thirteenth_gap_fill.md`.

## What changed

Edited `docs/features.md`, section 2 (Dialer / calling), the "Ringtone
settings" bullet: it now says every ringtone picker (default/SIM,
per-contact, per-group) lets you choose between the phone's built-in
ringtone list or any audio file from device storage, not just the
built-in list.

No other changes. The intro "What this app is" paragraph was re-checked
and is still accurate and inclusive.

## Why

A user-requested critical re-check of `docs/features.md` for missing
features and an inclusive app description — the thirteenth independent
gap-fill pass on this file. A fresh code sweep (screens, services,
widgets, `app_settings.dart`, native Kotlin, `pubspec.yaml`) found the
document essentially complete; the only real gap was the "audio file"
ringtone source, confirmed in
`lib/screens/add_edit_contact_screen.dart`, `lib/screens/groups_screen.dart`,
`lib/screens/ringtone_settings_screen.dart`, `lib/services/telecom_service.dart`,
and `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`.
