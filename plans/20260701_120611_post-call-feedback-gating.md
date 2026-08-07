# Post-call feedback: show only at call end, gated by a Settings toggle

**Status:** completed

## The issue

Two problems with the "How did it go?" post-call feedback sheet
([lib/widgets/post_call_feedback_sheet.dart](../lib/widgets/post_call_feedback_sheet.dart)):

1. **It appears as soon as you dial, not when the call ends.**
   `CallLifecycleMixin` ([lib/widgets/call_lifecycle_mixin.dart](../lib/widgets/call_lifecycle_mixin.dart))
   arms a `_pendingCall` in `startCall`, then shows the sheet on the **next app
   resume** (`didChangeAppLifecycleState(resumed)`). It shows the sheet
   *unconditionally* — it never checks whether the call actually happened/ended.
   Any resume after dialing (a permission dialog dismissing, the dialer bouncing
   back, a failed/immediately-returned call on an emulator, etc.) triggers it. The
   `reconcile()` call already returns the matched call-log duration, but the mixin
   ignores that return value (`call_lifecycle_mixin.dart:87`).

2. **There is no Settings toggle for it.** The feature is always on; the user wants
   it to fire only when explicitly enabled in Settings. `AppSettings`
   ([lib/state/app_settings.dart](../lib/state/app_settings.dart)) currently persists
   only theme mode + accent color, and `SettingsScreen`
   ([lib/screens/settings_screen.dart](../lib/screens/settings_screen.dart)) has no
   call-related option.

## The fix

Use the device call log (which `reconcile()` already queries) as the source of
truth for "the call ended," and gate the whole prompt behind a new persisted
setting.

### 1. Only show the sheet when a completed call is confirmed

In `CallLifecycleMixin._handleResume`:
- Capture `reconcile()`'s returned matched duration instead of discarding it.
- Show the feedback sheet **only when** a matching call-log entry with a real
  duration `> 0` was found (i.e. an actual connected call that has ended). A
  0-duration / missed / rejected / never-connected call is still logged/back-filled
  by `reconcile()`, but does **not** trigger the sheet.
- If no completed call is confirmed on this resume (call hasn't ended yet, or this
  resume was a premature bounce-back after dialing), **re-arm** `_pendingCall` so a
  later genuine call-end resume can catch it — bounded by a small max-attempts
  counter so it can't re-arm forever (e.g. give up after ~6 resumes).

In `CallService.reconcile` ([lib/services/call_service.dart](../lib/services/call_service.dart)):
- Add a short bounded poll (e.g. up to 4 tries ~750 ms apart) before giving up,
  because Android can take a moment to write the call-log row after a call ends.
  This makes both the back-fill and the feedback trigger reliable. Return value
  semantics are unchanged (matched duration in seconds, or null when nothing
  matched).

Note: this ties the auto-feedback prompt to `READ_CALL_LOG` access — the app
already depends on that permission for the call-history screen, and it is the only
reliable "call ended" signal on the non-default-dialer path. If the permission is
denied, `reconcile()` can't confirm the call end and the sheet won't auto-show
(better than the current premature pop-up).

### 2. Add a "post-call feedback" setting

`AppSettings`:
- New key `post_call_feedback_enabled`, field `_postCallFeedbackEnabled`, getter
  `postCallFeedbackEnabled`, setter `setPostCallFeedbackEnabled(bool)`, and load it
  in `load()`. Persisted via `shared_preferences` like the existing settings.
- **Default: OFF** (opt-in) — matches the user's "only if enabled in Settings"
  framing. (Open to defaulting ON if you prefer — see the question below.)

`CallLifecycleMixin._handleResume`:
- Read `context.read<AppSettings>().postCallFeedbackEnabled` (via `provider`,
  already the app's DI). Still run `reconcile()` (so duration/type back-fill and
  re-scoring keep working) but only show the sheet when the setting is enabled.

`SettingsScreen`:
- Add a toggle card (a `SwitchListTile`-style row, styled like the existing cards)
  bound to `AppSettings.postCallFeedbackEnabled`, placed with the call-related
  options (just under the "Default phone app" card). Title e.g. "Ask after calls",
  subtitle "Show the ‘How did it go?’ sheet when a call ends."

## Files to change

- [lib/widgets/call_lifecycle_mixin.dart](../lib/widgets/call_lifecycle_mixin.dart)
  — use reconcile result; gate on duration>0; gate on setting; bounded re-arm.
- [lib/services/call_service.dart](../lib/services/call_service.dart)
  — short bounded poll in `reconcile()` for call-log write latency.
- [lib/state/app_settings.dart](../lib/state/app_settings.dart)
  — persist the new `postCallFeedbackEnabled` setting.
- [lib/screens/settings_screen.dart](../lib/screens/settings_screen.dart)
  — add the toggle card.

## Not changing

- The feedback sheet UI itself (`post_call_feedback_sheet.dart`) — it's correct;
  the problem is *when* it's shown.
- The default-dialer / `InCallScreen` path (`main.dart`, `telecom_service.dart`) —
  out of scope for this fix.

## Tests / verification

- `flutter analyze` clean for the touched files.
- Existing `test/call_feature_test.dart` untouched and still passing (it doesn't
  cover the lifecycle/reconcile path — that's platform-bound and verified on device
  per the file's header comment).
- Manual on device: dial a number → sheet must NOT appear on dial; it appears only
  after the call actually ends, and only when the Settings toggle is on.

## Open question for approval

- Default for the new toggle: **OFF (opt-in)** as planned, or **ON**?
