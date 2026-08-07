// lib/widgets/tag_actions_sheet.dart
//
// Rename / merge / delete for a single tag, shared by the Tag Cloud (long-press
// a chip) and the per-tag contact list (app-bar menu) so the two cannot drift.
//
// A tag is not a row of its own — it exists only as the tag rows on contacts —
// which shapes two things here:
//   * Rename and merge are the same write ([ContactSyncService.retagAll]); the
//     only difference is whether the target name is already in use, so the
//     rename dialog says which one is about to happen.
//   * Delete is offered but blocked while the tag still has members, since
//     deleting it would silently strip the tag from every one of them. Emptying
//     a tag (from the tag's contact list) makes it vanish on its own.
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// What the sheet actually did, for the caller to react to.
enum TagActionKind { renamed, merged, deleted }

class TagActionResult {
  final TagActionKind kind;

  /// The surviving tag name after a rename or merge; null for a delete.
  final String? newName;

  const TagActionResult({required this.kind, this.newName});
}

/// Opens the actions sheet for [tag]. [contactCount] is how many contacts carry
/// it, used to gate delete. Returns null when nothing was changed.
Future<TagActionResult?> showTagActionsSheet(
  BuildContext context, {
  required String tag,
  required int contactCount,
}) {
  return showModalBottomSheet<TagActionResult>(
    context: context,
    builder: (_) => _TagActionsSheet(tag: tag, contactCount: contactCount),
  );
}

class _TagActionsSheet extends StatefulWidget {
  final String tag;
  final int contactCount;

  const _TagActionsSheet({required this.tag, required this.contactCount});

  @override
  State<_TagActionsSheet> createState() => _TagActionsSheetState();
}

class _TagActionsSheetState extends State<_TagActionsSheet> {
  final ContactSyncService _sync = ContactSyncService();

  /// Every other tag in use, for merge targets and for telling a rename from a
  /// merge. Loaded once when the sheet opens.
  List<String> _otherTags = const [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final all = await _sync.allTagNames();
      if (!mounted) return;
      setState(
        () => _otherTags = all
            .where((t) => t.toLowerCase() != widget.tag.toLowerCase())
            .toList(),
      );
    } catch (_) {
      // Merge just stays unavailable; rename and delete still work.
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Rename, which becomes a merge when the typed name is already in use. The
  /// dialog says which, so combining two tags is never a surprise.
  Future<void> _rename() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _RenameTagDialog(tag: widget.tag, otherTags: _otherTags),
    );
    if (newName == null || !mounted) return;

    final isMerge = _otherTags.any(
      (t) => t.toLowerCase() == newName.toLowerCase(),
    );
    try {
      final changed = await _sync.retagAll(widget.tag, newName);
      if (!mounted) return;
      _showMessage(
        isMerge
            ? 'Merged into #$newName ($changed contact(s) moved)'
            : 'Renamed to #$newName',
      );
      Navigator.pop(
        context,
        TagActionResult(
          kind: isMerge ? TagActionKind.merged : TagActionKind.renamed,
          newName: newName,
        ),
      );
    } catch (e) {
      _showMessage('Could not rename: $e');
    }
  }

  /// Merge into an existing tag picked from the list. Same write as rename.
  Future<void> _merge() async {
    final target = await showDialog<String>(
      context: context,
      builder: (_) => _MergeTargetDialog(
        tag: widget.tag,
        contactCount: widget.contactCount,
        targets: _otherTags,
      ),
    );
    if (target == null || !mounted) return;
    try {
      final changed = await _sync.retagAll(widget.tag, target);
      if (!mounted) return;
      _showMessage('Merged into #$target ($changed contact(s) moved)');
      Navigator.pop(
        context,
        TagActionResult(kind: TagActionKind.merged, newName: target),
      );
    } catch (e) {
      _showMessage('Could not merge: $e');
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete #${widget.tag}?'),
        content: const Text(
          'No contact uses this tag, so nothing else changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final gone = await _sync.deleteEmptyTag(widget.tag);
      if (!mounted) return;
      if (!gone) {
        // Someone tagged a contact between the count and the tap.
        _showMessage('Tag is in use again — remove its contacts first');
        Navigator.pop(context);
        return;
      }
      _showMessage('Deleted #${widget.tag}');
      Navigator.pop(context, const TagActionResult(kind: TagActionKind.deleted));
    } catch (e) {
      _showMessage('Could not delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final inUse = widget.contactCount > 0;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '#${widget.tag}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.contactCount} contact(s)',
                style: TextStyle(fontSize: 13, color: colors.mutedText),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Rename tag'),
            onTap: _rename,
          ),
          ListTile(
            leading: const Icon(Icons.merge_type),
            title: const Text('Merge into…'),
            subtitle: _otherTags.isEmpty
                ? const Text('No other tags to merge into')
                : null,
            enabled: _otherTags.isNotEmpty,
            onTap: _otherTags.isEmpty ? null : _merge,
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: inUse ? colors.mutedText : Theme.of(context).colorScheme.error,
            ),
            title: const Text('Delete tag'),
            // Blocked while contacts carry it: deleting would strip the tag off
            // all of them at once. The hint says how to get there instead.
            subtitle: inUse
                ? Text('Remove its contacts first (${widget.contactCount})')
                : null,
            enabled: !inUse,
            onTap: inUse ? null : _delete,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Rename field that notices when the typed name already exists and switches its
/// confirm button to "Merge into …", so a merge is always a deliberate act.
class _RenameTagDialog extends StatefulWidget {
  final String tag;
  final List<String> otherTags;

  const _RenameTagDialog({required this.tag, required this.otherTags});

  @override
  State<_RenameTagDialog> createState() => _RenameTagDialogState();
}

class _RenameTagDialogState extends State<_RenameTagDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tag);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typed = _controller.text.trim();
    final clash = widget.otherTags.firstWhere(
      (t) => t.toLowerCase() == typed.toLowerCase(),
      orElse: () => '',
    );
    final isMerge = clash.isNotEmpty;
    final valid = typed.isNotEmpty;

    return AlertDialog(
      title: Text('Rename #${widget.tag}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tag name',
              prefixText: '#',
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: valid
                ? (_) => Navigator.pop(context, typed)
                : null,
          ),
          if (isMerge)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '#$clash already exists. Both tags become one.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: valid ? () => Navigator.pop(context, typed) : null,
          child: Text(isMerge ? 'Merge into #$clash' : 'Rename'),
        ),
      ],
    );
  }
}

/// Pick an existing tag to merge into, with the cost stated up front.
class _MergeTargetDialog extends StatelessWidget {
  final String tag;
  final int contactCount;
  final List<String> targets;

  const _MergeTargetDialog({
    required this.tag,
    required this.contactCount,
    required this.targets,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Merge #$tag into'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: targets.length,
          itemBuilder: (context, i) => ListTile(
            title: Text('#${targets[i]}'),
            onTap: () => Navigator.pop(context, targets[i]),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
