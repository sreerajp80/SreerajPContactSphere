# ContactSphere — Feature Reference

This file is a reference for another LLM (or a developer) to check what this
app already does, before implementing a new feature. It is meant to be
accurate and complete as of the date it was written. If code has changed
since, trust the code over this file.

## What this app is

ContactSphere (package name `smart_contacts_dialer`) is an Android-only
Flutter app that combines an advanced contacts manager with a phone dialer.
All data is stored locally in an encrypted SQLite database (SQLCipher) — there
is no cloud backend. It can act as the phone's default dialer app, with its
own in-call UI that supports call waiting and merging a second call, sync
with the Android system contacts, sync directly with another phone over a
local network, and back up/restore its data as an encrypted file. It tracks
relationships between contacts (with duplicate detection and merge), lets you
organize contacts into tags and groups, and can block spam calls. It adds a
security layer of its own — app lock, hidden "secret" contacts, ephemeral
(self-destructing) contacts that expire on their own, an emergency-info
card, and a tamper-evident audit log of every contact change. A dialer that
doesn't answer gets a "Smart Redial" reminder notification instead of an
automatic retry, or a missed call can be answered with a canned text reply
instead. It scores the health of each relationship and surfaces "why might
this person be calling?" context before and during a call. It supports
English, Malayalam, and several other non-Latin scripts for T9 dialpad input. Contacts
can be shared or exchanged as a vCard, CSV, QR code, or directly over
Bluetooth to another phone, and it can show a contact's linked WhatsApp/
Telegram from the system contacts. It also supports multiple SIMs, with a
chosen default SIM and a distinct color per SIM.

This is an early-stage, actively developed app. Not every feature below is
finished — the "Known gaps" and "Roadmap" sections at the end call out what
is missing or only planned, so this file is not misread as claiming more
than what exists.

---

## 1. Contacts management

- Add/edit contact: name, formal name, salutation, phonetic key and transliteration key
  (used for sorting/search), multiple phone numbers, emails, addresses
  (personal/official), photo, a separate "calling card" photo (full-screen
  in-call background), organization/job details, birthday, anniversary, and
  meetiversary (the day you met) dates, social links, gender, blood group,
  tags, groups, per-contact ringtone with in-app preview, and relationship
  links.
- Contact detail screen: full profile view, call/message/share actions,
  pre-call summary, relationships section.
- Contact list: text search and voice search, favorites, quick actions on
  each row (call, view profile, email, delete). If a contact has more than
  one phone number, long-pressing its Call button opens a sheet to pick
  which number to dial, before the SIM chooser runs. Long-press a row to
  enter a multi-select mode, with a "select all visible" toggle and a
  bulk-delete action that asks for confirmation and reports how many
  contacts were
  deleted (and how many failed, if any).
  Secret contacts are hidden behind biometric/PIN gating. A "streak" badge
  (fire icon + count) shows on a contact's row when they've had 3 or more
  interactions in the last 30 days.
- Favorites (starred contacts).
- Groups: create/manage groups, add/remove members, per-group ringtone.
  Ringtone priority: contact tone > group tone > SIM tone > default.
