package `in`.sreerajp.contact_sphere

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build

/**
 * Fires a scheduled Smart Redial: places the call the user asked us to retry.
 *
 * Runs from [SmartRedialManager]'s alarm, so it must work with the app fully
 * closed — that is the whole point of the feature. It therefore does the dialing
 * here, natively, instead of launching [MainActivity] and letting Flutter do it:
 * a cold-started Flutter UI only picks up a parked number after its first frame
 * and after App lock, neither of which happens while the app is closed, so the
 * call used to sit waiting until the user opened the app.
 *
 * No UI of ours is needed. Once Telecom accepts the call, the system binds
 * [ContactSphereInCallService], which brings up our in-call screen itself.
 *
 * The SIM was decided when the reminder was scheduled and travels with the task
 * ([SmartRedialManager.Task]) — an unattended retry has nobody to answer a SIM
 * chooser.
 */
class SmartRedialReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != ACTION_FIRE) return
        val id = intent.getStringExtra(MainActivity.EXTRA_SMART_REDIAL_ID)
        val token = intent.getLongExtra(MainActivity.EXTRA_SMART_REDIAL_TOKEN, 0L)
        if (id.isNullOrBlank()) return

        // One-shot: only a token matching a still-pending task dials, and the
        // task is dropped in the same step so it can never fire twice.
        val task = SmartRedialManager.consume(context, id, token) ?: return

        val placed = TelecomCaller.placeCall(
            context,
            task.number,
            task.phoneAccountId,
            task.componentName,
        )
        // Couldn't dial (not the default dialer any more, or the call permission
        // was revoked since scheduling): tell the user rather than silently
        // dropping a reminder they asked for. Tapping opens our dialer with the
        // number filled in, so the retry is one tap away.
        if (!placed) postFallbackNotification(context, task)
    }

    private fun postFallbackNotification(context: Context, task: SmartRedialManager.Task) {
        val mgr = context.getSystemService(NotificationManager::class.java) ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mgr.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "Scheduled redials",
                    NotificationManager.IMPORTANCE_HIGH,
                ).apply {
                    description = "When a scheduled call retry is due"
                },
            )
        }
        val dial = Intent(context, MainActivity::class.java).apply {
            // ACTION_VIEW on tel: opens the dialer pre-filled (never auto-dials
            // — see MainActivity.handleDialIntent), which is what we want here:
            // the user taps to place the call themselves.
            action = Intent.ACTION_VIEW
            data = Uri.fromParts("tel", task.number, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        var piFlags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            piFlags = piFlags or PendingIntent.FLAG_IMMUTABLE
        }
        val contentPi = PendingIntent.getActivity(
            context,
            task.number.hashCode(),
            dial,
            piFlags,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context).setPriority(Notification.PRIORITY_HIGH)
        }
        val notification = builder
            .setSmallIcon(android.R.drawable.stat_sys_phone_call)
            .setContentTitle("Time to call ${task.displayName}")
            .setContentText("Tap to call ${task.number}")
            .setCategory(Notification.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(contentPi)
            .build()
        // No-op when notifications are denied (API 33+ POST_NOTIFICATIONS).
        runCatching { mgr.notify(NOTIFICATION_ID, notification) }
    }

    companion object {
        const val ACTION_FIRE = "in.sreerajp.contact_sphere.SMART_REDIAL_ALARM"
        private const val CHANNEL_ID = "smart_redial"
        private const val NOTIFICATION_ID = 4242
    }
}
