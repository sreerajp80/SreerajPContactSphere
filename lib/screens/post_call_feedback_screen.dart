// lib/screens/post_call_feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for post-call feedback settings ("How did it go?").
class PostCallFeedbackScreen extends StatelessWidget {
  const PostCallFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final enabled = context.watch<AppSettings>().postCallFeedbackEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Post-call Options')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              value: enabled,
              activeThumbColor: accent,
              onChanged: (v) =>
                  context.read<AppSettings>().setPostCallFeedbackEnabled(v),
              title: const Text(
                'Ask after calls',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Show the “How did it go?” sheet when a call ends',
                style: TextStyle(color: colors.mutedText, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
