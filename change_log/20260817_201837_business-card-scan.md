# Business card scan → new contact

Implements [plans/20260817_200056_business-card-scan.md](../plans/20260817_200056_business-card-scan.md).

## What was added

A new way to create a contact: photograph a paper business card (or pick a photo
of one), the text is read on the phone, and the Add contact form opens already
filled in. Reached from the contacts list ⋮ menu → **Scan business card**.

Flow: pick camera or gallery → on-device OCR → parser maps the lines to fields →
review sheet (tick box per field, plus the full scanned text) → normal Add
contact form, prefilled. Nothing is written to the database until the user saves,
the same rule the QR import path follows. The image and the recognized text never
leave the device.

## New files

- `lib/services/business_card_scan_service.dart` — wrapper over ML Kit's Latin
  text recognizer. Image path in, lines out, sorted into reading order (by
  vertical position, left-to-right for lines on the same row). Engine failures
  become a `BusinessCardScanException` with a user-facing message; an image with
  no text is not an error.
- `lib/utils/business_card_parser.dart` — pure Dart (no Flutter, no plugins), so
  it is host-testable. Maps lines to name / phones / emails / designation /
  company / work address / website. It never invents a value: a rule that does
  not fire leaves its field empty, and unplaced lines come back in
  `BusinessCardDraft.unmatchedLines`.
- `lib/screens/business_card_scan_screen.dart` — capture buttons, reading state,
  "nothing to fill in" and "could not read" states, an "Enter manually instead"
  escape, and the hand-off to the Add contact form.
- `lib/widgets/business_card_review_sheet.dart` — one tick box per field read,
  the unplaced lines, and an expandable panel with all scanned text. Returns a
  contact built from the ticked fields only. The work address is reviewed piece
  by piece (company / street / city / state / postal code / country), because OCR
  gets the company right far more often than the street split.
- `test/business_card_parser_test.dart` — 9 tests: the full corporate card, a
  bare national number, a two-number card, a duplicate number, a name-only card,
  the email-local-part name fallback, junk input, no input, and unplaced lines.
- `android/app/proguard-rules.pro` — see the release-build fix below.

## Edited files

- `pubspec.yaml` — added `google_mlkit_text_recognition` (resolved 0.15.1).
- `lib/screens/contact_list_screen.dart` — "Scan business card" menu item and its
  `_handleMenu` case, reloading the list when a contact was saved.
- `lib/screens/features_screen.dart`, `docs/features.md` — the feature is listed
  under Contact Exchange.
- `docs/dependencies.md` — why the OCR package is in the tree, including its size
  cost.
- `android/app/build.gradle.kts` — wired `proguard-rules.pro` into the release
  build type.

`AndroidManifest.xml` needed no change: `CAMERA` and `READ_MEDIA_IMAGES` were
already declared. `minSdk` needed no change either (24, above ML Kit's 21).

## Two things found during implementation

1. **Release build failed on R8.** The plugin compiles against all five ML Kit
   script recognizers, but only the Latin one is bundled, so R8 reported the
   Chinese / Devanagari / Japanese / Korean option classes as missing and failed
   `minifyProdReleaseWithR8`. Fixed with a new `android/app/proguard-rules.pro`
   holding `-dontwarn` rules for those four packages (never reached at runtime —
   nothing asks for a non-Latin script), referenced from the release build type.
   This file was not in the plan; it is required to keep release builds working.
2. **A phone-label bug caught by the tests.** The regex that strips labels like
   "Mob:" also matched the single letter "T", so "Tower B, 3rd Floor" became
   "ower B, 3rd Floor". The label now must not run straight into more letters,
   and is only stripped from a line that actually yielded a number (so an
   initial like "M. Ajay" survives).

## Verification

- `flutter analyze` — no issues.
- `flutter test test/business_card_parser_test.dart` — 9/9 pass, including the
  exact expected parse of the SoftwareOne card from the plan.
- `flutter test test/features_screen_test.dart`, `test/widget_test.dart` — pass.
- `flutter build apk --debug --flavor dev` — builds (ML Kit native side compiles).
- `flutter build apk --release --flavor prod --split-per-abi
  --target-platform android-arm64` — builds after the R8 fix.

## Size cost

The arm64 prod release APK went from **34.3 MB** (v15.16.57+82, before this
change) to **46.3 MB** — about **+12 MB** for the bundled ML Kit Latin model.
Switching to the Play-Services-delivered model variant would cut most of that,
at the cost of a one-time model download on first use.

## Not done

On-device testing on the moto g54 with the real card. The dev debug APK builds
but has not been installed and driven through a scan, so the OCR quality and the
field mapping have not been checked against a physical card yet.
