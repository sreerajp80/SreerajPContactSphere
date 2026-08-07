package `in`.sreerajp.contact_sphere

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.media.ToneGenerator
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import org.json.JSONObject
import java.io.File

/**
 * Plays the incoming-call ringtone and drives vibration while ContactSphere owns
 * the ringing UI (the manifest declares IN_CALL_SERVICE_RINGING, so the platform
 * does NOT ring for us — we must).
 *
 * [start] resolves the tone synchronously from the ringtone mirror — per-contact
 * and per-SIM tone maps the Flutter side keeps copied into native SharedPreferences
 * (see MainActivity.setRingtoneMirror) — falling back to the system default, so the
 * correct tone plays from the first note even on a cold start. [setCustomTone]
 * remains as a late correction for a stale mirror; it applies only when it
 * upgrades the playing tone's tier (default < SIM < contact) or corrects a
 * different tone at the same tier, so it never restarts a matching ring and a
 * racing SIM push can't override a contact tone. Everything is gated by the
 * device ringer mode:
 * silent → nothing, vibrate → vibrate only, normal → sound + vibrate. Best-effort
 * throughout: a failure to play a tone must never crash call handling.
 */
class IncomingCallRinger(private val context: Context) {

    private val audioManager =
        context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    private var player: MediaPlayer? = null
    private var focusRequest: AudioFocusRequest? = null
    private var vibrating = false

    /** Set while a call-waiting beep is running (a second call arriving while
     *  another call is already active). Instead of the loud ringtone we play the
     *  standard supervisory call-waiting tone into the voice-call stream and
     *  repeat it every few seconds, like other dialers. */
    private var toneGenerator: ToneGenerator? = null
    private val toneHandler = Handler(Looper.getMainLooper())
    private val toneRepeater = object : Runnable {
        override fun run() {
            try {
                toneGenerator?.startTone(ToneGenerator.TONE_SUP_CALL_WAITING)
                toneHandler.postDelayed(this, CALL_WAITING_REPEAT_MS)
            } catch (e: Exception) {
                // Best-effort; a tone that can't play just stops repeating.
            }
        }
    }

    /** The tone currently set up on [player], so a late push of the same tone
     *  (Flutter safety net vs. the mirror) doesn't restart it mid-ring. */
    private var playingUri: Uri? = null

    /** Tier of [playingUri] (default < SIM < contact), so a late push only ever
     *  upgrades the tone — a SIM push can never override a contact tone no matter
     *  how the Flutter-side resolutions race each other. */
    private var playingTier: Int = TIER_DEFAULT

    /**
     * User ringer preferences, mirrored from the Flutter side into a plain native
     * SharedPreferences file so we can read them synchronously the instant a call
     * arrives — the Flutter engine may not be running yet on a cold start. Absent
     * keys fall back to the defaults below (full volume, vibration on).
     */
    private val ringerPrefs =
        context.getSharedPreferences(RINGER_PREFS, Context.MODE_PRIVATE)

    /** 0.0–1.0 scale applied to the tone within the ring stream (100% by default). */
    private val volume: Float =
        (ringerPrefs.getInt(KEY_VOLUME_PERCENT, 100).coerceIn(0, 100)) / 100f

    /** Whether to vibrate on an incoming call (on by default). */
    private val vibrateEnabled: Boolean =
        ringerPrefs.getBoolean(KEY_VIBRATE, true)

    private val ringtoneAttributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
        .build()

    /**
     * Start ringing + vibration for a call from [number] on the SIM identified by
     * [phoneAccountId], gated by the ringer mode. The tone is resolved from the
     * mirrored maps (contact tone → SIM tone → system default) so the right tone
     * plays from the first note.
     */
    fun start(number: String?, phoneAccountId: String?) {
        when (audioManager.ringerMode) {
            AudioManager.RINGER_MODE_SILENT -> return
            AudioManager.RINGER_MODE_VIBRATE -> startVibration()
            else -> {
                startVibration()
                requestFocus()
                // A mirrored tone can be stale (backing file deleted/moved); fall
                // through to the next tier so the call still rings audibly.
                val contactUri = contactTonePath(number)?.let { safeUri(it) }
                val simUri = simTonePath(phoneAccountId)?.let { safeUri(it) }
                if (!playUri(contactUri, TIER_CONTACT) && !playUri(simUri, TIER_SIM)) {
                    playUri(defaultRingtoneUri(), TIER_DEFAULT)
                }
            }
        }
    }

    /**
     * Play a call-waiting beep for a second call that arrives while another call
     * is already active. Unlike [start] this is deliberately *not* gated by the
     * ringer mode: the call-waiting tone is an in-call supervisory tone heard in
     * the earpiece (through the voice-call stream) even in silent/vibrate mode,
     * matching how other dialers behave. Repeats every [CALL_WAITING_REPEAT_MS]
     * until [stop]. Best-effort — a failure to play must never crash call handling.
     */
    fun startCallWaiting() {
        try {
            if (toneGenerator == null) {
                toneGenerator = ToneGenerator(
                    AudioManager.STREAM_VOICE_CALL,
                    CALL_WAITING_TONE_VOLUME,
                )
            }
            // Fire once now, then repeat on the handler.
            toneHandler.removeCallbacks(toneRepeater)
            toneHandler.post(toneRepeater)
        } catch (e: Exception) {
            // A device that can't create a ToneGenerator simply gets no beep.
            toneGenerator = null
        }
    }

