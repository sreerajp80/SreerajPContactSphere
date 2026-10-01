# Item 2, phase 2e — secondary screens and Settings sub-screens moved to ARB

**Plan:** `plans/20260921_064200_item2-arb-string-externalization.md` (phase 2e of 2a–2g)
**Status:** done. Phases 2f (Help articles) and 2g (`app_config.json` and About) are not started
and need approval before any work begins.

---

## What this phase did

Moved every user-visible string in the phase 2e screens into the three ARB files, with Malayalam
and Sanskrit translations that use the approved glossary words.

The plan names this phase "Features, sync, backup, groups, tags, emergency info, duplicates,
audit". When 2e was approved, it also took in the Settings sub-screens that the 2d change log
listed as "reached from Settings but not in this phase", so a user who moves through Settings in
Malayalam or Sanskrit no longer drops into English.

**Part A — plan scope**

| Screen | File |
|---|---|
| Features | `lib/screens/features_screen.dart` |
| Emergency info | `lib/screens/emergency_info_screen.dart` |
| Groups | `lib/screens/groups_screen.dart` |
| Tag cloud | `lib/screens/tag_cloud_screen.dart` |
| Contacts with a tag | `lib/screens/tag_contacts_screen.dart` |
| Duplicates | `lib/screens/duplicates_screen.dart` |
| Audit log | `lib/screens/audit_log_screen.dart` |
| Audit entry details | `lib/screens/audit_entry_detail_screen.dart` |
| Backup & Restore | `lib/screens/backup/backup_restore_screen.dart` |
| Sync to another device (home, send, receive, shared views) | `lib/screens/sync/sync_home_screen.dart`, `send_to_device_screen.dart`, `receive_from_device_screen.dart`, `sync_views.dart` |

**Part B — Settings sub-screens**

| Screen | File |
|---|---|
| Security | `lib/screens/security_screen.dart` |
| App lock | `lib/screens/app_lock_screen.dart` |
| App PIN setup | `lib/screens/app_pin_setup_screen.dart` |
| Appearance | `lib/screens/appearance_screen.dart` |
| Speed dial | `lib/screens/speed_dial_screen.dart` |
| Default country | `lib/screens/default_country_screen.dart` |
| Permissions | `lib/screens/permissions_screen.dart` |
| SIM preferences | `lib/screens/sim_preferences_screen.dart` |
| Per-SIM ringtones | `lib/screens/per_sim_ringtone_screen.dart` |
| Volume & vibration | `lib/screens/ringtone_volume_vibration_screen.dart` |
| Relationship quiet hours | `lib/screens/relationship_quiet_hours_screen.dart` |
| Quick replies | `lib/screens/quick_replies_screen.dart` |
| Relationship names | `lib/screens/relationship_names_screen.dart` |
| Contact counts & search index | `lib/screens/contact_index_health_screen.dart` |
| Secret contacts & export | `lib/screens/secret_contacts_export_screen.dart` |
| Spoken caller announcement | `lib/screens/spoken_announcements_screen.dart` |
| Post-call options | `lib/screens/post_call_feedback_screen.dart` |

- **660 new keys**, so each ARB file now holds **1376 keys**. The three files have the same key
  set. The Features catalog alone is 235 keys (8 categories, each feature's title, description
  and highlights).
- A search of these screens finds no English UI text left, apart from the items under "Left in
  English on purpose".

### Screens still in English

These are not in 2e and stay English until a later phase: the relationship screen, relation
status, Bluetooth receive, QR scan and business-card scan screens. Help articles are phase 2f;
About is phase 2g.

---

## Files changed

| File | Change |
|---|---|
| `lib/l10n/app_en.arb`, `app_ml.arb`, `app_sa.arb` | +660 keys each. |
| `lib/l10n/app_localizations*.dart` | Regenerated with `flutter gen-l10n`. |
| `lib/l10n/audit_labels.dart` | **New.** Display text for audit actions, sources, changed fields, Yes/No values and undo descriptions. |
| `lib/l10n/permission_labels.dart` | **New.** Translated title and reason for each row of the Permissions screen. |
| `lib/l10n/relationship_labels.dart` | **New.** Translated names of the seven relationship categories. |
| The 30 screen files above | All user-visible strings now come from `AppLocalizations`. |
| `test/features_screen_test.dart` | Reads the feature text from `app_en.arb`; both widget tests now load the localization delegates. |
| `test/l10n/phase2e_screens_l10n_test.dart` | **New.** Tests described under Verification. |
| `test/l10n/label_length_test.dart` | A phase 2e block of 37 English keys added to `_englishOverBudget`; the fixed app name is no longer counted (see "Over-budget labels"). |
| `plans/20260921_064200_item2-arb-string-externalization.md` | Status line updated. |

Each converted screen was run through `dart format`, so some also carry small formatting changes
on lines this phase did not otherwise touch.

---

## Decisions made along the way

### Stored and signed text stays English; only the display is translated

- **Audit log.** Each entry's summary is saved in the database and is part of the SHA-256 hash
  chain, so changing its language would break the chain. The summary stays as saved. The words
  around it (action, source, changed-field names, "Yes"/"No", undo text) are translated at display
  time by `lib/l10n/audit_labels.dart`. The model `lib/models/audit_entry.dart` is unchanged.
- **Emergency info.** The form's field labels are translated. The preview keeps the model's
  English labels, because it shows exactly what the lock-screen card service generates.

### Catalogues that must stay `const` get their text from the language layer

`lib/core/constants/app_permissions.dart` mirrors the Android manifest and is a `const` list, so
it cannot read the app's language. The Permissions screen now shows `permissionTitle` and
`permissionReason` from `lib/l10n/permission_labels.dart`, matched by the row's English title.
An unknown row falls back to the catalogue's English. The same approach gives the relationship
categories (`lib/models/relationship.dart`) translated names; the later relationship-screen phase
can reuse `relationshipCategoryLabel`.

