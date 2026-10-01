package `in`.sreerajp.contact_sphere

/**
 * Decides whether an incoming call may ring and/or vibrate.
 *
 * Because the manifest declares `IN_CALL_SERVICE_RINGING` the platform does **not** ring
 * for us — [IncomingCallRinger] does it itself — so this app is also responsible for
 * obeying every system sound rule the platform would normally apply on our behalf.
 * Those rules used to be a single `when (ringerMode)`, which honoured silent/vibrate mode
 * but ignored both the user's "Vibrate for calls" system setting and Do Not Disturb.
 * During DND "Priority only" the ringer mode apps see is forced to silent, so for a
 * caller DND allows the phone's real ringer mode is used instead (see [decide]).
 *
 * Deliberately **pure**: no Android imports, no context, no I/O — just ints in, a
 * [Decision] out. That is what lets the whole ringing policy be unit tested on the plain
 * JVM (see `RingerPolicyTest`), which matters because a mistake here means a missed call.
 * [IncomingCallRinger] reads the three inputs from the platform and passes them straight
 * through.
 *
 * Every rule fails **open** — when an input can't be read the caller substitutes the
 * permissive default ([FILTER_ALL], vibrate-when-ringing on), so an unreadable setting
 * rings rather than silently swallowing a call.
 */
object RingerPolicy {

    /** What the ringer is allowed to do for one incoming call. */
    data class Decision(val playSound: Boolean, val vibrate: Boolean)

    /**
     * Resolve the policy for one incoming call.
     *
     * @param ringerMode the device ringer mode ([MODE_SILENT] / [MODE_VIBRATE] /
     *   [MODE_NORMAL]) — `AudioManager.getRingerMode()`.
     * @param interruptionFilter the Do Not Disturb state ([FILTER_ALL], [FILTER_PRIORITY],
     *   [FILTER_NONE], [FILTER_ALARMS]) — `NotificationManager.getCurrentInterruptionFilter()`.
     * @param vibrateWhenRinging the user's system-wide "Vibrate for calls" setting —
     *   `Settings.System.VIBRATE_WHEN_RINGING`.
     * @param appVibrateEnabled the app's own "Vibrate on incoming calls" toggle.
     * @param callerAllowedByDnd whether Do Not Disturb lets this caller through —
     *   `NotificationManager.matchesCallFilter(Uri)`; null when it couldn't be checked.
     * @param internalRingerMode the phone's real ringer mode — `Settings.Global.MODE_RINGER`;
     *   null when it couldn't be read.
     */
    fun decide(
        ringerMode: Int,
        interruptionFilter: Int,
        vibrateWhenRinging: Boolean,
        appVibrateEnabled: Boolean,
        callerAllowedByDnd: Boolean? = null,
        internalRingerMode: Int? = null,
    ): Decision {
        // Do Not Disturb, total silence or alarms-only: neither sound nor vibration.
        // Checked before the ringer mode because these filters leave the ringer mode at
        // NORMAL on most devices, which is exactly why the old code rang straight through
        // them.
        if (interruptionFilter == FILTER_NONE || interruptionFilter == FILTER_ALARMS) {
            return Decision(playSound = false, vibrate = false)
        }

        // DND "Priority only" (which Google's Driving mode uses) reports the ringer mode
        // to apps as SILENT while the phone's real mode stays NORMAL — so reading
        // AudioManager alone silenced every call, even callers DND lets through. For a
        // caller DND has allowed, use the real mode instead (still honouring a phone the
        // user really set to silent/vibrate). Anything unknown keeps the app-facing
        // mode, so a caller DND blocks is never rung.
        val effectiveMode =
            if (interruptionFilter == FILTER_PRIORITY &&
                callerAllowedByDnd == true &&
                internalRingerMode != null
            ) {
                internalRingerMode
            } else {
                ringerMode
            }

        return when (effectiveMode) {
            MODE_SILENT -> Decision(playSound = false, vibrate = false)

            // Vibrate mode: the phone must buzz — that is the whole point of the mode — so
            // the system "Vibrate for calls" setting is NOT consulted here. Only the app's
            // own toggle can turn it off.
            MODE_VIBRATE -> Decision(playSound = false, vibrate = appVibrateEnabled)

            // Normal mode: ring, and vibrate only if the user wants calls to vibrate both
            // system-wide and in this app.
            else -> Decision(
                playSound = true,
                vibrate = appVibrateEnabled && vibrateWhenRinging,
            )
        }
    }

    // The platform's own values, mirrored here so this object stays free of Android
    // imports and runs under plain JUnit. All four have been frozen public API since they
    // were introduced (ringer modes since API 1, interruption filters since API 21).

    /** `AudioManager.RINGER_MODE_SILENT`. */
    const val MODE_SILENT = 0

    /** `AudioManager.RINGER_MODE_VIBRATE`. */
    const val MODE_VIBRATE = 1

    /** `AudioManager.RINGER_MODE_NORMAL`. */
    const val MODE_NORMAL = 2

    /** `NotificationManager.INTERRUPTION_FILTER_ALL` — Do Not Disturb off. */
    const val FILTER_ALL = 1

    /** `NotificationManager.INTERRUPTION_FILTER_PRIORITY` — DND "Priority only". */
    const val FILTER_PRIORITY = 2

    /** `NotificationManager.INTERRUPTION_FILTER_NONE` — DND "Total silence". */
    const val FILTER_NONE = 3

    /** `NotificationManager.INTERRUPTION_FILTER_ALARMS` — DND "Alarms only". */
    const val FILTER_ALARMS = 4
}
