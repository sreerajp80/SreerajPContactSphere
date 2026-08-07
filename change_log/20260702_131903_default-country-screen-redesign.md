# Default country screen redesign

Implements [plans/20260702_131903_default-country-screen-redesign.md](../plans/20260702_131903_default-country-screen-redesign.md).

## What changed

Rewrote the presentation of
[lib/screens/default_country_screen.dart](../lib/screens/default_country_screen.dart)
to make the current selection unmistakable and give the ~250-country list visual
structure, using the app's own design tokens (`AppColors`, `colorScheme.primary`).
No data-model, `PhoneNormalizer`, `AppSettings`, or routing changes; tap-to-select
+ pop behavior is unchanged.

- **Pinned "Selected" card** between the search field and the list, always
  visible, showing the current country's ISO badge, name, and `+code` in an
  accent-tinted, accent-bordered container.
- **ISO-code avatar** (`_isoBadge`) — a rounded-square badge with the 2-letter
  ISO code in the accent color, on the header and every row. Chosen over flag
  emoji, which many Android builds render as bare letters.
- **Removed the per-row radio dots.** Unselected rows are plain card-surface
  rows with a subtle hairline border; the selected row is accent-tinted +
  accent-bordered with a trailing `Icons.check_circle` and bolder text. This
  removes the "wall of radio dots" that made the old list hard to scan.
- **Auto-scroll to the selected row** on first display via a `ScrollController`
  + post-frame `jumpTo`, so the highlighted country isn't hidden down the list
  (skipped while a search filter is active).

Kept the themed search field, the info line, and the empty-state message.

## Verification

- `flutter analyze lib/screens/default_country_screen.dart` — No issues found.
