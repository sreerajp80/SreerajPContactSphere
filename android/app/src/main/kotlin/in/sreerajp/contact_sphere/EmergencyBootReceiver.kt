package `in`.sreerajp.contact_sphere

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Notifications do not survive a reboot, so the lock-screen "Emergency info"
 * shortcut would silently disappear until the user next opened the app — the
 * one moment it must not. This re-posts it after boot, straight from the
 * published card in SharedPreferences (no Flutter engine needed).
 *
 * Also re-arms any still-pending Smart Redial alarms, which Android likewise
 * clears on reboot (see [SmartRedialManager.rescheduleAfterBoot]).
 */
class EmergencyBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        // Only the normal (post-unlock) boot broadcast: the card lives in
        // credential-encrypted storage, so it is not readable in direct-boot mode.
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != "android.intent.action.QUICKBOOT_POWERON"
        ) {
            return
        }
        EmergencyCardNotifier.refresh(context)
        SmartRedialManager.rescheduleAfterBoot(context)
        NotificationSchedulerManager.rescheduleAfterBoot(context)
    }
}
