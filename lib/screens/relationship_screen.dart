// lib/screens/relationship_screen.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/relationship_repository.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/avatar_initial.dart';
import 'package:smart_contacts_dialer/widgets/relationship_editor.dart';
import 'package:smart_contacts_dialer/screens/contact_detail_screen.dart';

/// Ego-centric "relationship sphere": the focused contact sits at the centre,
/// its directly-related contacts orbit on a ring with labelled edges. Tapping an
/// orbiting contact re-centres the sphere on them (pushed, so the back button
/// unwinds the traversal). Built with [CustomPaint] for the edges and tappable
/// widgets for the nodes — no extra dependency.
class RelationshipScreen extends StatefulWidget {
  final int focusContactId;

  const RelationshipScreen({super.key, required this.focusContactId});

  @override
  State<RelationshipScreen> createState() => _RelationshipScreenState();
}

class _RelationshipScreenState extends State<RelationshipScreen> {
  final _contacts = ContactRepository();
  final _relationships = RelationshipRepository();

  Contact? _focus;
  List<RelatedContact> _relations = [];
  bool _loading = true;
  bool _groupedView = true;

  /// The relations bucketed into the seven fixed categories, in enum order.
  /// Empty categories are left out, so the ring holds between one and seven
  /// nodes however many contacts are linked.
  Map<RelationshipCategory, List<RelatedContact>> get _categoryGroups {
    final map = <RelationshipCategory, List<RelatedContact>>{};
    for (final c in RelationshipCategory.values) {
      final members = _relations.where((r) => r.category == c).toList();
      if (members.isNotEmpty) map[c] = members;
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final focus = await _contacts.getContactById(widget.focusContactId);
      final relations = await _relationships.getRelationsOf(
        widget.focusContactId,
      );
      if (!mounted) return;
      setState(() {
        _focus = focus;
        _relations = relations;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Failed to load relationships: $e');
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _addRelationship() async {
    final exclude = _relations.map((r) => r.contactId).toSet();
    final choice = await showRelationshipEditor(
      context,
      ownerContactId: widget.focusContactId,
      excludeIds: exclude,
    );
    if (choice == null) return;
    await _relationships.setRelationship(
      contactId: widget.focusContactId,
      relatedContactId: choice.relatedContactId,
      type: choice.type,
      category: choice.category,
    );
    await _load();
  }

  Future<void> _editRelationship(RelatedContact r) async {
    final edit = await showRelationshipTypePicker(
      context,
      personName: r.firstName,
      currentType: r.relationshipType,
      currentCategory: r.category,
    );
    if (edit == null) return;
    if (edit.type == r.relationshipType && edit.category == r.category) return;
    await _relationships.setRelationship(
      contactId: widget.focusContactId,
      relatedContactId: r.contactId,
      type: edit.type,
      category: edit.category,
    );
    await _load();
  }

  void _recenterOn(int contactId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RelationshipScreen(focusContactId: contactId),
      ),
    );
  }

  void _openProfile(int contactId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactDetailScreen(contactId: contactId),
      ),
    );
  }

