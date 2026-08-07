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
 * Owns Smart Redial's scheduled auto-call-back tasks natively, so they survive
 * the Flutter engine / app process being killed while the user-chosen delay
 * (1-30 min) elapses — which Android routinely does in the background.
 *
 * Each task is persisted to [PREFS] (id, one-shot [token], number, display
 * name, the SIM chosen when it was scheduled, fire time) and mirrored as an
 * [AlarmManager] alarm that fires a broadcast to [SmartRedialReceiver] with the
 * task id and token. The receiver places the call itself, with no activity and
 * no Flutter engine involved, so a closed app dials on time.
 *
 * A broadcast (rather than an activity launch) is deliberate: launching an
 * activity from a background alarm is exactly what Android restricts, and the
 * call does not need any UI of our own — once Telecom has the call, our
 * [ContactSphereInCallService] is bound by the system and brings up the in-call
 * screen by itself.
 *
 * [consume] is the one-shot trust check: a fire only dials when the intent's
 * token matches the still-pending task's on-disk token — the same shape as the
 * missed-call notification's "Call back" ([PendingCallback]), except the token
 * lives on disk (not just in memory) since it must survive the app process
 * being killed for the whole delay, not just a few seconds.
 *
 * [MainActivity.ACTION_SMART_REDIAL_FIRE] still exists as the fallback path,
 * used when the receiver cannot place the call itself (we are not the default
 * dialer, or the permission was revoked) and posts a "tap to call" notification
 * instead. That activity is exported, so a crafted external intent could send
 * the action with a guessed id; even then it can only ever dial a number *we*
 * already scheduled (never an attacker-chosen one), and only once.
 */
object SmartRedialManager {

    private const val PREFS = "contact_sphere_smart_redial"
    private const val KEY_TASKS = "tasks"

    private val rng = SecureRandom()

    /**
     * A pending task as [consume] hands it back: everything the fire path needs
     * to place the call without asking the user anything.
     */
    data class Task(
        val number: String,
        val displayName: String,
        val phoneAccountId: String?,
        val componentName: String?,
    )

