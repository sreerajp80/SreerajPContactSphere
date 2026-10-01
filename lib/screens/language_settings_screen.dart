// lib/screens/language_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/state/locale_controller.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// The display name for a [LocaleController] value: the localized
/// "System default", or the language's own name in its own script (endonym).
String languageOptionLabel(AppLocalizations l10n, String value) =>
    switch (value) {
      'en' => l10n.languageNameEn,
      'ml' => l10n.languageNameMl,
      'sa' => l10n.languageNameSa,
      _ => l10n.labelSystemDefault,
    };

/// In-app language picker reached from Settings → Language (standard §8.4).
///
/// System default comes first, then each language in its own script. A tap
/// saves the choice and applies it at once through [LocaleController]; the
/// user stays on this screen and sees it redraw in the new language.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    final controller = context.watch<LocaleController>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleLanguage)),
      body: RadioGroup<String>(
        groupValue: controller.value,
        onChanged: (value) {
          if (value != null) controller.setLanguage(value);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final value in LocaleController.options)
                    RadioListTile<String>(
                      key: ValueKey('language_option_$value'),
                      value: value,
                      title: Text(
                        languageOptionLabel(l10n, value),
                        // An endonym is spoken in its own language by a screen
                        // reader, whatever language the app is in.
                        locale: value == LocaleController.systemValue
                            ? null
                            : Locale(value),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: value == LocaleController.systemValue
                          ? Text(
                              l10n.descLanguageSystemDefault,
                              style: TextStyle(
                                color: colors.mutedText,
                                fontSize: 12.5,
                              ),
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
