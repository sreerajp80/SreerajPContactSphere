// lib/screens/duplicates_screen.dart
//
// Find-duplicates screen. Ported from sample/FindDuplicatesScreen.dc.html:
// a summary banner, one card per duplicate set (reason header + count badge,
// contact rows with a KEEP badge and an include/exclude checkbox, a per-set
// footer with a "Keeping 1 · merging N" note and a Merge button) and a sticky
// "Merge all sets" bottom bar. The kept contact is fixed to the best candidate;
// tapping a non-kept row toggles whether it is merged. Styled with the same
// token system as the Add-contact screen (AppColors + ColorScheme) so it renders
// on-brand in Calm (light) and Midnight (dark) — no hardcoded palette.

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Design tokens resolved from the active theme, mirroring the mockup's CSS vars.
class _Tokens {
  final Color bg;
  final Color card;
  final Color field;
  final Color fieldBorder;
  final Color text;
  final Color sub;
  final Color caption;
  final Color accent;
  final Color accentSoft;
  final Color accentText;
  final Color accentBorder;
  final Color keepBg;
  final Color onAccent;
  final Gradient avatar;
  final List<BoxShadow> shadow;

  const _Tokens({
    required this.bg,
    required this.card,
    required this.field,
    required this.fieldBorder,
    required this.text,
    required this.sub,
    required this.caption,
    required this.accent,
    required this.accentSoft,
    required this.accentText,
    required this.accentBorder,
    required this.keepBg,
    required this.onAccent,
    required this.avatar,
    required this.shadow,
  });

  factory _Tokens.of(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final scheme = theme.colorScheme;
    final isDark = colors.isDark;
    final accent = scheme.primary;

    return _Tokens(
      bg: theme.scaffoldBackgroundColor,
      card: colors.cardSurface,
      field: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
      fieldBorder: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : const Color(0xFF0F2A28).withValues(alpha: 0.12),
      text: scheme.onSurface,
      sub: colors.mutedText,
      caption: colors.mutedText.withValues(alpha: 0.9),
      accent: accent,
      accentSoft: accent.withValues(alpha: isDark ? 0.15 : 0.10),
      accentText: _shiftLightness(accent, isDark ? 0.12 : -0.06),
      accentBorder: accent.withValues(alpha: isDark ? 0.22 : 0.16),
      keepBg: accent.withValues(alpha: isDark ? 0.18 : 0.13),
      onAccent: AppTheme.contrastOn(accent),
      avatar: colors.brandGradient,
      shadow: [
        BoxShadow(
          color: accent.withValues(alpha: isDark ? 0.30 : 0.22),
          blurRadius: isDark ? 34 : 26,
          offset: const Offset(0, 14),
          spreadRadius: -14,
        ),
      ],
    );
  }

  static Color _shiftLightness(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }
}

/// A duplicate set with its mutable UI selection. [keptId] starts on the set's
/// first (best) candidate but the user can re-point it to any member — people can
/// share a name without sharing a phone number, so the default keep isn't always
/// the right survivor. [excluded] holds the non-kept members the user has turned
/// off, so everything else in the set is merged into the kept one.
class _DupSet {
  final List<Contact> contacts;
  final String reason;
  final Map<int, String> details;

  /// True when members share a phone number. Name-only sets ([false]) start with
  /// every non-kept member excluded, and keep that "default off" stance when the
  /// kept contact is re-pointed (see [keep]).
  final bool linkedByPhone;
  int keptId;
  final Set<int> excluded = {};

  _DupSet(DuplicateSet set)
    : contacts = set.contacts,
      reason = set.reason,
      details = set.details,
      linkedByPhone = set.linkedByPhone,
      keptId = set.contacts.first.id! {
    // A set linked only by name (no shared phone number) may well be different
    // people who share a name, so start every non-kept member unticked — the
    // user opts them in deliberately. Phone-linked sets stay ticked.
    if (!linkedByPhone) {
      for (final c in contacts) {
        final id = c.id;
        if (id != null && id != keptId) excluded.add(id);
      }
    }
  }

  /// Makes [id] the contact to keep. A kept row can't also be excluded. For a
  /// phone-linked set the previously-kept row folds back into the merge (it is no
  /// longer [keptId], and [mergeIds] only skips [keptId]); for a name-only set the
  /// old keep is pushed to excluded instead, preserving the set's "default off"
  /// stance so switching keep never silently ticks a different person for merge.
  void keep(int id) {
    if (id == keptId) return;
    if (!linkedByPhone) excluded.add(keptId);
    keptId = id;
    excluded.remove(id);
  }

  /// The subtitle line for a member contact, precomputed by the repository.
  String detailFor(Contact c) {
    final id = c.id;
    return id == null ? 'No phone' : (details[id] ?? 'No phone');
  }