    /**
     * Arms a native alarm to auto-dial [number] at [fireAtMillis], replacing
     * any existing task with the same [id]. Returns whether the alarm was
     * actually armed — the task is only persisted on success, so a failure
     * (e.g. the exact-alarm permission isn't granted) never leaves behind a
     * record that looks "pending" forever with no real alarm behind it.
     *
     * [phoneAccountId] / [componentName] are the SIM to dial on, resolved by
     * the Flutter side when the reminder was scheduled (the SIM of the call
     * that went unanswered, else the user's default). Storing it here is what
     * lets the fire path skip the SIM chooser — an unattended retry has nobody
     * to answer it. Null/blank means "let Telecom use the system default".
     */
    @Synchronized
    fun schedule(
        context: Context,
        id: String,
        number: String,
        displayName: String,
        fireAtMillis: Long,
        phoneAccountId: String? = null,
        componentName: String? = null,
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
                .put("number", number)
                .put("displayName", displayName)
                // Stored as "" rather than JSON null: org.json's optString maps
                // a JSON null to the literal string "null", which would then be
                // handed to Telecom as a phone account id.
                .put("phoneAccountId", phoneAccountId.orEmpty())
                .put("componentName", componentName.orEmpty())
                .put("fireAtMillis", fireAtMillis),
        )
        writeTasks(prefs, tasks)
        return true
    }

    /** Cancels a pending task by [id] (no-op if already fired/cancelled). */
    @Synchronized
    fun cancel(context: Context, id: String) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val tasks = readTasks(prefs)
        val removed = tasks.removeAll { it.optString("id") == id }
        if (!removed) return
        writeTasks(prefs, tasks)
        cancelAlarm(context, id)
    }

    /** Cancels every pending task whose number matches [digits] (suffix match,
     *  mirroring [ContactSphereCallScreeningService.sameNumber]) — used when
     *  the scheduled contact calls back before their reminder fired. */
    @Synchronized
    fun cancelForNumber(context: Context, digits: String) {
        if (digits.isEmpty()) return
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val tasks = readTasks(prefs)
        val matching = tasks.filter { sameNumber(digits, numberDigits(it.optString("number"))) }
        if (matching.isEmpty()) return
        tasks.removeAll { t -> matching.any { it.optString("id") == t.optString("id") } }
        writeTasks(prefs, tasks)
        for (t in matching) cancelAlarm(context, t.optString("id"))
    }

    /** Ids of every task still pending (not yet fired or cancelled), so the
     *  Flutter-side UI list can reconcile itself against the native truth. */
    @Synchronized
    fun pendingIds(context: Context): List<String> {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return readTasks(prefs).map { it.optString("id") }
    }

    /** One-shot: if [id]/[token] match a pending task, removes it and returns
     *  it; otherwise returns null without side effects. */
    @Synchronized
    fun consume(context: Context, id: String, token: Long): Task? {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val tasks = readTasks(prefs)
        val match = tasks.firstOrNull { it.optString("id") == id && it.optLong("token") == token }
            ?: return null
        tasks.remove(match)
        writeTasks(prefs, tasks)
        val number = match.optString("number").ifBlank { null } ?: return null
        return Task(
            number = number,
            displayName = match.optString("displayName").ifBlank { number },
            phoneAccountId = match.optString("phoneAccountId").ifBlank { null },
            componentName = match.optString("componentName").ifBlank { null },
        )
    }

    /** Re-arms every task still in the future after a reboot (alarms don't
     *  survive one); drops any that were due while the phone was off, so the
     *  user never gets a surprise call for a stale reminder. */
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

    /** Whether the app is currently allowed to schedule exact/alarm-clock
     *  alarms. Always true below API 31, where this isn't gated. */
    fun hasExactAlarmPermission(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return false
        return alarmManager.canScheduleExactAlarms()
    }

    /** Opens the system "Alarms & reminders" settings screen for this app, so
     *  the user can grant [hasExactAlarmPermission] — there is no runtime
     *  request dialog for this permission, only this settings screen. No-op
     *  below API 31. */
    fun requestExactAlarmPermission(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        try {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.fromParts("package", context.packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            // Some OEM builds don't ship this screen; nothing more we can do.
        }
    }

    // ---- Alarm plumbing ----

    /**
     * Uses [AlarmManager.setAlarmClock] rather than `setExact(AndAllowWhileIdle)`:
     * it is the strongest "wake the device at exactly this time" guarantee
     * Android offers, and Doze never defers it. The alarm delivers a *broadcast*
     * to [SmartRedialReceiver], which places the call itself — broadcasts are
     * not subject to the background-activity-launch limits an alarm-launched
     * Activity has to fight, and no UI of ours is needed to dial.
     *
     * `setAlarmClock` requires [hasExactAlarmPermission] to be granted
     * (confirmed on-device: it throws `SecurityException` otherwise) — the
     * caller is expected to have checked that before scheduling; this only
     * guards against it being revoked in the gap between that check and this
     * call.
     *
     * Shows Android's standard small alarm-clock status-bar icon while a
     * redial is pending (tapping it opens the app via [showIntent]) — normal,
     * expected behaviour for this API, not specific to this app.
     *
     * Returns whether the alarm was actually armed — callers must not persist
     * a task record when this is false, or it would look "pending" forever
     * with no real alarm ever able to fire or cancel it.
     */
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
            // Permission revoked between the caller's check and this call;
            // nothing more we can do here than leave the reminder unarmed.
            false
        }
    }

    private fun cancelAlarm(context: Context, id: String) {
        val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return
        // Token doesn't matter for cancellation: PendingIntent equality is by
        // action/component/request code, not extras.
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
        val intent = Intent(context, SmartRedialReceiver::class.java).apply {
            action = SmartRedialReceiver.ACTION_FIRE
            putExtra(MainActivity.EXTRA_SMART_REDIAL_ID, id)
            putExtra(MainActivity.EXTRA_SMART_REDIAL_TOKEN, token)
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

    // ---- Storage ----

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

    // ---- Number matching (mirrors ContactSphereCallScreeningService.sameNumber) ----

    private fun numberDigits(number: String?): String = number?.filter { it.isDigit() } ?: ""

    private fun sameNumber(a: String, b: String): Boolean {
        if (a.isEmpty() || b.isEmpty()) return false
        if (a == b) return true
        val (shorter, longer) = if (a.length < b.length) a to b else b to a
        return shorter.length >= MIN_SUFFIX_DIGITS && longer.endsWith(shorter)
    }

    private const val MIN_SUFFIX_DIGITS = 9
}
