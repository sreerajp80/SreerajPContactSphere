package `in`.sreerajp.contact_sphere

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.provider.Settings
import org.json.JSONArray
import org.json.JSONObject
import java.security.SecureRandom

/**
 * Manages generic persistent scheduled notifications natively using [AlarmManager],
 * ensuring they fire at the specified time even if the app process or Flutter
 * engine is terminated by Android in the background.
 */
object NotificationSchedulerManager {

    private const val PREFS = "contact_sphere_scheduled_notifications"
    private const val KEY_TASKS = "tasks"

    private val rng = SecureRandom()

    data class Task(
        val id: String,
        val title: String,
        val body: String,
        val fireAtMillis: Long,
        val payload: String?,
        val category: String?,
    )

    @Synchronized
    fun schedule(
        context: Context,
        id: String,
        title: String,
        body: String,
        fireAtMillis: Long,
        payload: String? = null,
        category: String? = null,
    ): Boolean {
        var token = rng.nextLong()
        while (token == 0L) token = rng.nextLong()

        if (!armAlarm(context, id, token, fireAtMillis)) return false

        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val tasks = readTasks(prefs)
        tasks.removeAll { it.optString("id") == id }
        tasks.add(
            JSONObject()
                .put("id", id)
                .put("token", token)
                .put("title", title)
                .put("body", body)
                .put("fireAtMillis", fireAtMillis)
                .put("payload", payload.orEmpty())
                .put("category", category.orEmpty()),
        )
        writeTasks(prefs, tasks)
        return true
    }

    @Synchronized
    fun cancel(context: Context, id: String) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val tasks = readTasks(prefs)
        val removed = tasks.removeAll { it.optString("id") == id }
        if (!removed) return
        writeTasks(prefs, tasks)
        cancelAlarm(context, id)
    }

    @Synchronized
    fun pendingIds(context: Context): List<String> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return readTasks(prefs).map { it.optString("id") }
    }

    @Synchronized
    fun consume(context: Context, id: String, token: Long): Task? {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val tasks = readTasks(prefs)
        val match = tasks.firstOrNull { it.optString("id") == id && it.optLong("token") == token }
            ?: return null
        tasks.remove(match)
        writeTasks(prefs, tasks)
        val title = match.optString("title").ifBlank { "Reminder" }
        val body = match.optString("body")
        return Task(
            id = id,
            title = title,
            body = body,
            fireAtMillis = match.optLong("fireAtMillis"),
            payload = match.optString("payload").ifBlank { null },
            category = match.optString("category").ifBlank { null },
        )
    }

    @Synchronized
    fun rescheduleAfterBoot(context: Context) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val tasks = readTasks(prefs)
        val now = System.currentTimeMillis()
        val stillPending = mutableListOf<JSONObject>()
        for (t in tasks) {
            val fireAt = t.optLong("fireAtMillis")
            if (fireAt > now && armAlarm(context, t.optString("id"), t.optLong("token"), fireAt)) {
                stillPending.add(t)
            }
        }
        writeTasks(prefs, stillPending)
    }

    fun hasExactAlarmPermission(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return false
        return alarmManager.canScheduleExactAlarms()
    }

    fun requestExactAlarmPermission(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        try {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.fromParts("package", context.packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            // Best effort
        }
    }

    private fun armAlarm(context: Context, id: String, token: Long, fireAtMillis: Long): Boolean {
        val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return false
        val pi = firePendingIntent(context, id, token) ?: return false
        val showIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            piFlags(),
        )
        return try {
            alarmManager.setAlarmClock(
                AlarmManager.AlarmClockInfo(fireAtMillis, showIntent),
                pi,
            )
            true
        } catch (e: SecurityException) {
            false
        }
    }

    private fun cancelAlarm(context: Context, id: String) {
        val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return
        val pi = firePendingIntent(context, id, token = 0L, forCancel = true) ?: return
        alarmManager.cancel(pi)
        pi.cancel()
    }

    private fun firePendingIntent(
        context: Context,
        id: String,
        token: Long,
        forCancel: Boolean = false,
    ): PendingIntent? {
        val intent = Intent(context, ScheduledNotificationReceiver::class.java).apply {
            action = ScheduledNotificationReceiver.ACTION_FIRE
            putExtra(ScheduledNotificationReceiver.EXTRA_NOTIFICATION_ID, id)
            putExtra(ScheduledNotificationReceiver.EXTRA_NOTIFICATION_TOKEN, token)
        }
        var flags = if (forCancel) PendingIntent.FLAG_NO_CREATE else PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        return PendingIntent.getBroadcast(context, id.hashCode(), intent, flags)
    }

    private fun piFlags(): Int {
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        return flags
    }

    private fun readTasks(prefs: SharedPreferences): MutableList<JSONObject> {
        val raw = prefs.getString(KEY_TASKS, null) ?: return mutableListOf()
        return try {
            val arr = JSONArray(raw)
            MutableList(arr.length()) { arr.getJSONObject(it) }
        } catch (e: Exception) {
            mutableListOf()
        }
    }

    private fun writeTasks(prefs: SharedPreferences, tasks: List<JSONObject>) {
        val arr = JSONArray()
        for (t in tasks) arr.put(t)
        prefs.edit().putString(KEY_TASKS, arr.toString()).apply()
    }
}
