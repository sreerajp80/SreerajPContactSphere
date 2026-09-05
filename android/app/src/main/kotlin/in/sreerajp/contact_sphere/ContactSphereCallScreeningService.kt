package `in`.sreerajp.contact_sphere

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import org.json.JSONArray
import org.json.JSONObject

/**
 * Screens every incoming call *before it rings*. The system binds this
 * (guarded by BIND_SCREENING_SERVICE) automatically while ContactSphere is the
 * default phone app.
 *
 * Decisions come from the screening mirror — the blocked/spam number lists and
 * the Identification toggles the Flutter side keeps copied into a plain native
 * SharedPreferences file (see MainActivity.setScreeningMirror), so screening
 * works synchronously even on a cold start with no Flutter engine running:
 *  - number in the blocked list → reject (no ring, no notification; the call
 *    is parked in [KEY_BLOCKED_EVENTS] for the Flutter side to write into
 *    Recents, and the system call log records it as blocked);
 *  - no/hidden number while "Block unknown callers" is on → reject;
 *  - spam filter on and the number is user-marked spam or in India's TRAI
 *    `140` telemarketing series → allow but silence the ring (API 29+; older
 *    releases ring normally and rely on the in-app label);
 *  - otherwise → allow untouched.
 *
 * Numbers are matched on digit strings: exact equality, or one being a
 * suffix of the other with at least [MIN_SUFFIX_DIGITS] digits — so a stored
 * "+91 98765 43210" still matches an incoming national "9876543210".
 * Best-effort throughout: any failure must fall through to allowing the call.
 */
