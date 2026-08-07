# Change Log: Relationship-Aware Caller Context ("Why is this person calling?")

**Date & Time**: 2026-07-27 20:01:17  
**Plan Implemented**: [plans/20260727_200000_relationship_aware_caller_context.md](../plans/20260727_200000_relationship_aware_caller_context.md)

---

## Overview

Implemented ContactSphere's flagship killer feature: **Relationship-Aware Caller Context ("Why is this person calling?")**.

When an incoming or active call occurs, ContactSphere stitches four decoupled data domains (relationships, interaction/call history, pending reminders/callbacks, and upcoming birthdays/anniversaries) into a smart context card displayed directly on `InCallScreen` (e.g. **"Ravi — your cousin. Last spoke 3 weeks ago. You owe him a callback. Birthday next Tuesday."**).

---

## Detailed Changes

### 1. New Data Model: `lib/models/caller_context.dart`
- Added `CallerContext` data class holding:
  - `contactId`, `contactName`
  - `relationshipLabel` (e.g., `"your cousin"`, `"your father"`, `"Colleague"`)
  - `lastSpokeLabel` (e.g., `"Last spoke 3 weeks ago"`, `"Last spoke yesterday"`)
  - `pendingReminders` (e.g., `["You owe him a callback"]`)
  - `upcomingEventLabel` (e.g., `"Birthday next Tuesday"`, `"Anniversary in 3 days"`)
  - `recentNote`
- Added `buildSmartHeadline()` method to format natural language sentences summarizing the caller context.
- Added `hasContext` getter to check if any context attributes are populated.

### 2. New Service: `lib/services/caller_context_service.dart`
- Built `CallerContextService` with SQLite query paths across `contacts`, `relationships`, `call_logs`, `interactions`, and `reminders`.
- Implemented `formatRelationshipPerspective()` to convert raw relationship types (e.g., `"Cousin"`, `"Father"`, `"Colleague"`) into conversational phrases (`"your cousin"`, `"your father"`, `"your colleague"`).
- Implemented `formatLastSpokeTime()` to format relative time since last completed call or interaction (today, yesterday, X days ago, X weeks ago, X months ago).
- Implemented `_resolvePendingReminders()` to fetch uncompleted reminders (`is_completed = 0`).
- Implemented `_resolveUpcomingEvent()` to calculate upcoming birthdays, anniversaries, or meetiversaries within 14 days and format natural expressions ("Birthday today!", "Birthday tomorrow", "Birthday next Tuesday").
- Implemented `_resolveRecentNote()` to pull recent notes or call intents from `call_logs` and emotional tone from `interactions`.

### 3. In-Call UI Integration: `lib/screens/in_call_screen.dart`
- Wired `CallerContextService` into `_InCallScreenState`.
- Added `_callerContext` state field and asynchronously resolved it during `_resolveName(number)`.
- Implemented `_callerContextCard(Color fg, CallerContext ctx)` glassmorphic card on `InCallScreen` displaying:
  - Header: `"WHY THEY ARE CALLING"` with an amber sparkle icon (`Icons.auto_awesome`).
  - Headline text: Natural text summary constructed by `buildSmartHeadline()`.
  - Context badges: Individual visual chips for Relationship (blue), Last Spoke (emerald), Pending Callback (red), and Birthday/Event (amber).

### 4. Automated Tests: `test/caller_context_service_test.dart`
- Added unit tests verifying:
  - `buildSmartHeadline()` sentence construction.
  - `formatRelationshipPerspective()` conversions.
  - `formatLastSpokeTime()` relative date calculations.
  - Integration test stitching DB relationships, call logs, reminders, and birthdays for a resolved contact.

---

## Verification

- `flutter analyze`: **Clean (0 issues)**.
- `flutter test test/caller_context_service_test.dart`: **All 4 unit tests passed**.
- `flutter test`: **Full test suite green**.
