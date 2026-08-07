# Enable stricter lint rules in analysis_options.yaml

**Status:** completed

## Issue

`analysis_options.yaml` is the stock Flutter template. It only includes
`package:flutter_lints/flutter.yaml` and enables no extra rules — every entry under
`linter.rules` is a commented-out example. The engineering standard §16.1 requires starting
from `flutter_lints` and then **deliberately adding** a recommended baseline of stricter rules
(`avoid_print`, `prefer_single_quotes`, `always_use_package_imports`,
`prefer_const_constructors`, and others). None of these are on today.

`flutter_lints: ^6.0.0` is already major-pinned in `pubspec.yaml`, which satisfies the pinning
part of §16.1. Only the rule additions are missing.

## Files to change

- `analysis_options.yaml` — add the §16.1 recommended baseline rules under `linter.rules`.

## Fix

Replace the commented-out example rules with the full recommended baseline from §16.1 of the
engineering standard:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_single_quotes: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_final_fields: true
    prefer_final_locals: true
    avoid_unnecessary_containers: true
    sized_box_for_whitespace: true
    use_key_in_widget_constructors: true
    prefer_is_empty: true
    avoid_empty_else: true
    unnecessary_brace_in_string_interps: true
    unnecessary_this: true
    no_duplicate_case_values: true
    avoid_redundant_argument_values: true
    sort_child_properties_last: true
    use_full_hex_values_for_flutter_colors: true
    always_use_package_imports: true
    cancel_subscriptions: true
    close_sinks: true
    use_decorated_box: true
    avoid_bool_literals_in_conditional_expressions: true
    noop_primitive_operations: true
    use_enums: true
```

The stock header comments about how to customize/suppress rules are kept.

## Note / expected side effect

Turning these on will make `flutter analyze` report **new lint issues** across existing code
(likely many: single-quote conversions, missing `const`, `print` usage, relative imports, etc.).

This plan only flips the rules on. It does **not** fix the resulting analyzer findings. Options
for how to handle the fallout (fix all now, fix incrementally, or leave as warnings) can be
decided after we see the `flutter analyze` count. Say if you want the fixes included instead —
that would be a larger, separate effort.

## Verification

- Run `flutter analyze` after the change to confirm the config parses and to see the new
  finding count.
