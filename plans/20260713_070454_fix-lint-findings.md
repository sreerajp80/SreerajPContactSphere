# Fix all lint findings surfaced by the new stricter rules

**Status:** completed

## Issue

Enabling the §16.1 lint baseline (plan `20260713_070255`) surfaced **454 `info`-level findings**
in existing code. They are all style/quality, no errors, but the standard says repositories
SHOULD aim for zero analyzer warnings. This plan clears them.

Breakdown:

| Count | Rule | Auto-fixable by `dart fix`? |
|------:|------|---|
| 396 | always_use_package_imports | yes |
| 34 | avoid_redundant_argument_values | yes |
| 14 | prefer_const_constructors | 10 yes, 4 no |
| 5 | use_decorated_box | yes |
| 3 | prefer_final_locals | yes |
| 1 | prefer_const_declarations | yes |
| 1 | avoid_bool_literals_in_conditional_expressions | yes |

`dart fix --dry-run` confirms 450 are auto-fixable. The 4 remaining `prefer_const_constructors`
need manual review.

## Files to change

- Many files under `lib/` and `test/` — the edits are mechanical (relative → `package:` imports,
  add `const`, drop redundant default args, `Container` → `DecoratedBox`, `var`/`final` locals).
  Exact file list is whatever `dart fix` and the 4 manual fixes touch; no file list is enumerated
  here because the changes are tool-driven and low-risk.
- No change to `analysis_options.yaml` (already done in the previous plan).

## Fix

1. Run `dart fix --apply` to apply the 450 automatic fixes.
2. Run `dart format .` to normalize formatting the fixes may have shifted.
3. Run `flutter analyze` — expect ~4 `prefer_const_constructors` findings left.
4. Manually inspect and fix (or, if genuinely not const-able, leave with a brief justification)
   the remaining 4.
5. Re-run `flutter analyze` to confirm it is clean (or document any intentional remainder).

## Risk / safety

- `always_use_package_imports`, redundant-arg, and `const` fixes are semantics-preserving.
- `Container`→`DecoratedBox` (`use_decorated_box`) only triggers when the `Container` has just a
  decoration, so behavior is preserved.
- The bulk of the churn is import-line rewrites (396), which are safe.

## Verification

- `flutter analyze` returns clean (target: 0 issues, or only documented intentional ones).
- Sanity-check that the app still compiles. Full test suite is run **one file per invocation**
  (native-assets sqlite crash on batch runs — known project constraint), or at minimum the
  const-touched test files, to confirm nothing broke.
