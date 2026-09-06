# Features screen: remove claims the app cannot deliver, add what is missing

**Status:** completed

## What I checked

`lib/screens/features_screen.dart` lists 8 categories and 29 features, each with a
description and three or four short "highlight" chips. I compared every description and
every chip against the real screens, services and native code. The page is a promise to the
user, so a chip naming something that does not exist is worse than a missing one.

## Issue 1 — Features and highlights that do not exist

| Where | Claim | Reality |
|---|---|---|
| Multi-Script T9 Keypad Search | chip "Speed dial shortcuts" | No speed dial anywhere in the app. The only match for "speed dial" in the whole repo is this chip. |
| Dual-SIM Calling Controls | "set a preferred default SIM for individual contacts" + chip "Per-contact default SIM" | There is no per-contact SIM setting. `SimPreferencesScreen` offers a global default SIM, an "Ask before each call" switch, and SIM colours. |
| Spoken Caller Announcements | chips "Custom prefix/suffix" and "Headset-only option" | `SpokenAnnouncementsScreen` has only: on/off, a quiet-hours exception with a time range, and a test button. Neither chip exists. |
| Spoken Caller Announcements | "Hear the caller's name **or phone number** spoken" | Only the name is announced (from the name mirror). An unknown number is not read out. |
| Duplicate Contact Finder | "matching names, phone numbers, **or emails**" | `ContactRepository.findDuplicateGroups` matches exact name key, transliterated search key, phone digits, and E.164 number. Email is deliberately excluded, as is phonetic matching. |
| Security Audit Log | "history of every time secret contacts, exports, or security settings were **accessed**" + chip "Access timestamps" | The audit log records contact create / edit / delete with before-and-after snapshots, hash chaining, per-entry undo, and a signed export. It logs no access events at all. |
| Default Country Dialing Code | chip "Smart carrier detection" | Nothing in the app detects a carrier. The setting only picks the country used to normalize numbers. |
| Encrypted Cloud Sync | chip "Automatic backups" | Cloud backup is manual — the screen's own button reads "Upload Encrypted Backup Now". Nothing is scheduled. |
| Device Contacts & Call Log Sync | "Two-way synchronization" + chips "Two-way live sync", "Conflict resolution" | Contact sync is four separate actions the user runs by hand (add device→app, add app→device, and destructive versions of each). There is no live sync and no conflict resolution — a match is skipped, not merged. Only the call log syncs on its own. |
| Offline Backup & Restore | "restore … with password **or biometric verification**" | Restore always needs the backup password. Biometrics only gate opening the Backup & Restore screen; they are not an alternative to the password. |
| Blocked Numbers Manager | "block any number directly from call history **or contact details**" | The contact card has no block action. Blocking is a long-press in Recents, the Block control on the call screen, or adding the number by hand. |
| Automatic Call Screening | "drop **known spam**" | There is no spam database. Screening checks your own blocked list, your own spam marks, and number-series rules. Worth rewording so it does not read as a cloud reputation service. |
| Screenshot Guard | "while viewing secret contacts and security settings" | The guard covers contact details, the in-call screen, the app lock screen, the secret contacts list, and the audit log. The description names the wrong screens and understates it. |
| 7 Relationship Spheres | "Family, Close Friends, Friends, Work, Professional, Acquaintance, and Services" | The seven in `RelationshipCategory` are Immediate Family, Extended Family, Family by Marriage, Professional, Educational, Social, Service. Five of the seven names are wrong. |
| Relationship Quiet Hours | "Silence calls … while allowing vital circles … to ring through" + chip "Per-sphere quiet rules" | Right in effect, wrong in mechanism. It is a single allow list — starred contacts, categories, tags, and named individuals. There are no per-sphere rules or schedules. |
| Rich Contact Profiles | chip "Custom labels & fields" | Custom labels exist; there is no custom-field feature in the contact model or schema. |
| Color Tags & Custom Groups | "Assign **colorful** tags" + chip "Color-coded tags" | Tags carry no colour. The tag cloud sizes a chip by how many contacts use the tag. |
| Top Contacts Quick Access | "most frequently called contacts or favorite family and friends" | Misses the third option, "Likely to answer now". |
| Local Wi-Fi Direct (P2P) | "Wi-Fi Direct" | It is an ordinary local Wi-Fi network, not Android Wi-Fi Direct. Both phones must be on the same network. |

