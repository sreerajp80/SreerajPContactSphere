// lib/screens/appearance_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Lets the user choose Light / Dark / System and pick an accent color from a
/// full HSV color wheel. Changes apply live (the whole app re-themes) and are
/// persisted by [AppSettings].
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  late HSVColor _hsv;
  Brightness? _lastBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-sync the wheel to the active mode's accent whenever the effective
    // brightness changes (including via the Light/Dark/System toggle). Picking a
    // color keeps the same brightness, so it won't clobber the user's edit.
    final brightness = Theme.of(context).brightness;
    if (brightness == _lastBrightness) return;
    _lastBrightness = brightness;
    _hsv = HSVColor.fromColor(
      context.read<AppSettings>().accentFor(brightness),
    );
  }

  void _apply(HSVColor hsv) {
    setState(() => _hsv = hsv);
    context.read<AppSettings>().setAccentFor(
      Theme.of(context).brightness,
      hsv.toColor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final settings = context.watch<AppSettings>();
    final selected = _hsv.toColor();
    final onAccent = AppTheme.contrastOn(selected);

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _label(context, 'FONT'),
          const SizedBox(height: 10),
          for (final font in AppFont.values) ...[
            _FontTile(
              font: font,
              selected: settings.appFont == font,
              onTap: () => context.read<AppSettings>().setAppFont(font),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          _label(context, 'TEXT SIZE'),
          const SizedBox(height: 10),
          SegmentedButton<AppTextScale>(
            segments: [
              for (final scale in AppTextScale.values)
                ButtonSegment(value: scale, label: Text(scale.label)),
            ],
            selected: {settings.appTextScale},
            showSelectedIcon: false,
            onSelectionChanged: (s) =>
                context.read<AppSettings>().setAppTextScale(s.first),
          ),
          const SizedBox(height: 18),
          _label(context, 'THEME'),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto_outlined),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) =>
                context.read<AppSettings>().setThemeMode(s.first),
          ),
          const SizedBox(height: 28),
          _label(context, 'ACCENT COLOR'),
          const SizedBox(height: 14),

          // Live preview chip — uses contrastOn so the label is always legible.
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: selected,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: selected.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.palette_outlined, color: onAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Sample text',
                    style: TextStyle(
                      color: onAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick-pick presets.
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (final c in AppTheme.presetAccents)
                _PresetSwatch(
                  color: c,
                  selected: _sameColor(c, selected),
                  onTap: () => _apply(HSVColor.fromColor(c)),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Full HSV wheel (hue + saturation) and a brightness slider.
          Center(
            child: _HueWheel(
              size: 248,
              hsv: _hsv,
              onChanged: (hue, sat) =>
                  _apply(_hsv.withHue(hue).withSaturation(sat)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.brightness_6_outlined, size: 20),
              Expanded(
                child: Slider(
                  value: _hsv.value,
                  onChanged: (v) => _apply(_hsv.withValue(v.clamp(0.05, 1.0))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                final brightness = Theme.of(context).brightness;
                context.read<AppSettings>().resetAccentFor(brightness);
                setState(() {
                  _hsv = HSVColor.fromColor(
                    brightness == Brightness.dark
                        ? AppTheme.midnightAccent
                        : AppTheme.calmAccent,
                  );
                });
              },
              icon: const Icon(Icons.restart_alt),
              label: Text(
                'Reset ${theme.brightness == Brightness.dark ? 'Dark' : 'Light'} to default',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Text contrast is adjusted automatically for readability.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _sameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();

  Widget _label(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _PresetSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PresetSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: selected
            ? Icon(Icons.check, color: AppTheme.contrastOn(color), size: 22)
            : null,
      ),
    );
  }
}

/// One selectable font row in the Appearance → Font list. Shows the font's name
/// plus a live English + Malayalam preview rendered in that very font, so the
/// user can judge readability of both scripts before picking.
class _FontTile extends StatelessWidget {
  final AppFont font;
  final bool selected;
  final VoidCallback onTap;

  const _FontTile({
    required this.font,
    required this.selected,
    required this.onTap,
  });

  /// English + Malayalam sample rendered in each font. Malayalam reads
  /// "Malayalam is beautiful".
  static const String _englishSample = 'The quick brown fox • 0123';
  static const String _malayalamSample = 'മലയാളം സുന്ദരമാണ്';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    // null family = platform default (Roboto); let TextStyle fall through.
    final family = font.family;

    return Material(
      color: colors.cardSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? accent
                  : theme.dividerColor.withValues(alpha: 0.4),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      font.label,
                      style: TextStyle(
                        fontFamily: family,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _englishSample,
                      style: TextStyle(
                        fontFamily: family,
                        fontSize: 14,
                        color: colors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _malayalamSample,
                      style: TextStyle(
                        fontFamily: family,
                        fontSize: 16,
                        color: colors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? accent : colors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A circular HSV picker: angle = hue, distance from center = saturation.
class _HueWheel extends StatelessWidget {
  final double size;
  final HSVColor hsv;
  final void Function(double hue, double saturation) onChanged;

  const _HueWheel({
    required this.size,
    required this.hsv,
    required this.onChanged,
  });

  void _handle(Offset local) {
    final radius = size / 2;
    final center = Offset(radius, radius);
    final v = local - center;
    final dist = v.distance;
    final sat = (dist / radius).clamp(0.0, 1.0);
    var deg = v.direction * 180 / math.pi; // -180..180
    if (deg < 0) deg += 360;
    onChanged(deg, sat);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) => _handle(d.localPosition),
      onPanUpdate: (d) => _handle(d.localPosition),
      child: CustomPaint(size: Size.square(size), painter: _WheelPainter(hsv)),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final HSVColor hsv;
  const _WheelPainter(this.hsv);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    // Hue sweep.
    final hueColors = <Color>[
      for (var i = 0; i <= 360; i += 30)
        HSVColor.fromAHSV(1, i % 360.0, 1, 1).toColor(),
    ];
    final sweep = Paint()
      ..shader = SweepGradient(
        colors: hueColors,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sweep);

    // Saturation falloff: white at center fading to transparent at the rim.
    final satPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, satPaint);

    // Brightness dimming.
    if (hsv.value < 1) {
      final dim = Paint()
        ..color = Colors.black.withValues(alpha: 1 - hsv.value);
      canvas.drawCircle(center, radius, dim);
    }

    // Thumb at the selected hue/sat position.
    final angle = hsv.hue * math.pi / 180;
    final r = hsv.saturation * radius;
    final thumb = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
    canvas.drawCircle(
      thumb,
      11,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(thumb, 8, Paint()..color = hsv.toColor());
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.hsv != hsv;
}
