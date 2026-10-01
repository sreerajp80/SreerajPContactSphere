# Remove local system details from old plans and change logs

**Status:** completed

## Files to change

38 files in `plans/` and `change_log/` that hold `file:///` links, plus these files with other local details:

- `plans/20260703_173130_pin-gradle-jdk.md` (JDK drive path)
- `change_log/20260703_165835_sim-ringtone-picker.md` (JDK drive path)
- `plans/20260711_100024_sync-to-device-local-account.md` (personal Google email)
- `plans/20260713_054101_about-screen-config-pattern.md` (drive path, personal email)
- `change_log/20260713_054101_about-screen-config-pattern.md` (drive path, personal email)
- `plans/20260713_071232_add-security-and-release-docs.md` (drive path)
- `plans/20260806_065728_roadmap-doc-reanalysis.md` (drive path)
- `change_log/20260806_070300_roadmap-doc-reanalysis.md` (drive path)

(Each file will be found by search when the fix runs; the folder named above is where the search found it.)

## Issue

The project rule says `plans/` and `change_log/` files may become public. They must use relative
repository paths only and must not show drive letters, local folders or personal email addresses.
A search found:

- 144 links that start with `file:///` followed by the drive and the project folder, in 38 files.
- Drive paths to a local JDK folder and to other local project folders (5 hits).
- Two personal email addresses (3 hits).

Two hits are false alarms and will stay as they are:

- `plans/20260830_113800_build_metadata_and_about_build_date.md` — the match is the end of `version:`
  followed by a regular-expression escape, not a drive path.
- `plans/20260807_021200_optical-airgap-and-qr-safety.md` — `http://192.168.1.1/malware.apk` is a
  made-up test input, not this machine's address.

## Plan

1. Markdown links: change `](file:///<drive>/<project folder>/some/path)` to `](../some/path)`. The
   link then still works from inside `plans/` or `change_log/`.
2. Any other `file:///<drive>/<project folder>/` text (inside backticks or brackets): remove the prefix so
   only the repository-relative path is left, e.g. `docs/features.md`.
3. JDK path: replace it with "a local JDK 24 install".
4. Paths to other local folders (the shared guidelines master copy and the list of other apps):
   replace with "the shared guidelines repository" (now `docs/guidelines/`) and "the author's list
   of other apps".
5. Personal Google email: replace with "the phone's Google account".
6. Author email in the About-config plan and log: replace with `<author email>`.
7. Search again with the same patterns and confirm only the two false alarms remain.
8. Write a change log.

Only text in these Markdown files changes. No code, no tests.

## Not included

- Old versions of these files remain in git history. Rewriting history needs a force push and is
  not part of this plan. Say so if you want it done as a separate step.
- The other audit findings (localization gaps, tooltips, cloud screens, docs) are separate plans.
