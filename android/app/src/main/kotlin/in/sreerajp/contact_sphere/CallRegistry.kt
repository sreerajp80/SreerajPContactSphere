package `in`.sreerajp.contact_sphere

import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.telecom.Call
import android.telecom.CallAudioState
import android.telecom.Connection
import android.telecom.DisconnectCause
import android.telecom.InCallService
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.telecom.VideoProfile

/**
 * Bridges Android Telecom (the bound [InCallService] and its [Call] objects) to
 * the Flutter layer.
 *
 * Tracks every live [Call] (not just one) so it can drive multi-party features:
 * a foreground/primary call, a held/background call, and merged conferences.
 * Answer / hold / mute / speaker / DTMF / add-call / merge / swap are exposed to
 * the method channel, and a single [Listener] (MainActivity's EventChannel sink)
 * is notified with a plain-map snapshot of the **primary** call (plus multi-call
 * capability flags) whenever call or audio state changes. Kept as an `object`
 * because the OS creates the service and the activity independently — this is the
 * shared point they both talk through.
 */
object CallRegistry {

    /** Notified on every call/audio-state change with the latest snapshot (or null). */
    interface Listener {
        fun onCallChanged(snapshot: Map<String, Any?>?)
    }

    /**
     * Drives the call-notification + ringing experience the app owns
     * (IN_CALL_SERVICE_RINGING): the [ContactSphereInCallService] implements this so
     * it can play the ringtone, vibrate, and run as a phoneCall foreground service for
     * the *whole* call — a full-screen incoming notification while ringing, then a
     * rich ongoing-call notification (controls + duration, tappable to return to the
     * in-call screen) once answered/outgoing. Kept separate from [Listener] because
     * the service (not the activity) owns this, and it must react even when no Flutter
     * UI is listening.
     */
    interface RingController {
        /** [callWaiting] is true when another call is already active/held, so the
         *  service plays a short call-waiting beep instead of the full ringtone. */
        fun startRinging(call: Call, callWaiting: Boolean)
        fun setCustomRingtone(path: String?, source: String?)
        fun updateCallerName(name: String?)
        /** Identification label for the caller (e.g. "Suspected spam"),
         *  resolved on the Flutter side; blank clears a previous one. */
        fun updateCallerLabel(label: String?)
        /** In-call UI visibility flipped while ringing: re-post the ringing
         *  notification in the right shape (quiet when the UI is up, heads-up
         *  capable when it isn't). */
        fun onUiVisibilityChanged()
        fun stopRinging()
        /** A non-ringing call is in progress (answered / outgoing / holding): show the
         *  ongoing-call notification and keep the foreground service alive. */
        fun showOngoingCall(number: String?)
        /** No call remains: clear the notification and leave the foreground. */
        fun onCallEnded()
        /** An incoming call ended unanswered (a missed call): post our own
         *  missed-call notification (with a "Call back" action). [number] is the
         *  caller's number, or null when Telecom didn't provide one; [phoneAccountId]
         *  is the SIM it arrived on. */
        fun onMissedCall(number: String?, phoneAccountId: String?)

        /** An incoming call ended while another call was still live — so it was
         *  never the primary the Flutter snapshot logger tracks, and only this
         *  side ever saw it. The service journals it for the Flutter side to drain
         *  into Recents. [wasActive] tells an answered call (logged as 'incoming'
         *  with [durationSeconds]) from one that never connected (logged 'missed'). */
        fun onIncomingCallEnded(
            number: String?,
            phoneAccountId: String?,
            wasActive: Boolean,
            durationSeconds: Long,
        )

        /** An outgoing call ended and Telecom said why ([outcome] is an
         *  `AppCallOutcome` value). Journaled for the Flutter side to attach to
         *  the call's Recents row: a call the app didn't place itself — a Smart
         *  Redial retry dialed natively with the app closed — has no pending
         *  record on the Dart side to latch the reason onto, so without this
         *  journal the row falls back to the device log, which knows the
         *  duration but never why the call ended. [atMillis] is when the call was
         *  created, which is how the device log dates an outgoing call, so the
         *  two records stay matchable. */
        fun onOutgoingCallEnded(number: String?, outcome: String, atMillis: Long)
    }

    private var ringController: RingController? = null

