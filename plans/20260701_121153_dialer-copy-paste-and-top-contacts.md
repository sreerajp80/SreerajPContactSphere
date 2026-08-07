# Dialer: copy/paste number + Favorites & Top-contacts sections

**Status:** completed

## What the user asked for

Looking at the Dialer screen, the user wants three things:

1. **Copy & paste a number** to/from the dialpad — copy the number currently typed
   into the field, and paste a number from the clipboard into the field.
2. A **Favorites view in the dialer** (it exists today but only implicitly, as the
   empty-state list).
3. Alongside Favorites, a **Top contacts based on relationship** view — the people the
   user interacts with most, surfaced before any digits are typed.

## Current state (what's there today)

- [lib/screens/dialer_screen.dart](../lib/screens/dialer_screen.dart) is a standalone
  T9 dialpad. The number is held in `_number` (a plain `String`, not a `TextField`), so
  there is no OS text-selection/copy/paste affordance at all.
- The empty-input state (`_strip`) already shows **Favorites**
  (`_contacts.getFavoriteMatches()`), rendered as `_matchRow`s under a "FAVORITES" header.
  There is no second section.
- [lib/repositories/contact_repository.dart](../lib/repositories/contact_repository.dart)
  has `getFavoriteMatches()` returning `List<PhoneMatch>` (contact id, name, primary phone,
  label). Contacts carry a computed `relationship_score` column (maintained by
  `RelationshipScoringService`) but there is **no** query that returns the top contacts by
  that score.

## The issue

- No clipboard integration: users can't paste a number they copied from elsewhere (SMS,
  browser, notes) into the dialer, nor copy the number they've dialed.
- Only one pre-dial list (Favorites). The relationship_score signal the app already
  computes isn't surfaced in the dialer.

## Plan for the fix

### 1. Repository — new query for top contacts by relationship score

File: `lib/repositories/contact_repository.dart`

Add a method mirroring `getFavoriteMatches`:

```dart
/// Non-secret contacts with the highest relationship_score (the people the user
/// interacts with most), with their primary phone + label, for the dialer's
/// "Top contacts" list shown before any digits are typed. Only contacts with a
/// score above 0 are returned (so a brand-new address book shows nothing rather
/// than an arbitrary alphabetical slice), highest score first. Favorites are
/// excluded so the two dialer sections don't repeat the same people.
Future<List<PhoneMatch>> getTopRelationshipMatches({int limit = 5}) async { ... }
```

- `WHERE c.is_secret = 0 AND c.is_favorite = 0 AND c.relationship_score > 0`
- `ORDER BY c.relationship_score DESC, c.first_name ASC`
- `LIMIT ?`
- Same primary-phone / label correlated subqueries and the same `PhoneMatch` mapping as
  `getFavoriteMatches`. Contacts with no phone are still returned (empty number), matching
  the favorites behavior, so the row shows with its call action disabled.

### 2. Dialer screen — clipboard copy & paste

File: `lib/screens/dialer_screen.dart`

- `import 'package:flutter/services.dart';` for `Clipboard` / `ClipboardData`.
- **Copy:** long-press the number display (when `_number` is non-empty) copies `_number`
  to the clipboard and shows a `SnackBar` ("Number copied"). Implemented by wrapping the
  centered number `Text` in a `GestureDetector`/`InkWell` with `onLongPress`.
- **Paste:** add a paste `IconButton` (`Icons.content_paste`) in the currently-empty
  40px leading slot of `_numberDisplay`'s `Row` (symmetric with the trailing backspace).
  On tap it reads `Clipboard.getData('text/plain')`, sanitizes the text to dial-safe
  characters, and — if anything remains — sets it as the number (linked contact cleared,
  suggestions refreshed). If the clipboard is empty / has no dial-able characters, show a
  SnackBar ("Nothing to paste"). The paste button is shown in both empty and typed states
  (in the typed state it still occupies the leading slot, keeping the call button centered).
- Sanitizer helper `_dialSafe(String)`: keep `0-9 + * # , ;` and strip everything else
  (spaces, dashes, parentheses, letters, newlines). Keeps `+` for intl and `, ;` for
  DTMF pause/wait, consistent with a dialer.

### 3. Dialer screen — Favorites + Top contacts sections

File: `lib/screens/dialer_screen.dart`

- Add state `List<PhoneMatch> _topContacts = const [];`.
- In `_loadFavorites` (rename conceptually to also load top contacts — keep the method but
  load both, or add a sibling load), call `getTopRelationshipMatches()` and store into
  `_topContacts`. Both are best-effort (errors leave the list empty). This runs on
  `initState`, after returning from a contact detail, and after adding a contact — same
  triggers that already refresh favorites.
- In `_strip`'s empty-input branch, render **two** sections in one `ListView`:
  - "FAVORITES" header + favorite rows (only if `_favorites` non-empty).
  - "TOP CONTACTS" header + top-contact rows (only if `_topContacts` non-empty).
  - If **both** are empty, keep the existing centered "Star a contact to see it here"
    empty message.
- Reuse the existing `_matchRow` widget for both lists. Top-contact rows use the same
  styling as favorites (`favorite: true` → circular avatar) so the section reads as a
  peer of Favorites; the section is distinguished by its header, not the row style.

## Files to change

1. `lib/repositories/contact_repository.dart` — add `getTopRelationshipMatches`.
2. `lib/screens/dialer_screen.dart` — clipboard copy/paste; load + render the Top-contacts
   section beside Favorites.

## Out of scope / notes

- No DB schema change (uses the existing `relationship_score`, `is_favorite`, `is_secret`).
- "Top contacts based on relationship" is interpreted as **highest relationship_score**
  (the interaction-driven signal the app already computes), not the explicit
  family/friend `relationships` links. If you meant the latter (e.g. only people tagged
  Family/Friend), say so and I'll adjust the query.
- No new dependency: `flutter/services` (Clipboard) ships with Flutter.

## Verification

- `flutter analyze` clean.
- Manual: type a number → long-press it → "Number copied"; clear field → tap paste with a
  number on the clipboard → it fills in; empty dialer shows Favorites and Top contacts
  sections (each hidden when empty; combined empty shows the star hint).
