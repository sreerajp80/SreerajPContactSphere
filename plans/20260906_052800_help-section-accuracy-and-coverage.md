# Help section: fix wrong facts and cover the missing topics

**Status:** completed

## What I checked

I read every file in `lib/screens/help/` (the hub plus 14 topic pages) and compared each
claim with the real code: settings screens, services, repositories, and the native call
code. Below is what is wrong, and what is missing.

## Issue 1 — Wrong facts in existing topics

### A. Menu paths that do not exist

The real Settings list is: Security, Contacts, Dialpad script, Sync to Another Device,
Online Provider Sync, Backup & Restore, Encrypted Cloud Backup, SIM & calling, Ringtone,
Emergency info, Default country, Appearance, Features, Permissions, Help, About.

| Help page says | Real path |
|---|---|
| Settings → Blocked Numbers | Settings → Contacts → Blocked numbers |
| Settings → Smart Redial | Settings → SIM & calling → Smart Redial & "Reach Me" |
| Settings → Spoken Announcements | Settings → SIM & calling → Spoken caller announcement |
| Settings → Quick Replies | Settings → SIM & calling → Quick replies |
| Settings → Dialpad Script | Settings → Dialpad script (a card on the main Settings page) |
| Settings → Contact Index Health | Settings → Contacts → Contact counts & search index |
| Settings → Backup | Settings → Backup & Restore |
| Settings → Contacts → Sync | Settings → Contacts → Device & cloud sync |
| Settings → Online Sync | Settings → Online Provider Sync |
| Settings → Cloud Backup | Settings → Encrypted Cloud Backup |
| Settings → Security (to reach secret contacts) | The secret vault is opened from the contact list, not from Security |
| Settings/Contacts → "Receive over Bluetooth" | Contacts → menu → Bluetooth transfer |

### B. Features described that the app does not have

- **`call_management_help_screen.dart`** — Spoken announcements: claims you can "speak
  always, or only when wired headphones or Bluetooth headsets are connected", and that you
  can "customize the speech prefix and speech rate". The real screen has only: an on/off
  switch, a quiet-hours exception with a time range, and a test button. None of the three
  claimed options exist.
- **`call_management_help_screen.dart`** — Smart Redial: claims a "retry limit". The real
  screen has a default retry delay, a preset "Reach Me" message, and a list of active
  scheduled redials. There is no retry limit.
- **`duplicate_merge_help_screen.dart`** — claims duplicates are detected by "Matching
  Email Addresses". `ContactRepository.findDuplicateGroups` matches on exact name key,
  transliterated search key, exact phone digits, and canonical E.164 number only. Email is
  never used. (The code comment also records that phonetic matching was deliberately
  removed for causing false merges.)
- **`privacy_security_help_screen.dart`** — describes the Audit Log as a record of "vault
  unlocks, secret contact exports, and PIN updates". The real audit log records contact
  create / edit / delete with a full before/after snapshot, SHA-256 hash chaining, undo
  from the detail screen, and a signed export. It does not log unlocks or PIN changes.
- **`call_screening_help_screen.dart`** — says to block a number you "tap a call entry or a
  contact card, tap the 3-dots menu, and choose Block Number". In reality you **long-press**
  a Recents entry to get the action sheet, or use the Block control on the in-call screen.
  There is no block action on the contact card at all.
- **`contact_sharing_help_screen.dart`** — says the QR scanner is opened from "the QR icon
  in the top search bar". It is in the contact list overflow menu ("Scan QR code").
- **`faq_troubleshooting_help_screen.dart`** — the quiet-hours answer describes the feature
  backwards. It says you pick the spheres to silence. The real screen is an **allow list**:
  quiet hours silence everything except the starred contacts, relationships, tags, and
  specific contacts you allow.
- **`help_home_screen.dart`** — the Relationship Spheres card says "The 7 relationship
  buckets (Family, Friends, Work) ... and quiet hours". The real seven are Immediate
  Family, Extended Family, Family by Marriage, Professional, Educational, Social, Service.
  The page also says nothing about quiet hours.
- **`biometrics_help_screen.dart`** — "Where you are asked" lists only three places. It
  actually also guards: app start (App lock in Device-lock mode), the Audit Log, Backup &
  Restore, and an incoming Bluetooth transfer. It also omits that the App PIN can stand in
  for the device lock.
- **`privacy_security_help_screen.dart`** — says the vault "automatically locks whenever
  you leave the screen". Worth restating as what the code does: the secret list closes when
  you toggle it off or leave the contact list, and App lock re-locks the whole app.

## Issue 2 — Topics with no help page at all

These are shipped, user-visible features with nothing in Help:

1. **Contact organisation** — groups (with per-group ringtones), colour tags, the tag cloud,
   and bulk selection.
2. **Import & export files** — Contacts → menu → Import / Export (CSV and vCard both ways).
   Today only QR / BLE / backup sharing is documented.
3. **AirQR (animated QR)** — streaming large or multi-contact vCards over animated QR codes
   with no Bluetooth or network. Completely undocumented.
4. **Temporary (ephemeral) contacts** — contacts that expire after a chosen time.
5. **Connected apps** — opening WhatsApp / Telegram / Arattai and other messengers straight
   from a contact.
6. **Caller intelligence** — the pre-call summary, "Likely to answer now" ordering, and the
   best-time-to-reach advice. Important to state plainly that this only advises and re-orders;
   it never dials.
7. **Post-call notes and feedback** — the post-call sheet, voice-to-text notes, the
   interaction timeline, and the Post-call options settings.
8. **Appearance and accessibility** — theme mode, accent colour, font family and text scale,
   plus the Malayalam fonts.
