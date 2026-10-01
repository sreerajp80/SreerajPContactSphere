// lib/screens/help/personalization_help_screen.dart
//
// User-facing documentation for how the app looks and sounds: theme, accent
// colour, fonts and text size, contact display options, ringtones, volume and
// vibration, and the default country. Mirrors [AppearanceScreen],
// [TypographySettingsScreen], [ContactDisplaySettingsScreen],
// [RingtoneSettingsScreen] / [PerSimRingtoneScreen] and [DefaultCountryScreen].
// If those screens change, update this page.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/screens/help/help_article.dart';

class PersonalizationHelpScreen extends StatelessWidget {
  const PersonalizationHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HelpArticleScaffold(
      title: AppLocalizations.of(context).helpPersonalizationTitle1,
      children: [
        HelpIntro(AppLocalizations.of(context).helpPersonalizationIntro),
        const SizedBox(height: 24),

        HelpSection(
          icon: Icons.palette_outlined,
          title: AppLocalizations.of(context).helpPersonalizationTitle2,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPersonalizationBullet1),
            HelpBullet(AppLocalizations.of(context).helpPersonalizationBullet2),
          ],
        ),

        HelpSection(
          icon: Icons.text_fields_outlined,
          title: AppLocalizations.of(context).helpPersonalizationTitle3,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPersonalizationBullet3),
            HelpBullet(AppLocalizations.of(context).helpPersonalizationBullet4),
            HelpBullet(AppLocalizations.of(context).helpPersonalizationBullet5),
          ],
        ),

        HelpSection(
          icon: Icons.sort_by_alpha,
          title: AppLocalizations.of(context).helpPersonalizationTitle4,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPersonalizationBullet6),
            HelpBullet(AppLocalizations.of(context).helpPersonalizationBullet7),
          ],
        ),

        HelpSection(
          icon: Icons.music_note_outlined,
          title: AppLocalizations.of(context).helpPersonalizationTitle5,
          children: [
            HelpBullet(AppLocalizations.of(context).helpPersonalizationBullet8),
            HelpBullet(AppLocalizations.of(context).helpPersonalizationBullet9),
            HelpBullet(
              AppLocalizations.of(context).helpPersonalizationBullet10,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpPersonalizationBullet11,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpPersonalizationBullet12,
            ),
          ],
        ),

        HelpSection(
          icon: Icons.public_outlined,
          title: AppLocalizations.of(context).helpPersonalizationTitle6,
          children: [
            HelpBullet(
              AppLocalizations.of(context).helpPersonalizationBullet13,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpPersonalizationBullet14,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpPersonalizationBullet15,
            ),
            HelpBullet(
              AppLocalizations.of(context).helpPersonalizationBullet16,
            ),
          ],
        ),

        const SizedBox(height: 8),
        HelpFooter(AppLocalizations.of(context).helpPersonalizationFooter),
      ],
    );
  }
}
