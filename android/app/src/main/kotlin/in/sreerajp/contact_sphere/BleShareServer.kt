package `in`.sreerajp.contact_sphere

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattServer
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import java.util.UUID

/**
 * BLE peripheral for "Share via Bluetooth": advertises ContactSphere's share
 * service and serves one vCard payload over a GATT server, so another phone
 * (the flutter_blue_plus central in ble_receive_service.dart) can scan,
 * connect, and download it.
 *
 * Chunked-read protocol (GATT attribute values are capped at 512 bytes, so a
 * vCard can't be a single read):
 *  - `size` (read): uint32 little-endian total payload length.
 *  - `offset` (write): uint32 little-endian; the offset the next `data` read
 *    starts from. Explicit offsets keep the protocol stateless per read, so a
 *    receiver retry can't skip or duplicate bytes.
 *  - `data` (read): payload bytes from the written offset, at most
 *    min(MTU - 3, 480) per read.
 *
 * The advertisement carries the service UUID (receivers scan-filter on it);
 * the scan response carries the shared contact's display name as service data
 * (31-byte scan response - 18-byte service-data overhead = 13 name bytes).
 *
 * All Bluetooth callbacks arrive on binder threads; events are posted to the
 * main thread before reaching [listener] (which forwards to the Flutter
 * EventChannel). Every Bluetooth call is wrapped against [SecurityException]
 * so a mid-flight permission revocation degrades to an error event, never a
 * crash.
 */
class BleShareServer(private val context: Context) {

    /** Receives `{state, message?}` maps, already on the main thread. */
    interface Listener {
        fun onEvent(event: Map<String, Any?>)
    }

    var listener: Listener? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    private var advertiser: BluetoothLeAdvertiser? = null
    private var gattServer: BluetoothGattServer? = null
    private var payload: ByteArray = ByteArray(0)

    /** Offset the next `data` read serves from; written by the central. */
    @Volatile private var currentOffset = 0

    /** Negotiated MTU (server side); 23 is the BLE default. */
    @Volatile private var mtu = 23

    /** True once the final payload byte has been served (event fired once). */
    @Volatile private var completeSent = false

    private fun emit(state: String, message: String? = null) {
        mainHandler.post {
            listener?.onEvent(mapOf("state" to state, "message" to message))
        }
    }

    /**
     * Progress variant of [emit] for `sending`: [sent]/[total] bytes served so
     * far, so the Dart dialog can show a percentage on long (whole-book)
     * transfers. One event per chunk read (~10/s) — fine for an EventChannel.
     */
    private fun emitSending(sent: Int, total: Int) {
        mainHandler.post {
            listener?.onEvent(
                mapOf(
                    "state" to "sending",
                    "message" to null,
                    "sent" to sent,
                    "total" to total,
                ),
            )
        }
    }

    /**
     * Starts the GATT server and advertising for [vcard], announcing
     * [displayName] in the scan response. Returns null on success or a short
     * error code ("bluetooth_off", "unsupported", "no_permission",
     * "already_sharing", "start_failed") the Dart side turns into UI.
     */
    fun start(vcard: ByteArray, displayName: String): String? {
        if (gattServer != null) return "already_sharing"

        val manager = context.getSystemService(Context.BLUETOOTH_SERVICE)
            as? BluetoothManager ?: return "unsupported"
        val adapter: BluetoothAdapter = manager.adapter ?: return "unsupported"
        if (!adapter.isEnabled) return "bluetooth_off"
        val leAdvertiser = adapter.bluetoothLeAdvertiser ?: return "unsupported"

        payload = vcard
        currentOffset = 0
        mtu = 23
        completeSent = false

        val service = BluetoothGattService(
            SERVICE_UUID,
            BluetoothGattService.SERVICE_TYPE_PRIMARY,
        ).apply {
            addCharacteristic(
                BluetoothGattCharacteristic(
                    SIZE_UUID,
                    BluetoothGattCharacteristic.PROPERTY_READ,
                    BluetoothGattCharacteristic.PERMISSION_READ,
                ),
            )
            addCharacteristic(
                BluetoothGattCharacteristic(
                    OFFSET_UUID,
                    BluetoothGattCharacteristic.PROPERTY_WRITE,
                    BluetoothGattCharacteristic.PERMISSION_WRITE,
                ),
            )
            addCharacteristic(
                BluetoothGattCharacteristic(
                    DATA_UUID,
                    BluetoothGattCharacteristic.PROPERTY_READ,
                    BluetoothGattCharacteristic.PERMISSION_READ,
                ),
            )
        }

        try {
            gattServer = manager.openGattServer(context, gattCallback)
            if (gattServer == null) {
                stop()
                return "start_failed"
            }
            gattServer?.addService(service)
        } catch (e: SecurityException) {
            stop()
            return "no_permission"
        } catch (e: Exception) {
            stop()
            return "start_failed"
        }

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .setConnectable(true)
            .setTimeout(0) // The Dart dialog owns the share timeout.
            .build()
        val advertiseData = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()
        val scanResponse = AdvertiseData.Builder()
            .addServiceData(
                ParcelUuid(SERVICE_UUID),
                truncateUtf8(displayName, MAX_NAME_BYTES),
            )
            .build()

        return try {
            advertiser = leAdvertiser
            leAdvertiser.startAdvertising(settings, advertiseData, scanResponse, advertiseCallback)
            null
        } catch (e: SecurityException) {
            stop()
            "no_permission"
        } catch (e: Exception) {
            stop()
            "start_failed"
        }
    }

