# Features screen: false claims removed, missing features added

Implements `plans/20260906_055448_features-screen-accuracy.md`.

## What was done

The Features screen (Settings → Features) advertised things the app cannot do. Every
description and every highlight chip was checked against the real screens, services and
native code. Wrong claims were rewritten, and nine shipped features that were never listed
were added.

Only the `const _categories` list in `lib/screens/features_screen.dart` changed — no layout
or widget code was touched.

## Claims that were removed or corrected

- **"Speed dial shortcuts"** — no speed dial exists anywhere in the app. Replaced with
  "Matches names either way", which the T9 search really does.
- **"Per-contact default SIM"**, and the description promising a preferred SIM per contact —
  there is no such setting. The card now describes the real ones: a global default SIM, an
  "Ask before each call" switch, SIM colours, and the SIM shown in Recents.
- **"Custom prefix/suffix"** and **"Headset-only option"** for spoken announcements —
  neither exists. Replaced with "Malayalam announcements" and "Quiet-hours exception". The
  description also no longer claims a phone number is read out; only a saved name is.
- **"Smart carrier detection"** — nothing detects a carrier. Replaced with "Matches callers
  to contacts", and the description now explains what the default country actually does.
- **"Automatic backups"** for cloud storage — cloud backup is a manual upload. The card was
  merged with online provider sync and now says what each part really is.
- **"Two-way live sync"** and **"Conflict resolution"** for device sync — sync is four
  separate actions the user runs by hand, and a matching contact is skipped rather than
  merged. Rewritten to say the direction is chosen by the user, that it adds and updates but
  never deletes, and that only the call log arrives on its own.
- **"or emails"** in duplicate detection — matching is by phone number and by name,
  including transliterated names. Email and phonetic codes are deliberately excluded.
- **Audit log described as logging access** ("every time secret contacts, exports, or
  security settings were accessed", chip "Access timestamps") — it records contact create /
  edit / delete with before-and-after snapshots and per-entry undo. Retitled "Contact Change
  Audit Log" and rewritten.
- **"password or biometric verification"** on restore — restore always needs the backup
  password. Reworded, and the chip now says "Restore replaces everything", which is the part
  users need to know.
- **"block … from call history or contact details"** — the contact card has no block action.
  Now: long-press in Recents, the in-call Block control, or typing the number in. Added that
  blocking a live call hangs it up at once and that blocked calls still show in Recents.
- **"drop known spam"** — there is no spam database. Now says screening checks your own
  blocked list, entirely on the phone, with nothing looked up online.
- **Screenshot Guard scope** — named the wrong screens. Now lists what it really covers:
  contact details, a call in progress, the lock screen, secret contacts, and the audit log.
- **The seven relationship spheres** were listed as "Family, Close Friends, Friends, Work,
  Professional, Acquaintance, Services". Five of seven were wrong. Now the real seven:
  Immediate Family, Extended Family, Family by Marriage, Professional, Educational, Social,
  Service.
- **Quiet hours** described as per-sphere rules. It is one allow list — starred contacts,
  categories, tags, or named people. Rewritten, chip "Per-sphere quiet rules" replaced with
  "Allow list, not a block list".
- **"Custom labels & fields"** — custom fields do not exist in the model or schema. Now
  "Custom labels".
- **"Color-coded tags"** and "colorful tags" — tags carry no colour; the tag cloud sizes a
  chip by how many contacts use it. Retitled "Tags & Custom Groups" and reworded, with
  group ringtones added.
- **"Wi-Fi Direct"** — device sync uses an ordinary local Wi-Fi network. Retitled "Local
  Wi-Fi Device-to-Device Sync", with the QR pairing code and add-only merge mentioned.
- **Top contacts** listed only two of the three options; "Likely to answer now" was missing.

## Features added

Nine cards for things the app ships but never advertised:

| Category | Added |
|---|---|
| Smart Dialer & Calling | Voice Dial (speak a number or name, English & Malayalam) |
| Contact Management & Relations | Temporary (Ephemeral) Contacts; Connected Messaging Apps |
| Instant Contact Sharing & Scanning | AirQR Animated Code Streaming; CSV & vCard Import / Export |
| Call Defense & Spam Blocking | Block Unknown Callers; Caller Identification & Spam Filter |
| Personalization & Accessibility | Contact Counts & Search Index; In-App Help & Guides |

"Biometric & App PIN Lock" was also retitled "App Lock: Off, Device Lock or App PIN" and now
mentions the one-time recovery code.

The page goes from 33 features to 42. No feature was dropped. (The plan said "29 to 39" —
that was a miscount of the original list; nothing was left out.)

## Files changed

**Edited**
- `lib/screens/features_screen.dart` — the `_categories` list only.
- `test/features_screen_test.dart` — a test file already existed here. Its single test was
  kept (retitled inputs unchanged) and four new tests were added around it. Its fixed
  1000-pixel drag was changed to `scrollUntilVisible`, because adding the Voice Dial card
  pushed "Relationship Context Cards" out of reach of a fixed drag.

## Tests

The file now has five tests. The four new ones:

- builds the screen and checks all eight category headings render;
- reads `RelationshipCategory.values` and asserts every one of the seven display names
  appears on the page, so renaming a category in the model breaks this test instead of
  quietly leaving the page wrong;
- asserts that ten removed claims — "speed dial", "per-contact default sim", "carrier
  detection", "headset-only", "prefix/suffix", "conflict resolution", "automatic backups",
  "custom labels & fields", "color-coded tags", "wi-fi direct" — do **not** appear anywhere
  in the file, so none of them can creep back;
- asserts the ten newly documented feature titles are present.

The original test is kept as the fifth: the page builds and named feature cards render,
including one reached only by scrolling.

Results: `flutter analyze` — no issues. `flutter test` — 492 passed, 1 skipped.

## Note for later

Two of the removed claims describe features that would be reasonable to build rather than
delete: **speed dial** on the T9 keypad, and a **per-contact preferred SIM**. Neither exists
today. If either is built, delete its line from the "does not advertise" test in
`test/features_screen_test.dart` and put the claim back on the page.
