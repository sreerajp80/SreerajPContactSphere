# Polish minor wording gaps in docs/features.md

**Status:** completed

## What the issue is

A follow-up critical review of `docs/features.md` (after the earlier
`20260802_145357_fix_features_doc_gaps.md` pass) found the doc is already
accurate and complete on substance — every screen and service in `lib/`
maps to something already described. Three small discoverability nits
remain:

1. The "Relationship Health" overview screen (section 1) is described but
   its actual screen name/entry point (`RelationStatusScreen`, "Relation
   Status" in the UI) isn't mentioned, so a reader can't map the doc text to
   the running app.
2. "Connected apps" (reads WhatsApp/Telegram/etc. links from synced
   contacts) is only mentioned in passing under Sharing (section 4) as part
   of a longer bullet, understating that it's its own distinct feature.
3. The Caller ID / spam-filter settings (section 2 and section 12) don't
   make clear that local caller-ID heuristics and "filter suspected spam"
   (silent-ring for spam-marked numbers) are two independent toggles on
   their own dedicated settings screen, not one combined switch.

## Files to be changed

- `docs/features.md` only. No code changes.

## The plan for the fix

1. **Section 1 (Contacts management)** — in the existing "Relationship
   Health overview screen" bullet, add its UI name: "shown as the 'Relation
   Status' screen."
2. **Section 4 (Sharing / interoperability)** — give "Connected apps" its
   own short bullet instead of folding it into a longer one, keeping the
   same factual content (reads links already present in Android system
   contacts; opens them via intent).
3. **Section 2 (Dialer / calling) and Section 12 (Settings screen)** — reword
   the caller ID / spam-filter mentions to note they are two independent
   toggles on one dedicated settings screen (local caller-ID heuristics vs.
   "filter suspected spam" silent-ring), not a single combined switch.

No other section changes. The "What this app is" intro is not touched —
it already covers all major pillars and doesn't need a new capability
mentioned.

## Why this shape

These are precision/discoverability fixes only, not new content — nothing
found in this review was actually missing from the doc. The goal is just to
make three existing descriptions easier for a reader (human or LLM) to map
onto the real screens and settings.
