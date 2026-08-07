// lib/screens/contacts_settings_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/device_contact_service.dart';
import 'package:smart_contacts_dialer/services/export_import_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/screens/blocked_numbers_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_sync_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/relationship_names_screen.dart';

/// Contacts-related settings, reached from Settings → Contacts. Hosts "Add Me"
/// (a shortcut to the phone owner's own Self contact) and the secret-contact
/// export controls.
class ContactsSettingsScreen extends StatelessWidget {
  const ContactsSettingsScreen({super.key});

  /// Opens the Self contact for editing if one exists (Self is a singleton),
  /// otherwise opens the Add screen in self mode to create it.
  Future<void> _addMe(BuildContext context) async {
    Contact? self;
    try {
      self = await ContactSyncService().selfContact();
    } catch (_) {
      // Fall through to creating a new Self record.
    }
    if (!context.mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => self != null
            ? AddEditContactScreen(contact: self)
            : const AddEditContactScreen(initialIsSelf: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const _ContactCountsCard(),
          const SizedBox(height: 12),
          const _SearchIndexCard(),
          const SizedBox(height: 12),
          _AddMeCard(onTap: () => _addMe(context)),
          const SizedBox(height: 12),
          const _SyncCard(),
          const SizedBox(height: 12),
          const _BlockedNumbersCard(),
          const SizedBox(height: 12),
          const _RelationshipNamesCard(),
          const SizedBox(height: 12),
          const _SortOrderCard(),
          const SizedBox(height: 12),
          const _NameFormatCard(),
          const SizedBox(height: 12),
          const _HideWithoutPhoneCard(),
          const SizedBox(height: 12),
          const _IncludeSecretInExportCard(),
          const SizedBox(height: 12),
          const _ExportSecretContactsCard(),
        ],
      ),
    );
  }
}

/// Read-only summary at the top of the screen: how many contacts live on the
/// phone versus in the app. The device count uses the light fetch (no photos)
/// and can be null when the contacts permission is missing — the card then shows
/// a tappable hint to grant it. Reloads whenever a sync/mirror/restore changes
/// the numbers (via [ContactSyncService.onSyncCompleted]).
class _ContactCountsCard extends StatefulWidget {
  const _ContactCountsCard();

  @override
  State<_ContactCountsCard> createState() => _ContactCountsCardState();
}

class _ContactCountsCardState extends State<_ContactCountsCard> {
  int? _appCount;
  int? _deviceCount; // null = unknown (no permission or not yet loaded/failed)
  bool _loading = true;
  StreamSubscription<int>? _sub;

  @override
  void initState() {
    super.initState();
    _load();
    _sub = ContactSyncService().onSyncCompleted.listen((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    int? app;
    int? device;
    try {
      app = await ContactSyncService().contactCount(includeSecret: true);
    } catch (_) {
      app = null;
    }
    try {
      device = await DeviceContactService().deviceContactCount();
    } catch (_) {
      device = null;
    }
    if (!mounted) return;
    setState(() {
      _appCount = app;
      _deviceCount = device;
      _loading = false;
    });
  }

  Future<void> _requestPermission() async {
    await DeviceContactService().ensurePermission();
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    final needsPermission = !_loading && _deviceCount == null;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: needsPermission ? _requestPermission : _load,
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
                child: Icon(Icons.groups_outlined, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact counts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (needsPermission)
                      Text(
                        'Grant contacts permission to count device contacts',
                        style: TextStyle(color: colors.mutedText, fontSize: 13),
                      )
                    else
                      Text(
                        'Device: ${_countText(_deviceCount)}  ·  '
                        'App: ${_countText(_appCount)}',
                        style: TextStyle(color: colors.mutedText, fontSize: 13),
                      ),
                  ],
                ),
              ),
              if (_loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: accent,
                  ),
                )
              else if (needsPermission)
                Icon(Icons.chevron_right, color: colors.mutedText)
              else
                Icon(Icons.refresh, color: colors.mutedText),
            ],
          ),
        ),
      ),
    );
  }

  /// A count as text, or an em dash when it is unknown.
  static String _countText(int? count) => count?.toString() ?? '—';
}

/// Health + repair for the contact search index.
///
/// Name search does not read names directly — it reads two keys derived from
/// each name (`name_translit`, `name_phonetic`) and stored on the row. If a
/// stored key ever drifts from the name it came from, that contact silently
/// stops being findable, which is exactly the bug this card exists to catch.
/// The card compares every stored key against a fresh computation and offers a
/// one-tap rebuild, so a future drift is a button press instead of an app
/// update.
class _SearchIndexCard extends StatefulWidget {
  const _SearchIndexCard();

