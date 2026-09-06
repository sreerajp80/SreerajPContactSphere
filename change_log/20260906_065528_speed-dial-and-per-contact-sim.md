# Speed Dial and Per-Contact Preferred SIM built

Implements `plans/20260906_062305_speed-dial-and-per-contact-sim.md`.

Both features were advertised on the Features screen but had never been built. The false
claims were removed in `change_log/20260906_060652_features-screen-accuracy.md`. They are now
real, and the claims are back on the page.

---

## Part 1 — Speed dial

Keypad keys **1 to 9** can each hold one saved number. Holding a key on the dialer calls it.

- **Storage.** New `speed_dial` table in the encrypted database: `slot` (the primary key, so
  one number per key), `contact_id`, `phone_number`, `created_at`. The foreign key uses
  `ON DELETE CASCADE`, so deleting a contact frees its key with no orphan row left behind.
  The number is personal data, so it lives in the encrypted database, not SharedPreferences.
- **Long-press on the keypad.** A key holding a number calls it (with a short "Calling …"
  message naming who). An empty key opens the contact picker to fill it. Both act **only
  when the number box is empty** — a long press while a number is being typed does nothing,
  so a stray press can never dial the wrong person.
- **Key 0 is unchanged**: it still types `+`. `*` and `#` are not slots.
- **Discoverability.** A key that holds a number shows a small accent dot above the digit.
  The dot is drawn as an overlay, so it costs the key no height and cannot push the digit or
  the letter legend out of the key at large system font sizes.
- **Assigning.** Pick a contact (the picker searches exactly as the Contacts screen does),
  then pick which number if the contact has more than one.
- **Settings → Speed Dial.** Lists all nine keys with who each one calls; tap to set or
  change, tap the ✕ to clear.
- **Secret contacts are refused**, in three places: the picker hides them, the repository
  rejects an assign, and reads filter them out. A key would otherwise show a hidden person's
  name on the keypad and dial them with no unlock. Making an already-assigned contact secret
  frees its key inside the same transaction as the update.
- **Backups.** `speed_dial` travels in a full backup and is restored with contact links
  intact (a full restore preserves contact ids). It is listed as an *optional* managed table,
  so restoring a backup made before this feature existed leaves the keys on the phone alone
  instead of wiping them. It is carried only on a full run, so a category-picked
  device-to-device share never sends it — which key calls whom is personal to one phone.

## Part 2 — Per-contact preferred SIM

A contact can be given its own SIM, used ahead of the global default.

- **Storage.** Two new columns on `contacts`: `preferred_sim_id` (the Telecom
  `phoneAccountId`) and `preferred_sim_label` (display only, so the contact screen can name
  the SIM before the SIM list has loaded). App-only, like the calling card: never written to
  the device address book, not in vCard/CSV export.
- **Which SIM a call uses.** New pure function `SimService.resolve`: the **contact's
  preferred SIM**, then the **global default**, then null (let Android choose). An id that no
  longer matches a SIM in the phone — a removed or swapped SIM — is skipped, so a stale
  preference quietly falls back instead of failing the call.
