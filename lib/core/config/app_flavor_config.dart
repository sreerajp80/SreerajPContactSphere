// lib/core/config/app_flavor_config.dart
//
// Build-flavor configuration for ContactSphere. Tells the running app whether it
// is a `dev` or `prod` build. See engineering standard §5.2 (Recommended Flavor
// Model) and the folder guideline §3 (this path is fixed).
//
// The flavor value is read from two compile-time environment variables, in
// priority order, so a single config works on every platform:
//   1. APP_FLAVOR          — passed by desktop builds via
//                            `--dart-define=APP_FLAVOR=<value>` (Flutter does not
//                            accept `--flavor` on Windows/Linux/macOS).
//   2. FLUTTER_APP_FLAVOR  — auto-injected by Flutter on Android/iOS whenever
//                            `--flavor <name>` is passed. Defaults to 'prod' so an
//                            unflavored debug build still resolves deterministically.
//
// NEVER pass `--dart-define=FLUTTER_APP_FLAVOR=...` — that name is reserved by the
// framework (Flutter >= 3.19) and fails the build at kernel_snapshot_program.
// This app is Android-only today, but the two-variable pattern is a guideline
// MUST and keeps the config valid if a desktop target is added later.

enum AppFlavor { dev, prod }

class AppFlavorConfig {
  AppFlavorConfig._(this.flavor);

  // Explicit value passed by desktop builds via --dart-define=APP_FLAVOR=<value>.
  // Empty when not provided.
  static const _appFlavorValue = String.fromEnvironment('APP_FLAVOR');

  // Auto-injected by Flutter on Android/iOS when --flavor is passed.
  // Falls back to 'prod' so an unflavored debug build still has a deterministic value.
  static const _frameworkFlavorValue = String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: 'prod',
  );

  static String _resolved() =>
      _appFlavorValue.isNotEmpty ? _appFlavorValue : _frameworkFlavorValue;

  static final AppFlavorConfig instance = AppFlavorConfig._(
    _parse(_resolved()),
  );

  final AppFlavor flavor;

  static AppFlavor _parse(String value) {
    switch (value.trim().toLowerCase()) {
      case 'dev':
        return AppFlavor.dev;
      case 'prod':
      default:
        return AppFlavor.prod;
    }
  }

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;

  // Matches the resValue("string", "app_name", ...) values in
  // android/app/build.gradle.kts so the Dart and native names stay aligned.
  String get appName => isDev ? 'ContactSphere Dev' : 'ContactSphere';
  bool get showEnvironmentBanner => isDev;
  bool get enableVerboseLogging => isDev;
}
