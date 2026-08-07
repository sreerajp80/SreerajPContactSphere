# Default country screen redesign

**Status:** completed

## The issue

[lib/screens/default_country_screen.dart](../lib/screens/default_country_screen.dart)
renders all ~250 countries as one flat `ListView` of near-identical rows. Each row
is a radio dot + name + dial code. Problems the user reported:

- It reads as an undifferentiated wall of country codes ("quite ugly").
- The current selection lives *inside* that list as just one more radio dot, so
  it's hard to see what is actually selected — you'd have to scroll and hunt for
  the one filled dot.

## Goal

Make the current selection unmistakable and give the list visual structure that
matches the app's own design system (accent-driven, `AppColors` tokens, rounded
`Card` surfaces — same language as `sim_settings_screen.dart`). Not a Google/
Material clone; use the app's neutral, themed treatment.

## Plan for the fix

Rewrite the presentation in `default_country_screen.dart` (no data/model or
`PhoneNormalizer` changes; behavior — tap to select + pop — stays identical).

1. **A pinned "Current selection" header card, above the scroll.**
   Sits between the search field and the list, always visible (not scrolled
   away). An accent-tinted `Card` showing the selected country's ISO badge, name,
   and `+code`, with a small "Selected" label. This is the single clearest answer
   to "which one is selected".

2. **ISO-code avatar instead of a radio dot.**
   Each row (and the header) gets a leading rounded-square badge showing the
   2-letter ISO code (e.g. `IN`) in the accent color. This is device-independent
   (unlike flag emoji, which many Android builds render as bare letters) and
   gives the list scannable visual rhythm.

3. **Stronger selected-row treatment in the list.**
   The selected row gets an accent-tinted background fill, an accent border, and
   a trailing filled check (`Icons.check_circle`) in the accent color. Unselected
   rows have no radio dot at all — removing ~250 competing radio circles is what
   kills the "wall of dots" ugliness. Row = ISO badge + bold name + muted `+code`.

4. **Keep** the existing search field, the info line, the empty-state message,
   and all `AppColors`/`colorScheme.primary` theming. Auto-scroll the list so the
   selected row is in view on open (via a `ScrollController` + post-frame jump),
   so the highlighted row isn't hidden far down the list.

## Files to change

- `lib/screens/default_country_screen.dart` — rewrite the widget tree
  (header card, ISO-badge rows, selected-row highlight, initial scroll-to-
  selected). No signature/route changes; still a `StatefulWidget` reached from
  the Settings hub.

## Out of scope

- No changes to `PhoneNormalizer`, `AppSettings`, `country_names.dart`, or the
  Settings hub entry. No new dependencies (no flag-emoji package).

## Verification

- `flutter analyze` on the changed file is clean.
- Manual: open Settings → Default country; the current country shows in the
  pinned header and is highlighted + scrolled into view in the list; searching
  filters; tapping a country updates the selection and pops.
