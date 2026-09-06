# Speed Dial and Per-Contact Preferred SIM

**Status:** completed

Build the two features that the Features screen used to claim but the app never had. The
false claims were removed in `plans/20260906_055448_features-screen-accuracy.md`; this plan
builds the real thing and puts the claims back.

---

## The issue

1. **No speed dial.** Long-pressing a keypad digit does nothing (except `0`, which types
   `+`). There is no way to call a saved person with one press.
2. **No per-contact preferred SIM.** On a dual-SIM phone the app has only a *global*
   default SIM plus an "Ask before each call" switch. A person you always call on SIM 2
   has to be chosen by hand every time, or the wrong SIM is used.

Both were advertised on the Features screen and had to be deleted, and
`test/features_screen_test.dart` now has a guard test that fails if the words come back.
That guard has to be relaxed as part of this work.

---

## Decisions already made

| Question | Decision |
|---|---|
| Contact SIM vs "Ask before each call" | The chooser still appears when the setting is on. The contact's SIM is **pre-selected** in it, one tap away. When the setting is off, the contact SIM is used silently. |
| Speed dial slots | Keys **1–9** (nine slots). Key `0` keeps its `+` long-press. |
| Filling a slot | Long-press an **empty** key opens a contact picker and assigns it. Also editable from a new Settings screen. |
| Long-press a **filled** key | Dials at once, showing whose number it is. |

Extra rule (not asked, stated here so it is visible before approval): speed dial only dials
when the dialer input box is **empty**. While you are typing a number, a long-press does
nothing. This is stock dialer behaviour and stops a mis-press turning into a wrong call
mid-typing.

---

## Part 1 — Speed dial

### Storage

A new `speed_dial` table in the encrypted database, not SharedPreferences, because the rows
hold a contact id and a phone number.

```sql
CREATE TABLE speed_dial (
  slot INTEGER PRIMARY KEY,           -- 1..9
  contact_id INTEGER,
  phone_number TEXT NOT NULL,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
)
```

`ON DELETE CASCADE` means deleting a contact frees its slot automatically — no orphan rows,
per the project's defensive-data rule.

### Secret contacts

Secret contacts are **never** assignable to a speed-dial key. The picker already hides them
(`searchSummaries` defaults to `includeSecret: false`), and the repository will also refuse a
contact whose `is_secret = 1`. Reason: a speed-dial key would show a hidden person's name on
the keypad and dial them without any unlock.

### Files

| File | Change |
|---|---|
| `lib/database/database_helper.dart` | Add the table to `_onCreate`; bump DB version 29 → 30; add an `oldVersion < 30` migration; add `_ensureSpeedDialTable(db)` to `_onOpen` so a dev build that bumped the version early still self-heals (the pattern already used for other columns). |
| `lib/models/speed_dial_entry.dart` | **New.** `slot`, `contactId`, `phoneNumber`, plus display-only `displayName` and `photoPath` filled by the repository's join. `fromMap` / `toMap`. |
| `lib/repositories/speed_dial_repository.dart` | **New.** `all()` (nine slots, joined to contact name/photo, secret rows filtered out), `forSlot(int)`, `assign(slot, contactId, number)`, `clear(slot)`. All writes in a transaction. |
| `lib/screens/dialer_screen.dart` | Load the assignments on init and refresh after a change. `onLongPress` for keys `1`–`9`: input empty **and** slot filled → dial through the existing `startCall`; input empty and slot empty → open the assign flow; input not empty → do nothing. Add a small accent dot on assigned keys so they are discoverable. |
| `lib/screens/speed_dial_screen.dart` | **New.** Settings screen listing slots 1–9 with name, number and label; tap to assign or change, swipe/menu to clear. |
| `lib/screens/settings_screen.dart` | New card: "Speed Dial — call a saved person by holding a keypad key". |
| `lib/services/sync_bundle_service.dart` | Carry `speed_dial` in a full backup. It goes in `_optionalManagedTables`, not `_allManagedTables`, so restoring an **older** backup that has no speed-dial data does not wipe the assignments already on the phone (exactly the reason that list exists for the emergency card). Not added to any peer-to-peer share category — slot numbers are personal to one phone. |

### Assign flow

Long-press an empty key → `showContactSearchPickerSheet(requirePhone: true)` → if the picked
contact has more than one number, `showNumberPickerSheet` to choose which → write the row →
short confirmation.

---

## Part 2 — Per-contact preferred SIM

### Storage

Two new columns on `contacts`:

```sql
preferred_sim_id TEXT       -- the SIM's phoneAccountId, NULL = no preference
preferred_sim_label TEXT    -- label at the time it was set, for display only
```

The label is stored only so the contact screen can still say something sensible when the SIM
list has not loaded yet. The **id** is always what routes the call, and a stored id that no
longer matches a SIM in the phone is ignored and falls back to the global default — the same
tolerance `SimService.defaultSim` already has.

App-only field: like `card_photo_path`, it is not written to the device address book and not
part of vCard/CSV export.

### Precedence

`SimService` gains one pure, testable function:

```dart
String? resolveSimId({String? contactPreferredId, String? defaultSimId, required List<SimAccount> sims})
```

Order: **contact preference** (if it still matches a live SIM) → **global default** → `null`
(let Android choose).

`CallLifecycleMixin._resolveSim` becomes `_resolveSim(int? contactId)`:

