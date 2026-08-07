# Change log: let voice capture finish, then act instantly

Implements plan
[plans/20260707_140256_voice-dial-pause-too-short.md](../plans/20260707_140256_voice-dial-pause-too-short.md).

## Problem

After the previous change, the mic closed too early (1.2s silence timeout) and clipped the
spoken name. Also, once a single match was found there was a deliberate 2.5s "Calling…"
countdown before dialing. Desired: let capture take the time it needs, but do everything after
capture with no delay.

## Changes

### `lib/services/speech_service.dart`
- Raised `pauseFor` from `Duration(milliseconds: 1200)` to `Duration(seconds: 2)`, so a normal
  mid-phrase pause no longer ends listening before the name is finished.

### `lib/screens/dialer_screen.dart`
- Removed `import 'dart:async';` (no longer needed).
- Removed the `_pendingCallTimer` field, the `dispose()` override that cancelled it, and the
  timer-cancel lines in `_clearVoice()` (kept the `_lastVoiceSearch = null` reset).
- Rewrote `_confirmAndCall(match)`: it now fills the field via `_selectSuggestion`, shows a
  brief non-blocking "Calling <name>…" snackbar, and calls `_placeCall()` immediately — no
  countdown, no cancel window.
- Live partial-result search and the `_voiceToken` / `_lastVoiceSearch` guards are unchanged.

## Behavior after change

- The mic keeps listening through a normal pause and captures the full name (2s silence
  window instead of 1.2s).
- A single confident match dials immediately after capture — no 2.5s wait.
- Several matches still list to pick from; a spoken number still just fills the field.

## Trade-off

A single match now dials with no cancel window, so a misheard lone match calls at once. This is
the requested behavior; auto-call only fires on exactly one match, and the 2s capture window
reduces mishears.

## Verification

- `flutter analyze lib/screens/dialer_screen.dart lib/services/speech_service.dart` →
  "No issues found!".
