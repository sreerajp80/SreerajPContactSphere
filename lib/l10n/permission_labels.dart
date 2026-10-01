// lib/l10n/permission_labels.dart
//
// Display text for the Permissions screen. The catalogue in
// lib/core/constants/app_permissions.dart keeps English titles and reasons
// (it mirrors the manifest and is a `const` list); these helpers pick the
// translated text by the row's English title. Unknown rows fall back to the
// catalogue's English.

import 'package:smart_contacts_dialer/core/constants/app_permissions.dart';
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';

/// The translated (title, reason) pair for [p], or null for an unknown row.
(String, String)? _textFor(AppLocalizations l, AppPermission p) =>
    switch (p.title) {
      'Default phone app' => (l.labelPermDialer, l.descPermDialer),
      'Contacts' => (l.labelPermContacts, l.descPermContacts),
      'Phone & Call Log' => (l.labelPermPhone, l.descPermPhone),
      'Microphone' => (l.labelPermMicrophone, l.descPermMicrophone),
      'Location' => (l.labelPermLocation, l.descPermLocation),
      'Notifications' => (l.labelPermNotifications, l.descPermNotifications),
      'Alarms & reminders' => (l.labelPermAlarms, l.descPermAlarms),
      'Photos & Media' => (l.labelPermPhotos, l.descPermPhotos),
      'Camera' => (l.labelPermCamera, l.descPermCamera),
      'Bluetooth Scan' => (l.labelPermBtScan, l.descPermBtScan),
      'Bluetooth Connect' => (l.labelPermBtConnect, l.descPermBtConnect),
      'Bluetooth Advertise' => (l.labelPermBtAdvertise, l.descPermBtAdvertise),
      'Biometrics' => (l.labelPermBiometrics, l.descPermBiometrics),
      'Screen off near ear' => (l.labelPermProximity, l.descPermProximity),
      'Foreground Call Service & Ringing' => (
        l.labelPermCallService,
        l.descPermCallService,
      ),
      'Bluetooth (legacy)' => (l.labelPermBtLegacy, l.descPermBtLegacy),
      'Start after restart' => (l.labelPermBoot, l.descPermBoot),
      'Internet & Wi-Fi' => (l.labelPermInternet, l.descPermInternet),
      _ => null,
    };

/// The permission's name in the app's language.
String permissionTitle(AppLocalizations l, AppPermission p) =>
    _textFor(l, p)?.$1 ?? p.title;

/// Why the app needs the permission, in the app's language.
String permissionReason(AppLocalizations l, AppPermission p) =>
    _textFor(l, p)?.$2 ?? p.reason;
