# Dependencies (intended features)

Heavy packages declared in `pubspec.yaml`. Most are declared but **not yet integrated**.

- **Telephony / dialer** — `flutter_phone_direct_caller`, `call_log`, `flutter_ringtone_player`
- **Device contacts sync** — `flutter_contacts`
- **QR** — `qr_flutter` (render/share a contact QR), `mobile_scanner` (camera scan → import)
- **Business card OCR** — `google_mlkit_text_recognition` (on-device Latin text recognition
  behind the business card scanner; the photo and the recognized text never leave the phone.
  The bundled ML Kit model is what makes the release APK noticeably larger)
- **BLE** — `flutter_blue_plus` (receiver side of BLE contact exchange: scan + GATT reads;
  the sender/peripheral side is native Kotlin — `BleShareServer.kt`)
- **Biometrics** — `local_auth` (intended to gate `is_secret` contacts)
- **Location** — `geolocator`
- **Timezone lookup** — `timezone` (offline city/country → IANA-zone map used by the
  pre-call summary; no notification-scheduling library is wired in — see
  `docs/known-gaps.md`)
- **Speech** — `speech_to_text` (wired: voice search in the contacts list,
  voice dialing in the dialer — see `services/speech_service.dart`)
- **Media / sharing** — `image_picker`, `share_plus`, `csv`
- **Storage / state** — `sqflite`, `path`, `path_provider`, `shared_preferences`, `provider`
- **Permissions** — `permission_handler`
- **i18n** — `intl`
