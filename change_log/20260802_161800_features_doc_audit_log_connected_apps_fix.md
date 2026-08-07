# Change log: fix two inaccuracies in docs/features.md

Implements: `plans/20260802_161500_features_doc_audit_log_connected_apps_fix.md`

## What changed

In `docs/features.md`:

1. Section 1 (Contacts management) — the audit log bullet no longer claims the log
   "Never leaves the device." It now says the log stays on-device by default but can be
   exported as a signed JSON file and shared off-device via the "1-Click Export Signed
   Audit Log" action (`AuditRepository.exportSignedAuditLog()`).
2. Section 13 (Native Android platform features) — added a bullet for the
   `contact_sphere/connected_apps` MethodChannel in `MainActivity.kt`, which reads a
   contact's linked third-party messenger apps from the Android contacts provider for the
   "Connected apps" feature (section 4). This data isn't exposed by the `flutter_contacts`
   plugin, which is why it needs native code.

No other changes. A full audit of the rest of the document (screens, services, models,
native code, pubspec dependencies, App Description) found no further gaps.
