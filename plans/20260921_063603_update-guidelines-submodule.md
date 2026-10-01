# Update `docs/guidelines` submodule pointer

**Status:** completed

## Files to be changed

- `.gitmodules` — no change (kept as is).
- `docs/guidelines` — git submodule checkout moved to commit `eb4b462` (`origin/master`).
- Superproject gitlink (submodule pointer) recorded in the repository index.
- New change log file under `change_log/` after the work is done.

No Dart or Flutter source file changes.

## The issue

The `docs/guidelines` submodule (`https://github.com/sreerajp80/Flutter_Guidelines`) is three
commits behind its remote `origin/master`:

- Current submodule pointer in the superproject: `7e664ba` ("Updates")
- Latest commit on remote `origin/master`: `eb4b462` ("Updates")

New commits to pick up: `8c4861a`, `7ed5a36`, `eb4b462`.

Files changed across those three commits (20 files, about 2200 lines added):

- `AGENTS_MD_GUIDELINE.md`, `CLAUDE_MD_GUIDELINE.md`, `GUIDELINES_MANIFEST.md`, `README.md`
- `flutter_project_engineering_standard.md` (large update), its README, `guideline.md`,
  `release_process.md`, `docs/release_process_README.md`, `flutter_build_flavors_guide.md`
- Several new `plans/` and `change_log/` files inside the guidelines repository.

This matters because `CLAUDE.md` points at `docs/guidelines/flutter_project_engineering_standard.md`
and `docs/guidelines/guideline.md` as required reading for any code change. The local copy is stale.

## The plan for the fix

1. In `docs/guidelines`, check out `origin/master` (commit `eb4b462`).
2. In the superproject root, stage the updated submodule pointer: `git add docs/guidelines`.
3. Verify `git status` in both the submodule and the superproject.
4. Read the updated `GUIDELINES_MANIFEST.md`, `guideline.md`, and
   `flutter_project_engineering_standard.md` to check whether any new rule conflicts with this
   project's `CLAUDE.md` or `docs/`. Report any conflict; do not change `CLAUDE.md` in this task.
5. Create the change log in `change_log/` referencing this plan.
6. Commit only if the user asks. Do not push to any remote.

## Risk

Low. Documentation only. No app code, no schema, no build config. Reversible by pointing the
submodule back at `7e664ba`.
