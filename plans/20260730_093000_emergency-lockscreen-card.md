# Emergency info card on the lock screen

**Status:** completed

## What the user asked for

An "emergency info" card, built from data the user keeps in ContactSphere (which lives in the
encrypted database), that a first responder or bystander can read on the lock screen **without
unlocking the phone**.

## What Android does and does not allow (important)

- Android has its own "Emergency information" page behind the lock screen's **Emergency** button.
  That page belongs to the system / OEM app. **A third-party app cannot write into it.** So we
  cannot put our card there.
- What we *can* do, and what this plan does:
  1. Post a **lock-screen notification** ("Emergency info — tap to view") that is marked public,
     so its text is visible on a locked phone.
  2. Tapping it opens a small **native Android activity** flagged `showWhenLocked`, which draws
     the card over the keyguard. No PIN, no unlock, no Flutter engine needed.
  3. From that card, each emergency contact has a **Call** button that dials straight away
     (the app already holds `CALL_PHONE`).
- Because the card must render while the phone is locked, it **cannot** read the SQLCipher
  database live in a reliable way (before first unlock the Keystore-backed key may be
  unavailable, and booting the Flutter engine on the keyguard is slow and fragile). So we do what
  the app already does for missed-call names: keep a small **native mirror** of *only* the fields
  the user explicitly chose to publish.

## The security trade-off (please read before approving)

The mirror is **plaintext** in the app's private `SharedPreferences`. That is unavoidable — data
readable on a locked screen is by definition not protected by the lock. This matches the existing,
already-approved missed-call name mirror pattern (see `docs/security.md`).

Controls that keep this safe:

- **Off by default.** Nothing is mirrored until the user turns the feature on.
- **Per-field opt-in.** Each line (blood group, allergies, medicines, notes, address, each
  emergency contact) has its own "show on lock screen" switch. Only switched-on fields ever leave
  the encrypted DB.
- **The master copy stays encrypted.** The full record lives in the SQLCipher DB as usual; the
  mirror is a derived subset.
- **Turning the feature off wipes the mirror and removes the notification** immediately.
- A plain-English warning is shown on the edit screen: *anyone holding your phone can read this.*
- Medical data is a new, more sensitive data class for this app, so `docs/security.md` gets a new
  inventory row and a short note.

## Files to change

### New — Dart

| File | Purpose |
|---|---|
| `lib/models/emergency_info.dart` | `EmergencyInfo` + `EmergencyContactEntry` models (fields, per-field `showOnLock` flags, JSON for the mirror). |
| `lib/repositories/emergency_info_repository.dart` | Load/save the single record + contact entries; build and push the mirror payload. |
| `lib/services/emergency_card_service.dart` | Method-channel wrapper: `setEmergencyMirror(json)`, `clearEmergencyMirror()`. |
| `lib/screens/emergency_info_screen.dart` | Edit screen: master switch, medical fields, emergency-contact picker, per-field lock-screen switches, live preview, warning banner. |
| `lib/screens/help/emergency_info_help_screen.dart` | Plain-English help page, matching the other help pages. |

### New — Android (Kotlin / resources)

| File | Purpose |
|---|---|
| `.../contact_sphere/EmergencyInfoActivity.kt` | Full-screen card, `showWhenLocked` + `turnScreenOn`, reads the mirror, renders rows, Call buttons. Native views only. |
| `.../contact_sphere/EmergencyCardNotifier.kt` | Creates the low-importance notification channel, posts / cancels the ongoing public lock-screen notification. |
| `.../contact_sphere/EmergencyBootReceiver.kt` | Re-posts the notification after reboot (`BOOT_COMPLETED`). |
| `android/app/src/main/res/layout/activity_emergency_info.xml` | Card layout (header, medical rows, contact rows). |
| `android/app/src/main/res/values/strings.xml` (add keys) | Labels used by the native card. |

### Modified

| File | Change |
|---|---|
| `lib/database/database_helper.dart` | Bump schema 21 → 22; create `emergency_info` (single row) and `emergency_contacts` tables; add the same in `_onUpgrade`, guarded by a table-existence check (per the earlier "column added but missing on device" lesson). |
| `lib/screens/settings_screen.dart` | New "Emergency info" tile → `EmergencyInfoScreen`. |
| `lib/state/app_settings.dart` | Hold the master on/off flag; re-push the mirror on app load so existing installs stay in sync. |
| `lib/screens/help/help_home_screen.dart` | Link the new help page. |
| `android/app/src/main/kotlin/.../MainActivity.kt` | New `emergency` method channel: `setEmergencyMirror`, `clearEmergencyMirror` → write prefs + post/cancel the notification. |
| `android/app/src/main/AndroidManifest.xml` | `RECEIVE_BOOT_COMPLETED` permission; register `EmergencyInfoActivity` (not exported, `showWhenLocked`, `excludeFromRecents`, `taskAffinity=""`, own task) and `EmergencyBootReceiver`. |
| `docs/security.md` | New sensitive-data row ("Emergency card mirror — plaintext by design, opt-in") plus a short subsection explaining the trade-off and the controls. |
| `docs/architecture.md` | Two lines: the new tables and the emergency mirror path. |

### New tests

| File | Covers |
|---|---|
| `test/emergency_info_test.dart` | Mirror payload building: off → empty payload; only fields with `showOnLock` set are included; contact entries keep name+number+relation only; JSON round-trip. |

## Data model

`emergency_info` (one row, `id = 1`):
`blood_group`, `allergies`, `medications`, `conditions`, `notes`, `address`, `organ_donor`,
one `show_*` integer per field, and `enabled` (master switch).

`emergency_contacts`:
`id`, `contact_id` (nullable link to `contacts`), `display_name`, `number`, `relation_label`,
`sort_order`, `show_on_lock`.

Linked contacts are snapshotted (name + chosen number) into the row when saved, so the mirror
never has to touch the encrypted contact tables.

## Mirror payload

A single JSON string in `SharedPreferences` file `contact_sphere_emergency`, key `card_json`:

```json
{ "v": 1,
  "owner": "Sreeraj P",
  "rows": [ {"label": "Blood group", "value": "B+"}, {"label": "Allergies", "value": "Penicillin"} ],
  "contacts": [ {"name": "Anita", "relation": "Wife", "number": "+91…"} ] }
```

Written only when the master switch is on; deleted (and the notification cancelled) when off.

## Order of work

1. Schema + models + repository (+ tests).
2. Method channel + prefs write + notification + native activity + manifest.
3. Flutter edit screen and settings/help wiring.
4. `flutter analyze`, `flutter test` (sqlite-backed test files run one per invocation), docs, change log.

## Open choices (tell me if you want them different)

- **Notification is always present** while the feature is on (ongoing, cannot be swiped away).
  Alternative: show it only while the screen is locked — more code, and it can flicker. I suggest
  ongoing.
- **Call buttons dial immediately** from the lock screen. Alternative: open the dialer pre-filled.
  I suggest dialing immediately — that is the point of an emergency card.
- The card shows **no photo** (keeps the native layout simple and the mirror small).

---

Do you approve this plan?
