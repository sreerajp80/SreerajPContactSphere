# Write social links on the local device-account path

Implements plan `plans/20260711_110915_local-social-links.md`.

## Why

The native local-account write (the "Device" destination) skipped social links, so a
contact saved there lost them, while the real-account (plugin) path kept them. The local
payload also derived `websites` from URL-like social links — something the plugin path
(`_toDevice`) never does.

## What changed

### `android/app/src/main/kotlin/in/sreerajp/contact_sphere/LocalContactWriter.kt`
- Replaced the `websites` block with a `socialLinks` block that writes each link as an
  Android **`Im`** data row (`vnd.android.cursor.item/im`): `Im.DATA` = value,
  `Im.PROTOCOL` = `PROTOCOL_CUSTOM`, `Im.CUSTOM_PROTOCOL` = label. This is byte-for-byte
  what flutter_contacts' `SocialMedia.toInsertOperation` writes, so
  `DeviceContactService._toApp` reads them back identically.

### `lib/services/device_contact_service.dart`
- `_localPayload` now emits `socialLinks: [{value, label}]` from `c.socialLinks` instead of
  a `websites` list, and dropped the `_looksLikeUrl` heuristic. The local path now mirrors
  the plugin path exactly.

## Verification

- `flutter analyze` — clean (full project).
- On-device build/install/test done by the user: a contact with a social link saved to
  **Device** now shows the social link on the phone and round-trips back into the app.
