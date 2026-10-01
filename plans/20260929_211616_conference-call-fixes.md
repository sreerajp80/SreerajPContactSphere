# Plan: Make conference calling work properly

**Status:** completed

## Goal

When the user has two calls, "Merge" should only show when the network can
really merge them, and it should actually merge them. Once merged, the in-call
screen should clearly show a **conference call**, list the people on it, and
let the user drop one person or talk to one person privately. Recents should
not lose calls that were part of a conference.

## What is wrong today

I read `CallRegistry.kt`, `in_call_screen.dart`, `call_state.dart`,
`telecom_service.dart` and `call_event_logger.dart`. These are the problems:

1. **Merge button shows when it should not.** `canMerge` is
   `capability || secondary != null`. So Merge shows any time a second call
   exists — even when the network cannot conference, and even when the second
   call is still **ringing** (call waiting). Tapping it then does nothing.
2. **Swap button shows when it should not.** `canSwap` has the same
   `|| secondary != null` shortcut, so Swap shows next to a ringing
   call-waiting call, where it does nothing.
3. **Merge fallbacks never run.** `merge()` wraps `conference()` in
   try/catch and falls back to other methods on error. But Android's
   `Call.conference()` and `mergeConference()` never throw when the network
   refuses — they just do nothing. So the first attempt is the only attempt,
   and it may be the wrong one. Android's own dialer instead uses the call's
   `conferenceableCalls` list first, then `mergeConference()` when the call
   has the `MERGE_CONFERENCE` capability.
4. **The screen does not know it is a conference.** `isConference` is sent
   from native but no screen uses it. After merging, the conference "host"
   call usually has no number. The screen skips name lookup for an empty
   number, so it keeps showing the **first person's name and photo** as if
   it were still a one-to-one call.
5. **The call notification is also stale.** It keeps the first person's name
   and number after the merge.
6. **No way to manage the people on the call.** The user cannot see who is
   in the conference, cannot drop one person, and cannot split one person
   off for a private talk. Android supports both (`child.disconnect()` and
   `child.splitFromConference()`), gated by per-call capabilities.
7. **Hold + held call.** With one call active and one held, the Hold button
   still shows. Pressing it puts **both** calls on hold. Android's dialer
   hides Hold in this case and offers Swap instead.
8. **Held conference has a poor label.** When the held call is a conference
   (no number), the banner says "Second call — on hold".
9. **Recents can lose a merged incoming call.** The Flutter call logger only
   follows the current main ("primary") call. After a merge the primary
   becomes the conference host, so the logger drops the incoming call it was
   tracking. Native only journals an incoming call when *another call is
   still live* at the moment it ends. If that incoming call is the last one
   to end, nobody logs it (only the later device-log import may catch it).

## Files to change

| File | Change |
|------|--------|
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/CallRegistry.kt` | Fix `canMerge` / `canSwap`; rewrite `merge()`; add participant list + held-conference flag to the snapshot; add `disconnectParticipant` / `separateParticipant`; journal incoming calls that were in a conference |
| `android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt` | Two new method-channel entries: `disconnectParticipant`, `separateParticipant` (by call id) |
| `lib/models/call_state.dart` | New `ConferenceParticipant` class; new fields `participants` and `heldIsConference`; parse them in `fromMap` |
| `lib/services/telecom_service.dart` | New `disconnectParticipant(int callId)` and `separateParticipant(int callId)` |
| `lib/screens/in_call_screen.dart` | Conference view: title "Conference call", "N people" subtitle, brand backdrop, "Manage" button + participants sheet (Private / Drop per person, with contact names), held-conference label, hide Hold while another call is on hold, push the conference label to the notification |
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` + generated `app_localizations*.dart` | New strings (see below); refresh help bullet 4 to mention Manage |
| `test/conference_call_test.dart` | Tests for the new fields and the two new service calls |
| `docs/architecture.md` | Short note on the conference flow (in-call section) |

## The fix, step by step

### 1. Native — `CallRegistry.kt`

- **canMerge** = the primary call has at least one entry in
  `conferenceableCalls`, **or** it has `CAPABILITY_MERGE_CONFERENCE`. Drop
  the `|| secondary != null` shortcut. (This is the same rule Android's own
  dialer uses. A ringing or dialing call is never conferenceable, so call
  waiting no longer shows Merge.)
- **canSwap** = the primary has `CAPABILITY_SWAP_CONFERENCE`, **or** there is
  another top-level call in the **HOLDING** state. A ringing second call no
  longer counts.
- **merge()** — rewrite without the fake fallbacks:
  1. if the primary's `conferenceableCalls` is not empty → prefer the
     secondary call if it is in that list, else the first entry →
     `primary.conference(thatCall)`;
  2. else if the primary can `MERGE_CONFERENCE` → `primary.mergeConference()`;
  3. else if the secondary lists the primary as conferenceable →
     `secondary.conference(primary)`;
  4. else do nothing (the button should not have been shown).
