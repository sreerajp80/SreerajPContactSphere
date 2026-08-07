# Change log: P2P LAN sync re-architecture

Implements `plans/20260708_104631_p2p-sync-rearchitecture.md` (approved).

## What changed

Re-architected the phone-to-phone LAN sync from a one-way **MIRROR / full
replace** clone into a **connect-then-choose** flow with a **client-wins
add-only merge**, plus **QR pairing** and hardening. The receiver now keeps its
own data; nothing is wiped.

### Flow (connect-then-choose)
- Host binds a **random OS-assigned port** (was fixed `8243`), shows IP + port +
  pairing code **and a QR**, and after a client authenticates it **holds the
  connection open**. The sender then picks a **Full Sync** or specific
  **categories** and the payload is pushed on that action.
- A **120 s idle timer** stops a host that nobody joins.
- PBKDF2 iterations raised **120k → 300k**. Crypto library unchanged
  (`cryptography`) — swapping to `encrypt`+`pointycastle` was avoided as needless
  churn (same PBKDF2-HMAC-SHA256 → AES-256-GCM primitives).
- Wire **protocol bumped to `2`**; a receiver refuses a payload from a different
  protocol with a clear "update both phones" message.

### Merge (add-only, "client wins")
- Incoming rows get **new receiver ids** with every foreign key remapped.
- **Contact match = normalized name AND ≥1 shared phone number** → a matched
  contact is skipped (receiver keeps its own); a genuinely new contact is added.
- **History follows new contacts**: a new contact's detail children and its
  `call_logs` / `interactions` / `reminders` travel with it; existing contacts
  are untouched.
- Groups match by `name` (UNIQUE); `relationships` remap both endpoints and
  dedupe; `contact_groups` dedupe on the pair; `flagged_numbers` dedupe on
  `(number_e164, kind)`; the sender's `is_self` (owner) card is never merged.
- Settings: **overwrite** on a Full Sync, **fill-only** on an incremental one.
  SIM-account-keyed settings and `device_id`/`merged_device_ids` still never
  travel; ringtone audio still path-matched only.

### UI
- New **Settings → "Sync to Another Device"** hub with two sub-items,
  **Send to Another Device** and **Receive from Another Device** (still behind the
  `AuthService` biometric gate).
- Send screen shows the QR + selectable IP/port/code, a live "waiting →
  connected" status, and a "choose what to share" section (Full Sync + per-
  category checkboxes) enabled once a peer connects.
- Receive screen scans the QR (`mobile_scanner`) or takes IP/port/code by hand,
  shows "connected — waiting for the sender…", then an "Added N, kept M" summary.

## Files

### Rewritten
- `lib/services/p2p_sync_service.dart` — random port, hold-open host with idle
  timer + drop detection (bounded line reader now exposes a `closed` future), QR
  URI build/parse, 300k PBKDF2, connect-then-choose client split into an
  app-agnostic `_connectAndFetch` transport half + the DB merge. Added
  `forTest` constructor and `debugPushBundle` / `debugConnectFetchMeta` hooks.
- `lib/services/sync_bundle_service.dart` — `SyncMode` / `SyncCategory`,
  category-filtered `exportBundle`, and the id-remapping add-only `applyBundle`
  merge.

### New
- `lib/screens/sync/sync_home_screen.dart` — the hub.
- `lib/screens/sync/send_to_device_screen.dart` — host (QR + choose-what-to-share).
- `lib/screens/sync/receive_from_device_screen.dart` — client (+ a private QR
  scanner for the pairing code).
- `lib/screens/sync/sync_views.dart` — small shared presentational widgets
  (progress / result / info / warning / labelled value). This shared-widgets file
  is a minor addition beyond the plan's file list, to keep the two screens DRY.

### Edited
- `lib/screens/settings_screen.dart` — card renamed to "Sync to Another Device";
  opens `SyncHomeScreen`.
- `docs/architecture.md`, `docs/known-gaps.md` — rewrote the P2P sync sections.

### Deleted
- `lib/screens/p2p_sync_screen.dart` — replaced by the three screens above.

### Tests
- `test/p2p_crypto_test.dart` — added QR URI build/parse tests.
- `test/p2p_transport_test.dart` (new) — loopback connect-then-choose: happy path
  (host holds open, then pushes; client receives), wrong code rejected, push with
  no client errors.
- `test/p2p_bundle_test.dart` — rewritten for the add-only merge: new contacts
  added with new ids + remapped children/history, matched contact skipped, groups
  matched by name / new group created, flagged dedupe, fill-only settings, plus
  protocol / schema-version / field-cap guards.

`pubspec.yaml` and `AndroidManifest.xml` needed no change — `qr_flutter`,
`mobile_scanner`, `cryptography`, and the `CAMERA` + LAN permissions were already
present.

## Verification
- `flutter analyze` — no issues.
- `flutter test test/p2p_crypto_test.dart test/p2p_transport_test.dart` — 16
  passed.
- `flutter test test/p2p_bundle_test.dart` (run alone, sqlite-backed) — 7 passed.
- Not verified here: the cross-device transfer + camera QR scan on two real
  phones (the one path loopback can't exercise) — to be checked manually before
  release.