## Issue 2 — Shipped features the page never mentions

- **AirQR** — animated multi-frame QR for contacts too large for one code.
- **CSV and vCard import / export** — the whole Contacts → Import / Export menu.
- **Ephemeral (temporary) contacts** — self-deleting after 2 h, 24 h, 7 days, or one call.
- **Connected apps** — opening WhatsApp / Telegram / Arattai from a contact.
- **Caller identification & spam filtering** — labelling unknown callers and ringing
  suspected spam silently. Only blocking is listed today.
- **Block unknown callers** — rejecting calls with no number.
- **Voice dial** — the microphone in the dialer that turns speech into a number or a name
  search, in English and Malayalam.
- **Contact counts & search index** — with its Rebuild.
- **App lock modes** — Off / Device lock / App PIN with a recovery code. The page mentions
  an "App PIN fallback" but never that App lock is a separate three-way setting.
- **The Help section itself** — 22 in-app guides, worth one line.

## Plan

One file changes: `lib/screens/features_screen.dart`. The data is a `const` list of
`_FeatureCategory` / `_AppFeature`, so this is text work only — no layout or widget changes.

### Step 1 — Correct what is wrong

Rewrite the descriptions and highlight chips listed in Issue 1. Rules I will follow:

- A chip must name something the user can actually find and use.
- Replace a false chip rather than deleting it, so each card keeps its three-chip shape,
  e.g. "Speed dial shortcuts" → "Favorites row"; "Per-contact default SIM" → "Default SIM
  or ask each time"; "Custom prefix/suffix" → "Malayalam announcements"; "Headset-only
  option" → "Quiet-hours exception"; "Smart carrier detection" → "Caller number matching";
  "Automatic backups" → "Manual upload"; "Access timestamps" → "Before & after snapshots";
  "Color-coded tags" → "Tag cloud sizing"; "Custom labels & fields" → "Custom labels".
- Name the seven relationship categories correctly.
- Reword quiet hours, contact sync, call screening, screenshot guard and restore so the
  mechanism matches the code.

### Step 2 — Add the missing features

Add these cards in the categories where they belong:

| Category | New card |
|---|---|
| Smart Dialer & Calling | Voice Dial (English & Malayalam) |
| Call Defense & Spam Blocking | Caller Identification & Spam Filter; Block Unknown Callers |
| Instant Contact Sharing & Scanning | AirQR Animated Code Streaming; CSV & vCard Import / Export |
| Contact Management & Relations | Temporary (Ephemeral) Contacts; Connected Messaging Apps |
| Privacy, Security & Vault | App Lock: Off, Device Lock or App PIN |
| Personalization & Accessibility | Search Index Health; In-App Help & Guides |

That takes the page from 29 to 39 features. The category list itself stays as it is.

### Step 3 — Keep the two pages in step

The Features screen and the Help section now describe the same things. Where a feature has
a help page, the Features wording will use the same names and paths as that page, so the
two never contradict each other again.

### Step 4 — Tests

- Add `test/features_screen_test.dart`: the screen builds, every category heading renders,
  and a few of the corrected claims are pinned (the seven category names appear; the words
  "speed dial", "per-contact default SIM" and "carrier" do not appear anywhere on the page).
- Run `dart format`, `flutter analyze` (must stay at zero) and `flutter test`.

## Files to change

**Edited**
- `lib/screens/features_screen.dart`

**Added**
- `test/features_screen_test.dart`

## Out of scope

Nothing in `lib/` outside the Features screen changes. If a claim turns out to be worth
building rather than removing (speed dial and a per-contact SIM are both reasonable
features), that is a separate plan — this one only makes the page tell the truth about the
app as it stands today.
