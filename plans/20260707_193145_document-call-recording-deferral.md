# Document why call recording stays deferred (sideloaded default dialer)

**Status:** completed

## Issue

`docs/known-gaps.md` currently frames call recording as "technically
permissible / revisitable now that the app can take the default-dialer role."
That framing is misleading for how this app is actually shipped — a **sideloaded**
default dialer. In that setup two-way call recording is **not** achievable:

- The privileged capture path (`CAPTURE_AUDIO_OUTPUT` / `VOICE_CALL` source) is a
  `signature|privileged` permission. A sideloaded app (in `/data/app`, not
  platform-signed, no `privapp-permissions` whitelist entry) is **denied it at
  runtime** even while it holds `ROLE_DIALER`. The dialer role grants call
  *control* (`InCallService`, the `Call` object, `CallAudioState` routing) but
  **not** privileged audio permissions — those are governed separately and only
  the ROM's own phone app gets both.
- The only sideload-compatible way to capture the remote party is the **routing
  hack**: force speakerphone and pick both sides up acoustically through the
  normal mic. That is device-dependent, low quality, and forces speaker — unusable
  in public. Rejected.
- Everything else captures at most the **local mic** (your side only).

So the deferral is not "postponed until we find time" — it is a platform limit for
this distribution model. The doc should say that plainly so the decision is not
re-litigated later.

## Files to change

- `docs/known-gaps.md` — documentation only. No code changes.

## Plan for the fix

1. **Expand the "Deferred → Call recording" bullet** (currently lines ~142-147) so
   it states the real reason for a sideloaded default dialer:
   - dialer role = call control, not call audio;
   - `CAPTURE_AUDIO_OUTPUT` is privileged and unavailable to a sideloaded app;
   - the only working remote-party path (speaker + mic routing) is rejected as
     unusable in public;
   - local-mic-only is the sole sideload-safe capture and would have to be
     labeled "your side only";
   - post-call feedback remains the deliberate substitute.
   - Note the conditions under which it *would* become possible (preinstalled /
     platform-signed / rooted) so the door is documented, not just shut.

2. **Correct the one-line follow-up in the 2026-07-01 default-phone-app entry**
   (lines ~74-75) that says call recording is "technically permissible as the
   default dialer" — soften to "technically permissible only for a privileged/
   preinstalled dialer; not for this sideloaded build — see the Deferred section."

No new sections, no schema/code/manifest changes. Wording only, kept in the
existing structure and style of the file.

## After implementation

Write a change log to `change_log/` referencing this plan.
