# Incoming-call notification now shows contact name

Implements [plans/20260703_120832_incoming-call-notification-name.md](../plans/20260703_120832_incoming-call-notification-name.md).

## Problem

The incoming-call heads-up notification showed the raw phone number even though the
full-screen in-call UI showed the contact name. The notification is built natively
(`ContactSphereInCallService`) with only the number; contact-name resolution lives in
Flutter (`InCallScreen._resolveName` → `ContactRepository`), which native can't reach.

## Change

Push the resolved name from Flutter to native and re-post the ongoing ring
notification with the caller's name.

- **`android/.../ContactSphereInCallService.kt`** — added a `currentNumber` field set
  in `startRinging` and cleared in `stopRinging`. `buildIncomingNotification` now takes
  an optional `name` and renders title = name (fallback number → "Unknown") with text
  "Incoming call" (previously title "Incoming call" / text = number). Added
  `updateCallerName(name)` (new `RingController` method) that re-posts the notification
  via `NotificationManager.notify(RING_NOTIFICATION_ID, …)`, gated on an active ring so
  a name arriving after answer/end doesn't resurrect it.
- **`android/.../CallRegistry.kt`** — added `updateCallerName(name)` to the
  `RingController` interface and a `setCallerDisplayName(name)` forwarder (mirrors
  `setIncomingRingtone`).
- **`android/.../MainActivity.kt`** — new method-channel case `setIncomingCallerName`
  → `CallRegistry.setCallerDisplayName`.
- **`lib/services/telecom_service.dart`** — added `setIncomingCallerName(String name)`
  (`_invokeVoid`, no-op off Android).
- **`lib/screens/in_call_screen.dart`** — `_resolveName` now calls
  `setIncomingCallerName` when a non-empty name resolves and the call is still ringing.

## Verification

`flutter analyze` on the two changed Dart files: no issues. Kotlin changes reuse the
already-imported `NotificationManager` and the existing `getSystemService` pattern.

## Notes

On a cold-start incoming call there is a brief window where the notification shows the
number before Flutter resolves and pushes the name — unavoidable without duplicating
the contact lookup/normalization in Kotlin, which was intentionally not done.
