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
    );
    await _load();
  }

  Future<void> _editRelationship(RelatedContact r) async {
    final newType = await showRelationshipTypePicker(
      context,
      personName: r.firstName,
      currentType: r.relationshipType,
    );
    if (newType == null || newType == r.relationshipType) return;
    await _relationships.setRelationship(
      contactId: widget.focusContactId,
      relatedContactId: r.contactId,
      type: newType,
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

  Future<void> _nodeMenu(RelatedContact r) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(r.fullName),
              subtitle: Text(r.relationshipType),
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
              title: const Text('Edit relationship type'),
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
      appBar: AppBar(title: Text(focus?.fullName ?? 'Relationships')),
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

        // Position each orbit node evenly around the ring, starting at top.
        final positions = <Offset>[];
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

        final children = <Widget>[
          // Edge lines behind the nodes. Type labels are separate tappable
          // widgets added below so tapping a label edits the relationship type.
          Positioned.fill(
            child: CustomPaint(
              painter: _EdgePainter(
                center: center,
                nodes: positions,
                edgeColor: accent.withValues(alpha: 0.45),
              ),
            ),
          ),
          // Centre node.
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
        ];

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

        // Type labels at each edge midpoint, on top of the lines and tappable
        // to edit the relationship type. FractionalTranslation centres each
        // label on the midpoint without needing its measured size.
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
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