    /** True while we're actively ringing, so start/stop fire exactly once. */
    private var ringing = false

    /** True while [MainActivity] is resumed (reported from onResume/onPause), so the
     *  ringing notification can stay out of heads-up when our UI is already in front. */
    private var uiVisible = false

    /** Whether the current call session **brought our UI to the front** — i.e. our in-call
     *  screen was not already visible when the first call arrived (an incoming call on a
     *  cold start / from the background). Captured in [onCallAdded] before the service's
     *  launchInCallUi flips visibility, and read by [MainActivity] when the last call ends
     *  so it can send the app back instead of leaving its own screen on display. A call
     *  dialed from inside the app (UI already visible) leaves this false. */
    private var callBroughtUiToFront = false

    /** Monotonic id assigned per [onCallAdded] so the Flutter logger can dedupe
     *  a single physical call that flaps through more than one end cycle. */
    private var callCounter: Long = 0

    var listener: Listener? = null
        set(value) {
            field = value
            // Push current state immediately so a late-attaching UI syncs up
            // (e.g. the activity subscribes after a call already arrived).
            value?.onCallChanged(snapshot())
        }

    private var service: InCallService? = null

    /** Every call Telecom has handed us, in arrival order (conference children
     *  included; [topLevel] filters them out for primary/secondary selection). */
    private val calls = mutableListOf<Call>()

    /** Stable per-call id for the Flutter Recents logger, keyed by [Call]. */
    private val callIds = mutableMapOf<Call, Long>()

    /** Calls ever seen ringing — the pre-API-29 fallback for inferring an
     *  incoming call (no [Call.Details.getCallDirection]). */
    private val sawRingingCalls = mutableSetOf<Call>()

    /** Calls ever seen active (answered/connected) — used to tell a missed call
     *  (incoming, never active) from an answered one when a call is removed. */
    private val sawActiveCalls = mutableSetOf<Call>()

    private var audioState: CallAudioState? = null

    private val callback = object : Call.Callback() {
        override fun onStateChanged(c: Call, state: Int) {
            if (state == Call.STATE_RINGING) {
                sawRingingCalls.add(c)
                startRingingIfNeeded(c)
            } else if (noneRinging()) {
                stopRingingIfNeeded()
            }
            if (state == Call.STATE_ACTIVE) {
                sawActiveCalls.add(c)
                if (topLevel().size >= 2) {
                    merge()
                }
            }
            if (state == Call.STATE_SELECT_PHONE_ACCOUNT) maybeResolvePhoneAccount(c)
            notifyChange()
        }
        override fun onDetailsChanged(c: Call, details: Call.Details) = notifyChange()
    }

    fun attachService(s: InCallService) {
        service = s
    }

    fun detachService(s: InCallService) {
        if (service === s) service = null
    }

    fun setRingController(rc: RingController) {
        ringController = rc
    }

    fun clearRingController(rc: RingController) {
        if (ringController === rc) ringController = null
    }

    /** Reported by [MainActivity]'s onResume/onPause. A flip mid-ring re-posts the
     *  ringing notification so it demotes to a quiet status-bar entry while our
     *  in-call UI is showing, and promotes back to heads-up when the user leaves. */
    fun setInCallUiVisible(visible: Boolean) {
        if (uiVisible == visible) return
        uiVisible = visible
        if (ringing) ringController?.onUiVisibilityChanged()
    }

    fun isInCallUiVisible(): Boolean = uiVisible

    /** Whether the current/just-ended call session brought our UI to the front (an
     *  incoming call while the app wasn't showing). [MainActivity] reads this when the
     *  last call ends to decide whether to send the app back. See [callBroughtUiToFront]. */
    fun didCallBringUiToFront(): Boolean = callBroughtUiToFront

    /** Forwards a late-resolved ringtone (from the Flutter side) to the ringer.
     *  [source] is "contact" or "sim" so the ringer can rank the push against the
     *  tone the mirror already started (contact tone outranks SIM tone). */
    fun setIncomingRingtone(path: String?, source: String?) {
        ringController?.setCustomRingtone(path, source)
    }

    /** Forwards the contact name (resolved on the Flutter side) to the service so it
     *  can re-post the call notification — ringing or ongoing — with the contact's
     *  name. A blank name clears a previously pushed one. */
    fun setCallerDisplayName(name: String?) {
        ringController?.updateCallerName(name)
    }