- Tags: tag cloud sized by usage, per-tag member list, add/remove contacts
  from a tag, and rename/merge/delete a tag (long-press a chip in the Tag
  Cloud, or the app-bar menu on a tag's contact list). Delete is blocked while
  the tag still has members.
- Duplicate detection and merge: matches by exact full name, the
  transliteration search key, and phone number (digits or E.164) — an
  earlier phonetic step (Double Metaphone / Soundex) was removed because it
  produced false positives (e.g. unrelated names colliding on a truncated
  code), so it is name/search-key and phone matching only now — with a
  keep-one merge UI. The default selection is safety-tuned: a set matched by
  a shared phone number starts with every member ticked for merge, but a set
  matched only by name similarity (no shared number) starts every non-kept
  member unticked, so a false-positive name match isn't merged by accident.
  Tapping a different non-kept contact in a set re-points which contact is
  "kept" before merging. Each set has its own Merge button, and a sticky
  bottom bar also totals the selections across every set and can merge all
  of them in one tap ("Merge all sets"). A merge you've already confirmed is
  remembered by phone number, so the same person won't resurface later as a
  "new" duplicate even if Android reassigns the underlying device-contact id
  (this can happen after e.g. a WhatsApp re-link).
- When picking members for a group or tag, the app suggests contacts who share
  a house name (from their address) or an employer (from their organization),
  matched on a canonicalized key so spelling differences don't matter.
- Contact relationships: reciprocal typed links (e.g. Father ↔ Child), a
  visual "relationship sphere" centered on one contact, an editable list of
  relationship type names, and a "Relationship Health" overview screen
  (shown in the UI as the "Relation Status" screen). In the sphere, tapping
  another contact re-centers it on them; long-pressing a contact opens a menu
  to re-centre, open their profile, edit the relationship type, or remove the
  relationship; and tapping a relationship's type label jumps straight to
  editing that type.
- Relationship scoring: a weighted score based on call frequency, recency,
  and post-call sentiment, stored per contact.
- Ephemeral (self-destructing) contacts: created with a timed expiry
  (2h/24h/7d) or a "delete after 1 call" mode; never synced to the device's
  contacts, auto-deleted by a background check that runs roughly every 60
  seconds while the app is running. In practice a completed call scrubs the
  contact right away no matter which mode was chosen — the timer only
  matters if the contact is never called before it runs out. From the
  contact's detail screen you can also manage it directly: "+24 Hours"
  (push the expiry further out), "Keep Permanently" (convert it to a normal,
  non-expiring contact), or "Scrub Now" (delete it immediately). Scrubbing
  an ephemeral contact, by any of these paths, also deletes its matching
  call-history (Recents) rows, not just the contact record.
- Secret contacts: excluded from lists and device sync, viewable only after
  biometric/PIN authentication.
- A special "self" contact representing the phone's owner, excluded from
  duplicate merging.
- Audit log: every contact create/edit/delete/merge is recorded with a
  before/after snapshot, tamper-evident via a hash chain, with the chain's
  verification status shown live on the screen itself (a "Tamper-Proof
  Chain Verified" badge, or a warning naming the first tampered entry).
  Supports undo. Filterable by All/Added/Edited/Deleted. Old entries are
  pruned after 90 days or 5000 rows; a manual "Clear log" action can also
  wipe the whole log on demand (contacts themselves are untouched). Entries
  for secret contacts are hidden by default and only shown after a
  biometric/PIN check via a lock icon in the app bar; the signed export
  respects the same show/hide state, so exporting while secret entries are
  hidden leaves them out. Stays on-device by default; a "1-Click Export
  Signed Audit Log" action can export it as a signed JSON file and share it
  off-device via the system share sheet.

## 2. Dialer / calling

- A dedicated T9 dialer screen with live contact-match suggestions as you
  type on the keypad. If the typed number matches no existing contact, an
  "Add to contacts" shortcut opens the add-contact screen pre-filled with
  that number.
- Multi-script T9: works for English transliteration plus several other
  scripts (see section 9); the active keypad script is selectable in
  Settings.
- Voice dialing: tap the mic on the dialer and speak digits, words, or a
  contact name.
- Can be set as the Android default phone app (`ROLE_DIALER`), with its own
  in-call screen (answer/reject/mute/speaker/hold/end, duration timer). The
  in-call background falls back in order: the contact's calling-card photo,
  then their profile photo, then a gradient chosen by their relationship to
  the phone owner (warm for family, cool/flat for work), then the plain brand
  gradient. The screen blanks (proximity sensor) while the phone is held to
  the ear during a call, like the stock in-call UI. The in-call screen also
  has its own Block/Unblock button, shown both while ringing and once
  connected — a third way to block a number, besides the Blocked Numbers
  screen and the Recents long-press menu below; blocking while still
  ringing also hangs up the call immediately.
- Call waiting: a second incoming call while one is active shows an
  answer/reject card; answering holds the first call automatically.
- Multi-call handling: hold and swap between two active calls, add a second
  outgoing call from within an active call, and merge both into a
  conference call where the network supports it.
- In-call DTMF keypad: send touch-tones during a call (for IVR menus,
  conference bridges, etc.).
- Multi-SIM support: lists call-capable SIMs, lets you set a default SIM, or
  choose "ask before every call"; records which SIM each call used. Each SIM
  can be given its own display color, shown on the in-call screen.
- Smart Redial: after a user-chosen delay (1/3/5/10/15/30 min, set in SIM &
  calling settings), the app calls the contact back automatically — no tap
  needed. It's scheduled and fired natively: an exact Android alarm wakes a
  background receiver that places the call itself, with no app window and no
  Flutter engine needed, so it still fires when the app was killed for the
  whole delay (and survives a reboot). The SIM is decided when the reminder is
  scheduled — the one the unanswered call used, else your default SIM — so the
  retry never stops to ask. If the call can't be placed (the app is no longer
  the default dialer, or call permission was revoked), a "tap to call"
  notification is posted instead. A "Reach Me" SMS
  with an editable preset message can be sent instead. The schedule
  auto-cancels itself the instant the same number calls back — checked
  natively before the phone even rings, so it works even while the app isn't
  running. SIM & calling settings also lists any currently pending redials
  with a cancel action. The whole feature has a master on/off switch (on by
  default); when off, no post-call Smart Redial sheet is shown at all.
- Post-call feedback: an opt-in setting (off by default) that, when
  enabled, shows a sheet after each call to record sentiment, an intent
  tag, and notes — feeds the relationship score and can create a follow-up
  reminder.
- Pre-call summary: shows recent interactions, last call time, upcoming
  birthday, and an offline-computed local time for the contact, before you
  place a call.
- Caller context: pulls together relationship info, call history, the most
  recent call's note/intent/sentiment, reminders, and events to answer "why
  might this person be calling?" — assembled into a single natural-language
  headline shown to the user (e.g. "Ravi — your cousin. Last spoke 3 weeks
  ago. You owe him a callback. Birthday next Tuesday."). The card's header
  reads "Why they are calling" for an incoming call, or "About this contact"
  for an outgoing call, since "why are they calling" doesn't make sense for
  a call you placed yourself.
- Missed-call handling: a custom notification with "Call back" and
  "Dismiss" actions, replacing the system's own duplicate notification, and
  showing the contact's name even while the app is closed.
- Quick replies: a user-managed list of canned SMS texts (add/edit/delete,
  40-char default set, 160-char limit each, reset-to-default), plus a
  "Write your own…" free-text option, that you can send to a caller instead
  of answering, sent silently via the system's "reject call with message"
  API (no SMS app opens, no `SEND_SMS` permission needed). This is a
  different delivery path from Smart Redial's "Reach Me" message below,
  which opens the phone's own SMS app.
- Ringtone settings: master volume/vibration, per-SIM ringtone, per-contact
  or per-group override, with in-app preview. Every picker (default/SIM,
  per-contact, per-group) lets you choose between the phone's built-in
  ringtone list or any audio file from device storage.
- Recents / call history: outgoing calls logged live by the app; incoming
  and missed calls logged live while set as default dialer; a manual
  import from the Android system call log is also available, either as a
  merge (add/update only) or a destructive "replace" that clears the
  app's call history first and rebuilds it from the device. Calls the
  native call-screener rejects, and calls parked during call waiting, are
  also logged to Recents with a distinct "Blocked" icon/label. Long-
  pressing any entry opens block/unblock, mark/unmark spam, Smart Redial
  & Reach Me, "Copy number" (to the clipboard), "Share number" (via the
  system share sheet), and "remove this entry" actions, without needing to
  open the dedicated Blocked Numbers screen. Adding or editing a contact
  retroactively links any existing unlinked Recents rows whose number
  matches, so a call logged before the contact existed stops showing as a
  raw number.
- Caller ID: labels unknown numbers using the user's own spam marks plus
  heuristics for known Indian telemarketer number ranges (e.g. `140…`), a
  separate non-spam "Service call" label for known Indian service-number
  ranges (e.g. `160…`), and shows a separate STIR/SHAKEN verification flag
  where available.
- Call blocking / spam filtering: blocked numbers are rejected before the
  phone rings (via Android's call-screening API); optional "block unknown
  callers" and optional silent-ring for numbers that are either marked as
  spam by the user or match a known Indian telemarketer number range (e.g.
  `140…`), independent of any user mark. Screening does not need the app to
  be running: the native call-screening service decides from its own mirrored
  copy of the lists and toggles (kept in sync by the app), so blocking and
  silencing still work on a cold start with no Flutter engine alive. A call
  blocked while the app was closed is parked natively (number + time, most
  recent 200) and drained into Recents the next time the app is opened.
- A dedicated screen to manage the blocked/spam number lists.
- A dedicated identification settings screen with two independent toggles:
  local caller-ID heuristics (labeling/spam marks) and "filter suspected
  spam" (silent-ring for numbers that are user-marked spam or match a known
  telemarketer range) — these are separate switches, not one combined
  setting.
- Configurable source for which contacts the dialer's "top contacts" strip
  shows: "Most recent" (default), "Family & friends", or "Likely to answer
  now".
- Best-time-to-reach: the app measures, per contact, when calls to them
  actually get answered (answered vs. missed by part of the day, from the
  last 180 days of Recents). It shows this as a line on the contact's
  pre-call summary ("Usually answers after 5pm") and, if you pick the
  "Likely to answer now" source above, uses it to order the top-contacts
  strip. It stays silent unless the history really supports the claim — it
  needs at least 8 calls, 3 of them in the winning part of the day, and that
  part must answer at least 20 points better than the contact's average.
  **This is advice only: it never places or schedules a call.** Smart Redial
  remains the only auto-dial, and there you choose the delay yourself.

## 3. Search

- Text search and voice search across contacts.
- Matching supports phonetic similarity and Malayalam/English
  transliteration, not just exact text.
- Sortable by first name or last name.

## 4. Sharing / interoperability

- vCard (RFC 2426) export/import, for a single contact or the whole
  address book. Importing a vCard also writes each contact to the Android
  device address book, the same as adding a contact normally.
- CSV export/import. Unlike vCard import, CSV import is app-database only
  and does not write to the device address book.
- Two lighter-weight share options from a contact's Share sheet: "Share as
  Text" (name and numbers as a plain-text share) and "Copy Name & Phone" to
  the clipboard.
- Share a contact as a QR code; scan a QR code to import a contact.
- Bluetooth (BLE) contact exchange between two phones with this app
  installed — single contact or "send all," with progress shown. The
  receiving phone shows an approximate proximity label from signal strength
  ("Very close" / "Nearby" / "Weak signal — move the phones closer") instead
  of raw signal numbers, and a share with no activity for 2 minutes times
  out on its own with a "Try again" option. Photos are not included in a BLE
  transfer. BLE scanning requires location permission on older Android
  versions, so a location prompt can appear the first time you use this.
- The app responds to standard Android contact intents (view/edit/insert/
  pick a contact, `tel:` links) and is registered as a target for dial/call
  intents.
- Connected apps: a dedicated feature that reads links to third-party
  messaging apps (e.g. WhatsApp, Telegram) already associated with a
  contact in the Android system contacts, shows them on the contact, and
  opens them via intent.

## 5. Device (Android system) contacts sync

- Two-way merge with the phone's built-in Contacts app: name, phone
  numbers, emails, addresses, organization, birthday/anniversary, social
  links, and photo are synced both ways.
- App-only fields (gender, blood group, meetiversary date, ringtone, tags,
  groups, relationships, secret flag) are never pushed to the device and
  stay local to this app.
- Adding or editing a contact in this app also updates the device contact;
  deleting removes it from the device too.
- An initial sync runs in the background, plus incremental re-syncs after
  that.
- Optional one-directional "mirror" sync (overwrite one side from the
  other), separate from the normal two-way merge.
- You can choose which device account (local vs. a real Google/other
  account) new contacts are written into.
- Secret contacts are always excluded from device sync.

## 6. Phone-to-phone (peer-to-peer) sync

- Direct sync between two phones on the same local network, without any
  cloud service.
- Paired using a one-time code (shown as text and as a QR code); the
  connection is encrypted (AES-GCM, password-derived key).
- Choose between a full sync or syncing only specific categories.
- Merge is "add only" — the receiving phone gains new contacts, existing
  contacts and duplicates (matched by name + shared number) are not
  overwritten.
- App settings (not SIM-specific ones) are synced too: on a full sync the
  sending phone's settings overwrite the receiving phone's; on an
  incremental sync only settings the receiving phone doesn't already have
  are filled in.
- Not included in an incremental/selective P2P sync: links to device
  contacts, SIM-specific settings, ringtone audio files (only the file
  path), the "self" contact, and the audit log. A Full Sync is the one
  exception for the self contact: it is included in the payload and lands
  on the receiving phone as an ordinary (non-self) contact.
- The emergency info card is the one exception to "add-only": since it's a
  single record, not a list, it is only installed on the receiving phone if
  that phone has no card of its own — it never overwrites an existing one.
- Requires passing a biometric/PIN check before it can be opened from
  Settings.

## 7. Backup & restore

- Creates a password-protected backup file containing the whole database
  plus contact photos and calling-card images, encrypted (AES-GCM,
  password-derived key).
- Restoring fully replaces all existing app data; requires the backup
  password and a matching schema version. The audit log is cleared and one
  summary entry is logged after a restore.
- Requires passing a biometric/PIN check before it can be opened from
  Settings.

## 8. Security / privacy

- The local database is encrypted at rest (SQLCipher); the encryption key
  is stored in the Android Keystore.
- App lock: device biometric/PIN/pattern, or an app-only PIN with a
  recovery code. PIN and recovery codes are stored only as salted hashes,
  never in plain text.
- Secret contacts require passing the app lock to view, and default to
  hidden if authentication fails.
- Optional screenshot/screen-recording blocking, always on for the lock
  screen and secret-contact screens, toggleable elsewhere in Settings.
- The app opts out of Android's automatic OS-level backup of its data.
- Emergency info (ICE) card: an opt-in, field-by-field emergency profile
  (blood group, allergies, medicines, conditions, notes, address, organ
  donor status, emergency contacts) that can be shown on the lock screen,
  rendered as a QR code, backed by a persistent notification with a 1-tap
  emergency-call action, and
  re-shown automatically after a reboot. Emergency contacts can be called
  directly from this card without unlocking the phone. The full record
  always stays in the encrypted database; only a published subset of the
  fields the user opted to show on the lock screen is mirrored to plain
  Android storage, by design, so the lock screen can read it without
  unlocking.
- A permissions screen listing every permission the app uses and its
  current grant status.

## 9. Localization / accessibility

- Full support for both Malayalam and Latin script in names, T9 typing,
  transliteration, and search.
- T9 dialpad script is not limited to English/Malayalam: it also supports
  Devanagari, Cyrillic, Arabic, and Greek character-to-digit mapping, plus
  an auto-detect mode based on device locale, and a "none" (Latin-only)
  mode. Selectable in Settings.
- Three bundled fonts (Manjari, Anek Malayalam, Noto Sans Malayalam),
  selectable in Settings.
- Standard Flutter localization delegates are wired in.

## 10. Appearance / theming

- Light, Dark, or follow-system theme, plus a full custom accent color
  picker, applied live.
- Font picker among the three bundled fonts.
- Text-size picker (Small/Default/Large/Larger), applied app-wide.
- Choice of T9 dialpad script/layout — see section 9 for the full list of
  supported scripts.

## 11. Navigation / gestures

- Bottom navigation with four tabs: Contacts, Dialer, Recents, Tags.
- Swipe right to go back on most screens (not during an active call).
- Swipe left to cycle between the home tabs; swiping right twice quickly
  prompts to exit the app.

## 12. Settings screen

Audit Log, Contacts (see "Contacts settings" below), Sync to Another
Device, Backup & Restore, SIM & calling (default SIM, per-SIM color,
caller ID, spam filter, quick replies, post-call feedback toggle, a Smart
Redial on/off toggle (on by default), delay, and "Reach Me" message, and a
list of pending Smart Redial reminders with a cancel action),
Ringtone, Emergency info, Default country (for
phone number formatting), Appearance, Features (an in-app showcase screen —
note it contains some marketing-style copy that is not fully backed by the
code, e.g. it describes a per-contact notes timeline that doesn't exist, so
don't treat it as ground truth on its own), Permissions, Help (separate
help pages for backup, biometrics, contact sync, emergency info, P2P sync,
and T9 dialing), About (version and build number, plus other app details
read from config, e.g. author/email), a default-dialer-role status card, an
app-lock-mode status card, a screenshot-guard toggle, and a card to choose
the dialer's "top contacts" source (Most recent / Family & friends / Likely
to answer now).

### Contacts settings

- Sort order (first name or last name) and, separately, name display
  format (e.g. "First Last" vs. "Last, First").
- "Hide contacts without a phone number" toggle.
- Search-index health check and rebuild: detects contacts whose stored
  phonetic/transliteration search keys have drifted from their current
  name, with a one-tap rebuild.
- Secret-contacts export: a separate, biometric-gated action to export
  secret contacts (CSV or vCard) on their own, plus a toggle for whether
  the normal CSV/vCard export includes secret contacts at all.
- A live count of device vs. app contacts.
- "Add Me": a shortcut to create or edit the "self" contact.
- "Sync": opens a dedicated screen grouping the manual device-contact
  actions (merge device→app, merge app→device with an account picker, and
  a destructive "mirror" — make one side match the other — in either
  direction) and the two call-log import actions (merge or destructive
  replace) described above.
- "Blocked numbers": opens the blocked/spam number list screen described
  in section 2.
- "Relationship names": opens the editable list of relationship type
  names described in section 1.

## 13. Native Android platform features

These are implemented in Kotlin (not Flutter/Dart) because they need direct
access to Android system APIs:

- Acting as the system's `InCallService` when set as default dialer:
  in-call notification with action buttons, ringing, missed-call
  notification.
- Call state tracking and control (answer/hold/mute/speaker), including
  fallback logic to resolve which SIM a "System default" call actually used.
- Pre-ring call screening that blocks calls from numbers on the block/spam
  list before the phone rings.
- Swapping the ringtone that plays for an incoming call based on which
  contact/group is calling.
- Handling the action buttons on notifications (e.g. "Call back",
  "Dismiss") via a non-exported broadcast receiver, with a one-time token so
  a malicious app can't trigger a callback on your behalf.
- Acting as a Bluetooth Low Energy peripheral (GATT server) to send a
  contact to another phone.
- Writing a contact directly to local (no-account) device storage — not
  something the Flutter contacts plugin supports on its own.
- Reading a contact's linked third-party messenger apps (e.g. WhatsApp,
  Telegram) straight from the Android contacts provider, for the
  "Connected apps" feature in section 4 — `flutter_contacts` doesn't expose
  this data.
