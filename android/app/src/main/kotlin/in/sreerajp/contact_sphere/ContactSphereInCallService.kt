package `in`.sreerajp.contact_sphere

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Person
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telecom.Call
import android.telecom.CallAudioState
import android.telecom.InCallService
import android.telecom.TelecomManager
import org.json.JSONArray
import org.json.JSONObject

/**
 * The system binds this service (guarded by BIND_INCALL_SERVICE) once
 * ContactSphere is the default phone app, then routes every call through it.
 *
 * We forward call/audio-state to [CallRegistry] (which the Flutter UI observes)
 * and bring [MainActivity] to the front so our own in-call screen can show.
 *
 * Because the manifest declares IN_CALL_SERVICE_RINGING we own the incoming-call
 * ringing experience: the platform will NOT ring for us. As [CallRegistry.RingController]
 * this service therefore plays the ringtone (via [IncomingCallRinger]) and, for the
 * *whole* call, runs as a phoneCall foreground service posting a single call
 * notification that is swapped in place:
 *  - while ringing: a full-screen incoming notification (shows from background / over the
 *    lock screen), with Answer/Decline — demoted to a quiet status-bar entry whenever our
 *    own in-call UI is in the foreground so no heads-up banner covers it;
 *  - once answered / for outgoing calls: a rich ongoing-call notification with a live
 *    duration timer and hang-up / mute / speaker controls, tappable to return to the
 *    in-call screen after the user has switched to another app.
 * The action buttons route through [CallActionReceiver] back into [CallRegistry].
 */
class ContactSphereInCallService : InCallService(), CallRegistry.RingController {

    private var ringer: IncomingCallRinger? = null

    /** Schedules the delayed re-cancels of the platform's own missed-call
     *  notification (posted asynchronously after ours). */
    private val missedHandler = Handler(Looper.getMainLooper())

    /** The current call's number/name, kept so a later name push (or an audio-state
     *  change) can rebuild the notification without Telecom handing us the call again. */
    private var currentNumber: String? = null
    private var currentName: String? = null

    /** Identification label pushed from Flutter (e.g. "Suspected spam") for a
     *  caller who isn't a saved contact; shown on the call notification. */
    private var currentLabel: String? = null

    /** True once we've promoted to the foreground for the current call, so later updates
     *  post via NotificationManager rather than re-invoking startForeground. */
    private var inForeground = false

    /** True while a call is present, guarding stray name-push updates after the call ends. */
    private var hasCall = false

    /** Whether the currently posted notification is the ongoing (vs incoming) shape, so a
     *  name push re-posts the right one. */
    private var showingOngoing = false

