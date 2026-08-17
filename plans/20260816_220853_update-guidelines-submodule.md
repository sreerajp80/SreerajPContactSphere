# Update guidelines submodule

**Status:** completed

## Files to change

- `docs/guidelines` (submodule pointer / gitlink in the main repo)

## Issue

The `docs/guidelines` submodule points at commit `aed1261`. The remote
(https://github.com/sreerajp80/Flutter_Guidelines, branch `master`) has one newer
commit, `2b381be "Update"`. The project is reading older guideline docs.

## Plan for the fix

1. Move the submodule working copy to `origin/master` (`2b381be`).
2. Check what changed in that commit, so we know if any project rule changed.
3. Stage the new gitlink in the main repo (`git add docs/guidelines`).
4. Leave the commit to the user unless they ask me to commit.

No app source code changes.
