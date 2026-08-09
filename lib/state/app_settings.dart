// lib/state/app_settings.dart
//
// App-wide, persisted UI preferences: theme mode (Light / Dark / System) and
// the accent color. Backed by shared_preferences. This is the one place the
// previously-unused `provider` dependency is wired in.

import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/emergency_info_repository.dart';
import 'package:smart_contacts_dialer/repositories/flagged_number_repository.dart';
import 'package:smart_contacts_dialer/services/quiet_hours_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// A picked ringtone: the file path/URI plus a human label for display. Used for
/// the per-SIM ringtone map in [AppSettings].
class RingtoneRef {
  final String path;
  final String label;

  const RingtoneRef({required this.path, required this.label});

  Map<String, dynamic> toJson() => {'path': path, 'label': label};

  factory RingtoneRef.fromJson(Map<String, dynamic> json) => RingtoneRef(
    path: json['path'] as String? ?? '',
    label: json['label'] as String? ?? '',
  );
}

/// What the dialer's pre-dial "Top contacts" section is populated from.
enum DialerTopSource {
  /// Highest relationship score first, then filled with the most-recently
  /// contacted people (so the section isn't empty once any call has been made).
  recent,

  /// Contacts the user has explicitly linked as relations (family, friends, …).
  relations,

  /// Contacts whose measured answer rate is highest in the current part of the
  /// day. Ordering only — the section behaves like the other two, and nothing
  /// is dialed until the user taps a row.
  likelyToAnswer,
}

/// Secondary script layout displayed alongside English letters on dialpad keys 2–9.
enum DialpadScript {
  /// Auto-detect based on device locale.
  auto,

  /// Malayalam script (ക-ങ, ച-ഞ, ...)
  malayalam,

  /// Devanagari script (Sanskrit, Hindi, Marathi: क-ङ, च-ञ, ...)
  devanagari,

  /// Cyrillic script (Russian, Ukrainian: АБВГ, ДЕЖЗ, ...)
  cyrillic,

  /// Arabic script (ا ب ت ث, ج ح خ, ...)
  arabic,

  /// Greek script (ΑΒΓ, ΔΕΖ, ...)
  greek,

  /// English only (A-Z, no secondary script legend)
  none,
}

/// Display name for each [DialpadScript].
extension DialpadScriptInfo on DialpadScript {
  String get label {
    switch (this) {
      case DialpadScript.auto:
        return 'Auto (Device locale)';
      case DialpadScript.malayalam:
        return 'Malayalam (മലയാളം)';
      case DialpadScript.devanagari:
        return 'Devanagari (Sanskrit / Hindi)';
      case DialpadScript.cyrillic:
        return 'Cyrillic (Russian / Ukrainian)';
      case DialpadScript.arabic:
        return 'Arabic (العربية)';
      case DialpadScript.greek:
        return 'Greek (Ελληνικά)';
      case DialpadScript.none:
        return 'English only';
    }
  }
}

/// How the contacts list is sorted (see [AppSettings.contactSortOrder]).
enum ContactSortOrder {
  /// Sort by first name, then last name (the app's original behavior).
  firstName,

  /// Sort by last name, then first name.
  lastName,
}

/// How opening the app is protected (Settings → App lock). See
/// [AppSettings.lockMode].
enum LockMode {
  /// No app lock; the app opens straight to content.
  none,

  /// Unlock with the device credential (fingerprint / face / device PIN) via
  /// `local_auth`. Requires a device screen lock to exist.
  deviceLock,

  /// Unlock with an app-only numeric PIN kept by this app (works with no device
  /// screen lock). See `AppPinService`.
  appPin,
}

/// The app-wide UI font the user can pick (Settings → Appearance → Font).
/// Every choice renders both Latin (English) and Malayalam. [system] keeps the
/// platform default (Roboto + the system Malayalam fallback).
enum AppFont {
  /// The platform default font (Roboto). No bundled family; [family] is null.
  system,

  /// Manjari — elegant, highly readable Malayalam with a clean Latin.
  manjari,

  /// Anek Malayalam — modern, neutral sans covering both scripts.
  anekMalayalam,

  /// Noto Sans Malayalam — Google's plain, maximally legible workhorse.
  notoSansMalayalam,
}

/// Display name and the bundled font-family string for each [AppFont]. The
/// [family] must exactly match a `family:` declared in pubspec.yaml (null for
/// [AppFont.system], which uses the platform default).
extension AppFontInfo on AppFont {
  String get label {
    switch (this) {
      case AppFont.system:
        return 'System default';
      case AppFont.manjari:
        return 'Manjari';
      case AppFont.anekMalayalam:
        return 'Anek Malayalam';
      case AppFont.notoSansMalayalam:
        return 'Noto Sans Malayalam';
    }
  }

  /// The pubspec font-family name, or null to use the platform default.
  String? get family {
    switch (this) {
      case AppFont.system:
        return null;
      case AppFont.manjari:
        return 'Manjari';
      case AppFont.anekMalayalam:
        return 'Anek Malayalam';
      case AppFont.notoSansMalayalam:
        return 'Noto Sans Malayalam';
    }
  }
}

/// App-wide text size the user can pick (Settings → Appearance → Text size).
/// Each choice is a multiplier applied on top of the theme's base font sizes.
/// [normal] (1.0×) is the default and leaves text unchanged.
enum AppTextScale {
  /// 0.85× — a little smaller than default.
  small,

  /// 1.0× — the app's default size.
  normal,

  /// 1.15× — a little larger than default.
  large,

  /// 1.30× — noticeably larger, for easier reading.
  larger,
}

/// Display name and the scale multiplier for each [AppTextScale].
extension AppTextScaleInfo on AppTextScale {
  String get label {
    switch (this) {
      case AppTextScale.small:
        return 'Small';
      case AppTextScale.normal:
        return 'Default';
      case AppTextScale.large:
        return 'Large';
      case AppTextScale.larger:
        return 'Larger';
    }
  }

  /// The multiplier applied to every text size in the app.
  double get scale {
    switch (this) {
      case AppTextScale.small:
        return 0.85;
      case AppTextScale.normal:
        return 1.0;
      case AppTextScale.large:
        return 1.15;
      case AppTextScale.larger:
        return 1.30;
    }
  }
}

/// How a contact's name is displayed in the list (see
/// [AppSettings.nameDisplayFormat]).
enum NameDisplayFormat {
  /// "First Last" — the app's original [Contact.fullName] arrangement.
  firstFirst,

  /// "Last, First" — surname first.
  lastFirst,
}

class AppSettings extends ChangeNotifier {
  static const String _kThemeMode = 'theme_mode';

  /// Legacy single-accent key (applied to both themes). Migrated to the per-mode
  /// keys below on first load, then removed.
  static const String _kAccentColorLegacy = 'accent_color';
  static const String _kAccentColorLight = 'accent_color_light';
  static const String _kAccentColorDark = 'accent_color_dark';

