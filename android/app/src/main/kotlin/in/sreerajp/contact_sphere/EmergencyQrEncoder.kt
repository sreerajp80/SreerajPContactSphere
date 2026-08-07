package `in`.sreerajp.contact_sphere

import android.graphics.Bitmap
import android.graphics.Color
import com.google.zxing.BarcodeFormat
import com.google.zxing.EncodeHintType
import com.google.zxing.qrcode.QRCodeWriter

/**
 * Generates a high-contrast QR code bitmap for the lockscreen emergency card.
 *
 * Paramedics or first responders can scan this code using any mobile camera
 * to immediately read the medical summary and ICE emergency contact details.
 */
object EmergencyQrEncoder {

    /**
     * Renders [content] into a high-contrast [Bitmap] of size [sizePx] x [sizePx].
     * Uses stark white modules on a dark background for optimum readability on screens.
     */
    fun generateHighContrastQr(content: String, sizePx: Int): Bitmap? {
        if (content.isBlank()) return null
        return try {
            val hints = mapOf(
                EncodeHintType.MARGIN to 1,
                EncodeHintType.CHARACTER_SET to "UTF-8",
            )
            val matrix = QRCodeWriter().encode(content, BarcodeFormat.QR_CODE, sizePx, sizePx, hints)
            val width = matrix.width
            val height = matrix.height
            val pixels = IntArray(width * height)
            for (y in 0 until height) {
                val offset = y * width
                for (x in 0 until width) {
                    pixels[offset + x] = if (matrix.get(x, y)) Color.WHITE else Color.BLACK
                }
            }
            Bitmap.createBitmap(pixels, width, height, Bitmap.Config.ARGB_8888)
        } catch (_: Exception) {
            null
        }
    }
}
