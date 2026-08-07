# Change log — Critical review fixes in docs/features.md

Implements: `plans/20260802_153000_features_doc_critical_review.md`

## What changed

Edited `docs/features.md` only. No code files were touched.

- **"What this app is" (intro paragraph):** added a sentence naming three
  pillars that were missing from the description even though the rest of
  the file documents them in depth: relationship tracking with duplicate
  detection/merge, caller ID and spam-call blocking, and the security layer
  (app lock, secret contacts, emergency-info card).
- **Section 1 (Contacts management), field list:** added "meetiversary"
  (the day you met a contact) to the list of fields a contact can hold — it
  is a real, editable field but was previously only mentioned in passing
  under the device-sync section.
- **Section 1, ephemeral-contacts bullet:** noted that expiry is enforced by
  a background check that runs roughly every 60 seconds while the app is
  running, not instantly.

## Why

A fresh critical review compared the doc directly against every screen and
service file in `lib/`, the native Kotlin code, and `AndroidManifest.xml`
(via a full codebase sweep), rather than trusting the document's own earlier
self-review. The doc held up well on substance — no fabricated features, no
missing screens or services — but these three gaps were found: one omitted
field, one omitted background mechanism, and an app description that didn't
mention some of the app's most distinctive capabilities.
