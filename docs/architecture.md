# Architecture

Layered, with a clear dependency direction:
**screens → repositories/services → database → models**.

- `lib/main.dart` — entry point. Requests permissions via `PermissionService`, then runs
  `SmartContactsApp` whose home is `ContactListScreen`. `provider` is a dependency but no
  `ChangeNotifierProvider`/state wiring exists yet — state is currently local `setState`.
- `lib/database/database_helper.dart` — singleton wrapper over `sqflite`. Owns the full schema
  (`smart_contacts.db`, **version 2**; the v1→v2 migration in `_onUpgrade` adds the foreign-key
  indexes). All persistence funnels through `DatabaseHelper().database`. **Bump the version number
  in `_onUpgrade` when you change `_onCreate`**, since existing installs won't re-run `_onCreate`.
- `lib/repositories/contact_repository.dart` — the data-access layer for contacts. Assembles a
  full `Contact` aggregate (phone numbers, emails, addresses, groups, official details,
  relationships) via multiple queries, and writes them back inside a single
  `db.transaction(...)`. Also hosts duplicate-detection (`findDuplicates`) and `mergeContacts`.
- `lib/repositories/relationship_repository.dart` — read/write for the `relationships` table.
  A link between two contacts is stored as **two reciprocal directed rows** (A→B and B→A); the
  reverse type comes from `RelationshipTypes.reciprocalOf` (Father↔Child, Spouse↔Spouse, …), so
  each contact's links are a trivial `WHERE contact_id = ?` query and the sphere view is
  symmetric. De-duplication is enforced in code (no UNIQUE constraint). `ContactRepository`
  hydrates relationships and leaves them out of the wholesale child-replace in `updateContact`
  so an edit never wipes them.
- `lib/models/` — plain data classes with `toMap()` / `fromMap()` mirroring the SQL columns
  (snake_case in DB ↔ camelCase in Dart). `Contact` is the aggregate root holding lists of the
  child models.
- `lib/services/` — feature logic that reads/writes the DB directly via `DatabaseHelper`:
  `relationship_scoring_service` (weighted frequency/recency/emotional-tone score over the
  `interactions` table), `pre_call_summary_service` (recent interactions + last call + upcoming
  birthday + timezone), `export_import_service` (CSV via `csv` + `share_plus`).
- `lib/screens/` — Flutter UI. `contact_list_screen.dart` (search + secret-contact gating) is the
  hub, navigating to `add_edit_contact_screen`, `contact_detail_screen` (dialer + pre-call
  summary), `groups_screen`, and `duplicates_screen`. Placing a call from the detail screen logs a
  provisional `call_logs`/`interactions` row, then reconciles the real duration/type from the
  device call log on resume and recomputes the relationship score. `relationship_screen.dart`
  is the ego-centric "relationship sphere": the focused contact at the centre with its related
  contacts orbiting on a labelled ring (`CustomPaint` edges + tappable node widgets); tapping an
  orbit node pushes a new sphere focused on it. Reached from the contact list overflow menu, the
  detail screen's Relationships section, and the add/edit form (which stages links and persists
  them after the contact id exists). The add-a-link flow is the shared
  `widgets/relationship_editor.dart` bottom sheet.

## Default phone app (Telecom / in-call UI)

ContactSphere can take Android's **default phone app** role (`ROLE_DIALER`) and then owns
the in-call experience with its own UI. This spans a thin native bridge and a Flutter layer:

