package `in`.sreerajp.contact_sphere

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Quiet hours gate the spoken caller announcement ("Amma calling"). The default window
 * is 22:00→07:00, which wraps past midnight — the case most likely to be got wrong.
 */
class QuietHoursTest {

    private fun at(hour: Int, minute: Int = 0) = hour * 60 + minute

    private fun quiet(hour: Int, minute: Int = 0, start: String = "22:00", end: String = "07:00") =
        CallerAnnouncer.isInQuietHours(start, end, at(hour, minute))

    // ---- A window that wraps past midnight (the default) ----

    @Test
    fun `late evening is quiet`() {
        assertTrue(quiet(23))
    }

    @Test
    fun `after midnight is still quiet`() {
        assertTrue(quiet(2))
    }

    @Test
    fun `early morning before the end is quiet`() {
        assertTrue(quiet(6, 59))
    }

    @Test
    fun `daytime is not quiet`() {
        assertFalse(quiet(12))
        assertFalse(quiet(9))
        assertFalse(quiet(21, 59))
    }

    @Test
    fun `the window is inclusive at the start and exclusive at the end`() {
        assertTrue("22:00 starts the window", quiet(22, 0))
        assertFalse("07:00 ends it", quiet(7, 0))
    }

    // ---- A window inside one day ----

    @Test
    fun `a same-day window covers only its own hours`() {
        assertTrue(quiet(14, start = "13:00", end = "15:00"))
        assertFalse(quiet(12, 59, start = "13:00", end = "15:00"))
        assertFalse(quiet(15, 0, start = "13:00", end = "15:00"))
        assertFalse(quiet(23, start = "13:00", end = "15:00"))
    }

    // ---- Bad input never silences anything by accident ----

    @Test
    fun `a malformed time is treated as not quiet`() {
        assertFalse(CallerAnnouncer.isInQuietHours("nonsense", "07:00", at(2)))
        assertFalse(CallerAnnouncer.isInQuietHours("22:00", "", at(2)))
        assertFalse(CallerAnnouncer.isInQuietHours("22", "07:00", at(2)))
        assertFalse(CallerAnnouncer.isInQuietHours("", "", at(2)))
    }

    // ---- Script detection picks the announcement language ----

    @Test
    fun `Malayalam names are detected`() {
        assertTrue(CallerAnnouncer.isMalayalamScript("അമ്മ"))
        assertTrue(CallerAnnouncer.isMalayalamScript("Sreeraj പി"))
    }

    @Test
    fun `Latin and other scripts are not Malayalam`() {
        assertFalse(CallerAnnouncer.isMalayalamScript("Sreeraj"))
        assertFalse(CallerAnnouncer.isMalayalamScript(""))
        assertFalse(CallerAnnouncer.isMalayalamScript("+919876543210"))
        assertFalse(CallerAnnouncer.isMalayalamScript("नमस्ते"))
    }
}