class ContactSphereCallScreeningService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        // Q+ can also hand the default dialer its *outgoing* calls — never touch those.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            callDetails.callDirection != Call.Details.DIRECTION_INCOMING
        ) {
            respondToCall(callDetails, CallResponse.Builder().build())
            return
        }
        val response = try {
            screen(callDetails)
        } catch (e: Exception) {
            // Screening must never break call delivery.
            CallResponse.Builder().build()
        }
        respondToCall(callDetails, response)
    }

    private fun screen(callDetails: Call.Details): CallResponse {
        val prefs = getSharedPreferences(SCREENING_PREFS, Context.MODE_PRIVATE)
        val number = callDetails.handle?.schemeSpecificPart
        val digits = number?.filter { it.isDigit() } ?: ""

        // The caller is ringing right now, so any Smart Redial reminder scheduled
        // for this number is moot — cancel it before the phone even rings. Runs
        // regardless of block/spam outcome, and works even when the Flutter side
        // isn't running (this service is bound natively as the default dialer).
        if (digits.isNotEmpty()) {
            try {
                SmartRedialManager.cancelForNumber(applicationContext, digits)
            } catch (e: Exception) {
                // Best-effort; must never break call delivery.
            }
        }

        if (digits.isEmpty()) {
            return if (prefs.getBoolean(KEY_BLOCK_UNKNOWN, false)) {
                recordBlockedCall(prefs, number?.takeIf { it.isNotBlank() } ?: "Unknown")
                reject()
            } else {
                allow()
            }
        }
        if (matchesList(digits, readList(prefs, KEY_BLOCKED))) {
            recordBlockedCall(prefs, number ?: digits)
            return reject()
        }
        if (prefs.getBoolean(KEY_SPAM_FILTER, false) &&
            (matchesList(digits, readList(prefs, KEY_SPAM)) || isTelemarketerSeries(digits))
        ) {
            return silence()
        }

        // Relationship-tier quiet hours: silence non-allowed calls during night hours.
        if (prefs.getBoolean(KEY_QUIET_HOURS_ENABLED, false)) {
            val start = prefs.getString(KEY_QUIET_HOURS_START, "22:00") ?: "22:00"
            val end = prefs.getString(KEY_QUIET_HOURS_END, "07:00") ?: "07:00"
            if (isTimeInQuietHours(start, end)) {
                val allowedNumbers = readList(prefs, KEY_QUIET_HOURS_ALLOWED_NUMBERS)
                if (!matchesList(digits, allowedNumbers)) {
                    return silence()
                }
            }
        }

        return allow()
    }

    private fun allow(): CallResponse = CallResponse.Builder().build()

    /** No ring, no missed-call notification; the system logs it as blocked. */
    private fun reject(): CallResponse = CallResponse.Builder()
        .setDisallowCall(true)
        .setRejectCall(true)
        .setSkipCallLog(false)
        .setSkipNotification(true)
        .build()

    /** The call proceeds (and is answerable) but rings silently. Silencing
     *  arrived with API 29; older releases just ring and show the label. */
    private fun silence(): CallResponse =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            CallResponse.Builder().setSilenceCall(true).build()
        } else {
            allow()
        }

    // ---- Matching ----

    /** India's TRAI telemarketing series: a 10-digit national number starting
     *  `140`, tolerating a leading country code (91) or trunk zero. Mirrors the
     *  Dart-side CallerIdService.identifyBySeries. */
    private fun isTelemarketerSeries(digits: String): Boolean {
        var n = digits
        if (n.length == 12 && n.startsWith("91")) n = n.substring(2)
        if (n.length == 11 && n.startsWith("0")) n = n.substring(1)
        return n.length >= 10 && n.startsWith("140")
    }

    /** Returns true if current local time is within [startStr] and [endStr] ("HH:mm"). */
    private fun isTimeInQuietHours(startStr: String, endStr: String): Boolean {
        return try {
            val startParts = startStr.split(":").map { it.toInt() }
            val endParts = endStr.split(":").map { it.toInt() }
            if (startParts.size != 2 || endParts.size != 2) return false

            val now = java.util.Calendar.getInstance()
            val currentMinutes =
                now.get(java.util.Calendar.HOUR_OF_DAY) * 60 + now.get(java.util.Calendar.MINUTE)
            val startMinutes = startParts[0] * 60 + startParts[1]
            val endMinutes = endParts[0] * 60 + endParts[1]

            if (startMinutes < endMinutes) {
                currentMinutes in startMinutes until endMinutes
            } else if (startMinutes > endMinutes) {
                currentMinutes >= startMinutes || currentMinutes < endMinutes
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    companion object {
        /** Native mirror of the Flutter-side screening data (see MainActivity). */
        const val SCREENING_PREFS = "contact_sphere_screening"

        /** JSON array of digit strings (E.164 digits) that never ring. */
        const val KEY_BLOCKED = "blocked_numbers"

        /** JSON array of digit strings the user marked as spam. */
        const val KEY_SPAM = "spam_numbers"

        /** Reject calls that carry no / a hidden number. */
        const val KEY_BLOCK_UNKNOWN = "block_unknown"

        /** Silence suspected-spam calls instead of ringing loudly. */
        const val KEY_SPAM_FILTER = "spam_filter"

        /** Enable relationship-tier quiet hours call silencing. */
        const val KEY_QUIET_HOURS_ENABLED = "quiet_hours_enabled"

        /** Start time for quiet hours ("HH:mm"). */
        const val KEY_QUIET_HOURS_START = "quiet_hours_start"

        /** End time for quiet hours ("HH:mm"). */
        const val KEY_QUIET_HOURS_END = "quiet_hours_end"

        /** JSON array of allowed digit strings during quiet hours. */
        const val KEY_QUIET_HOURS_ALLOWED_NUMBERS = "quiet_hours_allowed_numbers"

        /** JSON array of `{number, at}` for calls rejected while the app was
         *  down, drained one-shot via MainActivity.getBlockedCallEvents. */
        const val KEY_BLOCKED_EVENTS = "blocked_events"

        /** Minimum overlap for a suffix match (below this: exact only). */
        const val MIN_SUFFIX_DIGITS = 9

        private const val MAX_EVENTS = 200

        fun readList(prefs: SharedPreferences, key: String): List<String> {
            val raw = prefs.getString(key, null) ?: return emptyList()
            return try {
                val arr = JSONArray(raw)
                List(arr.length()) { arr.optString(it) }.filter { it.isNotBlank() }
            } catch (e: Exception) {
                emptyList()
            }
        }

        fun matchesList(digits: String, list: List<String>): Boolean =
            list.any { sameNumber(digits, it) }

        /** Exact digit equality, or a ≥[MIN_SUFFIX_DIGITS]-digit suffix match — so
         *  country-code variants ("+91…" vs national) of one number still agree,
         *  while short codes only ever match exactly. */
        fun sameNumber(a: String, b: String): Boolean {
            if (a == b) return true
            val (shorter, longer) = if (a.length < b.length) a to b else b to a
            return shorter.length >= MIN_SUFFIX_DIGITS && longer.endsWith(shorter)
        }

        /** Appends `{number, at}` to the parked blocked-call events, capped at
         *  [MAX_EVENTS] (oldest dropped) so the prefs entry can't grow unbounded
         *  if the app isn't opened for a long time. */
        fun recordBlockedCall(prefs: SharedPreferences, number: String) {
            try {
                val arr = prefs.getString(KEY_BLOCKED_EVENTS, null)?.let {
                    try { JSONArray(it) } catch (e: Exception) { JSONArray() }
                } ?: JSONArray()
                arr.put(
                    JSONObject()
                        .put("number", number)
                        .put("at", System.currentTimeMillis()),
                )
                val trimmed = if (arr.length() > MAX_EVENTS) {
                    JSONArray().also { out ->
                        for (i in arr.length() - MAX_EVENTS until arr.length()) {
                            out.put(arr.get(i))
                        }
                    }
                } else {
                    arr
                }
                prefs.edit().putString(KEY_BLOCKED_EVENTS, trimmed.toString()).apply()
            } catch (e: Exception) {
                // Journal is best-effort; blocking itself already succeeded.
            }
        }
    }
}
