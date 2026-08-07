# Block button on the caller screen + Quick Replies (reject with SMS)

Implements [plans/20260705_134538_block-button-and-quick-replies.md](../plans/20260705_134538_block-button-and-quick-replies.md).

## What changed

### 1. Block control on the in-call screen

- `lib/screens/in_call_screen.dart`
  - New **Block** control, shown whenever the call carries a number: beside
    Speaker while ringing, and appended to the secondary-actions row on a
    connected call.
  - Confirmation dialog → `FlaggedNumberRepository.add(number, kind: kindBlocked)`
    (which already pushes the native screening mirror, so future calls are
    rejected before ringing). If the call is still ringing it is also declined
    immediately. The number appears in **Settings → Contacts → Blocked numbers**.
  - If the number is already blocked the control reads **Blocked** (highlighted)
    and the dialog offers **Unblock** (`removeNumber`).
  - Blocked status is resolved alongside name resolution (per number, guarded
    against number changes mid-query).

### 2. Quick Replies (reject an incoming call with an SMS)

- `lib/state/app_settings.dart` — new persisted `quickReplies` string list
  (key `quick_replies`, 4 defaults), `setQuickReplies`, `resetQuickReplies`,
  and static `readQuickReplies()` for the call flow (cold-start safe).
- `lib/screens/quick_replies_screen.dart` — **new screen**: list / add / edit /
  delete quick replies, plus a Reset-to-defaults action. Card style matches the
  other settings screens.
- `lib/screens/sim_settings_screen.dart` — new "Quick replies" navigation card
  in **Settings → SIM & calling**.
- `lib/screens/in_call_screen.dart` — new **Reply** control while ringing:
  bottom sheet listing the quick replies plus **"Write your own…"** (free-text
  dialog, 160 chars). Picking a message calls `rejectWithMessage`.
- `lib/services/telecom_service.dart` — new `rejectWithMessage(String)` wrapper
  (no-ops off Android like the rest).
- `android/.../MainActivity.kt` — new `"rejectWithMessage"` method-channel case
  (ignores null/blank messages).
- `android/.../CallRegistry.kt` — new `rejectWithMessage(message)`: calls
  `Call.reject(true, message)` on the primary call **only while it is
  `STATE_RINGING`**. The Telecom system service (`RespondViaSmsManager`) sends
  the SMS itself on the SIM the call arrived on — no `SEND_SMS` permission,
  no SmsManager code (same mechanism as the AOSP dialer).

## Not changed

No DB schema change, no new permissions, no new dependencies.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 68 tests pass.
- `flutter build apk --debug` — Gradle `assembleDebug` compiled the Kotlin
  changes and produced fresh `app-dev-debug.apk` / `app-prod-debug.apk`
  (the flutter tool's post-build "couldn't find .apk" message is only its
  lookup expecting an unflavored `app-debug.apk`; the flavored APKs were
  built at 13:57).
