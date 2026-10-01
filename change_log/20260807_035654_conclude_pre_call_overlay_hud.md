# Change Log: Conclude Pre-call Overlay HUD Roadmap Entry

## References
- Plan: [`plans/20260807_035016_conclude_pre_call_overlay_hud.md`](../plans/20260807_035016_conclude_pre_call_overlay_hud.md)

## Summary of Changes
- Updated [`docs/feature_analysis_and_roadmap.md`](../docs/feature_analysis_and_roadmap.md) Section 6 table entry for **Pre-call overlay HUD**:
  - Marked status as `✅ **Shipped (In-app only).**` referencing [`pre_call_summary_service.dart`](../lib/services/pre_call_summary_service.dart).
  - Recorded decision concluding that floating overlays over native call screens are rejected to preserve user trust and avoid asking for `SYSTEM_ALERT_WINDOW`.
