# Known gaps

The early-scaffold compile blockers have been resolved (see
`change_log/` entries for the 2026-06-25 build-out). `flutter analyze` is clean and
the widget smoke test passes. What remains are **declared-but-not-integrated**
features, not bugs.

## Resolved (2026-07-08 P2P sync re-architecture)
- **Phone-to-phone sync (connect-then-choose + add-only merge)** — re-architected
  from the earlier mirror/full-replace clone. Security is unchanged in spirit: a
  per-session ~320-bit pairing code (shown on the host as text **and a QR**,
  scanned/typed on the client, never sent) keys an AES-GCM payload
  (PBKDF2-derived, now **300k iters**); a wrong code fails to decrypt. The host
  binds a **random port** and **holds the connection open** after auth; the
  sender then picks a **Full Sync** or specific **categories** and pushes.
  **Merge is add-only ("client wins")**: the receiver keeps its data, incoming
  rows get new ids with every foreign key remapped, a contact already present
  (normalized name + ≥1 shared phone) is skipped, and history follows only
  newly-added contacts. `P2PSyncService` (transport/crypto + QR + hold-open host)
  + `SyncBundleService` (`SyncMode`/`SyncCategory` export + id-remapping merge) +
  `screens/sync/` (`sync_home_screen` hub → `send_to_device_screen` /
  `receive_from_device_screen`, shared `sync_views`), reached from Settings
  ("Sync to Another Device") behind a biometric check. Not copied: device-book
  links (`device_id`/`merged_device_ids`), SIM-account-keyed settings, ringtone
  audio (path-matched only), and the sender's `is_self` card. See
  `docs/architecture.md`. **Out of scope (deliberate):** two-way sync, mDNS
  auto-discovery, ringtone-audio transfer. Verified by `test/p2p_crypto_test.dart`,
  `test/p2p_transport_test.dart` and `test/p2p_bundle_test.dart`; the cross-device
  socket transfer + QR scan are verified manually on devices.

## Resolved (was a gap, now implemented)
- `lib/services/permission_service.dart` — implemented (defensive, never throws into
  `main`).
- Models `Address`, `OfficialDetails`, `CallSummary`, and `Group` — implemented with
  `toMap`/`fromMap`.
- Missing imports across models/repository/services — fixed.
- File picking — switched from `file_picker` (win32 conflict with `share_plus` 13) to
  the Flutter-team `file_selector`.
- Data layer — foreign keys are now enabled (`PRAGMA foreign_keys = ON`), FK indexes
  added (DB v2 with a v1→v2 migration), repository gained `getContactById`,
  `updateContact`, `deleteContact`, and `mergeContacts` now re-points every child
  table.
- Android runtime permissions — declared in `AndroidManifest.xml`.
- Screens — add/edit, detail (with dialer + pre-call summary), groups, and duplicates
  are implemented; the list screen is wired to all of them and gates secret contacts
  behind `AuthService` (biometrics).
- **Contact relationships** — the `relationships` table is now used:
  `RelationshipRepository` stores links as two reciprocal rows, the `Contact` aggregate
  hydrates them, and `relationship_screen.dart` renders the ego-centric "relationship sphere".
  Links can be added/removed from the contact detail screen, the add/edit form, and the sphere;
  the list screen's overflow menu opens the sphere on the most-connected contact.
- **Dialer, call history & post-call feedback** — there is now a standalone T9 `dialer_screen.dart`
  (with match-as-you-type contact suggestions) and a `call_history_screen.dart` ("Recents"), both
  first-class tabs in `home_shell.dart`'s `NavigationBar` alongside the contacts list. The
  place-a-call lifecycle (place → provisional log → reconcile on resume → re-score) is centralised in
  `services/call_service.dart` and `widgets/call_lifecycle_mixin.dart`, shared by the dialer, contact
  detail, and list quick-call. After each call a `widgets/post_call_feedback_sheet.dart` captures
  sentiment (→ `interactions.emotional_tone`, feeding the score), an intent tag and notes (→
  `call_logs`), and an optional follow-up `reminders` row. No schema change was needed.
- **Timezone lookup** — `PreCallSummaryService._getTimezoneForLocation` is implemented,
  offline only: a built-in city/country → IANA-zone map plus the bundled `timezone`
  database render e.g. `5:30 PM (Asia/Kolkata)` in the pre-call summary. An unmapped
  location still yields null, so the summary simply omits the line.

