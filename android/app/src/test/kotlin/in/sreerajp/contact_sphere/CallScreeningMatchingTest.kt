package `in`.sreerajp.contact_sphere

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class CallScreeningMatchingTest {

    @Test
    fun `exact numbers match`() {
        assertTrue(
            ContactSphereCallScreeningService.sameNumber("9876543210", "9876543210")
        )
    }

    @Test
    fun `country code suffix matches`() {
        // Stored as 919876543210, incoming national 9876543210
        assertTrue(
            ContactSphereCallScreeningService.sameNumber("919876543210", "9876543210")
        )
        // Stored national 9876543210, incoming international 919876543210
        assertTrue(
            ContactSphereCallScreeningService.sameNumber("9876543210", "919876543210")
        )
    }

    @Test
    fun `short numbers only match exactly`() {
        // Below MIN_SUFFIX_DIGITS (9), suffix match is forbidden
        assertTrue(ContactSphereCallScreeningService.sameNumber("12345", "12345"))
        assertFalse(ContactSphereCallScreeningService.sameNumber("12345", "9876512345"))
    }

    @Test
    fun `seven and eight digit overlaps are not enough`() {
        // 919876543210 ends with "6543210" (7) and "76543210" (8). Real numbers
        // can share that much, so neither may count as a match — the threshold
        // is 9. The Dart side (FlaggedNumberRepository) mirrors this rule.
        assertFalse(
            ContactSphereCallScreeningService.sameNumber("919876543210", "6543210")
        )
        assertFalse(
            ContactSphereCallScreeningService.sameNumber("919876543210", "76543210")
        )
        // Nine digits of overlap is a match again.
        assertTrue(
            ContactSphereCallScreeningService.sameNumber("919876543210", "876543210")
        )
    }

    @Test
    fun `different numbers do not match`() {
        assertFalse(
            ContactSphereCallScreeningService.sameNumber("9876543210", "9876543211")
        )
    }

    @Test
    fun `matchesList correctly checks against list`() {
        val blocked = listOf("919876543210", "919123456789")
        assertTrue(ContactSphereCallScreeningService.matchesList("9876543210", blocked))
        assertTrue(ContactSphereCallScreeningService.matchesList("9123456789", blocked))
        assertFalse(ContactSphereCallScreeningService.matchesList("9999999999", blocked))
    }
}
