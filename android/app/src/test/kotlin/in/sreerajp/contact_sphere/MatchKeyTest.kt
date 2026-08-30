package `in`.sreerajp.contact_sphere

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * `IncomingCallRinger.matchKey` is how every native reader — the ringer looking up a
 * per-contact tone, the missed-call notification looking up a name — keys a phone
 * number. The Flutter side keys its mirror the same way, so if this drifts, incoming
 * calls quietly lose their custom tone and their caller name.
 */
class MatchKeyTest {

    @Test
    fun `keeps the trailing ten digits`() {
        assertEquals("9876543210", IncomingCallRinger.matchKey("9876543210"))
    }

    @Test
    fun `absorbs a country code`() {
        assertEquals("9876543210", IncomingCallRinger.matchKey("+919876543210"))
    }

    @Test
    fun `absorbs a leading zero`() {
        assertEquals("9876543210", IncomingCallRinger.matchKey("09876543210"))
    }

    @Test
    fun `strips spaces, dashes and brackets`() {
        assertEquals("9876543210", IncomingCallRinger.matchKey("+91 (98765) 43-210"))
    }

    @Test
    fun `every spelling of one number agrees`() {
        val keys = listOf(
            "9876543210",
            "+919876543210",
            "09876543210",
            "+91-98765-43210",
            "0091 98765 43210",
        ).map { IncomingCallRinger.matchKey(it) }
        assertEquals(1, keys.distinct().size)
    }

    @Test
    fun `a shorter number is kept whole`() {
        assertEquals("12345", IncomingCallRinger.matchKey("12345"))
    }

    @Test
    fun `a landline with an STD code keys on its last ten digits`() {
        assertEquals("4842345678", IncomingCallRinger.matchKey("+914842345678"))
    }

    /**
     * Ten digits, not seven: real Indian mobiles collide on a shorter suffix. Both of
     * these end in 0123456.
     */
    @Test
    fun `distinct numbers sharing a seven-digit suffix do not collide`() {
        val a = IncomingCallRinger.matchKey("9000123456")
        val b = IncomingCallRinger.matchKey("9111123456")
        assertEquals(10, a!!.length)
        assert(a != b) { "10-digit keys must not collide: $a vs $b" }
    }

    @Test
    fun `null and blank and non-numeric yield no key`() {
        assertNull(IncomingCallRinger.matchKey(null))
        assertNull(IncomingCallRinger.matchKey(""))
        assertNull(IncomingCallRinger.matchKey("   "))
        assertNull(IncomingCallRinger.matchKey("unknown"))
    }

    @Test
    fun `matches the documented digit count`() {
        assertEquals(10, IncomingCallRinger.MATCH_DIGITS)
    }
}