  /// Ids folded into [keptId] on merge: every non-kept, non-excluded member.
  List<int> get mergeIds => [
    for (final c in contacts)
      if (c.id != null && c.id != keptId && !excluded.contains(c.id)) c.id!,
  ];
}

class DuplicatesScreen extends StatefulWidget {
  const DuplicatesScreen({super.key});

  @override
  State<DuplicatesScreen> createState() => _DuplicatesScreenState();
}

class _DuplicatesScreenState extends State<DuplicatesScreen> {
  final _repository = ContactRepository();
  final _syncService = ContactSyncService();
  // Own messenger so this screen's SnackBars are scoped to its route and vanish
  // when it is popped, instead of leaking onto the Contacts screen behind it.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  List<_DupSet> _sets = [];
  bool _loading = true;
  double _scanTurns = 0;

  late _Tokens _t;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _scanTurns += 1;
    });
    try {
      final groups = await _repository.findDuplicateGroups();
      if (!mounted) return;
      setState(() {
        _sets = groups.map(_DupSet.new).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Failed to find duplicates: $e');
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    _messengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  int get _totalMerging =>
      _sets.fold(0, (sum, set) => sum + set.mergeIds.length);

  Future<void> _mergeSet(_DupSet set) async {
    final ids = set.mergeIds;
    if (ids.isEmpty) return;
    final ok = await _confirm(
      'Merge this set?',
      'Keep the selected contact and merge ${ids.length} other'
          '${ids.length == 1 ? '' : 's'} into it. This cannot be undone.',
    );
    if (ok != true) return;
    try {
      await _syncService.mergeContacts(set.keptId, ids);
      _showMessage('Merged ${ids.length} contact${ids.length == 1 ? '' : 's'}');
      await _load();
    } catch (e) {
      _showMessage('Merge failed: $e');
    }
  }

  Future<void> _mergeAll() async {
    final pending = [
      for (final set in _sets)
        if (set.mergeIds.isNotEmpty) set,
    ];
    final total = _totalMerging;
    if (pending.isEmpty) {
      _showMessage('Nothing selected to merge');
      return;
    }
    final ok = await _confirm(
      'Merge all sets?',
      'Resolve ${pending.length} set${pending.length == 1 ? '' : 's'}, merging '
          '$total contact${total == 1 ? '' : 's'} into their kept ones. '
          'This cannot be undone.',
    );
    if (ok != true) return;
    try {
      for (final set in pending) {
        await _syncService.mergeContacts(set.keptId, set.mergeIds);
      }
      _showMessage('Merged $total contact${total == 1 ? '' : 's'}');
      await _load();
    } catch (e) {
      _showMessage('Merge failed: $e');
    }
  }

  Future<bool?> _confirm(String title, String body) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Merge'),
          ),
        ],
      ),
    );
  }

  // ----- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _t = _Tokens.of(context);
    final hasSets = _sets.isNotEmpty;
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: _t.bg,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  _topBar(),
                  _summary(),
                  Expanded(
                    child: _loading
                        ? Center(
                            child: CircularProgressIndicator(color: _t.accent),
                          )
                        : ListView(
                            padding: EdgeInsets.fromLTRB(
                              18,
                              2,
                              18,
                              hasSets ? 108 : 24,
                            ),
                            children: [
                              for (final set in _sets) ...[
                                _setCard(set),
                                const SizedBox(height: 16),
                              ],
                              if (!hasSets) _allDone(),
                            ],
                          ),
                  ),
                ],
              ),
              if (hasSets && !_loading)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _stickyFooter(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIconButton(
            icon: Icons.arrow_back,
            background: Colors.transparent,
            foreground: _t.text,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Text(
            'Find duplicates',
            style: TextStyle(
              color: _t.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          Material(
            color: _t.accentSoft,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _loading ? null : _load,
              child: SizedBox(
                width: 40,
                height: 40,
                child: AnimatedRotation(
                  turns: _scanTurns,
                  duration: const Duration(milliseconds: 600),
                  child: Icon(Icons.refresh, size: 20, color: _t.accent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    final n = _sets.length;
    final headline = _loading
        ? 'Scanning…'
        : n > 0
        ? '$n duplicate ${n == 1 ? 'set' : 'sets'} found'
        : 'No duplicates';
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _t.accentSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _t.accentBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _t.accent,
                borderRadius: BorderRadius.circular(13),
                boxShadow: _t.shadow,
              ),
              child: Icon(Icons.copy_all_rounded, size: 21, color: _t.onAccent),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: TextStyle(
                      color: _t.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Tap a contact to choose which to keep; untick the rest.',
                    style: TextStyle(
                      color: _t.caption,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _allDone() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 10),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _t.accentSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.check_circle_outline, size: 30, color: _t.accent),
          ),
          const SizedBox(height: 12),
          Text(
            'All cleaned up',
            style: TextStyle(
              color: _t.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No more duplicate contacts. Your address book is tidy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _t.caption,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ----- set card ------------------------------------------------------------

  Widget _setCard(_DupSet set) {
    return Container(
      decoration: BoxDecoration(
        color: _t.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _t.fieldBorder),
        boxShadow: _t.shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _setHeader(set),
          for (int i = 0; i < set.contacts.length; i++)
            _contactRow(set, set.contacts[i], first: i == 0),
          _setFooter(set),
        ],
      ),
    );
  }

  Widget _setHeader(_DupSet set) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 11),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _t.fieldBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _t.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                set.reason,
                style: TextStyle(
                  color: _t.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _t.accentSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${set.contacts.length} contacts',
              style: TextStyle(
                color: _t.accentText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(_DupSet set, Contact c, {required bool first}) {
    final id = c.id;
    final kept = id != null && id == set.keptId;
    final merging = !kept && id != null && !set.excluded.contains(id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Tapping the row body chooses this contact as the one to keep.
      onTap: kept || id == null ? null : () => setState(() => set.keep(id)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: kept ? _t.accentSoft : Colors.transparent,
          border: Border(
            top: BorderSide(color: first ? Colors.transparent : _t.fieldBorder),
          ),
        ),
        child: Row(
          children: [
            _avatar(c),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          c.fullName.isEmpty ? 'Unnamed' : c.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _t.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (kept) ...[const SizedBox(width: 8), _keepBadge()],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    set.detailFor(c),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _t.sub,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // The checkbox toggles whether a non-kept row is merged or left
            // alone; the kept row's control is a non-interactive filled circle.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: kept || id == null
                  ? null
                  : () => setState(() {
                      if (!set.excluded.remove(id)) set.excluded.add(id);
                    }),
              child: _selectionControl(kept: kept, merging: merging),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keepBadge() {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 7, 3),
      decoration: BoxDecoration(
        color: _t.keepBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 10, color: _t.accent),
          const SizedBox(width: 3),
          Text(
            'KEEP',
            style: TextStyle(
              color: _t.accent,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// The right-hand indicator: a filled circle for the kept contact, a filled
  /// square tick for a merging row, an empty square for an excluded one.
  Widget _selectionControl({required bool kept, required bool merging}) {
    final on = kept || merging;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: on ? _t.accent : Colors.transparent,
        shape: kept ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: kept ? null : BorderRadius.circular(8),
        border: Border.all(color: on ? _t.accent : _t.fieldBorder, width: 2),
      ),
      child: on
          ? Icon(Icons.check, size: 14, color: _t.onAccent)
          : const SizedBox.shrink(),
    );
  }

  Widget _setFooter(_DupSet set) {
    final n = set.mergeIds.length;
    final enabled = n > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 11, 15, 13),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _t.fieldBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              enabled ? 'Keeping 1 · merging $n' : 'Nothing selected',
              style: TextStyle(
                color: _t.caption,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: enabled ? () => _mergeSet(set) : null,
            child: Opacity(
              opacity: enabled ? 1 : 0.6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: enabled ? _t.accent : _t.field,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.merge,
                      size: 14,
                      color: enabled ? _t.onAccent : _t.caption,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Merge',
                      style: TextStyle(
                        color: enabled ? _t.onAccent : _t.caption,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stickyFooter() {
    final total = _totalMerging;
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        14,
        18,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [_t.bg, _t.bg, _t.bg.withValues(alpha: 0)],
          stops: const [0, 0.62, 1],
        ),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$total',
                style: TextStyle(
                  color: _t.text,
                  fontSize: 15,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'to merge',
                style: TextStyle(
                  color: _t.caption,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: total > 0 ? _mergeAll : null,
              child: Opacity(
                opacity: total > 0 ? 1 : 0.6,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: _t.accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _t.shadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.merge, size: 18, color: _t.onAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Merge all sets',
                        style: TextStyle(
                          color: _t.onAccent,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(Contact c) {
    final hasPhoto = c.photoPath != null && File(c.photoPath!).existsSync();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: hasPhoto ? null : _t.avatar,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.file(File(c.photoPath!), fit: BoxFit.cover)
          : Center(
              child: Text(
                _initials(c),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required Color background,
    required Color foreground,
    VoidCallback? onTap,
  }) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 22, color: foreground),
        ),
      ),
    );
  }

  String _initials(Contact c) {
    final f = c.firstName.trim();
    final l = (c.lastName ?? '').trim();
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    final s = '$a$b'.toUpperCase();
    return s.isEmpty ? '?' : s;
  }
}
