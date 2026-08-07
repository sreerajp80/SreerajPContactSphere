# Ongoing-call notification must not heads-up over the in-call screen

**Status:** completed

## Issue

When a call becomes active, the **ongoing-call notification** ("സജീവമായ കോൾ" / active call,
with Hang up / Mute / Speaker) briefly pops up as a **heads-up banner over the in-call
screen** (see the screenshot the user shared). Our own full-screen in-call UI is already
showing, so this heads-up is redundant and looks wrong. It should quietly sit in the
notification shade instead.

### Root cause

Both the **incoming** and the **ongoing** call notifications are posted on the single
`incoming_calls` channel, which is created with `NotificationManager.IMPORTANCE_HIGH`
([ContactSphereInCallService.kt:299-314](../android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt#L299-L314)).
`IMPORTANCE_HIGH` means the notification "appears as a heads-up." That is correct and wanted
for the **incoming** notification (it needs to take over the screen / show over the lock
screen, and also uses `setFullScreenIntent`). But the **ongoing** notification, posted on the
same HIGH channel (via `startForeground` for outgoing calls, or the `notify` update when an
incoming call is answered), inherits the heads-up behavior and peeks over our in-call screen.

On Android O+ the heads-up (peek) behavior is governed by the **channel importance**, not by
the per-notification priority — so the only reliable way to stop the ongoing notification from
peeking, while keeping the incoming one prominent, is to post it on a **separate,
lower-importance channel**.

## Fix

Split the single call channel into two:

- **`incoming_calls`** — keep `IMPORTANCE_HIGH`. Used only for the incoming/ringing
  notification (heads-up + full-screen intent, unchanged behavior).
- **`ongoing_call`** (new) — `IMPORTANCE_LOW`. Used for the ongoing/active call notification.
  `IMPORTANCE_LOW` shows the notification silently in the shade with **no heads-up peek**.
  Silent (no sound / no vibration), same as today. The `CallStyle.forOngoingCall` layout,
  chronometer, and Hang up / Mute / Speaker action buttons all still render on a LOW channel.

`buildCallStyleNotification` and `buildLegacyNotification` already receive the `ongoing` flag,
so they pick the channel id from that flag. `createChannel()` is generalised to create both
channels (idempotent, as today).

Behaviour after the fix:
- Outgoing call → ongoing notification appears **silently in the shade**, no banner over the
  in-call screen.
- Incoming call → unchanged: still heads-up / full-screen over the lock screen with
  Answer / Decline.
- Answer an incoming call → the notification is re-posted as the ongoing shape on the LOW
  channel (same notification id 42), so it stops peeking once the call is active.

### Files to change

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`**
   - Add a second channel constant, e.g. `ONGOING_CHANNEL_ID = "ongoing_call"`, keeping the
     existing `CHANNEL_ID = "incoming_calls"` for incoming.
   - `createChannel()` → create/ensure **both** channels: `incoming_calls` at
     `IMPORTANCE_HIGH` (as now) and `ongoing_call` at `IMPORTANCE_LOW` (silent, no vibration).
   - `buildCallStyleNotification(...)` and `buildLegacyNotification(...)`: select the channel
     id by the `ongoing` flag (`if (ongoing) ONGOING_CHANNEL_ID else CHANNEL_ID`) when
     constructing the `Notification.Builder`.

### Not changing
- No Flutter/Dart changes.
- No manifest / permission changes.
- Incoming notification behavior (heads-up + full-screen) is intentionally left as-is.

## Verification
- `flutter build apk` succeeds.
- Place an outgoing call → the active-call notification appears in the shade **without** a
  heads-up banner over the in-call screen; tapping it still returns to the call; Hang up /
  Mute / Speaker still work and the duration timer still runs.
- Receive an incoming call → still shows full-screen / over the lock screen with
  Answer / Decline (unchanged).
- Answer the incoming call → banner stops peeking, ongoing notification sits quietly in the
  shade.