  /// The app-wide UI font (see [AppFont]). Stored as the enum index; absent
  /// means [AppFont.system] (the platform default).
  static const String _kAppFont = 'app_font';

  /// The app-wide text size (see [AppTextScale]). Stored as the enum index;
  /// absent means [AppTextScale.normal] (1.0×, unchanged).
  static const String _kTextScale = 'app_text_scale';

  /// Whether to show the "How did it go?" sheet after a call ends. Opt-in:
  /// defaults to off so it never surprises the user until they enable it.
  static const String _kPostCallFeedback = 'post_call_feedback_enabled';

  /// Multi-SIM: the default SIM's phone-account id (null = system default), and
  /// whether to prompt for a SIM before each call.
  static const String _kDefaultSimId = 'default_sim_id';
  static const String _kAskSimBeforeCall = 'ask_sim_before_call';

  /// Source for the dialer's "Top contacts" section (see [DialerTopSource]).
  static const String _kDialerTopSource = 'dialer_top_source';

  /// Secondary script layout for dialpad keys (see [DialpadScript]).
  static const String _kDialpadScript = 'dialpad_script';

  /// Incoming-call ringer preferences. Volume is a 0–100 percentage applied to
  /// the tone; vibrate toggles vibration. Both are mirrored to the native ringer
  /// (see [_mirrorRingerPrefs]). Per-SIM ringtones map a SIM's phone-account id
  /// to a picked [RingtoneRef], stored as a JSON object.
  static const String _kRingtoneVolume = 'ringtone_volume_percent';
  static const String _kVibrateOnCall = 'vibrate_on_incoming_call';
  static const String _kPerSimRingtones = 'per_sim_ringtones';
  static const String _kSpokenCallerAnnouncement =
      'spoken_caller_announcement_enabled';
  static const String _kSpokenCallerQuietHours =
      'spoken_caller_quiet_hours_enabled';
  static const String _kSpokenCallerQuietHoursStart =
      'spoken_caller_quiet_hours_start';
  static const String _kSpokenCallerQuietHoursEnd =
      'spoken_caller_quiet_hours_end';

  static const String _kRelationshipQuietHoursEnabled =
      'rel_quiet_hours_enabled';
  static const String _kRelationshipQuietHoursStart =
      'rel_quiet_hours_start';
  static const String _kRelationshipQuietHoursEnd =
      'rel_quiet_hours_end';
  static const String _kRelationshipQuietHoursAllowedTiers =
      'rel_quiet_hours_allowed_tiers';
  static const String _kRelationshipQuietHoursAllowedTags =
      'rel_quiet_hours_allowed_tags';
  static const String _kRelationshipQuietHoursAllowedContactIds =
      'rel_quiet_hours_allowed_contact_ids';

  /// Per-SIM display colors (in-call SIM chip), mapping a SIM's phone-account
  /// id to an ARGB int, stored as a JSON object. Absent = slot default
  /// ([AppTheme.defaultSimColor]).
  static const String _kPerSimColors = 'per_sim_colors';

  /// Default country (ISO 3166-1 alpha-2, e.g. "IN") used to normalize phone
  /// numbers to E.164 when matching an incoming/dialed number to a contact.
  static const String _kDefaultCountry = 'default_country';

  /// How far the device call log has been synced into Recents, in epoch millis
  /// (the newest device call seen). Lets the sync ask the phone only for what
  /// is new instead of re-reading years of history on every check.
  static const String _kCallLogSyncedThrough = 'call_log_synced_through_millis';

  /// Whether the one-shot repair that collapses duplicate Recents rows has run.
  /// The duplicates were written before the live logger deduped; new calls can't
  /// create them, so this only ever needs to run once per install.
  static const String _kCallLogDuplicatesMerged = 'call_log_duplicates_merged';

  /// Whether the regular Export CSV / Export vCard actions include secret
  /// contacts. Off by default so secrets never leave the phone unless the user
  /// opts in (a separate secret-only export exists in Settings → Contacts).
  static const String _kIncludeSecretInExport = 'include_secret_in_export';

  /// Call screening / identification. Blocking callers with no (hidden) number
  /// is off by default; caller identification (labels for non-contacts, e.g.
  /// telemarketing series, verification hints) is on by default; the spam
  /// filter (flagged callers ring silently) is opt-in. All three are mirrored
  /// natively so the screening service can read them before the phone rings.
  static const String _kBlockUnknownCallers = 'block_unknown_callers';
  static const String _kCallerIdEnabled = 'caller_id_enabled';
  static const String _kSpamFilterEnabled = 'spam_filter_enabled';

  /// Quick replies: canned messages offered when rejecting an incoming call
  /// with a text (Settings → SIM & calling → Quick replies). Stored as a
  /// string list; when the key is absent the defaults below apply.
  static const String _kQuickReplies = 'quick_replies';

  /// Contacts-list display options: sort order, how the name is arranged, and
  /// whether contacts with no phone number are hidden from the list.
  static const String _kContactSortOrder = 'contact_sort_order';
  static const String _kNameDisplayFormat = 'name_display_format';
  static const String _kHideContactsWithoutPhone =
      'hide_contacts_without_phone';

  /// The relationship-type names offered when linking two contacts (Settings →
  /// Contacts → Relationship Names). Stored as a string list; when the key is
  /// absent the built-in [RelationshipTypes.presets] are used (and are also what
  /// "Reset to defaults" restores).
  static const String _kRelationshipNames = 'relationship_names';

  /// How opening the app is protected (see [LockMode]). Stored as the enum index.
  /// Off by default. Read early via [readLockMode] by the launch lock gate.
  static const String _kLockMode = 'app_lock_mode';

  /// Legacy boolean toggle (device lock on/off) from before [LockMode] existed.
  /// Read once on [load] to migrate old installs, then superseded by [_kLockMode].
  static const String _kAppLockEnabledLegacy = 'app_lock_enabled';

  /// Whether contact detail and the in-call screen block screenshots.
  static const String _kScreenshotGuard = 'screenshot_guard_enabled';

  /// Smart redial & Reach Me mode settings.
  static const String _kSmartRedialEnabled = 'smart_redial_enabled';
  static const String _kSmartRedialDelayMinutes = 'smart_redial_delay_minutes';
  static const String _kPresetReachMeMessage = 'preset_reach_me_message';

  /// The default "trying to reach you" preset message.
  static const String defaultReachMeMessage =
      'Hi, I tried reaching you just now. Please call or text back when you see this!';

  /// The out-of-the-box quick replies, used until the user edits the list.
  static const List<String> defaultQuickReplies = [
    "Can't talk now. Call you later.",
    "Can't talk now. What's up?",
    "I'm in a meeting.",
    'On my way.',
  ];

