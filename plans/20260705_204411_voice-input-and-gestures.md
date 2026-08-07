# Voice input (speech_to_text) + navigation gestures

**Status:** completed

## The issue

1. `speech_to_text` is declared in `pubspec.yaml` but no Dart file uses it
   (listed in `docs/known-gaps.md` under "not integrated"). There is no voice
   search and no voice dialing.
2. The app has no navigation gestures. The user wants:
   - Swipe **right** on any pushed screen → go back to the parent screen.
   - Swipe **right** on the main screen twice (within a short window) → exit the app.
   - Swipe **left** on the main screen → move to the next tab, circular
     (Contacts → Dialer → Recents → Contacts …).

## What already exists (no work needed)

- `RECORD_AUDIO` is already in `AndroidManifest.xml`.
- `PermissionService.ensureMicrophone()` already exists.
- The dialer already has match-as-you-type contact search (`_suggestions`),
  which voice dialing can reuse.

## Files to change

| File | Change |
|---|---|
| `lib/services/speech_service.dart` | **New.** Small wrapper around `speech_to_text`: one-time init, `listen()` with partial-result callback, stop/cancel, error handling. Asks mic permission via `PermissionService` first. Never throws to callers; reports "not available" cleanly. |
| `lib/widgets/voice_input_button.dart` | **New.** Reusable mic button styled from `AppColors` (accent tint, pulsing while listening, "Listening…" state). Used by both screens so voice input looks the same everywhere. |
| `lib/screens/contact_list_screen.dart` | **Voice search.** Mic icon in the search bar (shown when the query is empty; the clear "X" still shows when there is text). Tap → listen; partial results fill the search field live and run the existing DB-backed search. |
| `lib/screens/dialer_screen.dart` | **Voice dialing.** Mic button next to the number display. Spoken **digits** ("0 4 7 1 2…") → typed into the number field. Spoken **name** → run the existing suggestion search; a single confident match fills the number and shows the name chip so one tap on Call dials; several matches → show them as the normal suggestion list. |
| `lib/screens/home_shell.dart` | **Main-screen gestures.** Horizontal-drag detector on the tab body: swipe left → `_onSelect((_index + 1) % 3)` (circular); swipe right → first swipe shows a "Swipe right again to exit" snackbar, a second swipe within ~2 s calls `SystemNavigator.pop()`. |
| `lib/main.dart` | **Swipe-back on pushed screens.** `MaterialApp.builder` wraps the navigator in a horizontal-drag detector: a right swipe calls `maybePop()` when the navigator can pop. The **in-call screen is excluded** (a stray swipe must not hide an active call). |
| `android/app/src/main/AndroidManifest.xml` | Add the `android.speech.RecognitionService` intent to the existing `<queries>` block — required on Android 11+ for `speech_to_text` to find the device recognizer. |
| `docs/known-gaps.md`, `docs/dependencies.md` | Move the speech entry to "resolved/wired"; note the new gestures. |
| `test/` | Small unit test for the voice-dialing "digits vs name" text classifier. |

## How the gestures avoid conflicts

- Inner horizontal gestures always win in Flutter's gesture arena. So the
  swipe rows in Add/Edit (`flutter_slidable`), sliders, and any horizontal
  scrolling keep working; the swipe-back only fires where nothing else claims
  the drag.
- Swipes need a real horizontal fling (velocity + distance threshold), so
  normal vertical scrolling is not affected.
- On the main screen only `home_shell.dart`'s detector runs (nothing to pop),
  so tab-cycling and double-swipe-exit never fight with swipe-back.

## Voice behavior details

- Mic tap: ask mic permission (existing flow). If denied, or the device has no
  speech recognizer, show a short snackbar — never crash.
- Results are on-device/Google recognizer via `speech_to_text`; we only read
  the recognized words, nothing is stored.
- UI follows the app's own design tokens (`AppColors`), not a Google clone.

## Out of scope

- No always-on hotword ("Hey app…") listening.
- No voice commands beyond search/dial (no "delete contact", etc.).
- No schema/DB change.
