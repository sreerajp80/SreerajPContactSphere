package `in`.sreerajp.contact_sphere

import android.content.ComponentName
import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager

/**
 * Places outgoing calls through Telecom, from any [Context].
 *
 * Lives outside [MainActivity] because a call must also be placeable with no
 * activity (and no Flutter engine) alive at all — a Smart Redial alarm firing
 * while the app is closed goes through [SmartRedialReceiver], which has only a
 * broadcast context. [MainActivity] uses the same code for its own dialing so
 * there is one implementation of "how this app places a call".
 */
object TelecomCaller {

    /** Whether this app currently holds the default-dialer role. */
    fun isDefaultDialer(context: Context): Boolean =
        context.packageName == telecom(context)?.defaultDialerPackage

    /**
     * Places a call to [number], routed over the SIM identified by
     * [phoneAccountId] + [componentName] when both are given (otherwise Telecom
     * uses the system default, or prompts). Returns whether Telecom accepted it.
     *
     * Requires the default-dialer role: only then may the app place a call while
     * it has no visible UI, which is the whole point for the alarm path.
     */
    fun placeCall(
        context: Context,
        number: String?,
        phoneAccountId: String?,
        componentName: String?,
    ): Boolean {
        if (number.isNullOrBlank() || !isDefaultDialer(context)) return false
        val tm = telecom(context) ?: return false
        return try {
            val uri = Uri.fromParts("tel", number, null)
            val extras = Bundle()
            if (!phoneAccountId.isNullOrBlank() && !componentName.isNullOrBlank()) {
                val cn = ComponentName.unflattenFromString(componentName)
                if (cn != null) {
                    extras.putParcelable(
                        TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE,
                        PhoneAccountHandle(cn, phoneAccountId),
                    )
                }
            }
            tm.placeCall(uri, extras)
            true
        } catch (e: SecurityException) {
            // CALL_PHONE not granted yet; caller falls back to its own path.
            false
        } catch (e: Exception) {
            // Some OEM builds throw on a malformed account handle; never crash
            // a broadcast receiver over a call we can still fall back for.
            false
        }
    }

    private fun telecom(context: Context): TelecomManager? =
        context.getSystemService(TelecomManager::class.java)
}
