# Block button on the caller screen + Quick Replies (reject with SMS)

**Status:** completed

## Issue / feature request

1. **Block from the caller screen.** The in-call screen has no way to block the caller.
   The user must remember the number and add it manually in Settings → Contacts →
   Blocked numbers. A Block button on the caller screen should add the number to that
   same list (the existing `flagged_numbers` table / screening mirror — no new storage).
2. **Quick Replies.** No way to reject an incoming call with a text message. We need:
   - A **Settings → SIM & calling → Quick replies** screen to manage a list of canned
     reply messages.
   - A **Reply button on the incoming-call screen** that shows those messages (plus a
     "Write your own…" custom-message option), rejects the call, and sends the chosen
     text as an SMS to the caller.

## How the SMS gets sent (design note)

Android Telecom natively supports "reject with message": `Call.reject(true, message)`
on a `STATE_RINGING` call. The **Telecom system service** (`RespondViaSmsManager`)
sends the SMS itself, on the SIM/subscription the call arrived on. Because the OS sends
the message, the app needs **no `SEND_SMS` permission** and no SmsManager code — this is
exactly what the AOSP/Google dialer does. Reject-with-message is only valid while the
call is ringing, so the Reply button appears only for incoming ringing calls.

## Files to change

| File | Change |
|---|---|
| `lib/state/app_settings.dart` | New persisted `quickReplies` list (`getStringList`, key `quick_replies`) with 4 sensible defaults; `setQuickReplies(List<String>)`; load in `load()`. Defaults returned when the key is unset. |
| `lib/screens/quick_replies_screen.dart` | **New screen.** Lists the replies; add / edit / delete via dialogs; "Reset to defaults" action; same card-based visual style as the other settings screens. |
| `lib/screens/sim_settings_screen.dart` | Add a "Quick replies" navigation card (same pattern as the Identification card) routing to the new screen. |
| `lib/services/telecom_service.dart` | New `rejectWithMessage(String message)` → invokes native `rejectWithMessage`. |
| `android/.../MainActivity.kt` | New method-channel case `"rejectWithMessage"` → `CallRegistry.rejectWithMessage(msg)`. |
| `android/.../CallRegistry.kt` | New `rejectWithMessage(message: String)`: if the primary call is `STATE_RINGING`, `call.reject(true, message)`; else no-op. |
| `lib/screens/in_call_screen.dart` | Two additions: **(a) Block** — a control shown whenever the call has a number: while ringing it sits beside Speaker; on a connected call it joins the secondary-actions row. Confirmation dialog → `FlaggedNumberRepository.add(number, kind: kindBlocked)` (which already pushes the native screening mirror) → if ringing, also `disconnect()`. Snackbar-less (screen may pop); the number then appears in Settings → Contacts → Blocked numbers as requested. If the number is already blocked the dialog offers Unblock instead. **(b) Reply** — while ringing, a "Reply" control beside Speaker opens a bottom sheet listing the quick replies plus "Write your own…" (inline text field). Choosing/submitting a message calls `TelecomService.rejectWithMessage(text)`; the call ends and Telecom sends the SMS. |

No DB schema change, no new permissions, no new dependencies.

## Plan for the fix (implementation order)

1. `AppSettings`: quick-replies storage (defaults: "Can't talk now. Call you later.",
   "Can't talk now. What's up?", "I'm in a meeting.", "On my way.").
2. Native: `CallRegistry.rejectWithMessage` + `MainActivity` channel case.
3. `TelecomService.rejectWithMessage` Dart wrapper (no-ops off Android like the rest).
4. `QuickRepliesScreen` + entry card in `SimSettingsScreen`.
5. `InCallScreen`: Block control (+ confirm dialog) and Reply control (+ bottom sheet
   with custom-message field).
6. `flutter analyze` + `flutter test` to verify nothing regressed.

## Notes / limitations

- Blocking takes effect for **future** calls via the existing CallScreeningService;
  blocking during a ringing call also rejects that call immediately.
- Reply requires the caller's number to be visible (hidden numbers get no Reply button)
  and only works while ContactSphere is the default phone app (same as the rest of the
  in-call UI).
- Whether the SMS is actually delivered is up to the platform/carrier (as with any
  dialer's "reject with message").