## Resolved (2026-06-30 device-contacts build-out)
- **Device-contacts sync** (`flutter_contacts`) — wired as a **live merge + full
  two-way sync**. `contacts` gained a `device_id` link (DB **v5**, additive `ALTER`
  migration). `DeviceContactService` wraps `flutter_contacts` with bidirectional,
  full-detail mappers (name, phones, emails, addresses, organization, birthday/
  anniversary events, social/websites, photo); app-only fields without a device
  equivalent (gender, blood group, meetiversary, ringtone, tags, groups,
  relationships, secret flag) stay in SQLite. `ContactSyncService` orchestrates the
  two sources: the contact list shows a de-duplicated merge of app + device
  contacts; add/edit pushes changes to the device; deleting in the app (detail-screen
  action, list long-press / Delete quick-action) removes the device contact too; and
  the device book is pulled into the app on permission grant (startup `main.dart`,
  `permissions_screen`). The contact list shows locally-stored contacts immediately and
  runs `syncFromDevice` in the background once the initial sync has completed (tracked by
  a persisted flag); only the very first run blocks behind a spinner, and read-only
  navigation does a cheap local-only re-read. **Secret contacts
  are app-only:** they are never written to the device, and making a contact secret
  deletes it from the device and clears its `device_id`. All device calls are
  best-effort/caught, so a missing permission or the host test VM degrades gracefully.

## Resolved (2026-07-01 default-phone-app build-out)
- **Default phone app (`ROLE_DIALER`) + in-call UI** — the app can now be set as Android's
  default dialer and shows its **own** in-call screen. A native Telecom bridge
  (`ContactSphereInCallService` + `CallRegistry` + `MainActivity` method/event channels)
  surfaces call state to Flutter (`TelecomService`, `CallState`), `in_call_screen.dart`
  renders answer/reject/mute/speaker/hold/end with a duration timer, and `main.dart` drives
  navigation off the call-event stream. Outgoing calls route through `TelecomManager` when
  we're default (else fall back to `flutter_phone_direct_caller`). Requesting the role lives
  on the Settings "Default phone app" card. Manifest adds the dialer + contact intent-filters
  and the `InCallService`; `minSdk` floored at 24. See `docs/architecture.md`. **Follow-ups
  this unlocks: the per-contact ringtone now plays on incoming calls (see "Partially
  integrated" below), and the per-group ringtone plays as of 2026-07-05 (contact tone >
  group tone > SIM tone > default). Still deferred: call recording** — the dialer role
  gives call *control*, not privileged access to call *audio*, so this is only permissible
  for a preinstalled/platform-signed dialer, **not** for this sideloaded build. See the
  "Deferred" section below for the full reasoning.

## Resolved (2026-07-01 multi-SIM build-out)
- **Multi-SIM support** — the app now enumerates the device's call-capable SIMs and can place
  outgoing calls over a chosen SIM. A native `getSimAccounts` (SubscriptionManager +
  TelecomManager, matched by phone-account id) feeds `SimService`; `MainActivity.placeCall`
  sets `EXTRA_PHONE_ACCOUNT_HANDLE` for the selected SIM. Settings has a **"SIM & calling"**
  screen (`sim_settings_screen.dart`) to pick the **default SIM** and toggle **"ask which SIM
  before each call"** (stored in `AppSettings`); when on with 2+ SIMs, `CallLifecycleMixin`
  shows `sim_picker_sheet.dart` before dialing. `call_logs` gained `sim_id` + `sim_label`
  columns (DB **v9**, additive migration); the SIM is written at placement (chosen SIM) and
  back-filled on reconcile from the device call log (`phoneAccountId`/`simDisplayName`).
  **Recents** now shows the SIM label, the call duration, and the number.
- **Incoming/missed calls in Recents** — while the app is the default dialer,
  `CallEventLogger` (started in `main.dart`, driven by the Telecom call-event stream) logs
  incoming and missed calls — each with its SIM and duration — into `call_logs`. Outgoing calls
  stay on the existing place→reconcile path (no double-logging). The native call snapshot now
  carries `phoneAccountId` and call `direction` (`Call.Details.getCallDirection` on API 29+,
  else a ringing heuristic). Requires being the default dialer; degrades to no incoming rows
  otherwise.