    /**
     * Late Flutter-side tone push (best-effort) — kept as a safety net for a stale
     * mirror. [source] is `"contact"` or `"sim"`; the push applies only when it
     * *upgrades* the playing tone's tier (a contact tone the mirror missed) or
     * corrects a genuinely different tone at the same tier (stale mirror). Anything
     * else no-ops, so a push matching what [start] already resolved never restarts
     * the ring, and a racing SIM push can never override a contact tone. Also no-op
     * when the ringer isn't in normal mode (silent/vibrate) or the path can't be
     * resolved.
     */
    fun setCustomTone(path: String?, source: String?) {
        if (path.isNullOrBlank()) return
        if (audioManager.ringerMode != AudioManager.RINGER_MODE_NORMAL) return
        val tier = if (source == SOURCE_CONTACT) TIER_CONTACT else TIER_SIM
        val uri = safeUri(path) ?: return
        if (uri == playingUri) {
            // Same tone — just record the stronger tier so a later, weaker push
            // can't displace it.
            if (tier > playingTier) playingTier = tier
            return
        }
        // A weaker tier never displaces a stronger tone (a racing SIM push must not
        // override a contact tone). Equal tier + different URI = stale-mirror fix.
        if (tier < playingTier) return
        requestFocus()
        // A persisted content:// tone can fail if its backing file was deleted/moved
        // (or an SD card unmounted). Fall back to the default tone so the call still
        // rings audibly instead of going silent.
        if (!playUri(uri, tier)) playUri(defaultRingtoneUri(), TIER_DEFAULT)
    }

    /** Stop everything and release resources. Safe to call more than once. */
    fun stop() {
        try { player?.stop() } catch (e: Exception) { /* already stopped */ }
        player?.release()
        player = null
        playingUri = null
        playingTier = TIER_DEFAULT
        stopCallWaiting()
        abandonFocus()
        stopVibration()
    }

    /** Stop and release the call-waiting beep (if any). */
    private fun stopCallWaiting() {
        toneHandler.removeCallbacks(toneRepeater)
        try { toneGenerator?.stopTone() } catch (e: Exception) { /* ignore */ }
        try { toneGenerator?.release() } catch (e: Exception) { /* ignore */ }
        toneGenerator = null
    }

    // ---- Ringtone mirror (contact/SIM tone maps pushed from Flutter) ----

    /** [toUri] that never throws (null for an unparseable path). */
    private fun safeUri(path: String): Uri? =
        try { toUri(path) } catch (e: Exception) { null }

    private fun contactTonePath(number: String?): String? {
        val key = matchKey(number) ?: return null
        return readMirrorMap(KEY_CONTACT_TONES)?.optString(key)?.takeIf { it.isNotBlank() }
    }

    private fun simTonePath(phoneAccountId: String?): String? {
        if (phoneAccountId.isNullOrBlank()) return null
        return readMirrorMap(KEY_SIM_TONES)?.optString(phoneAccountId)?.takeIf { it.isNotBlank() }
    }

    /** Trailing [MATCH_DIGITS] digits of [number] (whole string when shorter). */
    private fun matchKey(number: String?): String? = Companion.matchKey(number)

    private fun readMirrorMap(prefKey: String): JSONObject? {
        val raw = ringerPrefs.getString(prefKey, null) ?: return null
        return try { JSONObject(raw) } catch (e: Exception) { null }
    }

    /** Returns true when the tone was set up, false when [uri] couldn't be opened. */
    private fun playUri(uri: Uri?, tier: Int): Boolean {
        if (uri == null) return false
        // Replace any tone already playing (e.g. default → custom).
        try { player?.stop() } catch (e: Exception) { /* ignore */ }
        player?.release()
        player = null
        playingUri = null
        playingTier = TIER_DEFAULT
        var created: MediaPlayer? = null
        return try {
            val mp = MediaPlayer()
            created = mp
            mp.setDataSource(context, uri)
            mp.setAudioAttributes(ringtoneAttributes)
            mp.isLooping = true
            // Scale the tone by the user's ringtone-volume preference (0 mutes
            // the sound while any enabled vibration still fires).
            mp.setVolume(volume, volume)
            mp.setOnPreparedListener {
                // A competing playUri/stop may have released this player while it
                // was preparing; starting it then throws inside the system callback.
                if (player === mp) {
                    try { it.start() } catch (e: Exception) { /* replaced mid-prepare */ }
                }
            }
            mp.setOnErrorListener { failed, _, _ ->
                // An async failure (media unreadable only after setDataSource) would
                // otherwise leave the call ringing in silence — fall back to the
                // default tone. If the default itself fails, give up (no retry loop).
                if (player === failed && uri != defaultRingtoneUri()) {
                    playUri(defaultRingtoneUri(), TIER_DEFAULT)
                }
                true
            }
            mp.prepareAsync()
            player = mp
            playingUri = uri
            playingTier = tier
            true
        } catch (e: Exception) {
            // Couldn't open this tone (missing file / lost permission); report so the
            // caller can fall back rather than leaving silence.
            created?.release()
            player = null
            false
        }
    }

