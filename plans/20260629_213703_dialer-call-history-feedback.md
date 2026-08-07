# Dialer, Call History & Post-Call Feedback

**Status:** completed

## Issue / motivation

`docs/known-gaps.md` (item *"3. Where is the Dialer?"*) records that ContactSphere has
**no standalone dialer**. Calling only happens from `contact_detail_screen.dart` (and a quick-call
on the list). There is also no unified **call history** screen, and no **feedback mechanism** to
capture how a call went — even though the data layer already supports it
(`call_logs.call_intent`/`notes`, `interactions.emotional_tone`, and a `reminders` table), and
`RelationshipScoringService` already weights `emotional_tone` at 30% of the score.

**Decisions taken (confirmed with user):**
- **Call recording** is *deferred to a later phase* — it is not reliably possible for a non-default
  third-party dialer on Android 10+ and would violate Play policy. Out of scope here; noted as a
  future investigation in `known-gaps.md`.
- **Scope this round:** dialer **+** call history **+** post-call feedback, together.
- **Feedback:** the *full outcome form* — sentiment + note + intent tag + optional follow-up
  reminder (written to the existing `reminders` table).

## No database migration required

The schema already has every column we need:
- `call_logs`: `call_type`, `duration`, `timestamp`, `call_intent`, `notes`, nullable `contact_id`.
- `interactions`: `emotional_tone`, `duration`.
- `reminders`: `contact_id`, `reminder_text`, `reminder_time`, `location`, `is_completed`.

So `database_helper.dart` stays at **v3** — no `_onCreate`/`_onUpgrade` change, no version bump.

## Design consistency (style contract — applies to every new screen/widget)

All new UI must adhere to the app's existing **premium idiom** established by
`contact_list_screen.dart` and the `AppColors` theme extension — *not* the plainer
`AppBar`/`ListTile` look of `groups_screen.dart`. Concretely, every new screen/widget:

- Reads design tokens via `Theme.of(context).extension<AppColors>()!` and
  `Theme.of(context).colorScheme.primary` — **no hard-coded colors** except the shared mood
  palette from `AppTheme.moodFor(...)`. Never assume light/dark; branch on `colors.isDark`.
