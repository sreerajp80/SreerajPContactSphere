# Dependencies — ContactSphere

This document catalogs the notable packages used in ContactSphere, their architectural purpose, and the explicit list of prohibited dependencies.
Read this before adding or evaluating any package in `pubspec.yaml`.

Read [../CLAUDE.md](../CLAUDE.md), [../AGENTS.md](../AGENTS.md), and [architecture.md](architecture.md) first.

---

## 1. Integrated Runtime Dependencies

All declared runtime dependencies are fully integrated and tested in the application.

### Data & Security
- **`sqflite`** (`^2.4.2`): SQLite database interface and transaction types.
- **`sqflite_sqlcipher`** (`^3.1.0`): SQLCipher driver providing transparent 256-bit AES database encryption at rest.
- **`flutter_secure_storage`** (`^10.3.1`): Hardware-backed Android Keystore storage for the SQLCipher master encryption key.
- **`cryptography`** (`^2.9.0`): Pure-Dart cryptographic primitives (PBKDF2, AES-GCM) used for P2P Wi-Fi sync encryption and audit log tamper-proofing.
- **`local_auth`** (`^3.0.1`): Device biometric authentication (fingerprint/face/device credentials) guarding secret contacts.

### Telephony, Contacts & Platform
- **`flutter_contacts`** (`^2.1.0`): Two-way synchronization bridge between local SQLite storage and the Android system contacts provider.
- **`call_log`** (`^6.0.0`): Device call history reading used for reconciling outgoing calls and importing call history.
- **`flutter_phone_direct_caller`** (`^2.1.1`): Direct call placement fallback when ContactSphere is not set as the default phone app.
- **`flutter_blue_plus`** (`^2.3.9`): BLE central client scanning for nearby ContactSphere instances during Bluetooth contact exchange.
- **`permission_handler`** (`^12.0.1`): Granular Android runtime permission inspection and requests.
- **`speech_to_text`** (`^7.2.0`): On-device speech recognition powering voice contact search and voice dialing.

### UI, Media & Scanning
- **`qr_flutter`** (`^4.1.0`): Contact vCard QR code generation for off-network contact sharing.
- **`mobile_scanner`** (`^7.0.1`): Camera-based QR code scanner for vCard import and P2P pairing.
- **`google_mlkit_text_recognition`** (`^0.15.0`): 100% on-device OCR for scanning physical business cards into contact fields (no data leaves device).
- **`image_picker`** (`^1.0.4`): Scoped photo picker for contact avatars.
- **`file_selector`** (`^1.1.0`): Scoped file selector for custom ringtones, CSV/vCard import, and database backup files.
- **`share_plus`** (`^13.1.0`): Android system share sheet integration for vCard and emergency card exports.
- **`flutter_slidable`** (`^4.0.3`): Smooth swipe action gestures on contacts and call history items.

### Utilities, Localization & State
- **`provider`** (`^6.1.1`): App-wide reactive state management for `AppSettings` (theme, accents, fonts, SIM preferences).
- **`shared_preferences`** (`^2.2.2`): Lightweight key-value persistence for app configuration and native-bridge flags.
- **`package_info_plus`** (`^10.2.0`): Native version verification ensuring `app_config.json` stays synchronized with Gradle build versions.
- **`logger`** (`^2.4.0`): Backend for sanitized application logging via `AppLogger`.
- **`characters`** (`^1.3.0`): Unicode grapheme-cluster-aware text splitting for Malayalam script avatars and section headers.
- **`phone_numbers_parser`** (`^9.0.24`): E.164 phone number parsing, validation, and country-code formatting.
- **`csv`** (`^8.0.0`): CSV contact import and export with UTF-8 BOM encoding.
- **`intl`** (`^0.20.2`): Date, time, and locale formatting.
- **`timezone`** (`^0.11.0`): Offline IANA timezone database powering pre-call geographic time summaries.
- **`flutter_localizations`** (`sdk: flutter`): Material, Cupertino, and Widgets localization delegates ensuring proper date pickers and dialogs.

---

## 2. Dev Dependencies

- **`flutter_test`** (`sdk: flutter`): Core test framework for unit and widget tests.
- **`flutter_lints`** (`^6.0.0`): Official Flutter recommended lint rules.
- **`sqflite_common_ffi`** (`^2.3.6`): Host-side SQLite FFI driver enabling in-memory SQLite testing without an Android emulator or device.

---

## 3. Explicit Prohibited Dependencies

ContactSphere is strictly **offline-first** and prioritizes user privacy. The following categories of packages are **strictly prohibited** and must never be added:

1. **Remote analytics & telemetry**: Firebase Analytics, Mixpanel, Amplitude, Segment, PostHog, or any user-tracking SDK.
2. **Crash reporting SDKs**: Firebase Crashlytics, Sentry, Bugsnag (all crash debugging is local and off-line via log files or symbols).
3. **Advertising SDKs**: Google Mobile Ads, Unity Ads, AppLovin, Facebook Audience Network.
4. **Cloud BaaS & Remote DBs**: Firebase Firestore / Realtime DB, AWS Amplify, Supabase.
5. **General-purpose HTTP network clients**: `dio`, `http` (the app does not communicate with external web servers; P2P sync uses raw encrypted TCP sockets via `dart:io`).
