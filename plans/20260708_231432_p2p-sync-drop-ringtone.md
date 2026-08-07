# Drop per-contact ringtone from P2P sync

**Status:** completed

## Issue

The P2P sync currently carries each contact's `ringtone_path` in the payload.
On export the path is left as-is; on the receiver `_resolveRingtone` keeps the
sender's path only if a file happens to already exist at that same path on the
receiving phone. Ringtone paths point at device-local files, so this almost
never resolves and adds no value. We do not want to sync ringtones at all.

## Files to change

- `lib/services/sync_bundle_service.dart` — stop sending and stop applying the
  per-contact `ringtone_path`.

## Plan for the fix

In `lib/services/sync_bundle_service.dart`:

1. In `exportBundle` (contacts staging loop, around line 199): set
   `row['ringtone_path'] = null` so no ringtone path travels in the payload.
   Update the comment to say ringtones are intentionally not synced.

2. In `applyBundle` (new-contact insert, around line 378): replace
   `..['ringtone_path'] = _resolveRingtone(raw['ringtone_path'])` with
   `..['ringtone_path'] = null`. This also stays correct if an older payload
   still carried a ringtone path.

3. Remove the now-unused `_resolveRingtone` method (lines ~593-602).

## Out of scope

- The global `ringtone_volume_percent` setting stays in `_syncedSettingKeys`.
  It is a device-neutral volume preference, not a per-contact ringtone, so it is
  not part of "syncing ringtones."
- SIM-keyed `per_sim_ringtones` are already excluded from sync.

## Tests

No existing test asserts ringtone sync behavior (`test/p2p_bundle_test.dart`
has none). `flutter analyze` after the change to confirm no dead references.
