package `in`.sreerajp.contact_sphere

import android.Manifest
import android.app.KeyguardManager
import android.app.NotificationManager
import android.app.role.RoleManager
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.database.ContentObserver
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.CallLog
import android.provider.ContactsContract
import android.provider.OpenableColumns
import android.provider.Settings
import android.telecom.TelecomManager
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream

/**
 * Hosts the Flutter UI and the Telecom bridge.
 *
 * A [MethodChannel] exposes default-dialer status/request plus in-call controls,
 * and an [EventChannel] streams [CallRegistry] snapshots so the Flutter in-call
 * screen can react to call state. The service ([ContactSphereInCallService])
 * brings this activity to front when a call arrives; the event stream (which
 * pushes the current snapshot on subscribe) is what actually drives navigation.
 */
class MainActivity : FlutterFragmentActivity(), CallRegistry.Listener {

    private var eventSink: EventChannel.EventSink? = null
    private var pendingRoleResult: MethodChannel.Result? = null

    /** Pending result for an in-flight [ACTION_RINGTONE_PICKER] launch, if any. */
    private var pendingRingtoneResult: MethodChannel.Result? = null

    /** Pending result for an in-flight [ACTION_OPEN_DOCUMENT] audio pick, if any. */
    private var pendingAudioResult: MethodChannel.Result? = null

    /** In-app preview player for the ringtone settings screens (not the ringer). */
    private var previewPlayer: MediaPlayer? = null

    /**
     * Raw vCard text delivered via a VIEW/SEND intent, parked until the Flutter
     * side collects it with `getPendingVCard`. Kept as the single source of
     * truth for both cold starts (Dart polls after the first frame) and warm
     * deliveries (a `vcardReceived` nudge tells Dart to collect immediately).
     */
    private var pendingVCard: String? = null
    private var vcardChannel: MethodChannel? = null

    /**
     * Parked contact intent data (view, edit, insert, pick) to pass to Flutter.
     * Maps to `{action, uri, mimeType, extras: {name, phone, email, ...}}`.
     */
    private var pendingContactIntent: Map<String, Any?>? = null
    private var contactIntentsChannel: MethodChannel? = null

    /**
     * A phone number handed in via a dial/call intent (a missed-call "Call back",
     * a tapped tel: link), parked until the Flutter side collects it with
     * `getPendingDial`. [pendingDialAutoCall] is true when the intent was
     * ACTION_CALL ("place it now"), false for ACTION_DIAL/VIEW ("show the dialer
     * pre-filled"). Same cold-start-poll / warm-nudge pattern as [pendingVCard].
     */
    private var pendingDial: String? = null
    private var pendingDialAutoCall: Boolean = false

    private var pendingNotificationPayload: String? = null

    /**
     * Set when the activity is started (or re-delivered an intent) by the call
     * notification's tap target — `ContactSphereInCallService.ACTION_SHOW_IN_CALL`.
     * Parked until the Flutter side collects it with `consumePendingShowInCall`,
     * the same cold-start-poll / warm-nudge pattern as [pendingDial].
     *
     * Needed because the tap only brings this activity to the front: if the Dart
     * calling screen was popped (a back press during a live call) or buried under
     * another route, the call state has not changed, so no call event is emitted
     * and nothing would re-show the screen.
     */
    private var pendingShowInCall = false

    /** The `contact_sphere/telecom` channel, kept so warm dial intents can nudge Dart. */
    private var telecomChannel: MethodChannel? = null

    /** BLE peripheral for "Share via Bluetooth" (created on first use). */
    private var bleShareServer: BleShareServer? = null
    private var bleEventSink: EventChannel.EventSink? = null

    /**
     * Proximity screen-off wake lock, held while a call is connected on the
     * earpiece so an ear/cheek at the screen blanks it (and its touch) instead
     * of tapping the in-call controls. The stock in-call UI does this for us;
     * as the default dialer we own our own UI, so we must do it ourselves.
     * Created lazily (only on devices that support the level).
     */
    private var proximityWakeLock: PowerManager.WakeLock? = null

    /** Whether the previous [onCallChanged] snapshot had a call (edge detection). */
    private var hadCall = false

