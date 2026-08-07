// lib/widgets/screenshot_guard_mixin.dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/services/screen_security_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';

/// Blocks screenshots, screen recording and the Recents thumbnail for as long as
/// the mixing screen is alive, when the "Block screenshots" setting is on.
///
/// Mix it into a [State] and it needs no other wiring — it holds the window's
/// secure flag from `initState` to `dispose`. The reason it acquires is unique
/// per screen instance, so two stacked screens (e.g. one contact opened from
/// another) each hold their own and the flag only clears when the last of them
/// closes; the same counting also keeps this independent of the app-lock and
/// secret-contact holders (see [ScreenSecurity]).
///
/// The setting is read once, at open time: a change made while the screen is
/// already open takes effect the next time it is opened.
mixin ScreenshotGuard<T extends StatefulWidget> on State<T> {
  late final String _guardReason = 'screen_${identityHashCode(this)}';
  bool _guardHeld = false;

  @override
  void initState() {
    super.initState();
    unawaited(_applyGuard());
  }

  Future<void> _applyGuard() async {
    if (!await AppSettings.readScreenshotGuardEnabled()) return;
    if (!mounted) return; // closed while we were reading the setting
    _guardHeld = true;
    await ScreenSecurity.acquire(_guardReason);
  }

  @override
  void dispose() {
    if (_guardHeld) unawaited(ScreenSecurity.release(_guardReason));
    super.dispose();
  }
}
