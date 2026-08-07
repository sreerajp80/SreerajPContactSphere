# Show contact name in the call notification for both incoming and outgoing calls

Implements [plans/20260703_181949_notification-contact-name-both-directions.md](../plans/20260703_181949_notification-contact-name-both-directions.md).

## What changed

1. **`lib/screens/in_call_screen.dart`** — `_resolveName()` now pushes the resolved
   contact name to native on every resolution, not just while the call is ringing. This
   covers outgoing calls (dialing/connecting/active) and incoming calls answered before
   resolution completed. When a (new) number resolves to no contact, an empty string is
   pushed so native clears any stale name from a previous number (add call / swap).

2. **`android/.../ContactSphereInCallService.kt`** — `updateCallerName()` now treats a
   blank name as "clear": it resets `currentName` and re-posts the notification showing
   the number, instead of ignoring the push. Non-blank behavior unchanged; still a no-op
   after the call ends.

3. **Rename `setIncomingCallerName` → `setCallerName`** (behavior-neutral): the channel
   method now serves both call directions.
   - `lib/services/telecom_service.dart`: method + channel string renamed, doc updated.
   - `android/.../MainActivity.kt`: channel handler key updated.
   - `android/.../CallRegistry.kt`: stale doc comment on `setCallerDisplayName` fixed.

## Verification

- `flutter analyze lib/screens/in_call_screen.dart lib/services/telecom_service.dart`
  → no issues.
- `gradlew compileDevDebugKotlin` → BUILD SUCCESSFUL (only pre-existing deprecation
  warnings).
- No remaining references to `setIncomingCallerName` anywhere in `lib/`, `android/`,
  or `test/`.
