# docs/features.md now lists only implemented features

Implements `plans/20260816_204004_features-doc-implemented-only.md`.

## Why

`docs/features.md` is meant to be a trustworthy list of what the app really does.
An audit of the whole file against the code found one feature that was claimed
but is not used by the app at all, plus two small accuracy problems.

## What changed (documentation only — no code touched)

**`docs/features.md`**

1. **Removed the scheduled-notification bullet from section 13** (Native Android
   platform features). It described `NotificationSchedulerManager.kt` /
   `ScheduledNotificationReceiver.kt` / `NotificationSchedulerService` as a
   working feature that fires timed reminder notifications. No Dart file in
   `lib/` imports or calls `NotificationSchedulerService` — the only hit for that
   name in the whole project is the file's own header comment. The native side is
   complete and reachable over the method channel, but nothing ever calls it, so
   no scheduled notification can fire.

2. **Added a "Known gaps" bullet** for scheduled reminder notifications, saying
   plainly that none are scheduled or fired today, that a saved follow-up
   reminder is stored only, and that the scheduler plumbing exists but is unused
   groundwork. This matches what `docs/known-gaps.md` already says.

3. **Fixed the roadmap "nudge notifications" bullet.** It used to say alerting
   "is backed by `NotificationSchedulerService`", which read as if it worked. It
   now says the scoring is implemented but nothing alerts the user, and points at
   the new Known gaps entry.

4. **Added the missing help page** to the section 12 Help list:
   `relationship_categories_help_screen.dart` was not listed.

5. **Updated the "accurate as of" date** at the top from August 10 to
   August 16, 2026.

## What was checked and left alone

Everything else in the file was verified against the code and kept. Spot checks
that matched exactly: conference merge / hold / swap / DTMF / proximity blanking
/ STIR-SHAKEN flag; the 30-day streak window; audit prune at 90 days and 5000
rows; Smart Redial delays of 1/3/5/10/15/30 minutes; the 160-char quick-reply
limit; 200 natively parked blocked calls; the T9 script set; the three bundled
fonts; `allowBackup="false"`; no `proguard-rules.pro`; and no in-app "delete all
data". Every service named in the doc (AirQR, QR safety, cloud backup, online
provider sync, quiet hours, reach windows, caller context, ephemeral contacts,
connected apps, call-log import) is reached from a real screen.
