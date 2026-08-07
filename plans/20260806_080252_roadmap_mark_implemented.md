# Mark implemented features in the roadmap document

**Status:** completed

## 1. The issue

[docs/feature_analysis_and_roadmap.md](../docs/feature_analysis_and_roadmap.md) is stale in a few
places now that 5.2 (best-time-to-reach) has shipped. The document contradicts itself:

- Section 5's opening line still says **"None of these exist today"**, immediately above 5.2,
  which is marked shipped.
- The section 7 gantt chart still schedules **Best-Time-To-Reach in Phase 2**, after work that
  hasn't started, and its "Shipped" section doesn't list it.
- Section 2 ("Current foundation") lists the contextual-intelligence services but not the new
  one.
- 5.2's own status line is a paragraph tacked on the end, unlike the `— **Shipped**` heading
  style section 3 uses.
- The "Last re-verified" date needs to reflect this pass.

## 2. What I checked

I re-verified every other status claim against the code before proposing any change, so this
edit doesn't quietly bless something that isn't real. **Every remaining "Not started" claim is
still true:**

| Item | Searched for | Found |
| :--- | :--- | :--- |
| 3.3 decay nudges | `decay` | nothing |
| 3.4 personas | `persona` | only the word "personal" (phone/address types) |
| 3.5 decoy vault | `decoy`, `stealth` | nothing |
| 3.6 scratchpad / HUD | `scratchpad`, `SYSTEM_ALERT_WINDOW`, `overlay` | only Flutter's own `Overlay` widget; the permission is **not** in the manifest |
| 3.7 BLE mesh | `mesh`, `WifiDirect` | only `HomeShell` matching the letters |
| 5.1 scheduler | service files named `sched`/`nudge`/`remind` | none |
| 5.3 number-change | `numberChange` | nothing |
| 5.4 quiet hours | `quietHours` | nothing |
| 5.5 optical air-gap | `multiFrame`, `animatedQr`, `airGap` | nothing |
| 5.6 QR safety checks | `validatePayload`, `sanitizeVcard` | nothing |
| 5.7 spoken announcement | `flutter_tts`, `TextToSpeech` | nothing, and no TTS dependency |
| 5.8 senior mode | `seniorMode`, `largeTouch` | nothing |
| 5.9 emergency card hand-off | `Share.share` in the emergency files | nothing |

So this is a small, targeted edit — **only 5.2 changes status**. Section 3 and the section 6
table are already accurate and stay as they are.

## 3. Files to change

| File | Change |
| :--- | :--- |
| [docs/feature_analysis_and_roadmap.md](../docs/feature_analysis_and_roadmap.md) | The five edits in §4. |
| `change_log/<ts>_roadmap_mark_implemented.md` | Written after. |

No code changes. No other document changes — [docs/features.md](../docs/features.md) was already
updated when 5.2 shipped.

## 4. The fix

1. **Header** — set "Last re-verified against code" to 2026-08-06 (this pass), and add one line
   noting that the not-started claims were re-checked, not assumed.
2. **Section 2** — add best-time-to-reach to the "Contextual intelligence" bullet, naming
   `reach_window_service.dart`, with the advice-only limit stated in half a sentence.
3. **Section 5 intro** — replace "None of these exist today" with wording that survives items
   shipping one at a time: these were all proposals when written, and each carries its own
   status.
4. **5.2 heading** — retitle to `### 5.2 Best-time-to-reach windows — **Shipped**`, matching
   section 3's style, and fold the trailing status paragraph into a short note that keeps the
   two caveats: it never dials, and the 5.1 "nudge now" case is still outstanding.
5. **Section 7 gantt** — move Best-Time-To-Reach into the Shipped section as `:done`, and
   re-anchor Number-Change Detection (which currently starts `after p2_1`) so Phase 2 still
   chains correctly. Retitle the chart to the current revision date.

## 5. Risk

The one thing to get right is the gantt re-anchor: removing `p2_1` from Phase 2 without fixing
what pointed at it would leave a dangling `after p2_1` reference and break the chart. Number-
Change Detection becomes the Phase 2 head, anchored `after p1_3` as 5.2 previously was.

I'll re-read the rendered mermaid block after editing to confirm no task references a removed id.

## 6. Approval

Do you approve this plan?