- **Calls with "System default" SIM stalling** — as the default dialer, placing a call with no
  chosen SIM (in-app default "System default", "ask" off) on a multi-SIM device whose OS SIM
  preference is "ask every time" parked the call in `SELECT_PHONE_ACCOUNT` with nothing to
  answer it, so **no call was placed**. `CallRegistry` now resolves such a call onto the OS
  default outgoing account (`getDefaultOutgoingPhoneAccount`), and `main.dart` shows the
  in-app SIM picker (→ `TelecomService.selectPhoneAccount`) when there is no OS default.

## Resolved (2026-07-05 voice-input + gestures build-out)
- **Speech to text** (`speech_to_text`) — now wired as **voice search + voice dialing**.
  `SpeechService` wraps the recognizer (singleton, never throws; mic permission via
  `PermissionService`, availability cached after one probe) and the shared
  `VoiceInputButton` gives both features the same mic UI (muted idle, pulsing accent
  while listening). Contacts list: mic in the search bar streams partial results into
  the existing DB-backed search. Dialer: mic in the number display; `VoiceDialParser`
  (unit-tested) classifies the final phrase — digits (spoken or worded, with a
  "call/dial" lead-in dropped) fill the number field, a name runs
  `searchContactSummaries` — one match auto-fills ready to call, several are listed in
  the strip under `Heard "…"`. The manifest gained the `android.speech.RecognitionService`
  `<queries>` entry (package visibility on Android 11+).
- **Navigation gestures** — a right fling on any pushed screen pops back to the parent
  (a root detector above the `Navigator` via `MaterialApp.builder`; inner horizontal
  gestures win the arena, and the in-call route is excluded so a stray swipe can't hide
  a live call). On the home shell: a left fling cycles the tabs circularly
  (Contacts → Dialer → Recents → Contacts), and two right flings within 2 s exit the
  app (first shows a "Swipe right again to exit" snackbar).

## Resolved (2026-07-05 sharing build-out)
- **QR** — fully wired. Share: contact detail → QR dialog (`qr_flutter`,
  `QrShareService`, 2026-07-03). Scan: contacts list menu → "Scan QR code"
  (`QrScanScreen`, `mobile_scanner` — the discontinued `qr_code_scanner` was never used and
  is gone from `pubspec.yaml`); a scanned vCard runs the same review/import flow as opening
  a `.vcf`.
- **BLE** (`flutter_blue_plus`) — wired as **BLE contact exchange**.
  Sender: contact detail → Share → "Share via Bluetooth" advertises the (photo-less) vCard
  from a native Kotlin peripheral (`BleShareServer.kt`: advertiser + GATT server behind the
  `contact_sphere/ble_share` channels — flutter_blue_plus is central-only, so the peripheral
  role had to be native). Receiver: contacts list menu → "Receive via Bluetooth"
  (`ble_receive_screen.dart`) scans via `flutter_blue_plus`, downloads over the chunked
  `size`/`offset`/`data` GATT protocol (`ble_protocol.dart`), and reuses the QR/.vcf
  review/import flow. Manifest gained `BLUETOOTH_ADVERTISE`. Contact **photos are not
  transferred** (kept sub-second; QR has the same limit). The contacts list menu also has
  **"Send all via Bluetooth"**: the whole book as one multi-contact vCard
  (secret contacts only per the export setting), advertised as "N contacts", with
  percentage progress on both ends and an idle — not absolute — sender timeout. Books
  beyond ~2,000 photo-less contacts would hit the receiver's 1 MB sanity cap.

