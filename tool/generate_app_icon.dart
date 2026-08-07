// tool/generate_app_icon.dart
//
// Generates the Android launcher icon assets by painting with dart:ui Canvas —
// no external image tooling required. Run from the project root with:
//
//   flutter test tool/generate_app_icon.dart
//
// It (re)writes, for every density bucket (mdpi..xxxhdpi):
//   * mipmap-*/ic_launcher.png            — legacy full-bleed icon (pre-API 26)
//   * mipmap-*/ic_launcher_background.png — adaptive-icon background (gradient)
//   * mipmap-*/ic_launcher_foreground.png — adaptive-icon foreground (white glyph)
//   * mipmap-*/ic_launcher_monochrome.png — Android 13+ themed-icon layer
// plus build/icon_preview.png, a composited preview of the adaptive icon as a
// launcher would mask it (circle), for quick visual inspection.
//
// Design: the app's brand gradient (Calm teal accent, hue +32° end — mirrors
// AppTheme._gradientFrom) behind a white "sphere of contacts" glyph: a central
// disc wrapped by a tilted orbit ring carrying small satellite dots.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Calm theme accent — keep in sync with AppTheme.calmAccent.
const Color _accent = Color(0xFF0D9488);

/// Mirrors AppTheme._gradientFrom: hue +32°, saturation ×0.95.
Color _gradientEnd(Color accent) {
  final hsl = HSLColor.fromColor(accent);
  return hsl
      .withHue((hsl.hue + 32) % 360)
      .withSaturation((hsl.saturation * 0.95).clamp(0.0, 1.0))
      .toColor();
}

/// Density-bucket scale factors relative to mdpi (1x).
const Map<String, double> _densities = {
  'mdpi': 1,
  'hdpi': 1.5,
  'xhdpi': 2,
  'xxhdpi': 3,
  'xxxhdpi': 4,
};

const int _legacyBaseDp = 48; // legacy launcher icon is 48dp
const int _adaptiveBaseDp = 108; // adaptive icon layers are 108dp

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate launcher icon assets', () async {
    final resDir = Directory('android/app/src/main/res');
    expect(
      resDir.existsSync(),
      isTrue,
      reason:
          'run from the project root: flutter test tool/generate_app_icon.dart',
    );

    for (final entry in _densities.entries) {
      final dir = Directory('${resDir.path}/mipmap-${entry.key}');
      dir.createSync(recursive: true);

      final legacy = (_legacyBaseDp * entry.value).round();
      final adaptive = (_adaptiveBaseDp * entry.value).round();

      await _writePng('${dir.path}/ic_launcher.png', legacy, _paintLegacy);
      await _writePng(
        '${dir.path}/ic_launcher_background.png',
        adaptive,
        _paintBackground,
      );
      await _writePng(
        '${dir.path}/ic_launcher_foreground.png',
        adaptive,
        _paintForeground,
      );
      await _writePng(
        '${dir.path}/ic_launcher_monochrome.png',
        adaptive,
        _paintForeground,
      );
    }

    Directory('build').createSync(recursive: true);
    await _writePng('build/icon_preview.png', 432, _paintPreview);
  });
}

Future<void> _writePng(
  String path,
  int size,
  void Function(Canvas, double) paint,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );
  paint(canvas, size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
  image.dispose();
}

Paint _gradientPaint(double s) => Paint()
  ..shader = ui.Gradient.linear(Offset.zero, Offset(s, s), [
    _accent,
    _gradientEnd(_accent),
  ]);

/// Legacy icon: rounded gradient square, glyph sized for the full tile.
void _paintLegacy(Canvas c, double s) {
  final rect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, s, s),
    Radius.circular(s * 0.22),
  );
  c.drawRRect(rect, _gradientPaint(s));
  _paintGlyph(c, Offset(s / 2, s / 2), s * 0.28);
}

/// Adaptive background layer: full-bleed gradient (launcher applies the mask).
void _paintBackground(Canvas c, double s) {
  c.drawRect(Rect.fromLTWH(0, 0, s, s), _gradientPaint(s));
}

/// Adaptive foreground / monochrome layer: white glyph inside the 66/108dp
/// safe zone (extent kept within a 0.306·s radius of the center).
void _paintForeground(Canvas c, double s) {
  _paintGlyph(c, Offset(s / 2, s / 2), s * 0.24);
}

/// Preview: background + foreground composited under a circular launcher mask.
void _paintPreview(Canvas c, double s) {
  c.save();
  c.clipPath(
    Path()
      ..addOval(Rect.fromCircle(center: Offset(s / 2, s / 2), radius: s / 2)),
  );
  _paintBackground(c, s);
  _paintForeground(c, s);
  c.restore();
}

/// The "sphere of contacts" glyph, white, centered on [center]. [g] is the
/// glyph radius unit: the orbit ring's semi-major axis. Max extent ≈ 1.16·g.
void _paintGlyph(Canvas c, Offset center, double g) {
  final fill = Paint()
    ..color = Colors.white
    ..isAntiAlias = true;
  final stroke = Paint()
    ..color = Colors.white
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = g * 0.14;

  c.save();
  c.translate(center.dx, center.dy);
  c.rotate(-24 * math.pi / 180);

  // Orbit ring (tilted ellipse) — kept clearly open around the disc so the
  // mark reads as an orbit, not an eye.
  final rx = g;
  final ry = g * 0.58;
  c.drawOval(
    Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
    stroke,
  );

  // Satellite dots sitting on the ring.
  for (final (t, r) in [(-20.0, 0.16), (150.0, 0.13), (255.0, 0.11)]) {
    final a = t * math.pi / 180;
    c.drawCircle(Offset(rx * math.cos(a), ry * math.sin(a)), g * r, fill);
  }

  // Central disc.
  c.drawCircle(Offset.zero, g * 0.33, fill);

  c.restore();
}
