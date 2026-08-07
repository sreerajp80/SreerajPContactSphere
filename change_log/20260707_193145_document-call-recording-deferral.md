# Change log — document why call recording stays deferred

**Plan:** `plans/20260707_193145_document-call-recording-deferral.md`
**Date:** 2026-07-07

## What changed

Documentation only — edits to `docs/known-gaps.md`. No code, schema, or manifest
changes.

1. **Expanded the "Deferred → Call recording" bullet.** It now explains that for
   this app's distribution model (a **sideloaded** default dialer) call recording is
   a platform limit, not a postponed task:
   - the dialer role grants call *control* (`InCallService`, `Call`, `CallAudioState`
     routing), not privileged access to call *audio*;
   - the call-audio sources (`VOICE_CALL` / `VOICE_DOWNLINK` / `VOICE_UPLINK`) are
     gated behind `CAPTURE_AUDIO_OUTPUT`, a `signature|privileged` permission that a
     sideloaded app is denied at runtime even while it is the default dialer;
   - the only sideload-compatible way to capture the remote party (force speaker +
     acoustic mic pickup) is rejected as unusable in public;
   - local-mic-only is the sole sideload-safe capture and records "your side only";
   - it would become possible only if the app were preinstalled / platform-signed /
     rooted;
   - post-call feedback remains the deliberate substitute.

2. **Corrected the one-line follow-up in the 2026-07-01 default-phone-app entry.**
   It previously said call recording was "technically permissible as the default
   dialer." It now says the dialer role gives call control, not privileged call
   audio, so recording is permissible only for a preinstalled/platform-signed dialer
   — not for this sideloaded build — and points to the Deferred section.

## Why

The old wording implied taking the default-dialer role made recording revisitable.
For a sideloaded app that is not true, and the misleading framing risked the
decision being re-litigated. The doc now records the real platform constraint.