- **Native (Kotlin, `android/app/src/main/kotlin/in/sreerajp/contact_sphere/`)** —
  `ContactSphereInCallService` is the `InCallService` the system binds once we're default;
  it forwards call/audio-state to `CallRegistry` (an `object` holding the active `Call` and
  the service, and driving answer/hold/mute/speaker) and brings `MainActivity` to front. When
  a call arrives while the app isn't showing (an incoming call, cold start included),
  `CallRegistry.didCallBringUiToFront()` records that our UI was launched *by* the call; when
  the last call ends `MainActivity` then `moveTaskToBack()`s so it doesn't leave its own screen
  on display for a call the user never opened the app for. A call dialed from inside the app
  (UI already visible) is left on screen as before.
  `MainActivity` exposes a `MethodChannel` (`contact_sphere/telecom`: role status/request +
  in-call controls + `placeCall`) and an `EventChannel` (`contact_sphere/call_events`)
  streaming call snapshots. The role is requested via `RoleManager` (API 29+) with a
  `TelecomManager.ACTION_CHANGE_DEFAULT_DIALER` fallback for API 24–28. Manifest declares the
  dialer intent-filters (`DIAL`/`VIEW tel:`/`CALL`/`CALL_BUTTON`), contact intent-filters
  (`VIEW`/`EDIT`/`INSERT`), and the `InCallService`; `minSdk` is floored at 24.
- **Missed calls, "Call back" & "Dismiss".** When an incoming call ends unanswered,
  `CallRegistry` (natively, so it works with the Flutter engine down) classifies it as missed
  and `ContactSphereInCallService` posts our **own** missed-call notification (a "Missed calls"
  channel) with **Call back** and **Dismiss** actions, then calls
  `TelecomManager.cancelMissedCallsNotification()` to drop the system's duplicate. Because
  `MainActivity` is exported, every **external** `ACTION_CALL`/`tel:` intent only opens the
  dialer **pre-filled** (never a silent call) — `handleDialIntent`. Auto-dial happens **only**
  from our own notification: the Call back button is a `getActivity` `PendingIntent` that
  launches `MainActivity` with `ACTION_TRUSTED_CALL_BACK` — launching the activity directly (not
  a broadcast that then calls `startActivity`, which Android 12+ blocks as a notification
  trampoline) is what makes the app reliably come to the front. Trust is a one-shot random
  token: the notification arms the number in `PendingCallback` and carries the token in the
  intent; `MainActivity.handleTrustedCallbackIntent` places the call only when the token matches
  a live one (the number is read from the holder, never trusted from an extra), then Dart places
  it through `CallService` (logged, and honouring the SIM setting). A crafted external intent
  can't guess a live token, so this keeps the confused-deputy hole closed. If the phone is
  locked, the call-back requests keyguard dismissal so the SIM picker is usable. **Dismiss** is a
  cancel-only broadcast to the non-exported `CallActionReceiver` that clears the notification and
  drops the armed token.
  The notification title shows the **contact name** even when the app is closed:
  `ContactRepository.contactNameMirrorEntries` pushes a digit→name map into the same
  native prefs the ringtone mirror uses (via `setRingtoneMirror`), and the service reads
  it by the shared trailing-digit key. That key is the number's **last 10 digits**
  (`_mirrorMatchDigits` / `IncomingCallRinger.MATCH_DIGITS`) — India's fixed 10-digit
  mobile plan — so distinct numbers sharing a shorter suffix don't collide; the same
  slice keys the tone mirror and prefilters `findByFullNumber`.
- **Flutter** — `services/telecom_service.dart` wraps both channels (and **no-ops off
  Android**, so tests and other platforms are unaffected), emitting `models/call_state.dart`
  snapshots. `screens/in_call_screen.dart` renders the live call (identity resolved from
  `ContactRepository`, duration timer, answer/reject/mute/speaker/hold/end).
  `main.dart` listens to `TelecomService.callEvents` via a `navigatorKey` and pushes/pops the
  in-call screen as calls come and go. `CallService.placeCall` routes through Telecom when we
  are default (so outgoing calls use our UI) and falls back to `flutter_phone_direct_caller`
  otherwise. Settings has a "Default phone app" card to request/see the role.

## BLE contact exchange

