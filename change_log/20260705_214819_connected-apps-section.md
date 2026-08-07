# Connected apps section on the contact detail screen

Implements [plans/20260705_213646_connected-apps-section.md](../plans/20260705_213646_connected-apps-section.md).

## What changed

1. **`android/app/src/main/kotlin/in/sreerajp/contact_sphere/MainActivity.kt`**
   - New MethodChannel `contact_sphere/connected_apps` with two methods:
     - `getConnectedApps(contactId)` — queries `ContactsContract.Data` for
       custom third-party MIME rows (`vnd.android.cursor.item/vnd.%`), runs on
       a background thread, resolves each row's owning app (name + PNG icon)
       via `PackageManager`, and returns rows grouped per app and sorted by
       app name. Rows no installed app handles are dropped. Returns an empty
       list without `READ_CONTACTS`.
     - `openConnectedAppAction(dataId, mimetype)` — fires the `ACTION_VIEW`
       intent on the data row so the owning app opens the chat/call. Returns
       false instead of throwing when nothing handles it.
   - New helper `drawableToPng` to send app icons to Dart.

2. **`android/app/src/main/AndroidManifest.xml`** *(small addition not in the
   plan)* — added a `<queries>` intent for `ACTION_VIEW` +
   `vnd.android.cursor.item/*`. Android 11+ package-visibility rules hide
   other apps from `resolveActivity`/`startActivity` without it, so the
   feature would silently show nothing on the moto g54.

3. **`lib/services/connected_apps_service.dart`** (new) — never-throw singleton
   wrapper over the channel, plus the `ConnectedApp` / `ConnectedAppAction`
   DTO models. Degrades to an empty list / false on any error, missing
   platform, or blank device-contact id.

4. **`lib/screens/contact_detail_screen.dart`** — after the contact loads, if
   it is linked to a device contact (`deviceId`), the connected apps are
   fetched in the background and shown in a "Connected apps" `Card` between
   the summary card and the phone tiles: one `ExpansionTile` per app (icon +
   name), expanding to its action rows (labels come from each app, already
   localized). Tapping an action opens the app; failure shows a SnackBar.
   The section is hidden when the list is empty or the contact is local-only.

5. **`test/connected_apps_service_test.dart`** (new) — pins the service's
   contracts: empty list / false when no platform handler exists (the
   `flutter test` host), the empty-id short-circuit, payload-to-model mapping
   (including dropping broken rows), and argument forwarding for `openAction`.

## Verification

- `flutter analyze` — no issues.
- `flutter test` — all 100 tests pass (5 new).
- `flutter build apk --debug --flavor dev` — builds, so the Kotlin compiles.
- Real-device check (moto g54, contacts known to WhatsApp/Telegram/Arattai)
  is still pending — emulators don't have these apps.