9. **Ringtones, volume and vibration** — per-SIM, per-group and per-contact ringtones.
10. **Caller identification and spam filtering** — the two Identification toggles (label
    unknown callers; ring suspected spam silently) and "Block unknown callers". These belong
    with call screening but are not mentioned anywhere.
11. **App lock modes** — Off / Device lock / App PIN, and how to set or change the PIN.
12. **Search index health** — contact counts, what the index is for, and when to rebuild it.
    Only a one-line FAQ mention exists today.
13. **Default country** — what it changes (number formatting, caller matching, blocklist
    matching).
14. **Permissions** — what each permission is used for and which are optional.

## Plan

### Step 1 — Correct the existing pages

Edit text only, no layout or widget changes:

- `lib/screens/help/help_home_screen.dart` — fix the Relationship Spheres subtitle; fix any
  other subtitle that no longer matches its page; add the new cards from step 2.
- `lib/screens/help/call_management_help_screen.dart` — rewrite the spoken-announcement and
  smart-redial sections to match the real settings; fix all menu paths; mention the
  Malayalam announcement voice.
- `lib/screens/help/call_screening_help_screen.dart` — fix the blocking steps (long-press in
  Recents, or Block on the in-call screen); fix the Blocked numbers path; add the "blocking
  during a live call disconnects it immediately" behaviour and blocked unknown callers.
- `lib/screens/help/duplicate_merge_help_screen.dart` — remove the email claim, describe the
  real match rules, and correct the Backup path.
- `lib/screens/help/contact_sharing_help_screen.dart` — fix the QR scanner and Bluetooth
  entry points; add AirQR and the CSV / vCard import-export, or link to the new page.
- `lib/screens/help/privacy_security_help_screen.dart` — rewrite the Audit Log section to
  describe contact-change history with undo and signed export; correct the vault entry point
  and the auto-lock wording.
- `lib/screens/help/biometrics_help_screen.dart` — complete the list of places you are asked,
  and mention the App PIN.
- `lib/screens/help/faq_troubleshooting_help_screen.dart` — fix the quiet-hours answer, the
  index-rebuild path, and the block / duplicate paths; add FAQs for the new topics.
- `lib/screens/help/contact_sync_help_screen.dart`, `p2p_sync_help_screen.dart`,
  `cloud_sync_help_screen.dart`, `backup_help_screen.dart`,
  `relationship_categories_help_screen.dart`, `emergency_info_help_screen.dart`,
  `t9_dialing_help_screen.dart` — path corrections only; their substance checked out.

### Step 2 — Add the missing pages

New files under `lib/screens/help/`, each following the existing
`_Intro` / `_Section` / `_Bullet` / `_Footer` pattern:

| New file | Covers |
|---|---|
| `groups_tags_help_screen.dart` | groups, group ringtones, colour tags, tag cloud, bulk actions |
| `import_export_help_screen.dart` | CSV and vCard import / export, plus AirQR |
| `caller_intelligence_help_screen.dart` | pre-call summary, likely-to-answer ordering, post-call notes and voice input, interaction timeline |
| `caller_id_spam_help_screen.dart` | caller identification, spam filtering, block unknown callers |
| `app_lock_help_screen.dart` | Off / Device lock / App PIN, changing the PIN, re-lock behaviour |
| `personalization_help_screen.dart` | theme, accent colour, fonts and text size, ringtones, volume and vibration, default country |
| `contact_tools_help_screen.dart` | temporary contacts, connected apps, search index health and rebuild |
| `permissions_help_screen.dart` | each permission, why it is needed, which are optional |

The Help hub gains these under its existing section headings, with one new heading
("Personalization & Tools") for the last three.

### Step 3 — Tests

- Extend `test/help_screens_test.dart` so every help page, including the new ones, builds
  and shows its title.
- Add a test asserting the hub links to every page in `lib/screens/help/`, so a future page
  cannot be orphaned.
- Run `flutter analyze` (must stay at zero) and `flutter test`.

## Files to change

**Edited**
- `lib/screens/help/help_home_screen.dart`
- `lib/screens/help/call_management_help_screen.dart`
- `lib/screens/help/call_screening_help_screen.dart`
- `lib/screens/help/duplicate_merge_help_screen.dart`
- `lib/screens/help/contact_sharing_help_screen.dart`
- `lib/screens/help/privacy_security_help_screen.dart`
- `lib/screens/help/biometrics_help_screen.dart`
- `lib/screens/help/faq_troubleshooting_help_screen.dart`
- `lib/screens/help/contact_sync_help_screen.dart`
- `lib/screens/help/p2p_sync_help_screen.dart`
- `lib/screens/help/cloud_sync_help_screen.dart`
- `lib/screens/help/backup_help_screen.dart`
- `lib/screens/help/relationship_categories_help_screen.dart`
- `lib/screens/help/emergency_info_help_screen.dart`
- `lib/screens/help/t9_dialing_help_screen.dart`
- `test/help_screens_test.dart`

**Added**
- `lib/screens/help/groups_tags_help_screen.dart`
- `lib/screens/help/import_export_help_screen.dart`
- `lib/screens/help/caller_intelligence_help_screen.dart`
- `lib/screens/help/caller_id_spam_help_screen.dart`
- `lib/screens/help/app_lock_help_screen.dart`
- `lib/screens/help/personalization_help_screen.dart`
- `lib/screens/help/contact_tools_help_screen.dart`
- `lib/screens/help/permissions_help_screen.dart`

## Out of scope (flagged, not changed)

`lib/screens/features_screen.dart` has the same kind of drift — it lists "Speed dial
shortcuts" (no such feature in the code), names the seven spheres wrongly as "Family, Close
Friends, Friends, Work, Professional, Acquaintance, Services", and claims "smart carrier
detection". That is the Features page, not Help. Say the word and I will fix it in the same
pass or in a follow-up plan.