  @override
  State<_SearchIndexCard> createState() => _SearchIndexCardState();
}

class _SearchIndexCardState extends State<_SearchIndexCard> {
  int? _stale; // null = not known yet (still checking, or the check failed)
  bool _checking = true;
  bool _rebuilding = false;
  StreamSubscription<int>? _sub;

  @override
  void initState() {
    super.initState();
    _check();
    // A sync or restore writes contact rows, so re-check when one finishes.
    _sub = ContactSyncService().onSyncCompleted.listen((_) {
      if (mounted) _check();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (mounted) setState(() => _checking = true);
    int? stale;
    try {
      final db = await DatabaseHelper().database;
      stale = await DatabaseHelper().staleContactSearchKeyCount(db);
    } catch (_) {
      stale = null; // shown as "couldn't check"
    }
    if (!mounted) return;
    setState(() {
      _stale = stale;
      _checking = false;
    });
  }

  Future<void> _rebuild() async {
    setState(() => _rebuilding = true);
    int? changed;
    try {
      final db = await DatabaseHelper().database;
      changed = await DatabaseHelper().rebuildContactSearchKeys(db);
    } catch (_) {
      changed = null;
    }
    if (!mounted) return;
    setState(() => _rebuilding = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          changed == null
              ? 'Could not rebuild the search index'
              : changed == 0
              ? 'Search index was already up to date'
              : 'Search index rebuilt — $changed '
                    '${changed == 1 ? 'contact' : 'contacts'} updated',
        ),
      ),
    );
    await _check();
  }

  String get _statusText {
    if (_checking) return 'Checking…';
    final stale = _stale;
    if (stale == null) return 'Could not check the search index';
    if (stale == 0) return 'Search index is up to date';
    return '$stale ${stale == 1 ? 'contact has' : 'contacts have'} '
        'out-of-date search keys';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final needsWork = _stale != null && _stale! > 0;
    const warn = Color(0xFFF59E0B);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (needsWork ? warn : accent).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                needsWork ? Icons.error_outline : Icons.manage_search,
                color: needsWork ? warn : accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search index',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusText,
                    style: TextStyle(
                      color: needsWork ? warn : colors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rebuild this if a contact you know exists does not come '
                    'up in search.',
                    style: TextStyle(color: colors.mutedText, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (_rebuilding)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: accent,
                ),
              )
            else
              TextButton(
                onPressed: _checking ? null : _rebuild,
                child: const Text('Rebuild'),
              ),
          ],
        ),
      ),
    );
  }
}

/// The "Add Me" action card, styled like the Settings hub cards.
class _AddMeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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
                child: Icon(Icons.person_add_alt_1_outlined, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Me',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add or edit your own contact details',
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
}

/// Navigation card opening the dedicated Sync screen, which groups the four
/// contact sync actions (merge + destructive mirror, both directions) and the
/// two call-log import actions.
class _SyncCard extends StatelessWidget {
  const _SyncCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ContactSyncSettingsScreen()),
        ),
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
                child: Icon(Icons.sync_outlined, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sync',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sync contacts and call log with the device',
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
}

/// Routes to the blocked-numbers management screen (numbers that never ring,
/// plus the unknown-caller block toggle).
class _BlockedNumbersCard extends StatelessWidget {
  const _BlockedNumbersCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BlockedNumbersScreen())),
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
                child: Icon(Icons.block_outlined, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blocked numbers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Numbers that can’t call or ring you',
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
}

/// Routes to the relationship-names management screen (the editable list of
/// names offered when linking two contacts).
class _RelationshipNamesCard extends StatelessWidget {
  const _RelationshipNamesCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RelationshipNamesScreen()),
        ),
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
                child: Icon(Icons.people_alt_outlined, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Relationship names',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Edit the names offered when linking contacts',
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
}

/// Chooser card: how the contacts list is sorted (first name / last name).
class _SortOrderCard extends StatelessWidget {
  const _SortOrderCard();

  static String _labelFor(ContactSortOrder order) =>
      order == ContactSortOrder.lastName ? 'Last name' : 'First name';

