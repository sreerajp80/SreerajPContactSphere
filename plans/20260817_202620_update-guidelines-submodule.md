# Update `docs/guidelines` submodule pointer

**Status:** completed

## Files to be changed

- `.gitmodules` — no change (kept as is).
- `docs/guidelines` — the gitlink (submodule pointer) recorded in the superproject.
- New change log file under `change_log/` after the work is done.

No Dart/Flutter source file changes.

## The issue

The superproject still records the old guidelines commit `aed1261` ("Features"),
but the checked-out submodule is already at `2b381be` ("Update"), which is the
latest commit on the guidelines remote (`origin/HEAD`). So `git status` in the
main repo shows `docs/guidelines` as modified.

The new guidelines commit brings:

- `AGENTS_MD_GUIDELINE.md`, `CLAUDE_MD_GUIDELINE.md` — updated
- `DOCS_FOLDER_GUIDELINE.md` — updated
- `flutter_project_engineering_standard.md` (+ its README) — updated
- `guideline.md` — updated
- two new change-log / plan files about "mandatory l10n and no local system details"

The submodule working tree is clean; only the pointer in the parent repo is stale.

## The plan for the fix

1. Confirm the submodule is clean and at `2b381be` (already checked).
2. Stage the gitlink in the superproject: `git add docs/guidelines`.
3. Commit in the superproject with a message saying the guidelines submodule was
   moved from `aed1261` to `2b381be`.
4. Do **not** push unless the user asks.
5. Write the change log to `change_log/`.

## Note

The new guidelines add a rule about mandatory localisation (l10n) and about not
putting local system details in the repo. This project may not follow that rule
yet. Bringing the code in line with the new rule is **not** part of this plan —
it would be a separate plan.
