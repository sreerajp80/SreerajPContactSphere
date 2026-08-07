# Quick-action buttons: icon-only + add Email button

**Status:** completed

## Issue

On the contact list card, the expanded quick-action row currently shows three
buttons with **icon + text label** (Call / Profile / Delete). The request:

1. Remove the text labels — show **icons only**.
2. Add a fourth **Email** button that opens the device's default email client
   (a `mailto:` intent) addressed to the contact's primary email.
3. The Email button is **enabled only when the contact has an email address**;
   otherwise it renders disabled (dimmed, non-tappable).

The slim list summaries (`getContactSummaries` / `searchContactSummaries`) do
**not** currently carry emails, so a card loaded via those paths has no way to
know whether the contact has an email. (Cards loaded via `mergedContacts` are
fully hydrated and already carry emails.) We need the primary email available on
the slim summary so the button's enabled/disabled state is correct on every load
path. There is also no email-launching capability in the app yet
(`url_launcher` is only a transitive dependency, not a direct one).

## Files to change

1. **`pubspec.yaml`**
   - Add `url_launcher` to `dependencies` (used to fire the `mailto:` intent).
   - Requires running `flutter pub get` after.

2. **`lib/repositories/contact_repository.dart`**
   - Extend the `_summarySelect` constant with a correlated subquery selecting
     the contact's primary email (mirroring the existing `primary_number`
     subquery): prefer `is_primary DESC, id ASC`, `LIMIT 1`, aliased
     `primary_email`.
   - In `_summaryFromRow`, populate `contact.emails` with a single `Email`
     when `primary_email` is present and non-empty.

3. **`lib/screens/contact_list_screen.dart`**
   - Import `package:url_launcher/url_launcher.dart`.
   - Add helper `String? _primaryEmail(Contact)` returning the first non-empty
     email address, or null.
   - Add `Future<void> _quickEmail(Contact)`: resolve the primary email; if the
     contact has an `id` and no email in the slim summary, best-effort load full
     emails on demand (via a new `emailsFor` — see below) before giving up;
     launch `Uri(scheme: 'mailto', path: address)` with `launchUrl`; show a
     message on failure / no email.
   - In the expanded action `Row`, add a fourth `Expanded` **Email** button
     (`Icons.mail_outline`) between Profile and Delete (order:
     Call · Profile · Email · Delete), enabled only when `_primaryEmail != null`.
   - Rework `_QuickAction`:
     - Stop rendering the text `label` — icons only (drop the `Text` + spacing;
       bump the icon size for a comfortable tap target).
     - Add an `enabled` flag (default `true`): when `false`, dim the button
       (reduced opacity) and disable `onTap`/`onLongPress`.
     - Keep `label` as a field but use it only as the `Tooltip` message /
       semantics label (accessibility for icon-only buttons).

4. **`lib/services/contact_sync_service.dart`** (small addition)
   - Add `Future<List<Email>> emailsFor(int contactId)` delegating to a new
     public `getEmails` wrapper on the repository (mirrors `phoneNumbersFor`),
     so `_quickEmail` can load emails on demand when needed.
   - Add a public `getEmails` wrapper over `_getEmails` in
     `contact_repository.dart`.

## Plan for the fix

- DB: primary email flows into the slim summary so the button state is correct
  without a per-row async fetch on the common paths.
- UI: icon-only buttons with tooltips; Email button greys out when there is no
  address. Tapping a valid Email button hands off to the OS default mail app via
  `mailto:`.
- Launch is best-effort with a user-facing message if no mail client handles it.

## Notes / risks

- Adding `url_launcher` changes `pubspec.lock`; `flutter pub get` needed.
- Four buttons in one row on narrow screens: icons-only keeps them compact, so
  spacing should remain fine, but will verify visually.
- No schema/migration change — only a read-side query addition.
