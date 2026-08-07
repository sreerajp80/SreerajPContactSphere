# Best-time-to-reach windows (roadmap 5.2) — advice only, never auto-dial

**Status:** completed

## 1. The issue

Two separate problems.

**a. The roadmap text is wrong.** Section 6 of
[docs/feature_analysis_and_roadmap.md](../docs/feature_analysis_and_roadmap.md) says the
"Smart dialing intelligence" idea is *"Superseded by 5.2"*. Read plainly, that says the Smart
Redial scheduler goes away. It must not. The user-set delay (1–30 min), fired natively by
`SmartRedialManager.kt` and mirrored by
[smart_redial_service.dart](../lib/services/smart_redial_service.dart), stays exactly as it is.
Only the *old guess-based idea* ("rank business contacts during office hours") is dropped.

**b. Item 5.2 is not built.** The app has the data — `call_logs` holds every call with
`call_type`, `duration` and `timestamp` — but nothing ever asks it *when calls to this person
actually get answered*. The pre-call summary shows last-call duration and their local time; the
dialer's Top contacts section orders by relationship score then recency. Neither knows anything
about answer rates.

## 2. The hard constraint

**The new intelligence must never place or schedule a call by itself.** It may only advise:

- a line on the pre-call summary ("usually answers after 7pm"),
- an optional ordering of the dialer's Top contacts section.

Every call that results from it is a tap the user makes. No new code may reach `TelecomService`,
`url_launcher`, or `SmartRedialService`. Auto-dialing stays confined to Smart Redial, which is
the one place the user explicitly asked for it.

This is a review checkpoint, not just a note: if any step below ends up wanting a dial call, the
step is wrong.

## 3. Files to change

### New

| File | Purpose |
| :--- | :--- |
| `lib/models/reach_window.dart` | `ReachWindow` value object — bucket label, hour range, answer rate, sample size, weekday/weekend scope. |
| `lib/services/reach_window_service.dart` | Computes per-contact windows from `call_logs`; the only place the statistics live. |
| `test/reach_window_service_test.dart` | Unit tests over an in-memory DB. |
| `change_log/<ts>_best-time-to-reach.md` | Written after implementation. |

### Modified

| File | Change |
| :--- | :--- |
| [docs/feature_analysis_and_roadmap.md](../docs/feature_analysis_and_roadmap.md) | Rewrite the section 6 "Smart dialing intelligence" row; extend §5.2 with the no-auto-dial constraint. |
| [lib/models/call_summary.dart](../lib/models/call_summary.dart) | Add `bestTimeToReach` (a `ReachWindow?`). |
| [lib/services/pre_call_summary_service.dart](../lib/services/pre_call_summary_service.dart) | Populate that field via `ReachWindowService`. |
| [lib/screens/contact_detail_screen.dart](../lib/screens/contact_detail_screen.dart) | One extra line in `_buildSummaryCard` (~line 828). Display only. |
| [lib/state/app_settings.dart](../lib/state/app_settings.dart) | New `DialerTopSource.likelyToAnswer` value; persisted as today (index into prefs). |
| [lib/screens/settings_screen.dart](../lib/screens/settings_screen.dart) | Offer the new Top-contacts source. |
| [lib/repositories/contact_repository.dart](../lib/repositories/contact_repository.dart) | New `getLikelyToAnswerMatches()` beside `getTopRecentMatches()` (~line 321). |
| [lib/screens/dialer_screen.dart](../lib/screens/dialer_screen.dart) | `_loadFavorites()` (~line 305) handles the third source; section header text. |
| [docs/features.md](../docs/features.md) | Document the new feature and its advice-only limit. |

Existing Smart Redial files are **not** touched.

## 4. The fix

### 4.1 What counts as "answered"

From `call_logs`, per contact:

- **answered** — `call_type = 'incoming'` with `duration > 0`, or `call_type = 'outgoing'` with
  `duration > 0` (they picked up).
- **not answered** — `call_type = 'missed'`, or `'outgoing'` with `duration` 0 or null.
- **ignored** — `call_type = 'blocked'`, and rows with `duration IS NULL` *and* a timestamp inside
  the last 2 minutes (a provisional row a call is still in progress on).

Timestamps are parsed with `DateTime.parse(...).toLocal()` before bucketing. I will confirm during
implementation whether the write path stores local or UTC ISO strings and normalise once, in the
service, so a mixed history still buckets correctly.

### 4.2 Buckets

Four named day parts, each also split weekday vs weekend:

| Bucket | Hours | Phrase |
| :--- | :--- | :--- |
| morning | 06:00–11:59 | "usually answers in the morning" |
| afternoon | 12:00–16:59 | "usually answers in the afternoon" |
| evening | 17:00–20:59 | "usually answers after 5pm" |
| night | 21:00–05:59 | "usually answers late evening" |

Weekday/weekend is only mentioned when one clearly beats the other; otherwise the phrase stays
plain. Day parts, not raw hours, because per-hour counts are too thin to mean anything on a
personal call history.

### 4.3 Only speak when the data supports it

`ReachWindowService.bestWindow(contactId)` returns `null` — and the UI then shows nothing at all —
unless **all** of:

- at least **8** usable calls for the contact,
- at least **3** calls in the winning bucket,
- the winning bucket's answer rate is at least **20 percentage points** above the contact's
  overall answer rate.

A silent line is much better than a confident wrong one. These three numbers live as named
constants at the top of the service so they are easy to retune.

Only calls from the **last 180 days** are counted, so a habit from two years ago does not outvote
current behaviour.

### 4.4 Where it shows

**Pre-call summary.** `PreCallSummaryService.getPreCallSummary` calls the new service and puts the
result on `CallSummary.bestTimeToReach`. `_buildSummaryCard` adds one line, in the same style as
the existing lines, only when the field is non-null.

**Dialer Top contacts.** A third `DialerTopSource`, opt-in from Settings, alongside the current
`recent` and `relations`. `getLikelyToAnswerMatches()` orders candidates by whether *the current
day part* is their best window, then by relationship score, then recency — so the strip is simply
sorted differently. Section header: "Likely to answer now". Same rows, same tap behaviour as the
other two sources; nothing dials.

`recent` stays the default. Nobody's dialer changes unless they pick the new source.

### 4.5 Cost

One aggregate `GROUP BY` per contact, over an indexed `contact_id`. Cached in memory per contact
for the lifetime of a screen; the dialer's ordering query aggregates in SQL in a single pass. No
schema change, no migration, no background job.

## 5. Out of scope

- The 5.1 "nudge now" case — 5.1 (the unified scheduler) does not exist yet. Without it, 5.2
  never initiates anything, which suits the constraint in §2.
- Any change to Smart Redial.
- Any auto-dial, anywhere.

## 6. Tests

`test/reach_window_service_test.dart` over an in-memory DB:

- a clear evening-answerer returns the evening window;
- a contact with 5 calls returns null (below the sample floor);
- an evenly-spread contact returns null (no bucket clears the margin);
- missed and zero-duration outgoing calls count as not-answered;
- `blocked` rows and provisional (null-duration) rows are excluded;
- calls older than 180 days are excluded.

Run as its own `flutter test` invocation — sqlite-backed test files crash when batched with
others in this project.

Then `flutter analyze` and the full suite.

## 7. Approval

Do you approve this plan?
