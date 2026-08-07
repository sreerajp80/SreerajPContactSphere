# Recents card split-tap: left opens contact, right dials

**Status:** completed

## Issue

On the Recents (call history) screen, tapping anywhere on a call card runs
`_onTap`, which opens the contact page when the call is linked and otherwise
calls back. You want the tap zones split so the card behaves like a common
dialer recents list:

- Tapping the **left portion** of a card → open the contact page.
- Tapping the **right portion** of a card → start dialing (call back).

## Current behaviour (for reference)

File: [lib/screens/call_history_screen.dart](lib/screens/call_history_screen.dart)

- The card is a `ListTile` with a single `onTap: () => _onTap(call)` and a
  trailing `IconButton` (green call button) that runs `_callBack(call)`.
- `_onTap`: if `call.contactId != null` → open `ContactDetailScreen`; else
  `_callBack(call)`.

## Plan for the fix

Only one file changes: [lib/screens/call_history_screen.dart](lib/screens/call_history_screen.dart).

1. In `_callCard`, split the tap area into a **left zone** and a **right zone**
   instead of one whole-card `onTap`:
   - Keep the visual layout (avatar + title/subtitle on the left, the type icon
     and green call button on the right) unchanged.
   - Wrap the card body so that:
     - The **left zone** (avatar + name + subtitle area — roughly the leading +
       title/subtitle region) triggers **open contact**.
     - The **right zone** (the trailing icon/call area) triggers **dial**.
   - Implementation approach: replace the `ListTile`'s single `onTap` with a
     `Row` of two `InkWell`/`GestureDetector` regions inside the existing
     rounded `Container`, preserving the current padding, avatar, text styles,
     type icon, and colors so the card looks the same. The existing
     `onLongPress` (`_showActions`) stays available on the whole card.

2. Left-zone tap → **open contact page**:
   - If `call.contactId != null` → push `ContactDetailScreen` (same as today's
     linked path).
   - If the call is **not linked** (unknown number, no contact page exists) →
     open **Add to contact**: push
     `AddEditContactScreen(initialNumber: call.phoneNumber)` (same pattern the
     dialer's "Add to contacts" uses in
     [lib/screens/dialer_screen.dart:363](lib/screens/dialer_screen.dart#L363)).

3. Right-zone tap → **dial**: run `_callBack(call)` (same code path the green
   call button already uses, so SIM picking + post-call reconciliation still
   work via `CallLifecycleMixin`).

4. **Keep** the existing green trailing call `IconButton` (still dials) as a
   clear affordance. The whole right zone dials too.

## Testing

- `flutter analyze` on the changed file.
- Manual: on Recents, tap left half of a linked card → contact opens; tap right
  half → call starts. For an unknown number, tap left → **Add to contact**
  (number prefilled); tap right → call back.

## Decisions (confirmed)

- Unknown/unlinked left-tap → open **Add to contact** with the number prefilled.
- **Keep** the explicit green call button.