    /** Registered while a call is present. When the screen turns back on (e.g. the phone
     *  leaves the ear and the proximity blank lifts, or the user wakes it to hang up), it
     *  re-shows our in-call UI over the lock screen so End Call is right there — otherwise
     *  a plain wake lands on the keyguard, not our screen. */
    private var screenOnReceiver: BroadcastReceiver? = null

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)

        // Defensive call screening: if CallScreeningService was bypassed by the OS,
        // intercept blocked or blocked-unknown incoming calls immediately before
        // ringing or showing UI.
        val prefs = getSharedPreferences(
            ContactSphereCallScreeningService.SCREENING_PREFS,
            Context.MODE_PRIVATE,
        )
        val number = call.details?.handle?.schemeSpecificPart
        val digits = number?.filter { it.isDigit() } ?: ""
        val blockUnknown = prefs.getBoolean(
            ContactSphereCallScreeningService.KEY_BLOCK_UNKNOWN,
            false,
        )
        val isBlocked = if (digits.isEmpty()) {
            blockUnknown
        } else {
            val blockedList = ContactSphereCallScreeningService.readList(
                prefs,
                ContactSphereCallScreeningService.KEY_BLOCKED,
            )
            ContactSphereCallScreeningService.matchesList(digits, blockedList)
        }

        if (isBlocked && call.state == Call.STATE_RINGING) {
            ContactSphereCallScreeningService.recordBlockedCall(
                prefs,
                number?.takeIf { it.isNotBlank() } ?: "Unknown",
            )
            call.reject(false, null)
            return
        }

        CallRegistry.attachService(this)
        CallRegistry.setRingController(this)
        CallRegistry.onCallAdded(call)
        launchInCallUi()
    }

    override fun onCallRemoved(call: Call) {
        super.onCallRemoved(call)
        CallRegistry.onCallRemoved(call)
    }

    override fun onCallAudioStateChanged(audioState: CallAudioState) {
        super.onCallAudioStateChanged(audioState)
        CallRegistry.onAudioStateChanged(audioState)
    }

    override fun onSilenceRinger() {
        super.onSilenceRinger()
        // The user asked the platform to silence the ringer — via the power button
        // or a flip / shake / pick-up-to-silence gesture. Because we own the ringing
        // experience (IN_CALL_SERVICE_RINGING) and play the tone ourselves, the
        // platform can't silence it for us; we must stop our own ringtone + vibration.
        // The call stays ringing so it can still be answered or declined.
        ringer?.stop()
        ringer = null
    }

    override fun onDestroy() {
        onCallEnded()
        CallRegistry.clearRingController(this)
        CallRegistry.detachService(this)
        super.onDestroy()
    }

    // ---- CallRegistry.RingController: notification + ringing lifecycle ----

    override fun startRinging(call: Call, callWaiting: Boolean) {
        val number = call.details?.handle?.schemeSpecificPart
        currentNumber = number
        hasCall = true
        showingOngoing = false
        registerScreenOnReceiver()
        // Start as quiet because launchInCallUi() immediately brings the full-screen
        // in-call screen to the front, avoiding a heads-up banner above our own screen.
        postCallNotification(buildCallNotification(currentNumber, currentName, ongoing = false, forceQuiet = true))
        if (ringer == null) ringer = IncomingCallRinger(this)
        if (callWaiting) {
            // A second call while one is already active: a short call-waiting beep
            // into the earpiece, not the loud ringtone (matches other dialers).
            ringer?.startCallWaiting()
        } else {
            // Number + SIM let the ringer resolve any mirrored contact/SIM tone
            // synchronously, so the right tone plays from the first note.
            ringer?.start(number, call.details?.accountHandle?.id)
        }
    }

    override fun setCustomRingtone(path: String?, source: String?) {
        ringer?.setCustomTone(path, source)
    }

    /**
     * Re-posts the current call notification with the contact name once the Flutter side
     * has resolved it (native has no access to the app's contact DB). Updates whichever
     * notification is up — ringing or ongoing, incoming or outgoing. A blank name clears
     * a previously pushed one (the number shows instead), so a stale name doesn't survive
     * the call's number changing (add call / swap). No-ops once the call has ended so a
     * late-arriving name doesn't resurrect a notification.
     */
    override fun updateCallerName(name: String?) {
        if (!hasCall) return
        currentName = if (name.isNullOrBlank()) null else name
        postCallNotification(buildCallNotification(currentNumber, currentName, showingOngoing))
    }

    /** Same re-post as [updateCallerName], for the identification label (e.g.
     *  "Suspected spam"). A blank label clears a previously pushed one. */
    override fun updateCallerLabel(label: String?) {
        if (!hasCall) return
        currentLabel = if (label.isNullOrBlank()) null else label
        postCallNotification(buildCallNotification(currentNumber, currentName, showingOngoing))
    }

    override fun onUiVisibilityChanged() {
        // Only the ringing shape is visibility-sensitive; a CallStyle ongoing notification
        // renders as a persistent entry (never a heads-up), so it needs no re-post here.
        if (!hasCall || showingOngoing) return
        val uiVisible = CallRegistry.isInCallUiVisible()
        if (uiVisible) {
            // When returning to the full-screen call UI, cancel any active heads-up
            // banner before re-posting the quiet notification so the banner immediately disappears.
            getSystemService(NotificationManager::class.java)?.cancel(CALL_NOTIFICATION_ID)
        }
        postCallNotification(buildCallNotification(currentNumber, currentName, ongoing = false))
    }

    override fun stopRinging() {
        // Only silences the ringtone; the foreground notification lives on for the call
        // (it becomes the ongoing-call notification via [showOngoingCall]).
        ringer?.stop()
        ringer = null
    }

    override fun showOngoingCall(number: String?) {
        if (!number.isNullOrBlank()) currentNumber = number
        hasCall = true
        showingOngoing = true
        registerScreenOnReceiver()
        // Ringing (if somehow still going) belongs to the ring phase only.
        ringer?.stop()
        ringer = null
        postCallNotification(buildCallNotification(currentNumber, currentName, ongoing = true))
    }

    override fun onCallEnded() {
        ringer?.stop()
        ringer = null
        currentNumber = null
        currentName = null
        currentLabel = null
        hasCall = false
        showingOngoing = false
        unregisterScreenOnReceiver()
        if (inForeground) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            inForeground = false
        }
    }

    /**
     * Registers (once) a receiver for [Intent.ACTION_SCREEN_ON]. On screen-on, if a call is
     * still present and our in-call UI isn't already in front, re-shows it over the lock
     * screen so the user can hang up without hunting for the app. SCREEN_ON can't be a
     * manifest receiver on modern Android, so we register it at runtime for the call's life.
     */
    private fun registerScreenOnReceiver() {
        if (screenOnReceiver != null) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (hasCall && !CallRegistry.isInCallUiVisible()) launchInCallUi()
            }
        }
        registerReceiver(receiver, IntentFilter(Intent.ACTION_SCREEN_ON))
        screenOnReceiver = receiver
    }

    private fun unregisterScreenOnReceiver() {
        screenOnReceiver?.let {
            // Guard against a double-unregister (e.g. onCallEnded then onDestroy).
            runCatching { unregisterReceiver(it) }
        }
        screenOnReceiver = null
    }

    // ---- Missed-call notification ----

    /**
     * Posts our own missed-call notification with a "Call back" action, then
     * dismisses the system's duplicate. Runs natively from [CallRegistry] when an
     * incoming call ends unanswered, so it works even when the Flutter engine isn't
     * up. The notification shows the caller's number (native has no contact DB; the
     * name is resolved by Flutter for the in-call notification only). No-op if
     * notifications are denied (API 33+ POST_NOTIFICATIONS) — the notify simply
     * doesn't appear.
     */
    override fun onMissedCall(number: String?, phoneAccountId: String?) {
        // Journaling a call-waiting miss for Recents is handled by
        // [onIncomingCallEnded]; here we only post the missed-call notification.
        val mgr = getSystemService(NotificationManager::class.java) ?: return
        createMissedChannel()
        val notifId = nextMissedId()
        val caller = resolveContactName(number) ?: number?.ifBlank { null } ?: "Unknown"
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, MISSED_CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this).setPriority(Notification.PRIORITY_DEFAULT)
        }
        builder
            .setSmallIcon(android.R.drawable.stat_notify_missed_call)
            .setContentTitle(caller)
            .setContentText("Missed call")
            .setCategory(Notification.CATEGORY_MISSED_CALL)
            .setAutoCancel(true)
            .setShowWhen(true)
            .setContentIntent(missedContentIntent(notifId))
        // Only offer "Call back" when we actually have a number to dial; its trusted
        // token also lets "Dismiss" drop the armed call-back. "Dismiss" is always shown.
        val token = if (!number.isNullOrBlank()) PendingCallback.arm(number) else 0L
        if (!number.isNullOrBlank()) builder.addAction(callBackAction(number, notifId, token))
        builder.addAction(dismissAction(notifId, token))
        mgr.notify(notifId, builder.build())
        // The platform posts its own missed-call notification asynchronously, often
        // *after* this immediate cancel — so also re-cancel a few times shortly after
        // to clear the late duplicate (we're the default dialer).
        cancelSystemMissedCallNotification()
        for (delay in SYSTEM_MISSED_CANCEL_DELAYS_MS) {
            missedHandler.postDelayed({ cancelSystemMissedCallNotification() }, delay)
        }
    }

    /**
     * A call-waiting incoming call ended: journal it for the Flutter side to drain
     * into Recents. It was never the primary the snapshot logger tracks, so only
     * this journal records it. [wasActive] tells an answered call (drained as
     * 'incoming' with [durationSeconds]) from a miss (drained as 'missed').
     */
    override fun onIncomingCallEnded(
        number: String?,
        phoneAccountId: String?,
        wasActive: Boolean,
        durationSeconds: Long,
    ) {
        journalIncomingCall(number, phoneAccountId, wasActive, durationSeconds)
    }

    /**
     * An outgoing call ended with a reason Telecom gave us: journal it for the
     * Flutter side to attach to the call's Recents row. Needed for calls the app
     * itself didn't place (a Smart Redial retry fired while the app was closed),
     * where nothing on the Dart side was holding a pending record to latch the
     * reason onto.
     */
    override fun onOutgoingCallEnded(number: String?, outcome: String, atMillis: Long) {
        journalOutgoingOutcome(number, outcome, atMillis)
    }

    /** Appends `{number, at, outcome}` to the parked outgoing-call outcomes (in
     *  the ringer prefs), capped at [MAX_MISSED_EVENTS] (oldest dropped). The
     *  Flutter side drains these and patches the matching Recents row — it never
     *  inserts, so a dropped entry costs only the reason, not the row.
     *  Best-effort. */
    private fun journalOutgoingOutcome(number: String?, outcome: String, atMillis: Long) {
        if (number.isNullOrBlank()) return
        try {
            val prefs = getSharedPreferences(
                IncomingCallRinger.RINGER_PREFS,
                Context.MODE_PRIVATE,
            )
            val arr = prefs.getString(IncomingCallRinger.KEY_OUTGOING_OUTCOMES, null)?.let {
                try { JSONArray(it) } catch (e: Exception) { JSONArray() }
            } ?: JSONArray()
            arr.put(
                JSONObject()
                    .put("number", number)
                    .put("at", atMillis)
                    .put("outcome", outcome),
            )
            val trimmed = if (arr.length() > MAX_MISSED_EVENTS) {
                JSONArray().also { out ->
                    for (i in arr.length() - MAX_MISSED_EVENTS until arr.length()) {
                        out.put(arr.get(i))
                    }
                }
            } else {
                arr
            }
            prefs.edit().putString(IncomingCallRinger.KEY_OUTGOING_OUTCOMES, trimmed.toString())
                .apply()
        } catch (e: Exception) {
            // Journal is best-effort; the row itself still gets written by the
            // device-log import, just without the reason.
        }
    }

    /** Appends `{number, at, phoneAccountId, wasActive, duration}` to the parked
     *  call-waiting events (in the ringer prefs), capped at [MAX_MISSED_EVENTS]
     *  (oldest dropped). The Flutter side drains these into Recents as 'incoming'
     *  or 'missed' rows. Best-effort. */
    private fun journalIncomingCall(
        number: String?,
        phoneAccountId: String?,
        wasActive: Boolean,
        durationSeconds: Long,
    ) {
        if (number.isNullOrBlank()) return
        try {
            val prefs = getSharedPreferences(
                IncomingCallRinger.RINGER_PREFS,
                Context.MODE_PRIVATE,
            )
            val arr = prefs.getString(IncomingCallRinger.KEY_MISSED_EVENTS, null)?.let {
                try { JSONArray(it) } catch (e: Exception) { JSONArray() }
            } ?: JSONArray()
            arr.put(
                JSONObject()
                    .put("number", number)
                    .put("at", System.currentTimeMillis())
                    .put("phoneAccountId", phoneAccountId)
                    .put("wasActive", wasActive)
                    .put("duration", durationSeconds),
            )
            val trimmed = if (arr.length() > MAX_MISSED_EVENTS) {
                JSONArray().also { out ->
                    for (i in arr.length() - MAX_MISSED_EVENTS until arr.length()) {
                        out.put(arr.get(i))
                    }
                }
            } else {
                arr
            }
            prefs.edit().putString(IncomingCallRinger.KEY_MISSED_EVENTS, trimmed.toString())
                .apply()
        } catch (e: Exception) {
            // Journal is best-effort; the notification already posted.
        }
    }

    /**
     * "Call back" action: a `getActivity` PendingIntent that launches [MainActivity]
     * directly so the app reliably comes to the front (a broadcast that then calls
     * `startActivity` is blocked as a notification trampoline on Android 12+). The
     * auto-call stays trusted via the one-shot [token] (armed in [PendingCallback]):
     * [MainActivity] only places the call when the intent's token matches, so a crafted
     * external intent to the exported activity cannot forge an auto-dial.
     */
    private fun callBackAction(number: String, notifId: Int, token: Long): Notification.Action {
        // The number itself is looked up from the armed [PendingCallback] by token in
        // MainActivity — never trusted from an extra — so a crafted intent can't pick a
        // number. We keep [number] here only for the request-code / action title.
        val intent = Intent(this, MainActivity::class.java).apply {
            action = MainActivity.ACTION_TRUSTED_CALL_BACK
            putExtra(MainActivity.EXTRA_TOKEN, token)
            putExtra(MainActivity.EXTRA_NOTIFICATION_ID, notifId)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        // A per-notification request code keeps each Call-back PendingIntent distinct.
        val pi = PendingIntent.getActivity(this, notifId, intent, piFlags())
        return Notification.Action.Builder(
            Icon.createWithResource(this, android.R.drawable.sym_action_call),
            "Call back",
            pi,
        ).build()
    }

    /** "Dismiss" action: a cancel-only broadcast to the non-exported [CallActionReceiver]
     *  that clears the notification and drops the armed call-back token. No activity is
     *  launched, so the notification-trampoline restriction doesn't apply. */
    private fun dismissAction(notifId: Int, token: Long): Notification.Action {
        val intent = Intent(this, CallActionReceiver::class.java).apply {
            action = CallActionReceiver.ACTION_DISMISS_MISSED
            putExtra(CallActionReceiver.EXTRA_NOTIFICATION_ID, notifId)
            putExtra(CallActionReceiver.EXTRA_TOKEN, token)
        }
        // Distinct request code space from the Call-back PendingIntent (offset) so the
        // two actions on the same notification don't collide.
        val pi = PendingIntent.getBroadcast(this, notifId + DISMISS_REQUEST_OFFSET, intent, piFlags())
        return Notification.Action.Builder(
            Icon.createWithResource(this, android.R.drawable.ic_menu_close_clear_cancel),
            "Dismiss",
            pi,
        ).build()
    }

    /** Tapping the missed-call notification opens the app. */
    private fun missedContentIntent(notifId: Int): PendingIntent {
        val intent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return PendingIntent.getActivity(this, notifId, intent, piFlags())
    }

    private fun createMissedChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = getSystemService(NotificationManager::class.java) ?: return
        if (mgr.getNotificationChannel(MISSED_CHANNEL_ID) == null) {
            val channel = NotificationChannel(
                MISSED_CHANNEL_ID,
                "Missed calls",
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply { description = "Missed call alerts with a call-back action" }
            mgr.createNotificationChannel(channel)
        }
    }

    /** Resolves [number] to a saved contact's display name from the native mirror
     *  (pushed by Flutter, see ContactRepository.contactNameMirrorEntries), keyed by
     *  the shared trailing-digit rule. Null when unknown / no digits / no mirror —
     *  so the caller falls back to the number. No DB or Flutter needed. */
    private fun resolveContactName(number: String?): String? {
        val key = IncomingCallRinger.matchKey(number) ?: return null
        val prefs = getSharedPreferences(IncomingCallRinger.RINGER_PREFS, Context.MODE_PRIVATE)
        val raw = prefs.getString(IncomingCallRinger.KEY_CONTACT_NAMES, null) ?: return null
        return try {
            JSONObject(raw).optString(key).takeIf { it.isNotBlank() }
        } catch (e: Exception) {
            null
        }
    }

    /** Dismisses the platform's own missed-call notification so the user doesn't see
     *  two. Valid for the default dialer; ignored otherwise. */
    private fun cancelSystemMissedCallNotification() {
        try {
            val tm = getSystemService(Context.TELECOM_SERVICE) as? TelecomManager ?: return
            tm.cancelMissedCallsNotification()
        } catch (e: SecurityException) {
            // Only the default dialer may clear it; ignore if we somehow aren't.
        } catch (e: Exception) {
            // Best-effort; a failure just means the system notification may linger.
        }
    }

    // ---- Foreground service + call notification ----

    /**
     * Promotes to (or updates) the phoneCall foreground service with [notif]. The manifest
     * declares foregroundServiceType="phoneCall", so the plain startForeground picks up that
     * type. Once foregrounded, later updates post via NotificationManager to avoid
     * re-invoking startForeground on every state/audio change.
     */
    private fun postCallNotification(notif: Notification) {
        if (inForeground) {
            getSystemService(NotificationManager::class.java)?.notify(CALL_NOTIFICATION_ID, notif)
        } else {
            startForeground(CALL_NOTIFICATION_ID, notif)
            inForeground = true
        }
    }

    private fun buildCallNotification(
        number: String?,
        name: String?,
        ongoing: Boolean,
        forceQuiet: Boolean = false,
    ): Notification {
        createChannel()
        val caller = when {
            !name.isNullOrBlank() -> name
            !number.isNullOrBlank() -> number
            else -> "Unknown"
        }
        val contentPi = activityIntent()
        val uiVisible = forceQuiet || CallRegistry.isInCallUiVisible()
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            buildCallStyleNotification(caller, contentPi, ongoing, uiVisible)
        } else {
            buildLegacyNotification(caller, contentPi, ongoing, uiVisible)
        }
    }

    /** API 31+ rich CallStyle notification (matches other dialers). */
    private fun buildCallStyleNotification(
        caller: String,
        contentPi: PendingIntent,
        ongoing: Boolean,
        uiVisible: Boolean,
    ): Notification {
        val person = Person.Builder().setName(caller).setImportant(true).build()
        val style = if (ongoing) {
            Notification.CallStyle.forOngoingCall(person, broadcast(CallActionReceiver.ACTION_HANGUP))
        } else {
            Notification.CallStyle.forIncomingCall(
                person,
                broadcast(CallActionReceiver.ACTION_DECLINE),
                broadcast(CallActionReceiver.ACTION_ANSWER),
            )
        }
        // CallStyle's verification slot is the identification line next to the
        // caller ("Suspected spam", "Telemarketing", …).
        currentLabel?.let { style.setVerificationText(it) }
        // With our in-call UI already in front, the ringing notification goes on the
        // quiet channel with no full-screen intent so no heads-up banner covers it.
        val channelId = when {
            ongoing -> ONGOING_CHANNEL_ID
            uiVisible -> QUIET_INCOMING_CHANNEL_ID
            else -> CHANNEL_ID
        }
        val builder = Notification.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.sym_action_call)
            .setStyle(style)
            .setContentIntent(contentPi)
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_CALL)
        if (ongoing) {
            val connectTime = CallRegistry.currentConnectTimeMillis()
            if (connectTime > 0L) {
                builder.setWhen(connectTime).setUsesChronometer(true)
            }
            builder.addAction(muteAction())
            builder.addAction(speakerAction())
        } else if (!uiVisible) {
            builder.setFullScreenIntent(contentPi, true)
        }
        return builder.build()
    }

    /** Pre-31 fallback: a plain ongoing notification with manual action buttons. */
    private fun buildLegacyNotification(
        caller: String,
        contentPi: PendingIntent,
        ongoing: Boolean,
        uiVisible: Boolean,
    ): Notification {
        val channelId = when {
            ongoing -> ONGOING_CHANNEL_ID
            uiVisible -> QUIET_INCOMING_CHANNEL_ID
            else -> CHANNEL_ID
        }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setPriority(
                    if (ongoing || uiVisible) {
                        Notification.PRIORITY_DEFAULT
                    } else {
                        Notification.PRIORITY_HIGH
                    },
                )
        }
        builder
            .setSmallIcon(android.R.drawable.sym_action_call)
            .setContentTitle(caller)
            .setCategory(Notification.CATEGORY_CALL)
            .setOngoing(true)
            .setContentIntent(contentPi)
        if (ongoing) {
            builder.setContentText(currentLabel ?: "Ongoing call")
            val connectTime = CallRegistry.currentConnectTimeMillis()
            if (connectTime > 0L) {
                builder.setWhen(connectTime).setUsesChronometer(true)
            }
            builder.addAction(hangupAction())
            builder.addAction(muteAction())
            builder.addAction(speakerAction())
        } else {
            builder.setContentText(currentLabel ?: "Incoming call")
            if (!uiVisible) builder.setFullScreenIntent(contentPi, true)
            builder.addAction(declineAction())
            builder.addAction(answerAction())
        }
        return builder.build()
    }

    // ---- Notification actions ----

    private fun muteAction(): Notification.Action {
        val muted = CallRegistry.isMuted()
        val icon = if (muted) {
            android.R.drawable.ic_lock_silent_mode
        } else {
            android.R.drawable.ic_lock_silent_mode_off
        }
        val title = if (muted) "Unmute" else "Mute"
        return action(icon, title, CallActionReceiver.ACTION_MUTE)
    }

    private fun speakerAction(): Notification.Action {
        val on = CallRegistry.isSpeakerOn()
        val title = if (on) "Speaker on" else "Speaker"
        return action(android.R.drawable.stat_sys_speakerphone, title, CallActionReceiver.ACTION_SPEAKER)
    }

    private fun hangupAction(): Notification.Action =
        action(android.R.drawable.ic_menu_close_clear_cancel, "Hang up", CallActionReceiver.ACTION_HANGUP)

    private fun answerAction(): Notification.Action =
        action(android.R.drawable.sym_action_call, "Answer", CallActionReceiver.ACTION_ANSWER)

    private fun declineAction(): Notification.Action =
        action(android.R.drawable.ic_menu_close_clear_cancel, "Decline", CallActionReceiver.ACTION_DECLINE)

    private fun action(iconRes: Int, title: String, broadcastAction: String): Notification.Action =
        Notification.Action.Builder(
            Icon.createWithResource(this, iconRes),
            title,
            broadcast(broadcastAction),
        ).build()

    // ---- PendingIntents ----

    /** Brings [MainActivity] to the front so the still-mounted in-call screen shows. */
    private fun activityIntent(): PendingIntent {
        val intent = Intent(this, MainActivity::class.java).apply {
            action = ACTION_SHOW_IN_CALL
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        return PendingIntent.getActivity(this, 0, intent, piFlags())
    }

    private fun broadcast(broadcastAction: String): PendingIntent {
        val intent = Intent(this, CallActionReceiver::class.java).setAction(broadcastAction)
        return PendingIntent.getBroadcast(this, broadcastAction.hashCode(), intent, piFlags())
    }

    private fun piFlags(): Int {
        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            flags = flags or PendingIntent.FLAG_IMMUTABLE
        }
        return flags
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val mgr = getSystemService(NotificationManager::class.java) ?: return
        // Incoming/ringing: HIGH so it heads-up and shows over the lock screen (paired with
        // the full-screen intent). We play the ringtone/vibrate ourselves, so it stays silent.
        if (mgr.getNotificationChannel(CHANNEL_ID) == null) {
            val incoming = NotificationChannel(
                CHANNEL_ID,
                "Incoming calls",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Incoming call alerts"
                setSound(null, null)
                enableVibration(false)
            }
            mgr.createNotificationChannel(incoming)
        }
        // Incoming while our in-call UI is already showing: LOW so it never heads-ups
        // over our own screen — the notification only backs the foreground service and
        // sits in the shade. (A separate channel because channel importance is
        // immutable once created.)
        if (mgr.getNotificationChannel(QUIET_INCOMING_CHANNEL_ID) == null) {
            val quiet = NotificationChannel(
                QUIET_INCOMING_CHANNEL_ID,
                "Incoming calls (app open)",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Incoming call alerts while the app is on screen"
                setSound(null, null)
                enableVibration(false)
            }
            mgr.createNotificationChannel(quiet)
        }
        // Ongoing/active call: DEFAULT so the notification isn't treated as "silent" and
        // therefore stays visible in the lock-screen shade (silent notifications are hidden
        // there by default) — the user can hang up straight from the shade. A CallStyle
        // *ongoing* notification renders as a persistent entry, not a heads-up popup, so
        // this doesn't banner over our own in-call screen. We still keep it sound/vibration
        // free. VISIBILITY_PUBLIC shows the controls (not just "contents hidden") on the lock
        // screen. (A new channel id because the old one was created at LOW and channel
        // importance is immutable once created.)
        if (mgr.getNotificationChannel(ONGOING_CHANNEL_ID) == null) {
            val ongoing = NotificationChannel(
                ONGOING_CHANNEL_ID,
                "Ongoing call",
                NotificationManager.IMPORTANCE_DEFAULT,
            ).apply {
                description = "Active call controls"
                setSound(null, null)
                enableVibration(false)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            mgr.createNotificationChannel(ongoing)
        }
    }

    private fun launchInCallUi() {
        val intent = Intent(this, MainActivity::class.java).apply {
            action = ACTION_SHOW_IN_CALL
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        startActivity(intent)
    }

    companion object {
        const val ACTION_SHOW_IN_CALL = "in.sreerajp.contact_sphere.SHOW_IN_CALL"
        private const val CHANNEL_ID = "incoming_calls"
        private const val QUIET_INCOMING_CHANNEL_ID = "incoming_calls_quiet"
        // v2: recreated at IMPORTANCE_DEFAULT (was LOW) so it shows in the lock-screen shade;
        // channel importance is immutable, so the id had to change to take effect.
        private const val ONGOING_CHANNEL_ID = "ongoing_call_v2"
        private const val MISSED_CHANNEL_ID = "missed_calls"
        private const val CALL_NOTIFICATION_ID = 42

        /** Added to a missed-call notification id to form its "Dismiss" broadcast request
         *  code, keeping it distinct from the "Call back" PendingIntent's (which uses the
         *  raw notification id). Comfortably above the [nextMissedId] range. */
        private const val DISMISS_REQUEST_OFFSET = 1_000_000

        /** Delays (ms) at which we re-clear the platform's own missed-call
         *  notification, which it posts asynchronously after ours. */
        private val SYSTEM_MISSED_CANCEL_DELAYS_MS = longArrayOf(500L, 2000L)

        /** Cap on parked call-waiting missed-call events (oldest dropped). */
        private const val MAX_MISSED_EVENTS = 200

        /** Unique id per missed-call notification so several stack rather than
         *  replace each other. Starts above [CALL_NOTIFICATION_ID] to avoid clashes. */
        private var missedIdCounter = 1000

        @Synchronized
        private fun nextMissedId(): Int = ++missedIdCounter
    }
}
