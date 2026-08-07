# Change log — icon-only quick actions + Email button

Implements plan
[plans/20260703_113905_quickaction-icons-email-button.md](../plans/20260703_113905_quickaction-icons-email-button.md).

## What changed

### `pubspec.yaml`
- Added `url_launcher: ^6.3.0` to `dependencies` (fires the `mailto:` intent).
  `flutter pub get` run to resolve it.

### `lib/repositories/contact_repository.dart`
- Extended `_summarySelect` with a `primary_email` correlated subquery (mirrors
  `primary_number`; `ORDER BY e.is_primary DESC, e.id ASC LIMIT 1`).
- `_summaryFromRow` now populates `contact.emails` with a single primary `Email`
  when `primary_email` is present, so slim summaries carry the primary email.
- Added public `getEmails(int contactId)` wrapper over `_getEmails`.

### `lib/services/contact_sync_service.dart`
- Added `emailsFor(int contactId)` delegating to `ContactRepository.getEmails`
  (mirrors `phoneNumbersFor`), for on-demand email loading.
- Imported `../models/email.dart`.

### `lib/screens/contact_list_screen.dart`
- Imported `package:url_launcher/url_launcher.dart`.
- Added `_primaryEmail(Contact)` — first non-empty email from the summary, else
  null.
- Added `_quickEmail(Contact)` — resolves the primary email (with a best-effort
  on-demand `emailsFor` fallback), launches `mailto:` via `launchUrl`, and shows
  a message when there is no address / no mail app / the launch fails.
- Added a fourth quick-action button (`Icons.mail_outline`, "Email") between
  Profile and Delete, enabled only when `_primaryEmail(contact) != null`.
- Reworked `_QuickAction`:
  - Now **icon-only** — the `label` is used solely as the `Tooltip` /
    accessibility message; the inline `Text` and its spacing were removed and
    the icon size bumped (15 → 19) with vertical padding 10 → 11.
  - Added an `enabled` flag (default `true`): when `false`, the button is dimmed
    (`Opacity` 0.4) and `onTap`/`onLongPress` are nulled.

### `android/app/src/main/AndroidManifest.xml`
- Added a `mailto` `SENDTO` `<intent>` to the existing `<queries>` block so the
  `mailto:` launch is visible to package resolution on Android 11+ (without it
  `launchUrl` returns false even when a mail app is installed). This manifest
  addition is a necessary implementation detail of the approved email feature.

## Verification
- `flutter analyze` on the three changed Dart files: **No issues found**.
- `flutter test test/contact_sync_service_test.dart`: **all 11 tests passed**
  (including the summary-paging and email-search tests).

## Notes
- Button order in the expanded card row is now: Call · Profile · Email · Delete,
  all icon-only.
- `pubspec.lock` changed from adding `url_launcher`.
- Not exercised on a device/emulator in this session — recommend a quick visual
  check of the four-icon row and a `mailto:` tap on a device.
