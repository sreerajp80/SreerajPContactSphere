// lib/screens/sync/sync_views.dart
//
// Small presentational widgets shared by the P2P sync screens (send / receive)
// so the progress, result, and info/warning cards look identical on both sides.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Centred spinner + label. [fraction] draws a determinate ring when known.
class SyncProgressView extends StatelessWidget {
  final String message;
  final double? fraction;
  const SyncProgressView({super.key, required this.message, this.fraction});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(value: fraction),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(color: colors.mutedText, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Success / failure end state with a Done button.
class SyncResultView extends StatelessWidget {
  final bool success;
  final String title;
  final String message;
  final VoidCallback onDone;

  const SyncResultView({
    super.key,
    required this.success,
    required this.title,
    required this.message,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    const green = Color(0xFF10B981);
    final color = success ? green : Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error_outline,
            color: color,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: colors.mutedText, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: onDone, child: const Text('Done')),
        ],
      ),
    );
  }
}

/// Neutral info card (icon + body text).
class SyncInfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const SyncInfoCard({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: colors.mutedText, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Amber-tinted caution card.
class SyncWarningCard extends StatelessWidget {
  final String text;
  const SyncWarningCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    return Card(
      margin: EdgeInsets.zero,
      color: amber.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: amber),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5))),
          ],
        ),
      ),
    );
  }
}

/// A centred label with a selectable value and a copy button.
class SyncLabeledValue extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const SyncLabeledValue({
    super.key,
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Column(
      children: [
        Text(label, style: TextStyle(color: colors.mutedText, fontSize: 13)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: SelectableText(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }
}
