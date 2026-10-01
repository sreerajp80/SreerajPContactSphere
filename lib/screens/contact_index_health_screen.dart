// lib/screens/contact_index_health_screen.dart
import 'dart:async';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/device_contact_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Screen displaying contact counts (Device vs App) and search index health/rebuild tools.
class ContactIndexHealthScreen extends StatelessWidget {
  const ContactIndexHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).featureC7F4Title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const _ContactCountsCard(),
          const SizedBox(height: 12),
          const _SearchIndexCard(),
        ],
      ),
    );
  }
}

class _ContactCountsCard extends StatefulWidget {
  const _ContactCountsCard();

  @override
  State<_ContactCountsCard> createState() => _ContactCountsCardState();
}

class _ContactCountsCardState extends State<_ContactCountsCard> {
  int? _appCount;
  int? _deviceCount;
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
                    Text(
                      AppLocalizations.of(context).labelContactCounts,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (needsPermission)
                      Text(
                        AppLocalizations.of(context).descGrantContactsToCount,
                        style: TextStyle(color: colors.mutedText, fontSize: 13),
                      )
                    else
                      Text(
                        AppLocalizations.of(context).descDeviceAppCounts(
                          _countText(_deviceCount),
                          _countText(_appCount),
                        ),
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

  static String _countText(int? count) => count?.toString() ?? '—';
}

class _SearchIndexCard extends StatefulWidget {
  const _SearchIndexCard();

  @override
  State<_SearchIndexCard> createState() => _SearchIndexCardState();
}

class _SearchIndexCardState extends State<_SearchIndexCard> {
  int? _stale;
  bool _checking = true;
  bool _rebuilding = false;
  StreamSubscription<int>? _sub;

  @override
  void initState() {
    super.initState();
    _check();
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
    int staleCount = 0;
    try {
      final db = await DatabaseHelper().database;
      staleCount = await DatabaseHelper().staleContactSearchKeyCount(db);
    } catch (_) {
      staleCount = 0;
    }
    if (!mounted) return;
    setState(() {
      _stale = staleCount;
      _checking = false;
    });
  }

  Future<void> _rebuild() async {
    if (_rebuilding) return;
    setState(() => _rebuilding = true);
    try {
      final db = await DatabaseHelper().database;
      await DatabaseHelper().rebuildContactSearchKeys(db);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _rebuilding = false);
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;

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
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.manage_search_outlined, color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).labelSearchIndex,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (_checking)
                    Text(
                      AppLocalizations.of(context).msgCheckingSearchIndex,
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    )
                  else if (_stale == 0)
                    Text(
                      AppLocalizations.of(context).descIndexHealthy,
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    )
                  else
                    Text(
                      AppLocalizations.of(context).descIndexStale(_stale ?? 0),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            if (_rebuilding)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: accent,
                ),
              )
            else if (_stale != null && _stale! > 0)
              TextButton(
                onPressed: _rebuild,
                child: Text(AppLocalizations.of(context).actionRebuild),
              )
            else
              IconButton(
                icon: Icon(Icons.refresh, color: colors.mutedText),
                tooltip: AppLocalizations.of(context).tooltipCheckAgain,
                onPressed: _check,
              ),
          ],
        ),
      ),
    );
  }
}
