package `in`.sreerajp.contact_sphere

import java.security.SecureRandom

/**
 * A one-shot, in-process hand-off for **trusted** "Call back" numbers offered on our own
 * missed-call notifications.
 *
 * The trust problem: the Call Back action's PendingIntent now launches [MainActivity]
 * directly (a `getActivity` PendingIntent) so the app reliably comes to the front — a
 * broadcast that then calls `startActivity` is blocked as a notification trampoline on
 * Android 12+. But [MainActivity] is exported, so a crafted external intent could otherwise
 * forge a "place this call now" and borrow our CALL_PHONE permission (the confused-deputy
 * hole a past security review closed).
 *
 * The guard is a random one-shot **token**. When a missed-call notification is built we
 * [arm] the number and get back a 64-bit [SecureRandom] token, which is also put in the
 * Call back intent's extras. [MainActivity] treats the call-back as a trusted auto-call
 * only when the intent's token matches a currently-armed one ([take]). An external app
 * cannot guess a live token, so it cannot auto-dial; an unmatched token is ignored.
 *
 * Kept as an `object` (like [CallRegistry]) because the notification-building service and
 * the activity are created independently by the OS and need a shared point to talk through.
 */
object PendingCallback {

    private val rng = SecureRandom()

    /** token -> number for every armed-but-not-yet-consumed call-back. Bounded so a run of
     *  never-tapped notifications can't grow it without limit. */
    private val pending = LinkedHashMap<Long, String>()

    private const val MAX_PENDING = 16

    /** Arms a trusted call-back for [number] and returns its one-shot token, to be carried
     *  in the Call back intent's extras. */
    @Synchronized
    fun arm(number: String): Long {
        var token = rng.nextLong()
        // Astronomically unlikely, but never hand out a token already in flight.
        while (token == 0L || pending.containsKey(token)) token = rng.nextLong()
        if (pending.size >= MAX_PENDING) {
            val oldest = pending.keys.firstOrNull()
            if (oldest != null) pending.remove(oldest)
        }
        pending[token] = number
        return token
    }

    /** Returns and clears the number for [token] iff it matches an armed call-back
     *  (one-shot, so a re-read can't dial twice), else null. */
    @Synchronized
    fun take(token: Long): String? = pending.remove(token)

    /** Drops [token] without dialing (used when the user dismisses the notification). */
    @Synchronized
    fun drop(token: Long) {
        pending.remove(token)
    }
}
