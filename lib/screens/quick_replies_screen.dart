// lib/screens/quick_replies_screen.dart
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Quick-reply management, reached from Settings → SIM & calling. These canned
/// messages are offered on the incoming-call screen's Reply action: picking one
/// rejects the call and the message is texted to the caller as an SMS (sent by
/// the OS on the SIM the call arrived on).
class QuickRepliesScreen extends StatefulWidget {
  const QuickRepliesScreen({super.key});

  @override
  State<QuickRepliesScreen> createState() => _QuickRepliesScreenState();
}

class _QuickRepliesScreenState extends State<QuickRepliesScreen> {
  /// Opens the add/edit dialog. When [index] is null a new reply is appended;
  /// otherwise the reply at [index] is replaced.
  Future<void> _editReply({int? index}) async {
    final settings = context.read<AppSettings>();
    final replies = settings.quickReplies;
    final controller = TextEditingController(
      text: index == null ? '' : replies[index],
    );
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          index == null
              ? AppLocalizations.of(context).titleNewQuickReply
              : AppLocalizations.of(context).titleEditQuickReply,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 160,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).labelMessage,
            hintText: AppLocalizations.of(context).hintQuickReplyExample,
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(AppLocalizations.of(context).actionSave),
          ),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    final next = List<String>.from(replies);
    if (index == null) {
      next.add(text.trim());
    } else {
      next[index] = text.trim();
    }
    await context.read<AppSettings>().setQuickReplies(next);
  }

  Future<void> _removeReply(int index) async {
    final settings = context.read<AppSettings>();
    final next = List<String>.from(settings.quickReplies)..removeAt(index);
    await settings.setQuickReplies(next);
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleResetQuickReplies),
        content: Text(AppLocalizations.of(context).descResetQuickReplies),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(context).actionReset),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AppSettings>().resetQuickReplies();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final replies = context.watch<AppSettings>().quickReplies;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).labelQuickReplies),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: AppLocalizations.of(context).tooltipResetToDefaults,
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _explainerNote(colors),
          const SizedBox(height: 12),
          _addReplyCard(colors),
          const SizedBox(height: 12),
          if (replies.isEmpty)
            _emptyNote(colors)
          else
            _repliesCard(colors, replies),
        ],
      ),
    );
  }

  Widget _explainerNote(AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colors.mutedText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                AppLocalizations.of(context).descQuickRepliesInfo,
                style: TextStyle(color: colors.mutedText, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addReplyCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _editReply(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.playlist_add, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).actionAddReply,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context).descAddReply,
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.mutedText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyNote(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        AppLocalizations.of(context).emptyNoQuickReplies,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.mutedText, fontSize: 13.5),
      ),
    );
  }

  Widget _repliesCard(AppColors colors, List<String> replies) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                AppLocalizations.of(context).labelRepliesCount(replies.length),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (var i = 0; i < replies.length; i++)
              _replyTile(colors, i, replies[i]),
          ],
        ),
      ),
    );
  }

  Widget _replyTile(AppColors colors, int index, String reply) {
    final accent = Theme.of(context).colorScheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _editReply(index: index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.sms_outlined, color: accent, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                reply,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: colors.mutedText, size: 20),
              tooltip: AppLocalizations.of(context).actionDelete,
              onPressed: () => _removeReply(index),
            ),
          ],
        ),
      ),
    );
  }
}