    /** Forwards the identification label (resolved on the Flutter side — e.g.
     *  "Suspected spam", "Telemarketing") so the call notification can carry
     *  it. A blank label clears a previously pushed one. */
    fun setCallerLabel(label: String?) {
        ringController?.updateCallerLabel(label)
    }

    private fun startRingingIfNeeded(c: Call) {
        if (ringing) return
        ringing = true
        ringController?.startRinging(c, hasOngoingCall(c))
    }

    /** Whether another top-level call is already established (active or held) —
     *  i.e. [c] is a call-waiting second call rather than a lone incoming call. */
    private fun hasOngoingCall(except: Call): Boolean =
        topLevel().any {
            it !== except &&
                (stateOf(it) == Call.STATE_ACTIVE || stateOf(it) == Call.STATE_HOLDING)
        }

    private fun stopRingingIfNeeded() {
        if (!ringing) return
        ringing = false
        ringController?.stopRinging()
    }

    /** No tracked call is currently ringing (call-waiting/second-line safe). */
    private fun noneRinging(): Boolean = calls.none { stateOf(it) == Call.STATE_RINGING }

    fun onCallAdded(c: Call) {
        // First call of a session: note whether it is bringing our UI to the front
        // (nothing of ours was visible yet). Captured before the service launches the
        // in-call activity, so uiVisible still reflects the pre-call state.
        if (calls.isEmpty()) callBroughtUiToFront = !uiVisible
        calls.add(c)
        callCounter += 1
        callIds[c] = callCounter
        // A call that arrives already ringing is incoming.
        if (stateOf(c) == Call.STATE_RINGING) sawRingingCalls.add(c)
        c.registerCallback(callback)
        // An outgoing call placed with no chosen SIM (in-app "System default") can
        // arrive already needing an account. Resolve it before anyone waits on it.
        if (stateOf(c) == Call.STATE_SELECT_PHONE_ACCOUNT) maybeResolvePhoneAccount(c)
        // A call that arrives already ringing needs the ring to start now (the
        // state-change callback won't fire for the initial state). A second,
        // *outgoing* add-call arrives dialing/connecting, so it never rings here.
        if (stateOf(c) == Call.STATE_RINGING) startRingingIfNeeded(c)
        notifyChange()
    }

    fun onCallRemoved(c: Call) {
        c.unregisterCallback(callback)
        // Classify before we drop this call's tracking sets (both reads need them).
        maybeNotifyMissed(c)
        maybeJournalCallWaiting(c)
        maybeJournalOutgoingOutcome(c)
        calls.remove(c)
        callIds.remove(c)
        sawRingingCalls.remove(c)
        sawActiveCalls.remove(c)
        if (noneRinging()) stopRingingIfNeeded()
        notifyChange()
    }

    /** Posts a missed-call notification (via the [RingController]) when [c] is an
     *  incoming call that ended unanswered and wasn't declined by the user. */
    private fun maybeNotifyMissed(c: Call) {
        if (!isMissedCall(c)) return
        ringController?.onMissedCall(
            c.details?.handle?.schemeSpecificPart,
            c.details?.accountHandle?.id,
        )
    }

    /**
     * Journals [c] for Recents when it is an **incoming** call that ended while
     * another call was still live — a call-waiting call (answered or missed). Such
     * a call was never the primary the Flutter snapshot logger tracks (the active
     * call always outranks it), so only this side ever saw it. A lone incoming call
     * is deliberately skipped here — the snapshot logger already writes its row, so
     * journaling it too would double-count it.
     *
     * Runs before [c] is removed from [calls], so "another call live" is a simple
     * presence check.
     */
    private fun maybeJournalCallWaiting(c: Call) {
        if (!isIncoming(c)) return
        val callWaiting = calls.any { it !== c }
        if (!callWaiting) return
        val wasActive = sawActiveCalls.contains(c)
        val connectTime = c.details?.connectTimeMillis ?: 0L
        val durationSeconds =
            if (wasActive && connectTime > 0L) {
                ((System.currentTimeMillis() - connectTime) / 1000L).coerceIn(0L, 359999L)
            } else {
                0L
            }
        ringController?.onIncomingCallEnded(
            c.details?.handle?.schemeSpecificPart,
            c.details?.accountHandle?.id,
            wasActive,
            durationSeconds,
        )
    }

