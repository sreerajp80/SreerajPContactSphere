# Make docs/features.md list only implemented features

**Status:** completed

## Files to be changed

- `docs/features.md` (documentation only — no code changes)

## What I checked

I read `docs/features.md` end to end and checked each claim against the code
(`lib/`, `android/app/src/main/kotlin/`, `AndroidManifest.xml`, `pubspec.yaml`).

Almost everything in the file is real. I verified, among others:

- Conference merge, hold/swap, DTMF, proximity blanking, STIR/SHAKEN flag —
  all present in `TelecomService` / `CallRegistry.kt` / `ContactSphereInCallService.kt`.
- Streak badge (30-day window), audit prune (90 days / 5000 rows), Smart Redial
  delays (1/3/5/10/15/30), quick-reply 160-char limit, 200 parked blocked calls —
  the numbers in the doc match the code.
- AirQR, QR safety inspection, cloud backup, online provider sync, quiet hours,
  reach windows, caller context, ephemeral contacts, connected apps, call-log
  import — every one of these services is reached from a real screen.
- `allowBackup="false"`, no `proguard-rules.pro`, no in-app "delete all data" —
  so the "Known gaps" section is still correct.

## The issue

One feature is claimed but is **not actually used by the app**:

**Scheduled reminder notifications.**
`lib/services/notification_scheduler_service.dart` exists, and the native side
(`NotificationSchedulerManager.kt`, `ScheduledNotificationReceiver.kt`, the boot
hook in `EmergencyBootReceiver.kt`, the method-channel handlers in
`MainActivity.kt`) is complete. But **no Dart file anywhere imports or calls
`NotificationSchedulerService`** — I grepped the whole of `lib/`; the only hit is
the file's own header comment. So it is dormant plumbing, not a working feature.

`docs/known-gaps.md` already says the same thing: follow-up reminders are
"persisted-only" and "nothing schedules notifications for them yet".

`docs/features.md` currently contradicts that in two places:

1. Section 13 (Native Android platform features), last bullet — describes it as a
   working feature that fires "timed reminder notifications".
2. The Roadmap section, "nudge notifications" bullet — the parenthetical says
   alerting "is backed by `NotificationSchedulerService`", which reads as if it
   works today.

Two smaller accuracy problems:

3. The Help list in section 12 omits one help page that exists:
   `relationship_categories_help_screen.dart`.
4. The "accurate as of" date at the top still says August 10, 2026.

## The plan for the fix

1. **Section 13** — move the scheduled-notification bullet out of the list of
   working features. Replace it with a short, honest line under a new
   "Built but not yet used by any feature" note (or drop it from section 13 and
   record it once in "Known gaps"), saying: the native exact-alarm scheduler and
   its Dart wrapper exist and survive reboot, but no feature calls them yet, so
   no scheduled notification ever fires today.
2. **Roadmap bullet** — remove the misleading "is backed by
   `NotificationSchedulerService`" wording. Say plainly that the scoring is
   implemented but nothing notifies the user, and that the scheduler plumbing is
   unused.
3. **Known gaps section** — add one bullet for scheduled reminder notifications,
   matching `docs/known-gaps.md`.
4. **Section 12 Help list** — add the relationship-categories help page.
5. **Header date** — update to August 16, 2026.

No other text in the file is changed, because everything else checks out against
the code.

## After the change

Write a change log to `change_log/` referencing this plan.
