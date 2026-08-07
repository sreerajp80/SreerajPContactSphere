# Plan — Per-group ringtone (make it real, not schema-only)

**Status:** completed

## The issue

The `groups` table has had a `ringtone_path` column since the first schema, but nothing uses
it: there is no UI to set it, and the ringing pipeline never looks at it. Only the per-contact
ringtone actually plays (via the native ringtone mirror + the in-call late correction).

## How ringing works today (for context)

1. **Mirror (first note):** `ContactRepository.ringtoneMirrorEntries()` builds a map of
   trailing-7-digit number → tone for every contact with a custom tone. It is pushed to native
   SharedPreferences (`setRingtoneMirror`). When a call arrives, `IncomingCallRinger.start()`
   resolves synchronously: contact tone → SIM tone → system default.
2. **Late correction:** `in_call_screen.dart` looks up the caller; if the contact has
   `ringtonePath`, it pushes it with `setIncomingRingtone(source: 'contact')`. Tiers stop a
   SIM push from overriding a contact tone (default < SIM < contact).

## Chosen approach

Treat the group tone as a **fallback inside the contact tier**: a contact's effective tone is
their own tone, else the tone of one of their groups. Precedence becomes:

> contact tone > group tone > SIM tone > system default

This needs **no native (Kotlin) changes at all** — the mirror map and the late correction
simply carry the effective tone. If a contact is in several groups that have tones, the group
first by name (then lowest id) wins, deterministically.

## Files to change

1. **`lib/database/database_helper.dart`**
   - Add `ringtone_label TEXT` to the `groups` CREATE TABLE (for display, same as contacts).
   - Bump DB version 13 → 14; add a v13→v14 `_onUpgrade` block:
     `ALTER TABLE groups ADD COLUMN ringtone_label TEXT`.

2. **`lib/models/group.dart`**
   - Add `ringtoneLabel` field + `toMap` / `fromMap` mappings (`ringtone_label`).

3. **`lib/repositories/group_repository.dart`**
   - New `setGroupRingtone(int id, {String? path, String? label})` — writes both columns
     (nulls clear the tone).
   - New `groupRingtoneForContact(int contactId)` — the deterministic group tone for a
     contact (name ASC, id ASC, first non-empty), or null. Used by the in-call late lookup.
   - After any write that can change effective tones — `setGroupRingtone`, `deleteGroup`,
     `addContactToGroup`, `removeContactFromGroup` — call
     `ContactRepository().pushRingtoneMirror()` (already debounced/static, so this is cheap).

4. **`lib/repositories/contact_repository.dart`** *(note: this file has two intentional NUL
   bytes — edit carefully, do not "fix" the encoding)*
   - Extend the `ringtoneMirrorEntries()` SQL so the tone is
     `COALESCE(contact tone, best group tone)` via a correlated subquery on
     `contact_groups`/`groups` (same name-ASC/id-ASC pick), keeping the trailing-digit keying
     unchanged.

5. **`lib/screens/in_call_screen.dart`**
   - In `_resolveName`, when the matched contact has no own `ringtonePath`, ask
     `GroupRepository.groupRingtoneForContact(...)` and, if found and still ringing, push it
     with `setIncomingRingtone(source: 'contact')` (same tier as a contact tone, so it beats
     a racing SIM push, and a real contact tone found first still wins because
     `_contactToneApplied` is set before the push).

6. **`lib/screens/groups_screen.dart`**
   - Show the tone in the tile subtitle when set (e.g. `3 contact(s) · Chime`).
   - Replace the trailing delete icon with a `PopupMenuButton` (⋮): **Ringtone…**,
     **Clear ringtone** (only when one is set), **Delete**. This keeps the screen's plain
     Material style (our own design, not a clone of anyone's).
   - **Ringtone…** opens the same two-source chooser idea as the contact editor: a small
     bottom sheet with "Phone ringtone" (system picker via `TelecomService.pickRingtone`,
     which previews tones itself) and "Audio file" (`file_selector`, label from
     `p.basename`). No separate in-app preview button on this screen.

7. **`docs/known-gaps.md`**
   - Remove/replace the "group ringtone is schema-only" note.

8. **Tests — new `test/group_ringtone_test.dart`** (sqflite ffi, like the other repo tests)
   - v13→v14 migration keeps existing group rows.
   - `ringtoneMirrorEntries()`: contact tone wins; group tone fills in when the contact has
     none; multi-group pick is deterministic; contacts with no tone anywhere are absent.
   - `groupRingtoneForContact()` returns the same pick.

## Out of scope

- No Kotlin/native changes (tiers, mirror keys, ringer all unchanged).
- CSV/vCard export of group tones (device-local paths, same as contact tones).
- No new dependencies.

## Verification

- `flutter analyze` and `flutter test` clean.
- On device: contact in a group with a tone (and no own tone) rings the group tone from the
  first note; a contact with their own tone still gets their own; SIM tone still applies to
  group-less callers.
