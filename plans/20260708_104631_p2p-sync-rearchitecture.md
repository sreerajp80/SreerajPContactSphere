# Plan: P2P LAN sync re-architecture (connect-then-choose + add-only merge)

**Status:** completed

## What the user wants

Re-architect the existing P2P LAN sync to follow the newer
`flutter_p2p_lan_sync_guide.md`. This is a full re-architecture (chosen by the
user), not just hardening. The current feature is a one-way **MIRROR / full
replace** clone (the receiver wipes its whole database and reloads the sender's
rows verbatim, ids preserved). The new design keeps the receiver's own data and
**merges add-only (client wins)**, lets the **sender choose what to share after
the peer connects** (connect-then-choose), and adds **QR pairing**.

### Decisions locked with the user

1. **Full re-architecture** to the guide model (connect-then-choose flow +
   client-wins add-only merge + QR + hardening).
2. **Contact natural key = normalized full name AND at least one shared phone
   number.** An incoming contact is "already on the receiver" only if a receiver
   contact has the same normalized display name *and* shares >= 1 phone number.
   Matched contacts are **skipped** (receiver keeps its own version).
3. **History follows new contacts.** In *both* sync modes, the per-contact
   history tables (`call_logs`, `interactions`, `reminders`) and the contact's
   own detail children are copied **only for contacts this merge newly adds**.
   Contacts already present on the receiver are left completely untouched.
4. **UI entry:** Settings -> **"Sync to Another Device"** (a hub screen) with two
   sub-items: **Send to Another Device** (host) and **Receive from Another
   Device** (client). The whole flow stays behind the existing `AuthService`
   biometric gate (secret contacts are still in the payload).

### Deviations from the guide (deliberate, to fit this app)

- **Keep the `cryptography` package** (already integrated and working) instead of
  swapping to `encrypt` + `pointycastle` as the guide's sample uses. Swapping
  crypto libraries is pure churn with regression risk and no benefit; the
  primitives (PBKDF2-HMAC-SHA256 -> AES-256-GCM) are identical.
- **PBKDF2 iterations raised 120k -> 300k** to match the guide.
- Media (photos / calling-card images) still travel as **bundled file bytes**;
  ringtone audio still never crosses the wire (only the path, kept if a file
  already exists there). Unchanged from today.

## The core design

### Flow: connect-then-choose (replaces immediate-send)

```
HOST (sender)                                CLIENT (receiver)
  ServerSocket.bind(anyIPv4, 0)  ← RANDOM port (was fixed 8243)
  show IP + port + code + QR
  accept()                        ◀── Socket.connect(ip, port)
  send base64(salt)  (clear)     ───▶ derive key(code, salt)
  derive key(code, salt)
                                 ◀─── enc(HELLO_SYNC)
  decrypt==HELLO_SYNC? no -> enc(DENIED), keep listening
  yes: enc(ACCEPT_SYNC)          ───▶ decrypt==ACCEPT_SYNC? else abort
  --- HOST HOLDS THE CONNECTION OPEN ---   client shows "connected, waiting…"
  ...sender picks Full Sync or categories, taps Send...
  enc(META json)                 ───▶ read META (long payloadWaitTimeout)
  enc(media frame) × N           ───▶ read exactly N frames
  teardown (one payload/session)      validate + add-only merge -> summary
```

- **META** = `{ protocol:2, schema:1, dbVersion:<n>, mode:"full"|"incremental",
  categories:[...], tables:{...}, settings:[...], files:[{ref,ext}] }`.
- `protocol:2` marks the hold-open wire format. It is **not** compatible with the
  old immediate-send host; the client rejects a mismatched protocol with a clear
  "update both phones" message. (Single app, so we simply bump and gate.)
- Host **idle auto-stop**: if no client authenticates within 120 s, stop hosting
  and return to idle. After a client connects the idle timer is cancelled.
- Two timeouts, as the guide splits them: short `socketTimeout` (30 s) per
  handshake/media line; long `payloadWaitTimeout` (10 min) for the client's wait
  on META while the sender is still choosing.

### QR pairing

- Host renders a QR of a versioned, app-specific URI:
  `contactspheresync://sync?v=1&ip=<ip>&port=<port>&code=<code>` via `qr_flutter`
  (already a dependency), alongside the existing selectable IP / port / code text.
- Client can **scan** (reuse the `mobile_scanner` pattern already in
  `lib/screens/qr_scan_screen.dart`) or type IP + port + code manually.
- Strict parse: scheme + host + version + valid port + non-empty code, else the
  QR is rejected. Code is out-of-band and never sent over the socket.

