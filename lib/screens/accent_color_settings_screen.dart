// lib/screens/accent_color_settings_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for picking an Accent Color using presets or an HSV color wheel.
class AccentColorSettingsScreen extends StatefulWidget {
  const AccentColorSettingsScreen({super.key});

  @override
  State<AccentColorSettingsScreen> createState() =>
      _AccentColorSettingsScreenState();
}

class _AccentColorSettingsScreenState extends State<AccentColorSettingsScreen> {
  late HSVColor _hsv;
  Brightness? _lastBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final selected = _hsv.toColor();
    final onAccent = AppTheme.contrastOn(selected);

    return Scaffold(
      appBar: AppBar(title: const Text('Accent Color')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _label(context, 'LIVE PREVIEW'),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
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
          const SizedBox(height: 24),
          _label(context, 'PRESETS'),
          const SizedBox(height: 12),
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
          _label(context, 'CUSTOM COLOR WHEEL'),
          const SizedBox(height: 14),
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
    var deg = v.direction * 180 / math.pi;
    if (deg < 0) deg += 360;
    onChanged(deg, sat);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (d) => _handle(d.localPosition),
      onPanUpdate: (d) => _handle(d.localPosition),
      child: CustomPaint(
        size: Size.square(size),
        painter: _WheelPainter(hsv),
      ),
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

    final hueColors = <Color>[
      for (var i = 0; i <= 360; i += 30)
        HSVColor.fromAHSV(1, i % 360.0, 1, 1).toColor(),
    ];
    final sweep = Paint()
      ..shader = SweepGradient(
        colors: hueColors,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sweep);

    final satPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, satPaint);

    if (hsv.value < 1) {
      final dim = Paint()
        ..color = Colors.black.withValues(alpha: 1 - hsv.value);
      canvas.drawCircle(center, radius, dim);
    }

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
