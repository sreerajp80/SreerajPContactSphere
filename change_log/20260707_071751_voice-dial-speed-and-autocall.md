# Change log: voice dialing speed + confirm-then-call

Implements plan
[plans/20260707_071751_voice-dial-speed-and-autocall.md](../plans/20260707_071751_voice-dial-speed-and-autocall.md).

## Problem

Voice dialing felt slow (a ~3 second dead wait after you stopped speaking) and never
actually placed a call — it only filled the number field, so you still had to tap the
green button.

## Changes

### `lib/services/speech_service.dart`
- Shortened the recognizer's silence timeout from `pauseFor: Duration(seconds: 3)` to
  `Duration(milliseconds: 1200)`, so the final result (and thus the search) fires soon
  after the user stops talking. Shared with contacts voice search, which benefits too.

### `lib/screens/dialer_screen.dart`
- Added `import 'dart:async';` for `Timer`.
- New state: `_voiceToken` and `_lastVoiceSearch` (guard live searches against stale /
  duplicate responses) and `_pendingCallTimer` (the auto-call countdown).
- Added a `dispose()` override that cancels `_pendingCallTimer`, then calls
  `super.dispose()` so `CallLifecycleMixin` still removes its observer.
- `_clearVoice()` now also clears `_lastVoiceSearch` and cancels any pending call timer,
  so typing / pasting / picking a contact aborts a scheduled auto-call.
- Reworked `_onVoiceWords(words, isFinal)`:
  - Acts on **partial** results now (was final-only), so matches appear live while
    speaking.
  - Spoken **number** → fills the field live; never auto-dials.
  - Spoken **name** → live search (deduped by `_lastVoiceSearch`, stale-guarded by
    `_voiceToken`) shown in the strip.
  - On the **final** result, exactly one match with a dialable number →
    `_confirmAndCall`.
- Extracted the name→`List<PhoneMatch>` lookup into a new `_voiceSearch(query)` helper
  (exact/substring, then Malayalam stem fallback; empty list on error).
- Added `_confirmAndCall(match)`: fills the field via `_selectSuggestion`, then shows a
  `SnackBar` "Calling <name>…" with a **Cancel** action and a 2.5s `Timer`; on elapse
  (uncancelled, still mounted) it hides the snackbar and calls `_placeCall()`.

## Behavior after change

- Matches show up ~1.2s after you stop speaking (was ~3s, and only then).
- One clear match → "Calling <name>…" with a 2.5s Cancel window, then it dials itself.
- Several matches → listed to pick (unchanged). A spoken number → fills the field
  (unchanged, no auto-call).

## Verification

- `flutter analyze lib/screens/dialer_screen.dart lib/services/speech_service.dart` →
  "No issues found!".
- Parser untouched, so `test/voice_dial_parser_test.dart` still applies.
