package `in`.sreerajp.contact_sphere

import android.content.ContentProviderOperation
import android.content.ContentResolver
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds.Email
import android.provider.ContactsContract.CommonDataKinds.Event
import android.provider.ContactsContract.CommonDataKinds.Im
import android.provider.ContactsContract.CommonDataKinds.Organization
import android.provider.ContactsContract.CommonDataKinds.Phone
import android.provider.ContactsContract.CommonDataKinds.Photo
import android.provider.ContactsContract.CommonDataKinds.StructuredName
import android.provider.ContactsContract.CommonDataKinds.StructuredPostal
import android.provider.ContactsContract.Data
import android.provider.ContactsContract.RawContacts

/**
 * Writes a contact into the phone's **local** account (ACCOUNT_TYPE = null,
 * ACCOUNT_NAME = null) via a direct ContentResolver batch.
 *
 * flutter_contacts 2.1.0 cannot target the local account: an empty [Account] is
 * discarded and `create()` falls back to the user's default (cloud) account. So
 * the "Device (this phone)" destination is written here instead. Real accounts
 * still go through the plugin.
 *
 * The payload is a compact map mirroring what `DeviceContactService._toDevice`
 * produces; the type ints are standard `ContactsContract` values resolved on the
 * Dart side, so this stays a dumb builder. Returns the new contact id as a
 * string, or null on failure.
 */
object LocalContactWriter {