    private var callLogObserver: ContentObserver? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleShowInCallIntent(intent)
        handleVCardIntent(intent)
        handleDialIntent(intent)
        handleTrustedCallbackIntent(intent)
        handleSmartRedialIntent(intent)
        handleScheduledNotificationIntent(intent)
        handleContactIntent(intent)
        registerCallLogObserver()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleShowInCallIntent(intent)
        handleVCardIntent(intent)
        handleDialIntent(intent)
        handleTrustedCallbackIntent(intent)
        handleSmartRedialIntent(intent)
        handleScheduledNotificationIntent(intent)
        handleContactIntent(intent)
    }

    /**
     * Handles the call notification's tap target: allows this activity over the
     * keyguard, parks [pendingShowInCall] and, for an app that is already running,
     * nudges Dart to bring the calling screen back.
     * On a cold start the channel isn't up yet, so Dart drains the flag with
     * `consumePendingShowInCall` after its first frame.
     */
    private fun handleShowInCallIntent(intent: Intent?) {
        if (intent?.action != ContactSphereInCallService.ACTION_SHOW_IN_CALL) return
        // Let this activity show over the keyguard: the tap may well come from a
        // locked device while the call is ringing.
        applyShowWhenLocked(true)
        pendingShowInCall = true
        // Warm delivery: Dart answers the nudge, which is how we know it was acted on
        // and can drop the flag. On a cold start no Dart handler is up yet, nothing
        // answers, and the flag survives for Dart to drain after its first frame.
        runOnUiThread {
            telecomChannel?.invokeMethod(
                "showInCall",
                null,
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        pendingShowInCall = false
                    }

                    override fun error(code: String, message: String?, details: Any?) = Unit

                    override fun notImplemented() = Unit
                },
            )
        }
    }

    private fun handleScheduledNotificationIntent(intent: Intent?) {
        if (intent?.action == ScheduledNotificationReceiver.ACTION_NOTIFICATION_TAP) {
            val payload = intent.getStringExtra(ScheduledNotificationReceiver.EXTRA_PAYLOAD)
            if (!payload.isNullOrBlank()) {
                pendingNotificationPayload = payload
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        telecomChannel = MethodChannel(messenger, METHOD_CHANNEL)
        telecomChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "isDefaultDialer" -> result.success(isDefaultDialer())
                "requestDefaultDialer" -> requestDefaultDialer(result)
                "getSimAccounts" -> result.success(getSimAccounts())
                "placeCall" -> result.success(
                    placeCall(
                        call.argument<String>("number"),
                        call.argument<String>("phoneAccountId"),
                        call.argument<String>("componentName"),
                    ),
                )
                "selectPhoneAccount" -> {
                    CallRegistry.selectPhoneAccount(
                        call.argument<String>("phoneAccountId"),
                        call.argument<String>("componentName"),
                    )
                    result.success(null)
                }
                "setIncomingRingtone" -> {
                    CallRegistry.setIncomingRingtone(
                        call.argument<String>("path"),
                        call.argument<String>("source"),
                    )
                    result.success(null)
                }
                "setCallerName" -> {
                    CallRegistry.setCallerDisplayName(call.argument<String>("name"))
                    result.success(null)
                }
                "setCallerLabel" -> {
                    CallRegistry.setCallerLabel(call.argument<String>("label"))
                    result.success(null)
                }
                "setScreeningMirror" -> {
                    setScreeningMirror(
                        call.argument<List<String>>("blockedNumbers"),
                        call.argument<List<String>>("spamNumbers"),
                        call.argument<Boolean>("blockUnknown"),
                        call.argument<Boolean>("spamFilter"),
                        call.argument<Boolean>("quietHoursEnabled"),
                        call.argument<String>("quietHoursStart"),
                        call.argument<String>("quietHoursEnd"),
                        call.argument<List<String>>("quietHoursAllowedNumbers"),
                    )
                    result.success(null)
                }
                "getBlockedCallEvents" -> result.success(drainBlockedCallEvents())
                "setRingerPrefs" -> {
                    setRingerPrefs(
                        call.argument<Int>("volumePercent"),
                        call.argument<Boolean>("vibrate"),
                        call.argument<Boolean>("spokenAnnouncementEnabled"),
                        call.argument<Boolean>("quietHoursEnabled"),
                        call.argument<String>("quietHoursStart"),
                        call.argument<String>("quietHoursEnd"),
                    )
                    result.success(null)
                }
                "previewCallerAnnouncement" -> {
                    val name = call.argument<String>("name")
                    if (!name.isNullOrBlank()) {
                        IncomingCallRinger.previewAnnouncement(this, name)
                    }
                    result.success(null)
                }
                "setRingtoneMirror" -> {
                    setRingtoneMirror(
                        call.argument<Map<String, String>>("contactTones"),
                        call.argument<Map<String, String>>("simTones"),
                        call.argument<Map<String, String>>("contactNames"),
                    )
                    result.success(null)
                }
                "getDefaultRingtone" -> result.success(defaultRingtoneInfo())
                "pickRingtone" -> pickRingtone(call.argument<String>("existingUri"), result)
                "pickAudioDocument" -> pickAudioDocument(result)
                "previewRingtone" -> result.success(previewRingtone(call.argument<String>("uri")))
                "stopRingtonePreview" -> { stopRingtonePreview(); result.success(null) }
                "answer" -> { CallRegistry.answer(); result.success(null) }
                "disconnect" -> { CallRegistry.disconnect(); result.success(null) }
                "answerWaiting" -> { CallRegistry.answerRingingCall(); result.success(null) }
                "rejectWaiting" -> { CallRegistry.rejectRingingCall(); result.success(null) }
                "getMissedCallEvents" -> result.success(drainMissedCallEvents())
                "getOutgoingOutcomeEvents" -> result.success(drainOutgoingOutcomeEvents())
                "rejectWithMessage" -> {
                    val message = call.argument<String>("message")
                    if (!message.isNullOrBlank()) CallRegistry.rejectWithMessage(message)
                    result.success(null)
                }
                "hold" -> { CallRegistry.hold(); result.success(null) }
                "unhold" -> { CallRegistry.unhold(); result.success(null) }
                "setMuted" -> {
                    CallRegistry.setMuted(call.argument<Boolean>("muted") ?: false)
                    result.success(null)
                }
                "setSpeaker" -> {
                    CallRegistry.setSpeaker(call.argument<Boolean>("on") ?: false)
                    result.success(null)
                }
                "playDtmf" -> {
                    val digit = call.argument<String>("digit")?.firstOrNull()
                    if (digit != null) CallRegistry.playDtmf(digit)
                    result.success(null)
                }
                "stopDtmf" -> { CallRegistry.stopDtmf(); result.success(null) }
                "merge" -> { CallRegistry.merge(); result.success(null) }
                "swap" -> { CallRegistry.swap(); result.success(null) }
                "setSecureFlag" -> {
                    // Add/clear the window FLAG_SECURE so sensitive UI (secret
                    // contacts, the app-lock screen) is excluded from
                    // screenshots, screen recording and the Recents thumbnail.
                    // Window-flag changes must run on the UI thread.
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    runOnUiThread {
                        if (enabled) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                    }
                    result.success(null)
                }
                "getActiveCall" -> result.success(CallRegistry.snapshot())
                // One-shot collect of a number handed in via a dial/call intent:
                // returns `{number, autoCall}` (or null) and clears it so a re-poll
                // can't dial it twice.
                "getPendingDial" -> {
                    // Returns whatever a dial/call intent or a trusted call-back parked
                    // (a trusted call-back arrives with autoCall = true; see
                    // handleTrustedCallbackIntent). One-shot: cleared so a re-poll can't
                    // dial it twice.
                    val number = pendingDial
                    val autoCall = pendingDialAutoCall
                    pendingDial = null
                    pendingDialAutoCall = false
                    result.success(
                        if (number == null) null
                        else mapOf("number" to number, "autoCall" to autoCall),
                    )
                }
                "scheduleSmartRedial" -> {
                    val id = call.argument<String>("id")
                    val number = call.argument<String>("number")
                    val displayName = call.argument<String>("displayName")
                    val fireAtMillis = call.argument<Long>("fireAtMillis")
                    val armed =
                        if (id != null && number != null && displayName != null && fireAtMillis != null) {
                            SmartRedialManager.schedule(
                                this,
                                id,
                                number,
                                displayName,
                                fireAtMillis,
                                call.argument<String>("phoneAccountId"),
                                call.argument<String>("componentName"),
                            )
                        } else {
                            false
                        }
                    result.success(armed)
                }
                "cancelSmartRedial" -> {
                    val id = call.argument<String>("id")
                    if (id != null) SmartRedialManager.cancel(this, id)
                    result.success(null)
                }
                "getPendingSmartRedialIds" -> result.success(SmartRedialManager.pendingIds(this))
                "hasExactAlarmPermission" ->
                    result.success(SmartRedialManager.hasExactAlarmPermission(this))
                "requestExactAlarmPermission" -> {
                    SmartRedialManager.requestExactAlarmPermission(this)
                    result.success(null)
                }
                "scheduleNotification" -> {
                    val id = call.argument<String>("id")
                    val title = call.argument<String>("title")
                    val body = call.argument<String>("body")
                    val fireAtMillis = call.argument<Long>("fireAtMillis")
                    val payload = call.argument<String>("payload")
                    val category = call.argument<String>("category")
                    val armed = if (id != null && title != null && body != null && fireAtMillis != null) {
                        NotificationSchedulerManager.schedule(
                            this,
                            id,
                            title,
                            body,
                            fireAtMillis,
                            payload,
                            category,
                        )
                    } else {
                        false
                    }
                    result.success(armed)
                }
                "cancelNotification" -> {
                    val id = call.argument<String>("id")
                    if (id != null) NotificationSchedulerManager.cancel(this, id)
                    result.success(null)
                }
                "getPendingNotificationIds" ->
                    result.success(NotificationSchedulerManager.pendingIds(this))
                // One-shot collect: true when the app was opened (or re-entered) by
                // the call notification and the calling screen still has to be shown.
                "consumePendingShowInCall" -> {
                    val show = pendingShowInCall
                    pendingShowInCall = false
                    result.success(show)
                }
                "getPendingNotificationPayload" -> {
                    val payload = pendingNotificationPayload
                    pendingNotificationPayload = null
                    result.success(payload)
                }
                else -> result.notImplemented()
            }
        }

        vcardChannel = MethodChannel(messenger, VCARD_CHANNEL).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    // One-shot collect: returns the parked vCard text (or null)
                    // and clears it so a re-poll can't import it twice.
                    "getPendingVCard" -> {
                        result.success(pendingVCard)
                        pendingVCard = null
                    }
                    else -> result.notImplemented()
                }
            }
        }

        contactIntentsChannel = MethodChannel(messenger, CONTACT_INTENTS_CHANNEL).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPendingContactIntent" -> {
                        result.success(pendingContactIntent)
                        pendingContactIntent = null
                    }
                    "submitContactPickerResult" -> {
                        val contactUriStr = call.argument<String>("contactUri")
                        val phoneNum = call.argument<String>("phone")
                        val emailAddr = call.argument<String>("email")

                        var resultUriStr = contactUriStr

                        val deviceId = contactUriStr?.substringAfterLast("/")
                        if (deviceId != null && deviceId.toLongOrNull() != null) {
                            if (phoneNum != null) {
                                resultUriStr = resolvePhoneDataUri(deviceId, phoneNum) ?: contactUriStr
                            } else if (emailAddr != null) {
                                resultUriStr = resolveEmailDataUri(deviceId, emailAddr) ?: contactUriStr
                            }
                        }

                        if (resultUriStr != null) {
                            val resultIntent = Intent().apply {
                                data = Uri.parse(resultUriStr)
                            }
                            setResult(RESULT_OK, resultIntent)
                        } else {
                            setResult(RESULT_CANCELED)
                        }
                        finish()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        MethodChannel(messenger, BLE_METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Returns null on success or a short error code the Dart share
                // dialog maps to user-facing text.
                "start" -> {
                    val payload = call.argument<ByteArray>("payload")
                    val name = call.argument<String>("name") ?: ""
                    if (payload == null || payload.isEmpty()) {
                        result.success("start_failed")
                    } else {
                        val server = bleShareServer ?: BleShareServer(this).also { s ->
                            s.listener = object : BleShareServer.Listener {
                                override fun onEvent(event: Map<String, Any?>) {
                                    bleEventSink?.success(event)
                                }
                            }
                            bleShareServer = s
                        }
                        result.success(server.start(payload, name))
                    }
                }
                "stop" -> {
                    bleShareServer?.stop()
                    result.success(null)
                }
                // Lets Dart decide the runtime-permission set (legacy BLE scans
                // on Android 11 and below additionally need location).
                "getSdkInt" -> result.success(Build.VERSION.SDK_INT)
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, CONNECTED_APPS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getConnectedApps" -> {
                    val contactId = call.argument<String>("contactId")
                    if (contactId.isNullOrBlank()) {
                        result.success(emptyList<Map<String, Any?>>())
                    } else {
                        // Provider queries + icon rendering can be slow; keep
                        // them off the platform thread, answer back on it.
                        Thread {
                            val apps = try {
                                queryConnectedApps(contactId)
                            } catch (t: Throwable) {
                                emptyList<Map<String, Any?>>()
                            }
                            runOnUiThread { result.success(apps) }
                        }.start()
                    }
                }
                "openConnectedAppAction" -> result.success(
                    openConnectedAppAction(
                        call.argument<Number>("dataId")?.toLong(),
                        call.argument<String>("mimetype"),
                    ),
                )
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, CONTACTS_LOCAL_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Creates a contact in the phone's local (null/null) account and
                // returns its contact id, or null on failure. flutter_contacts
                // 2.1.0 can't target the local account, so this is the only path
                // for the "Device (this phone)" destination.
                "createLocalContact" -> {
                    val payload = call.arguments as? Map<String, Any?>
                    if (payload == null) {
                        result.success(null)
                    } else {
                        // Provider batch writes can be slow; keep them off the
                        // platform thread and answer back on it.
                        Thread {
                            val id = try {
                                LocalContactWriter.create(contentResolver, payload)
                            } catch (t: Throwable) {
                                null
                            }
                            runOnUiThread { result.success(id) }
                        }.start()
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, EMERGENCY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                // Publishes the emergency card the user chose to show on the lock
                // screen (plaintext by necessity — see EmergencyCardNotifier) and
                // posts the notification that opens it.
                "setEmergencyMirror" -> {
                    val json = call.argument<String>("json")
                    if (json.isNullOrBlank()) {
                        EmergencyCardNotifier.clear(this)
                    } else {
                        EmergencyCardNotifier.publish(this, json)
                    }
                    result.success(null)
                }
                // Master switch off: wipe the published copy and the notification.
                "clearEmergencyMirror" -> {
                    EmergencyCardNotifier.clear(this)
                    result.success(null)
                }
                // Why the card may not be on the lock screen (see
                // EmergencyCardNotifier.notificationStatus).
                "emergencyNotificationStatus" -> {
                    result.success(EmergencyCardNotifier.notificationStatus(this))
                }
                // Opens this app's settings for the emergency card channel.
                "openEmergencyChannelSettings" -> {
                    result.success(openEmergencyChannelSettings())
                }
                // Opens the system lock-screen notification settings — the
                // "Hide silent notifications" choice lives there and no app can
                // change it on the user's behalf.
                "openLockScreenNotificationSettings" -> {
                    result.success(openLockScreenNotificationSettings())
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, BLE_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    bleEventSink = sink
                }

                override fun onCancel(arguments: Any?) {
                    bleEventSink = null
                }
            },
        )

        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                    // Registering pushes the current snapshot immediately.
                    CallRegistry.listener = this@MainActivity
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    if (CallRegistry.listener === this@MainActivity) {
                        CallRegistry.listener = null
                    }
                }
            },
        )
    }

    override fun onResume() {
        super.onResume()
        // The ringing notification stays out of heads-up while our own in-call
        // UI is in front; the registry re-posts it if this changes mid-ring.
        CallRegistry.setInCallUiVisible(true)
        registerCallLogObserver()
        // Coming back to the front: the window may have been resized (or the IME
        // dismissed) while we were paused, and that update can be missed. Ask for
        // a fresh dispatch so Flutter's view insets match reality. See
        // [requestInsetRefresh].
        requestInsetRefresh()
    }

    override fun onPause() {
        CallRegistry.setInCallUiVisible(false)
        super.onPause()
    }

    private fun registerCallLogObserver() {
        if (callLogObserver != null) return
        try {
            val observer = object : ContentObserver(Handler(Looper.getMainLooper())) {
                override fun onChange(selfChange: Boolean, uri: Uri?) {
                    super.onChange(selfChange, uri)
                    runOnUiThread {
                        telecomChannel?.invokeMethod("onCallLogChanged", null)
                    }
                }
            }
            contentResolver.registerContentObserver(
                CallLog.Calls.CONTENT_URI,
                true,
                observer,
            )
            callLogObserver = observer
        } catch (_: Throwable) {
            // Permission for READ_CALL_LOG might not be granted yet.
        }
    }

    private fun unregisterCallLogObserver() {
        val observer = callLogObserver ?: return
        callLogObserver = null
        try {
            contentResolver.unregisterContentObserver(observer)
        } catch (_: Throwable) {
        }
    }

    override fun onCallChanged(snapshot: Map<String, Any?>?) {
        // Telecom callbacks may arrive off the platform thread.
        runOnUiThread {
            val hasCall = snapshot != null

            // Show the in-call UI over the lock screen while a call is present
            // (an incoming call is launched via the notification's full-screen
            // intent); drop the flag once there's no call so normal launches
            // don't bypass the keyguard.
            applyShowWhenLocked(hasCall)
            // Changing those window flags relayouts the window; make sure Flutter
            // hears the resulting insets (see [requestInsetRefresh]).
            requestInsetRefresh()

            // Blank the screen while the call is connected on the earpiece so an
            // ear/cheek can't tap the controls. Not while ringing (the user needs
            // to answer) or on speaker (the phone isn't at the ear).
            val state = snapshot?.get("state") as? String
            val onSpeaker = snapshot?.get("speaker") as? Boolean ?: false
            val onEarpiece = (state == "active" || state == "holding") && !onSpeaker
            applyProximityLock(onEarpiece)

            // Call ended: if this call brought our UI to the front (an incoming call, or
            // any call that arrived while the app wasn't showing), send the app back so we
            // don't leave our own screen on display for a call the user never opened the
            // app for. This also covers the over-the-lock-screen case. A call dialed from
            // inside the app (UI already visible) leaves the app on screen as before.
            if (!hasCall && hadCall && CallRegistry.didCallBringUiToFront()) {
                moveTaskToBack(true)
            }
            hadCall = hasCall

            // While a call is up, stop the OS from snapshotting the task: a
            // snapshot taken as the user leaves mid-call replays as the starting
            // window when they return after the call ended — a stale "still
            // calling" flash. Restored once no call remains so Recents gets its
            // normal thumbnail back.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                setRecentsScreenshotEnabled(snapshot == null)
            }
            eventSink?.success(snapshot)
        }
    }

    /**
     * Asks Android to dispatch the current window insets again.
     *
     * A call arriving while the keyboard is open changes this window underneath
     * the IME: [applyShowWhenLocked] flips the show-when-locked flags, an incoming
     * call may raise us over the keyguard through a full-screen intent, and the
     * task is moved to the back when the call ends. The IME is dismissed during
     * that transition while the activity is paused, and the resulting
     * `WindowInsets` (IME height back to zero) can fail to reach `FlutterView` --
     * Flutter then keeps the stale keyboard height in `MediaQuery.viewInsets`, so
     * every Scaffold body stays short by one keyboard until the app is restarted.
     *
     * Posting the request lets the window settle first. Guarded: a failed inset
     * refresh must never disturb call handling.
     */
    private fun requestInsetRefresh() {
        try {
            val decor = window?.decorView ?: return
            decor.post {
                try {
                    decor.requestApplyInsets()
                } catch (_: Throwable) {
                }
            }
        } catch (_: Throwable) {
        }
    }

    private fun applyShowWhenLocked(show: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(show)
            setTurnScreenOn(show)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (show) window.addFlags(flags) else window.clearFlags(flags)
        }
    }

    /**
     * Holds ([active]) or releases the proximity screen-off wake lock. The lock
     * is created lazily on first need and only on devices that support the level.
     * Releasing uses the default so the screen comes back on immediately once the
     * phone leaves the ear. Safe to call repeatedly with the same value.
     */
    private fun applyProximityLock(active: Boolean) {
        val pm = getSystemService(Context.POWER_SERVICE) as? PowerManager ?: return
        if (active) {
            val lock = proximityWakeLock ?: run {
                if (!pm.isWakeLockLevelSupported(
                        PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK,
                    )
                ) {
                    return
                }
                pm.newWakeLock(
                    PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK,
                    "contact_sphere:incall_proximity",
                ).also { proximityWakeLock = it }
            }
            if (!lock.isHeld) lock.acquire()
        } else {
            proximityWakeLock?.let { if (it.isHeld) it.release() }
        }
    }

    // ---- vCard open/share-target handling ----

    /**
     * If [intent] carries a vCard (ACTION_VIEW on a .vcf / vCard mime type, or
     * ACTION_SEND with a vCard stream), reads its text, parks it in
     * [pendingVCard], and nudges the Flutter side to collect it. Ignores
     * anything else — the dialer/contacts intent filters share this activity.
     */
    private fun handleVCardIntent(intent: Intent?) {
        if (intent == null) return
        val type = intent.type ?: ""
        val dataLooksVcf =
            intent.data?.toString()?.endsWith(".vcf", ignoreCase = true) == true
        val isVCard = type == "text/x-vcard" || type == "text/vcard" ||
            type == "text/directory" || dataLooksVcf
        if (!isVCard) return

        val uri: Uri? = when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(Intent.EXTRA_STREAM)
            }
            else -> null
        }
        val text = uri?.let { readTextFromUri(it) }
        if (text.isNullOrBlank()) return

        pendingVCard = text
        // Warm delivery: tell Dart to collect now. On a cold start the channel
        // isn't up yet; Dart polls getPendingVCard after its first frame.
        runOnUiThread { vcardChannel?.invokeMethod("vcardReceived", null) }
    }

    /** Reads [uri] as UTF-8 text, or null on failure / absurd size. */
    private fun readTextFromUri(uri: Uri): String? = try {
        contentResolver.openInputStream(uri)?.use { input ->
            val bytes = input.readBytes()
            if (bytes.size > MAX_VCARD_BYTES) null else String(bytes, Charsets.UTF_8)
        }
    } catch (e: Exception) {
        null
    }

    // ---- Dial / call intents (tel: links, missed-call "Call back") ----

    /**
     * If [intent] carries a `tel:` number (ACTION_CALL / ACTION_DIAL / ACTION_VIEW),
     * parks the number in [pendingDial] and nudges the Flutter side to collect it.
     *
     * These are **external** intents (from other apps, `tel:` links, or the system's
     * own missed-call notification), so they only ever open the dialer **pre-filled**
     * ([pendingDialAutoCall] = false) — never a silent call. Auto-call ("place it
     * now") comes exclusively from our own missed-call notification via the trusted,
     * token-guarded [PendingCallback] path (see [handleTrustedCallbackIntent]); this
     * closes the confused-deputy hole where any app could send ACTION_CALL and borrow our
     * CALL_PHONE permission. Ignores intents with no tel: data (a bare ACTION_DIAL
     * just opens the app on its dialer).
     */
    private fun handleDialIntent(intent: Intent?) {
        if (intent == null) return
        val isDial = intent.action == Intent.ACTION_CALL ||
            intent.action == Intent.ACTION_DIAL ||
            intent.action == Intent.ACTION_VIEW
        if (!isDial) return
        val number = telNumber(intent.data) ?: return

        pendingDial = number
        pendingDialAutoCall = false
        // Warm delivery: tell Dart to collect now. On a cold start the channel
        // isn't up yet; Dart polls getPendingDial after its first frame.
        runOnUiThread { telecomChannel?.invokeMethod("dialReceived", null) }
    }

    /**
     * Handles our own missed-call notification's **"Call back"** launch. The action is a
     * `getActivity` PendingIntent (so the app reliably foregrounds — a broadcast that then
     * calls `startActivity` is blocked as a notification trampoline on Android 12+), and it
     * carries a one-shot [EXTRA_TOKEN]. We place the call automatically **only** when that
     * token matches a live one armed in [PendingCallback] ([PendingCallback.take]); because
     * this activity is exported, that token is what stops a crafted external intent from
     * forging an auto-dial (the confused-deputy hole a past security review closed).
     *
     * On a match: park the number as an auto-call, cancel the notification, ask to unlock
     * if the phone is locked (so the SIM picker is usable), and nudge Dart to collect it.
     * A missing / stale token is ignored (no call placed). One-shot: we null the intent's
     * action so a config-change replay can't reprocess it.
     */
    private fun handleTrustedCallbackIntent(intent: Intent?) {
        if (intent == null || intent.action != ACTION_TRUSTED_CALL_BACK) return
        val token = intent.getLongExtra(EXTRA_TOKEN, 0L)
        val notifId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, -1)
        intent.action = null // consume so a later re-delivery can't reprocess it
        if (notifId != -1) {
            getSystemService(NotificationManager::class.java)?.cancel(notifId)
        }
        val number = if (token != 0L) PendingCallback.take(token) else null
        if (number.isNullOrBlank()) return
        pendingDial = number
        pendingDialAutoCall = true
        ensureUnlockedForCallback()
        // Warm delivery: tell Dart to collect now. On a cold start the channel isn't up
        // yet; Dart polls getPendingDial after its first frame.
        runOnUiThread { telecomChannel?.invokeMethod("dialReceived", null) }
    }

    /**
     * Handles a Smart Redial alarm arriving as an activity launch.
     *
     * Scheduled redials now fire into [SmartRedialReceiver], which places the call
     * natively so a closed app still dials on time. This path stays for alarms that
     * were armed by an older build of the app (their PendingIntent still points
     * here) — it is only ever reached with the app being started, so going through
     * Flutter to dial is fine.
     *
     * Trusted the same way as [handleTrustedCallbackIntent]: the intent's token must
     * match the task's on-disk one-shot token ([SmartRedialManager.consume]) or
     * nothing is dialled — this activity is exported, so an external intent guessing
     * [EXTRA_SMART_REDIAL_ID] could otherwise re-fire an already-consumed task.
     *
     * Unlike the missed-call callback, the token lives on disk (not just in
     * [PendingCallback]'s memory) because it must survive the *app process itself*
     * having been killed for up to the user's chosen delay (1-30 min), not just the
     * few seconds it takes to tap a notification.
     */
    private fun handleSmartRedialIntent(intent: Intent?) {
        if (intent == null || intent.action != ACTION_SMART_REDIAL_FIRE) return
        val id = intent.getStringExtra(EXTRA_SMART_REDIAL_ID)
        val token = intent.getLongExtra(EXTRA_SMART_REDIAL_TOKEN, 0L)
        intent.action = null // consume so a later re-delivery can't reprocess it
        if (id.isNullOrBlank()) return
        val task = SmartRedialManager.consume(this, id, token) ?: return
        // Dial on the SIM chosen when the reminder was scheduled, without asking.
        if (TelecomCaller.placeCall(this, task.number, task.phoneAccountId, task.componentName)) {
            return
        }
        val number = task.number
        pendingDial = number
        pendingDialAutoCall = true
        ensureUnlockedForCallback()
        runOnUiThread { telecomChannel?.invokeMethod("dialReceived", null) }
    }

    /**
     * For a call-back launched from the lock screen: show over the keyguard, turn the
     * screen on, and (if locked) request the keyguard be dismissed, so the SIM-picker sheet
     * is visible and interactive instead of sitting behind the lock screen. The call that
     * follows keeps the app over the keyguard via [applyShowWhenLocked].
     */
    private fun ensureUnlockedForCallback() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        val km = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager ?: return
        if (km.isKeyguardLocked && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            km.requestDismissKeyguard(this, null)
        }
    }

    /** The dialable number in a `tel:` [uri] (URL-decoded), or null for any other scheme. */
    private fun telNumber(uri: Uri?): String? {
        if (uri == null || !"tel".equals(uri.scheme, ignoreCase = true)) return null
        val ssp = uri.schemeSpecificPart ?: return null
        return Uri.decode(ssp).trim().ifBlank { null }
    }

    // ---- Contact Intents handling (VIEW, EDIT, INSERT, PICK) ----

    private fun handleContactIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action ?: return

        val isContactAction = action == Intent.ACTION_VIEW ||
                action == Intent.ACTION_EDIT ||
                action == Intent.ACTION_INSERT ||
                action == Intent.ACTION_INSERT_OR_EDIT ||
                action == Intent.ACTION_PICK ||
                action == Intent.ACTION_GET_CONTENT

        if (!isContactAction) return

        // If it's VIEW but the data is tel:, it's handled by handleDialIntent
        if (action == Intent.ACTION_VIEW && intent.data?.scheme == "tel") return

        // If it's VIEW/SEND on vcard, it's handled by handleVCardIntent
        val type = intent.type ?: ""
        val dataLooksVcf = intent.data?.toString()?.endsWith(".vcf", ignoreCase = true) == true
        if (type == "text/x-vcard" || type == "text/vcard" || type == "text/directory" || dataLooksVcf) return

        val extrasMap = mutableMapOf<String, String>()
        intent.extras?.let { bundle ->
            val name = bundle.getString(ContactsContract.Intents.Insert.NAME) ?: bundle.getString("name")
            if (name != null) extrasMap["name"] = name

            val phone = bundle.getString(ContactsContract.Intents.Insert.PHONE) ?: bundle.getString("phone")
            if (phone != null) extrasMap["phone"] = phone

            val email = bundle.getString(ContactsContract.Intents.Insert.EMAIL) ?: bundle.getString("email")
            if (email != null) extrasMap["email"] = email

            val postal = bundle.getString(ContactsContract.Intents.Insert.POSTAL) ?: bundle.getString("postal")
            if (postal != null) extrasMap["postal"] = postal

            val company = bundle.getString(ContactsContract.Intents.Insert.COMPANY) ?: bundle.getString("company")
            if (company != null) extrasMap["company"] = company

            val title = bundle.getString(ContactsContract.Intents.Insert.JOB_TITLE) ?: bundle.getString("job_title")
            if (title != null) extrasMap["job_title"] = title

            val notes = bundle.getString(ContactsContract.Intents.Insert.NOTES) ?: bundle.getString("notes")
            if (notes != null) extrasMap["notes"] = notes
        }

        val actionName = when (action) {
            Intent.ACTION_VIEW -> "view"
            Intent.ACTION_EDIT -> "edit"
            Intent.ACTION_INSERT -> "insert"
            Intent.ACTION_INSERT_OR_EDIT -> "insertOrEdit"
            Intent.ACTION_PICK -> "pick"
            Intent.ACTION_GET_CONTENT -> "pick"
            else -> "unknown"
        }

        pendingContactIntent = mapOf(
            "action" to actionName,
            "uri" to intent.data?.toString(),
            "mimeType" to intent.type,
            "extras" to extrasMap
        )

        runOnUiThread {
            contactIntentsChannel?.invokeMethod("contactIntentReceived", null)
        }
    }

    private fun resolvePhoneDataUri(deviceId: String, phoneNumber: String): String? {
        val cleanPhone = phoneNumber.replace(Regex("[^0-9+]"), "")
        val contentResolver = contentResolver ?: return null

        var dataUri: String? = null
        val uri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI
        val projection = arrayOf(ContactsContract.CommonDataKinds.Phone._ID, ContactsContract.CommonDataKinds.Phone.NUMBER)
        val selection = "${ContactsContract.CommonDataKinds.Phone.CONTACT_ID} = ?"
        val selectionArgs = arrayOf(deviceId)

        try {
            contentResolver.query(uri, projection, selection, selectionArgs, null)?.use { cursor ->
                val idCol = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone._ID)
                val numCol = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                while (cursor.moveToNext()) {
                    if (idCol >= 0 && numCol >= 0) {
                        val id = cursor.getLong(idCol)
                        val rawNum = cursor.getString(numCol) ?: ""
                        val cleanRaw = rawNum.replace(Regex("[^0-9+]"), "")
                        if (cleanRaw.endsWith(cleanPhone) || cleanPhone.endsWith(cleanRaw)) {
                            dataUri = "${ContactsContract.Data.CONTENT_URI}/$id"
                            break
                        }
                    }
                }
            }
        } catch (e: Exception) {
            // fallback
        }
        return dataUri
    }

    private fun resolveEmailDataUri(deviceId: String, emailAddress: String): String? {
        val contentResolver = contentResolver ?: return null
        var dataUri: String? = null
        val uri = ContactsContract.CommonDataKinds.Email.CONTENT_URI
        val projection = arrayOf(ContactsContract.CommonDataKinds.Email._ID, ContactsContract.CommonDataKinds.Email.ADDRESS)
        val selection = "${ContactsContract.CommonDataKinds.Email.CONTACT_ID} = ?"
        val selectionArgs = arrayOf(deviceId)

        try {
            contentResolver.query(uri, projection, selection, selectionArgs, null)?.use { cursor ->
                val idCol = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email._ID)
                val emailCol = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS)
                while (cursor.moveToNext()) {
                    if (idCol >= 0 && emailCol >= 0) {
                        val id = cursor.getLong(idCol)
                        val email = cursor.getString(emailCol) ?: ""
                        if (email.trim().equals(emailAddress.trim(), ignoreCase = true)) {
                            dataUri = "${ContactsContract.Data.CONTENT_URI}/$id"
                            break
                        }
                    }
                }
            }
        } catch (e: Exception) {
            // fallback
        }
        return dataUri
    }

    // ---- Default dialer ----

    private fun telecom(): TelecomManager =
        getSystemService(Context.TELECOM_SERVICE) as TelecomManager

    private fun isDefaultDialer(): Boolean = packageName == telecom().defaultDialerPackage

    private fun requestDefaultDialer(result: MethodChannel.Result) {
        if (isDefaultDialer()) {
            result.success(true)
            return
        }
        pendingRoleResult = result
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val rm = getSystemService(RoleManager::class.java)
            if (rm != null &&
                rm.isRoleAvailable(RoleManager.ROLE_DIALER) &&
                !rm.isRoleHeld(RoleManager.ROLE_DIALER)
            ) {
                startActivityForResult(
                    rm.createRequestRoleIntent(RoleManager.ROLE_DIALER),
                    REQ_ROLE_DIALER,
                )
                return
            }
        }
        // Pre-Q (API 24-28) fallback: the legacy change-default-dialer prompt.
        @Suppress("DEPRECATION")
        val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
            .putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
        startActivityForResult(intent, REQ_ROLE_DIALER)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            REQ_ROLE_DIALER -> {
                // Report the effective state rather than resultCode: the user may
                // have granted/declined the role regardless of how the flow ended.
                pendingRoleResult?.success(isDefaultDialer())
                pendingRoleResult = null
            }
            REQ_PICK_RINGTONE -> {
                val pending = pendingRingtoneResult
                pendingRingtoneResult = null
                if (pending == null) return
                val uri: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    data?.getParcelableExtra(
                        RingtoneManager.EXTRA_RINGTONE_PICKED_URI,
                        Uri::class.java,
                    )
                } else {
                    @Suppress("DEPRECATION")
                    data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                }
                // Cancelled → resolve to null so the caller leaves the tone unchanged.
                // "Silent"/None picked → a null uri, reported as an explicit empty map.
                pending.success(uri?.let { ringtoneInfo(it) } ?: mapOf<String, Any?>())
            }
            REQ_OPEN_AUDIO -> {
                val pending = pendingAudioResult
                pendingAudioResult = null
                if (pending == null) return
                val uri = data?.data
                // Cancelled / nothing picked → empty map (caller leaves tone unchanged).
                if (resultCode != RESULT_OK || uri == null) {
                    pending.success(mapOf<String, Any?>())
                    return
                }
                pending.success(persistAudioDocument(uri))
            }
        }
    }

    // ---- SIM / phone-account enumeration ----

    /**
     * The device's call-capable phone accounts (SIMs), enriched with the matching
     * [SubscriptionInfo] where available. Empty when READ_PHONE_STATE is missing
     * or the query fails, so the Flutter side simply shows "no SIMs".
     *
     * A SIM phone-account's `id` is the subscription id as a string on stock
     * Android, which is how we match handles to subscriptions and how the device
     * call log records PHONE_ACCOUNT_ID.
     */
    private fun getSimAccounts(): List<Map<String, Any?>> {
        val tm = telecom()
        val handles = try {
            tm.callCapablePhoneAccounts
        } catch (e: SecurityException) {
            return emptyList()
        } catch (e: Exception) {
            return emptyList()
        }
        val subs: List<SubscriptionInfo> = try {
            val sm = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE)
                as? SubscriptionManager
            sm?.activeSubscriptionInfoList ?: emptyList()
        } catch (e: Exception) {
            emptyList()
        }
        val result = mutableListOf<Map<String, Any?>>()
        for (h in handles) {
            val acct = try { tm.getPhoneAccount(h) } catch (e: Exception) { null }
            val sub = subs.firstOrNull { it.subscriptionId.toString() == h.id }
            result.add(
                mapOf(
                    "phoneAccountId" to h.id,
                    "componentName" to h.componentName.flattenToString(),
                    "label" to acct?.label?.toString(),
                    "subscriptionId" to sub?.subscriptionId,
                    "slotIndex" to sub?.simSlotIndex,
                    "displayName" to sub?.displayName?.toString(),
                    "carrierName" to sub?.carrierName?.toString(),
                ),
            )
        }
        return result
    }

    // ---- Outgoing call through Telecom so it surfaces in our in-call UI ----

    /** Delegates to [TelecomCaller] — the same code the Smart Redial alarm uses,
     *  so a call placed from the UI and one placed with no UI at all behave
     *  identically (SIM routing included). */
    private fun placeCall(
        number: String?,
        phoneAccountId: String?,
        componentName: String?,
    ): Boolean = TelecomCaller.placeCall(this, number, phoneAccountId, componentName)

    // ---- Ringer preferences (mirrored for the native IncomingCallRinger) ----

    /**
     * Persists the user's ringtone-volume / vibration preferences into the plain
     * native SharedPreferences file [IncomingCallRinger] reads at ring time. The
     * Flutter side owns these values and pushes them here on change and on load,
     * so the ringer can read them synchronously even on a cold-start incoming call
     * (before the Flutter engine is running). Null args leave that key untouched.
     */
    private fun setRingerPrefs(
        volumePercent: Int?,
        vibrate: Boolean?,
        spokenAnnouncementEnabled: Boolean?,
        quietHoursEnabled: Boolean?,
        quietHoursStart: String?,
        quietHoursEnd: String?,
    ) {
        val prefs = getSharedPreferences(
            IncomingCallRinger.RINGER_PREFS,
            Context.MODE_PRIVATE,
        )
        prefs.edit().apply {
            if (volumePercent != null) {
                putInt(IncomingCallRinger.KEY_VOLUME_PERCENT, volumePercent.coerceIn(0, 100))
            }
            if (vibrate != null) putBoolean(IncomingCallRinger.KEY_VIBRATE, vibrate)
            if (spokenAnnouncementEnabled != null) {
                putBoolean(IncomingCallRinger.KEY_SPOKEN_ANNOUNCEMENT_ENABLED, spokenAnnouncementEnabled)
            }
            if (quietHoursEnabled != null) {
                putBoolean(IncomingCallRinger.KEY_QUIET_HOURS_ENABLED, quietHoursEnabled)
            }
            if (quietHoursStart != null) {
                putString(IncomingCallRinger.KEY_QUIET_HOURS_START, quietHoursStart)
            }
            if (quietHoursEnd != null) {
                putString(IncomingCallRinger.KEY_QUIET_HOURS_END, quietHoursEnd)
            }
            apply()
        }
    }

    /**
     * Persists the mirror — per-contact tones and per-contact display names keyed by
     * trailing number digits, plus per-SIM tones keyed by phoneAccountId — as JSON
     * strings in the same native prefs file, so [IncomingCallRinger] can resolve the
     * correct tone (and [ContactSphereInCallService] the caller's name for a
     * missed-call notification) synchronously before the Flutter engine is up on a
     * cold start. Each map replaces the stored one wholesale; a null map leaves that
     * key untouched.
     */
    private fun setRingtoneMirror(
        contactTones: Map<String, String>?,
        simTones: Map<String, String>?,
        contactNames: Map<String, String>?,
    ) {
        val prefs = getSharedPreferences(
            IncomingCallRinger.RINGER_PREFS,
            Context.MODE_PRIVATE,
        )
        prefs.edit().apply {
            if (contactTones != null) {
                putString(IncomingCallRinger.KEY_CONTACT_TONES, JSONObject(contactTones).toString())
            }
            if (simTones != null) {
                putString(IncomingCallRinger.KEY_SIM_TONES, JSONObject(simTones).toString())
            }
            if (contactNames != null) {
                putString(IncomingCallRinger.KEY_CONTACT_NAMES, JSONObject(contactNames).toString())
            }
            apply()
        }
    }

    // ---- Call-screening mirror (read by ContactSphereCallScreeningService) ----

    /**
     * Persists the screening data — blocked/spam digit lists and the
     * Identification toggles — into the plain native SharedPreferences file the
     * call-screening service reads synchronously when a call arrives (before
     * the Flutter engine is up on a cold start). Each list replaces the stored
     * one wholesale; null args leave that key untouched.
     */
    private fun setScreeningMirror(
        blockedNumbers: List<String>?,
        spamNumbers: List<String>?,
        blockUnknown: Boolean?,
        spamFilter: Boolean?,
        quietHoursEnabled: Boolean?,
        quietHoursStart: String?,
        quietHoursEnd: String?,
        quietHoursAllowedNumbers: List<String>?,
    ) {
        val prefs = getSharedPreferences(
            ContactSphereCallScreeningService.SCREENING_PREFS,
            Context.MODE_PRIVATE,
        )
        prefs.edit().apply {
            if (blockedNumbers != null) {
                putString(
                    ContactSphereCallScreeningService.KEY_BLOCKED,
                    JSONArray(blockedNumbers).toString(),
                )
            }
            if (spamNumbers != null) {
                putString(
                    ContactSphereCallScreeningService.KEY_SPAM,
                    JSONArray(spamNumbers).toString(),
                )
            }
            if (blockUnknown != null) {
                putBoolean(
                    ContactSphereCallScreeningService.KEY_BLOCK_UNKNOWN,
                    blockUnknown,
                )
            }
            if (spamFilter != null) {
                putBoolean(
                    ContactSphereCallScreeningService.KEY_SPAM_FILTER,
                    spamFilter,
                )
            }
            if (quietHoursEnabled != null) {
                putBoolean(
                    ContactSphereCallScreeningService.KEY_QUIET_HOURS_ENABLED,
                    quietHoursEnabled,
                )
            }
            if (quietHoursStart != null) {
                putString(
                    ContactSphereCallScreeningService.KEY_QUIET_HOURS_START,
                    quietHoursStart,
                )
            }
            if (quietHoursEnd != null) {
                putString(
                    ContactSphereCallScreeningService.KEY_QUIET_HOURS_END,
                    quietHoursEnd,
                )
            }
            if (quietHoursAllowedNumbers != null) {
                putString(
                    ContactSphereCallScreeningService.KEY_QUIET_HOURS_ALLOWED_NUMBERS,
                    JSONArray(quietHoursAllowedNumbers).toString(),
                )
            }
            apply()
        }
        val currentBlocked = ContactSphereCallScreeningService.readList(
            prefs,
            ContactSphereCallScreeningService.KEY_BLOCKED,
        )
        val currentBlockUnknown = prefs.getBoolean(
            ContactSphereCallScreeningService.KEY_BLOCK_UNKNOWN,
            false,
        )
        CallRegistry.disconnectBlockedCalls(currentBlocked, currentBlockUnknown)
    }

    /**
     * One-shot drain of the calls the screening service rejected: returns the
     * parked `{number, at}` events (oldest first) and clears them, so a re-poll
     * can't write duplicate Recents rows — the same collect pattern as
     * `getPendingVCard`.
     */
    private fun drainBlockedCallEvents(): List<Map<String, Any?>> {
        val prefs = getSharedPreferences(
            ContactSphereCallScreeningService.SCREENING_PREFS,
            Context.MODE_PRIVATE,
        )
        val raw = prefs.getString(
            ContactSphereCallScreeningService.KEY_BLOCKED_EVENTS,
            null,
        ) ?: return emptyList()
        prefs.edit()
            .remove(ContactSphereCallScreeningService.KEY_BLOCKED_EVENTS)
            .apply()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).mapNotNull { i ->
                val obj = arr.optJSONObject(i) ?: return@mapNotNull null
                val number = obj.optString("number")
                if (number.isBlank()) return@mapNotNull null
                mapOf<String, Any?>("number" to number, "at" to obj.optLong("at"))
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /**
     * One-shot drain of the call-waiting missed calls the in-call service parked
     * (the snapshot logger never saw them). Returns the `{number, at,
     * phoneAccountId}` events (oldest first) and clears them so a re-poll can't
     * write duplicate Recents rows — the same collect pattern as
     * [drainBlockedCallEvents].
     */
    private fun drainMissedCallEvents(): List<Map<String, Any?>> {
        val prefs = getSharedPreferences(
            IncomingCallRinger.RINGER_PREFS,
            Context.MODE_PRIVATE,
        )
        val raw = prefs.getString(
            IncomingCallRinger.KEY_MISSED_EVENTS,
            null,
        ) ?: return emptyList()
        prefs.edit()
            .remove(IncomingCallRinger.KEY_MISSED_EVENTS)
            .apply()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).mapNotNull { i ->
                val obj = arr.optJSONObject(i) ?: return@mapNotNull null
                val number = obj.optString("number")
                if (number.isBlank()) return@mapNotNull null
                mapOf<String, Any?>(
                    "number" to number,
                    "at" to obj.optLong("at"),
                    "phoneAccountId" to obj.optString("phoneAccountId").ifBlank { null },
                    "wasActive" to obj.optBoolean("wasActive"),
                    "duration" to obj.optLong("duration"),
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /**
     * One-shot drain of the outgoing-call outcomes the in-call service parked
     * (calls the app didn't place itself, so no Flutter screen latched the
     * reason). Returns the `{number, at, outcome}` events (oldest first) and
     * clears them — the same collect pattern as [drainMissedCallEvents]. Losing
     * an event costs only the reason: the Recents row is written by the
     * device-log import either way.
     */
    private fun drainOutgoingOutcomeEvents(): List<Map<String, Any?>> {
        val prefs = getSharedPreferences(
            IncomingCallRinger.RINGER_PREFS,
            Context.MODE_PRIVATE,
        )
        val raw = prefs.getString(
            IncomingCallRinger.KEY_OUTGOING_OUTCOMES,
            null,
        ) ?: return emptyList()
        prefs.edit()
            .remove(IncomingCallRinger.KEY_OUTGOING_OUTCOMES)
            .apply()
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).mapNotNull { i ->
                val obj = arr.optJSONObject(i) ?: return@mapNotNull null
                val number = obj.optString("number")
                val outcome = obj.optString("outcome")
                if (number.isBlank() || outcome.isBlank()) return@mapNotNull null
                mapOf<String, Any?>(
                    "number" to number,
                    "at" to obj.optLong("at"),
                    "outcome" to outcome,
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    // ---- Ringtone catalog / picker / preview ----

    /** `{uri, title}` for the actual system default ringtone, or nulls on failure. */
    private fun defaultRingtoneInfo(): Map<String, Any?> {
        val uri = try {
            RingtoneManager.getActualDefaultRingtoneUri(this, RingtoneManager.TYPE_RINGTONE)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        } catch (e: Exception) {
            null
        }
        return if (uri == null) mapOf("uri" to null, "title" to null) else ringtoneInfo(uri)
    }

    /** `{uri, title}` for [uri]; the title is best-effort (the raw string on failure). */
    private fun ringtoneInfo(uri: Uri): Map<String, Any?> {
        val title = try {
            RingtoneManager.getRingtone(this, uri)?.getTitle(this)
        } catch (e: Exception) {
            null
        }
        return mapOf("uri" to uri.toString(), "title" to (title ?: uri.toString()))
    }

    /**
     * Launches the system ringtone picker, pre-selecting [existingUri] when given.
     * The result is delivered to [pendingRingtoneResult] in [onActivityResult].
     */
    private fun pickRingtone(existingUri: String?, result: MethodChannel.Result) {
        // Only one picker at a time; abandon any stale pending result.
        pendingRingtoneResult?.success(mapOf<String, Any?>())
        pendingRingtoneResult = result
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_RINGTONE)
            putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Select ringtone")
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, false)
            if (!existingUri.isNullOrBlank()) {
                putExtra(
                    RingtoneManager.EXTRA_RINGTONE_EXISTING_URI,
                    try { Uri.parse(existingUri) } catch (e: Exception) { null },
                )
            }
        }
        try {
            startActivityForResult(intent, REQ_PICK_RINGTONE)
        } catch (e: Exception) {
            // No picker available; report "no selection" rather than hang.
            pendingRingtoneResult = null
            result.success(mapOf<String, Any?>())
        }
    }

    /**
     * Plays a one-off in-app preview of [uri] (file path or content URI) on the
     * **ring** stream with the same audio attributes and in-app volume scale as
     * [IncomingCallRinger], so the preview sounds exactly like an actual call.
     *
     * Returns [PREVIEW_PLAYING] when playback started and should be audible,
     * [PREVIEW_MUTED] when it started but the ring stream is silenced (silent /
     * vibrate mode, ring volume 0, or the in-app ringtone volume set to 0), and
     * [PREVIEW_MISSING] when the source can't be opened — e.g. a `content://`
     * tone whose backing file was deleted/moved throws synchronously at
     * [MediaPlayer.setDataSource] — so the caller can revert to the default tone.
     */
    private fun previewRingtone(uri: String?): String {
        if (uri.isNullOrBlank()) return PREVIEW_MISSING
        stopRingtonePreview()
        val parsed = try {
            if (uri.contains("://")) Uri.parse(uri) else Uri.parse("file://$uri")
        } catch (e: Exception) {
            return PREVIEW_MISSING
        }
        val scale = getSharedPreferences(IncomingCallRinger.RINGER_PREFS, Context.MODE_PRIVATE)
            .getInt(IncomingCallRinger.KEY_VOLUME_PERCENT, 100)
            .coerceIn(0, 100) / 100f
        return try {
            previewPlayer = MediaPlayer().apply {
                setDataSource(this@MainActivity, parsed)
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build(),
                )
                // Loop the preview so the "stop" affordance stays meaningful until
                // the user (or a new selection) stops it.
                isLooping = true
                setVolume(scale, scale)
                setOnPreparedListener { it.start() }
                setOnErrorListener { _, _, _ -> true }
                prepareAsync()
            }
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val audible = audioManager.ringerMode == AudioManager.RINGER_MODE_NORMAL &&
                audioManager.getStreamVolume(AudioManager.STREAM_RING) > 0 &&
                scale > 0f
            if (audible) PREVIEW_PLAYING else PREVIEW_MUTED
        } catch (e: Exception) {
            previewPlayer = null
            PREVIEW_MISSING
        }
    }

    // ---- Audio-file picker (SAF document with a persisted read grant) ----

    /**
     * Launches the Storage Access Framework document picker for an audio file. Unlike
     * `file_selector` (which returns a throwaway cache copy), this yields the original
     * file's `content://` URI and we take a *persistable* read grant on it, so the tone
     * survives app restarts without copying the file. Result delivered in
     * [onActivityResult] as `{uri, title}` (empty map on cancel).
     */
    private fun pickAudioDocument(result: MethodChannel.Result) {
        // Only one picker at a time; abandon any stale pending result.
        pendingAudioResult?.success(mapOf<String, Any?>())
        pendingAudioResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            type = "audio/*"
            addCategory(Intent.CATEGORY_OPENABLE)
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
            )
        }
        try {
            startActivityForResult(intent, REQ_OPEN_AUDIO)
        } catch (e: Exception) {
            pendingAudioResult = null
            result.success(mapOf<String, Any?>())
        }
    }

    /**
     * Takes a persistable read grant on [uri] and returns `{uri, title}` (the display
     * name from the document, falling back to the URI string). Returns an empty map if
     * the grant can't be taken.
     */
    private fun persistAudioDocument(uri: Uri): Map<String, Any?> {
        try {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
        } catch (e: Exception) {
            return mapOf<String, Any?>()
        }
        return mapOf("uri" to uri.toString(), "title" to (displayName(uri) ?: uri.toString()))
    }

    /** Best-effort display name for a document [uri] via [OpenableColumns]. */
    private fun displayName(uri: Uri): String? = try {
        contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { cursor ->
                if (cursor.moveToFirst() && !cursor.isNull(0)) cursor.getString(0) else null
            }
    } catch (e: Exception) {
        null
    }

    /** Stops and releases the preview player. Safe to call repeatedly. */
    private fun stopRingtonePreview() {
        try { previewPlayer?.stop() } catch (e: Exception) { /* already stopped */ }
        previewPlayer?.release()
        previewPlayer = null
    }

    override fun onDestroy() {
        unregisterCallLogObserver()
        stopRingtonePreview()
        proximityWakeLock?.let { if (it.isHeld) it.release() }
        proximityWakeLock = null
        bleShareServer?.stop()
        bleShareServer = null
        super.onDestroy()
    }

    /**
     * Rows other apps (WhatsApp, Telegram, …) sync into the contacts provider
     * for [contactId], grouped per app:
     * `[{package, name, icon, actions: [{dataId, mimetype, label}]}]`.
     *
     * Only custom third-party MIME types are considered (no hardcoded app
     * list), and a row is kept only when some installed activity handles its
     * VIEW intent — which also drops stale rows from uninstalled apps.
     */
    private fun queryConnectedApps(contactId: String): List<Map<String, Any?>> {
        if (checkSelfPermission(Manifest.permission.READ_CONTACTS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return emptyList()
        }

        data class App(
            val name: String,
            val icon: ByteArray?,
            val actions: MutableList<Map<String, Any?>>,
        )

        val apps = LinkedHashMap<String, App>() // keyed by package name
        contentResolver.query(
            ContactsContract.Data.CONTENT_URI,
            arrayOf(
                ContactsContract.Data._ID,
                ContactsContract.Data.MIMETYPE,
                ContactsContract.Data.DATA2,
                ContactsContract.Data.DATA3,
            ),
            "${ContactsContract.Data.CONTACT_ID} = ? AND " +
                "${ContactsContract.Data.MIMETYPE} LIKE ?",
            arrayOf(contactId, "vnd.android.cursor.item/vnd.%"),
            ContactsContract.Data._ID,
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val dataId = cursor.getLong(0)
                val mimetype = cursor.getString(1) ?: continue
                val intent = Intent(Intent.ACTION_VIEW).setDataAndType(
                    ContentUris.withAppendedId(ContactsContract.Data.CONTENT_URI, dataId),
                    mimetype,
                )
                val resolved =
                    packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
                        ?: continue
                val pkg = resolved.activityInfo?.packageName ?: continue
                // Apps store a ready-made, localized action label in DATA3
                // ("Message +91 98…"); DATA2 is a coarser fallback.
                val label = cursor.getString(3)?.takeIf { it.isNotBlank() }
                    ?: cursor.getString(2)?.takeIf { it.isNotBlank() }
                    ?: mimetype.substringAfterLast('.')
                val app = apps.getOrPut(pkg) {
                    App(
                        name = resolved.loadLabel(packageManager)?.toString() ?: pkg,
                        icon = try {
                            drawableToPng(resolved.loadIcon(packageManager))
                        } catch (t: Throwable) {
                            null
                        },
                        actions = mutableListOf(),
                    )
                }
                app.actions.add(
                    mapOf("dataId" to dataId, "mimetype" to mimetype, "label" to label),
                )
            }
        }
        return apps.entries
            .sortedBy { it.value.name.lowercase() }
            .map { (pkg, app) ->
                mapOf(
                    "package" to pkg,
                    "name" to app.name,
                    "icon" to app.icon,
                    "actions" to app.actions,
                )
            }
    }

    /**
     * Fires the VIEW intent that opens the owning app on this contact (chat,
     * voice call, …). Returns false when nothing handles it.
     */
    private fun openConnectedAppAction(dataId: Long?, mimetype: String?): Boolean {
        if (dataId == null || mimetype.isNullOrBlank()) return false
        return try {
            startActivity(
                Intent(Intent.ACTION_VIEW)
                    .setDataAndType(
                        ContentUris.withAppendedId(ContactsContract.Data.CONTENT_URI, dataId),
                        mimetype,
                    )
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
            true
        } catch (t: Throwable) {
            false
        }
    }

    /**
     * Opens the system settings page for the emergency card notification channel,
     * falling back to this app's notification settings on older releases.
     * Returns false when no settings screen handles it.
     */
    private fun openEmergencyChannelSettings(): Boolean {
        val intents = mutableListOf<Intent>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            intents += Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                .putExtra(Settings.EXTRA_CHANNEL_ID, EmergencyCardNotifier.CHANNEL_ID)
            intents += Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        }
        intents += Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            .setData(Uri.fromParts("package", packageName, null))
        return startFirstThatResolves(intents)
    }

    /**
     * Opens the lock-screen notification settings. There is no public constant
     * for that screen, so we try the well-known actions in order and fall back to
     * this app's notification settings.
     */
    private fun openLockScreenNotificationSettings(): Boolean {
        val intents = listOf(
            Intent("android.settings.LOCK_SCREEN_SETTINGS"),
            Intent("android.settings.NOTIFICATION_SETTINGS"),
            Intent(Settings.ACTION_SECURITY_SETTINGS),
        )
        if (startFirstThatResolves(intents)) return true
        return openEmergencyChannelSettings()
    }

    /**
     * Starts the first intent that some activity actually handles. Uses try/catch
     * rather than `resolveActivity` because package visibility rules can hide the
     * answer on API 30+.
     */
    private fun startFirstThatResolves(intents: List<Intent>): Boolean {
        for (intent in intents) {
            try {
                startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                return true
            } catch (t: Throwable) {
                // Try the next one.
            }
        }
        return false
    }

    /** [drawable] rendered to PNG bytes so Dart can show it with Image.memory. */
    private fun drawableToPng(drawable: Drawable): ByteArray {
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            drawable.bitmap
        } else {
            val w = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
            val h = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
            Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888).also { b ->
                val canvas = Canvas(b)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
            }
        }
        return ByteArrayOutputStream().use { out ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            out.toByteArray()
        }
    }

    companion object {
        /** Our own missed-call notification's "Call back" launches this activity with
         *  this action + [EXTRA_TOKEN] / [EXTRA_NOTIFICATION_ID]. The auto-call is placed
         *  only when the token matches a live one in [PendingCallback]. */
        const val ACTION_TRUSTED_CALL_BACK = "in.sreerajp.contact_sphere.TRUSTED_CALL_BACK"
        const val EXTRA_TOKEN = "in.sreerajp.contact_sphere.extra.TOKEN"
        const val EXTRA_NOTIFICATION_ID = "in.sreerajp.contact_sphere.extra.NOTIFICATION_ID"

        /** A Smart Redial alarm ([SmartRedialManager]) launches this activity with this
         *  action + [EXTRA_SMART_REDIAL_ID] / [EXTRA_SMART_REDIAL_TOKEN]. See
         *  [handleSmartRedialIntent]. */
        const val ACTION_SMART_REDIAL_FIRE = "in.sreerajp.contact_sphere.SMART_REDIAL_FIRE"
        const val EXTRA_SMART_REDIAL_ID = "in.sreerajp.contact_sphere.extra.SMART_REDIAL_ID"
        const val EXTRA_SMART_REDIAL_TOKEN = "in.sreerajp.contact_sphere.extra.SMART_REDIAL_TOKEN"

        private const val METHOD_CHANNEL = "contact_sphere/telecom"
        private const val EVENT_CHANNEL = "contact_sphere/call_events"
        private const val VCARD_CHANNEL = "contact_sphere/vcard"
        private const val CONTACT_INTENTS_CHANNEL = "contact_sphere/contact_intents"
        private const val BLE_METHOD_CHANNEL = "contact_sphere/ble_share"
        private const val BLE_EVENT_CHANNEL = "contact_sphere/ble_share_events"
        private const val CONNECTED_APPS_CHANNEL = "contact_sphere/connected_apps"
        private const val CONTACTS_LOCAL_CHANNEL = "contact_sphere/contacts_local"
        private const val EMERGENCY_CHANNEL = "contact_sphere/emergency"

        /** A whole-book .vcf with photos can run to megabytes; 20 MB is ample. */
        private const val MAX_VCARD_BYTES = 20 * 1024 * 1024
        private const val REQ_ROLE_DIALER = 7001
        private const val REQ_PICK_RINGTONE = 7002
        private const val REQ_OPEN_AUDIO = 7003

        /** [previewRingtone] statuses, mirrored by the Dart `RingtonePreviewStatus`. */
        private const val PREVIEW_PLAYING = "playing"
        private const val PREVIEW_MUTED = "muted"
        private const val PREVIEW_MISSING = "missing"
    }
}
