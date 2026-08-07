package `in`.sreerajp.contact_sphere

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

import android.net.Uri
import org.json.JSONObject

/**
 * Owns the published emergency card: the plaintext copy in our own
 * SharedPreferences and the lock-screen notification that opens it.
 *
 * Why a plaintext copy at all: the card has to be readable while the phone is
 * locked, so it cannot come from the SQLCipher database (before the first
 * unlock the Keystore-held key may be unavailable, and starting the Flutter
 * engine on the keyguard is slow and unreliable). Flutter pushes only the
 * fields the user explicitly switched on — the master record stays encrypted.
 * Same pattern as the missed-call name mirror; see docs/security.md.
 */
object EmergencyCardNotifier {
    const val EMERGENCY_PREFS = "contact_sphere_emergency"
    const val KEY_CARD_JSON = "card_json"

    /**
     * v2 because the first channel was created at [NotificationManager.IMPORTANCE_LOW],
     * which Android files as a *silent* notification — and the lock screen hides
     * silent notifications whenever "Hide silent conversations and notifications"
     * is on (the default on many devices). A channel's importance cannot be
     * changed after it is created, so the only way out is a new channel id.
     */
    const val CHANNEL_ID = "emergency_info_v2"
    private const val LEGACY_CHANNEL_ID = "emergency_info"
    private const val NOTIFICATION_ID = 9701

    /** Stores [json] as the published card and (re)posts the notification. */
    fun publish(context: Context, json: String) {
        context.applicationContext
            .getSharedPreferences(EMERGENCY_PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_CARD_JSON, json)
            .apply()
        postNotification(context)
    }

    /** Removes the published card and its notification. */
    fun clear(context: Context) {
        context.applicationContext
            .getSharedPreferences(EMERGENCY_PREFS, Context.MODE_PRIVATE)
            .edit()
            .remove(KEY_CARD_JSON)
            .apply()
        context.getSystemService(NotificationManager::class.java)
            ?.cancel(NOTIFICATION_ID)
    }

    /** The published card, or null when the feature is off. */
    fun readCard(context: Context): String? =
        context.applicationContext
            .getSharedPreferences(EMERGENCY_PREFS, Context.MODE_PRIVATE)
            .getString(KEY_CARD_JSON, null)

    /**
     * Re-posts the notification if a card is published, otherwise does nothing.
     * Called after a reboot (notifications don't survive one) and when the app
     * starts.
     */
    fun refresh(context: Context) {
        if (readCard(context) == null) return
        postNotification(context)
    }

    private fun postNotification(context: Context) {
        val mgr = context.getSystemService(NotificationManager::class.java) ?: return
        createChannel(mgr)
        val cardJsonStr = readCard(context) ?: return
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context).setPriority(Notification.PRIORITY_LOW)
        }

        var primaryName: String? = null
        var primaryNumber: String? = null
        try {
            val json = JSONObject(cardJsonStr)
            val contacts = json.optJSONArray("contacts")
            if (contacts != null && contacts.length() > 0) {
                val first = contacts.optJSONObject(0)
                if (first != null) {
                    primaryName = first.optString("name").trim()
                    primaryNumber = first.optString("number").trim()
                }
            }
        } catch (_: Exception) {}

        val subtext = if (!primaryName.isNullOrEmpty()) "ICE: $primaryName — Tap to view" else "Tap to view — no unlock needed"

        builder
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Emergency info")
            .setContentText(subtext)
            // PUBLIC so the title/text are readable on the lock screen even when
            // the user hides sensitive notification content.
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setCategory(Notification.CATEGORY_STATUS)
            // Ongoing: an emergency card that can be swiped away by accident is
            // no use to a first responder.
            .setOngoing(true)
            .setShowWhen(false)
            .setContentIntent(cardIntent(context))

        if (!primaryNumber.isNullOrEmpty()) {
            val dialIntent = Intent(Intent.ACTION_CALL, Uri.parse("tel:$primaryNumber")).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            var flags = PendingIntent.FLAG_UPDATE_CURRENT
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                flags = flags or PendingIntent.FLAG_IMMUTABLE
            }
            val pendingCall = PendingIntent.getActivity(context, 1, dialIntent, flags)
            val actionTitle = if (!primaryName.isNullOrEmpty()) "1-TAP CALL $primaryName" else "1-TAP EMERGENCY CALL"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val action = Notification.Action.Builder(
                    android.R.drawable.ic_menu_call,
                    actionTitle,
                    pendingCall
                ).build()
                builder.addAction(action)
            } else {
                @Suppress("DEPRECATION")
                builder.addAction(android.R.drawable.ic_menu_call, actionTitle, pendingCall)
            }
        }

        val notification = builder.build()
        // No-op if notifications are denied (API 33+ POST_NOTIFICATIONS).
        mgr.notify(NOTIFICATION_ID, notification)
    }

    private fun cardIntent(context: Context): PendingIntent {
        val intent = Intent(context, EmergencyInfoActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        }
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        return PendingIntent.getActivity(context, 0, intent, flags)
    }

    private fun createChannel(mgr: NotificationManager) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        // The old LOW channel would otherwise linger as a dead entry in the
        // system notification settings for this app.
        if (mgr.getNotificationChannel(LEGACY_CHANNEL_ID) != null) {
            mgr.deleteNotificationChannel(LEGACY_CHANNEL_ID)
        }
        if (mgr.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Emergency info",
            // DEFAULT, not LOW: anything below DEFAULT counts as "silent" and the
            // lock screen may filter it out. Sound and vibration are switched off
            // below, so the card is still quiet — it just is not classed silent.
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Lock-screen shortcut to your emergency info card"
            setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setSound(null, null)
            enableVibration(false)
            enableLights(false)
        }
        mgr.createNotificationChannel(channel)
    }

    /**
     * What the system currently allows, so the app can tell the user why the card
     * is not on the lock screen instead of failing quietly.
     *
     * - `notificationsEnabled` — false when POST_NOTIFICATIONS is denied or the
     *   user switched this app's notifications off. Nothing shows anywhere.
     * - `channelBlocked` — the channel itself was turned off.
     * - `channelSilent` — the channel was turned down below DEFAULT, so the lock
     *   screen may hide it (this is what the old v1 channel did by default).
     *
     * Whether the lock screen hides silent notifications is a system-wide setting
     * with no API to read, so the app cannot report that part — it can only point
     * the user at the setting.
     */
    fun notificationStatus(context: Context): Map<String, Any> {
        val mgr = context.getSystemService(NotificationManager::class.java)
        val enabled = mgr?.areNotificationsEnabled() ?: false
        var blocked = false
        var silent = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = mgr?.getNotificationChannel(CHANNEL_ID)
            if (channel != null) {
                blocked = channel.importance == NotificationManager.IMPORTANCE_NONE
                silent = channel.importance in
                    (NotificationManager.IMPORTANCE_MIN..NotificationManager.IMPORTANCE_LOW)
            }
        }
        return mapOf(
            "notificationsEnabled" to enabled,
            "channelBlocked" to blocked,
            "channelSilent" to silent,
            "published" to (readCard(context) != null),
        )
    }
}
