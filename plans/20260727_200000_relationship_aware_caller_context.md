# Plan: Relationship-Aware Caller Context ("Why is this person calling?")

**Date & Time**: 2026-07-27 20:00:00  
**Feature**: Stitch relationships, last interaction/call logs, pending reminders/callbacks, and upcoming events (birthdays/anniversaries) into a smart, relationship-aware caller context card displayed on incoming and in-call screens.

---

## 1. Issue & Goal

### Goal
When an incoming call arrives or an active call is connected, instead of showing just the caller's name or number, present a smart context card answering *"Why is this person calling?"* (e.g. **"Ravi — your cousin. Last spoke 3 weeks ago. You owe him a callback. Birthday next Tuesday."**).

This stitches data from four decoupled features in ContactSphere:
1. **Relationships**: Relationship type relative to the user ("your cousin", "your father", "your colleague", etc.).
2. **Interactions & Call History**: Natural relative timestamp of when the user last spoke/interacted ("Last spoke 3 weeks ago", "Last spoke yesterday", "Last spoke 2 hours ago").
3. **Reminders**: Pending callbacks/to-dos from `reminders` table ("You owe him a callback", "Discuss project update").
4. **Upcoming Events**: Important upcoming dates from `contacts` (`dob`, `anniversary`, `meetiversary`) (e.g., "Birthday next Tuesday", "Anniversary in 3 days").

---

## 2. Proposed Changes & Architecture

### A. New Model: `lib/models/caller_context.dart`
- **Fields**:
  - `contactId`: `int`
  - `contactName`: `String`
  - `relationshipLabel`: `String?` (e.g., `"your cousin"`, `"your father"`, `"Colleague"`)
  - `lastSpokeLabel`: `String?` (e.g., `"Last spoke 3 weeks ago"`, `"Last spoke yesterday"`)
  - `lastSpokeTime`: `DateTime?`
  - `pendingReminders`: `List<String>` (e.g., `["You owe him a callback"]`)
  - `upcomingEventLabel`: `String?` (e.g., `"Birthday next Tuesday"`, `"Anniversary in 3 days"`)
  - `recentNote`: `String?` (latest interaction note or sentiment)
- **Methods**:
  - `String buildSmartHeadline()`: Generates the natural language summary (e.g., `"Ravi — your cousin. Last spoke 3 weeks ago. You owe him a callback. Birthday next Tuesday."`).
  - `bool get hasContext`: Returns true if any context field is populated.

### B. New Service: `lib/services/caller_context_service.dart`
- **Responsibilities**:
  - `getCallerContextByContactId(int contactId)`:
    - Queries DB tables: `contacts`, `relationships`, `call_logs`, `interactions`, `reminders`.
    - Resolves relationship label from the user's perspective (e.g., "Father" -> "your father", "Cousin" -> "your cousin").
    - Computes elapsed time since last call/interaction and formats human-readable relative time ("Last spoke 3 weeks ago", "Last spoke yesterday").
    - Retrieves uncompleted reminders (`is_completed = 0`) for the contact.
    - Computes upcoming birthdays/anniversaries within 14 days and formats natural date expressions ("Birthday next Tuesday", "Birthday tomorrow").
  - `getCallerContextByNumber(String number, {String? defaultIso})`:
    - Resolves contact by phone number via `ContactRepository.findByFullNumber` and calls `getCallerContextByContactId`.

### C. In-Call UI Integration: `lib/screens/in_call_screen.dart`
- Inject `CallerContextService` into `_InCallScreenState`.
- Resolve `CallerContext` asynchronously alongside caller identity resolution in `_resolveName(number)`.
- Add `_callerContextCard(Color fg)` widget to `InCallScreen` body under the caller's name & status block:
  - Renders a glassmorphic context card with accent icon (`Icons.auto_awesome` / `Icons.psychology_outlined`).
  - Displays the natural summary headline and individual context chips (Relationship badge, Last spoke badge, Callback pending badge, Birthday badge).
  - Designed for high legibility over both dark/light photo backdrops and standard brand gradients.

### D. Unit Tests: `test/caller_context_service_test.dart`
- Unit tests covering:
  - Formatting of relationship labels ("your cousin", "your father", "your colleague").
  - Formatting of relative time for last spoke (today, yesterday, X days ago, X weeks ago).
  - Formatting of upcoming events (birthdays/anniversaries).
  - Assembling full smart context headline.
  - Non-contact phone numbers gracefully returning null/empty context.

---

## 3. Files to Create & Modify

#### [NEW] [caller_context.dart](file:///l:/Android/SreerajPContactSphere/lib/models/caller_context.dart)
Data model for caller context, holding relationship, last interaction, pending reminders, and upcoming events, with `buildSmartHeadline()`.

#### [NEW] [caller_context_service.dart](file:///l:/Android/SreerajPContactSphere/lib/services/caller_context_service.dart)
Service stitching SQLite queries across `contacts`, `relationships`, `call_logs`, `interactions`, and `reminders` into `CallerContext`.

#### [MODIFY] [in_call_screen.dart](file:///l:/Android/SreerajPContactSphere/lib/screens/in_call_screen.dart)
Integrates `CallerContextService` and renders the Smart Context Card on incoming and active call screens.

#### [NEW] [caller_context_service_test.dart](file:///l:/Android/SreerajPContactSphere/test/caller_context_service_test.dart)
Unit tests for caller context calculation, formatting, and headline construction.

---

## 4. Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure zero linter errors.
- Run `flutter test test/caller_context_service_test.dart` to verify unit tests pass.
- Run `flutter test` to verify full test suite remains green.

### Manual Verification
- Test incoming and outgoing calls on Android device / emulator.
- Verify caller context card appears with relationship, last spoke time, pending callbacks, and upcoming birthday notifications.
