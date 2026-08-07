# Change log — Dialer, Call History & Post-Call Feedback

Implements plan
[plans/20260629_213703_dialer-call-history-feedback.md](../plans/20260629_213703_dialer-call-history-feedback.md).

## What changed

Added a standalone T9 **dialer**, a unified **call history ("Recents")**, and a **full post-call
feedback** flow, all surfaced through a new bottom-navigation shell. No database migration was
required — every column used already existed (`call_logs.call_intent`/`notes`,
`interactions.emotional_tone`, the `reminders` table), so `DatabaseHelper` stays at v3.

Call **recording** was deferred to a future phase (not reliable for a non-default-dialer app on
Android 10+); documented in `docs/known-gaps.md`.

### New files
- `lib/models/call_record.dart` — a `call_logs` row joined to the contact name (history display).
- `lib/repositories/call_log_repository.dart` — history reads (`recentCalls`), `deleteCall`,
  `clearHistory`.
- `lib/repositories/reminder_repository.dart` — minimal `insert` for follow-up reminders
  (persisted-only; notification scheduling remains a known gap).
- `lib/services/call_service.dart` — UI-free place-a-call lifecycle: `placeCall` (permission →
  dial → resolve contact → provisional log) and `reconcile` (device call-log match → back-fill →
  re-score). Exposes `PendingCall` and `CallPermissionDeniedException`.
- `lib/widgets/call_lifecycle_mixin.dart` — `CallLifecycleMixin` on `State + WidgetsBindingObserver`:
  registers the observer, reconciles on resume, shows the feedback sheet, persists feedback, re-scores,
  and calls `onCallReconciled()`.
- `lib/widgets/post_call_feedback_sheet.dart` — the "How did it go?" modal: sentiment (mood palette),
  intent chips, notes, optional follow-up reminder with date/time. Returns `PostCallFeedback`.
- `lib/screens/dialer_screen.dart` — custom T9 dialpad (no `TextField`), match-as-you-type
  suggestions, gradient call button.
- `lib/screens/call_history_screen.dart` — day-grouped recents with type icons, duration, intent,
  call-back, and clear-history.
- `lib/screens/home_shell.dart` — Material 3 `NavigationBar` (Contacts / Dialer / Recents) over an
  `IndexedStack`, themed from `AppColors`.
- `test/call_feature_test.dart` — unit tests for `findByPhoneFragment`, `recordCallFeedback`,
  `recentCalls` join, and `clearHistory`.

### Modified files
- `lib/main.dart` — `home:` is now `HomeShell`.
- `lib/repositories/contact_repository.dart` — added `PhoneMatch` + `findByPhoneFragment` (digit-only
  matching) and the static `normalizeDigits` helper.
- `lib/repositories/interaction_repository.dart` — `logCall` now accepts a nullable `contactId`
  (unknown-number calls); added `recordCallFeedback`.
- `lib/screens/contact_detail_screen.dart` — dropped the inline pending-call/observer/match code in
  favour of `CallLifecycleMixin`; `_call` now delegates to `startCall`.
- `lib/screens/contact_list_screen.dart` — `_quickCall` now routes through `CallLifecycleMixin`
  (reconciliation + feedback on the list too).
- `docs/known-gaps.md` — recorded the dialer/history/feedback as implemented, added a "Deferred"
  section for call recording, and noted reminders are now written (but still unscheduled).
- `test/widget_test.dart` — updated to assert the new `HomeShell`/`NavigationBar` instead of the bare
  contacts screen.

## Design consistency
All new screens/widgets follow the premium idiom from `contact_list_screen.dart`: `AppColors` tokens
(`cardSurface`, `mutedText`, `searchFill`, `brandGradient`), 20px rounded cards with the dark-border /
light-shadow treatment, gradient primary actions with `AppTheme.contrastOn`, and the shared mood
palette for sentiment. The `NavigationBar` is themed from the same tokens.

## Verification
- `flutter analyze` — No issues found.
- `flutter test` — all 16 tests pass (12 pre-existing + 4 new).
- Device-bound paths (placing calls, call-log reconciliation, feedback round-trip into the score) are
  intended for manual verification on a device, consistent with the existing repository tests' note.