    /**
     * Journals the observed outcome of an **outgoing** call [c] so it survives to
     * Recents even when no Flutter screen was watching.
     *
     * The Dart side normally latches the reason from the live event stream, but
     * only for a call it placed itself (`CallLifecycleMixin`). A Smart Redial
     * retry is dialed natively by [SmartRedialReceiver] with the app possibly
     * closed, so nothing holds a pending record for it and the row ends up with
     * only what the device call log knows — a duration, and no reason. Journaling
     * here means a retry can say "Busy" or "Declined" too.
     *
     * Journals the outcome only; the Recents row itself is created by the
     * device-log import, and the Flutter drain patches rather than inserts, so
     * this can never produce a second row for one call.
     *
     * Runs before [c] is dropped from the tracking sets, so [callOutcome] can
     * still see whether the call was ever active.
     */
    private fun maybeJournalOutgoingOutcome(c: Call) {
        if (isIncoming(c)) return
        val outcome = callOutcome(c) ?: return
        val details = c.details
        // Date it the way the device call log dates an outgoing call — at
        // creation — so the Flutter side can match the two records. Falling back
        // to "now" costs at most the call's length, which the match window
        // absorbs.
        val at = creationTimeMillis(details).takeIf { it > 0L } ?: System.currentTimeMillis()
        ringController?.onOutgoingCallEnded(
            details?.handle?.schemeSpecificPart,
            outcome,
            at,
        )
    }

    /** True when [c] is an incoming call that was never answered and ended because
     *  it went unanswered (Telecom's MISSED, or the caller giving up = REMOTE) —
     *  not because the user declined it (LOCAL / REJECTED) or it was canceled. */
    private fun isMissedCall(c: Call): Boolean {
        if (!isIncoming(c)) return false
        if (sawActiveCalls.contains(c)) return false
        val code = c.details?.disconnectCause?.code ?: return false
        return code == DisconnectCause.MISSED || code == DisconnectCause.REMOTE
    }

    /**
     * Why [c] ended, in the vocabulary Flutter stores in `call_logs.call_outcome`
     * (see `AppCallOutcome`) — or null while the call is still live, and whenever
     * Telecom gives a reason we can't map.
     *
     * This is the only place that can tell *why* an outgoing call didn't connect.
     * The device call log records duration and direction but no reason, so
     * without this a busy line, a decline and a rang-out all look the same.
     *
     * Reaching ACTIVE settles it regardless of the cause code: every call ends
     * with LOCAL or REMOTE, and on an answered call that says who hung up, not
     * whether anyone talked.
     *
     * ERROR is the one code that cannot be read at face value. Telecom uses it
     * as a catch-all: a real network failure lands there, but so does an
     * ordinary VoLTE call nobody picked up — on a Jio line an unanswered call
     * comes back as `Code: (ERROR) ... ImsReasonInfo :: {336 :
     * CODE_SIP_TEMPRARILY_UNAVAILABLE, 480, ...}`, i.e. plain SIP 480. Reading
     * that as "failed" put "Failed" on calls that had simply rung out, so ERROR
     * is now resolved through the SIP code (see [imsSipCode]) and falls back to
     * "we don't know" rather than to a failure we can't evidence.
     */
    private fun callOutcome(c: Call): String? {
        val cause = c.details?.disconnectCause
        if (stateOf(c) != Call.STATE_DISCONNECTED) return null
        if (sawActiveCalls.contains(c)) return "answered"
        return when (cause?.code) {
            DisconnectCause.BUSY -> "busy"
            DisconnectCause.REJECTED -> "declined"
            // The user gave up before the far end resolved it either way.
            DisconnectCause.CANCELED, DisconnectCause.LOCAL -> "cancelled"
            // Rang out: the far end stopped it (REMOTE) or Telecom called it missed.
            DisconnectCause.MISSED, DisconnectCause.REMOTE -> "no_answer"
            // Catch-all: only the IMS layer knows what actually happened, and
            // when it doesn't say we return null rather than claim a failure.
            DisconnectCause.ERROR -> imsSipCode(cause)?.let { outcomeFromSipCode(it) }
            // UNKNOWN, OTHER, RESTRICTED and anything new: say nothing rather
            // than guess. Flutter then falls back to the duration.
            else -> null
        }
    }

