# Plan: Missed-call "Call back" opens Google Dialer instead of ContactSphere

**Status:** completed

**Decision:** When default dialer, "Call back" places the call immediately (confirmed by user).

## Issue

Tapping **Call back** on a missed-call notification opens the Google Dialer, not
ContactSphere.

Two root causes:

1. **Missing `ACTION_CALL` intent-filter.** The "Call back" button on a missed-call
   notification fires an `ACTION_CALL` intent with a `tel:` URI (Android Telecom's
   `MissedCallNotifier`). Our `MainActivity` registers only `ACTION_DIAL`,
   `ACTION_VIEW` (`tel:`) and `ACTION_CALL_BUTTON`
   (`AndroidManifest.xml`, lines ~97-113). It does **not** register `ACTION_CALL`.
   Google Dialer does, so Android routes the callback to it.

2. **No handling of an incoming `tel:` number.** `MainActivity.onCreate` /
   `onNewIntent` only handle vCard intents (`handleVCardIntent`). Neither native nor
   Dart code reads a `tel:` number from the launch intent. So even the `DIAL` /
   `VIEW(tel:)` intents the app already advertises are dropped on the floor — the app
   opens on the home screen and ignores the number.

Both must be fixed: the filter so the intent reaches us, and the number handling so we
act on it.

## Files to change

### Native (Android / Kotlin)
1. **`android/app/src/main/AndroidManifest.xml`**
   - Add `<action android:name="android.intent.action.CALL"/>` to the existing
     `tel:`-scheme dialer intent-filter (alongside `DIAL`/`VIEW`), so the callback
     intent resolves to ContactSphere. Keep `category.DEFAULT`; `CALL` does not use
     `BROWSABLE`.

2. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - Add a `handleDialIntent(intent)` called from `onCreate` and `onNewIntent`
     (next to the existing `handleVCardIntent`). It matches
     `ACTION_CALL` / `ACTION_DIAL` / `ACTION_VIEW` with a `tel:` URI, decodes the
     number from the URI (`Uri.getSchemeSpecificPart()`, URL-decoded), and parks it
     in a `pendingDial: String?` field.
   - Expose it to Dart the same way vCards are handled: a `getPendingDial` method on a
     method channel that returns and clears `pendingDial`, plus a warm-delivery nudge
     (`dialReceived`) invoked on the channel so a running app reacts immediately.
     Reuse the existing `contact_sphere/telecom` channel (add the `getPendingDial`
     case) rather than adding a new channel.

### Flutter (Dart)
3. **`lib/services/telecom_service.dart`**
   - Add `Future<String?> getPendingDial()` (invokes `getPendingDial`, returns the
     parked number or null; no-op → null off Android).

4. **`lib/main.dart`**
   - On startup (in `_bootstrap`, cold start) and on the `dialReceived` warm nudge,
     call `getPendingDial()`; if a number comes back, route it:
     - if we are the default dialer → place the call via the existing
       `CallService` / `TelecomService.placeCall` path (so it flows through our own
       in-call UI), which is the natural "call back" behaviour;
     - otherwise → open `DialerScreen` pre-filled with the number.
   - Register a handler for the `dialReceived` method on the telecom channel (mirror
     the existing `vcardReceived` wiring).

5. **`lib/screens/dialer_screen.dart`** *(only if needed)*
   - `DialerScreen` currently takes no initial number. Add an optional
     `initialNumber` parameter so `main.dart` can open it pre-filled for the
     not-default-dialer path. (If we always place the call directly when default
     dialer, this is only used in the fallback.)

### Docs
6. **`docs/architecture.md`** / **`docs/known-gaps.md`** — note that incoming
   `tel:` dial/call intents (dialer links, missed-call callback) are now handled, and
   how (native parks the number, Dart collects it like vCards).

## Fix approach (summary)

`missed-call notification → ACTION_CALL(tel:NNN)` now resolves to ContactSphere →
`MainActivity` parks the number → Dart collects it → default dialer places the call
through our in-call UI (or opens the dialer pre-filled if we're not the default).

## Open decision for the user
- **When we are the default dialer, should "Call back" place the call immediately, or
  open the dialer pre-filled so the user taps the call button?** Plan assumes *place
  immediately* (matches how every stock dialer's callback behaves). Easy to switch to
  pre-fill if preferred.

## Testing
- `flutter analyze`, `flutter test` (existing suites unchanged; TelecomService still
  no-ops off Android).
- Manual on device (moto g54):
  - Set ContactSphere as default phone app. Get a missed call. Tap **Call back** →
    ContactSphere places the call through its in-call UI (not Google Dialer).
  - Tap a `tel:` link / a contact's number in another app → ContactSphere handles it.
  - Not-default-dialer case → dialer opens pre-filled.

## Risks / rollback
- `ACTION_CALL` handling requires either default-dialer role or `CALL_PHONE` (already
  held), so no new permission. Rollback = revert the manifest filter and the
  `handleDialIntent` wiring; the Dart additions are inert without the native nudge.