    /** Stops advertising and closes the GATT server. Safe to call repeatedly. */
    fun stop() {
        try {
            advertiser?.stopAdvertising(advertiseCallback)
        } catch (e: Exception) {
            // Adapter already off / permission gone; nothing left to stop.
        }
        advertiser = null
        try {
            gattServer?.close()
        } catch (e: Exception) {
            // Same: closing a dead server is a no-op for us.
        }
        gattServer = null
        payload = ByteArray(0)
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            emit("advertising")
        }

        override fun onStartFailure(errorCode: Int) {
            emit(
                "error",
                when (errorCode) {
                    ADVERTISE_FAILED_DATA_TOO_LARGE -> "Advertisement too large"
                    ADVERTISE_FAILED_TOO_MANY_ADVERTISERS -> "Bluetooth is busy advertising"
                    ADVERTISE_FAILED_ALREADY_STARTED -> "Already advertising"
                    ADVERTISE_FAILED_FEATURE_UNSUPPORTED ->
                        "This phone can't advertise over Bluetooth LE"
                    else -> "Could not start Bluetooth sharing (code $errorCode)"
                },
            )
        }
    }

    private val gattCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            when (newState) {
                BluetoothGatt.STATE_CONNECTED -> {
                    // New receiver: restart the transfer bookkeeping.
                    currentOffset = 0
                    emit("connected")
                }
                BluetoothGatt.STATE_DISCONNECTED -> emit("disconnected")
            }
        }

        override fun onMtuChanged(device: BluetoothDevice, newMtu: Int) {
            mtu = newMtu
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice,
            requestId: Int,
            attOffset: Int,
            characteristic: BluetoothGattCharacteristic,
        ) {
            val server = gattServer ?: return
            val value: ByteArray? = when (characteristic.uuid) {
                SIZE_UUID -> uint32Le(payload.size)
                DATA_UUID -> {
                    val from = (currentOffset + attOffset).coerceAtMost(payload.size)
                    val to = (from + chunkCap()).coerceAtMost(payload.size)
                    val chunk = payload.copyOfRange(from, to)
                    emitSending(to, payload.size)
                    if (to >= payload.size && payload.isNotEmpty() && !completeSent) {
                        completeSent = true
                        emit("complete")
                    }
                    chunk
                }
                else -> null
            }
            try {
                if (value == null) {
                    server.sendResponse(
                        device, requestId, BluetoothGatt.GATT_READ_NOT_PERMITTED, 0, null,
                    )
                } else {
                    // `size` is a plain 4-byte value: honor ATT's own offset on
                    // it (a long read of a short value slices past attOffset).
                    val out = if (characteristic.uuid == SIZE_UUID) {
                        if (attOffset >= value.size) ByteArray(0)
                        else value.copyOfRange(attOffset, value.size)
                    } else {
                        value // `data` already applied attOffset above.
                    }
                    server.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, attOffset, out)
                }
            } catch (e: Exception) {
                emit("error", "Transfer failed mid-read")
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            attOffset: Int,
            value: ByteArray?,
        ) {
            var status = BluetoothGatt.GATT_REQUEST_NOT_SUPPORTED
            if (characteristic.uuid == OFFSET_UUID && !preparedWrite &&
                value != null && value.size >= 4
            ) {
                currentOffset = readUint32Le(value).coerceAtLeast(0)
                status = BluetoothGatt.GATT_SUCCESS
            }
            if (responseNeeded) {
                try {
                    gattServer?.sendResponse(device, requestId, status, attOffset, null)
                } catch (e: Exception) {
                    emit("error", "Transfer failed mid-write")
                }
            }
        }
    }

    /**
     * Max `data` bytes per read: MTU minus the 1-byte ATT opcode and a 2-byte
     * safety margin, hard-capped under the 512-byte attribute limit.
     */
    private fun chunkCap(): Int = (mtu - 3).coerceIn(20, 480)

    companion object {
        // Fixed app-specific UUIDs; mirrored in lib/services/ble_protocol.dart.
        val SERVICE_UUID: UUID = UUID.fromString("7f9a1b3e-c5d2-4b8a-9f6e-2d8f3a7c4e10")
        val SIZE_UUID: UUID = UUID.fromString("7f9a1b3e-c5d2-4b8a-9f6e-2d8f3a7c4e11")
        val OFFSET_UUID: UUID = UUID.fromString("7f9a1b3e-c5d2-4b8a-9f6e-2d8f3a7c4e12")
        val DATA_UUID: UUID = UUID.fromString("7f9a1b3e-c5d2-4b8a-9f6e-2d8f3a7c4e13")

        /** 31-byte scan response minus 18 bytes of 128-bit service-data overhead. */
        private const val MAX_NAME_BYTES = 13

        fun uint32Le(v: Int): ByteArray = byteArrayOf(
            (v and 0xFF).toByte(),
            ((v shr 8) and 0xFF).toByte(),
            ((v shr 16) and 0xFF).toByte(),
            ((v shr 24) and 0xFF).toByte(),
        )

        fun readUint32Le(b: ByteArray): Int =
            (b[0].toInt() and 0xFF) or
                ((b[1].toInt() and 0xFF) shl 8) or
                ((b[2].toInt() and 0xFF) shl 16) or
                ((b[3].toInt() and 0xFF) shl 24)

        /** [s] as UTF-8, cut to at most [max] bytes on a character boundary. */
        fun truncateUtf8(s: String, max: Int): ByteArray {
            val bytes = s.toByteArray(Charsets.UTF_8)
            if (bytes.size <= max) return bytes
            var end = max
            // Back off any continuation bytes (10xxxxxx) split mid-character.
            while (end > 0 && (bytes[end].toInt() and 0xC0) == 0x80) end--
            return bytes.copyOfRange(0, end)
        }
    }
}