    @Suppress("UNCHECKED_CAST")
    fun create(resolver: ContentResolver, payload: Map<String, Any?>): String? {
        val ops = ArrayList<ContentProviderOperation>()

        // 0: the raw contact, pinned to the local (null/null) account.
        ops.add(
            ContentProviderOperation.newInsert(RawContacts.CONTENT_URI)
                .withValue(RawContacts.ACCOUNT_TYPE, null)
                .withValue(RawContacts.ACCOUNT_NAME, null)
                .build(),
        )
        val rawIdx = 0

        // Structured name.
        val prefix = payload["prefix"] as? String
        val first = payload["first"] as? String
        val middle = payload["middle"] as? String
        val last = payload["last"] as? String
        if (!prefix.isNullOrEmpty() || !first.isNullOrEmpty() ||
            !middle.isNullOrEmpty() || !last.isNullOrEmpty()
        ) {
            ops.add(
                dataInsert(rawIdx, StructuredName.CONTENT_ITEM_TYPE)
                    .withValue(StructuredName.PREFIX, prefix)
                    .withValue(StructuredName.GIVEN_NAME, first)
                    .withValue(StructuredName.MIDDLE_NAME, middle)
                    .withValue(StructuredName.FAMILY_NAME, last)
                    .build(),
            )
        }

        (payload["phones"] as? List<Map<String, Any?>>)?.forEach { p ->
            val number = p["number"] as? String ?: return@forEach
            if (number.isEmpty()) return@forEach
            ops.add(
                dataInsert(rawIdx, Phone.CONTENT_ITEM_TYPE)
                    .withValue(Phone.NUMBER, number)
                    .withValue(Phone.TYPE, (p["type"] as? Number)?.toInt() ?: Phone.TYPE_OTHER)
                    .withValue(Phone.LABEL, p["label"] as? String)
                    .build(),
            )
        }

        (payload["emails"] as? List<Map<String, Any?>>)?.forEach { e ->
            val address = e["address"] as? String ?: return@forEach
            if (address.isEmpty()) return@forEach
            ops.add(
                dataInsert(rawIdx, Email.CONTENT_ITEM_TYPE)
                    .withValue(Email.ADDRESS, address)
                    .withValue(Email.TYPE, (e["type"] as? Number)?.toInt() ?: Email.TYPE_OTHER)
                    .withValue(Email.LABEL, e["label"] as? String)
                    .build(),
            )
        }

        (payload["addresses"] as? List<Map<String, Any?>>)?.forEach { a ->
            ops.add(
                dataInsert(rawIdx, StructuredPostal.CONTENT_ITEM_TYPE)
                    .withValue(StructuredPostal.STREET, a["street"] as? String)
                    .withValue(StructuredPostal.CITY, a["city"] as? String)
                    .withValue(StructuredPostal.REGION, a["state"] as? String)
                    .withValue(StructuredPostal.POSTCODE, a["postalCode"] as? String)
                    .withValue(StructuredPostal.COUNTRY, a["country"] as? String)
                    .withValue(
                        StructuredPostal.TYPE,
                        (a["type"] as? Number)?.toInt() ?: StructuredPostal.TYPE_HOME,
                    )
                    .build(),
            )
        }

        (payload["organization"] as? Map<String, Any?>)?.let { org ->
            val company = org["company"] as? String
            val title = org["title"] as? String
            val department = org["department"] as? String
            if (!company.isNullOrEmpty() || !title.isNullOrEmpty() ||
                !department.isNullOrEmpty()
            ) {
                ops.add(
                    dataInsert(rawIdx, Organization.CONTENT_ITEM_TYPE)
                        .withValue(Organization.COMPANY, company)
                        .withValue(Organization.TITLE, title)
                        .withValue(Organization.DEPARTMENT, department)
                        .withValue(Organization.TYPE, Organization.TYPE_WORK)
                        .build(),
                )
            }
        }

        (payload["events"] as? List<Map<String, Any?>>)?.forEach { ev ->
            val month = (ev["month"] as? Number)?.toInt() ?: return@forEach
            val day = (ev["day"] as? Number)?.toInt() ?: return@forEach
            val year = (ev["year"] as? Number)?.toInt()
            val date = if (year != null) {
                "%04d-%02d-%02d".format(year, month, day)
            } else {
                "--%02d-%02d".format(month, day)
            }
            ops.add(
                dataInsert(rawIdx, Event.CONTENT_ITEM_TYPE)
                    .withValue(Event.START_DATE, date)
                    .withValue(Event.TYPE, (ev["type"] as? Number)?.toInt() ?: Event.TYPE_OTHER)
                    .build(),
            )
        }

        // Social links use the deprecated-but-still-standard `Im` data kind, the
        // same representation flutter_contacts writes (PROTOCOL_CUSTOM + the label
        // as the custom protocol), so DeviceContactService reads them back the same.
        (payload["socialLinks"] as? List<Map<String, Any?>>)?.forEach { s ->
            val value = s["value"] as? String ?: return@forEach
            if (value.isEmpty()) return@forEach
            ops.add(
                dataInsert(rawIdx, Im.CONTENT_ITEM_TYPE)
                    .withValue(Im.DATA, value)
                    .withValue(Im.PROTOCOL, Im.PROTOCOL_CUSTOM)
                    .withValue(Im.CUSTOM_PROTOCOL, s["label"] as? String)
                    .build(),
            )
        }

        (payload["photo"] as? ByteArray)?.let { bytes ->
            if (bytes.isNotEmpty()) {
                ops.add(
                    dataInsert(rawIdx, Photo.CONTENT_ITEM_TYPE)
                        .withValue(Photo.PHOTO, bytes)
                        .build(),
                )
            }
        }

        return try {
            val results = resolver.applyBatch(ContactsContract.AUTHORITY, ops)
            val rawContactUri = results[0].uri ?: return null
            val rawContactId = android.content.ContentUris.parseId(rawContactUri)
            contactIdForRawContact(resolver, rawContactId)
        } catch (t: Throwable) {
            null
        }
    }

    private fun dataInsert(rawContactIndex: Int, mimeType: String) =
        ContentProviderOperation.newInsert(Data.CONTENT_URI)
            .withValueBackReference(Data.RAW_CONTACT_ID, rawContactIndex)
            .withValue(Data.MIMETYPE, mimeType)

    private fun contactIdForRawContact(resolver: ContentResolver, rawContactId: Long): String? =
        resolver.query(
            RawContacts.CONTENT_URI,
            arrayOf(RawContacts.CONTACT_ID),
            "${RawContacts._ID} = ?",
            arrayOf(rawContactId.toString()),
            null,
        )?.use { c ->
            if (c.moveToFirst() && !c.isNull(0)) c.getLong(0).toString() else null
        }
}
