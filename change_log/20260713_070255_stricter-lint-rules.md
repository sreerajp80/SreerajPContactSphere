# Change log — Enable stricter lint rules

Implements plan `plans/20260713_070255_stricter-lint-rules.md`.

## What changed

- `analysis_options.yaml` — replaced the two commented-out example rules with the full
  recommended lint baseline from engineering standard §16.1 (24 rules), enabled on top of the
  existing `include: package:flutter_lints/flutter.yaml`. Added a short comment explaining the
  rules are deliberate additions and can be suppressed inline when needed.

Rules enabled: `avoid_print`, `prefer_single_quotes`, `prefer_const_constructors`,
`prefer_const_declarations`, `prefer_final_fields`, `prefer_final_locals`,
`avoid_unnecessary_containers`, `sized_box_for_whitespace`, `use_key_in_widget_constructors`,
`prefer_is_empty`, `avoid_empty_else`, `unnecessary_brace_in_string_interps`, `unnecessary_this`,
`no_duplicate_case_values`, `avoid_redundant_argument_values`, `sort_child_properties_last`,
`use_full_hex_values_for_flutter_colors`, `always_use_package_imports`, `cancel_subscriptions`,
`close_sinks`, `use_decorated_box`, `avoid_bool_literals_in_conditional_expressions`,
`noop_primitive_operations`, `use_enums`.

`flutter_lints: ^6.0.0` was already major-pinned in `pubspec.yaml`; no change needed there.

## Verification

`flutter analyze` runs cleanly (config parses, no errors). It now reports **454 new `info`-level
lint findings** in existing code — all style/quality, no errors. Breakdown by rule:

| Count | Rule |
|------:|------|
| 396 | always_use_package_imports |
| 34 | avoid_redundant_argument_values |
| 14 | prefer_const_constructors |
| 5 | use_decorated_box |
| 3 | prefer_final_locals |
| 1 | prefer_const_declarations |
| 1 | avoid_bool_literals_in_conditional_expressions |

## Scope note

Per the approved plan, this change **only enables the rules**. It does not fix the resulting
findings. Fixing them (especially the 396 relative→`package:` import conversions) is a larger,
separate effort to be decided on next.