### Add-only merge (the hard part: id remapping)

The receiver keeps its data; incoming rows get **new receiver ids** and every
foreign key is remapped. Algorithm in `applyBundle`, one transaction:

1. **Index receiver contacts** by natural key: `normalize(name)` + set of that
   contact's phone numbers (queried from `phone_numbers`).
2. **Contacts.** For each incoming contact (its bundled phone numbers give its
   key): if the key matches an existing receiver contact -> record
   `senderContactId -> existingReceiverId`, mark **matched (skip)**. Else insert
   the contact (drop sender id so SQLite assigns a new one; `device_id = NULL`;
   photo/card paths resolved to freshly-written local files) -> record
   `senderContactId -> newReceiverId`, mark **added**.
3. **Groups.** Index receiver groups by name. For each incoming group: name
   exists -> map sender group id -> existing id; else insert -> map to new id.
4. **Per-contact children — only for ADDED contacts** (matched contacts keep the
   receiver's own): for each of `phone_numbers, emails, addresses,
   official_details, social_links, tags, call_logs, interactions, reminders`,
   remap `contact_id` (sender->receiver), drop the child's own id, insert.
5. **contact_groups.** Only for ADDED contacts: remap both `contact_id` and
   `group_id`; skip if that (contact, group) pair already exists.
6. **relationships** (stored as two reciprocal directed rows). Remap both
   `contact_id` and `related_contact_id` via the sender->receiver map (endpoints
   may be either added or matched contacts). Insert only if **both endpoints
   resolved** and the (contact, related, type) row does not already exist. This
   lets a newly-added contact link to a contact the receiver already had.
7. **flagged_numbers.** Keyed by phone number, not a contact. Add-only: insert an
   incoming number only if the receiver does not already have it (normalized).
8. **Media.** Only ADDED contacts' photos/cards are written to app storage and
   their path columns repointed; `@sync:<ref>` sentinels resolve to the files.
9. **Settings.** `mode:"full"` -> overwrite; `mode:"incremental"` -> fill-only
   (only set a key the receiver has not already set). SIM-account-keyed settings
   never travel (unchanged). Explicit allow-list, as today.
10. **Never copied:** `contacts.device_id`, `merged_device_ids` (source-phone
    address-book links). Same exclusions as today.

`SyncSummary` becomes richer: contacts **added** vs **skipped (already present)**,
groups added/reused, plus history/relationship counts, so the client screen can
show "Added N, kept M".

### Sync modes in the UI (connect-then-choose)

- **Full Sync** button — for a brand-new phone: share every category; settings
  overwrite. (On an empty receiver, add-only == full clone, so this subsumes the
  old MIRROR use case without wiping anything.)
- **Selective** — checkboxes per category (Contacts always on as the spine;
  Call history, Groups, Relationships, Blocked numbers, Settings optional);
  settings fill-only. A note: "This won't override anything already on the other
  device; on a conflict the other device keeps its data."
- Both run the same merge engine; mode only changes the settings overwrite policy
  and which categories are present in META.

## Files to change / create

### New

1. **`lib/screens/sync_home_screen.dart`** — the "Sync to Another Device" hub:
   two cards, "Send to Another Device" and "Receive from Another Device", each
   pushing the matching screen. (Kept behind the Settings biometric gate.)
2. **`lib/screens/send_to_device_screen.dart`** — host UI: connection card (QR +
   selectable IP/port/code + copy) with a live status chip
   ("Waiting for a device…" -> "Device connected"); then a "Choose what to share"
   section (Full Sync + per-category checkboxes), disabled until a device
   connects; per-item "sending…" + result summary.
3. **`lib/screens/receive_from_device_screen.dart`** — client UI: "Scan QR"
   (reusing the `mobile_scanner` screen) + manual IP/port/code form ->
   "Connected, waiting for the sender…" -> summary (added / kept / applied).

### Rewritten (existing files)

4. **`lib/services/p2p_sync_service.dart`** — transport/crypto engine:
   - Random OS-assigned port; carry it to the UI and QR.
   - PBKDF2 iterations 300k.
   - Hold-open host: `startHost` with `onClientConnected` / `onClientDisconnected`
     callbacks + idle-timeout timer; `sendToConnectedClient(payload/bundle)`;
     `stopHost`. Keep the bounded line reader and timeouts (add the long
     `payloadWaitTimeout` for the client's META wait).
   - Client `connectAndReceive` with an `onConnected` callback fired after ACCEPT
     (before the long wait), then read META + media, then merge.
   - QR URI **build** + strict **parse** helpers.
   - `SyncState` gains `SyncHosting(clientConnected)`, `SyncWaitingForSender`,
     and richer completion; keep it a `ChangeNotifier`.
5. **`lib/services/sync_bundle_service.dart`** — replace MIRROR apply with the
   **add-only merge** above (id remapping, natural-key matching, history-follows-
   new-contacts, groups-by-name, relationship endpoint remap, flagged dedup,
   fill-only vs overwrite settings). `exportBundle` gains a **category filter** +
   **mode** marker and includes each contact's phone numbers so the receiver can
   compute the natural key. Keep media staging + ringtone/`device_id` rules.
6. **`lib/screens/p2p_sync_screen.dart`** — **removed** (replaced by the three
   screens above). Delete the file and its import.

### Edited

7. **`lib/screens/settings_screen.dart`** — rename the card to **"Sync to Another
   Device"** (subtitle e.g. "Send or receive over Wi-Fi"), open
   `SyncHomeScreen` behind the existing biometric gate.
8. **`android/app/src/main/AndroidManifest.xml`** — verify `CAMERA` (QR scan) and
   the LAN permissions (`INTERNET`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`)
   are present; add any missing. (`CAMERA` already exists for vCard QR.)
