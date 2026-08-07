# Plan: fourth gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md` (documentation only, no code changes)

## The issue

`docs/features.md` has already had three gap-fill passes today (see
`plans/20260803_000000_...`, `plans/20260803_010000_...`,
`plans/20260803_020000_...`). The user asked me to critically re-check it
again, so I re-read the whole doc and had an Explore agent dig for anything
those three passes missed, then hand-verified its findings against the
source. Two real gaps survived verification:

1. **Wrong citation in the "Known gaps" section (near line 369-393).** The
   section says every bullet below it is "explicitly documented as missing
   in `docs/known-gaps.md`." That's only true for 3 of the 6 bullets (Call
   recording, Reminder notifications, General app state management). The
   other three bullets — Release build hardening, In-app "delete all data",
   and iOS/Windows/other platforms — are not in `known-gaps.md` at all. I
   checked: release-build hardening and "delete all data" are documented in
   `docs/security.md` (§8 M7 risk-acceptance, §17 open items) instead; the
   iOS/other-platforms bullet has no cited source doc at all (confirmed by
   grep — `known-gaps.md` never mentions iOS). Since the doc explicitly
   tells readers to trust `known-gaps.md` as the source for this section,
   this is a real broken promise, not a nitpick.

2. **Audit log bullet (section 1, near line 81) is missing the
   show/hide-secret-entries behavior.** I read
   `lib/screens/audit_log_screen.dart`: the screen hides audit entries for
   secret contacts by default (`_showSecret = false`), and a lock icon in
   the app bar (`_toggleSecret()`) requires a biometric/PIN check before
   revealing them — this also turns on the screenshot guard while shown.
   The signed export action (`_exportSignedLog()` →
   `AuditRepository.exportSignedAuditLog(includeSecret: _showSecret)`)
   respects the same show/hide state, so a signed export taken while secret
   entries are hidden excludes them. None of this is in the doc today, and
   it's a distinct behavior from the filter chips/clear/chain-badge that the
   third pass already added.

## The fix

Two small edits to `docs/features.md`:

1. **Known gaps section intro sentence** — reword to say the bullets are
   documented "in `docs/known-gaps.md` or `docs/security.md`" (both are
   real, already-existing project docs), instead of citing only
   `known-gaps.md`.

2. **Section 1, Audit log bullet** — add one clause noting that entries for
   secret contacts are hidden by default and require a biometric/PIN check
   (via a lock icon) to reveal, and that the signed export respects the same
   show/hide state.

No other wording changes.

## Not changing

- Everything the Explore agent re-checked and confirmed still matches the
  code: screens list, services list, repositories, `AppSettings` persisted
  settings, native Kotlin files, the intro paragraph's breadth, and the
  Roadmap section's fidelity to `feature_analysis_and_roadmap.md`.
- All fixes from the three prior passes today, which remain correct.