- The emergency-info lock-screen card: notification, dedicated activity, a
  boot receiver to re-show it after restart, and QR code generation.

---

## Known gaps / not yet implemented

These are explicitly documented as missing in `docs/known-gaps.md` or
`docs/security.md` — do not assume they exist:

- **Call recording** — not implemented, and not planned. Android does not
  allow a sideloaded (non-Play-Store) dialer app to record calls; a
  local-mic-only workaround was considered and rejected as misleading to
  users.
- **Reminder notifications** — the app writes reminder rows (e.g. from
  post-call follow-ups) to the database, but nothing yet schedules an actual
  system notification for them. They are stored but not surfaced.
- **General app state management** — most individual screens (contacts list,
  detail, etc.) still use plain local `setState` for their own UI state.
  App-wide settings are already centralized, though: `AppSettings` (in
  `lib/state/app_settings.dart`) is a `ChangeNotifier` provided app-wide via
  `provider`, and it covers around 30 persisted settings — ringtone, SIM,
  dialer, security toggles, and more — not just theme mode and accent color.
- **Release build hardening** — release builds are not yet obfuscated
  (no `--obfuscate` / `--split-debug-info`), and there is no
  `proguard-rules.pro`. This is a known, accepted risk, not an oversight.
- **In-app "delete all data"** — there is no in-app way to fully wipe app
  data; the only way today is uninstalling the app.