- **Surfaces:** cards/containers use `colors.cardSurface`, `BorderRadius.circular(20)` (sheets/keys
  may use a smaller radius consistent with `_QuickAction`'s 13), and the existing dark-vs-light
  treatment — a subtle `Colors.white.withValues(alpha: 0.06)` border in dark, a soft
  `0F2A28`/accent shadow in light (copy the `_buildContactCard` pattern).
- **Primary actions** (the dialer call button, sheet "Save") use `colors.brandGradient` with
  `AppTheme.contrastOn(accent)` for the foreground — mirroring `_buildFab`. Secondary actions use
  the `_QuickAction` pill style (`accent.withValues(alpha: 0.1)` fill, accent foreground).
- **Typography:** screen titles 26 / `w800` / `letterSpacing: -0.6`; secondary text via
  `colors.mutedText`; weights/sizes consistent with the contact card.
- **Top-level tab screens (Dialer, Recents)** use the custom in-body header (like the contacts
  screen) rather than a stock `AppBar`, since they live inside `HomeShell`'s `NavigationBar`.
  Modal sheets (feedback) use `colors.cardSurface`, a grab handle, and rounded top corners.
- **Sentiment colors** in the feedback sheet/history reuse the `Mood` palette
  (`10B981` positive / `F59E0B` neutral / `EF4444` negative) so they read as the same visual
  language as the relationship-health mood used everywhere else.
- The `NavigationBar` in `HomeShell` is themed from the same tokens (surface = `cardSurface`,
  selected indicator = accent alpha) so the three tabs feel like one app.

The existing widget smoke test plus a quick manual pass in **both** Calm (light) and Midnight (dark)
themes is the acceptance bar for style.

## Design

### 1. Shared call lifecycle (de-duplicate existing logic)
Today the "place call → log provisional rows → reconcile on resume → re-score" flow lives inline in
`contact_detail_screen.dart`, and a partial copy lives in `contact_list_screen.dart` (`_quickCall`).
Extract it so the dialer, detail, and list all share one correct implementation:

- **`lib/services/call_service.dart`** (new) — pure logic, no UI:
  - `Future<PendingCall?> placeCall({int? contactId, required String number})` — checks
    `Permission.phone`, calls `FlutterPhoneDirectCaller.callNumber`, then best-effort logs a
    provisional `call_logs` row (and an `interactions` row when `contactId != null`). Returns a
    `PendingCall` token (number, placedAt, callLogId, interactionId?) or `null` if logging failed.
  - `Future<CallType?> reconcile(PendingCall pending)` — the `CallLog.query` + `_bestMatch` +
    `updateCallOutcome` + `calculateRelationshipScore` logic currently in the detail screen, moved
    here verbatim (including the digit-normalisation match helpers and `_mapCallType`).
- **`lib/widgets/call_lifecycle_mixin.dart`** (new) — a `mixin` on `State<T> with WidgetsBindingObserver`
  that holds the current `PendingCall`, on `AppLifecycleState.resumed` calls `CallService.reconcile`
  and then shows the post-call feedback sheet. Screens mix this in instead of re-implementing the
  observer. (Keeps `contact_detail_screen` from growing further and lets the dialer reuse it.)

### 2. Dialer screen (T9 dialpad)
- **`lib/screens/dialer_screen.dart`** (new), styled with the existing `AppColors` theme extension:
  - Number display field + backspace (long-press to clear).
  - 3×4 dialpad grid (1–9, `*`, 0 with `+` on long-press, `#`), with letter sub-labels.
  - **Match-as-you-type:** as digits are entered, query `ContactRepository` for contacts whose
    number contains the typed digits (digit-normalised, reusing the match logic), shown as a tappable
    suggestion list; tapping fills the number / opens the contact.
  - Big green call button → `CallService.placeCall(contactId: matchOrNull, number: typed)`, then the
    mixin reconciles + shows feedback on resume.
  - A new read method `ContactRepository.findByPhoneFragment(String digits)` (LIKE on normalised
    trailing digits) backs both the suggestion list and contact resolution for unknown numbers.

### 3. Call history screen ("Recents")
- **`lib/models/call_record.dart`** (new) — a `call_logs` row joined with the contact's display name
  (named `CallRecord` to avoid colliding with the `call_log` package's `CallLogEntry`).
- **`lib/repositories/call_log_repository.dart`** (new) — read path:
  `recentCalls({int limit})` returns `List<CallRecord>` via a `LEFT JOIN contacts` ordered by
  `timestamp DESC`; `clearHistory()` and `deleteCall(id)` for management. (Write path stays in
  `InteractionRepository`.)
- **`lib/screens/call_history_screen.dart`** (new) — grouped-by-day list; each row shows
  name-or-raw-number, call-type icon (in/out/missed), relative time, duration, and the captured
  sentiment/intent if present. Tap → contact detail (when linked) or a "call back / add contact"
  action for unknown numbers. Overflow: clear history.

### 4. Post-call feedback (full outcome form)
- **`lib/widgets/post_call_feedback_sheet.dart`** (new) — a modal bottom sheet shown after a call
  reconciles (via the mixin). Fields:
  - **Sentiment:** positive / neutral / negative (maps to `interactions.emotional_tone`, the exact
    strings `RelationshipScoringService` already switches on).
  - **Intent tag:** short chips + free text → `call_logs.call_intent`.
  - **Note:** free text → `call_logs.notes`.
  - **Follow-up reminder (optional):** text + date/time → a `reminders` row.
  - "Skip" dismisses without writing feedback (provisional rows already captured the call itself).
- **`lib/repositories/interaction_repository.dart`** (modified) — add
  `recordCallFeedback({required int callLogId, int? interactionId, String? tone, String? intent, String? notes})`
  that updates `interactions.emotional_tone` and `call_logs.call_intent`/`notes` in one transaction,
  then the caller re-runs `calculateRelationshipScore`.
- **`lib/repositories/reminder_repository.dart`** (new) — minimal `insert(...)` for the follow-up.
  *Note:* per `known-gaps.md`, nothing schedules notifications yet, so the reminder is **persisted
  only** (surfacing/notifying it is explicitly out of scope and stays a known gap).

### 5. Navigation — make the dialer first-class
- **`lib/screens/home_shell.dart`** (new) + **`lib/main.dart`** (modified): set `home:` to a
  `HomeShell` with a Material 3 `NavigationBar` of three tabs — **Contacts** (the existing
  `ContactListScreen`, unchanged internally), **Dialer**, **Recents** (call history). This gives the
  "proper dialer" feel without rewriting the contacts screen.
- **`lib/screens/contact_detail_screen.dart`** (modified): replace its inline pending-call/observer
  code with `CallService` + `CallLifecycleMixin`; show the feedback sheet on resume.
- **`lib/screens/contact_list_screen.dart`** (modified): route `_quickCall` through `CallService` so
  the list also gets reconciliation + feedback (removes the duplicated logging).

## Files to change

**New**
- `lib/services/call_service.dart`
- `lib/widgets/call_lifecycle_mixin.dart`
- `lib/screens/dialer_screen.dart`
- `lib/screens/call_history_screen.dart`
- `lib/screens/home_shell.dart`
- `lib/models/call_record.dart`
- `lib/repositories/call_log_repository.dart`
- `lib/repositories/reminder_repository.dart`
- `lib/widgets/post_call_feedback_sheet.dart`

**Modified**
- `lib/main.dart` — host `HomeShell` as `home:`.
- `lib/screens/contact_detail_screen.dart` — use `CallService` + mixin + feedback sheet.
- `lib/screens/contact_list_screen.dart` — `_quickCall` via `CallService`.
- `lib/repositories/interaction_repository.dart` — add `recordCallFeedback`.
- `lib/repositories/contact_repository.dart` — add `findByPhoneFragment`.
- `docs/known-gaps.md` — mark dialer/history/feedback as implemented; record call **recording** as a
  deferred future phase.

**No change:** `database_helper.dart` (no migration), `AndroidManifest.xml` (CALL_PHONE +
READ_CALL_LOG already declared; mic/RECORD_AUDIO already present but unused here).

## Verification
- `flutter analyze` clean.
- `flutter test` — existing widget smoke test still passes (HomeShell must pump cleanly with an empty
  DB). Add a unit test for `CallService.reconcile` matching and `recordCallFeedback` if practical with
  `sqflite_common_ffi`.
- Manual: dial a number, place a call, confirm provisional row, return → reconciliation back-fills
  duration, feedback sheet appears, sentiment flows into the relationship score, and the call shows in
  Recents.

## Out of scope (future phases)
- **Call recording** (deferred per decision; needs default-dialer role / is Play-policy constrained).
- **Reminder notifications** (the existing unscheduled `reminders` gap is unchanged).
- Becoming the system **default dialer** / handling incoming-call UI.