9. **`docs/architecture.md`** + **`docs/known-gaps.md`** — rewrite the "P2P LAN
   sync" section to describe connect-then-choose + add-only merge + QR (it
   currently describes the MIRROR design).

`pubspec.yaml` needs **no change** — `qr_flutter`, `mobile_scanner`, and
`cryptography` are already dependencies.

### Tests

10. **`test/p2p_crypto_test.dart`** — keep the crypto round-trip + wrong-code +
    pairing-code tests; add **QR URI build/parse** tests (round-trip, reject
    foreign scheme / bad port / missing code).
11. **`test/p2p_bundle_test.dart`** — rewrite for add-only merge: seed the
    receiver with existing data, apply a bundle from a second seed, and assert:
    a genuinely new contact is added with a **new id** and its children/history
    remapped; a name+phone match is **skipped** (receiver's version untouched);
    a relationship between an added and an existing contact links correctly;
    groups match by name; `flagged_numbers` dedups; settings are **fill-only** in
    incremental and **overwrite** in full; caps still reject an over-cap payload.
    (Own file — sqlite-backed; run alone per the known native-assets crash.)
12. **`test/p2p_transport_test.dart`** (new) — loopback connect-then-choose:
    client connects, host `onClientConnected` pushes a payload,
    `connectAndReceive` returns it and `onConnected` fired; wrong code is
    rejected and never connects; `sendToConnectedClient` with no client throws;
    idle timeout fires with no peer. (No DB — safe alongside the crypto test.)

## Order of work

1. Engine rewrite (`p2p_sync_service.dart`): random port, hold-open host, idle
   timer, QR build/parse, 300k iters + `test/p2p_transport_test.dart` and the QR
   parts of `test/p2p_crypto_test.dart`.
2. Bundle rewrite (`sync_bundle_service.dart`): add-only merge + category/mode
   export + `test/p2p_bundle_test.dart`.
3. UI: `sync_home_screen.dart`, `send_to_device_screen.dart`,
   `receive_from_device_screen.dart`; delete `p2p_sync_screen.dart`; rewire
   `settings_screen.dart`.
4. Manifest check; docs update.
5. `flutter analyze`; run the two non-DB test files together and the bundle test
   on its own; then write the change log.

## Risks / call-outs

- **Add-only merge is materially more complex** than MIRROR (id remapping across
  ~14 tables, natural-key matching, relationship endpoint resolution). The bundle
  test is the safety net; this is where bugs will hide.
- **Protocol break:** a phone running the old build cannot sync with a new one.
  Acceptable for a single-app rollout; the version gate gives a clear message.
- **Natural-key false negatives:** a contact renamed on one phone (same number)
  is added again as a duplicate. This is the accepted trade-off of "Name + phone"
  (the user chose it over "phone only" to avoid wrongly merging namesakes).
- **Full Sync is no longer a wipe:** a receiver that already has data and picks
  "Full Sync" gets a *merge*, not a replace. If a true wipe-and-replace is ever
  wanted again, it would be a separate explicit mode (out of scope here).

## Out of scope (not building now)

- Two-way / continuous sync, mDNS auto-discovery, ringtone-audio transfer,
  background sync. All unchanged from the previous plan's exclusions.
