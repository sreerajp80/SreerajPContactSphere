# Plan: fourteenth gap-fill pass on docs/features.md

**Status:** completed

## What the issue is

The user asked for a critical re-check of `docs/features.md` for missing
features and an inclusive app description — this is the 14th independent
pass. I re-read the whole doc plus the related docs (`architecture.md`,
`known-gaps.md`, `security.md`, `dependencies.md`,
`feature_analysis_and_roadmap.md`) and ran a fresh, independent codebase
sweep (all screens, services, widgets, native Kotlin files, `pubspec.yaml`,
and every `AppSettings` key) through a sub-agent that had not seen the doc,
so it could not just parrot it back.

Almost everything the sweep found is already in the doc (ephemeral
contacts, connected apps, caller ID's TRAI 140/160 heuristic, pre-call
summary timezone, Smart Redial vs. Quick Replies as separate features,
the "Reach Me" preset message, the P2P sync merge model and its emergency
-card exception, `allowBackup=false`, secret contacts, etc.). I checked
each flagged item by reading the actual source, not by trusting the
sub-agent's summary.

One real, verifiable gap survived that check:

- **`docs/features.md` section 2 ("Call blocking / spam filtering")** does
  not say that blocking still works when ContactSphere's own process isn't
  running. I read
  `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereCallScreeningService.kt`
  directly: the native call-screening service reads a plain
  `SharedPreferences` mirror of the blocked/spam lists and toggles (kept in
  sync by the Flutter side), so a call is rejected or silenced
  synchronously even on a cold start with no Flutter engine running at
  all. Blocked calls are also journaled (number + timestamp, capped at 200
  entries) in that same native prefs file and drained into Recents the
  next time the app opens. This is the same "keeps working with the app
  closed" pattern the doc already documents for the missed-call name
  mirror and the ringtone mirror, but it isn't said for call blocking
  itself — a reader could wrongly assume blocking needs the app running.

I also confirmed two things that turned out **not** to be gaps, so no
change is needed for them:

- The `geolocator` package is declared in `pubspec.yaml` but has zero
  usage anywhere in `lib/` or the native Kotlin code. It isn't described
  as a feature anywhere, so there's nothing in `features.md` to fix —
  `security.md` already correctly scopes its permission line to "BLE scan
  on older Android," which matches the code. (Not a `features.md` issue;
  not touching it.)
- The in-app "Features" showcase screen
  (`lib/screens/features_screen.dart`) still claims a "Quick notes
  timeline" and "automated follow-up prompts" that don't exist in code.
  `features.md` already carries a caveat about this screen containing
  unverified marketing copy, so this doesn't need a new gap entry.

## Files to be changed

- `docs/features.md` — one bullet edit in section 2 ("Dialer / calling"),
  the "Call blocking / spam filtering" bullet.

## The fix

Add a clause to that bullet stating that blocking/silencing is enforced by
the native call-screening service reading a mirrored native prefs copy of
the lists/toggles, so it keeps working even if the app's own process
isn't running (cold start), and that a call blocked while the app was
closed is logged into Recents once the app is reopened.

No other changes — the rest of the document, including the intro "What
this app is" paragraph, was re-checked against the fresh code sweep and is
still accurate and inclusive.

## Change log

After this edit is approved and made, a change log will be written to
`change_log/` following the same naming pattern as the prior thirteen
gap-fill passes.