The Features screen's catalogue was a `const` list inside the screen. It is now built from
`AppLocalizations` each time the screen builds.

### Messages built from parts are now whole messages

For example, "Sent 120 contacts, 4 groups and 300 call-log entries", "Added 12 new contacts (3
already on this phone were kept)", "Signed Audit Log exported successfully (42 entries verified)"
and "3 contact(s) have stale search keys" are each one key with typed values. The last one is now
a real plural ("1 contact has…" / "3 contacts have…").

### No context lookups after `await`

Snackbar messages shown after an `await` either use a `_say` helper that checks `mounted` before
it looks up the translation, or take the translations once before the `await` (Backup & Restore,
secret contacts export).

### Reused keys

Where an existing key already had the same English, it was reused (for example `actionCancel`,
`titleSecurity`, `titleAuditLog`, `errorCouldNotPickRingtone`, `emptyNoCountriesMatch`). Two new
keys were renamed because the name was already taken by different text: the relationship-name
hint is `hintRelationshipNameExample` ("e.g. Mentor"; the existing `hintRelationshipExample` is
"e.g. Father").

---

## Left in English on purpose

| What | Why |
|---|---|
| Audit entry summaries | Saved and hash-chained; see above. |
| The emergency card preview | Shows exactly what the lock-screen card service writes. |
| Error text coming from services (`BackupException`, sync service progress and error messages) | Produced outside the screens; shown after a translated prefix such as "Backup failed:". |
| Saved relationship names and quick replies | User data, which the user can edit. |
| The two sample-voice chips "Amma (English)" and "അമ്മ (Malayalam)" | They name the test voice and its language, and fill the name field with that sample. |
| "SIM 1", "SIM 2" | "SIM" is kept as a technical word in all three languages. |
| Technical names: SHA-256, VCF, BLE, P2P, Wi-Fi, ICE, QR, PIN, `neverForLocation`, Smart Redial, the app name | Formats, protocols, flags, feature and product names. |

---

## Over-budget labels

- **English:** 37 existing English labels in these screens are longer than the §8.6 limit of 20
  characters. They are listed in `test/l10n/label_length_test.dart` in a separate phase 2e block.
  The longest are "Allowed Relationships & Categories" (34), "Full Sync (for a brand-new phone)"
  (33), "Foreground Call Service & Ringing" (33), "Include secret contacts in export" (33) and
  "Not seeing it on the lock screen?" (33). Whether to shorten them is a copy decision for the
  owner.
- **The app name.** Two headings contain the app name ("SreerajP Contacts Sphere is locked",
  "SreerajP Contacts Sphere Features"). The name stays in Latin letters in every language and is
  24 characters on its own, so no translation can fit. The length test now removes the name before
  counting, the same way it removes `{placeholders}`. The rest of each heading fits.
- **Malayalam:** one label was over 22 characters and was shortened:
  `labelIncludeSecretInExport` is now "രഹസ്യ വിലാസവിവരങ്ങളും ചേർക്കുക" ("add the secret contacts
  too"). Every other Malayalam and Sanskrit label fits.

---

## Sanskrit gate

The §8.5.1 gate flagged four Sanskrit strings during this phase. All were false positives from
substrings of correct Sanskrit words, the same kind as in earlier phases, and each word was
replaced:

| Key | Flagged | Now |
|---|---|---|
| `titleCouldNotReceive` | ग्रहीतुं (contains रही) | ग्रहणम् असफलम् |
| `descIndexHealthy` | शक्याः (contains क्या) | अन्वेषणीयाः |
| `featureC5F2Desc` | an earlier wording | WebDAV कोशे |
| `featureC7F2Desc` | an earlier wording | तालपटले दृश्याः इति |

`titleCouldNotSend` was changed to "प्रेषणम् असफलम्" to match. The gate now finds nothing in
`lib/l10n/app_sa.arb` or `assets/config/app_config.json`.

---

## Verification

- `flutter analyze` → No issues found.
- `flutter test` → 660 passed, 2 skipped, 2 failed in the full run. The two failures were
  `test/contact_search_picker_sheet_test.dart` ("a contact is found by typing digits of its
  number") and `test/smart_redial_service_test.dart` ("rescheduling auto-redial for same phone
  number cancels previous active task"). Both pass when run again on their own (8 passed,
  1 skipped), so they look timing-sensitive under full-suite load rather than broken by this
  phase. The smart-redial test failed the same way once in an earlier phase.
- `test/l10n/phase2e_screens_l10n_test.dart` (new, 27 tests):
  - Appearance, Backup & Restore, Sync home, Post-call options, Volume & vibration and Quick
    replies, each in `en`, `ml` and `sa`, on a 360×740 screen at 1.3× text: the translated title
    and a row are shown, no English leaks into `ml`/`sa`, and nothing overflows. Screens that need
    the encrypted database or a platform plugin to build are left to the manual release
    checklist.
  - Unit tests for the three new helpers in all three languages: every audit action, source and
    field has a label; every permission row and every relationship category is translated in
    `ml` and `sa` and unchanged in `en`.
- Key parity: `app_en.arb`, `app_ml.arb` and `app_sa.arb` each have the same 1376 keys.
- Mixed-script check: no Malayalam letters in Sanskrit strings and no Devanagari in Malayalam
  strings, except the intended language names and script samples.

## Needs a fluent reader

As in earlier phases, the Malayalam and Sanskrit text was written to the approved glossary but has
not been read by a fluent speaker. The longest new texts to check first are the Features catalog,
the permission reasons, and the intro texts of Audit log, Sync and Backup & Restore.
