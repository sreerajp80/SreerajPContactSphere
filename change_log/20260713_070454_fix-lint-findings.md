# Change log — Fix all lint findings from the new stricter rules

Implements plan `plans/20260713_070454_fix-lint-findings.md`.

## What changed

1. `dart fix --apply` — **450 automatic fixes across 89 files**:
   - 396 `always_use_package_imports` (relative → `package:` imports)
   - 34 `avoid_redundant_argument_values`
   - 10 `prefer_const_constructors`
   - 5 `use_decorated_box` (`Container` → `DecoratedBox`)
   - 3 `prefer_final_locals`
   - 1 `prefer_const_declarations`
   - 1 `avoid_bool_literals_in_conditional_expressions`
2. `dart format .` — normalized formatting (99 files reformatted).
3. A second `dart fix --apply` — **3 more fixes in 2 files** for
   `curly_braces_in_flow_control_structures` (single-line `if`s that reformatting exposed in
   `lib/services/p2p_sync_service.dart` and `lib/services/sync_bundle_service.dart`).

All edits are tool-driven and semantics-preserving. The 4 `prefer_const_constructors` cases
flagged in the plan as possibly needing manual work were resolved automatically during the
apply/format cycle — no hand edits were required.

## Verification

- `flutter analyze` → **No issues found!** (0 issues, down from 454).
- `flutter build apk --debug --flavor dev` → **built successfully**, confirming the whole
  project still compiles after the changes.

## Related

Follows plan `20260713_070255` (change log `change_log/20260713_070255_stricter-lint-rules.md`),
which enabled the lint rules that surfaced these findings.