  /// Region used when no default country has been chosen yet. Auto-detected
  /// from the device locale, falling back to "US" when the locale has no
  /// region. Shared by the instance loader and [readDefaultCountryIso].
  static String _autoDetectedCountryIso() {
    final region = PlatformDispatcher.instance.locale.countryCode;
    return (region == null || region.trim().isEmpty)
        ? 'US'
        : region.trim().toUpperCase();
  }

  ThemeMode _themeMode = ThemeMode.system;

  bool _postCallFeedbackEnabled = false;

  String? _defaultSimId;
  bool _askSimBeforeCall = false;

  DialerTopSource _dialerTopSource = DialerTopSource.recent;
  DialpadScript _dialpadScript = DialpadScript.auto;

  int _ringtoneVolumePercent = 100;
  bool _vibrateOnIncomingCall = true;
  Map<String, RingtoneRef> _perSimRingtones = const {};
  Map<String, Color> _perSimColors = const {};

  bool _spokenCallerAnnouncementEnabled = false;
  bool _spokenCallerQuietHoursEnabled = true;
  String _spokenCallerQuietHoursStart = '22:00';
  String _spokenCallerQuietHoursEnd = '07:00';

  bool _relationshipQuietHoursEnabled = false;
  String _relationshipQuietHoursStart = '22:00';
  String _relationshipQuietHoursEnd = '07:00';
  List<String> _relationshipQuietHoursAllowedTiers = const [
    QuietHoursTiers.emergency,
    QuietHoursTiers.immediateFamily,
  ];
  List<String> _relationshipQuietHoursAllowedTags = const [];
  List<int> _relationshipQuietHoursAllowedContactIds = const [];

  String _defaultCountryIso = _autoDetectedCountryIso();

  bool _includeSecretInExport = false;

  bool _blockUnknownCallers = false;
  bool _callerIdEnabled = true;
  bool _spamFilterEnabled = false;

  List<String> _quickReplies = defaultQuickReplies;

  List<String> _relationshipNames = RelationshipTypes.presets;

  ContactSortOrder _contactSortOrder = ContactSortOrder.firstName;
  NameDisplayFormat _nameDisplayFormat = NameDisplayFormat.firstFirst;
  bool _hideContactsWithoutPhone = false;

  LockMode _lockMode = LockMode.none;

  bool _smartRedialEnabled = true;
  bool _screenshotGuardEnabled = true;
  int _smartRedialDelayMinutes = 5;
  String _presetReachMeMessage = defaultReachMeMessage;

  /// Per-mode accent overrides. Null means "use that theme's default" (teal for
  /// Calm, indigo for Midnight) so each theme keeps its signature look until the
  /// user deliberately overrides it for that mode.
  Color? _lightAccent;
  Color? _darkAccent;

  /// The app-wide UI font. Defaults to [AppFont.system] (platform default).
  AppFont _appFont = AppFont.system;

  /// The app-wide text size. Defaults to [AppTextScale.normal] (1.0×).
  AppTextScale _appTextScale = AppTextScale.normal;

  ThemeMode get themeMode => _themeMode;

  /// The app-wide UI font the user picked.
  AppFont get appFont => _appFont;

  /// The bundled font-family string to seed the themes with, or null to use the
  /// platform default (Roboto). See [AppFont.family].
  String? get fontFamily => _appFont.family;

  /// The app-wide text size the user picked.
  AppTextScale get appTextScale => _appTextScale;

  /// The multiplier to apply to every text size in the app (1.0 = unchanged).
  /// See [AppTextScale.scale].
  double get textScaleFactor => _appTextScale.scale;

  /// Whether the post-call "How did it go?" feedback sheet should be offered
  /// when a call ends.
  bool get postCallFeedbackEnabled => _postCallFeedbackEnabled;

  /// Phone-account id of the SIM to place calls on by default. Null means "let
  /// the system decide" (system default SIM).
  String? get defaultSimId => _defaultSimId;

  /// Whether to prompt for a SIM before each call (only meaningful with 2+ SIMs).
  bool get askSimBeforeCall => _askSimBeforeCall;

  /// What the dialer's "Top contacts" section is populated from.
  DialerTopSource get dialerTopSource => _dialerTopSource;

  /// Secondary script layout for dialpad keys.
  DialpadScript get dialpadScript => _dialpadScript;

  /// Incoming-call ringtone volume as a 0–100 percentage.
  int get ringtoneVolumePercent => _ringtoneVolumePercent;

  /// Whether the phone vibrates on an incoming call (subject to the device
  /// ringer mode — silent mode still suppresses vibration).
  bool get vibrateOnIncomingCall => _vibrateOnIncomingCall;

  /// Whether incoming callers' names are announced aloud ("Amma calling").
  bool get spokenCallerAnnouncementEnabled => _spokenCallerAnnouncementEnabled;

  /// Whether spoken caller announcements are suppressed during quiet hours.
  bool get spokenCallerQuietHoursEnabled => _spokenCallerQuietHoursEnabled;

  /// Start time for spoken caller announcement quiet hours (HH:mm).
  String get spokenCallerQuietHoursStart => _spokenCallerQuietHoursStart;

  /// End time for spoken caller announcement quiet hours (HH:mm).
  String get spokenCallerQuietHoursEnd => _spokenCallerQuietHoursEnd;

  /// Whether relationship-tier quiet hours call silencing is enabled.
  bool get relationshipQuietHoursEnabled => _relationshipQuietHoursEnabled;

  /// Start time for relationship-tier quiet hours (HH:mm).
  String get relationshipQuietHoursStart => _relationshipQuietHoursStart;

  /// End time for relationship-tier quiet hours (HH:mm).
  String get relationshipQuietHoursEnd => _relationshipQuietHoursEnd;

  /// Allowed relationship tiers during quiet hours (e.g. emergency, immediate_family).
  List<String> get relationshipQuietHoursAllowedTiers =>
      List.unmodifiable(_relationshipQuietHoursAllowedTiers);

  /// Allowed tag names during quiet hours.
  List<String> get relationshipQuietHoursAllowedTags =>
      List.unmodifiable(_relationshipQuietHoursAllowedTags);

  /// Allowed contact IDs during quiet hours.
  List<int> get relationshipQuietHoursAllowedContactIds =>
      List.unmodifiable(_relationshipQuietHoursAllowedContactIds);

  /// Per-SIM ringtones, keyed by phone-account id. Empty when none are set.
  Map<String, RingtoneRef> get perSimRingtones =>
      Map.unmodifiable(_perSimRingtones);

  /// The ringtone configured for the SIM with [phoneAccountId], or null.
  RingtoneRef? ringtoneForSim(String? phoneAccountId) =>
      (phoneAccountId == null || phoneAccountId.isEmpty)
      ? null
      : _perSimRingtones[phoneAccountId];

