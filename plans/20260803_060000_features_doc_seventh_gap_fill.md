# Plan: seventh gap-fill pass on docs/features.md

**Status:** completed

## Files to change

- `docs/features.md`

## The issue

I did a fresh, independent review of `docs/features.md` against the code
(via a research agent that listed all `lib/` screens/services/models,
native Kotlin files, and `app_settings.dart`, and checked them against the
doc). The document is accurate after six earlier gap-fill passes today, with
one small gap left:

- The "What this app is" intro paragraph (line 8) names many features —
  contacts + dialer, encrypted storage, default-dialer role, call
  waiting/merging, device sync, P2P sync, backup/restore, relationships,
  security (app lock, secret contacts, ephemeral contacts, emergency card,
  audit log), Smart Redial, localization, sharing, and multi-SIM — but never
  mentions **Tags** or **Groups**. Both are major, fully-documented features
  in section 1 (tag cloud, rename/merge/delete, group ringtones, member
  management), and **Tags** is one of only four bottom-navigation tabs
  (`lib/screens/home_shell.dart`: Contacts, Dialer, Recents, Tags) — the same
  navigational prominence as Contacts and Dialer, which the intro already
  names. This matches the exact gap pattern the six earlier passes today
  fixed repeatedly for other features (sharing, multi-SIM, ephemeral
  contacts, audit log, Smart Redial were each added to the intro over those
  passes) — Tags/Groups were simply never caught.

No other missing features, wrong counts, or stale claims were found.

## The fix

Add one clause to the intro paragraph mentioning tags and groups for
organizing contacts, placed near where similar organizational features
(relationships, labels) are already mentioned. Small wording-only edit, no
other section changes.
