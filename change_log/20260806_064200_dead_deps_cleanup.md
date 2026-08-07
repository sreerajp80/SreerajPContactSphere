# Dead dependency cleanup + reminder hint

**Plan**: (skipped per user request — trivial fix from the feature audit)

## What changed

### 1. Removed dead dependencies from `pubspec.yaml`
- **`geolocator: ^14.0.2`** — declared but never imported by any Dart file.
  The pre-call timezone lookup uses the `timezone` package with an offline
  city map, not GPS. Removing avoids unnecessary APK weight and potential
  location-permission confusion.
- **`flutter_ringtone_player: ^4.0.0+4`** — declared but never imported.
  All ringtone playback (incoming calls, in-app preview) is handled natively
  via `IncomingCallRinger.kt` and `MainActivity.previewRingtone`.

### 2. Added UI hint on the post-call feedback follow-up reminder toggle
- File: `lib/widgets/post_call_feedback_sheet.dart`
- The `SwitchListTile` for "Add a follow-up reminder" now has a `subtitle`:
  *"Saved for reference — notifications coming soon"*
- This sets expectations: the reminder is persisted to the `reminders` table
  but no notification scheduler is wired in yet.

### 3. Updated `docs/known-gaps.md`
- Added a **"Resolved (2026-08-06 dead dependency cleanup)"** section
  documenting the `geolocator` and `flutter_ringtone_player` removal.
- Updated the **"Still not integrated"** reminders entry to note the new
  UI hint on the post-call feedback sheet.

## Files changed
- `pubspec.yaml` — 2 lines removed
- `lib/widgets/post_call_feedback_sheet.dart` — 7 lines added (subtitle)
- `docs/known-gaps.md` — 12 lines added (new section + updated section)
