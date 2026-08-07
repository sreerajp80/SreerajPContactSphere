# Fix inaccurate "state management" claim in docs/features.md

**Status:** completed

## What the issue is

The user asked for a fresh critical review of `docs/features.md`: check that every
feature is listed, and that the "What this app is" description is inclusive.

I ran a full sweep (screens, services, native Kotlin code, `AndroidManifest.xml`,
and the opening description paragraph) and found the document is in good shape
overall — no missing screens, no missing features, and the opening paragraph
already fairly represents the depth of the file (an earlier review round already
fixed the paragraph and two smaller gaps).

One real inaccuracy remains, in the "Known gaps" section:

> **General app state management** — most screens use plain local `setState`.
> The `provider` package is wired up only for theme mode and accent color, not
> for app-wide state.

This is wrong. `lib/state/app_settings.dart` defines `AppSettings extends
ChangeNotifier`, provided app-wide via `ChangeNotifierProvider<AppSettings>` in
`lib/main.dart`. It is not limited to theme/accent — it holds and persists
around 27 different app-wide settings, each with its own setter that calls
`notifyListeners()`, including: ringtone volume/vibration, per-SIM ringtone and
color, default SIM, ask-before-call, dialer top-contacts source, dialpad
script, quick replies, contact sort order, name display format,
hide-without-phone toggle, relationship type names, app-lock mode,
secret-export inclusion, default country, block-unknown-callers, caller-ID and
spam-filter toggles, screenshot-guard, smart-redial enable/delay, and the
preset "Reach Me" message.

So the true gap is narrower than stated: individual *screens* (contacts list,
detail, etc.) still use local `setState` for their own UI state, but the
*settings* layer is already centralized through `provider`, not "wired up only
for theme mode and accent color."

This same wrong claim also exists in `docs/known-gaps.md` (lines 215–218,
"Architectural notes"), which `features.md` is paraphrasing. Fixing only
`features.md` would leave the source of the error in place, so this plan
touches both files for consistency.

## Files to be changed

- `docs/features.md` — correct the "General app state management" bullet
  under "Known gaps / not yet implemented".
- `docs/known-gaps.md` — correct the matching "State management" bullet under
  "Architectural notes", since it's the source `features.md` is paraphrasing.

## The plan for the fix

In both files, replace the claim that `provider`/`AppSettings` is "only for
theme mode and accent color" with an accurate one: `AppSettings` is an
app-wide `ChangeNotifier` covering roughly 27 persisted settings (ringtone,
SIM, dialer, security, sync-related toggles, etc.), not just theme/accent.
Keep the real gap intact — per-screen UI state (contacts list, detail, etc.)
still uses local `setState`, not `provider` — since that part of the claim is
still true.

No other changes. The rest of the document was checked line-by-line against
the code (screens, services, native Kotlin, manifest) and holds up.

## Why this shape

This is a documentation-only correction, one factual bullet in two files that
say the same wrong thing. No app behavior changes.
