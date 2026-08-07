// lib/screens/audit_entry_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/screens/audit_log_screen.dart'
    show auditActionStyle;
import 'package:smart_contacts_dialer/screens/contact_detail_screen.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// One audit entry in full: what changed, who changed it, when — and the Undo
/// button that puts it back.
///
/// Pops with `true` when something was undone, so the list behind it reloads.
class AuditEntryDetailScreen extends StatefulWidget {
  final AuditEntry entry;

  const AuditEntryDetailScreen({super.key, required this.entry});

  @override
  State<AuditEntryDetailScreen> createState() => _AuditEntryDetailScreenState();
}

class _AuditEntryDetailScreenState extends State<AuditEntryDetailScreen> {
  final ContactRepository _contacts = ContactRepository();

  bool _busy = false;

  /// True once this entry has been undone, so the button can't be pressed twice.
  bool _undone = false;

  AuditEntry get _entry => widget.entry;

  Future<void> _undo() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Undo this change?'),
        content: Text(_entry.undoDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Undo'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      final contactId = await _contacts.undoAudit(_entry);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _undone = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            contactId == null ? 'Contact removed again' : 'Change undone',
          ),
        ),
      );
    } on StateError catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Undo failed: $e')));
    }
  }

  Future<void> _openContact() async {
    final id = _entry.contactId;
    if (id == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ContactDetailScreen(contactId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final changes = _entry.changes;
    return PopScope(
      canPop: !_busy,
      onPopInvokedWithResult: (didPop, _) {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Change details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _busy
                ? null
                : () => Navigator.of(context).pop(_undone),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _headerCard(colors),
            const SizedBox(height: 12),
            if (_entry.action == AuditAction.update && changes.isEmpty)
              _note(
                colors,
                'No field visible in the log is different. The change was '
                'recorded because something was written to this contact.',
              )
            else if (changes.isNotEmpty)
              _changesCard(colors, changes),
            const SizedBox(height: 12),
            _undoCard(colors),
            if (_entry.contactId != null &&
                _entry.action != AuditAction.delete) ...[
              const SizedBox(height: 12),
              _openContactCard(colors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerCard(AppColors colors) {
    final style = auditActionStyle(_entry.action, Theme.of(context).colorScheme);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(style.icon, color: style.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _entry.contactName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_entry.action.label} · ${_entry.source.label}',
                    style: TextStyle(color: colors.mutedText, fontSize: 13),
                  ),
                  Text(
                    DateFormat(
                      'd MMMM yyyy, h:mm a',
                    ).format(_entry.changedAt),
                    style: TextStyle(color: colors.mutedText, fontSize: 13),
                  ),
                  if (_entry.summary.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(_entry.summary, style: const TextStyle(fontSize: 13.5)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _changesCard(AppColors colors, List<FieldChange> changes) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What changed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            for (final change in changes) _changeRow(colors, change),
          ],
        ),
      ),
    );
  }

  Widget _changeRow(AppColors colors, FieldChange change) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            change.label,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _valueBlock(colors, 'Before', change.before, faded: true),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: colors.mutedText,
                ),
              ),
              Expanded(
                child: _valueBlock(colors, 'After', change.after),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueBlock(
    AppColors colors,
    String label,
    String value, {
    bool faded = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.mutedText),
        ),
        Text(
          value.isEmpty ? '—' : value,
          style: TextStyle(
            fontSize: 13.5,
            color: faded ? colors.mutedText : null,
          ),
        ),
      ],
    );
  }

  Widget _undoCard(AppColors colors) {
    final canUndo = _entry.canUndo && !_undone;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Undo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _undone
                  ? 'This change has been undone. The undo itself is recorded '
                        'as a new entry.'
                  : _entry.canUndo
                  ? _entry.undoDescription
                  : 'This entry cannot be undone — it has no saved copy of the '
                        'earlier version.',
              style: TextStyle(color: colors.mutedText, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canUndo && !_busy ? _undo : null,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.undo),
                label: Text(_undone ? 'Undone' : 'Undo this change'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _openContactCard(AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: const Icon(Icons.person_outline),
        title: const Text('Open this contact'),
        subtitle: Text(
          'See the contact as it is now',
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right, color: colors.mutedText),
        onTap: _openContact,
      ),
    );
  }

  Widget _note(AppColors colors, String text) {
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
