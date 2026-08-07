# Dialer: copy/paste number + Favorites & Top-contacts sections

Implements
[plans/20260701_121153_dialer-copy-paste-and-top-contacts.md](../plans/20260701_121153_dialer-copy-paste-and-top-contacts.md).

## What changed

### `lib/repositories/contact_repository.dart`
- Added `getTopRelationshipMatches({int limit = 5})` → `List<PhoneMatch>`. Returns
  non-secret, non-favorite contacts with `relationship_score > 0`, ordered by
  `relationship_score DESC, first_name ASC`, each with its primary phone + label. Mirrors
  `getFavoriteMatches` (same correlated subqueries and `PhoneMatch` mapping); favorites are
  excluded so the dialer's two pre-dial sections don't repeat the same people, and the
  score>0 filter avoids showing an arbitrary alphabetical slice for a fresh address book.

### `lib/screens/dialer_screen.dart`
- Imported `package:flutter/services.dart` (`Clipboard`, `ClipboardData`).
- **Copy:** long-pressing the typed number copies it to the clipboard and shows a
  "Number copied" snackbar (`_copyNumber`; number `Text` wrapped in a `GestureDetector`).
- **Paste:** added a paste `IconButton` (`Icons.content_paste_outlined`) in the previously
  empty 40px leading slot of the number-display row (symmetric with the trailing
  backspace). It reads the clipboard, sanitizes via `_dialSafe` (keeps `0-9 + * # , ;`,
  strips everything else), and — if anything remains — sets the number, clears any linked
  contact, and refreshes suggestions; otherwise shows "Nothing to paste" (`_pasteNumber`).
- Added a `_showSnack` helper (hides the current snackbar before showing the next).
- **Top contacts section:** added `_topContacts` state; `_loadFavorites` now also loads
  `getTopRelationshipMatches()` (best-effort, same refresh triggers as favorites). The
  empty-input branch of `_strip` now renders two headed sections — "FAVORITES" and
  "TOP CONTACTS" — each shown only when non-empty, falling back to the existing
  "Star a contact to see it here" hint when both are empty. Top-contact rows reuse
  `_matchRow` with the favorite (circular-avatar) styling.

## Verification
- `flutter analyze lib/screens/dialer_screen.dart lib/repositories/contact_repository.dart`
  → **No issues found.**

## Notes
- No DB schema change; no new dependency (`Clipboard` ships with Flutter).
- "Top contacts based on relationship" was implemented as highest `relationship_score`
  (the interaction-driven signal), not the explicit family/friend `relationships` links.
