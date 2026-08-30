package `in`.sreerajp.contact_sphere

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * The ringing policy is the highest-consequence logic in the app — get it wrong and a
 * call is missed — so every branch is pinned here.
 */
class RingerPolicyTest {

    private fun decide(
        ringerMode: Int = RingerPolicy.MODE_NORMAL,
        interruptionFilter: Int = RingerPolicy.FILTER_ALL,
        vibrateWhenRinging: Boolean = true,
        appVibrateEnabled: Boolean = true,
    ) = RingerPolicy.decide(
        ringerMode = ringerMode,
        interruptionFilter = interruptionFilter,
        vibrateWhenRinging = vibrateWhenRinging,
        appVibrateEnabled = appVibrateEnabled,
    )

    // ---- Normal ring mode ----

    @Test
    fun `normal mode rings and vibrates when everything is on`() {
        assertEquals(RingerPolicy.Decision(playSound = true, vibrate = true), decide())
    }

    /** The bug this policy was written to fix. */
    @Test
    fun `normal mode does not vibrate when the phone's vibrate-for-calls is off`() {
        val d = decide(vibrateWhenRinging = false)
        assertTrue("must still ring", d.playSound)
        assertFalse("must not vibrate — the phone said not to", d.vibrate)
    }

    @Test
    fun `normal mode does not vibrate when the app's own toggle is off`() {
        val d = decide(appVibrateEnabled = false)
        assertTrue(d.playSound)
        assertFalse(d.vibrate)
    }

    // ---- Silent / vibrate ringer modes ----

    @Test
    fun `silent mode is fully silent`() {
        assertEquals(
            RingerPolicy.Decision(playSound = false, vibrate = false),
            decide(ringerMode = RingerPolicy.MODE_SILENT),
        )
    }

    @Test
    fun `silent mode stays silent even with both vibrate switches on`() {
        val d = decide(
            ringerMode = RingerPolicy.MODE_SILENT,
            vibrateWhenRinging = true,
            appVibrateEnabled = true,
        )
        assertFalse(d.playSound)
        assertFalse(d.vibrate)
    }

    @Test
    fun `vibrate mode buzzes without sound`() {
        assertEquals(
            RingerPolicy.Decision(playSound = false, vibrate = true),
            decide(ringerMode = RingerPolicy.MODE_VIBRATE),
        )
    }

    /**
     * Vibrate mode is the one place the system "Vibrate for calls" setting is ignored:
     * the phone is in vibrate mode, so it must buzz.
     */
    @Test
    fun `vibrate mode ignores the phone's vibrate-for-calls setting`() {
        val d = decide(ringerMode = RingerPolicy.MODE_VIBRATE, vibrateWhenRinging = false)
        assertTrue("vibrate mode must still buzz", d.vibrate)
    }

    @Test
    fun `vibrate mode still honours the app's own toggle`() {
        val d = decide(ringerMode = RingerPolicy.MODE_VIBRATE, appVibrateEnabled = false)
        assertFalse(d.playSound)
        assertFalse(d.vibrate)
    }

    // ---- Do Not Disturb ----

    /** The second bug: these filters leave the ringer mode at NORMAL. */
    @Test
    fun `DND alarms-only neither rings nor vibrates`() {
        assertEquals(
            RingerPolicy.Decision(playSound = false, vibrate = false),
            decide(
                ringerMode = RingerPolicy.MODE_NORMAL,
                interruptionFilter = RingerPolicy.FILTER_ALARMS,
            ),
        )
    }

    @Test
    fun `DND total silence neither rings nor vibrates`() {
        assertEquals(
            RingerPolicy.Decision(playSound = false, vibrate = false),
            decide(
                ringerMode = RingerPolicy.MODE_NORMAL,
                interruptionFilter = RingerPolicy.FILTER_NONE,
            ),
        )
    }

    @Test
    fun `DND wins over vibrate ringer mode too`() {
        val d = decide(
            ringerMode = RingerPolicy.MODE_VIBRATE,
            interruptionFilter = RingerPolicy.FILTER_NONE,
        )
        assertFalse(d.vibrate)
    }

    /** Documented non-goal: honouring this needs ACCESS_NOTIFICATION_POLICY. */
    @Test
    fun `DND priority-only still rings, by design`() {
        val d = decide(interruptionFilter = RingerPolicy.FILTER_PRIORITY)
        assertTrue(d.playSound)
        assertTrue(d.vibrate)
    }

    @Test
    fun `DND off rings normally`() {
        assertTrue(decide(interruptionFilter = RingerPolicy.FILTER_ALL).playSound)
    }

    // ---- Fail-open ----

    /**
     * Callers substitute the permissive defaults when a setting can't be read. An
     * unknown ringer mode must land on the ringing branch, never on silence.
     */
    @Test
    fun `an unrecognised ringer mode rings rather than staying silent`() {
        assertTrue(decide(ringerMode = 99).playSound)
    }

    @Test
    fun `an unrecognised interruption filter does not suppress the call`() {
        assertTrue(decide(interruptionFilter = 99).playSound)
    }

    // ---- The mirrored platform constants ----

    @Test
    fun `mirrored constants match the platform values`() {
        // AudioManager.RINGER_MODE_*
        assertEquals(0, RingerPolicy.MODE_SILENT)
        assertEquals(1, RingerPolicy.MODE_VIBRATE)
        assertEquals(2, RingerPolicy.MODE_NORMAL)
        // NotificationManager.INTERRUPTION_FILTER_*
        assertEquals(1, RingerPolicy.FILTER_ALL)
        assertEquals(2, RingerPolicy.FILTER_PRIORITY)
        assertEquals(3, RingerPolicy.FILTER_NONE)
        assertEquals(4, RingerPolicy.FILTER_ALARMS)
    }
}
