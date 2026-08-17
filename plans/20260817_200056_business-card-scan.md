# Business card scan → new contact

**Status:** completed

## What the user wants

Point the phone at a paper business card (or pick a photo of one), let the app read the text,
and land in the Add contact form with the fields already filled. Today there is no way to do
this: the only "read a contact from outside" paths are QR scan, Bluetooth receive, and
vCard/CSV import.

## The issue

- No OCR anywhere in the app. `pubspec.yaml` has `image_picker` (photo pick) and
  `mobile_scanner` (barcodes only) — neither reads plain text from an image.
- `AddEditContactScreen` already accepts a prefilled `Contact` (`contact:` parameter, used by
  `QrScanScreen`), so the form side needs no new plumbing. What is missing is: a text
  recognizer, a parser that turns loose card lines into contact fields, and a screen to
  capture the photo and let the user check the result before the form opens.

## Design decisions

1. **OCR engine: `google_mlkit_text_recognition`.** It is the only practical offline text
   recognizer for Flutter on Android. It runs fully on-device — no card image or text ever
   leaves the phone, which matches how the rest of the app treats contact data (encrypted
   SQLite, no cloud). Latin script model only (the cards in scope are Latin); Malayalam is not
   covered by ML Kit's Latin recognizer, so Malayalam cards fall back to manual entry.
2. **Camera: reuse `mobile_scanner`'s camera? No.** `mobile_scanner` gives barcodes, not
   frames we can OCR cleanly. Instead use `image_picker` (already a dependency) with
   `ImageSource.camera` and `ImageSource.gallery`. This keeps the new native surface to one
   package, gets the system camera UI (focus, flash, retake) for free, and works for the
   user's case of an existing photo.
3. **The user always confirms before saving.** Parsing a card is guesswork, so the flow ends
   at the normal Add contact form (prefilled, nothing saved yet) — same shape as the QR
   import path. No silent writes to the DB.
4. **Own design, not a Google-style card reader.** The review screen uses the app's existing
   section/token styling from `AddEditContactScreen` (`_section`-style cards, theme tokens),
   not a new visual language, and is named "Scan business card".

## Flow

```
Contacts ⋮ menu → "Scan business card"
      → BusinessCardScanScreen: [Take photo] / [Choose from gallery]
      → on-device OCR (BusinessCardScanService)
      → BusinessCardParser maps lines → draft Contact
      → review sheet: shows each guessed field with a checkbox, plus the raw
        recognized text (expandable) so nothing read off the card is lost
      → AddEditContactScreen(contact: draft) → user saves as normal
```

## Parsing rules (BusinessCardParser)

Input: the recognized text lines, in reading order. Output: a draft `Contact`.

