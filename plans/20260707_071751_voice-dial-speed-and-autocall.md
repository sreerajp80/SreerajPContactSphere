# Voice dialing: faster response + confirm-then-call

**Status:** completed

## The issue

Two complaints about voice dialing on the Dialer screen:

1. **It takes too long.** After you finish speaking, nothing happens for about 3 seconds.
2. **It does not call.** Even when it hears the right person, it only fills the number; you
   still have to tap the green button. With several same-name contacts it just lists them.

### Why (root cause)

- The dialer ignores every partial result and acts only on the *final* result
  (`_onVoiceWords` in [dialer_screen.dart:124](../lib/screens/dialer_screen.dart#L124):
  `if (!isFinal) return;`).
- The recognizer only marks a result "final" after **3 seconds of silence**
  (`pauseFor: Duration(seconds: 3)` in
  [speech_service.dart:88](../lib/services/speech_service.dart#L88)). So there is a ~3s dead
  wait before the app even searches.
- On a single match, `_onVoiceWords` calls `_selectSuggestion`, which only fills the number
  field. It was never wired to place the call. On multiple matches it lists them (correct —
  it can't know which one).

## The plan (agreed behavior)

- **Speed:** shorten the silence timeout to ~1.2s **and** show contact matches live while the
  user speaks (using partial results), so feedback feels near-instant.
- **Calling:** when the final phrase resolves to exactly **one** contact with a dialable
  number, fill it and show a short, cancellable "Calling <name>…" countdown, then place the
  call. Multiple matches keep today's pick-from-list behavior. A spoken bare number keeps
  today's fill-only behavior (no auto-call).

## Files to change

1. **`lib/services/speech_service.dart`**
   - Change `pauseFor` from `Duration(seconds: 3)` to `Duration(milliseconds: 1200)`.
   - Note: this service is shared with contacts voice search, which already uses partial
     results — the shorter pause helps there too and changes no logic.

2. **`lib/screens/dialer_screen.dart`**
   - Add `import 'dart:async';` (for `Timer`).
   - Add state fields: `int _voiceToken = 0;`, `String? _lastVoiceSearch;`,
     `Timer? _pendingCallTimer;`.
   - Rework `_onVoiceWords(words, isFinal)`:
     - Parse the phrase (unchanged parser).
     - **Number** → fill the field live (as today, but now also on partials); never auto-call.
     - **Name** → run the same contact search (exact/substring, then stem fallback) live on
       each partial, guarded by `_voiceToken` (drop stale responses) and `_lastVoiceSearch`
       (skip re-searching an unchanged phrase); show the matches in the strip.
     - **On the final result only:** if exactly one match with a non-empty number →
       `_confirmAndCall(match)`; otherwise leave the list shown.
   - Extract the name→`List<PhoneMatch>` search into a small helper (moved out of the current
     inline block).
   - Add `_confirmAndCall(PhoneMatch)`: calls `_selectSuggestion` to fill the field, then
     shows a `SnackBar` "Calling <name>…" with a **Cancel** action and a ~2.5s `Timer`; when
     the timer fires (not cancelled) it hides the snackbar and calls `_placeCall()`.
   - Cancel `_pendingCallTimer` inside `_clearVoice()` (so typing/pasting/picking aborts a
     pending call) and in a new `dispose()` override (which then calls `super.dispose()` so
     the `CallLifecycleMixin` observer is still removed).

## Notes / trade-offs

- 1.2s pause is more eager: a long mid-name pause could cut you off early. Acceptable per the
  chosen setting; easy to bump back up if it clips real speech.
- The 2.5s "Calling…" countdown is the safety net against a misheard single match — it places
  a real call, so Cancel is always shown.
- No new dependencies, no schema change, no test file changes required. Existing
  `voice_dial_parser_test.dart` still applies (parser is untouched).

## Verification

- `flutter analyze` clean on the two changed files.
- Manual: on the Dialer, tap the mic, say a name → matches appear quickly; one match →
  "Calling…" then dials unless cancelled; several matches → list to pick. Say digits → fills
  the field. Tapping a key / pasting during the countdown cancels the pending call.
