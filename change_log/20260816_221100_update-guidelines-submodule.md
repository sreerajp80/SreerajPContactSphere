# Update guidelines submodule

Implements [plans/20260816_220853_update-guidelines-submodule.md](../plans/20260816_220853_update-guidelines-submodule.md).

## What changed

- `docs/guidelines` submodule pointer moved from `aed1261` to `2b381be` ("Update", branch `master`).
- The new gitlink is staged in the main repo. Not committed — left to the user.
- No app source code changed.

## What the new guidelines commit brings

Title: *Mandatory ARB String Externalization + No Local System Details In Plans/Change Logs*.

Files touched upstream: `guideline.md`, `flutter_project_engineering_standard.md`,
`CLAUDE_MD_GUIDELINE.md`, `AGENTS_MD_GUIDELINE.md`, `DOCS_FOLDER_GUIDELINE.md`, plus its own
plan and change log.

Two new rules that now apply to this project:

1. **ARB localization is mandatory.** `l10n.yaml` at the project root and `lib/l10n/app_<base>.arb`
   are required for every app, even a single-language one. All user-visible text must come from
   `AppLocalizations` — no raw string literals in widgets.
2. **No local system details in `plans/` and `change_log/`.** These files must use relative repo
   paths only: no OS user name, host name, drive-letter or home paths, LAN IPs, local server URLs,
   device serial numbers, personal email addresses, or any secret. They are committed and may
   become public.

Neither rule was applied to the project in this change — flagging them as follow-up work.
