# Update the docs/guidelines submodule

Implements plan: `plans/20260929_215042_update-guidelines-submodule.md`

## What changed

- `docs/guidelines`: the submodule now points to `eb4b462`, the latest commit on the guidelines repo's `master` branch. The last commit in this repo pointed to `7e664ba`.
- Inside the submodule, the checkout was moved from the `glossary-contact-call-tag-phone-number` side branch back to `master`, and fast-forwarded to `origin/master`.
- The new pointer is staged. It has not been committed.

## Not included

- The glossary commit `5fed66b` ("Add Contact, Call, Tag and Phone number to the 8.5.4 glossary") is still on its side branch, locally and on the remote. It can be picked up once it is merged into `master`.

## Checks

- `git submodule status` shows `eb4b462 docs/guidelines (heads/master)` with no `+` mark, so the submodule is clean.
