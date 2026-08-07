# Drop per-contact ringtone from P2P sync

Implements `plans/20260708_231432_p2p-sync-drop-ringtone.md`.

## What changed

`lib/services/sync_bundle_service.dart`:

- `exportBundle`: the contacts staging loop now sets `ringtone_path = null`, so
  no per-contact ringtone path is written into the sync payload. Updated the
  comment to say ringtones are intentionally not synced.
- `applyBundle`: the new-contact insert now sets `ringtone_path = null` instead
  of calling `_resolveRingtone`. This also clears any ringtone path an older
  payload may still carry.
- Removed the now-unused `_resolveRingtone` helper method.

## Not changed

- `ringtone_volume_percent` stays in `_syncedSettingKeys` — it is a
  device-neutral volume preference, not a per-contact ringtone.
- SIM-keyed `per_sim_ringtones` were already excluded from sync.

## Verification

`flutter analyze lib/services/sync_bundle_service.dart` — no issues. No tests
asserted ringtone sync behavior, so none needed updating.