- **iOS / Windows / other platforms** — this app is Android-only. There is
  no iOS or desktop support, and none is planned.

## Roadmap / aspirational — NOT implemented

These ideas appear in `docs/feature_analysis_and_roadmap.md` as proposals
for the future. None of them exist in the app today:

- An offline, multi-hop Bluetooth mesh network for broadcasting emergency
  info without internet or phone signal.
- Proactive "nudge" notifications from the relationship scoring engine
  (the scoring itself is implemented; alerting the user based on it is not).
- Multiple calling "personas" (e.g. switching between Work/Personal/
  Freelance modes).
  Both of the above quietly depend on the same missing piece: a working
  notification *scheduler*. Reminder rows are already written to the
  database (see "Known gaps" above), but nothing schedules an actual
  system notification for them yet. The app's existing notifications
  (missed call, emergency card, in-call) are all built natively via
  Android's `NotificationCompat`/`NotificationManager` in Kotlin, not a
  Flutter-side library — there is currently no notification-scheduling
  library wired in at all. Until that scheduler is built, neither
  relationship-decay nudges nor per-persona reminders can actually fire,
  regardless of how complete the scoring or persona logic is.
- A "decoy vault" — a second, fake unlock PIN that shows a decoy set of
  data.
- A floating note-taking overlay during a call.
- Reprioritizing dialer contact suggestions by time of day.