  /// Per-SIM display colors, keyed by phone-account id. Empty when none are set.
  Map<String, Color> get perSimColors => Map.unmodifiable(_perSimColors);

  /// The user-picked color for the SIM with [phoneAccountId], or null when it
  /// should fall back to the slot default ([AppTheme.defaultSimColor]).
  Color? colorForSim(String? phoneAccountId) =>
      (phoneAccountId == null || phoneAccountId.isEmpty)
      ? null
      : _perSimColors[phoneAccountId];

  /// Default country (ISO 3166-1 alpha-2) used to normalize phone numbers when
  /// matching an incoming/dialed number to a saved contact.
  String get defaultCountryIso => _defaultCountryIso;

  /// Whether the regular exports (CSV / vCard) include secret contacts.
  bool get includeSecretInExport => _includeSecretInExport;

  /// Whether calls with no / hidden number are rejected before ringing.
  bool get blockUnknownCallers => _blockUnknownCallers;

  /// Whether the ringing/in-call UI labels non-contact callers with what can
  /// be determined locally (telemarketing series, spam marks, verification).
  bool get callerIdEnabled => _callerIdEnabled;

  /// Whether suspected-spam calls ring silently instead of loudly.
  bool get spamFilterEnabled => _spamFilterEnabled;

  /// The canned messages offered when rejecting an incoming call with a text.
  List<String> get quickReplies => List.unmodifiable(_quickReplies);

  /// The relationship-type names offered in the relationship picker. Never
  /// empty — falls back to the built-in [RelationshipTypes.presets].
  List<String> get relationshipNames => List.unmodifiable(_relationshipNames);

  /// How the contacts list is sorted.
  ContactSortOrder get contactSortOrder => _contactSortOrder;

  /// How a contact's name is arranged for display.
  NameDisplayFormat get nameDisplayFormat => _nameDisplayFormat;

  /// Whether contacts with no phone number are hidden from the list.
  bool get hideContactsWithoutPhone => _hideContactsWithoutPhone;

  /// How opening the app is protected (none / device lock / app PIN).
  LockMode get lockMode => _lockMode;

  /// Whether any app lock is active. Convenience over [lockMode].
  bool get appLockEnabled => _lockMode != LockMode.none;

  /// Whether Smart Redial / Reach Me prompt is offered after an unanswered call.
  bool get smartRedialEnabled => _smartRedialEnabled;

  /// When true (the default), the contact detail and in-call screens set the
  /// window's secure flag: no screenshot, no screen recording, and a blank
  /// Recents thumbnail. The app-lock and secret-contact screens set that flag
  /// regardless of this setting — the user asked for that data to be hidden.
  bool get screenshotGuardEnabled => _screenshotGuardEnabled;

  /// Default delay in minutes for Smart Redial auto-retry.
  int get smartRedialDelayMinutes => _smartRedialDelayMinutes;

  /// Pre-set "trying to reach you" message text.
  String get presetReachMeMessage => _presetReachMeMessage;

  /// Accent to seed the light (Calm) theme with.
  Color get lightAccent => _lightAccent ?? AppTheme.calmAccent;

  /// Accent to seed the dark (Midnight) theme with.
  Color get darkAccent => _darkAccent ?? AppTheme.midnightAccent;

  /// The effective accent for a given [brightness] (override or default).
  Color accentFor(Brightness brightness) =>
      brightness == Brightness.dark ? darkAccent : lightAccent;

  /// The user's accent override for [brightness], or null if it's still the
  /// per-theme default.
  Color? overrideFor(Brightness brightness) =>
      brightness == Brightness.dark ? _darkAccent : _lightAccent;

  /// Loads persisted values. Safe to call before `runApp`; never throws.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt(_kThemeMode);
      if (modeIndex != null &&
          modeIndex >= 0 &&
          modeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[modeIndex];
      }

      _postCallFeedbackEnabled = prefs.getBool(_kPostCallFeedback) ?? false;

      _defaultSimId = prefs.getString(_kDefaultSimId);
      _askSimBeforeCall = prefs.getBool(_kAskSimBeforeCall) ?? false;

      final sourceIndex = prefs.getInt(_kDialerTopSource);
      if (sourceIndex != null &&
          sourceIndex >= 0 &&
          sourceIndex < DialerTopSource.values.length) {
        _dialerTopSource = DialerTopSource.values[sourceIndex];
      }

      final scriptIndex = prefs.getInt(_kDialpadScript);
      if (scriptIndex != null &&
          scriptIndex >= 0 &&
          scriptIndex < DialpadScript.values.length) {
        _dialpadScript = DialpadScript.values[scriptIndex];
      }

      final country = prefs.getString(_kDefaultCountry);
      if (country != null && country.trim().isNotEmpty) {
        _defaultCountryIso = country.trim().toUpperCase();
      }

      _includeSecretInExport = prefs.getBool(_kIncludeSecretInExport) ?? false;

      _blockUnknownCallers = prefs.getBool(_kBlockUnknownCallers) ?? false;
      _callerIdEnabled = prefs.getBool(_kCallerIdEnabled) ?? true;
      _spamFilterEnabled = prefs.getBool(_kSpamFilterEnabled) ?? false;

      _quickReplies =
          prefs.getStringList(_kQuickReplies) ?? defaultQuickReplies;

      final sortIndex = prefs.getInt(_kContactSortOrder);
      if (sortIndex != null &&
          sortIndex >= 0 &&
          sortIndex < ContactSortOrder.values.length) {
        _contactSortOrder = ContactSortOrder.values[sortIndex];
      }
      final formatIndex = prefs.getInt(_kNameDisplayFormat);
      if (formatIndex != null &&
          formatIndex >= 0 &&
          formatIndex < NameDisplayFormat.values.length) {
        _nameDisplayFormat = NameDisplayFormat.values[formatIndex];
      }
      _hideContactsWithoutPhone =
          prefs.getBool(_kHideContactsWithoutPhone) ?? false;

      final relationshipNames = prefs.getStringList(_kRelationshipNames);
      if (relationshipNames != null && relationshipNames.isNotEmpty) {
        _relationshipNames = relationshipNames;
      }

      final lockIndex = prefs.getInt(_kLockMode);
      if (lockIndex != null &&
          lockIndex >= 0 &&
          lockIndex < LockMode.values.length) {
        _lockMode = LockMode.values[lockIndex];
      } else if (prefs.getBool(_kAppLockEnabledLegacy) ?? false) {
        // Migrate an old install: the legacy on/off toggle meant device lock.
        _lockMode = LockMode.deviceLock;
        await prefs.setInt(_kLockMode, _lockMode.index);
      }

