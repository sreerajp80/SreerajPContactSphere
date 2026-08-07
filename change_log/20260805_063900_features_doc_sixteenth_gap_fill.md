# Features doc — sixteenth gap fill

Implements: `plans/20260805_063900_features_doc_sixteenth_gap_fill.md`

## What changed

`docs/features.md` only, no code changes:

1. App Description intro: added a clause on relationship-health scoring and
   "why is this person calling?" caller context, and a clause on rejecting a
   missed call with a canned text reply.
2. Section 1, duplicate detection bullet: added that tapping a different
   non-kept contact re-points which one is "kept," and that a sticky bottom
   bar can merge all duplicate sets in one tap ("Merge all sets"), on top of
   each set's own Merge button.
3. Section 1, relationships bullet: expanded "visual relationship sphere" to
   describe re-centering on tap, the long-press menu (re-centre/open
   profile/edit type/remove), and jumping to edit a type from its edge
   label.
4. Section 2, caller context bullet: added that the context is assembled
   into a single natural-language headline shown to the user.
5. Section 2, quick replies bullet: clarified the canned reply list itself
   is user-managed (add/edit/delete/reset), not just a fixed set plus
   one-off free text.
6. Section 4, BLE bullet: added the receiver's proximity label (from signal
   strength, not raw numbers) and the 2-minute idle auto-timeout.

Two things the audit turned up were intentionally left alone: `geolocator`
is declared in `pubspec.yaml` but unused in `lib/` (a `docs/dependencies.md`
accuracy question, out of scope here), and the contact-picker sheets are
internal building blocks already covered indirectly through the
already-documented flows they power.