| Card content | Detection rule | Lands in |
|---|---|---|
| Email | line containing a `\S+@\S+\.\S+` token | `Email(type: 'official', isPrimary: true)` |
| Phone(s) | 7+ digits after stripping spaces/dashes/dots/brackets; `+`-prefixed kept; run through `PhoneNormalizer` | `PhoneNumber(type: 'official')`, first is primary |
| Website | token with `www.` or `http`, or a bare `*.com`-style domain that is not part of an email | `SocialLink(label: 'Website')` |
| Person name | first line that is not a phone/email/URL, has 1–4 words, and is not the company line; split into first / middle / last | `firstName`, `middleName`, `lastName` |
| Designation | line right after the name matching a job-title word list (Manager, Engineer, Director, Head, Officer, Lead, Consultant, Executive, President, Founder, Analyst, Architect, Developer, Designer, Specialist, Partner, Associate, Administrator, Coordinator, Supervisor, Advisor, Sales, Marketing…) | `OfficialDetails.designation` |
| Company | line with a company suffix (Pvt, Private, Ltd, Limited, LLP, Inc, Corp, Corporation, Technologies, Solutions, Services, Systems, Labs, Group, Industries, Enterprises, GmbH, Co.) | `Address(type: 'official').companyName` |
| Postal code | 5–6 digit run in an address-looking line | `Address.postalCode` |
| City / state / country | comma-split tail of the address block; last non-postal segment → `state`, the one before → `cityTown`; an explicit country name (checked against `PhoneNormalizer`'s country list) → `country` | `Address.cityTown`, `.state`, `.country` |
| Remaining address lines | everything else in the block below the company line | `Address.street` (joined with ", ") |
| Anything unmatched | — | kept in the raw-text panel on the review screen, not dropped silently |

Nothing is invented: a rule that does not fire leaves its field empty. The email local part
(e.g. `ajay.shankar`) is used as a *fallback* name only when no name line was found.

Worked example — the card in the user's photo parses to: first `Ajay`, middle `Shankar`, last
`K`; phone `+91 9497369134`; email `ajay.shankar@softwareone.com`; designation `Business
Development Manager`; company `SoftwareOne India Private Ltd.`; street `Tower B, 3rd Floor,
Global Technology Park, Bellandur`; city `Bangalore`; state `Karnataka`; postal `560103`;
website `www.softwareone.com`.

## Files to change

**New**

| File | Purpose |
|---|---|
| `lib/services/business_card_scan_service.dart` | Thin wrapper over ML Kit `TextRecognizer`: image path in, ordered lines + full raw text out; owns recognizer lifecycle and `close()`; turns engine failures into a typed `BusinessCardScanException` (never throws raw platform errors at the UI), mirroring `SpeechService`'s style. |
| `lib/utils/business_card_parser.dart` | Pure Dart, no Flutter/plugin imports (so it is unit-testable on the host): lines → `BusinessCardDraft` (draft `Contact` + list of unmatched lines + raw text). |
| `lib/screens/business_card_scan_screen.dart` | Capture (camera / gallery), progress state, error states (permission denied, no text found), then the review sheet → `AddEditContactScreen`. |
| `lib/widgets/business_card_review_sheet.dart` | Per-field checkboxes over the draft + expandable raw text; returns the accepted `Contact` or null. |
| `test/business_card_parser_test.dart` | Parser unit tests: the SoftwareOne card above, an Indian mobile without `+91`, a card with two phones, a name-only card, a card with no name (email fallback), and junk input (must return an empty draft, not throw). |

**Edited**

| File | Change |
|---|---|
| `pubspec.yaml` | add `google_mlkit_text_recognition: ^1.0.1` with a one-line comment saying what it is for (matches the file's existing commenting habit). |
| `lib/screens/contact_list_screen.dart` | new `'scan_card'` menu entry ("Scan business card") next to "Scan QR code", plus its `_handleMenu` case, reloading the list on a saved contact — same shape as `'scan_qr'` (lines ~779, ~987). |
| `android/app/build.gradle.kts` | bump `minSdk` only if ML Kit requires above the current value; verified during implementation, left untouched otherwise. |
| `docs/features.md`, `lib/screens/features_screen.dart` | list the feature under the existing "Contact Exchange" category. |
| `docs/dependencies.md` | one line on why `google_mlkit_text_recognition` is in the tree. |

`AndroidManifest.xml` needs **no** change — `CAMERA` and `READ_MEDIA_IMAGES` are already
declared (lines 36 and 66).

## Risks and how they are handled

- **APK size.** ML Kit's Latin text model adds roughly 15–20 MB (bundled model). Flagging
  this now: it is the cost of on-device OCR. If that is unacceptable, the alternative is the
  Play-Services-delivered variant (smaller APK, needs a one-time model download on first
  use) — say so and I will switch the plan to that.
- **OCR misreads.** Mitigated by the confirm-before-save flow and the raw-text panel; the
  user can fix anything in the Add contact form.
- **Nothing recognized.** Explicit empty state on the scan screen with a retake button, plus
  an "Enter manually" button that opens a blank Add contact form.
- **`flutter test` and the new plugin.** The parser test imports no plugin code, so it runs on
  the host. Per project history, sqlite-backed tests are run one file per invocation; this new
  test file touches no DB.

## Verification

1. `flutter pub get`, then `flutter analyze` — no new warnings.
2. `flutter test test/business_card_parser_test.dart` — all parser cases pass.
3. On the moto g54 (dev flavor, install confirmed before testing): scan the SoftwareOne card
   → check every field lands as in the worked example → save → reopen the contact and confirm
   phone, email, designation, and work address persisted.
4. Repeat with a gallery photo and with a blank sheet of paper (empty-state path).
