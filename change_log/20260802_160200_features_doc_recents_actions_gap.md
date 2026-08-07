# Change log — Document Recents context-menu actions in docs/features.md

Implements: `plans/20260802_160000_features_doc_recents_actions_gap.md`

## What changed

Edited `docs/features.md` only (section 2, "Recents / call history" bullet).
No code files were touched.

- Added that calls rejected by the native call-screener, and calls parked
  during call waiting, also appear in Recents with a distinct "Blocked"
  icon/label (`call_history_screen.dart`, `call_event_logger.dart`
  `drainBlockedCalls()` / `drainCallWaitingCalls()`).
- Added that long-pressing a Recents entry opens block/unblock, mark/unmark
  spam, Smart Redial & Reach Me, and "remove this entry" actions directly,
  without needing the dedicated Blocked Numbers screen.

## Why

A fresh, independent critical review (separate from the several review
rounds already done today) re-checked the doc against all screens, widgets,
services, repositories, and models. These two features in
`call_history_screen.dart` were confirmed in the code but were missing
from the doc. Everything else — including the "What this app is" summary
paragraph — was re-checked and already matched the code; no other gaps
were found.