      final volume = prefs.getInt(_kRingtoneVolume);
      if (volume != null) _ringtoneVolumePercent = volume.clamp(0, 100);
      _vibrateOnIncomingCall = prefs.getBool(_kVibrateOnCall) ?? true;
      _spokenCallerAnnouncementEnabled =
          prefs.getBool(_kSpokenCallerAnnouncement) ?? false;
      _spokenCallerQuietHoursEnabled =
          prefs.getBool(_kSpokenCallerQuietHours) ?? true;
      _spokenCallerQuietHoursStart =
          prefs.getString(_kSpokenCallerQuietHoursStart) ?? '22:00';
      _spokenCallerQuietHoursEnd =
          prefs.getString(_kSpokenCallerQuietHoursEnd) ?? '07:00';

      _relationshipQuietHoursEnabled =
          prefs.getBool(_kRelationshipQuietHoursEnabled) ?? false;
      _relationshipQuietHoursStart =
          prefs.getString(_kRelationshipQuietHoursStart) ?? '22:00';
      _relationshipQuietHoursEnd =
          prefs.getString(_kRelationshipQuietHoursEnd) ?? '07:00';
      _relationshipQuietHoursAllowedTiers =
          prefs.getStringList(_kRelationshipQuietHoursAllowedTiers) ??
              const [
                QuietHoursTiers.emergency,
                QuietHoursTiers.immediateFamily,
              ];
      _relationshipQuietHoursAllowedTags =
          prefs.getStringList(_kRelationshipQuietHoursAllowedTags) ?? const [];
      final rawContactIds =
          prefs.getStringList(_kRelationshipQuietHoursAllowedContactIds) ?? [];
      _relationshipQuietHoursAllowedContactIds = rawContactIds
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .toList();
      _perSimRingtones = _decodeSimRingtones(
        prefs.getString(_kPerSimRingtones),
      );
      _perSimColors = _decodeSimColors(prefs.getString(_kPerSimColors));

      // Push the ringer prefs to the native side so the incoming-call ringer has
      // them even on a cold start (before the Flutter engine is running).
      _mirrorRingerPrefs();

      // Same for the ringtone mirror (contact + per-SIM tone maps), so existing
      // installs get a native mirror without waiting for the next edit.
      _mirrorSimRingtones();
      ContactRepository().pushRingtoneMirror();

      // And the call-screening mirror (toggles here, number lists from the
      // repository), so the screening service has them on a cold start.
      _mirrorScreeningPrefs();
      unawaited(FlaggedNumberRepository().pushScreeningMirror());
      unawaited(QuietHoursService().syncQuietHoursMirror(settings: this));

      // And the emergency card, so the lock-screen shortcut matches the saved
      // record after a reinstall/restore without waiting for the next edit.
      // Publishes nothing while the feature is off — see EmergencyInfo.
      unawaited(EmergencyInfoRepository().pushMirror());

      _screenshotGuardEnabled = prefs.getBool(_kScreenshotGuard) ?? true;
      _smartRedialEnabled = prefs.getBool(_kSmartRedialEnabled) ?? true;
      _smartRedialDelayMinutes =
          prefs.getInt(_kSmartRedialDelayMinutes) ?? 5;
      _presetReachMeMessage =
          prefs.getString(_kPresetReachMeMessage) ?? defaultReachMeMessage;

      final fontIndex = prefs.getInt(_kAppFont);
      if (fontIndex != null &&
          fontIndex >= 0 &&
          fontIndex < AppFont.values.length) {
        _appFont = AppFont.values[fontIndex];
      }

      final textScaleIndex = prefs.getInt(_kTextScale);
      if (textScaleIndex != null &&
          textScaleIndex >= 0 &&
          textScaleIndex < AppTextScale.values.length) {
        _appTextScale = AppTextScale.values[textScaleIndex];
      }

      final lightArgb = prefs.getInt(_kAccentColorLight);
      final darkArgb = prefs.getInt(_kAccentColorDark);
      if (lightArgb != null) _lightAccent = Color(lightArgb);
      if (darkArgb != null) _darkAccent = Color(darkArgb);