  Future<void> _choose(BuildContext context, ContactSortOrder current) async {
    final chosen = await showDialog<ContactSortOrder>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Sort contacts by'),
        children: [
          for (final order in ContactSortOrder.values)
            _ChoiceTile(
              selected: order == current,
              title: _labelFor(order),
              onTap: () => Navigator.of(ctx).pop(order),
            ),
        ],
      ),
    );
    if (chosen != null && context.mounted) {
      context.read<AppSettings>().setContactSortOrder(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<AppSettings>().contactSortOrder;
    return _ChooserCard(
      icon: Icons.sort_by_alpha,
      title: 'Sort by',
      subtitle: _labelFor(order),
      onTap: () => _choose(context, order),
    );
  }
}

/// Chooser card: how a contact's name is arranged (First Last / Last, First).
class _NameFormatCard extends StatelessWidget {
  const _NameFormatCard();

  static String _labelFor(NameDisplayFormat format) =>
      format == NameDisplayFormat.lastFirst ? 'Last, First' : 'First Last';

  Future<void> _choose(BuildContext context, NameDisplayFormat current) async {
    final chosen = await showDialog<NameDisplayFormat>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Name display format'),
        children: [
          for (final format in NameDisplayFormat.values)
            _ChoiceTile(
              selected: format == current,
              title: _labelFor(format),
              onTap: () => Navigator.of(ctx).pop(format),
            ),
        ],
      ),
    );
    if (chosen != null && context.mounted) {
      context.read<AppSettings>().setNameDisplayFormat(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = context.watch<AppSettings>().nameDisplayFormat;
    return _ChooserCard(
      icon: Icons.badge_outlined,
      title: 'Name format',
      subtitle: _labelFor(format),
      onTap: () => _choose(context, format),
    );
  }
}

/// Switch card: whether contacts with no phone number are hidden from the list.
class _HideWithoutPhoneCard extends StatelessWidget {
  const _HideWithoutPhoneCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final settings = context.watch<AppSettings>();

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => settings.setHideContactsWithoutPhone(
          !settings.hideContactsWithoutPhone,
        ),
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
                child: Icon(Icons.phone_disabled_outlined, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hide contacts without a number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Only show contacts that have a phone number',
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.hideContactsWithoutPhone,
                onChanged: settings.setHideContactsWithoutPhone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A settings card that shows the current value and opens a chooser on tap,
/// styled like the other cards on this screen.
class _ChooserCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChooserCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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
                child: Icon(icon, color: accent),
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
}

/// A single selectable row in a chooser dialog on this screen, with a leading
/// check on the current selection.
class _ChoiceTile extends StatelessWidget {
  final bool selected;
  final String title;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? accent : colors.mutedText,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Switch card: whether the regular Export CSV / Export vCard actions include
/// secret contacts.
class _IncludeSecretInExportCard extends StatelessWidget {
  const _IncludeSecretInExportCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final settings = context.watch<AppSettings>();

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            settings.setIncludeSecretInExport(!settings.includeSecretInExport),
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
                child: Icon(Icons.lock_outline, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Include secret contacts in export',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Export CSV and Export vCard also contain your '
                      'secret contacts',
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.includeSecretInExport,
                onChanged: settings.setIncludeSecretInExport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action card exporting only the secret contacts (CSV or vCard). Disabled
/// while "Include secret contacts in export" is on, since the regular export
/// already covers them. Requires device authentication before exporting.
class _ExportSecretContactsCard extends StatelessWidget {
  const _ExportSecretContactsCard();

  Future<void> _export(BuildContext context, {required bool asVcf}) async {
    void showMessage(String msg) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    final ok = await AuthService().authenticate(
      reason: 'Authenticate to export secret contacts',
    );
    if (!ok) {
      showMessage('Authentication required to export secret contacts');
      return;
    }

    try {
      final service = ExportImportService();
      await (asVcf
          ? service.exportSecretContactsVcf()
          : service.exportSecretContacts());
    } on StateError {
      showMessage('No secret contacts to export');
    } catch (e) {
      showMessage('Export failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final includeInRegular = context.watch<AppSettings>().includeSecretInExport;
    final enabled = !includeInRegular;
    final titleColor = enabled ? null : colors.mutedText;
    final iconColor = enabled ? accent : colors.mutedText;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.ios_share_outlined, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export secret contacts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        enabled
                            ? 'Export only your secret contacts as a '
                                  'CSV or vCard file'
                            : 'Not needed — secret contacts are already '
                                  'included in the regular export',
                        style: TextStyle(color: colors.mutedText, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: enabled
                        ? () => _export(context, asVcf: false)
                        : null,
                    child: const Text('CSV'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: enabled
                        ? () => _export(context, asVcf: true)
                        : null,
                    child: const Text('vCard (.vcf)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