## Deferred (investigated, postponed to a future phase)
- **Call recording** — intentionally not implemented, and for this app's distribution model it is a
  **platform limit, not a "postponed until we get to it" gap.** ContactSphere ships as a **sideloaded**
  default dialer, and in that setup two-way recording (capturing the remote party) is **not achievable**:
  - **The dialer role gives call _control_, not call _audio_.** Holding `ROLE_DIALER` grants the
    `InCallService`, the `Call` object, and `CallAudioState` routing — but **not** privileged audio
    permissions. Those are governed separately, and only the ROM's own phone app gets both.
  - **The privileged capture path is closed to a sideloaded app.** The call-audio sources (`VOICE_CALL`,
    `VOICE_DOWNLINK`, `VOICE_UPLINK`) are gated behind `CAPTURE_AUDIO_OUTPUT`, a `signature|privileged`
    permission. A sideloaded app (in `/data/app`, not platform-signed, no `privapp-permissions`
    whitelist entry) is **denied it at runtime** even while it is the default dialer — declaring it in
    the manifest does nothing.
  - **The only sideload-compatible remote-party path is rejected.** Forcing speakerphone and picking up
    both sides acoustically through the normal mic works, but it is device-dependent, low quality, and
    forces speaker — unusable in public. Not built.
  - **Local-mic-only is the sole sideload-safe capture**, and it records **your side only** (remote
    party faint or absent). If ever added it must be labeled as such so it is not mistaken for full-call
    capture.

  This is the same wall Google hit when it closed third-party call recording in Android 10; mic-based
  workarounds also violate Play policy. It **would** become genuinely possible only if the app were
  **preinstalled / platform-signed / rooted** (privileged capture path). Until then, the post-call
  feedback flow above is the deliberate substitute for "how the call went". Follow-up **reminder
  notifications** also remain unscheduled (see below).

## Partially integrated
- **Per-contact ringtone** — `contacts` has `ringtone_path` + `ringtone_label` columns
  (DB v4, with a v3→v4 migration). The Add/Edit screen has a ringtone picker (audio file via
  `file_selector`) and the contact detail screen shows the chosen tone. As of the 2026-07-02
  incoming-call ringing fix, the per-contact tone **now plays on an actual incoming call** when
  ContactSphere is the default dialer: the native `InCallService` owns ringing
  (`IN_CALL_SERVICE_RINGING`) and plays the system default tone immediately, then `InCallScreen`
  swaps in the caller's `ringtone_path` via the `setIncomingRingtone` method channel
  (`IncomingCallRinger`). Remaining limits: it applies only while we're the default dialer (a
  non-default app still can't reprogram the OS ringer), the swap is best-effort and honors ringer
  mode (silent → no sound). The **group-level** ringtone is real as of 2026-07-05 (DB v14 adds
  `groups.ringtone_label`): the Groups screen sets it, and a member without a tone of their own
  rings with the group's tone — the mirror map carries the effective tone (own tone, else the
  first toned group by name), so no native change was needed. An
  **in-app preview** (play/stop) of the selected tone is also available on the Add/Edit ringtone
  section, the contact detail ringtone row, and the per-SIM ringtone settings, via the native
  preview player (`MainActivity.previewRingtone`), which plays on the ring stream at ring volume.

## Resolved (2026-08-06 dead dependency cleanup)
- **`geolocator`** — declared in `pubspec.yaml` but never imported by any Dart file.
  The pre-call timezone lookup (`PreCallSummaryService`) uses an offline city/country → IANA-zone
  map (backed by the `timezone` package), not GPS. Removed to reduce APK weight and avoid
  unnecessary location-permission associations.
- **`flutter_ringtone_player`** — declared in `pubspec.yaml` but never imported. All ringtone
  playback (incoming-call ringing, in-app preview) is handled natively through
  `IncomingCallRinger.kt` and `MainActivity.previewRingtone`. Removed.

## Still not integrated (intentional, out of current scope)
- **Notifications / reminders** — the post-call feedback flow now *writes* follow-up rows to the
  `reminders` table (`ReminderRepository`), but nothing schedules notifications for them yet, so
  they are persisted-only. No notification-scheduling library is wired in; existing app
  notifications (missed call, emergency card, in-call) are all native Android
  (`NotificationCompat`/`NotificationManager`). As of 2026-08-06 the post-call feedback sheet's
  follow-up toggle shows a subtitle ("Saved for reference — notifications coming soon") so users
  know the reminder is stored but won't fire a notification yet.

## Architectural notes (not feature gaps)
- **State management** — most individual screens (contacts/detail/etc.) still use local
  `setState` for their own UI state. `provider` is wired app-wide for settings, though:
  `AppSettings` (in `lib/state/app_settings.dart`) is a `ChangeNotifier`, persisted via
  `shared_preferences`, provided in `main.dart`, and it covers around 27 persisted
  settings — theme mode, accent color, ringtone, SIM, dialer, security toggles, and
  more — not just theme mode and accent color.
