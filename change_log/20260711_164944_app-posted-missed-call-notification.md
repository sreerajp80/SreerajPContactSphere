# Change log: App-posted missed-call notification + closed the auto-call hole

Implements plan `plans/20260711_163724_app-posted-missed-call-notification.md`
(security-review finding #6: exported `ACTION_CALL` let any app borrow our
`CALL_PHONE` permission — confused deputy).

## What changed

The app now posts its **own** missed-call notification with a "Call back" button.
That button auto-places the call through a **trusted, non-exported** path, so
auto-call no longer depends on (or trusts) the system's `ACTION_CALL` intent.
Every **external** `ACTION_CALL`/`tel:` intent now only opens the dialer
**pre-filled** — never a silent call — which closes the hole. The auto-call
honours the multi-SIM setting just like the dialer.

### Native (Android / Kotlin)

- **New `PendingCallback.kt`** — a one-shot in-process holder (`object`) for the
  trusted call-back number. Only our non-exported receiver can set it, so no other
  app can make the app auto-dial.
- **`CallRegistry.kt`** — added a `sawActiveCalls` set and missed-call
  classification: on `onCallRemoved`, an **incoming** call that **never went
  active** and ended with `DisconnectCause.MISSED`/`REMOTE` (i.e. not a user
  decline) is reported to the service via a new `RingController.onMissedCall(number)`.
- **`ContactSphereInCallService.kt`** — implements `onMissedCall`: creates a
  "Missed calls" notification channel and posts a missed-call notification (unique
  id per call, `CATEGORY_MISSED_CALL`) with a **Call back** action, then calls
  `TelecomManager.cancelMissedCallsNotification()` to drop the system's duplicate.
  The Call back action is a `PendingIntent` to the non-exported `CallActionReceiver`.
- **`CallActionReceiver.kt`** — new `ACTION_CALL_BACK` (+ `EXTRA_NUMBER`,
  `EXTRA_NOTIFICATION_ID`): parks the number in `PendingCallback`, cancels the
  notification, and brings `MainActivity` forward.
- **`MainActivity.kt`** — `handleDialIntent` now parks every external
  `ACTION_CALL`/`ACTION_DIAL`/`ACTION_VIEW` (`tel:`) with `autoCall = false`
  (pre-fill only). New `drainTrustedCallback()` (called first in the `getPendingDial`
  channel handler) moves a `PendingCallback` number in as `autoCall = true`; new
  `nudgeTrustedCallback()` (called from `onCreate`/`onNewIntent`) triggers warm
  collection.

### Flutter (Dart)

- **`lib/main.dart`** — `_placeCallback` now resolves the SIM the same way the
  dialer does (`CallLifecycleMixin._resolveSim`): when "ask which SIM" is on and
  there are 2+ SIMs it shows `showSimPickerSheet` (dismiss cancels the call-back),
  otherwise it uses the configured default SIM. Added the `models/sim_account.dart`
  import.

### Manifest / docs

- **`AndroidManifest.xml`** — updated the `ACTION_CALL` intent-filter comment to
  explain external intents are pre-fill only and auto-dial comes from our own
  notification's trusted path.
- **`docs/architecture.md`** — documented the missed-call notification + trusted
  Call-back flow and that the manifest now lists `CALL` among the dialer filters.

## Verification

- `flutter analyze` — No issues found.
- `flutter test` (run one file per invocation per the known sqlite native-assets
  issue) — all suites pass **except** `test/group_ringtone_test.dart`'s v13→v14
  migration test, which fails identically on the pre-change committed code
  (verified via `git stash`) — a pre-existing failure, not from this change.
- `./gradlew :app:compileDevDebugKotlin` — BUILD SUCCESSFUL (only pre-existing
  `startActivityForResult` deprecation warnings).

## Still to verify on device (moto g54) — see plan Testing/Risks

- The main risk: `cancelMissedCallsNotification()` reliably suppressing the OEM's
  own missed-call notification (no duplicate).
- Miss a call → our notification appears; Call back auto-dials (SIM picker first
  when enabled + 2 SIMs). Decline → no notification. External `tel:`/`ACTION_CALL`
  → dialer pre-filled, no silent call.

## Follow-up (not in this change)

- Missed-call notification shows the **number**; showing the saved contact name
  while the app is fully closed needs a digits→name mirror (like the ringtone/
  screening mirrors). Left as a future enhancement.