    /**
     * The SIP response code the IMS stack reported for [cause], or null when
     * there isn't one to read.
     *
     * Android exposes no public getter for the `ImsReasonInfo` riding along on a
     * [DisconnectCause] (the getter is a system API, and reflection onto it is
     * blocked as a non-SDK interface since Android 9), but the object prints
     * itself in [DisconnectCause.toString] in AOSP's own
     * `ImsReasonInfo :: {code, extraCode, extraMessage}` form, where `extraCode`
     * is the SIP response code. Reading it back out of the string is a hack, but
     * a contained one: anything that doesn't match the expected shape returns
     * null and the caller treats the outcome as unknown. Vendors annotate the
     * first field with the constant's name (Motorola prints
     * `{336 : CODE_SIP_TEMPRARILY_UNAVAILABLE, 480, ...}`), which is why the
     * pattern skips to the second field instead of splitting on commas.
     */
    private fun imsSipCode(cause: DisconnectCause): Int? {
        val text = runCatching { cause.toString() }.getOrNull() ?: return null
        val sip = imsReasonPattern.find(text)?.groupValues?.getOrNull(1)?.toIntOrNull()
            ?: return null
        // SIP response codes are 3 digits, 1xx-6xx. Anything else means we read
        // a field that wasn't the one we wanted.
        return if (sip in 100..699) sip else null
    }

    /**
     * What a SIP response code says about the call, in the vocabulary Flutter
     * stores in `call_logs.call_outcome`.
     *
     * Only the codes that genuinely describe the *other side's* behaviour are
     * translated; everything else stays "failed", which is what ERROR meant
     * before this mapping existed and is correct once we know the network really
     * did reject the call rather than the callee ignoring it.
     */
    private fun outcomeFromSipCode(sip: Int): String {
        return when (sip) {
            // 408 Request Timeout, 480 Temporarily Unavailable (switched off /
            // out of coverage / not picking up), 487 Request Terminated.
            408, 480, 487 -> "no_answer"
            // 486 Busy Here, 600 Busy Everywhere.
            486, 600 -> "busy"
            // 603 Decline: the callee actively rejected it.
            603 -> "declined"
            else -> "failed"
        }
    }

    /** Pulls `extraCode` (the SIP response code) out of an `ImsReasonInfo ::
     *  {code, extraCode, extraMessage}` fragment. See [imsSipCode]. */
    private val imsReasonPattern =
        Regex("""ImsReasonInfo\s*::\s*\{[^,}]*,\s*(\d{1,3})\s*[,}]""")

    /** When the call was created (ring start for an incoming call), or 0 when the
     *  platform can't say. [Call.Details.getCreationTimeMillis] is API 26+; below
     *  that the caller falls back to its own timing. */
    private fun creationTimeMillis(details: Call.Details?): Long {
        if (details == null) return 0L
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return 0L
        return details.creationTimeMillis
    }

