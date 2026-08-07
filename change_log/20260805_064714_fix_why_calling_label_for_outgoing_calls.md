# Fix "Why they are calling" label showing on outgoing calls

Implements plan: `plans/20260805_064714_fix_why_calling_label_for_outgoing_calls.md`

## What changed

`lib/screens/in_call_screen.dart` — the Smart Context Card on the
in-call screen used to always show the header "WHY THEY ARE CALLING",
even when you were the one placing the call. That heading only makes
sense for incoming calls.

The card now picks the header based on `_state.direction`
(`CallDirection`, already tracked on the call state):
- Outgoing calls now show "ABOUT THIS CONTACT".
- Incoming (and unknown-direction, as a fallback) calls keep
  "WHY THEY ARE CALLING", same as before.

Nothing else on the card changed — the relationship, last-spoke time,
reminders, and upcoming birthday badges are unaffected.

## Testing

- `flutter analyze lib/screens/in_call_screen.dart` — no issues.
- No existing widget test harness covers this native-call-driven
  screen, so this was verified by reading through both direction
  branches.
