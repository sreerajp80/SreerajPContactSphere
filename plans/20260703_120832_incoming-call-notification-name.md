# Incoming-call notification shows number instead of contact name

**Status:** completed

## Issue

When a call comes in, the full-screen in-call UI correctly shows the contact's name
(e.g. "[name]"), but the heads-up **notification** posted by the foreground
service still shows only the raw phone number ("[phone]").

### Why

The incoming-call notification is built entirely on the native side in
[ContactSphereInCallService.buildIncomingNotification](android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt#L82-L108):
its content text is set to `number` and nothing else. Contact-name resolution,
however, lives **only in Flutter** — [InCallScreen._resolveName](lib/screens/in_call_screen.dart#L110-L151)
queries `ContactRepository.findByFullNumber` against the app's own SQLite database
(with the default-country ISO for normalization). The native layer has no access to
that database or that logic, so at ring time it can only know the number.

The notification is posted immediately (`startForeground` in `promoteToForeground`),
possibly before the Flutter engine is even running on a cold-start call, so the native
side genuinely cannot resolve the name synchronously. The name must be pushed **down**
from Flutter once it resolves, and the ongoing notification re-posted.

## Fix

Reuse the existing Flutter resolution. After `InCallScreen` resolves the caller name,
send it across the method channel; the native service re-posts the ongoing ring
notification (same notification id) with the caller name as the title.

Notification layout change: instead of title `"Incoming call"` / text `number`, use
title = caller (contact name if known, else number, else `"Unknown"`) and text =
`"Incoming call"` — the standard phone-app layout, with the caller shown prominently.
Before the name arrives (or when it can't be resolved) it falls back to the number,
so behaviour never regresses.

The native update is gated on the ring being active (the foreground notification only
exists while ringing), so a late-arriving name after the call is answered/ended no-ops.

## Files to change

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`**
   - Store the current incoming `number` when ringing starts.
   - Change `buildIncomingNotification` to take an optional `name` and render
     title = name/number/"Unknown", text = "Incoming call".
   - Add `updateCaller(name)` (from the new `RingController` method) that re-posts the
     notification via `NotificationManager.notify(RING_NOTIFICATION_ID, …)`, but only
     while a ring is active. Clear the stored number in `stopRinging`.

2. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt`**
   - Add `fun updateCallerName(name: String?)` to the `RingController` interface.
   - Add `fun setCallerDisplayName(name: String?)` that forwards to `ringController`
     (mirrors the existing `setIncomingRingtone` forwarding).

3. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - Add a method-channel case `"setIncomingCallerName"` that calls
     `CallRegistry.setCallerDisplayName(call.argument<String>("name"))`.

4. **`lib/services/telecom_service.dart`**
   - Add `Future<void> setIncomingCallerName(String name)` invoking the new method
     (no-op off Android, like the other `_invokeVoid` wrappers).

5. **`lib/screens/in_call_screen.dart`**
   - In `_resolveName`, once a non-empty contact name is resolved and the call is still
     ringing, call `_telecom.setIncomingCallerName(name)` so the native notification
     updates.

## Not doing

- Native-side SQLite/ContactsContract lookup — the app is its own contact store with
  its own normalization; duplicating that in Kotlin would be fragile. Pushing the
  already-resolved name down is simpler and reuses the tested path.
