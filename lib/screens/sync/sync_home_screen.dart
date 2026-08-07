// lib/screens/sync/sync_home_screen.dart
//
// "Sync to Another Device" hub, reached from Settings behind a biometric check
// (the payload can include secret contacts). Two choices: send this phone's
// data to another phone, or receive another phone's data onto this one. The
// heavy lifting lives in the two screens this pushes.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/sync/receive_from_device_screen.dart';
import 'package:smart_contacts_dialer/screens/sync/send_to_device_screen.dart';

class SyncHomeScreen extends StatelessWidget {
  const SyncHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync to Another Device')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SyncOptionCard(
            icon: Icons.upload_outlined,
            title: 'Send to Another Device',
            subtitle:
                'Share your contacts (and more) with another phone over Wi-Fi.',
            onTap: () => _push(context, const SendToDeviceScreen()),
          ),
          const SizedBox(height: 12),
          _SyncOptionCard(
            icon: Icons.download_outlined,
            title: 'Receive from Another Device',
            subtitle:
                'Add another phone\'s contacts to this phone. Nothing already '
                'here is changed or removed.',
            onTap: () => _push(context, const ReceiveFromDeviceScreen()),
          ),
          const SizedBox(height: 20),
          _footer(context),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _footer(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Text(
      'Both phones must be on the same Wi-Fi network and running this app.',
      style: TextStyle(color: colors.mutedText, fontSize: 12.5),
      textAlign: TextAlign.center,
    );
  }
}

class _SyncOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SyncOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                foregroundColor: theme.colorScheme.primary,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
