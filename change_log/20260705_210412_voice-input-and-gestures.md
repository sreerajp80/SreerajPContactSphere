# Voice input (speech_to_text) + navigation gestures

Implements [plans/20260705_204411_voice-input-and-gestures.md](../plans/20260705_204411_voice-input-and-gestures.md).

## What changed

### Voice input (the unused `speech_to_text` package is now wired)

- **`lib/services/speech_service.dart` (new)** — singleton wrapper around the
  device speech recognizer. Asks the mic permission through the existing
  `PermissionService`, probes the recognizer once (`initialize` may only run
  once per process), and never throws into callers: mic denied, no recognizer,
  or the host test VM all come back as `false`. One listen session at a time;
  a per-session done-callback fires exactly once (final result, silence
  timeout, error, or explicit stop) so the UI can reset its mic state. Listens
  stop by themselves after a 3 s pause and are capped at 30 s.
- **`lib/widgets/voice_input_button.dart` (new)** — the shared mic button:
  muted outline icon when idle, accent-filled and gently pulsing while
  listening. Tap to listen, tap again (or stop talking) to finish. Problems
  surface as a snackbar ("Voice input is not available…"), never a crash.
  Fix along the way: the pulse `AnimationController` is created in
  `initState`, not as a lazy `late final` — a lazy field first touched in
  `dispose()` would create the controller during teardown, where the ticker's
  ancestor lookup is illegal (caught by the widget smoke test).
- **Voice search — `lib/screens/contact_list_screen.dart`** — the search bar's
  empty-state suffix is now the mic (the clear "X" still replaces it while a
  query is set). Partial results stream into the search field live, each
  running the existing DB-backed search (`_filterContacts`), so the list
  narrows while the user is still speaking.
- **Voice dialing — `lib/screens/dialer_screen.dart`** — the number display's
  right slot shows the mic while the field is empty (backspace takes over once
  digits exist). Only the final phrase is acted on:
  - digits (spoken as digits or as words) fill the number field and run the
    normal suggestion search;
  - a name runs the same slim `searchContactSummaries` the contacts list uses
    (name / transliteration aware). Exactly one match with a phone →
    `_selectSuggestion` fills the number, linked and ready to call in one tap;
    several matches (or none) render in the strip under a `Heard "…"` header
    (or a "No contact matches" note). Typing, pasting, or picking a match
    clears the voice state.
- **`lib/utils/voice_dial_parser.dart` (new)** — the digits-vs-name
  classifier: maps digit words (zero…nine, oh, plus, star, hash/pound), drops
  a leading command word ("call amma" → "amma"), keeps only dialable
  characters, and falls back to a name query when any word isn't dialable.
- **`test/voice_dial_parser_test.dart` (new)** — unit tests for the parser
  (digits, digit words, lead-ins, names, mixed phrases, blanks).
- **`android/app/src/main/AndroidManifest.xml`** — added the
  `android.speech.RecognitionService` intent to `<queries>`; without it the
  recognizer is invisible to the app on Android 11+ (`RECORD_AUDIO` was
  already declared).

### Navigation gestures

- **`lib/main.dart`** — `MaterialApp.builder` now wraps the navigator in a
  horizontal-drag detector: a right fling (≥ 300 px/s) calls `maybePop()` on
  the root navigator, giving every pushed screen swipe-right-to-go-back with
  no per-screen wiring. Inner widgets that claim horizontal drags (slidable
  rows, sliders, text fields) win the gesture arena, so nothing regresses.
  The in-call route is excluded (`_inCallRoute?.isCurrent`) — a stray swipe
  must never hide a live call.
- **`lib/screens/home_shell.dart`** — the tab body has its own detector
  (being inside the route, it wins over the root one while nothing is
  pushed): a left fling moves to the next tab, wrapping around
  (Contacts → Dialer → Recents → Contacts); a right fling shows
  "Swipe right again to exit" and a second fling within 2 s exits via
  `SystemNavigator.pop()`.

### Docs

- `docs/known-gaps.md` — new "Resolved (2026-07-05 voice-input + gestures
  build-out)" section; the old "Speech to text — not wired" bullet now points
  at it.
- `docs/dependencies.md` — the `speech_to_text` entry is marked wired.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 95 tests pass (including the new parser tests and the
  widget smoke test, which caught the dispose-time controller bug above).

## Limits

- Recognition quality/language comes from the device's recognizer (usually
  Google's); there is no always-on hotword and no commands beyond
  search/dial.
- Voice availability needs a recognizer on the device; in its absence the mic
  reports "not available" instead of failing.