Phone-to-phone contact sharing over Bluetooth LE. `flutter_blue_plus` is central-role only,
so the roles are split: the **sender** is a native Kotlin peripheral, `BleShareServer`
(advertiser + GATT server) behind `MethodChannel` `contact_sphere/ble_share` and
`EventChannel` `contact_sphere/ble_share_events` in `MainActivity` (same bridge pattern as
Telecom); the **receiver** is `flutter_blue_plus` in `services/ble_receive_service.dart`.
The payload is the photo-less `VCardService` vCard, pulled with a chunked GATT protocol
(`size`/`offset`/`data` characteristics — attribute values cap at 512 bytes) defined in
`services/ble_protocol.dart` and mirrored in Kotlin. UI: `widgets/ble_share_dialog.dart`
("Share via Bluetooth" on the contact detail share sheet; advertises only while open) and
`screens/ble_receive_screen.dart` ("Receive via Bluetooth" in the contact list menu), which
funnels received vCards through the same review/import flow as the QR scanner. The contact
list menu's "Send all via Bluetooth" shares the whole book (multi-contact vCard via
`toVCardAll`, secret contacts per the export setting) through the same dialog, advertised
as "N contacts"; `sending` events carry `sent`/`total` and `fetchVCard` reports progress,
so both ends show a percentage, and the sender's 2-minute timeout is idle-based (reset by
transfer activity) so a slow whole-book transfer is never cut off.

## P2P LAN sync (connect-then-choose + add-only merge)

Phone-to-phone sync of ContactSphere data over the local Wi-Fi, no server or
internet. Security rests on a per-session ~320-bit **pairing code** shown on the
host (as text **and a QR**) and scanned/typed on the client — it never crosses
the socket. Every frame after the salt is AES-GCM sealed with a key derived from
that code (PBKDF2-HMAC-SHA256, **300k iters**); a wrong code derives a wrong key
and decryption throws, which *is* the authentication (no fallback cipher).
Transport is a plain `dart:io` `ServerSocket` on a **random OS-assigned port**
(carried in the QR/URI), line-based; the salt is sent in the clear.

**Flow = connect-then-choose.** The host binds, shows IP + port + code + QR, and
after a client authenticates it **holds the connection open** (protocol `2`).
The sender then picks a **Full Sync** or specific **categories** and the payload
is pushed on that action; a 120 s idle timer stops a host nobody joined.

**Semantics = add-only merge, "client wins".** The receiver keeps its own data;
incoming rows get **new receiver ids** and every foreign key is remapped. A
contact already present (same normalized name **and** ≥1 shared phone number) is
**skipped**; a genuinely new contact is added and its detail children + history
(`call_logs`, `interactions`, `reminders`) travel with it — history "follows"
only newly-added contacts. Groups match by `name` (which is UNIQUE);
`relationships` remap both endpoints and dedupe; `flagged_numbers` dedupe on
`(number_e164, kind)`; the sender's `is_self` (owner) card is never merged.
Settings are **overwrite** on a Full Sync, **fill-only** on an incremental one.

`services/p2p_sync_service.dart` is the transport/crypto engine (crypto, QR
URI build/parse, hold-open host with `onClientConnected`/idle timer, bounded-line
reader that exposes a `closed` future for drop detection, local-IPv4 discovery, a
`ChangeNotifier` `SyncState`). `services/sync_bundle_service.dart` is the
app-specific half: `SyncMode`/`SyncCategory`, `exportBundle` (category-filtered
tables + device-neutral settings + photo/calling-card **file bytes**), and
`applyBundle` (the id-remapping merge in one transaction). Deliberately **not**
copied: `contacts.device_id` + `merged_device_ids` (source-phone address-book
links), SIM-account-keyed settings (`default_sim_id`, per-SIM ringtones/colors),
and ringtone audio (only the path travels; kept only if a file already exists at
that path). A protocol + DB schema-version guard refuses a sync between
mismatched app versions. UI: `screens/sync/` — `sync_home_screen.dart` (the
"Sync to Another Device" hub) → `send_to_device_screen.dart` (host) and
`receive_from_device_screen.dart` (client; reuses `mobile_scanner` for the QR),
with shared bits in `sync_views.dart`. Reached from Settings behind an
`AuthService` biometric check because secret contacts can be in the payload.
Manifest already carries `CAMERA` + `INTERNET` +
`ACCESS_NETWORK_STATE`/`ACCESS_WIFI_STATE`/`CHANGE_WIFI_STATE`.

