# Change log: Conference calling fixes

Implements plan: `plans/20260929_211616_conference-call-fixes.md`

## What changed

### Native (`android/app/src/main/kotlin/in/sreerajp/contact_sphere/`)

- `CallRegistry.kt`
  - **Merge button** now shows only when Telecom says the calls can be joined:
    the primary call lists conferenceable calls, or has the
    `MERGE_CONFERENCE` capability. The old `|| secondary != null` shortcut is
    gone, so Merge no longer shows next to a ringing call-waiting call or on
    networks without conference support.
  - **Swap button** now needs a second call that is **on hold** (or the
    network's conference swap). A ringing second call no longer counts.
  - **`merge()`** rewritten to pick the right method up front, in the same
    order as Android's own dialer. The old try/catch fallbacks never ran,
    because Android's merge calls do not throw when the network refuses.
  - The call snapshot now carries `participants` (for a conference: each
    person's id, number, state, and whether they can be dropped or split off)
    and `heldIsConference`.
  - New `disconnectParticipant(id)` (drop one person) and
    `separateParticipant(id)` (private talk). Both check the capability first.
  - Listens for `onParentChanged`, `onChildrenChanged` and
    `onConferenceableCallsChanged`, so the screen updates when people join or
    leave, or when merging becomes possible.
  - Recents: an incoming call that was merged into a conference is now
    journaled when it ends, even if it was the last call to end. Before, it
    could be lost from the app's own logging.
- `MainActivity.kt`: two new method-channel entries,
  `disconnectParticipant` and `separateParticipant`.

### Flutter

- `lib/models/call_state.dart`: new `ConferenceParticipant` class; new
  `participants` and `heldIsConference` fields on `CallState`, parsed
  defensively (bad entries are skipped).
- `lib/services/telecom_service.dart`: new `disconnectParticipant` and
  `separateParticipant`.
- `lib/screens/in_call_screen.dart`:
  - A merged call shows **"Conference call"**, a group icon and
    "N people", on the brand gradient. It no longer keeps the first person's
    name, photo, caller-ID chip or "why calling" card.
  - The call notification title switches to "Conference call" and back to the
    contact name when the call returns to one-to-one.
  - New **Manage** button opens a "People on this call" sheet with each
    person's contact name (or number), plus **Private** and **Drop** buttons
    when the network allows them. The sheet updates live and closes when the
    conference ends.
  - The Hold button is hidden while another call is on hold (Swap covers it),
    so the user can no longer put both calls on hold by mistake.
  - The held-call banner says "Conference call — on hold" for a held
    conference.
  - The second-call banner / call-waiting card now also shows for callers
    with a hidden number (it used to need a number).
  - Block is hidden for a conference (there is no single number to block).
- Strings (`lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` and the
  generated `app_localizations*.dart`): `labelConferenceCall`,
  `labelConferencePeople`, `labelManage`, `titlePeopleOnCall`,
  `actionPrivate`, `actionDrop`, `tooltipPrivateTalk`, `tooltipDropFromCall`.
  Help bullet `helpCallManagementBullet4` now mentions Manage, Private and
  Drop. English tooltips were kept within the 20-character label budget.

### Docs and tests

- `docs/architecture.md`: new "Conference calls" note in the default phone
  app section.
- `test/conference_call_test.dart`: tests for participant parsing, defaults,
  malformed input, and the two new service calls.

## Checks

- `flutter analyze`: no issues.
- `flutter test`: all tests pass.
- Kotlin compiled and native unit tests pass (`:app:testDevDebugUnitTest`).

## Still to check on a phone

Conference calling depends on the SIM network, so it must be tried on a real
device: merge two calls, use Manage → Drop / Private, confirm Merge and Swap
stay hidden while a second call is still ringing, and confirm both calls
appear once each in Recents.
