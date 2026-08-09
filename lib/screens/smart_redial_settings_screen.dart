// lib/screens/smart_redial_settings_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/services/smart_redial_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Configuration screen for Smart Redial & "Reach Me" mode settings.
class SmartRedialSettingsScreen extends StatefulWidget {
  const SmartRedialSettingsScreen({super.key});

  @override
  State<SmartRedialSettingsScreen> createState() =>
      _SmartRedialSettingsScreenState();
}

class _SmartRedialSettingsScreenState
    extends State<SmartRedialSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final settings = context.watch<AppSettings>();
    final enabled = settings.smartRedialEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Redial & "Reach Me"')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          ListenableBuilder(
            listenable: SmartRedialService(),
            builder: (context, _) =>
                _smartRedialCardContent(colors, settings, enabled),
          ),
        ],
      ),
    );
  }

  Widget _smartRedialCardContent(
    AppColors colors,
    AppSettings settings,
    bool enabled,
  ) {
    final accent = Theme.of(context).colorScheme.primary;
    final activeCount = SmartRedialService().activeTasks.length;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              value: enabled,
              activeThumbColor: accent,
              onChanged: (v) =>
                  context.read<AppSettings>().setSmartRedialEnabled(v),
              title: const Text(
                'Smart Redial & "Reach Me"',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Offer 1-tap auto-retry and reach-me SMS when a call is unanswered',
                style: TextStyle(color: colors.mutedText, fontSize: 13),
              ),
            ),
            if (enabled) ...[
              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(Icons.timer_outlined, color: accent),
                title: const Text('Default retry delay'),
                trailing: Text(
                  '${settings.smartRedialDelayMinutes} min',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                onTap: () => _showDelayDialog(settings),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(Icons.message_outlined, color: accent),
                title: const Text('Preset Reach Me message'),
                subtitle: Text(
                  settings.presetReachMeMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                ),
                onTap: () => _showPresetMessageDialog(settings),
              ),
              if (activeCount > 0)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(
                    Icons.alarm_on,
                    color: Color(0xFF10B981),
                  ),
                  title: const Text('Active scheduled redials'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$activeCount active',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: _showActiveRedialsDialog,
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDelayDialog(AppSettings settings) {
    final options = [1, 3, 5, 10, 15, 30];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Default Retry Delay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mins in options)
              ListTile(
                title: Text('$mins minutes'),
                trailing: settings.smartRedialDelayMinutes == mins
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  settings.setSmartRedialDelayMinutes(mins);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showPresetMessageDialog(AppSettings settings) {
    final controller = TextEditingController(
      text: settings.presetReachMeMessage,
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Preset Reach Me Message'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your preset reach-me message...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              settings.setPresetReachMeMessage(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showActiveRedialsDialog() async {
    await SmartRedialService().refresh();
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => const _ActiveRedialsDialogContent(),
    );
  }
}

class _ActiveRedialsDialogContent extends StatefulWidget {
  const _ActiveRedialsDialogContent();

  @override
  State<_ActiveRedialsDialogContent> createState() =>
      _ActiveRedialsDialogContentState();
}

class _ActiveRedialsDialogContentState
    extends State<_ActiveRedialsDialogContent> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = SmartRedialService();
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final tasks = service.activeTasks;
        return AlertDialog(
          title: const Text('Active Auto-Redials'),
          content: tasks.isEmpty
              ? const Text('No active scheduled redials.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final t = tasks[i];
                      return ListTile(
                        title: Text(t.displayName),
                        subtitle: Text(
                          '${t.phoneNumber} · in ${t.remainingDuration.inMinutes} min',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => service.cancelTask(t.id),
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