    /** Whether [c] is an incoming call: [Call.Details.getCallDirection] on API 29+,
     *  falling back to whether it was ever seen ringing. */
    private fun isIncoming(c: Call): Boolean {
        val details = c.details
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && details != null) {
            when (details.callDirection) {
                Call.Details.DIRECTION_INCOMING -> return true
                Call.Details.DIRECTION_OUTGOING -> return false
            }
        }
        return sawRingingCalls.contains(c)
    }

    fun onAudioStateChanged(state: CallAudioState) {
        audioState = state
        notifyChange()
    }

    // ---- Call selection -------------------------------------------------------

    /** Top-level calls only: independent calls and the conference host, but not a
     *  conference's child calls (those hang off [Call.getParent]). */
    private fun topLevel(): List<Call> = calls.filter { it.parent == null }

    @Suppress("DEPRECATION") // Call.getState() is fine down to our minSdk (24).
    private fun stateOf(c: Call): Int = c.state

    /**
     * The call the in-call UI should foreground. Prefers a connected call, then
     * an outgoing one being placed, then a ringing (incoming) call, then a held
     * one — so a two-call scenario surfaces the active leg while a lone incoming
     * call still shows as the primary.
     */
    private fun primaryCall(): Call? {
        val tl = topLevel()
        if (tl.isEmpty()) return null
        fun priority(c: Call): Int = when (stateOf(c)) {
            Call.STATE_ACTIVE -> 0
            Call.STATE_DIALING -> 1
            Call.STATE_CONNECTING -> 2
            Call.STATE_RINGING -> 3
            Call.STATE_SELECT_PHONE_ACCOUNT -> 4
            Call.STATE_HOLDING -> 5
            else -> 6
        }
        return tl.minByOrNull { priority(it) }
    }

    /** The background call behind the primary — the held leg of a two-call setup,
     *  else any other top-level call. Drives the "on hold" banner. */
    private fun secondaryCall(): Call? {
        val p = primaryCall() ?: return null
        return topLevel().firstOrNull { it !== p && stateOf(it) == Call.STATE_HOLDING }
            ?: topLevel().firstOrNull { it !== p }
    }

    // ---- Controls invoked from the Flutter method channel ---------------------

    fun answer() {
        primaryCall()?.answer(VideoProfile.STATE_AUDIO_ONLY)
    }

    fun disconnect() {
        primaryCall()?.disconnect()
    }

    /** The top-level call currently ringing — the waiting call in a call-waiting
     *  setup (the active call is primary, so [answer]/[disconnect] wouldn't target
     *  it). Null when nothing is ringing. */
    private fun ringingCall(): Call? =
        topLevel().firstOrNull { stateOf(it) == Call.STATE_RINGING }

    /** Answers the ringing (waiting) call. Telecom auto-holds the active call. */
    fun answerRingingCall() {
        ringingCall()?.answer(VideoProfile.STATE_AUDIO_ONLY)
    }

    /** Declines the ringing (waiting) call, leaving the active call untouched. */
    fun rejectRingingCall() {
        ringingCall()?.reject(false, null)
    }

    /**
     * Rejects a ringing incoming call and asks Telecom to text [message] back to
     * the caller. The Telecom system service sends the SMS itself (on the SIM the
     * call arrived on), so the app needs no SMS permission. No-op unless the
     * primary call is ringing — reject-with-message is only valid in that state.
     */
    fun rejectWithMessage(message: String) {
        val call = primaryCall() ?: return
        if (stateOf(call) == Call.STATE_RINGING) {
            call.reject(true, message)
        }
    }

    fun hold() {
        primaryCall()?.hold()
    }

    fun unhold() {
        primaryCall()?.unhold()
    }

    fun setMuted(muted: Boolean) {
        service?.setMuted(muted)
    }

    fun setSpeaker(on: Boolean) {
        val route = if (on) CallAudioState.ROUTE_SPEAKER else CallAudioState.ROUTE_EARPIECE
        service?.setAudioRoute(route)
    }

    // ---- State read by the ongoing-call notification's action buttons + timer -----

    fun isMuted(): Boolean = audioState?.isMuted ?: false

    fun isSpeakerOn(): Boolean =
        ((audioState?.route ?: 0) and CallAudioState.ROUTE_SPEAKER) != 0

    fun toggleMute() = setMuted(!isMuted())

    fun toggleSpeaker() = setSpeaker(!isSpeakerOn())

    /** Connect time of the primary call (0 until it goes active) for the notification's
     *  duration chronometer. */
    fun currentConnectTimeMillis(): Long = primaryCall()?.details?.connectTimeMillis ?: 0L

    /** Sends a DTMF touch-tone on the active call (IVR menus, dial-in bridges). */
    fun playDtmf(digit: Char) {
        try {
            primaryCall()?.playDtmfTone(digit)
        } catch (e: Exception) {
            // Best-effort; a tone that can't be sent just no-ops.
        }
    }

    /** Ends the DTMF tone started by [playDtmf] (call on key release). */
    fun stopDtmf() {
        try {
            primaryCall()?.stopDtmfTone()
        } catch (e: Exception) {
        }
    }

    /**
     * Conferences the primary and background calls, when the carrier/call reports
     * it can. Handles both "merge two independent calls" ([Call.conference]) and
     * "merge into an existing conference" ([Call.mergeConference]). Best-effort:
     * no-ops on networks without conference support (the UI hides the button then).
     */
    fun merge() {
        val p = primaryCall() ?: return
        val s = secondaryCall()
        try {
            if (s != null) p.conference(s) else p.mergeConference()
        } catch (e: Exception) {
            try {
                if (s != null) s.conference(p) else p.mergeConference()
            } catch (e2: Exception) {
                try {
                    p.mergeConference()
                } catch (e3: Exception) {
                }
            }
        }
    }

    /**
     * Swaps which call is in the foreground: a conference's own swap when
     * supported, else unholding the background leg (Telecom auto-holds the other).
     */
    fun swap() {
        val p = primaryCall() ?: return
        try {
            if (p.details.can(Call.Details.CAPABILITY_SWAP_CONFERENCE)) {
                p.swapConference()
                return
            }
        } catch (e: Exception) {
        }
        val held = topLevel().firstOrNull { stateOf(it) == Call.STATE_HOLDING }
        try {
            held?.unhold()
        } catch (e: Exception) {
        }
    }

    /**
     * Places [c] onto the phone account the user has designated for outgoing calls,
     * when one exists, so a call we placed with no chosen SIM (in-app "System
     * default") doesn't stall in [Call.STATE_SELECT_PHONE_ACCOUNT] waiting on us.
     *
     * When the OS is set to "ask every time" there is no default outgoing account,
     * so we leave the call in the select state and the Flutter layer shows the
     * in-app SIM picker (which drives [selectPhoneAccount]). Best-effort.
     */
    private fun maybeResolvePhoneAccount(c: Call) {
        val tm = service?.getSystemService(Context.TELECOM_SERVICE) as? TelecomManager
            ?: return
        val handle = try {
            tm.getDefaultOutgoingPhoneAccount("tel")
        } catch (e: Exception) {
            null
        } ?: return
        try {
            c.phoneAccountSelected(handle, false)
        } catch (e: Exception) {
            // Leave it selecting; the Flutter picker can still resolve it.
        }
    }

    /**
     * Resolves a call stuck in [Call.STATE_SELECT_PHONE_ACCOUNT] onto the SIM the
     * user picked in the in-app chooser. Reconstructs the handle from the flattened
     * component name + account id the Flutter side already holds.
     */
    fun selectPhoneAccount(phoneAccountId: String?, componentName: String?) {
        val c = topLevel().firstOrNull { stateOf(it) == Call.STATE_SELECT_PHONE_ACCOUNT }
            ?: return
        if (phoneAccountId.isNullOrBlank() || componentName.isNullOrBlank()) return
        val cn = ComponentName.unflattenFromString(componentName) ?: return
        try {
            c.phoneAccountSelected(PhoneAccountHandle(cn, phoneAccountId), false)
        } catch (e: Exception) {
            // Best-effort; the user can retry or cancel from the picker.
        }
    }

    fun hasActiveCall(): Boolean = calls.isNotEmpty()

    /** Plain-map snapshot of the primary call (plus multi-call flags), or null. */
    fun snapshot(): Map<String, Any?>? {
        val c = primaryCall() ?: return null
        val details = c.details
        val number = details?.handle?.schemeSpecificPart
        val canHold = details?.can(Call.Details.CAPABILITY_HOLD) ?: false
        val route = audioState?.route ?: 0
        val state = stateOf(c)
        val secondary = secondaryCall()

        // Multi-call / conference capabilities. Telecom sets MERGE/SWAP on the call
        // when the network can conference; when it can't, the flags stay false and
        // the Flutter UI simply doesn't show those buttons.
        val isConference = details?.hasProperty(Call.Details.PROPERTY_CONFERENCE) ?: false
        val canMergeCapability = details?.can(Call.Details.CAPABILITY_MERGE_CONFERENCE) ?: false
        val canMerge = canMergeCapability || secondary != null
        val canSwapCapability = details?.can(Call.Details.CAPABILITY_SWAP_CONFERENCE) ?: false
        val canSwap = canSwapCapability || secondary != null
        val busyLeg = topLevel().any {
            stateOf(it) == Call.STATE_RINGING ||
                stateOf(it) == Call.STATE_DIALING ||
                stateOf(it) == Call.STATE_CONNECTING
        }
        val canAddCall = (state == Call.STATE_ACTIVE || state == Call.STATE_HOLDING) &&
            !busyLeg && topLevel().size < 2
        val canDtmf = state == Call.STATE_ACTIVE

        // STIR/SHAKEN caller-number verification (API 30+): whether the network
        // vouches that the caller ID isn't spoofed. Null when unavailable.
        val verificationStatus =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && details != null) {
                when (details.callerNumberVerificationStatus) {
                    Connection.VERIFICATION_STATUS_PASSED -> "passed"
                    Connection.VERIFICATION_STATUS_FAILED -> "failed"
                    else -> "not_verified"
                }
            } else {
                null
            }

        return mapOf(
            "number" to number,
            "state" to stateName(state),
            "muted" to (audioState?.isMuted ?: false),
            "speaker" to (route and CallAudioState.ROUTE_SPEAKER != 0),
            "canHold" to canHold,
            "connectTimeMillis" to (details?.connectTimeMillis ?: 0L),
            // When the call was created — for an incoming call, when it started
            // ringing. The device call log stamps the call with this same
            // instant, so the Flutter logger dates its Recents row by it and the
            // two records of one call stay matchable (see CallEventLogger).
            "creationTimeMillis" to creationTimeMillis(details),
            // Which SIM/phone-account the call is on — matches the device call
            // log's PHONE_ACCOUNT_ID, so Flutter can map it to a SIM label.
            "phoneAccountId" to details?.accountHandle?.id,
            "direction" to callDirection(c),
            // Why the call ended, once it has. Null while it is still running —
            // the Flutter side latches the last non-null value it sees, because
            // the call is dropped from the registry moments later.
            "outcome" to callOutcome(c),
            // Stable per-call id so the Flutter logger writes exactly one Recents
            // row per physical call, even if the call flaps through end cycles.
            "callId" to (callIds[c] ?: 0L),
            // ---- Multi-call / conference ----
            "isConference" to isConference,
            "canMerge" to canMerge,
            "canSwap" to canSwap,
            "canAddCall" to canAddCall,
            "canDtmf" to canDtmf,
            "heldNumber" to secondary?.details?.handle?.schemeSpecificPart,
            "heldState" to secondary?.let { stateName(stateOf(it)) },
            "verificationStatus" to verificationStatus,
        )
    }

    /** "incoming" | "outgoing" | "unknown" for call [c]. Uses
     *  [Call.Details.getCallDirection] on API 29+, falling back to whether the
     *  call was ever seen ringing. */
    private fun callDirection(c: Call): String {
        val details = c.details
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && details != null) {
            return when (details.callDirection) {
                Call.Details.DIRECTION_INCOMING -> "incoming"
                Call.Details.DIRECTION_OUTGOING -> "outgoing"
                else -> if (sawRingingCalls.contains(c)) "incoming" else "unknown"
            }
        }
        return if (sawRingingCalls.contains(c)) "incoming" else "outgoing"
    }

    private fun notifyChange() {
        listener?.onCallChanged(snapshot())
        refreshCallNotification()
    }

    /**
     * Keeps the foreground call notification in step with call state: cleared when no
     * call remains, left to the ring path while ringing, otherwise shown as the ongoing
     * call notification (answered / outgoing / holding). Re-posting is cheap and lets the
     * mute/speaker buttons and the duration timer stay current on every state/audio change.
     */
    private fun refreshCallNotification() {
        val rc = ringController ?: return
        val p = primaryCall()
        if (p == null) {
            rc.onCallEnded()
            return
        }
        if (ringing) return
        rc.showOngoingCall(p.details?.handle?.schemeSpecificPart)
    }

    private fun stateName(state: Int): String = when (state) {
        Call.STATE_NEW -> "new"
        Call.STATE_CONNECTING -> "connecting"
        Call.STATE_DIALING -> "dialing"
        Call.STATE_RINGING -> "ringing"
        Call.STATE_ACTIVE -> "active"
        Call.STATE_HOLDING -> "holding"
        Call.STATE_DISCONNECTING -> "disconnecting"
        Call.STATE_DISCONNECTED -> "disconnected"
        Call.STATE_SELECT_PHONE_ACCOUNT -> "selecting"
        else -> "unknown"
    }
}
