# Voice dialing: let capture finish, then act instantly

**Status:** completed

## The issue

Two things to correct in voice dialing:

1. The mic closes too early (1.2s silence timeout) and clips the name — capture should take
   the time it needs.
2. After the phrase is captured there is a deliberate 2.5s "Calling…" countdown before the
   call goes out — the user wants no delay after capture; act immediately.

## Why

- `pauseFor: Duration(milliseconds: 1200)` in
  [speech_service.dart:90](../lib/services/speech_service.dart#L90) ends listening after only
  1.2s of silence, so a normal pause mid-phrase cuts the user off.
- `_confirmAndCall` in [dialer_screen.dart](../lib/screens/dialer_screen.dart) fills the field
  and then waits on a 2.5s cancellable `Timer` before calling — that is the post-capture delay
  the user now wants gone.

## The fix

- **Capture: take the necessary time.** Raise `pauseFor` to 2 seconds so a normal pause does
  not close the mic early. (Still well under the old 3s; and matches show live while speaking,
  so this only affects when capture *finishes*.)
- **After capture: no delay.** On a single confident match, fill the field and place the call
  **immediately** — drop the 2.5s countdown entirely. A brief "Calling <name>…" snackbar still
  shows as feedback, but it no longer gates the call.

This reverses the earlier "fill + confirm countdown" choice: a single match now dials at once.

## Files to change

1. **`lib/services/speech_service.dart`**
   - `pauseFor` from `Duration(milliseconds: 1200)` to `Duration(seconds: 2)`.

2. **`lib/screens/dialer_screen.dart`**
   - `_confirmAndCall`: replace the `Timer` + cancellable snackbar with an immediate
     `_selectSuggestion(match)` + info snackbar + `_placeCall()`.
   - Remove the now-unused `_pendingCallTimer` field, the `dispose()` override that cancelled
     it, and the timer-cancel lines in `_clearVoice()` (keep the `_lastVoiceSearch = null`
     reset there).
   - Remove `import 'dart:async';` if nothing else uses it.
   - Keep `_voiceToken` / `_lastVoiceSearch` and the live partial-result search unchanged.

## Trade-off

A single match now dials with no cancel window, so a misheard lone match will call at once.
This is the requested behavior; the 2s capture window and the fact that auto-call only fires on
exactly one match are the safeguards. Easy to reinstate a short confirm later if wanted.

## Verification

- `flutter analyze lib/screens/dialer_screen.dart lib/services/speech_service.dart` clean.
- Manual: tap mic, pause, say a name — it keeps listening and captures the full name; a single
  match dials immediately (no countdown); several matches still list to pick.
