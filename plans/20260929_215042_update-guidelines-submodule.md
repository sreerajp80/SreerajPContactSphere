# Update the docs/guidelines submodule

**Status:** completed

## Files to change

- `docs/guidelines` (submodule pointer only)

## Issue

The `docs/guidelines` submodule is in a mixed state:

- The last commit in this repo points to `7e664ba`.
- The staged change points to `eb4b462`, which is the newest commit on the guidelines repo's `master` branch.
- The checked-out copy is on a side branch (`glossary-contact-call-tag-phone-number`) at `5fed66b`. That commit is one ahead of `master` and has not been merged.

If this repo points at a side-branch commit, it can break later if that branch is rebased or deleted.

## Plan

1. In `docs/guidelines`, switch back to `master` and fast-forward it to `origin/master` (`eb4b462`). The glossary branch stays in the guidelines repo and on GitHub, so nothing is lost.
2. In this repo, stage `docs/guidelines` so the pointer is `eb4b462`.
3. Check that `git submodule status` shows `eb4b462` with no `+` mark (which means clean).
4. Write a change log.
5. Do not commit or push unless the user asks.

The glossary entries (`5fed66b`) can come in later, once that branch is merged into `master`.
