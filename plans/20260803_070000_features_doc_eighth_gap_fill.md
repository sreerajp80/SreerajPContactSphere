# Plan: eighth gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md`

## What the issue is

The user asked for a critical re-check that `docs/features.md` lists all
features and that the "What this app is" intro is inclusive. This doc has
already had seven gap-fill passes today. I ran a fresh, independent audit
(inventory of every file under `lib/screens`, `lib/services`, `lib/models`,
`lib/state`, `lib/widgets`, every native Kotlin file, and the full
`AndroidManifest.xml`) against the current doc.

Result: no undocumented feature was found — everything checked already maps
to a line in the doc. The intro paragraph was also re-checked against the
full feature list and already names every headline feature (encryption,
default-dialer role, call waiting/merge, device sync, P2P sync, backup,
relationships/duplicate detection, tags/groups, spam blocking, the security
layer, ephemeral contacts, emergency card, audit log, Smart Redial,
multi-script T9, sharing formats, connected apps, multi-SIM). It does not
need a further addition.

The audit did find two small **precision gaps** — not missing features, but
places where the doc describes a feature without a detail that explains an
otherwise-odd aspect of the app:

1. Section 4/13 (Bluetooth contact exchange) doesn't mention that Android
   requires location permission for BLE scanning on older OS versions, so a
   reader wouldn't know why a location prompt can appear during "Send/
   Receive via Bluetooth" (`lib/screens/ble_receive_screen.dart` calls
   `PermissionService.ensureLocation()` for this reason).
2. Section 2 documents "Quick Replies" and Smart Redial's "Reach Me" SMS as
   if they were the same kind of thing, but they use different delivery
   paths: Quick Replies uses the Telecom "reject call with message" system
   API (no `SEND_SMS` permission, no visible SMS app), while "Reach Me"
   opens the phone's own SMS app via an `sms:` URI intent
   (`lib/services/smart_redial_service.dart`). Noting this explains why the
   app has no `SEND_SMS` permission despite having two "send an SMS"
   features.

## The plan for the fix

Make two small, one-line-each additions to `docs/features.md`, no other
content changed:

1. In section 4 ("Sharing / interoperability"), in the Bluetooth bullet, add
   a short clause noting that BLE scanning needs location permission on
   older Android versions (this is why a location prompt can appear).
2. In section 2 ("Dialer / calling"), in or near the Quick Replies bullet,
   add a short clause distinguishing it from "Reach Me": Quick Replies uses
   the system's reject-with-message API silently, while Reach Me opens the
   phone's own SMS app.

No other changes. This keeps the doc accurate without padding it with
detail beyond what a reader needs to understand the app's behavior.
