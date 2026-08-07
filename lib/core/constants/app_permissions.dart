// lib/core/constants/app_permissions.dart
//
// Declarative catalogue of the Android permissions the app uses, mirroring
// `android/app/src/main/AndroidManifest.xml`. Drives the Permissions screen.
//
// The rows fall into three groups:
//   * "Explicit" — runtime-prompted; the OS shows a dialog before the feature
//     works (e.g. Contacts, Camera, the Android 12+ Bluetooth trio).
//   * "Manual" — not a prompt and not auto-granted; the user chooses it in the
//     Android settings. Currently only the Default phone app role, whose live
//     state and request flow come from `TelecomService`, not `permission_handler`.
//   * "Implicit" — normal permissions declared in the manifest and granted
//     automatically at install, no prompt (e.g. biometrics, wake lock, legacy
//     Bluetooth, INTERNET).

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// How a permission is surfaced to the user.
enum PermissionGroup { explicit, implicit }

/// One row on the Permissions screen.
class AppPermission {
  /// Short, user-facing title (e.g. "Contacts").
  final String title;

  /// One-line explanation of *why* the app needs it.
  final String reason;

  /// Icon shown beside the row.
  final IconData icon;

  /// Whether the OS prompts for this at runtime / system role (explicit) or not (implicit).
  final PermissionGroup group;

  /// The `permission_handler` permission used to query live status. Null for
  /// permissions that have no separate runtime status (most implicit ones).
  final Permission? handle;

  /// True for the one row whose live status and request action come from the
  /// default-dialer role (`TelecomService`) rather than `permission_handler`.
  final bool isDefaultDialerRole;

  const AppPermission({
    required this.title,
    required this.reason,
    required this.icon,
    required this.group,
    this.handle,
    this.isDefaultDialerRole = false,
  });
}

/// The full catalogue, in display order.
const List<AppPermission> kAppPermissions = <AppPermission>[
  // ---- Explicit (runtime-prompted / role selection) ----
  AppPermission(
    title: 'Default phone app',
    reason:
        'Become the system dialer so ContactSphere shows its own in-call '
        'screen and call screening controls.',
    icon: Icons.dialpad,
    group: PermissionGroup.explicit,
    isDefaultDialerRole: true,
  ),
  AppPermission(
    title: 'Contacts',
    reason: 'Read and sync contacts from your device address book.',
    icon: Icons.contacts_outlined,
    group: PermissionGroup.explicit,
    handle: Permission.contacts,
  ),
  AppPermission(
    title: 'Phone & Call Log',
    reason:
        'Place, answer and manage calls, and reconcile their real duration '
        'from the call log.',
    icon: Icons.call_outlined,
    group: PermissionGroup.explicit,
    handle: Permission.phone,
  ),
  AppPermission(
    title: 'Microphone',
    reason: 'Voice input / speech-to-text when adding notes.',
    icon: Icons.mic_none_outlined,
    group: PermissionGroup.explicit,
    handle: Permission.microphone,
  ),
  AppPermission(
    title: 'Location',
    reason:
        'Tag contacts with places and support BLE scanning on older Android.',
    icon: Icons.location_on_outlined,
    group: PermissionGroup.explicit,
    handle: Permission.location,
  ),
  AppPermission(
    title: 'Notifications',
    reason: 'Show reminders for birthdays, follow-ups and missed calls.',
    icon: Icons.notifications_none_outlined,
    group: PermissionGroup.explicit,
    handle: Permission.notification,
  ),
  AppPermission(
    title: 'Alarms & reminders',
    reason:
        'Lets Smart Redial call back on schedule even if the app is closed.',
    icon: Icons.alarm_outlined,
    group: PermissionGroup.explicit,
    handle: Permission.scheduleExactAlarm,
  ),
  AppPermission(
    title: 'Photos & Media',
    reason: 'Pick a profile photo for a contact from your gallery.',
    icon: Icons.photo_library_outlined,
    group: PermissionGroup.explicit,
    handle: Permission.photos,
  ),
  AppPermission(
    title: 'Camera',
    reason: 'Take a new photo for a contact or scan QR codes.',
    icon: Icons.photo_camera_outlined,
    group: PermissionGroup.explicit,
    handle: Permission.camera,
  ),
  AppPermission(
    title: 'Bluetooth Scan',
    reason:
        'Find a nearby phone sharing a contact over Bluetooth (declared '
        'with neverForLocation).',
    icon: Icons.bluetooth_searching,
    group: PermissionGroup.explicit,
    handle: Permission.bluetoothScan,
  ),
  AppPermission(
    title: 'Bluetooth Connect',
    reason: 'Connect to another phone to transfer contacts over Bluetooth.',
    icon: Icons.bluetooth_connected,
    group: PermissionGroup.explicit,
    handle: Permission.bluetoothConnect,
  ),
  AppPermission(
    title: 'Bluetooth Advertise',
    reason:
        'Make this phone discoverable while sharing contacts over Bluetooth.',
    icon: Icons.wifi_tethering,
    group: PermissionGroup.explicit,
    handle: Permission.bluetoothAdvertise,
  ),

  // ---- Implicit (declared in manifest, auto-granted at install) ----
  AppPermission(
    title: 'Biometrics',
    reason:
        'Unlock secret contacts, and confirm before exporting or syncing '
        'them, with fingerprint or face.',
    icon: Icons.fingerprint,
    group: PermissionGroup.implicit,
  ),
  AppPermission(
    title: 'Screen off near ear',
    reason:
        'Turns the screen off while holding the phone to your ear during a '
        'call so your cheek cannot tap controls.',
    icon: Icons.screen_lock_portrait_outlined,
    group: PermissionGroup.implicit,
  ),
  AppPermission(
    title: 'Foreground Call Service & Ringing',
    reason:
        'Runs active call services, full-screen incoming alerts, and '
        'vibration when calls arrive.',
    icon: Icons.ring_volume_outlined,
    group: PermissionGroup.implicit,
  ),
  AppPermission(
    title: 'Bluetooth (legacy)',
    reason: 'Bluetooth access on Android 11 and below.',
    icon: Icons.bluetooth,
    group: PermissionGroup.implicit,
  ),
  AppPermission(
    title: 'Start after restart',
    reason:
        'Puts your emergency info card back on the lock screen after the '
        'phone reboots. Used for nothing else.',
    icon: Icons.restart_alt,
    group: PermissionGroup.implicit,
  ),
  AppPermission(
    title: 'Internet & Wi-Fi',
    reason:
        'Copies your data to another phone over your local Wi-Fi during '
        'P2P sync. No cloud server is contacted.',
    icon: Icons.wifi_outlined,
    group: PermissionGroup.implicit,
  ),
];