## Multi-SIM

Native `MainActivity.getSimAccounts` enumerates call-capable SIMs (SubscriptionManager +
TelecomManager, matched by phone-account id) and `placeCall` accepts a chosen SIM's handle
(`EXTRA_PHONE_ACCOUNT_HANDLE`). `services/sim_service.dart` caches the list and maps a
phone-account id → label. The "SIM & calling" settings screen sets a default SIM and an
"ask before each call" toggle (`AppSettings`); `CallLifecycleMixin` resolves the SIM (default,
or the `sim_picker_sheet` when asking) before dialing. `call_logs` carries `sim_id`/`sim_label`;
outgoing calls record the SIM at placement and back-fill it on reconcile, while
`services/call_event_logger.dart` logs **incoming/missed** calls (with SIM + duration) from the
call-event stream when we're the default dialer. The call snapshot (`CallState`) carries
`phoneAccountId` + `direction` to support this. When a call we place with no chosen SIM
("System default") parks in `SELECT_PHONE_ACCOUNT`, `CallRegistry` first tries the OS default
outgoing account (`getDefaultOutgoingPhoneAccount`); failing that, `main.dart` shows the
`sim_picker_sheet` and resolves the call via `TelecomService.selectPhoneAccount`.

## Startup sequence, logging, and error boundaries

`main()` (`lib/main.dart`) is async and runs, in order: `WidgetsFlutterBinding.ensureInitialized()`
→ `installGlobalErrorHandlers()` → `await AppLogger.init()` → `runApp`. The error boundaries are
installed **before** the logger is configured on purpose — `AppLogger` tolerates being called
before `init()` (it falls back to `dart:developer log`), so a failure during startup is still
captured. See engineering standard §4.5 (init sequence) and §11.1 (error boundaries).

- `lib/core/errors/error_handlers.dart` — wires the three global boundaries (standard §11.1):
  `FlutterError.onError` (framework/build/paint errors), `PlatformDispatcher.instance.onError`
  (uncaught async errors), and `ErrorWidget.builder` (a neutral fallback widget shown in **release**
  in place of the raw red error box; debug keeps the default). All three funnel through `AppLogger`,
  so a crash reporter can later attach at one spot.
- `lib/core/logging/app_logger.dart` — the app's single logger (standard §14), backed by the
  `logger` package. Level is gated by `AppFlavorConfig.instance.isDev`: **dev** logs everything
  (`Level.trace`) to the console; **prod** logs `Level.info`+ to both the console and a file in the
  app cache directory (`app.log`). **Log rotation** (§14.4) is done as a startup task in
  `AppLogger.init()`: when `app.log` passes **5 MB** it is rolled over to `app.1.log`, shifting
  older files up and keeping at most **3** rotated files (`app.1.log`…`app.3.log`) before the oldest
  is dropped — the `logger` package's `FileOutput` does not rotate on its own.

## Database schema (key tables)

`contacts` is the hub; most tables FK to `contacts(id)` with `ON DELETE CASCADE`
(`call_logs` uses `ON DELETE SET NULL`). Tables: `contacts`, `phone_numbers`, `emails`,
`addresses`, `groups`, `contact_groups` (join), `call_logs`, `relationships`, `interactions`,
`reminders`, `official_details`. `phone_numbers`/`emails`/`addresses` carry a
`type CHECK IN ('personal','official')`. `contacts.is_secret` gates visibility (secret contacts
are intended to sit behind biometric auth — `local_auth` is a dependency). `relationship_score`
is denormalized onto `contacts` and recomputed by `RelationshipScoringService`.

