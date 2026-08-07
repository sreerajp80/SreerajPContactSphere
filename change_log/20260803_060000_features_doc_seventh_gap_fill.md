# Change log: seventh gap-fill pass on docs/features.md

Implements `plans/20260803_060000_features_doc_seventh_gap_fill.md`.

## What changed

`docs/features.md`, "What this app is" intro paragraph: added a clause
noting the app lets you organize contacts into tags and groups. Both are
major, fully-documented features in section 1, and Tags is one of only four
bottom-navigation tabs (`lib/screens/home_shell.dart`) — the same
navigational prominence as Contacts and Dialer, which the intro already
named — but the intro never mentioned them until now. Also tightened the
sentence flow around the edit (split one run-on sentence in two, cleaned up
a stray line break) without changing any other content.

No other gaps were found in this pass: a full independent cross-check of
`lib/` screens/services/models, native Kotlin files, and
`lib/state/app_settings.dart` against the document turned up nothing else
missing or inaccurate.

No code changes; documentation only.
