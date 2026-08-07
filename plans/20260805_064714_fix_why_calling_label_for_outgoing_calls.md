# Fix "Why they are calling" label showing on outgoing calls

**Status:** completed

## Issue

On the in-call screen, the Smart Context Card always shows the header
"WHY THEY ARE CALLING", no matter if the call is incoming (someone is
calling you) or outgoing (you are calling them). That heading only
makes sense for incoming calls. For outgoing calls, it is wrong — you
placed the call, so nothing is calling "them" at you.

The call direction is already known: `CallState.direction` is a
`CallDirection` enum (`incoming`, `outgoing`, `unknown`) set from the
native call state. The in-call screen just never reads it when
building this card's header.

The card's content below the header (relationship, last spoke time,
reminders, upcoming birthday) is correct either way and does not need
to change — only the header wording is wrong.

## Files to change

- `lib/screens/in_call_screen.dart` — `_callerContextCard` method
  (around line 661-696), where the header text and icon/label
  "WHY THEY ARE CALLING" is built.

## Fix plan

1. In `_callerContextCard`, read `_state.direction` (already available
   on the screen's state).
2. Pick the header text based on direction:
   - `CallDirection.outgoing` → `"ABOUT THIS CONTACT"` (context about
     the person you are calling, not "why they are calling" since you
     initiated it).
   - `CallDirection.incoming` or `CallDirection.unknown` (fallback,
     keeps today's behavior) → keep `"WHY THEY ARE CALLING"`.
3. No other logic changes — the card's badges, headline text, and
   `hasContext` check all stay the same.
4. Update the doc comment above `_callerContextCard` (currently says
   `/// Glassmorphic Smart Context Card answering "Why is this person
   calling?"`) to mention it also covers outgoing calls.

## Testing

- `flutter analyze` on the changed file.
- Manually reason through both branches (incoming vs outgoing) since
  there is no existing widget test harness for `in_call_screen.dart`
  in this repo (best-effort/native-call-driven screen).
