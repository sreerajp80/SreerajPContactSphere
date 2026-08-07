package `in`.sreerajp.contact_sphere

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Button
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import org.json.JSONObject

/**
 * The emergency info card, drawn **over the keyguard**: `showWhenLocked` means
 * the system shows this activity without asking for the PIN, which is the whole
 * point — a first responder can read it and call someone.
 *
 * It renders from the plaintext card written by [EmergencyCardNotifier], never
 * from the encrypted database, and builds its views in code so it needs no
 * Flutter engine, no AndroidX theme, and no plugin initialisation. Nothing here
 * can reach any other app data.
 */
class EmergencyInfoActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showOverKeyguard()
        val card = EmergencyCardNotifier.readCard(this)
        if (card == null) {
            // The user turned the feature off (or a stale notification survived).
            finish()
            return
        }
        setContentView(buildView(card))
    }

    /**
     * Puts the window in front of the lock screen and lights the display. We do
     * NOT request keyguard dismissal — the phone stays locked; only this one
     * screen is visible.
     */
    private fun showOverKeyguard() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    // ---- view building ----

    private fun buildView(cardJson: String): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(BG)
            setPadding(dp(20), dp(28), dp(20), dp(24))
        }

        root.addView(
            label("EMERGENCY INFO & ICE CARD", 13f, ACCENT, bold = true).apply {
                letterSpacing = 0.14f
            },
        )

        val json = try {
            JSONObject(cardJson)
        } catch (_: Exception) {
            // Corrupt payload: show nothing rather than half a card.
            finish()
            return root
        }

        val owner = json.optString("owner").trim()
        if (owner.isNotEmpty()) {
            root.addView(label(owner, 26f, FG, bold = true).apply {
                setPadding(0, dp(4), 0, 0)
            })
        }

        val rows = json.optJSONArray("rows")
        if (rows != null && rows.length() > 0) {
            root.addView(spacer(dp(18)))
            for (i in 0 until rows.length()) {
                val row = rows.optJSONObject(i) ?: continue
                root.addView(
                    infoRow(row.optString("label"), row.optString("value")),
                )
            }
        }

        val contacts = json.optJSONArray("contacts")
        if (contacts != null && contacts.length() > 0) {
            root.addView(spacer(dp(20)))
            root.addView(label("EMERGENCY CONTACTS", 12f, MUTED, bold = true))
            root.addView(spacer(dp(8)))
            for (i in 0 until contacts.length()) {
                val c = contacts.optJSONObject(i) ?: continue
                root.addView(
                    contactRow(
                        c.optString("name"),
                        c.optString("relation").trim(),
                        c.optString("number"),
                    ),
                )
            }
        }

        // Generate High-Contrast Emergency QR Code for Paramedics / First Responders
        val iceTextBuilder = StringBuilder("EMERGENCY ICE CARD\n")
        if (owner.isNotEmpty()) {
            iceTextBuilder.append("Name: ").append(owner).append("\n")
        }
        if (rows != null && rows.length() > 0) {
            for (i in 0 until rows.length()) {
                val row = rows.optJSONObject(i) ?: continue
                iceTextBuilder.append(row.optString("label")).append(": ").append(row.optString("value")).append("\n")
            }
        }
        if (contacts != null && contacts.length() > 0) {
            iceTextBuilder.append("Contacts:\n")
            for (i in 0 until contacts.length()) {
                val c = contacts.optJSONObject(i) ?: continue
                val name = c.optString("name")
                val relation = c.optString("relation").trim()
                val num = c.optString("number")
                if (relation.isNotEmpty()) {
                    iceTextBuilder.append("- ").append(name).append(" (").append(relation).append("): ").append(num).append("\n")
                } else {
                    iceTextBuilder.append("- ").append(name).append(": ").append(num).append("\n")
                }
            }
        }

        val qrBitmap = EmergencyQrEncoder.generateHighContrastQr(iceTextBuilder.toString().trim(), dp(200))
        if (qrBitmap != null) {
            root.addView(spacer(dp(20)))
            val qrContainer = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER_HORIZONTAL
                setBackgroundColor(Color.parseColor("#161B22"))
                setPadding(dp(16), dp(16), dp(16), dp(16))

                addView(label("HIGH-CONTRAST EMERGENCY QR", 11f, ACCENT, bold = true).apply {
                    gravity = Gravity.CENTER
                })
                addView(spacer(dp(10)))
                addView(ImageView(this@EmergencyInfoActivity).apply {
                    setImageBitmap(qrBitmap)
                    layoutParams = LinearLayout.LayoutParams(dp(180), dp(180))
                })
                addView(spacer(dp(8)))
                addView(label("Scan with any camera for instant ICE medical details", 12f, MUTED, bold = false).apply {
                    gravity = Gravity.CENTER
                })
            }
            root.addView(qrContainer)
        }

        root.addView(spacer(dp(24)))
        root.addView(
            Button(this).apply {
                text = "Close"
                setOnClickListener { finish() }
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                )
            },
        )

        return ScrollView(this).apply {
            setBackgroundColor(BG)
            addView(
                root,
                ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                ),
            )
        }
    }

    /** One "Blood group / B+" line. */
    private fun infoRow(labelText: String, value: String): View =
        LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, dp(10), 0, dp(10))
            addView(label(labelText.uppercase(), 11f, MUTED, bold = true))
            addView(label(value, 18f, FG, bold = false))
        }

    /** One emergency contact, with a Call button. */
    private fun contactRow(name: String, relation: String, number: String): View =
        LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(0, dp(8), 0, dp(8))
            val column = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                layoutParams = LinearLayout.LayoutParams(
                    0,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    1f,
                )
                val heading = if (relation.isEmpty()) name else "$name · $relation"
                addView(label(heading, 18f, FG, bold = true))
                addView(label(number, 15f, MUTED, bold = false))
            }
            addView(column)
            addView(
                Button(context).apply {
                    text = "1-Tap Call"
                    setTextColor(Color.WHITE)
                    setBackgroundColor(ACCENT)
                    setOnClickListener { placeCall(number) }
                },
            )
        }

    private fun label(text: String, sizeSp: Float, color: Int, bold: Boolean): TextView =
        TextView(this).apply {
            this.text = text
            setTextColor(color)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, sizeSp)
            if (bold) setTypeface(typeface, android.graphics.Typeface.BOLD)
        }

    private fun spacer(height: Int): View = View(this).apply {
        layoutParams = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            height,
        )
    }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()

    /**
     * Dials [number] straight away — an emergency card that makes you find the
     * dialer first is useless. Falls back to opening the dialer pre-filled if
     * CALL_PHONE was never granted or the call intent is refused.
     */
    private fun placeCall(number: String) {
        val uri = Uri.fromParts("tel", number, null)
        val granted = Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            checkSelfPermission(Manifest.permission.CALL_PHONE) ==
            PackageManager.PERMISSION_GRANTED
        if (granted) {
            try {
                startActivity(Intent(Intent.ACTION_CALL, uri))
                return
            } catch (_: Exception) {
                // fall through to the dialer
            }
        }
        try {
            startActivity(Intent(Intent.ACTION_DIAL, uri))
        } catch (_: Exception) {
            // Nothing can handle it; leave the card up.
        }
    }

    private companion object {
        val BG = Color.parseColor("#0E1116")
        val FG = Color.parseColor("#F2F4F8")
        val MUTED = Color.parseColor("#9AA4B2")
        val ACCENT = Color.parseColor("#FF5A5F")
    }
}
