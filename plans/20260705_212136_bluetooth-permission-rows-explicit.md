# Fix misleading "Denied" badges on the Permissions screen

**Status:** completed

## The issue

On the Permissions screen, the three new-style Bluetooth permissions (Scan, Connect,
Advertise) sit in the **Implicit** section, whose subtitle says "granted without a
separate prompt". But on Android 12+ these belong to the runtime **Nearby devices**
permission group. The OS reports them as `denied` until the user grants them, so the
screen shows red "Denied" chips under a header that claims no prompt is ever needed.
That contradiction is what looks like a bug.

## The fix

Reclassify the three Bluetooth rows as **explicit** (runtime-prompted), because that is
what they actually are on Android 12+. After the move:

- The Explicit section honestly shows their live status (Denied until the user uses
  "Share via Bluetooth" and accepts the Nearby-devices prompt, then Granted).
- The Implicit section keeps only rows with no runtime status (Default phone app,
  Bluetooth legacy, Internet), which all show the neutral "System" text — so no red
  badges remain under the "no separate prompt" header.

## Files to change

1. `lib/constants/app_permissions.dart`
   - Move the `Bluetooth Scan`, `Bluetooth Connect`, and `Bluetooth Advertise` entries
     from the implicit block to the end of the explicit block, changing their `group`
     to `PermissionGroup.explicit`.
   - Extend each `reason` with a short note that the prompt appears the first time
     Bluetooth sharing is used (Android 12+).
   - Update the file-top doc comment, which currently gives "some Bluetooth entries"
     as an example of implicit permissions.

2. `lib/screens/permissions_screen.dart` — **no change needed.** The grouping and the
   section subtitles already read correctly once the rows move.

## Not doing (and why)

- Showing "Not asked yet" instead of "Denied": Android cannot tell "never asked" apart
  from "asked and refused once" — both report `denied` — so that label could be wrong.
- Version-dependent grouping (implicit on Android ≤ 11): adds async OS-version logic to
  a static catalogue for little benefit; on old Android the rows would simply show
  "Granted".

## Verification

- `flutter analyze` on the touched files (the repo has known pre-existing errors; see
  docs/known-gaps.md — only check for new issues).
- Run the app and open the Permissions screen: the three Bluetooth rows appear under
  Explicit with their live status; the Implicit section shows only "System" rows.
