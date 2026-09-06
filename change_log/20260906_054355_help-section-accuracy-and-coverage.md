# Help section: wrong facts fixed, missing topics added

Implements `plans/20260906_052800_help-section-accuracy-and-coverage.md`.

## What was done

The in-app Help section had drifted away from the code. Claims were checked one by one
against the real screens, services and native call code. Wrong text was corrected, and
eight new pages were written for features that had no help at all.

## Wrong facts that were corrected

**Menu paths.** About a dozen pointed at places that do not exist. Now correct:

- Blocked numbers → Settings → Contacts → Blocked numbers
- Smart Redial, Spoken caller announcement, Quick replies, Post-call options →
  Settings → SIM & calling
- Dialpad script → the card on the main Settings page
- Search index → Settings → Contacts → Contact counts & search index
- Device sync → Settings → Contacts → Device & cloud sync
- Online Provider Sync and Encrypted Cloud Backup (were "Online Sync" / "Cloud Backup")
- Backup & Restore (was "Backup")
- Bluetooth receive → Contacts → three-dot menu → Bluetooth transfer

**Features described that do not exist.**

- *Spoken announcements* claimed a headset-only mode, a custom speech prefix, and a speech
  rate. None exist. The page now describes what is really there: an on/off switch, a
  quiet-hours exception with a time range, a test button, and Malayalam announcements.
- *Smart Redial* claimed a retry limit. Replaced with the real settings — default retry
  delay, preset "Reach Me" message, and the list of waiting redials. Added the note that a
  scheduled redial is the only place the app dials by itself, and that it can be cancelled.
- *Per-contact SIM* was described twice. There is no such setting. Both places now point at
  Settings → SIM & calling → SIM Cards & Accounts (default SIM, "Ask before each call",
  SIM colours).
- *Duplicate detection by email* was claimed. Matching is by name key, transliterated name,
  phone digits and E.164 number only. The page now says so, and states plainly that email
  and sound-alike codes are deliberately not used because they merged unrelated people.
- *The audit log* was described as a record of vault unlocks and PIN changes. It is really
  a before-and-after history of contact create / edit / delete, with per-entry undo, hash
  chaining, and a signed export. Rewritten to match.
- *Blocking* was described as a 3-dot menu on a call entry or a contact card. It is a
  long-press in Recents, or the Block control on the call screen; the contact card has no
  block action. Corrected, and the "blocking a live call hangs it up immediately" behaviour
  was added.
- *The QR scanner* was said to be in the top search bar. It is in the Contacts three-dot
  menu.
- *Quiet hours* were explained backwards in the FAQ, as a list of who gets silenced. It is
  an allow list: everyone is silenced except starred contacts, categories, tags and people
  you add. Corrected in the FAQ and explained again on the Relationship categories page.
- *The seven relationship categories* were listed on the hub as "Family, Friends, Work".
  The real seven are Immediate Family, Extended Family, Family by Marriage, Professional,
  Educational, Social and Service.
- *The biometric page* listed three places the app asks for an unlock. Four more were
  missing: Backup & Restore, the audit log, an incoming Bluetooth transfer, and opening the
  app when App lock is set to Device lock. All added, along with the App PIN alternative.
- *The secret vault* entry point and auto-lock wording were corrected to match the padlock
  toggle in the Contacts tab.
- *Backup password recovery* in the FAQ suggested biometrics could stand in for a lost
  backup password. It cannot. Reworded.

## New help pages

Eight topics had no page at all:

- **Caller ID & spam filter** — the two Identification switches, marking a number as spam,
  and "Block unknown callers".
- **Call context & notes** — pre-call summary (including local time in the contact's city),
  "Likely to answer now" ordering, the ringing context card, and the post-call notes sheet
  with voice input. States plainly that this only advises and re-orders; it never dials.
- **Groups & tags** — groups, group ringtones, the tag cloud, and multi-select.
- **Import & export files** — CSV and vCard in and out, how secret contacts are handled,
  and AirQR animated-QR streaming.
- **App lock & PIN** — the three lock modes, setting a 4–6 digit App PIN, and the one-time
  recovery code.
- **Permissions explained** — every permission grouped by purpose, explicit vs implicit,
  and what stops working if one is refused.
- **Look, sound & region** — theme, accent colour, fonts and text size, display options,
  ringtones and vibration (with the contact → group → SIM → default order), and the default
  country.
- **Contact tools** — ephemeral self-deleting contacts, connected messaging apps, and the
  search index with its Rebuild button.

Three new FAQ entries were added too: why a blocked number still appears in Recents, why a
contact vanished on its own, and where groups and tags live.

## Files changed

**Added**

- `lib/screens/help/help_article.dart` — shared `HelpIntro` / `HelpSection` / `HelpBullet` /
  `HelpFooter` / `HelpArticleScaffold`, so the new pages do not each copy the same widgets.
  The older pages keep their own private copies; the rendered result is identical.
- `lib/screens/help/caller_id_spam_help_screen.dart`
- `lib/screens/help/caller_intelligence_help_screen.dart`
- `lib/screens/help/groups_tags_help_screen.dart`
- `lib/screens/help/import_export_help_screen.dart`
- `lib/screens/help/app_lock_help_screen.dart`
- `lib/screens/help/permissions_help_screen.dart`
- `lib/screens/help/personalization_help_screen.dart`
- `lib/screens/help/contact_tools_help_screen.dart`

**Edited**

- `lib/screens/help/help_home_screen.dart` — corrected subtitles, eight new cards, and a new
  "Personalization & Tools" section.
- `lib/screens/help/call_management_help_screen.dart`
- `lib/screens/help/call_screening_help_screen.dart`
- `lib/screens/help/duplicate_merge_help_screen.dart`
- `lib/screens/help/contact_sharing_help_screen.dart`
- `lib/screens/help/privacy_security_help_screen.dart`
- `lib/screens/help/biometrics_help_screen.dart`
- `lib/screens/help/faq_troubleshooting_help_screen.dart`
- `lib/screens/help/t9_dialing_help_screen.dart`
- `lib/screens/help/contact_sync_help_screen.dart`
- `lib/screens/help/cloud_sync_help_screen.dart`
- `lib/screens/help/p2p_sync_help_screen.dart`
- `lib/screens/help/relationship_categories_help_screen.dart` — added a quiet-hours section,
  which the hub had been promising.
- `test/help_screens_test.dart`

## Tests

`test/help_screens_test.dart` was rewritten:

- every help page is built and checked for its own app-bar title (22 pages);
- the hub is checked to show all six section headings, and to open a topic on tap;
- a file-system test asserts that every `*_help_screen.dart` on disk is imported by the hub
  and covered by the test map, so a future page cannot be orphaned;
- two of the corrections above are pinned by assertions, so they cannot silently regress.

Help pages are plain `ListView`s that build only what fits on screen, so the tests that look
for later sections pump into a tall viewport.

Results: `flutter analyze` — no issues. `flutter test` — 488 passed, 1 skipped.

## Noted, not changed

`lib/screens/features_screen.dart` carries the same kind of drift and is outside the Help
section: it advertises "Speed dial shortcuts" (not implemented anywhere), "Per-contact
default SIM" (does not exist), "smart carrier detection", and names the seven relationship
categories wrongly as "Family, Close Friends, Friends, Work, Professional, Acquaintance,
Services". This needs its own plan.
