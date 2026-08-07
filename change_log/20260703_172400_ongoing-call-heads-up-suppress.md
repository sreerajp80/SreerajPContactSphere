# Ongoing-call notification no longer heads-ups over the in-call screen

Implements plan [plans/20260703_171823_ongoing-call-heads-up-suppress.md](../plans/20260703_171823_ongoing-call-heads-up-suppress.md).

## Problem

When a call became active, the ongoing-call notification (active call, with Hang up / Mute /
Speaker) briefly popped up as a heads-up banner over the app's own full-screen in-call
screen. It should sit silently in the notification shade instead.

## Cause

Both the incoming and the ongoing call notifications were posted on the single
`incoming_calls` channel, created at `IMPORTANCE_HIGH`. On Android O+ heads-up (peek) is
governed by channel importance, so the ongoing notification inherited the incoming ring's
heads-up behavior.

## Change

Only `android/app/src/main/kotlin/in/sreerajp/contact_sphere/ContactSphereInCallService.kt`:

- Added a second channel constant `ONGOING_CHANNEL_ID = "ongoing_call"` alongside the
  existing `CHANNEL_ID = "incoming_calls"`.
- `createChannel()` now creates/ensures **both** channels (idempotent):
  - `incoming_calls` — `IMPORTANCE_HIGH` (heads-up + full-screen for the ring, unchanged).
  - `ongoing_call` — `IMPORTANCE_LOW` (silent, no heads-up peek), both silent (no sound /
    vibration) as before.
- `buildCallStyleNotification` (API 31+) and `buildLegacyNotification` (pre-31) now pick the
  channel id from the `ongoing` flag. The legacy fallback also uses `PRIORITY_DEFAULT` for
  the ongoing shape (vs `PRIORITY_HIGH` for incoming) on pre-O devices.

No Dart, manifest, or permission changes. Incoming ring behavior (heads-up + full-screen) is
intentionally unchanged.

## Verification

- `flutter build apk --debug --flavor dev` succeeds (`assembleDevDebug`).
- Expected runtime behavior: outgoing call → ongoing notification appears silently in the
  shade, no banner over the in-call screen; tap still returns to the call; Hang up / Mute /
  Speaker and the duration timer still work. Incoming ring still shows full-screen / over the
  lock screen with Answer / Decline.