- **Snapshot additions:**
  - `participants`: when the primary is a conference, a list of its child
    calls, each as `{callId, number, state, canDisconnect, canSeparate}`.
    `canDisconnect` = `CAPABILITY_DISCONNECT_FROM_CONFERENCE`, `canSeparate`
    = `CAPABILITY_SEPARATE_FROM_CONFERENCE`. Children get their own ids from
    the existing `callIds` map.
  - `heldIsConference`: the secondary call has `PROPERTY_CONFERENCE`.
  - Register the call callback's `onChildrenChanged` /
    `onConferenceableCallsChanged` so the snapshot is re-sent when people
    join or leave, or when merge becomes possible.
- **New controls:** `disconnectParticipant(callId)` → find that child call →
  `disconnect()`. `separateParticipant(callId)` → `splitFromConference()`.
  Both check the capability first and no-op otherwise.
- **Recents:** keep a small set of calls seen as a conference child
  (`parent != null`). A call leaves the set if it is later seen split out
  (`parent == null`, e.g. "Private"). In `maybeJournalCallWaiting`, journal
  an incoming call when another call is live **or** it is in that set. The
  Flutter drain already uses `logCallIfNew`, which merges with a matching row,
  so this cannot make a second row for the same call.

### 2. Native — `MainActivity.kt`

Add `"disconnectParticipant"` and `"separateParticipant"` to the telecom
method channel, reading an integer `callId` argument.

### 3. Dart model and service

- `ConferenceParticipant` (immutable): `callId`, `number`, `phase`,
  `canDisconnect`, `canSeparate`, with a defensive `fromMap`.
- `CallState`: `participants` (default empty list) and `heldIsConference`
  (default false).
- `TelecomService.disconnectParticipant(int callId)` and
  `separateParticipant(int callId)` via `_invokeVoid`.

### 4. In-call screen

- When `isConference` is true:
  - Title = "Conference call"; subtitle under the timer = "N people".
  - Backdrop = brand gradient (not the first caller's photo); avatar shows a
    group icon instead of an initial. The caller-context card and SIM chip
    logic stay as they are.
  - Push "Conference call" to the notification with the existing
    `setCallerName`. When the call stops being a conference (e.g. one
    person left), push the resolved contact name again.
- New **Manage** button in the second row (only while in a conference and
  `participants` is not empty). It opens a bottom sheet "People on this
  call", one row per participant: contact name (looked up by number through
  `ContactRepository`, as the screen already does) or the number, plus
  **Private** (if `canSeparate`) and **Drop** (red, if `canDisconnect`)
  buttons. The sheet listens to the call stream so it updates live and
  closes itself when the conference ends.
- Held banner: when `heldIsConference`, the label is "Conference call — on
  hold".
- Hide the Hold button while another call is on hold (Swap covers it).
- UI follows the app's own design (same `_toggle` buttons, same sheet style
  as the quick-reply sheet).

### 5. Strings (en, ml, sa)

New keys: `labelConferenceCall` ("Conference call"),
`labelConferencePeople` ("{count, plural, =1{1 person} other{{count} people}}"),
`labelManage` ("Manage"), `titlePeopleOnCall` ("People on this call"),
`actionPrivate` ("Private"), `actionDrop` ("Drop"),
`tooltipPrivateTalk` ("Talk to this person alone"),
`tooltipDropFromCall` ("Remove this person from the call").
Update `helpCallManagementBullet4` to mention Manage / Private / Drop.
Then run `flutter gen-l10n`.

### 6. Tests and checks

- `test/conference_call_test.dart`: parse `participants` and
  `heldIsConference`; defaults when absent; bad entries skipped; the two new
  service calls forward the method name and `callId`.
- Run `dart format`, `flutter analyze` (zero warnings), and
  `flutter test test/conference_call_test.dart` (one file per run, per the
  known sqlite test crash), then the full suite.
- Build the dev APK to be sure the Kotlin compiles.

## What I cannot check from here

Conference calling depends on the SIM network (VoLTE/IMS). I cannot place real
calls, so the final check needs you on the phone:

1. Call A, then Add call → B. Merge should show; tap it → screen says
   "Conference call · 2 people".
2. Manage → Drop B → back to a call with A. Manage → Private on A (if your
   network allows it).
3. While on a call, receive a second call: Merge and Swap must **not** show
   until you answer it.
4. After the calls, both A and B appear in Recents once each.

## Out of scope

- Video conferencing and more than one held call at a time (Android allows
  only one held call anyway).
- The "Add call" second leg's post-call feedback sheet (already skipped on
  purpose today).