      // Migrate the legacy single accent (which applied to both themes) into the
      // per-mode keys, then drop it so this only runs once.
      final legacyArgb = prefs.getInt(_kAccentColorLegacy);
      if (legacyArgb != null) {
        final legacy = Color(legacyArgb);
        if (lightArgb == null) {
          _lightAccent = legacy;
          await prefs.setInt(_kAccentColorLight, legacyArgb);
        }
        if (darkArgb == null) {
          _darkAccent = legacy;
          await prefs.setInt(_kAccentColorDark, legacyArgb);
        }
        await prefs.remove(_kAccentColorLegacy);
      }
    } catch (_) {
      // Fall back to defaults if preferences are unavailable.
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kThemeMode, mode.index);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets and persists the app-wide UI font. Applies live (the whole app
  /// re-themes via [fontFamily]).
  Future<void> setAppFont(AppFont font) async {
    if (font == _appFont) return;
    _appFont = font;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kAppFont, font.index);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets and persists the app-wide text size. Applies live (all text re-scales
  /// via [textScaleFactor]).
  Future<void> setAppTextScale(AppTextScale scale) async {
    if (scale == _appTextScale) return;
    _appTextScale = scale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kTextScale, scale.index);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Enables/disables the post-call feedback sheet and persists the choice.
  Future<void> setPostCallFeedbackEnabled(bool enabled) async {
    if (enabled == _postCallFeedbackEnabled) return;
    _postCallFeedbackEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPostCallFeedback, enabled);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets the default SIM (by phone-account id) and persists it. Pass null to
  /// restore "system default".
  Future<void> setDefaultSimId(String? phoneAccountId) async {
    if (phoneAccountId == _defaultSimId) return;
    _defaultSimId = phoneAccountId;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (phoneAccountId == null) {
        await prefs.remove(_kDefaultSimId);
      } else {
        await prefs.setString(_kDefaultSimId, phoneAccountId);
      }
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets and persists the dialer's "Top contacts" source.
  Future<void> setDialerTopSource(DialerTopSource source) async {
    if (source == _dialerTopSource) return;
    _dialerTopSource = source;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kDialerTopSource, source.index);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets and persists the secondary script layout for dialpad keys.
  Future<void> setDialpadScript(DialpadScript script) async {
    if (script == _dialpadScript) return;
    _dialpadScript = script;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kDialpadScript, script.index);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets and persists the incoming-call ringtone volume (clamped to 0–100) and
  /// mirrors it to the native ringer.
  Future<void> setRingtoneVolumePercent(int percent) async {
    final clamped = percent.clamp(0, 100);
    if (clamped == _ringtoneVolumePercent) return;
    _ringtoneVolumePercent = clamped;
    notifyListeners();
    _mirrorRingerPrefs();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kRingtoneVolume, clamped);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Enables/disables vibration on incoming calls, persists it, and mirrors it to
  /// the native ringer.
  Future<void> setVibrateOnIncomingCall(bool vibrate) async {
    if (vibrate == _vibrateOnIncomingCall) return;
    _vibrateOnIncomingCall = vibrate;
    notifyListeners();
    _mirrorRingerPrefs();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kVibrateOnCall, vibrate);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Assigns [ringtone] to the SIM with [phoneAccountId] (pass null to clear it),
  /// then persists the whole map.
  Future<void> setSimRingtone(
    String phoneAccountId,
    RingtoneRef? ringtone,
  ) async {
    if (phoneAccountId.isEmpty) return;
    final next = Map<String, RingtoneRef>.from(_perSimRingtones);
    if (ringtone == null) {
      if (!next.containsKey(phoneAccountId)) return;
      next.remove(phoneAccountId);
    } else {
      next[phoneAccountId] = ringtone;
    }
    _perSimRingtones = next;
    notifyListeners();
    _mirrorSimRingtones();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (next.isEmpty) {
        await prefs.remove(_kPerSimRingtones);
      } else {
        await prefs.setString(_kPerSimRingtones, _encodeSimRingtones(next));
      }
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Assigns [color] to the SIM with [phoneAccountId] (pass null to restore the
  /// slot default), then persists the whole map.
  Future<void> setSimColor(String phoneAccountId, Color? color) async {
    if (phoneAccountId.isEmpty) return;
    final next = Map<String, Color>.from(_perSimColors);
    if (color == null) {
      if (!next.containsKey(phoneAccountId)) return;
      next.remove(phoneAccountId);
    } else {
      next[phoneAccountId] = color;
    }
    _perSimColors = next;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (next.isEmpty) {
        await prefs.remove(_kPerSimColors);
      } else {
        await prefs.setString(_kPerSimColors, _encodeSimColors(next));
      }
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  static String _encodeSimColors(Map<String, Color> map) =>
      jsonEncode(map.map((id, color) => MapEntry(id, color.toARGB32())));

  static Map<String, Color> _decodeSimColors(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      final result = <String, Color>{};
      decoded.forEach((key, value) {
        if (key is String && value is num) result[key] = Color(value.toInt());
      });
      return result;
    } catch (_) {
      return const {};
    }
  }

  /// Pushes the current volume/vibrate/spoken-announcement prefs to the native ringer.
  /// Fire-and-forget: the native side reads its own persisted copy, so a failed push is harmless.
  void _mirrorRingerPrefs() {
    unawaited(
      TelecomService().setRingerPrefs(
        volumePercent: _ringtoneVolumePercent,
        vibrate: _vibrateOnIncomingCall,
        spokenAnnouncementEnabled: _spokenCallerAnnouncementEnabled,
        quietHoursEnabled: _spokenCallerQuietHoursEnabled,
        quietHoursStart: _spokenCallerQuietHoursStart,
        quietHoursEnd: _spokenCallerQuietHoursEnd,
      ),
    );
  }

  /// Enables or disables spoken caller announcements ("Amma calling").
  Future<void> setSpokenCallerAnnouncementEnabled(bool enabled) async {
    if (enabled == _spokenCallerAnnouncementEnabled) return;
    _spokenCallerAnnouncementEnabled = enabled;
    _mirrorRingerPrefs();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSpokenCallerAnnouncement, enabled);
    } catch (_) {}
  }

  /// Enables or disables suppressing spoken announcements during quiet hours.
  Future<void> setSpokenCallerQuietHoursEnabled(bool enabled) async {
    if (enabled == _spokenCallerQuietHoursEnabled) return;
    _spokenCallerQuietHoursEnabled = enabled;
    _mirrorRingerPrefs();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSpokenCallerQuietHours, enabled);
    } catch (_) {}
  }

  /// Sets the quiet hours time range (start and end as "HH:mm").
  Future<void> setSpokenCallerQuietHoursRange(String start, String end) async {
    if (start == _spokenCallerQuietHoursStart &&
        end == _spokenCallerQuietHoursEnd) {
      return;
    }
    _spokenCallerQuietHoursStart = start;
    _spokenCallerQuietHoursEnd = end;
    _mirrorRingerPrefs();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSpokenCallerQuietHoursStart, start);
      await prefs.setString(_kSpokenCallerQuietHoursEnd, end);
    } catch (_) {}
  }

  /// Enables or disables relationship-tier quiet hours call silencing.
  Future<void> setRelationshipQuietHoursEnabled(bool enabled) async {
    if (enabled == _relationshipQuietHoursEnabled) return;
    _relationshipQuietHoursEnabled = enabled;
    unawaited(QuietHoursService().syncQuietHoursMirror(settings: this));
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRelationshipQuietHoursEnabled, enabled);
    } catch (_) {}
  }

  /// Sets the relationship quiet hours time range (start and end as "HH:mm").
  Future<void> setRelationshipQuietHoursRange(
      String start, String end) async {
    if (start == _relationshipQuietHoursStart &&
        end == _relationshipQuietHoursEnd) {
      return;
    }
    _relationshipQuietHoursStart = start;
    _relationshipQuietHoursEnd = end;
    unawaited(QuietHoursService().syncQuietHoursMirror(settings: this));
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kRelationshipQuietHoursStart, start);
      await prefs.setString(_kRelationshipQuietHoursEnd, end);
    } catch (_) {}
  }

  /// Sets the allowed relationship tiers during quiet hours.
  Future<void> setRelationshipQuietHoursAllowedTiers(
      List<String> tiers) async {
    _relationshipQuietHoursAllowedTiers = List.from(tiers);
    unawaited(QuietHoursService().syncQuietHoursMirror(settings: this));
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kRelationshipQuietHoursAllowedTiers, tiers);
    } catch (_) {}
  }

  /// Sets the allowed tags during quiet hours.
  Future<void> setRelationshipQuietHoursAllowedTags(
      List<String> tags) async {
    _relationshipQuietHoursAllowedTags = List.from(tags);
    unawaited(QuietHoursService().syncQuietHoursMirror(settings: this));
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kRelationshipQuietHoursAllowedTags, tags);
    } catch (_) {}
  }

  /// Sets the allowed individual contact IDs during quiet hours.
  Future<void> setRelationshipQuietHoursAllowedContactIds(
      List<int> ids) async {
    _relationshipQuietHoursAllowedContactIds = List.from(ids);
    unawaited(QuietHoursService().syncQuietHoursMirror(settings: this));
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _kRelationshipQuietHoursAllowedContactIds,
        ids.map((id) => id.toString()).toList(),
      );
    } catch (_) {}
  }

  /// Pushes the per-SIM tone map to the native ringtone mirror so the ringer can
  /// pick the SIM's tone from the first note of an incoming call. Fire-and-forget,
  /// same as [_mirrorRingerPrefs].
  void _mirrorSimRingtones() {
    unawaited(
      TelecomService().setRingtoneMirror(
        simTones: _perSimRingtones.map((id, ref) => MapEntry(id, ref.path)),
      ),
    );
  }

  static String _encodeSimRingtones(Map<String, RingtoneRef> map) =>
      jsonEncode(map.map((id, ref) => MapEntry(id, ref.toJson())));

  static Map<String, RingtoneRef> _decodeSimRingtones(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      final result = <String, RingtoneRef>{};
      decoded.forEach((key, value) {
        if (key is String && value is Map) {
          final ref = RingtoneRef.fromJson(Map<String, dynamic>.from(value));
          if (ref.path.isNotEmpty) result[key] = ref;
        }
      });
      return result;
    } catch (_) {
      return const {};
    }
  }

  /// Enables/disables rejecting calls with no / hidden number, persists the
  /// choice, and mirrors it to the native screening service.
  Future<void> setBlockUnknownCallers(bool block) async {
    if (block == _blockUnknownCallers) return;
    _blockUnknownCallers = block;
    notifyListeners();
    _mirrorScreeningPrefs();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kBlockUnknownCallers, block);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Enables/disables caller identification labels and persists the choice.
  Future<void> setCallerIdEnabled(bool enabled) async {
    if (enabled == _callerIdEnabled) return;
    _callerIdEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kCallerIdEnabled, enabled);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Enables/disables the spam filter (flagged callers ring silently),
  /// persists the choice, and mirrors it to the native screening service.
  Future<void> setSpamFilterEnabled(bool enabled) async {
    if (enabled == _spamFilterEnabled) return;
    _spamFilterEnabled = enabled;
    notifyListeners();
    _mirrorScreeningPrefs();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSpamFilterEnabled, enabled);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Replaces the quick-reply list and persists it. Blank entries are dropped;
  /// pass [defaultQuickReplies] (or an empty list) via [resetQuickReplies] to
  /// restore the defaults.
  Future<void> setQuickReplies(List<String> replies) async {
    final cleaned = [
      for (final r in replies)
        if (r.trim().isNotEmpty) r.trim(),
    ];
    _quickReplies = cleaned;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kQuickReplies, cleaned);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Restores the out-of-the-box quick replies (and forgets the custom list).
  Future<void> resetQuickReplies() async {
    _quickReplies = defaultQuickReplies;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kQuickReplies);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets and persists the contacts-list sort order.
  Future<void> setContactSortOrder(ContactSortOrder order) async {
    if (order == _contactSortOrder) return;
    _contactSortOrder = order;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kContactSortOrder, order.index);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets and persists how a contact's name is arranged for display.
  Future<void> setNameDisplayFormat(NameDisplayFormat format) async {
    if (format == _nameDisplayFormat) return;
    _nameDisplayFormat = format;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kNameDisplayFormat, format.index);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Enables/disables hiding contacts without a phone number, and persists it.
  Future<void> setHideContactsWithoutPhone(bool hide) async {
    if (hide == _hideContactsWithoutPhone) return;
    _hideContactsWithoutPhone = hide;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHideContactsWithoutPhone, hide);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Replaces the relationship-name list and persists it. Entries are trimmed,
  /// blanks dropped, and duplicates removed case-insensitively (first spelling
  /// kept). If the cleaned list is empty the built-in defaults are restored (via
  /// [resetRelationshipNames]) so the picker is never blank.
  Future<void> setRelationshipNames(List<String> names) async {
    final seen = <String>{};
    final cleaned = <String>[];
    for (final n in names) {
      final t = n.trim();
      if (t.isEmpty) continue;
      if (seen.add(t.toLowerCase())) cleaned.add(t);
    }
    if (cleaned.isEmpty) {
      await resetRelationshipNames();
      return;
    }
    _relationshipNames = cleaned;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kRelationshipNames, cleaned);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Restores the built-in relationship names ([RelationshipTypes.presets]) and
  /// forgets the custom list.
  Future<void> resetRelationshipNames() async {
    _relationshipNames = RelationshipTypes.presets;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kRelationshipNames);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets how the app lock protects opening the app, and persists it. The caller
  /// is responsible for having set up the credential first (a device lock must
  /// exist for [LockMode.deviceLock]; an app PIN must be saved for
  /// [LockMode.appPin]).
  Future<void> setLockMode(LockMode mode) async {
    if (mode == _lockMode) return;
    _lockMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kLockMode, mode.index);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Reads the persisted lock mode without an [AppSettings] instance, for the
  /// launch lock gate (which runs before [load] completes). Honors the legacy
  /// toggle so old installs still lock. Defaults to [LockMode.none].
  static Future<LockMode> readLockMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_kLockMode);
      if (index != null && index >= 0 && index < LockMode.values.length) {
        return LockMode.values[index];
      }
      if (prefs.getBool(_kAppLockEnabledLegacy) ?? false) {
        return LockMode.deviceLock;
      }
      return LockMode.none;
    } catch (_) {
      return LockMode.none;
    }
  }

  /// Reads the persisted quick replies without an [AppSettings] instance, for
  /// the call flow (which may run before [load] completes on a cold-start
  /// incoming call). Falls back to [defaultQuickReplies].
  static Future<List<String>> readQuickReplies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_kQuickReplies) ?? defaultQuickReplies;
    } catch (_) {
      return defaultQuickReplies;
    }
  }

  /// Pushes the screening toggles to the native side (the number lists are the
  /// [FlaggedNumberRepository]'s side of the mirror). Fire-and-forget, same as
  /// [_mirrorRingerPrefs].
  void _mirrorScreeningPrefs() {
    unawaited(
      TelecomService().setScreeningMirror(
        blockUnknown: _blockUnknownCallers,
        spamFilter: _spamFilterEnabled,
      ),
    );
  }

  /// Reads the persisted caller-identification toggle without an [AppSettings]
  /// instance, for the call flow (which may run before [load] completes on a
  /// cold-start incoming call). Defaults to true.
  /// Reads the screenshot-guard flag without a provider, for screens (contact
  /// detail, in-call) that apply it from their own lifecycle rather than from a
  /// widget rebuild. Defaults to true — protection is the safe failure.
  static Future<bool> readScreenshotGuardEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kScreenshotGuard) ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<bool> readCallerIdEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kCallerIdEnabled) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// How far the device call log has already been synced into Recents, or null
  /// when it never has (the first sync then does one full import).
  ///
  /// Static, like the other call-flow readers: the sync runs from services and
  /// at startup, where there may be no [AppSettings] instance yet.
  static Future<DateTime?> readCallLogSyncedThrough() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt(_kCallLogSyncedThrough);
      if (millis == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    } catch (_) {
      return null;
    }
  }

  /// Records how far the device call log has been synced. Never moves the mark
  /// backwards, so a partial sync can't make a later one re-import old calls.
  static Future<void> writeCallLogSyncedThrough(DateTime through) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = through.millisecondsSinceEpoch;
      final existing = prefs.getInt(_kCallLogSyncedThrough) ?? 0;
      if (millis > existing) {
        await prefs.setInt(_kCallLogSyncedThrough, millis);
      }
    } catch (_) {
      // Non-fatal: the next sync just re-checks a little more history.
    }
  }

  /// Whether the one-shot duplicate-Recents repair has already run.
  static Future<bool> readCallLogDuplicatesMerged() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kCallLogDuplicatesMerged) ?? false;
    } catch (_) {
      // Treat "can't tell" as done — the repair is a nice-to-have, and a failing
      // preference store shouldn't make it re-run on every launch.
      return true;
    }
  }

  /// Records that the one-shot duplicate-Recents repair has run.
  static Future<void> writeCallLogDuplicatesMerged() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kCallLogDuplicatesMerged, true);
    } catch (_) {
      // Non-fatal: at worst the repair runs again next launch (it is idempotent).
    }
  }

  /// Clears the call-log sync mark, so the next sync re-imports from scratch.
  /// Used after the destructive "replace Recents" action.
  static Future<void> clearCallLogSyncedThrough() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kCallLogSyncedThrough);
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Reads the persisted spam-filter toggle without an [AppSettings] instance,
  /// for the call flow. Defaults to false.
  static Future<bool> readSpamFilterEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kSpamFilterEnabled) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Enables/disables including secret contacts in the regular exports and
  /// persists the choice.
  Future<void> setIncludeSecretInExport(bool include) async {
    if (include == _includeSecretInExport) return;
    _includeSecretInExport = include;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kIncludeSecretInExport, include);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets and persists the Default country (ISO alpha-2, e.g. "IN"). Drives how
  /// numbers are normalized when identifying the contact behind a call.
  Future<void> setDefaultCountryIso(String iso) async {
    final normalized = iso.trim().toUpperCase();
    if (normalized.isEmpty || normalized == _defaultCountryIso) return;
    _defaultCountryIso = normalized;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kDefaultCountry, normalized);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Reads the persisted Default country without needing an [AppSettings]
  /// instance, for non-widget consumers (services resolving a caller ID).
  /// Falls back to the auto-detected region, matching [defaultCountryIso].
  static Future<String> readDefaultCountryIso() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final country = prefs.getString(_kDefaultCountry);
      if (country != null && country.trim().isNotEmpty) {
        return country.trim().toUpperCase();
      }
    } catch (_) {
      // Fall through to auto-detect.
    }
    return _autoDetectedCountryIso();
  }

  /// Reads the persisted per-SIM ringtone for [phoneAccountId] without an
  /// [AppSettings] instance, for the call flow (which may run before [load]
  /// completes on a cold-start incoming call). Null when none is set.
  static Future<RingtoneRef?> readSimRingtone(String? phoneAccountId) async {
    if (phoneAccountId == null || phoneAccountId.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _decodeSimRingtones(prefs.getString(_kPerSimRingtones));
      return map[phoneAccountId];
    } catch (_) {
      return null;
    }
  }

  /// Reads the persisted per-SIM color for [phoneAccountId] without an
  /// [AppSettings] instance, for the call flow (which may run before [load]
  /// completes on a cold-start incoming call). Null when none is set.
  static Future<Color?> readSimColor(String? phoneAccountId) async {
    if (phoneAccountId == null || phoneAccountId.isEmpty) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = _decodeSimColors(prefs.getString(_kPerSimColors));
      return map[phoneAccountId];
    } catch (_) {
      return null;
    }
  }

  /// Enables/disables the per-call SIM prompt and persists the choice.
  Future<void> setAskSimBeforeCall(bool ask) async {
    if (ask == _askSimBeforeCall) return;
    _askSimBeforeCall = ask;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kAskSimBeforeCall, ask);
    } catch (_) {
      // Non-fatal: the in-memory value still applies for this session.
    }
  }

  /// Sets and persists the accent for a single [brightness], leaving the other
  /// mode untouched.
  Future<void> setAccentFor(Brightness brightness, Color color) async {
    if (brightness == Brightness.dark) {
      _darkAccent = color;
    } else {
      _lightAccent = color;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        brightness == Brightness.dark ? _kAccentColorDark : _kAccentColorLight,
        color.toARGB32(),
      );
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Clears the accent override for a single [brightness], restoring that
  /// theme's default accent. The other mode is unaffected.
  Future<void> resetAccentFor(Brightness brightness) async {
    if (brightness == Brightness.dark) {
      _darkAccent = null;
    } else {
      _lightAccent = null;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(
        brightness == Brightness.dark ? _kAccentColorDark : _kAccentColorLight,
      );
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Sets and persists whether contact detail / in-call block screenshots.
  Future<void> setScreenshotGuardEnabled(bool enabled) async {
    if (enabled == _screenshotGuardEnabled) return;
    _screenshotGuardEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kScreenshotGuard, enabled);
    } catch (_) {}
  }

  /// Sets and persists whether Smart Redial prompts on unanswered calls.
  Future<void> setSmartRedialEnabled(bool enabled) async {
    if (enabled == _smartRedialEnabled) return;
    _smartRedialEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSmartRedialEnabled, enabled);
    } catch (_) {}
  }

  /// Sets and persists default delay in minutes for auto-retry.
  Future<void> setSmartRedialDelayMinutes(int minutes) async {
    final clamped = minutes.clamp(1, 120);
    if (clamped == _smartRedialDelayMinutes) return;
    _smartRedialDelayMinutes = clamped;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kSmartRedialDelayMinutes, clamped);
    } catch (_) {}
  }

  /// Sets and persists preset "trying to reach you" message text.
  Future<void> setPresetReachMeMessage(String message) async {
    final text = message.trim().isEmpty ? defaultReachMeMessage : message.trim();
    if (text == _presetReachMeMessage) return;
    _presetReachMeMessage = text;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kPresetReachMeMessage, text);
    } catch (_) {}
  }

  /// Reads whether Smart Redial is enabled without an instance.
  static Future<bool> readSmartRedialEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kSmartRedialEnabled) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Reads default delay in minutes without an instance.
  static Future<int> readSmartRedialDelayMinutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_kSmartRedialDelayMinutes) ?? 5;
    } catch (_) {
      return 5;
    }
  }

  /// Reads the user's default SIM (its phone-account id) without an instance.
  /// Null means "let the platform pick". Used by services with no
  /// `BuildContext` to hand — e.g. Smart Redial resolving the SIM a scheduled
  /// retry must dial on.
  static Future<String?> readDefaultSimId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kDefaultSimId);
    } catch (_) {
      return null;
    }
  }

  /// Reads preset reach me message without an instance.
  static Future<String> readPresetReachMeMessage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kPresetReachMeMessage) ?? defaultReachMeMessage;
    } catch (_) {
      return defaultReachMeMessage;
    }
  }
}

