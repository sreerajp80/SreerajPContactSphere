// lib/screens/tag_cloud_screen.dart
//
// The "Tags" tab: every tag used across the address book, drawn as a tag cloud
// where a chip's size grows with how many contacts carry that tag. Tapping a
// tag opens [TagContactsScreen], the list of contacts with that tag.
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/repositories/contact_repository.dart'
    show TagCount;
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/tag_contacts_screen.dart';
import 'package:smart_contacts_dialer/widgets/tag_actions_sheet.dart';

class TagCloudScreen extends StatefulWidget {
  const TagCloudScreen({super.key});

  @override
  State<TagCloudScreen> createState() => TagCloudScreenState();
}

class TagCloudScreenState extends State<TagCloudScreen> {
  final ContactSyncService _sync = ContactSyncService();

  List<TagCount> _tags = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Re-queries the tags. Called by [HomeShell] when the Tags tab is selected,
  /// so tags added/removed while editing on another tab show up without leaving.
  void reload() => _load();

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      // Secret contacts stay hidden here (as elsewhere by default), so their
      // tags neither appear nor pad the counts.
      final tags = await _sync.tagCounts();
      if (!mounted) return;
      setState(() {
        _tags = tags;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tags = const [];
        _loading = false;
      });
    }
  }

  Future<void> _openTag(String tag) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TagContactsScreen(tag: tag)));
    // A contact's tags may have changed on the detail screen; refresh counts.
    if (mounted) _load();
  }

  /// Long-press a chip: rename / merge / delete that tag. Any of the three
  /// changes the counts, so reload on a non-null result.
  Future<void> _editTag(TagCount tag) async {
    final result = await showTagActionsSheet(
      context,
      tag: tag.name,
      contactCount: tag.count,
    );
    if (result != null && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(colors),
            Expanded(child: _body(colors)),
          ],
        ),
      ),
    );
  }

  Widget _header(AppColors colors) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Tags',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(AppColors colors) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_tags.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No tags yet. Add tags to a contact and they show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.mutedText, fontSize: 14),
          ),
        ),
      );
    }

    // Map each tag's contact count onto a font size so the cloud reads at a
    // glance: the least-used tag sits at [minFont], the most-used at [maxFont],
    // scaled linearly between. When every tag has the same count they all render
    // at the same middle size.
    const double minFont = 14;
    const double maxFont = 30;
    var minCount = _tags.first.count;
    var maxCount = _tags.first.count;
    for (final t in _tags) {
      if (t.count < minCount) minCount = t.count;
      if (t.count > maxCount) maxCount = t.count;
    }
    final span = maxCount - minCount;

    double fontFor(int count) {
      if (span == 0) return (minFont + maxFont) / 2;
      final f = (count - minCount) / span;
      return minFont + f * (maxFont - minFont);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Long-press is invisible without saying so.
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Tap a tag to see its contacts. Long-press to rename, merge or delete.',
              style: TextStyle(fontSize: 12, color: colors.mutedText),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final t in _tags) _chip(colors, t, fontFor(t.count)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(AppColors colors, TagCount tag, double fontSize) {
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openTag(tag.name),
        onLongPress: () => _editTag(tag),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#${tag.name}',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${tag.count}',
                style: TextStyle(
                  // Count stays legible but never dominates the tag word.
                  fontSize: (fontSize * 0.55).clamp(11, 15),
                  fontWeight: FontWeight.w600,
                  color: colors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
