# Change log — update `docs/guidelines` submodule

Implements: `plans/20260817_202620_update-guidelines-submodule.md`

## What changed

- The `docs/guidelines` submodule pointer in this repo was moved from
  `aed1261` ("Features") to `2b381be` ("Update").
- Commit in this repo: `4257f06` — "Update docs/guidelines submodule".
- Nothing was pushed. The commit is local on `main`.

The submodule working tree was already checked out at `2b381be` and was clean,
so no files inside `docs/guidelines` were touched. Only the pointer stored in
the parent repo was stale.

## What the new guidelines commit contains

- `AGENTS_MD_GUIDELINE.md` — updated
- `CLAUDE_MD_GUIDELINE.md` — updated
- `DOCS_FOLDER_GUIDELINE.md` — updated
- `flutter_project_engineering_standard.md` and its README — updated
- `guideline.md` — updated
- two new plan / change-log files about "mandatory l10n and no local system details"

## Follow-up (not done here)

The new guidelines add a rule about mandatory localisation (l10n) and about not
keeping local system details in the repo. This app has not been checked against
that rule. Doing so needs its own plan.
