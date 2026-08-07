package `in`.sreerajp.contact_sphere

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Handles the call notification's action buttons (hang up / answer / decline / mute /
 * speaker) posted by [ContactSphereInCallService], plus the "Dismiss" button on our own
 * missed-call notification. Routes call controls back into the shared [CallRegistry]
 * singleton. Runs in the app process.
 *
 * This receiver is declared `android:exported="false"`, so only our own PendingIntents
 * can fire it. The missed-call **"Call back"** action does NOT go through here — it
 * launches [MainActivity] directly (a broadcast that then calls `startActivity` is
 * blocked as a notification trampoline on Android 12+), guarded by a one-shot token in
 * [PendingCallback]. Only cancel-only "Dismiss" (no activity launch) lives here.
 */
class CallActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_HANGUP -> CallRegistry.disconnect()
            ACTION_ANSWER -> CallRegistry.answer()
            ACTION_DECLINE -> CallRegistry.disconnect()
            ACTION_MUTE -> CallRegistry.toggleMute()
            ACTION_SPEAKER -> CallRegistry.toggleSpeaker()
            ACTION_DISMISS_MISSED -> handleDismissMissed(context, intent)
        }
    }

    /** "Dismiss" on our missed-call notification: cancel it and drop the armed call-back
     *  token so it doesn't linger. Cancel-only — no activity is launched. */
    private fun handleDismissMissed(context: Context, intent: Intent) {
        val notifId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, -1)
        if (notifId != -1) {
            context.getSystemService(NotificationManager::class.java)?.cancel(notifId)
        }
        val token = intent.getLongExtra(EXTRA_TOKEN, 0L)
        if (token != 0L) PendingCallback.drop(token)
    }

    companion object {
        const val ACTION_HANGUP = "in.sreerajp.contact_sphere.HANGUP"
        const val ACTION_ANSWER = "in.sreerajp.contact_sphere.ANSWER"
        const val ACTION_DECLINE = "in.sreerajp.contact_sphere.DECLINE"
        const val ACTION_MUTE = "in.sreerajp.contact_sphere.MUTE"
        const val ACTION_SPEAKER = "in.sreerajp.contact_sphere.SPEAKER"
        const val ACTION_DISMISS_MISSED = "in.sreerajp.contact_sphere.DISMISS_MISSED"
        const val EXTRA_NOTIFICATION_ID = "in.sreerajp.contact_sphere.extra.NOTIFICATION_ID"
        const val EXTRA_TOKEN = "in.sreerajp.contact_sphere.extra.TOKEN"
    }
}