- **With "Ask before each call" ON**, the chooser still appears (that setting means "confirm
  every call"), but the SIM the call would have used is highlighted, ticked and labelled
  "Usual SIM for this call", so honouring the preference is one tap.
- **Setting it.** Contact editor → "Preferred SIM", with "Default SIM" plus one row per SIM.
  The section is hidden unless the phone reports two or more SIMs, and on your own Self
  record.
- **Seeing it.** The contact detail screen shows a "Calls go out on this SIM" row when a
  preference is set.
- **Call-back from a missed-call notification** honours it too. That path knows only a
  number, so it now looks the contact up first; a failed lookup falls back to the default and
  never blocks the call.

## Part 3 — Claims restored

- Features screen: a new **Speed Dial** card, and **"Per-contact preferred SIM"** added to
  the Dual-SIM card (with the description saying it wins over the default).
- `test/features_screen_test.dart`: `speed dial` and `per-contact default sim` removed from
  the "does not advertise" guard list (the other eight stay) and moved to the "documented
  features are listed" test.
- Help → Calling & In-Call Controls: a new "Speed Dial" section, and three new points under
  Dual-SIM about setting a person's SIM, the pre-ticked chooser, and the fallback.

---

## Database

DB version **29 → 30**. Both steps are existence-checked helpers
(`ensureSpeedDialTable`, `ensurePreferredSimColumns`) that run from the migration **and** on
every open — the pattern already used in this file — so a phone whose version ran ahead of
the migration during development still heals itself.

---

## Files changed

**New (7)**
- `lib/models/speed_dial_entry.dart`
- `lib/repositories/speed_dial_repository.dart`
- `lib/screens/speed_dial_screen.dart` (also holds `assignSpeedDialSlot`, the assign flow
  shared by the keypad and the settings screen)
- `test/speed_dial_repository_test.dart`
- `test/preferred_sim_resolution_test.dart`
- `test/db_speed_dial_and_sim_columns_test.dart`
- `test/dialer_speed_dial_keypad_test.dart` (not in the plan — added while checking the
  keypad's layout, see below)

**Edited (16)**
- `lib/database/database_helper.dart` — schema, v30 migration, two self-healing helpers.
- `lib/models/contact.dart` — `preferredSimId`, `preferredSimLabel`.
- `lib/repositories/contact_repository.dart` — `preferredSimId()`, `setPreferredSim()`, and
  freeing speed-dial keys when a contact becomes secret.
- `lib/services/sim_service.dart` — `resolve()` and `resolveForCall()`.
- `lib/services/sync_bundle_service.dart` — `speed_dial` in full backups only, as an optional
  managed table.
- `lib/widgets/call_lifecycle_mixin.dart` — `_resolveSim(contactId)`.
- `lib/widgets/sim_picker_sheet.dart` — `preselectedId` / `preselectedNote`.
- `lib/screens/dialer_screen.dart` — assignments, long-press handling, the marker dot.
- `lib/screens/add_edit_contact_screen.dart` — "Preferred SIM" section.
- `lib/screens/contact_detail_screen.dart` — preferred-SIM row.
- `lib/screens/settings_screen.dart` — Speed Dial entry.
- `lib/screens/features_screen.dart` — both claims restored.
- `lib/screens/help/call_management_help_screen.dart` — how-to for both.
- `lib/main.dart` — notification call-back honours the preference.
- `test/features_screen_test.dart` — guard list and presence list.
- `test/backup_service_test.dart` — two new tests.

---

## Tests

New coverage:

- **`speed_dial_repository_test.dart`** (8 tests) — assign and read back with the joined
  name; a second assign replaces the first; clear; a secret contact is refused; a key stops
  showing when its contact is made secret; deleting the contact frees the key; slots outside
  1–9 and blank numbers are refused; a bare number is labelled by itself.
- **`preferred_sim_resolution_test.dart`** (6 tests) — the full precedence, including a
  preference for a SIM that is no longer in the phone, and both ids stale.
- **`db_speed_dial_and_sim_columns_test.dart`** (4 tests) — the migration against a pre-v30
  database, re-running it as a no-op, the cascade, and the one-number-per-key rule.
- **`dialer_speed_dial_keypad_test.dart`** (3 tests) — the keypad lays out with a key
  assigned; a long press does nothing while a number is typed; a long press on an empty key
  opens the picker.
- **`backup_service_test.dart`** — keys travel in a backup and come back with their contact
  link; a backup made before the feature existed leaves the phone's keys alone.

Results: `flutter analyze` — no issues. `flutter test` — **515 passed, 1 skipped**.

---

## Two notes

1. **A pre-existing layout limit, not caused by this change.** At a 320-logical-pixel screen
   width the keypad's letter legend row ("PQRS" with its letter spacing) is about 7 pixels
   too wide. This was checked against the unmodified dialer and overflows by the same 7
   pixels there, so it predates speed dial — the marker dot is an overlay and adds nothing to
   a key's width. The keypad test therefore runs at 360×740, about the narrowest width
   Android phones actually ship with. The 320 px legend width is left as it was; narrowing
   the legend is a separate change.

2. **The keypad widget test was not in the plan.** It was added while confirming the marker
   dot could not push a key's contents out of shape, and it is what turned up the note above.
