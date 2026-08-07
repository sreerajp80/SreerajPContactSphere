// lib/screens/relation_status_screen.dart
//
// Relation Status: the Relationship Health hero (moved off the contacts list)
// plus the contacts that have relationships defined. Tapping a contact opens
// the ego-sphere ([RelationshipScreen]) focused on it. Secondary page, pushed
// over the shell like Groups/Duplicates.
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/repositories/relationship_repository.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/relationship_screen.dart';
import 'package:smart_contacts_dialer/widgets/avatar_initial.dart';

class RelationStatusScreen extends StatefulWidget {
  const RelationStatusScreen({super.key});

  @override
  State<RelationStatusScreen> createState() => _RelationStatusScreenState();
}

class _RelationStatusScreenState extends State<RelationStatusScreen> {
  final ContactSyncService _sync = ContactSyncService();
  final RelationshipRepository _relationships = RelationshipRepository();

  bool _loading = true;
  double _avgScore = 0;
  int _total = 0;
  List<RelationOverview> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final avg = await _sync.averageScore();
      final total = await _sync.contactCount();
      final rows = await _relationships.getContactsWithRelations();
      if (!mounted) return;
      setState(() {
        _avgScore = avg;
        _total = total;
        _rows = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _rows = const [];
        _loading = false;
      });
    }
  }

  /// Opens the ego-sphere for [contactId]; relations can be edited there, so
  /// the list and score are refreshed on return.
  Future<void> _openSphere(int contactId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RelationshipScreen(focusContactId: contactId),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('Relation Status')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              // Hero + section header, then one row per contact (or the empty
              // hint when nothing has relationships yet).
              itemCount: 2 + (_rows.isEmpty ? 1 : _rows.length),
              itemBuilder: (context, index) {
                if (index == 0) return _buildHealthHero(context, colors);
                if (index == 1) return _buildSectionHeader(colors);
                if (_rows.isEmpty) return _buildEmptyHint(colors);
                return _buildRelationRow(_rows[index - 2], colors);
              },
            ),
    );
  }

  Widget _buildHealthHero(BuildContext context, AppColors colors) {
    final avg = _avgScore;
    final mood = AppTheme.moodFor(avg);
    final faceColor = colors.isDark ? mood.color : Colors.white;

    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RELATIONSHIP HEALTH',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: colors.isDark ? colors.mutedText : Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: avg.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: colors.isDark ? mood.color : Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: '/100',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.isDark
                            ? colors.mutedText
                            : Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${mood.label} · $_total contacts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.isDark
                      ? const Color(0xFFC7CBE8)
                      : Colors.white.withValues(alpha: 0.96),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 90,
            height: 90,
            child: CustomPaint(
              painter: _RingPainter(
                progress: (avg / 100).clamp(0.0, 1.0),
                color: colors.isDark ? mood.color : Colors.white,
                track: colors.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.28),
              ),
              child: Center(
                child: Icon(_moodIcon(avg), color: faceColor, size: 38),
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: colors.isDark
          ? BoxDecoration(
              color: colors.cardSurface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: mood.color.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: mood.color.withValues(alpha: 0.33),
                  blurRadius: 40,
                  spreadRadius: -10,
                ),
              ],
            )
          : BoxDecoration(
              gradient: colors.brandGradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: colors.gradientStart.withValues(alpha: 0.5),
                  blurRadius: 34,
                  offset: const Offset(0, 16),
                  spreadRadius: -12,
                ),
              ],
            ),
      child: inner,
    );
  }

  Widget _buildSectionHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 10),
      child: Text(
        'WITH RELATIONSHIPS',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: colors.mutedText,
        ),
      ),
    );
  }

  Widget _buildEmptyHint(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Text(
        "No relationships defined yet.\nAdd them from a contact's profile.",
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.mutedText, fontSize: 14),
      ),
    );
  }

  Widget _buildRelationRow(RelationOverview row, AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final mood = AppTheme.moodFor(row.relationshipScore);
    final hasPhoto = row.photoPath != null && File(row.photoPath!).existsSync();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: colors.isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F2A28).withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                  spreadRadius: -14,
                ),
              ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openSphere(row.contactId),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                  image: hasPhoto
                      ? DecorationImage(
                          image: FileImage(File(row.photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: hasPhoto
                    ? null
                    : AvatarInitial(
                        initialFor(row.firstName),
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.fullName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      row.relationCount == 1
                          ? '1 relation'
                          : '${row.relationCount} relations',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: colors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: mood.soft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _moodIcon(row.relationshipScore),
                      color: mood.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${row.relationshipScore.toInt()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: mood.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _moodIcon(double score) {
    if (score >= 75) return Icons.sentiment_very_satisfied;
    if (score >= 50) return Icons.sentiment_satisfied;
    if (score >= 25) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }
}

/// Circular progress ring used by the health hero.
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.09;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
