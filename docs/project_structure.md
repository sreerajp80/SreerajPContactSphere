# Project Structure — ContactSphere

This document provides a comprehensive overview of the file tree and directory responsibilities for the ContactSphere project.
Read this to understand where components live and how code is organized.

Read [architecture.md](architecture.md), [GUIDELINES_MANIFEST.md](GUIDELINES_MANIFEST.md), and [../CLAUDE.md](../CLAUDE.md) first.

---

## 1. Top-Level Directory Layout

```text
SreerajPContactSphere/
|-- .agents/               # Agent customization configurations (rules, skills)
|-- .git/                  # Git version control metadata
|-- android/               # Android native project (flavors, native services, Kotlin)
|-- assets/                # Bundled assets (fonts, app config, icons)
|-- change_log/            # Mandatory change logs (yyyymmdd_hhMMss_<slug>.md)
|-- docs/                  # Project living documentation and guidelines submodule
|   `-- guidelines/        # Git submodule pointing to shared Flutter guidelines
|-- lib/                   # Flutter application Dart source code
|-- plans/                 # Mandatory change plans (yyyymmdd_hhMMss_<slug>.md)
|-- test/                  # Unit and widget test suite (mirrors lib/)
|-- tool/                  # Build-time code generation scripts
|-- .gitignore             # Git ignore patterns (keystores, passwords, build outputs)
|-- .gitmodules            # Submodule configuration for docs/guidelines
|-- AGENTS.md              # Root instructions for non-Claude AI agents & LLMs
|-- CLAUDE.md              # Root instructions for Claude Code
|-- analysis_options.yaml  # Linting and static analysis rules
|-- dart_test.yaml         # Test runner settings (concurrency, tags)
|-- pubspec.yaml           # Flutter dependencies, fonts, assets, and app version
`-- README.md              # Project summary and quick start
```

---

## 2. Dart Source Layout (`lib/`)

The application follows a layered architecture with explicit dependency flow:
**screens → repositories / services → database → models**.

```text
lib/
|-- main.dart              # Application entry point, AppSettings provider, lifecycle
|-- core/                  # Shared foundations and cross-cutting concerns
|   |-- config/            # AppConfig model, ConfigService, AppFlavorConfig
|   |-- constants/         # App constants, generated version & build date
|   |-- errors/            # Custom exception types and error boundaries
|   |-- logging/           # AppLogger wrapper over logger package
|   `-- utils/             # Core utilities and formatting helpers
|-- database/              # SQLite database management
|   `-- database_helper.dart # Singleton owning SQLCipher schema, tables, migrations
|-- models/                # Plain data classes (Contact, Phone, Email, Address, etc.)
|-- repositories/          # Data access layer interfacing with SQLite
|   |-- contact_repository.dart       # Aggregate contact operations and transactions
|   |-- relationship_repository.dart  # Symmetric relationship links
|   |-- interaction_repository.dart   # Call logs, sentiment, and notes
|   `-- reminder_repository.dart      # Follow-up reminders
|-- services/              # Business logic, native method channel bridges, platform APIs
|   |-- audio/             # Ringtone playback, audio routing, in-call audio
|   |-- ble/               # Bluetooth LE contact sharing & receive protocol
|   |-- p2p/               # Device-to-device Wi-Fi sync, AES-GCM transport, bundles
|   |-- telecom/           # Android Telecom bridge (calls, SIM accounts, screening)
|   |-- auth_service.dart             # Biometric and PIN authentication
|   |-- backup_service.dart           # Encrypted database backup and restore
|   |-- call_service.dart             # Outgoing call placement and reconciliation
|   |-- contact_sync_service.dart     # Two-way sync with Android system contacts
|   `-- speech_service.dart           # Voice search and voice dialing recognizer
|-- state/                 # Application-wide state management
|   `-- app_settings.dart  # ChangeNotifier for theme, fonts, SIM, and user preferences
|-- screens/               # Full-page screens and navigation destinations
|   |-- about_screen.dart             # About screen driven by assets/config/app_config.json
|   |-- add_edit_contact_screen.dart  # Contact create and edit form
|   |-- call_history_screen.dart      # Recents / call log view
|   |-- contact_detail_screen.dart    # Contact profile, pre-call summary, quick actions
|   |-- contact_list_screen.dart      # Main contacts list, search, filters
|   |-- dialer_screen.dart            # T9 dialpad with multi-script search
|   |-- home_shell.dart               # Bottom navigation hub (Contacts, Dialer, Recents)
|   |-- in_call_screen.dart           # Active call in-call UI (answer, mute, hold, end)
|   |-- permissions_screen.dart       # Permissions overview and request flows
|   |-- relationship_screen.dart      # Interactive ego-centric relationship sphere
|   |-- settings_screen.dart          # App preferences and settings cards
|   `-- sync/                         # P2P LAN sync send and receive views
|-- theme/                 # Design tokens, color schemes, and ThemeData definitions
|-- utils/                 # Search ranking, phonetic algorithms, T9 transliteration
`-- widgets/               # Reusable UI widgets and dialogs
```

---

## 3. Platform Directory (`android/`)

Android is the sole supported native platform.

```text
android/
|-- app/
|   |-- src/
|   |   |-- main/
|   |   |   |-- kotlin/in/sreerajp/contact_sphere/
|   |   |   |   |-- MainActivity.kt                     # FlutterActivity & method channels
|   |   |   |   |-- ContactSphereInCallService.kt       # Telecom InCallService implementation
|   |   |   |   |-- ContactSphereCallScreeningService.kt # Pre-ring call screening
|   |   |   |   |-- EmergencyInfoActivity.kt            # Lock-screen medical/emergency card
|   |   |   |   |-- BleShareServer.kt                   # GATT server for BLE contact sharing
|   |   |   |   |-- IncomingCallRinger.kt               # Native ringtone and vibration engine
|   |   |   |   `-- SmartRedialManager.kt               # Auto-redial alarm scheduler
|   |   |   |-- res/                                    # Drawables, layouts, mipmap icons
|   |   |   |   `-- xml/network_security_config.xml     # Cleartext traffic prohibition
|   |   |   `-- AndroidManifest.xml                     # Components, permissions, filters
|   |   `-- test/                                       # Native JVM JUnit unit tests
|   |-- build.gradle.kts                                # App-level Gradle build, flavors, R8
|   `-- proguard-rules.pro                              # ProGuard / R8 keep rules
|-- build.gradle.kts                                    # Project-level Gradle build
`-- key.properties.example                              # Template for release signing keys
```

---

## 4. Test Suite (`test/`)

The test suite mirrors `lib/` and covers data access, business services, parsers, and utilities:

- SQLite integration tests use `sqflite_common_ffi` to test real queries and migrations in memory.
- Pure logic tests verify T9 transliteration, phonetic duplicate detection, search ranking, and crypto.
- Native JVM unit tests in `android/app/src/test/` verify pure Kotlin logic (`RingerPolicy`, number match keys, quiet hours).

---

## 5. Assets & Config (`assets/`)

- `assets/config/app_config.json`: Single source of truth for the About screen (app name, description, version, build, author, AI, IDE).
- `assets/fonts/`: Bundled SIL OFL fonts covering Latin and Malayalam scripts (`Manjari`, `Anek Malayalam`, `Noto Sans Malayalam`).
