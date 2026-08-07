// lib/core/config/config_service.dart
//
// Loads the About-screen config from `assets/config/app_config.json`. On any
// error it degrades to [AppConfig.fallback]. `loadAndVerify()` also checks the
// config's version/build against the real build via package_info_plus and logs a
// non-fatal debug note on mismatch. See guideline §1.5.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';
import 'package:smart_contacts_dialer/core/config/app_config.dart';

class ConfigService {
  static const String assetPath = 'assets/config/app_config.json';

  final Future<String> Function(String path) _loadAsset;

  ConfigService({Future<String> Function(String path)? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.loadString;

  Future<AppConfig> load() async {
    try {
      final text = await _loadAsset(assetPath);
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return AppConfig.fallback;
      return AppConfig.fromJson(decoded);
    } catch (_) {
      return AppConfig.fallback;
    }
  }

  Future<AppConfig> loadAndVerify({PackageInfo? packageInfo}) async {
    final config = await load();
    try {
      final info = packageInfo ?? await PackageInfo.fromPlatform();
      // The `dev` flavor appends a `-dev` versionNameSuffix (see
      // android/app/build.gradle.kts), so PackageInfo.version can be e.g.
      // `15.8.9-dev`. Compare only the base version (before the first `-`) so a
      // dev build does not trip a false drift note against the config's `15.8.9`.
      final buildVersion = info.version.split('-').first;
      final mismatch =
          buildVersion != config.version || info.buildNumber != config.build;
      if (mismatch && kDebugMode) {
        AppLogger.warning(
          'ConfigService: version/build in app_config.json '
          '(${config.version}+${config.build}) does not match the build '
          '(${info.version}+${info.buildNumber}).',
        );
      }
    } catch (_) {
      // Package info unavailable (e.g. plain unit test) — ignore.
    }
    return config;
  }
}