- read the contact's `preferred_sim_id` (skipped when `contactId` is null);
- if "Ask before each call" is on and there are 2+ SIMs → show the picker with the resolved
  SIM **pre-selected**;
- otherwise use the resolved SIM directly.

### Files

| File | Change |
|---|---|
| `lib/database/database_helper.dart` | Both columns in `_onCreate`; same v30 migration; `_ensurePreferredSimColumns(db)` in `_onOpen`. |
| `lib/models/contact.dart` | `preferredSimId`, `preferredSimLabel` fields, constructor args, `toMap`, `fromMap`. |
| `lib/repositories/contact_repository.dart` | Carry the columns through insert/update (they ride on `toMap`, so mainly a check); add `preferredSimId(int contactId)` for the fast lookup on the call path. |
| `lib/services/sim_service.dart` | Add `resolveSimId(...)` above, and a `Future<SimAccount?> resolveForCall({int? contactId, String? defaultSimId})` convenience used by the mixin. |
| `lib/widgets/call_lifecycle_mixin.dart` | `_resolveSim(contactId)` as described; pass `contactId` at its one call site in `startCall`. |
| `lib/widgets/sim_picker_sheet.dart` | New optional `preselectedId`; that tile is marked as selected and labelled (e.g. "Preferred for this contact"). Behaviour unchanged when null. |
| `lib/screens/add_edit_contact_screen.dart` | New "Preferred SIM" section, shown **only** when the phone reports 2+ SIMs. Options: "Use default SIM" plus one row per SIM. |
| `lib/screens/contact_detail_screen.dart` | Show the preferred SIM as a small row when set, so it is visible without opening the editor. |
| `lib/main.dart` | `_placeCallback` (the "Call back" from a missed-call notification) currently reads only the global default. Make it resolve the contact by number first so the preference is honoured there too. |

---

## Part 3 — Put the claims back

| File | Change |
|---|---|
| `lib/screens/features_screen.dart` | Restore "Speed dial" on the Smart Dialer card and "Per-contact SIM" on the SIM card, worded to match what is actually built (keys 1–9; preference pre-selected in the chooser). |
| `test/features_screen_test.dart` | Remove `speed dial` and `per-contact default sim` from the "does not advertise" guard list. The other eight stay. Add both to the "documented features are present" test. |
| `lib/screens/help/call_management_help_screen.dart` | Short how-to for both: holding a key to call, and setting a person's SIM. |

---

## Tests

New files:

- `test/speed_dial_repository_test.dart` — in-memory SQLite (`sqflite_common_ffi`): assign,
  overwrite a slot, clear, reject a secret contact, and confirm deleting a contact frees its
  slot through the cascade.
- `test/preferred_sim_resolution_test.dart` — pure unit tests of `resolveSimId`: contact
  preference wins; a stale id falls back to the default; no preference and no default gives
  `null`.
- `test/db_speed_dial_and_sim_columns_test.dart` — opens a database at the old version, runs
  the upgrade, and checks the table and both columns exist (mirrors the existing
  `db_formal_name_column_test.dart`).

Updated:

- `test/features_screen_test.dart` — guard list and presence list, as above.
- `test/backup_service_test.dart` — a restore from a bundle with no `speed_dial` key must
  leave existing assignments alone.

Per the note in memory, the SQLite-backed test files are run **one file per `flutter test`
invocation** to avoid the native-assets double-copy crash. `flutter analyze` must stay at
zero warnings and the full suite must pass.

---

## Risks and how they are handled

| Risk | Handling |
|---|---|
| DB version bump breaks an existing phone | Every schema step is existence-checked in `_onOpen` (`PRAGMA table_info` / `sqlite_master`), the pattern already proven in this file, so it heals a DB whose version ran ahead of the migration. |
| Accidental calls from a stray long-press | Speed dial only fires when the input box is empty; assigned keys are visually marked. |
| A secret contact leaking onto the keypad | Blocked in both the picker and the repository. |
| Restore wiping speed dial | `speed_dial` is an *optional* managed table, so an old backup without it leaves the phone's assignments untouched. |
| A removed SIM leaving a contact uncallable | An unmatched `preferred_sim_id` is ignored and the global default is used. |

---

## Files changed — summary

**New (6)**
- `lib/models/speed_dial_entry.dart`
- `lib/repositories/speed_dial_repository.dart`
- `lib/screens/speed_dial_screen.dart`
- `test/speed_dial_repository_test.dart`
- `test/preferred_sim_resolution_test.dart`
- `test/db_speed_dial_and_sim_columns_test.dart`

**Edited (16)**
- `lib/database/database_helper.dart`
- `lib/models/contact.dart`
- `lib/repositories/contact_repository.dart`
- `lib/services/sim_service.dart`
- `lib/services/sync_bundle_service.dart`
- `lib/widgets/call_lifecycle_mixin.dart`
- `lib/widgets/sim_picker_sheet.dart`
- `lib/screens/dialer_screen.dart`
- `lib/screens/add_edit_contact_screen.dart`
- `lib/screens/contact_detail_screen.dart`
- `lib/screens/settings_screen.dart`
- `lib/screens/features_screen.dart`
- `lib/screens/help/call_management_help_screen.dart`
- `lib/main.dart`
- `test/features_screen_test.dart`
- `test/backup_service_test.dart`
