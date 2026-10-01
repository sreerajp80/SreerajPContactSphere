// lib/screens/audit_log_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:smart_contacts_dialer/l10n/audit_labels.dart';
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/repositories/audit_repository.dart';
import 'package:smart_contacts_dialer/screens/audit_entry_detail_screen.dart';
import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/services/screen_security_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/l10n/formatting_locale.dart';

/// Settings → Audit Log: what changed on which contact, when, and who did it.
///
/// Entries are recorded by [ContactRepository] on every create / edit / delete,
/// each with a full before/after snapshot and SHA-256 cryptographic hash chaining
/// (`previousHash` + `currentPayload`), so history is tamper-proof and accidental
/// changes can be undone from the detail screen. Includes a 1-click Export Signed
/// Audit Log feature.
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final AuditRepository _repo = AuditRepository();
  final AuthService _auth = AuthService();

  List<AuditEntry> _entries = const [];
  bool _loading = true;
  bool _exporting = false;
  AuditChainVerificationResult? _chainResult;

  /// Null means "everything"; otherwise only this action is listed.
  AuditAction? _filter;

  /// Entries about secret contacts stay hidden until the user unlocks them,
  /// exactly as the contact list treats the contacts themselves.
  bool _showSecret = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    if (_showSecret) ScreenSecurity.release('audit_secret');
    super.dispose();
  }

  Future<void> _init() async {
    // Housekeeping happens here rather than on the write path: opening the log
    // is often enough to keep it small, and never slows down a contact save.
    try {
      await _repo.prune();
    } catch (_) {
      // Non-fatal: a log that failed to prune is still readable.
    }
    await _load();
  }

  Future<void> _load() async {
    try {
      final chain = await _repo.verifyChain();
      final entries = await _repo.entries(
        actions: _filter == null ? null : {_filter!},
        includeSecret: _showSecret,
      );
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _chainResult = chain;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _entries = const [];
        _loading = false;
      });
    }
  }

  Future<void> _toggleSecret() async {
    if (_showSecret) {
      setState(() => _showSecret = false);
      await ScreenSecurity.release('audit_secret');
      await _load();
      return;
    }
    final ok = await _auth.authenticate();
    if (!mounted) return;
    if (!ok) {
      _showMessage(AppLocalizations.of(context).errorAuthRequiredSecret);
      return;
    }
    setState(() => _showSecret = true);
    await ScreenSecurity.acquire('audit_secret');
    await _load();
  }

  Future<void> _exportSignedLog() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      await _repo.exportSignedAuditLog(includeSecret: _showSecret);
      if (mounted) {
        _showMessage(
          AppLocalizations.of(context).msgAuditExported(_entries.length),
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).errorExportFailed('$e'));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _clear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleClearAuditLog),
        content: Text(AppLocalizations.of(context).descClearAuditLog),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(context).actionClear),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _repo.clear();
    await _load();
    if (mounted) _showMessage(AppLocalizations.of(context).msgAuditCleared);
  }

  Future<void> _open(AuditEntry entry) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AuditEntryDetailScreen(entry: entry)),
    );
    if (changed == true) await _load();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).titleAuditLog),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).actionExportSignedAuditLog,
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_user_outlined),
            onPressed: _exporting ? null : _exportSignedLog,
          ),
          IconButton(
            tooltip: _showSecret
                ? AppLocalizations.of(context).tooltipHideSecret
                : AppLocalizations.of(context).tooltipShowSecret,
            icon: Icon(_showSecret ? Icons.lock_open : Icons.lock_outline),
            onPressed: _toggleSecret,
          ),
          PopupMenuButton<String>(
            tooltip: AppLocalizations.of(context).tooltipMore,
            onSelected: (v) {
              if (v == 'export') {
                _exportSignedLog();
              } else if (v == 'clear') {
                _clear();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.share, size: 18, color: colors.mutedText),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).actionExportSignedAuditLog,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text(AppLocalizations.of(context).actionClearLog),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _explainerNote(colors),
                const SizedBox(height: 10),
                _chainStatusBadge(colors),
                const SizedBox(height: 12),
                _filterChips(colors),
                const SizedBox(height: 12),
                if (_entries.isEmpty)
                  _emptyNote(colors)
                else
                  ..._groupedByDay(colors),
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
            Icon(Icons.history_toggle_off, color: colors.mutedText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                AppLocalizations.of(
                  context,
                ).descAuditIntro(AuditRepository.retention.inDays),
                style: TextStyle(color: colors.mutedText, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chainStatusBadge(AppColors colors) {
    final valid = _chainResult?.isValid ?? true;
    final verified = _chainResult?.verifiedEntries ?? 0;
    final total = _chainResult?.totalEntries ?? 0;

    return Card(
      margin: EdgeInsets.zero,
      color: valid
          ? Colors.green.withValues(alpha: 0.08)
          : Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              valid ? Icons.security : Icons.gpp_maybe,
              color: valid ? Colors.green : Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                valid
                    ? AppLocalizations.of(
                        context,
                      ).descChainVerified(verified, total)
                    : AppLocalizations.of(
                        context,
                      ).descChainTampered('${_chainResult?.firstTamperedId}'),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: valid
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.greenAccent
                            : Colors.green.shade800)
                      : Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChips(AppColors colors) {
    Widget chip(String label, AuditAction? action) {
      final selected = _filter == action;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) {
            setState(() {
              _filter = action;
              _loading = true;
            });
            _load();
          },
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(AppLocalizations.of(context).labelAll, null),
          chip(
            AppLocalizations.of(context).labelAuditAdded,
            AuditAction.create,
          ),
          chip(
            AppLocalizations.of(context).labelAuditEdited,
            AuditAction.update,
          ),
          chip(
            AppLocalizations.of(context).labelAuditDeleted,
            AuditAction.delete,
          ),
        ],
      ),
    );
  }

  Widget _emptyNote(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        _filter == null
            ? AppLocalizations.of(context).emptyAuditNothing
            : AppLocalizations.of(context).emptyAuditFilter,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.mutedText, fontSize: 13.5),
      ),
    );
  }

  /// The list, split into one card per day, newest day first.
  List<Widget> _groupedByDay(AppColors colors) {
    final out = <Widget>[];
    final byDay = <String, List<AuditEntry>>{};
    for (final e in _entries) {
      final key = DateFormat('yyyy-MM-dd').format(e.changedAt);
      (byDay[key] ??= <AuditEntry>[]).add(e);
    }
    for (final day in byDay.keys) {
      final entries = byDay[day]!;
      out.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Text(
                    _dayLabel(entries.first.changedAt),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                for (final entry in entries) _entryTile(colors, entry),
              ],
            ),
          ),
        ),
      );
    }
    return out;
  }

  Widget _entryTile(AppColors colors, AuditEntry entry) {
    final style = auditActionStyle(entry.action, Theme.of(context).colorScheme);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: style.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(style.icon, color: style.color, size: 20),
      ),
      title: Text(
        entry.contactName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${auditActionLabel(AppLocalizations.of(context), entry.action)} · '
        '${DateFormat.jm(_formatLocale).format(entry.changedAt)}\n'
        '${entry.summary}',
        style: TextStyle(color: colors.mutedText, fontSize: 12.5),
      ),
      isThreeLine: true,
      trailing: Icon(Icons.chevron_right, color: colors.mutedText),
      onTap: () => _open(entry),
    );
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(day.year, day.month, day.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return AppLocalizations.of(context).labelToday;
    if (diff == 1) return AppLocalizations.of(context).labelYesterday;
    return DateFormat('d MMMM yyyy', _formatLocale).format(day);
  }

  /// intl locale for display dates; Sanskrit falls back to English patterns.
  String get _formatLocale => formattingLocale(Localizations.localeOf(context));
}

/// Icon + colour for an action, shared by the list and the detail screen so
/// both draw the same badge.
({IconData icon, Color color}) auditActionStyle(
  AuditAction action,
  ColorScheme scheme,
) => switch (action) {
  AuditAction.create => (icon: Icons.person_add_alt, color: scheme.primary),
  AuditAction.update => (icon: Icons.edit_outlined, color: scheme.tertiary),
  AuditAction.delete => (icon: Icons.delete_outline, color: scheme.error),
};