  Future<void> _showGroupDetailsSheet(
    RelationshipCategory category,
    List<RelatedContact> contacts,
  ) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = Theme.of(context).colorScheme.primary;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.mutedText.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${category.emoji}  ${category.displayName}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${contacts.length} ${contacts.length == 1 ? 'contact' : 'contacts'})',
                    style: TextStyle(
                      color: colors.mutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final r = contacts[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      leading: _NodeAvatar(
                        initial: _initialOf(r.firstName),
                        photoPath: r.photoPath,
                        size: 42,
                        accent: accent,
                        highlight: false,
                      ),
                      title: Text(
                        r.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        r.relationshipType,
                        style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.hub_outlined, size: 20),
                            tooltip: 'Centre sphere here',
                            onPressed: () {
                              Navigator.pop(ctx);
                              _recenterOn(r.contactId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_outline, size: 20),
                            tooltip: 'Open profile',
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openProfile(r.contactId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, size: 20),
                            tooltip: 'Options',
                            onPressed: () {
                              Navigator.pop(ctx);
                              _nodeMenu(r);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _nodeMenu(RelatedContact r) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(r.fullName),
              subtitle: Text(
                '${r.relationshipType} · ${r.category.displayName}',
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.hub_outlined),
              title: const Text('Centre sphere here'),
              onTap: () => Navigator.pop(context, 'recenter'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Open profile'),
              onTap: () => Navigator.pop(context, 'profile'),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit relationship'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.link_off, color: Colors.redAccent),
              title: const Text('Remove relationship'),
              onTap: () => Navigator.pop(context, 'remove'),
            ),
          ],
        ),
      ),
    );
    switch (action) {
      case 'recenter':
        _recenterOn(r.contactId);
        break;
      case 'profile':
        _openProfile(r.contactId);
        break;
      case 'edit':
        await _editRelationship(r);
        break;
      case 'remove':
        await _relationships.removeRelationship(
          contactId: widget.focusContactId,
          relatedContactId: r.contactId,
        );
        await _load();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final focus = _focus;
    return Scaffold(
      appBar: AppBar(
        title: Text(focus?.fullName ?? 'Relationships'),
        actions: [
          if (_relations.isNotEmpty)
            IconButton(
              icon: Icon(
                _groupedView ? Icons.view_comfy_alt_outlined : Icons.workspaces_outlined,
              ),
              tooltip: _groupedView
                  ? 'View individual contacts'
                  : 'Group by category',
              onPressed: () => setState(() => _groupedView = !_groupedView),
            ),
        ],
      ),
      floatingActionButton: focus == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _addRelationship,
              icon: const Icon(Icons.add_link),
              label: const Text('Add'),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : focus == null
          ? const Center(child: Text('Contact not found'))
          : _buildSphere(context, focus),
    );
  }

  Widget _buildSphere(BuildContext context, Contact focus) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = Theme.of(context).colorScheme.primary;

    if (_relations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NodeAvatar(
              initial: _initialOf(focus.firstName),
              photoPath: focus.photoPath,
              size: 96,
              accent: accent,
              highlight: true,
            ),
            const SizedBox(height: 16),
            Text(
              'No relationships yet',
              style: TextStyle(color: colors.mutedText, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap “Add” to link a contact.',
              style: TextStyle(color: colors.mutedText, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final center = size.center(Offset.zero);
        const centerRadius = 40.0;
        const orbitRadius = 30.0;
        final ringRadius = math.max(
          70.0,
          math.min(size.width, size.height) / 2 - orbitRadius - 28,
        );

        final List<Widget> children = [];
        final List<Offset> positions = [];

        if (_groupedView) {
          final groups = _categoryGroups.entries.toList();
          final n = groups.length;
          for (var i = 0; i < n; i++) {
            final angle = (2 * math.pi * i / n) - math.pi / 2;
            positions.add(
              Offset(
                center.dx + ringRadius * math.cos(angle),
                center.dy + ringRadius * math.sin(angle),
              ),
            );
          }

          children.add(
            Positioned.fill(
              child: CustomPaint(
                painter: _EdgePainter(
                  center: center,
                  nodes: positions,
                  edgeColor: accent.withValues(alpha: 0.45),
                ),
              ),
            ),
          );

          // Centre node.
          children.add(
            _positioned(
              center,
              centerRadius,
              GestureDetector(
                onTap: () => _openProfile(focus.id!),
                child: _NodeAvatar(
                  initial: _initialOf(focus.firstName),
                  photoPath: focus.photoPath,
                  size: centerRadius * 2,
                  accent: accent,
                  highlight: true,
                ),
              ),
            ),
          );

          // Group orbit nodes.
          for (var i = 0; i < n; i++) {
            final group = groups[i];
            final category = group.key;
            final members = group.value;
            final count = members.length;
            final primaryMember = members.first;

            children.add(
              _positioned(
                positions[i],
                orbitRadius,
                GestureDetector(
                  onTap: () => _showGroupDetailsSheet(category, members),
                  onLongPress: () => _showGroupDetailsSheet(category, members),
                  child: _GroupNodeAvatar(
                    initial: _initialOf(primaryMember.firstName),
                    photoPath: primaryMember.photoPath,
                    count: count,
                    size: orbitRadius * 2,
                    accent: accent,
                  ),
                ),
              ),
            );
          }

          // Category labels at each edge midpoint.
          for (var i = 0; i < n; i++) {
            final group = groups[i];
            final category = group.key;
            final members = group.value;

            final mid = Offset(
              (center.dx + positions[i].dx) / 2,
              (center.dy + positions[i].dy) / 2,
            );
            children.add(
              Positioned(
                left: mid.dx,
                top: mid.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: _EdgeLabel(
                    text: category.displayName,
                    color: colors.mutedText,
                    background: colors.cardSurface,
                    onTap: () => _showGroupDetailsSheet(category, members),
                  ),
                ),
              ),
            );
          }
        } else {
          // Direct individual flat view.
          final n = _relations.length;
          for (var i = 0; i < n; i++) {
            final angle = (2 * math.pi * i / n) - math.pi / 2;
            positions.add(
              Offset(
                center.dx + ringRadius * math.cos(angle),
                center.dy + ringRadius * math.sin(angle),
              ),
            );
          }

          children.add(
            Positioned.fill(
              child: CustomPaint(
                painter: _EdgePainter(
                  center: center,
                  nodes: positions,
                  edgeColor: accent.withValues(alpha: 0.45),
                ),
              ),
            ),
          );

          // Centre node.
          children.add(
            _positioned(
              center,
              centerRadius,
              GestureDetector(
                onTap: () => _openProfile(focus.id!),
                child: _NodeAvatar(
                  initial: _initialOf(focus.firstName),
                  photoPath: focus.photoPath,
                  size: centerRadius * 2,
                  accent: accent,
                  highlight: true,
                ),
              ),
            ),
          );

          // Orbit nodes.
          for (var i = 0; i < n; i++) {
            final r = _relations[i];
            children.add(
              _positioned(
                positions[i],
                orbitRadius,
                GestureDetector(
                  onTap: () => _recenterOn(r.contactId),
                  onLongPress: () => _nodeMenu(r),
                  child: _NodeAvatar(
                    initial: _initialOf(r.firstName),
                    photoPath: r.photoPath,
                    size: orbitRadius * 2,
                    accent: accent,
                    highlight: false,
                  ),
                ),
              ),
            );
          }

          // Type labels at each edge midpoint.
          for (var i = 0; i < n; i++) {
            final r = _relations[i];
            final mid = Offset(
              (center.dx + positions[i].dx) / 2,
              (center.dy + positions[i].dy) / 2,
            );
            children.add(
              Positioned(
                left: mid.dx,
                top: mid.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: _EdgeLabel(
                    text: r.relationshipType,
                    color: colors.mutedText,
                    background: colors.cardSurface,
                    onTap: () => _editRelationship(r),
                  ),
                ),
              ),
            );
          }
        }

        return Stack(children: children);
      },
    );
  }

  /// Places [child] centred on [point] within the stack.
  Widget _positioned(Offset point, double radius, Widget child) {
    return Positioned(
      left: point.dx - radius,
      top: point.dy - radius,
      width: radius * 2,
      height: radius * 2,
      child: child,
    );
  }
}