`call_logs` splits a call into two facts: `call_type` (`incoming`/`outgoing`/`missed`/`blocked`)
is the **direction**, and `call_outcome` (`answered`, `no_answer`, `busy`, `declined`,
`cancelled`, `failed`, or null = not known) is **what happened**. They are separate columns
because `call_type` conflates the two — `missed` and `blocked` both imply "not answered", while
`outgoing` says nothing, so an outgoing call that was picked up used to be indistinguishable
from one that rang out. A new `call_type` value would have broken every `callType == 'outgoing'`
direction check instead. Outcome sources, strongest first: `CallRegistry`'s `DisconnectCause` on
the disconnected snapshot (the only source that can say *why* a call didn't connect), the
`wasActive` flag, then the device call log's duration — which may only ever *fill* a null
outcome, never overwrite one, because it rounds short answered calls to 0 seconds.

`emergency_info` (one row, `id = 1`) and `emergency_contacts` hold the emergency card. They are
standalone — `emergency_contacts.contact_id` is a nullable `ON DELETE SET NULL` link, and the
name/number are snapshotted so the card never has to read the contact tables. Both are created
by an existence-checked helper that runs on every open (`_ensureEmergencyTables`), not only by
the v21→v22 migration.

`audit_log` records every contact create / edit / delete: `contact_id` (deliberately **no** FK,
so the row outlives the contact it describes), the name at the time, `action`, `source`,
`changed_at`, a one-line `summary`, `is_secret`, and `before_json` / `after_json` — full JSON
snapshots of the contact aggregate (row + child rows + group names + relationship pairs) that
make an undo possible. Created by `_ensureAuditTable`, existence-checked on every open like the
emergency tables (v22→v23).

## Audit log

Writes go in from inside `ContactRepository`'s own transactions
(`insertContact` / `updateContact` / `deleteContact` / `mergeContacts`), so a contact cannot
change without its audit row landing atomically with it; every other write path (device sync,
CSV/vCard import, P2P, restore) funnels through those methods. A `source:` argument distinguishes
a hand edit from a device sync, a merge, an import or an undo. `SyncBundleService` writes its
rows table-wise rather than through the repository, so a P2P apply and a full restore each log
**one summary entry** instead of one per contact.

`AuditRepository` reads, prunes (90 days / 5000 rows, on screen open) and clears;
`ContactRepository.undoAudit` performs the reversal — delete for an undone create, write the
"before" snapshot back for an undone edit, re-insert for an undone delete (new id, so old call
logs stay unlinked and only relationships whose other person still exists come back). The undo is
itself recorded. The table is local: it is in neither `SyncBundleService`'s category tables nor
its managed-wipe list, so it is never exported. A **full restore** does clear it explicitly —
its rows describe the database that was just replaced, and their contact ids would otherwise
point at the backup's contacts — and then writes the restore's own summary entry. UI:
`AuditLogScreen` → `AuditEntryDetailScreen` (Settings → Audit Log).

## Emergency card on the lock screen

`EmergencyInfoRepository.pushMirror` sends the switched-on subset of the card (built by
`EmergencyInfo.toMirrorJson`) over the `contact_sphere/emergency` channel. Native
`EmergencyCardNotifier` stores it in its own SharedPreferences and posts a public, ongoing
notification whose tap target is `EmergencyInfoActivity` — an `showWhenLocked` activity that
renders the card over the keyguard with plain Android views (no Flutter engine, no DB access) and
dials an emergency contact directly. `EmergencyBootReceiver` re-posts the notification after a
reboot. The plaintext mirror is required (a locked phone cannot decrypt the DB) and is discussed
in [security.md](security.md) §4.
