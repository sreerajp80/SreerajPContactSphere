# Connected apps section on the contact detail screen

**Status:** completed

> Implementation note: one file was added to the list during implementation —
> `android/app/src/main/AndroidManifest.xml` gained a `<queries>` intent
> (`ACTION_VIEW` + `vnd.android.cursor.item/*`). Android 11+ package-visibility
> rules would otherwise hide WhatsApp/Telegram from `resolveActivity`, making
> the section always empty. No new permissions.

## What the feature is

On the contact detail screen, show a "Connected apps" section like the one in
Google Contacts. It lists third-party messaging apps (WhatsApp, Telegram,
Arattai, and any other app that syncs contacts) that know this contact. Each
app row can be expanded to show its actions (for example "Message", "Voice
call", "Video call"). Tapping an action opens that app directly on this
contact.

## How the data works (background)

Apps like WhatsApp register a sync adapter and insert extra rows into the
Android contacts database (`ContactsContract.Data`) with their own custom MIME
types. Any app with `READ_CONTACTS` (we already have it) can read these rows.
Tapping an action fires an `ACTION_VIEW` intent on the row's URI with its MIME
type, and the owning app opens the chat or call. We never talk to WhatsApp or
Telegram directly.

This only works for contacts linked to the device address book (our
`Contact.deviceId`). Contacts that live only in our SQLite database have no
such rows, so the section stays hidden for them.

## The issue

ContactSphere has no way to show or launch these per-contact app actions.
`flutter_contacts` does not expose custom MIME type rows, so this needs native
(Kotlin) code behind a platform channel.

## Files to change

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   Add two methods on a new channel `contact_sphere/connected_apps` (keeps the
   existing `contact_sphere/telecom` channel focused):
   - `getConnectedApps(deviceContactId)` —
     - Query `ContactsContract.Data` for that contact ID, keeping only rows
       whose MIME type starts with `vnd.android.cursor.item/vnd.` (that is, a
       custom third-party type; no hardcoded app list, so Arattai and future
       apps work automatically).
     - Read `_ID`, `MIMETYPE`, and `DATA3` (the ready-made, localized action
       label such as "Message +91 98…"; fall back to `DATA2` then the MIME
       type tail when blank).
     - For each row, resolve which app handles it via
       `PackageManager.resolveActivity` on the same `ACTION_VIEW` intent we
       would fire. That gives the app label ("WhatsApp") and icon (returned as
       PNG bytes). Rows nothing handles are dropped.
     - Group rows by app package and return:
       `[{appName, package, icon, actions: [{dataId, mimetype, label}]}]`,
       apps sorted by name.
   - `openConnectedAppAction(dataId, mimetype)` — build
     `ContentUris.withAppendedId(Data.CONTENT_URI, dataId)` and start
     `ACTION_VIEW` with `setDataAndType(uri, mimetype)` and `NEW_TASK`.
     Return false instead of throwing if no app handles it.

2. **`lib/services/connected_apps_service.dart`** (new)
   Small singleton service in the same never-throw style as
   `DeviceContactService`:
   - `fetchConnectedApps(String deviceContactId)` → list of a small
     `ConnectedApp` model (name, package, icon bytes, actions). Returns an
     empty list on any error, on non-Android hosts, or when permission is
     missing.
   - `openAction(int dataId, String mimetype)` → `Future<bool>`.
   The `ConnectedApp` / `ConnectedAppAction` models live in this file (they
   are channel DTOs, not database models, so they do not go in `lib/models/`).

3. **`lib/screens/contact_detail_screen.dart`**
   - After the contact loads, if `contact.deviceId != null`, fetch connected
     apps in the background and store them in state.
   - Render a "Connected apps" section between the summary card and the phone
     number tiles: one expandable tile per app (app icon + name + chevron,
     matching our existing `Card`/`ListTile` styling, not Google's design),
     expanding to the action rows. Tapping an action calls
     `openAction`; on failure show a short SnackBar.
   - The whole section is hidden when the list is empty.

4. **`test/connected_apps_service_test.dart`** (new)
   Unit test that the service returns an empty list when the platform channel
   is unavailable (the `flutter test` host), and a mocked-channel test that
   the response maps to models correctly.

## Not changing

- No new permissions (`READ_CONTACTS` is already declared and requested).
- No database/schema change — nothing is persisted; the data is read live
  from the contacts provider each time the detail screen opens.
- No `pubspec.yaml` change.

## Risks / limits

- Emulators have none of these apps; real testing needs the moto g54.
- Labels in `DATA3` come from each app already localized (Malayalam in the
  screenshot), which is what we want.
- Some apps put several action rows with the same MIME type (one per phone
  number); we show them all, as Google Contacts does.

## Test plan

- `flutter analyze` and `flutter test` stay clean.
- On the moto g54: open a contact known to WhatsApp/Telegram → section shows
  the apps; expand → actions listed; tap "Message" → WhatsApp chat opens;
  contact without `deviceId` → no section.