/// Draws the edge lines from the centre to each orbit node. The relationship
/// type labels are rendered as separate tappable widgets (see [_EdgeLabel]).
class _EdgePainter extends CustomPainter {
  final Offset center;
  final List<Offset> nodes;
  final Color edgeColor;

  _EdgePainter({
    required this.center,
    required this.nodes,
    required this.edgeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = edgeColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < nodes.length; i++) {
      canvas.drawLine(center, nodes[i], linePaint);
    }
  }

  @override
  bool shouldRepaint(_EdgePainter old) =>
      old.center != center || old.nodes != nodes || old.edgeColor != edgeColor;
}

/// The relationship-type label rendered at an edge midpoint. Tapping it edits
/// the relationship type. Styled to match the previous painted pill.
class _EdgeLabel extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _EdgeLabel({
    required this.text,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// The avatar-fallback initial for [name] — pass the first name (not the
/// salutation-prefixed full name) so "Mr John" yields "J".
String _initialOf(String name) => initialFor(name);

/// A circular node: photo when available, otherwise [initial].
class _NodeAvatar extends StatelessWidget {
  final String initial;
  final String? photoPath;
  final double size;
  final Color accent;
  final bool highlight;

  const _NodeAvatar({
    required this.initial,
    required this.photoPath,
    required this.size,
    required this.accent,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlight ? accent : accent.withValues(alpha: 0.14),
        border: Border.all(
          color: accent.withValues(alpha: highlight ? 1 : 0.5),
          width: highlight ? 3 : 2,
        ),
        image: hasPhoto
            ? DecorationImage(
                image: FileImage(File(photoPath!)),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: highlight ? 0.45 : 0.2),
            blurRadius: highlight ? 22 : 12,
            spreadRadius: -4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? null
          : Padding(
              padding: const EdgeInsets.all(6),
              child: AvatarInitial(
                initial,
                style: TextStyle(
                  color: highlight ? AppTheme.contrastOn(accent) : accent,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.4,
                ),
              ),
            ),
    );
  }
}

/// A grouped relationship node. When count == 1, renders the individual's avatar;
/// when count > 1, renders the count number as the avatar in the sphere node.
class _GroupNodeAvatar extends StatelessWidget {
  final String initial;
  final String? photoPath;
  final int count;
  final double size;
  final Color accent;

  const _GroupNodeAvatar({
    required this.initial,
    required this.photoPath,
    required this.count,
    required this.size,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 1) {
      return _NodeAvatar(
        initial: initial,
        photoPath: photoPath,
        size: size,
        accent: accent,
        highlight: false,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.16),
        border: Border.all(
          color: accent.withValues(alpha: 0.7),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 14,
            spreadRadius: -3,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: accent,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
