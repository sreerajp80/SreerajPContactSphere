// lib/theme/app_theme.dart
//
// Two themes adapted from sample/Smart Contacts.dc.html:
//   * Calm     (light) — Material 3, cool teal.
//   * Midnight (dark)  — deep navy with an emotional, mood-shifting accent glow.
//
// Both are seeded from a user-chosen accent color. Extra design tokens that
// don't fit ColorScheme (hero gradient, search fill, muted text, etc.) live on
// the [AppColors] ThemeExtension so screens read them via Theme.of(context).

import 'package:flutter/material.dart';

/// A relationship-health mood derived from a 0–100 score. Mirrors the `mood()`
/// function in the design mockup.
class Mood {
  final String label;
  final Color color;
  final Color soft;

  const Mood(this.label, this.color, this.soft);
}

/// Design tokens that aren't part of [ColorScheme] but are shared across the
/// redesigned screens.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// True for the Midnight (dark) theme — screens use this to switch the hero
  /// card between a gradient (Calm) and a glow (Midnight).
  final bool isDark;

  /// Background fill of the search field.
  final Color searchFill;

  /// Surface of contact / settings cards.
  final Color cardSurface;

  /// Secondary / muted text color.
  final Color mutedText;

  /// Start and end colors of the hero / FAB gradient (derived from the accent).
  final Color gradientStart;
  final Color gradientEnd;

  const AppColors({
    required this.isDark,
    required this.searchFill,
    required this.cardSurface,
    required this.mutedText,
    required this.gradientStart,
    required this.gradientEnd,
  });

  LinearGradient get brandGradient => LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  AppColors copyWith({
    bool? isDark,
    Color? searchFill,
    Color? cardSurface,
    Color? mutedText,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return AppColors(
      isDark: isDark ?? this.isDark,
      searchFill: searchFill ?? this.searchFill,
      cardSurface: cardSurface ?? this.cardSurface,
      mutedText: mutedText ?? this.mutedText,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      isDark: t < 0.5 ? isDark : other.isDark,
      searchFill: Color.lerp(searchFill, other.searchFill, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  /// Default accent for the Calm (light) theme — cool teal.
  static const Color calmAccent = Color(0xFF0D9488);

  /// Default accent for the Midnight (dark) theme — soft indigo.
  static const Color midnightAccent = Color(0xFF7C8AFF);

  /// A handful of pleasant preset accents shown as quick-picks above the wheel.
  static const List<Color> presetAccents = <Color>[
    Color(0xFF0D9488), // teal
    Color(0xFF3B82F6), // blue
    Color(0xFF7C8AFF), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFFF97316), // orange
    Color(0xFF10B981), // green
    Color(0xFFEF4444), // red
  ];

  /// Preset colors offered for tagging a SIM (Settings → SIM & calling). All
  /// are bright enough to read on the dark SIM chip of the in-call screen.
  static const List<Color> simColorChoices = <Color>[
    Color(0xFF4FC3F7), // light blue
    Color(0xFFFFB74D), // orange
    Color(0xFF81C784), // green
    Color(0xFFF06292), // pink
    Color(0xFFBA68C8), // violet
    Color(0xFF9FA8DA), // indigo
    Color(0xFF4DD0E1), // cyan
    Color(0xFFFFF176), // yellow
    Color(0xFFFF8A65), // coral
    Color(0xFFE57373), // red
  ];

  /// Default color for the SIM in [slotIndex] when the user hasn't picked one:
  /// slots cycle the first choices so dual SIMs are distinct out of the box
  /// (SIM 1 light blue, SIM 2 orange).
  static Color defaultSimColor(int? slotIndex) =>
      simColorChoices[(slotIndex ?? 0) % simColorChoices.length];

  /// Returns black or white — whichever reads best on top of [background].
  /// This is the contrast guarantee for accent-colored chips, badges and
  /// swatches.
  static Color contrastOn(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  /// Maps a 0–100 relationship score to a mood (color + label), matching the
  /// thresholds in the design mockup.
  static Mood moodFor(double score) {
    if (score >= 75) {
      return Mood(
        'Thriving',
        const Color(0xFF10B981),
        const Color(0xFF10B981).withValues(alpha: 0.16),
      );
    }
    if (score >= 50) {
      return Mood(
        'Steady',
        const Color(0xFFF59E0B),
        const Color(0xFFF59E0B).withValues(alpha: 0.18),
      );
    }
    if (score >= 25) {
      return Mood(
        'Fading',
        const Color(0xFFFB7185),
        const Color(0xFFFB7185).withValues(alpha: 0.16),
      );
    }
    return Mood(
      'Needs love',
      const Color(0xFFEF4444),
      const Color(0xFFEF4444).withValues(alpha: 0.16),
    );
  }

  /// Derives a two-tone gradient from any accent by rotating its hue, so the
  /// hero card and FAB stay attractive whatever color the user picks.
  static List<Color> _gradientFrom(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    final end = hsl
        .withHue((hsl.hue + 32) % 360)
        .withSaturation((hsl.saturation * 0.95).clamp(0.0, 1.0))
        .toColor();
    return [accent, end];
  }

  /// The Calm light theme. [fontFamily] is the bundled font-family name to use
  /// (null falls back to the platform default, Roboto).
  static ThemeData calm(Color accent, {String? fontFamily}) {
    const background = Color(0xFFF1F7F7);
    const ink = Color(0xFF0F2E2B);
    final scheme = ColorScheme.fromSeed(seedColor: accent).copyWith(
      surface: background,
      // Pin primary to the exact accent so the app renders the color the user
      // picked (ColorScheme.fromSeed otherwise remaps the seed into a tonal palette).
      primary: accent,
      onPrimary: contrastOn(accent),
    );
    final grad = _gradientFrom(accent);

    return _build(
      scheme: scheme,
      background: background,
      ink: ink,
      fontFamily: fontFamily,
      extension: AppColors(
        isDark: false,
        searchFill: Colors.white,
        cardSurface: Colors.white,
        mutedText: const Color(0xFF64807D),
        gradientStart: grad[0],
        gradientEnd: grad[1],
      ),
    );
  }

  /// The Midnight dark theme. [fontFamily] is the bundled font-family name to
  /// use (null falls back to the platform default, Roboto).
  static ThemeData midnight(Color accent, {String? fontFamily}) {
    const background = Color(0xFF0A0C16);
    const ink = Color(0xFFE8EAF6);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF12162A),
          // Pin primary to the exact accent so the app renders the color the user
          // picked (ColorScheme.fromSeed otherwise remaps the seed into a tonal palette).
          primary: accent,
          onPrimary: contrastOn(accent),
        );
    final grad = _gradientFrom(accent);

    return _build(
      scheme: scheme,
      background: background,
      ink: ink,
      fontFamily: fontFamily,
      extension: AppColors(
        isDark: true,
        searchFill: const Color(0xFF161A2C),
        cardSurface: const Color(0xFF12162A),
        mutedText: const Color(0xFF8B90B5),
        gradientStart: grad[0],
        gradientEnd: grad[1],
      ),
    );
  }

  static ThemeData _build({
    required ColorScheme scheme,
    required Color background,
    required Color ink,
    required AppColors extension,
    String? fontFamily,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      // The user-picked bundled font, or the platform default (Roboto).
      fontFamily: fontFamily ?? 'Roboto',
    );
    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[extension],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: extension.cardSurface,
        elevation: extension.isDark ? 0 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      iconTheme: IconThemeData(color: ink),
    );
  }
}
