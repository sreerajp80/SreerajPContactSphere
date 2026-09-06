// lib/screens/help/t9_dialing_help_screen.dart
//
// User-facing documentation for T9 Smart Dialing & Malayalam script mappings,
// reachable from Settings → Help → T9 Dialing & Malayalam.

import 'package:flutter/material.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

class T9DialingHelpScreen extends StatelessWidget {
  const T9DialingHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('T9 Dialing & Malayalam')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: const [
          _Intro(
            'SreerajP Contacts Sphere features a smart multi-script T9 dialpad. You can '
            'search your contacts seamlessly using English or regional script '
            'key presses (Malayalam, Devanagari, etc.).',
          ),
          SizedBox(height: 24),

          _Section(
            icon: Icons.sort_by_alpha,
            title: 'Malayalam Vowels Mapping (അ to അഃ)',
            children: [
              _Bullet('Key 2 (ക-ങ): Vowels അ, ആ + Matras ാ, ി, ീ'),
              _Bullet('Key 3 (ച-ഞ): Vowels ഉ, ഊ, ഋ + Matras ു, ൂ, ൃ'),
              _Bullet('Key 4 (ട-ണ): Vowels എ, ഏ, ഐ + Matras െ, േ, ൈ'),
              _Bullet('Key 5 (ത-ന): Vowels ഒ, ഓ, ഔ + Matras ൊ, ോ, ൌ, ൗ'),
              _Bullet(
                'Key 9 (ള-റ): Anusvaram & Visargam (ം, ഃ) + Chillu letters (ൺ, ൻ, ർ, ൽ, ൾ, ൿ)',
              ),
            ],
          ),

          _Section(
            icon: Icons.keyboard_outlined,
            title: 'Why Vowels Aren\'t Printed on Key Labels',
            children: [
              _Bullet(
                'Key legends display consonant group ranges (e.g. ക-ങ, ച-ഞ) '
                'to keep the dialpad clean and easy to read.',
              ),
              _Bullet(
                'Even though vowels are not printed on the button face, all '
                'vowels (അ-ഔ), matras, and chillu letters are fully mapped '
                'and active in T9 search.',
              ),
            ],
          ),

          _Section(
            icon: Icons.g_translate_outlined,
            title: 'Manglish & Transliteration Search',
            children: [
              _Bullet(
                'English T9 key presses automatically match Malayalam names. '
                'For example, typing 2-6-4-5 (A-N-I-L) will match both '
                '"Anil" and "അനിൽ".',
              ),
              _Bullet(
                'To change the script shown on the keys, use the "Dialpad '
                'script" card on the main Settings page.',
              ),
            ],
          ),

          SizedBox(height: 8),
          _Footer(
            'Tip: the "Dialpad script" card offers Auto, Malayalam, '
            'Devanagari, Cyrillic, Arabic, Greek, or None. Auto follows the '
            'app language. Whichever you pick, search still matches every '
            'script — the setting only changes what is printed on the keys.',
          ),
        ],
      ),
    );
  }
}

/// The lead paragraph at the top of the article.
class _Intro extends StatelessWidget {
  final String text;
  const _Intro(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Text(
      text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colors.mutedText,
        height: 1.5,
      ),
    );
  }
}

/// One titled section: an accent icon + heading, then its bullet points.
class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

/// A single bullet line inside a [_Section].
class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.mutedText,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The closing tip, set apart in a soft accent panel.
class _Footer extends StatelessWidget {
  final String text;
  const _Footer(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final colors = theme.extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.mutedText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