    private fun defaultRingtoneUri(): Uri? =
        RingtoneManager.getActualDefaultRingtoneUri(context, RingtoneManager.TYPE_RINGTONE)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)

    private fun toUri(path: String): Uri =
        if (path.contains("://")) Uri.parse(path) else Uri.fromFile(File(path))

    // ---- Audio focus ----

    private fun requestFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (focusRequest != null) return // already held
            val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT)
                .setAudioAttributes(ringtoneAttributes)
                .build()
            focusRequest = req
            audioManager.requestAudioFocus(req)
        } else {
            @Suppress("DEPRECATION")
            audioManager.requestAudioFocus(
                null,
                AudioManager.STREAM_RING,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT,
            )
        }
    }

    private fun abandonFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
            focusRequest = null
        } else {
            @Suppress("DEPRECATION")
            audioManager.abandonAudioFocus(null)
        }
    }

    // ---- Vibration ----

    private fun vibrator(): Vibrator? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE)
                as? VibratorManager
            vm?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }

    private fun startVibration() {
        if (!vibrateEnabled) return
        val v = vibrator() ?: return
        if (!v.hasVibrator()) return
        // wait, buzz, gap — repeats from index 0.
        val pattern = longArrayOf(0, 1000, 1000)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            v.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            v.vibrate(pattern, 0)
        }
        vibrating = true
    }

    private fun stopVibration() {
        if (!vibrating) return
        try { vibrator()?.cancel() } catch (e: Exception) { /* ignore */ }
        vibrating = false
    }

    companion object {
        /** Native mirror of the Flutter-side ringer preferences (see MainActivity). */
        const val RINGER_PREFS = "contact_sphere_ringer"
        const val KEY_VOLUME_PERCENT = "ringtone_volume_percent"
        const val KEY_VIBRATE = "vibrate_on_incoming_call"

        /** JSON map: trailing-digit number key → contact ringtone path/URI. */
        const val KEY_CONTACT_TONES = "contact_ringtones"

        /** JSON map: phoneAccountId → per-SIM ringtone path/URI. */
        const val KEY_SIM_TONES = "sim_ringtones"

        /** JSON map: trailing-digit number key → contact display name. Read by the
         *  missed-call notification (ContactSphereInCallService) to show a name. */
        const val KEY_CONTACT_NAMES = "contact_names"

        /** JSON array of `{number, at, phoneAccountId}` for call-waiting missed
         *  calls the snapshot logger never saw. Written by ContactSphereInCallService
         *  and drained into Recents one-shot via MainActivity.getMissedCallEvents. */
        const val KEY_MISSED_EVENTS = "missed_events"

        /** JSON array of `{number, at, outcome}` for outgoing calls Telecom gave a
         *  reason for that no Flutter screen was watching (chiefly a Smart Redial
         *  retry dialed with the app closed). Written by ContactSphereInCallService
         *  and drained one-shot via MainActivity.getOutgoingOutcomeEvents, which
         *  only ever patches an existing Recents row's outcome. */
        const val KEY_OUTGOING_OUTCOMES = "outgoing_outcomes"

        /**
         * Numbers are keyed by their trailing 10 digits — India's fixed 10-digit
         * mobile plan, and the same slice the Flutter side keys the mirror /
         * prefilters `findByFullNumber` on, so all of them agree. 10 (not 7) so
         * distinct numbers sharing a shorter suffix (e.g. 9000123456 and 9111123456
         * both end 0123456) don't collide, while a leading +91 / 0 is still absorbed.
         */
        const val MATCH_DIGITS = 10

        /** Trailing [MATCH_DIGITS] digits of [number] (whole digit string when
         *  shorter), or null when there are no digits. Shared so every native reader
         *  (the ringer and the missed-call notification) keys numbers identically. */
        fun matchKey(number: String?): String? {
            val digits = number?.filter { it.isDigit() } ?: return null
            if (digits.isEmpty()) return null
            return if (digits.length > MATCH_DIGITS) digits.takeLast(MATCH_DIGITS) else digits
        }

        /** How often the call-waiting supervisory tone repeats while a second
         *  call keeps ringing (the tone itself is a short pattern). */
        private const val CALL_WAITING_REPEAT_MS = 4000L

        /** ToneGenerator volume (0–100) for the call-waiting beep — moderate so it
         *  is audible in the earpiece over the active call without being harsh. */
        private const val CALL_WAITING_TONE_VOLUME = 80

        /** Tone tiers: a late push only ever moves up this ladder (see [setCustomTone]). */
        private const val TIER_DEFAULT = 0
        private const val TIER_SIM = 1
        private const val TIER_CONTACT = 2

        /** [setCustomTone] source value marking a contact-specific tone push. */
        const val SOURCE_CONTACT = "contact"
    }
}
