# Write social links on the local device-account path

**Status:** completed  (user approved: "Yes")

## Issue

The native local-account write (`LocalContactWriter.kt`, used for the "Device"
destination) skips social links, so a contact saved to the local account loses them —
while a contact saved to a real account (plugin path) keeps them. Also, the local
payload currently derives `websites` from URL-like social links, which the plugin path
(`_toDevice`) never does — an inconsistency.

## Fix

Make the local path map social links exactly like flutter_contacts does:
each app social link → an Android **`Im`** data row (mimetype
`vnd.android.cursor.item/im`), with `Im.DATA` = value, `Im.PROTOCOL` =
`PROTOCOL_CUSTOM (-1)`, `Im.CUSTOM_PROTOCOL` = label. This matches the plugin's
`SocialMedia.toInsertOperation`, so `DeviceContactService._toApp` reads them back
identically.

Remove the `websites`-from-social-links heuristic (the plugin path doesn't do it).

## Files to change

- `android/app/src/main/kotlin/in/sreerajp/contact_sphere/LocalContactWriter.kt` —
  replace the `websites` block with a `socialLinks` block writing `Im` rows.
- `lib/services/device_contact_service.dart` — in `_localPayload`, replace `websites`
  with `socialLinks: [{value, label}]` from `c.socialLinks`.

## Verification

- `flutter analyze` clean.
- User builds/installs; a contact with a social link saved to **Device** shows the
  social link on the phone and round-trips back into the app.
