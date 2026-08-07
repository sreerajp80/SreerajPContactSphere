# Fix two inaccuracies in docs/features.md

**Status:** completed

## Files to change

- `docs/features.md`

## The issue

I did a fresh critical review of `docs/features.md` against the actual code. Found two
concrete problems (everything else checked out fine — screens, services, models, native
Kotlin code, and pubspec dependencies all match what the doc says):

1. **Wrong claim about the audit log.** Section 1 says the audit log "Never leaves the
   device." That is not true: `audit_log_screen.dart` has an "Export Signed Audit Log"
   button, and its handler `AuditRepository.exportSignedAuditLog()`
   (`lib/repositories/audit_repository.dart:347-425`) writes a signed JSON file and opens
   the system share sheet (`SharePlus.instance.share(...)`) — the same off-device share
   flow used by CSV/vCard export. So the audit log *can* leave the device, on purpose,
   when the user taps export.

2. **Missing native platform feature.** Section 13 (native Android platform features)
   lists things like the BLE GATT server and the local-account contact writer, but leaves
   out the `contact_sphere/connected_apps` MethodChannel in `MainActivity.kt` (line 349,
   channel name at line 1477). This is what powers the already-documented "Connected apps"
   feature in section 4 (reading WhatsApp/Telegram links from the Android contacts
   provider) — it needs native code because that data isn't exposed by the `flutter_contacts`
   plugin. It should be listed in section 13 alongside the other native-only features.

## The plan

- In section 1 (Contacts management), change the audit log bullet so it says the log stays
  on-device by default but can be exported (signed JSON via the share sheet) as an explicit
  user action — instead of the current unconditional "Never leaves the device."
- In section 13 (Native Android platform features), add one bullet for the
  `connected_apps` MethodChannel, describing it as reading third-party messenger links from
  the Android contacts provider for the "Connected apps" feature, because `flutter_contacts`
  doesn't expose that data.

No other changes — the rest of the document was verified accurate in this pass.
