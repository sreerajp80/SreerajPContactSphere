# Change log — Post-call feedback: show only at call end, gated by Settings

Implements [plans/20260701_120611_post-call-feedback-gating.md](../plans/20260701_120611_post-call-feedback-gating.md).

## Problem

The "How did it go?" feedback sheet appeared **as soon as a number was dialed**,
not when the call ended, and there was no way to turn it off.

- `CallLifecycleMixin` showed the sheet on the *next app resume* after `startCall`,
  unconditionally — it ignored `reconcile()`'s return value, so any resume (a
  permission dialog closing, the dialer bouncing back, a failed call) triggered it.
- No Settings option existed to enable/disable the prompt.

## Changes

### lib/widgets/call_lifecycle_mixin.dart
- `_handleResume` now uses `reconcile()`'s returned duration: the sheet is shown
  **only when a completed call is confirmed** (a matching call-log entry with
  duration `> 0`).
- If the resume isn't a completed call end (premature bounce-back after dialing),
  the pending call is **re-armed** so the real call-end resume can catch it, bounded
  by `_maxReconcileAttempts` (6) so it can't poll forever.
- Added a `_reconciling` guard so overlapping resume events don't reconcile
  concurrently; `_reconcileAttempts` resets in `startCall`.
- The sheet is now **gated on the new `AppSettings.postCallFeedbackEnabled`**
  setting (read via `provider`). Reconciliation/back-fill/re-scoring still run
  regardless of the setting.

### lib/services/call_service.dart
- `reconcile()` now **polls the device call log** up to 4 times, 750 ms apart
  (`_reconcileMaxTries` / `_reconcileRetryDelay`), before giving up — Android can
  lag in writing the call-log row after a call ends. Return-value semantics
  unchanged (matched duration, or null).

### lib/state/app_settings.dart
- New persisted setting `postCallFeedbackEnabled` (key `post_call_feedback_enabled`),
  with getter, `setPostCallFeedbackEnabled(bool)`, and load logic. **Defaults to
  OFF** (opt-in) per the approved plan.

### lib/screens/settings_screen.dart
- New `_PostCallFeedbackCard` toggle ("Ask after calls" / "Show the ‘How did it
  go?’ sheet when a call ends"), placed just under the "Default phone app" card,
  bound to `AppSettings.postCallFeedbackEnabled` via `provider`.

## Verification

- `flutter analyze` on the four changed files: **No issues found**.
- `flutter test test/call_feature_test.dart`: **all 4 tests pass** (unchanged).
- The lifecycle/reconcile path is platform-channel bound and is verified manually
  on a device (per the test file's header note): dial → sheet does not appear on
  dial; it appears only after a connected call ends, and only when the toggle is on.
