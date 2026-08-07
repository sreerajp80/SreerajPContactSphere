# Plan: ninth gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md`

## What the issue is

The user asked (again) to critically check that `docs/features.md` lists all
features and that the intro is inclusive. This doc has already had eight
gap-fill passes today, and the eighth found zero missing features. Rather
than trust that, I ran a fresh, independent audit (every file under
`lib/screens`, `lib/services`, `lib/models`, `lib/state`, `lib/widgets`,
every native Kotlin file, `AndroidManifest.xml`, and `pubspec.yaml`) against
the current doc.

This time it found three real, small gaps — user-facing behavior that exists
in code but isn't mentioned anywhere in the doc:

1. **Contact-list row quick actions "Email" and "Delete"**
   (`lib/screens/contact_list_screen.dart:1566-1606`, `_quickEmail` at
   line 633). Each contact row's expanded action bar has four buttons: Call,
   Profile, Email, Delete. The doc's §1 "Contact list" bullet only mentions
   "quick-call actions" — Email (opens `mailto:`) and Delete aren't named.

2. **Two extra contact-share formats: plain-text share and clipboard copy**
   (`lib/screens/contact_detail_screen.dart:114-167`, `_shareText` at
   line 208). The Share sheet actually offers 5 options: vCard, "Share as
   Text" (SMS-style text share), "Copy Name & Phone" (clipboard), QR code,
   and Bluetooth. Doc §4 only documents vCard, CSV, QR, and Bluetooth.

3. **Proximity-sensor screen-off during a call**
   (`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt:561-580`,
   `applyProximityLock`). Blanks the screen/touch while the phone is held to
   the ear during a call, like the stock in-call UI. Not mentioned in §2
   "Dialer / calling" or §13 "Native Android platform features".

No doc claim was found to lack matching code (the doc's "Known gaps" claims
about reminders-not-scheduled, no release obfuscation, and no in-app
"delete all data" were all re-confirmed as accurate).

On the intro paragraph: it already covers every headline capability. Two
body sections (§10 Appearance/theming, §11 Navigation/gestures) have no
presence in the intro, but these are UX polish, not headline features, so
this is a defensible minor omission rather than something that needs fixing.
No intro change is planned.

One side note, not a doc issue: `pubspec.yaml` lists `geolocator` as a
dependency with zero imports anywhere in `lib/` — dead, unused. Not a
feature to document; flagging only in case it's worth pruning from
`pubspec.yaml` later (out of scope for this doc-only plan).

## The plan for the fix

Make three small, targeted additions to `docs/features.md`, no other content
changed:

1. In §1 "Contact list" bullet (around line 48), extend "quick-call actions"
   to also name the Email and Delete quick actions available on each row.

2. In §4 "Sharing / interoperability" (around lines 185-188), add a bullet
   (or extend the vCard bullet) noting the two additional share options on
   the contact detail screen: plain-text share and clipboard copy of
   name/phone.

3. In §2 "Dialer / calling", near the in-call screen bullet (around line
   106-110), add a short clause noting the proximity-sensor screen-off
   during an active call.

No other changes. This keeps the doc accurate without padding it with detail
beyond what a reader needs.
