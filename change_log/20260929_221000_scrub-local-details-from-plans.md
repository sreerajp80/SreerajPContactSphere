# Remove local system details from old plans and change logs

Implements plan: `plans/20260929_220215_scrub-local-details-from-plans.md`

## What changed

46 Markdown files in `plans/` and `change_log/` were edited (154 lines). Only text changed; no code
or tests.

- **`file:///` links (144, in 38 files).** Markdown links now use a relative path such as
  `](../lib/screens/in_call_screen.dart)`, so they still open from inside `plans/` or
  `change_log/`. Paths written as plain text (in backticks or brackets) now show only the
  repository-relative path, e.g. `docs/features.md`.
- **Local JDK path** in `plans/20260703_173130_pin-gradle-jdk.md` and
  `change_log/20260703_165835_sim-ringtone-picker.md`: now "a local JDK 24 install".
- **Paths to other local folders** (the guidelines master copy and the list of other apps) in the
  About-config, security-docs and roadmap plans and logs: now "the shared guidelines repository
  (now `docs/guidelines/...`)" and "the author's list of other apps".
- **Personal Google email** in `plans/20260711_100024_sync-to-device-local-account.md`: now "the
  phone's Google account".
- **Author email** in the About-config plan and change log: now `<author email>`.

## Left as it is

- `plans/20260807_021200_optical-airgap-and-qr-safety.md`: `http://192.168.1.1/malware.apk` is a
  made-up test input, not this machine's address.
- `plans/20260830_113800_build_metadata_and_about_build_date.md`: `version:` followed by a regex
  escape is not a drive path.
- Public GitHub links to the guidelines repository are not local details and were kept.

## Checks

- A new search for drive paths, `file:///`, LAN addresses, `localhost:<port>` and personal emails
  finds only the test URL above.

## Notes

- Some relative links point to files that no longer exist or were never created (for example
  `lib/screens/recents_screen.dart` and `lib/services/call_recorder_service.dart`). They were
  already broken before this change. This change only removed the local prefix.
- Old versions of these files remain in git history. Rewriting history was not part of this plan.
