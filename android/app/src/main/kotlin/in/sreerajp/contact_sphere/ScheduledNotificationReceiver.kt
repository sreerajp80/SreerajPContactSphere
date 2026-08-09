package `in`.sreerajp.contact_sphere

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Fires generic scheduled notifications armed by [NotificationSchedulerManager].
 *
 * Runs natively from [AlarmManager] when the scheduled time is due, so it works
 * even when the app is completely closed.
 */
class ScheduledNotificationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != ACTION_FIRE) return
        val id = intent.getStringExtra(EXTRA_NOTIFICATION_ID) ?: return
        val token = intent.getLongExtra(EXTRA_NOTIFICATION_TOKEN, 0L)
        if (id.isBlank()) return

        val task = NotificationSchedulerManager.consume(context, id, token) ?: return
        postNotification(context, task)
    }

    private fun postNotification(context: Context, task: NotificationSchedulerManager.Task) {
        val mgr = context.getSystemService(NotificationManager::class.java) ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            mgr.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    "Reminders & Notifications",
                    NotificationManager.IMPORTANCE_HIGH,
                ).apply {
                    description = "Scheduled contact reminders and alerts"
                },
            )
        }

        val launchIntent = Intent(context, MainActivity::class.java).apply {
            action = ACTION_NOTIFICATION_TAP
            if (!task.payload.isNullOrBlank()) {
                putExtra(EXTRA_PAYLOAD, task.payload)
            }
            putExtra(EXTRA_NOTIFICATION_ID, task.id)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }

        var piFlags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            piFlags = piFlags or PendingIntent.FLAG_IMMUTABLE
        }

        val contentPi = PendingIntent.getActivity(
            context,
            task.id.hashCode(),
            launchIntent,
            piFlags,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context).setPriority(Notification.PRIORITY_HIGH)
        }

        val notification = builder
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle(task.title)
            .setContentText(task.body)
            .setCategory(task.category ?: Notification.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(contentPi)
            .build()

        runCatching { mgr.notify(task.id.hashCode(), notification) }
    }

    companion object {
        const val ACTION_FIRE = "in.sreerajp.contact_sphere.SCHEDULED_NOTIFICATION_ALARM"
        const val ACTION_NOTIFICATION_TAP = "in.sreerajp.contact_sphere.NOTIFICATION_TAP"
        const val EXTRA_NOTIFICATION_ID = "scheduled_notification_id"
        const val EXTRA_NOTIFICATION_TOKEN = "scheduled_notification_token"
        const val EXTRA_PAYLOAD = "scheduled_notification_payload"
        private const val CHANNEL_ID = "scheduled_notifications"
    }
}
