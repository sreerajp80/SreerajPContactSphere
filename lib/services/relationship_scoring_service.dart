// lib/services/relationship_scoring_service.dart
import 'package:smart_contacts_dialer/database/database_helper.dart';

class RelationshipScoringService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<double> calculateRelationshipScore(int contactId) async {
    final db = await _dbHelper.database;

    // Get interaction data, most recent first so [0] is the latest.
    final interactions = await db.query(
      'interactions',
      where: 'contact_id = ? AND timestamp > ?',
      whereArgs: [
        contactId,
        DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      ],
      orderBy: 'timestamp DESC',
    );

    // Calculate frequency score
    double frequencyScore = (interactions.length / 90.0) * 100;
    if (frequencyScore > 100) frequencyScore = 100;

    // Calculate recency score from the most recent interaction.
    double recencyScore = 0;
    if (interactions.isNotEmpty) {
      final lastInteraction = DateTime.parse(
        interactions.first['timestamp'] as String,
      );
      final daysSinceLastInteraction = DateTime.now()
          .difference(lastInteraction)
          .inDays;
      recencyScore = (30 - daysSinceLastInteraction) / 30 * 100;
      if (recencyScore < 0) recencyScore = 0;
      if (recencyScore > 100) recencyScore = 100;
    }

    // Calculate emotional tone score
    double emotionalScore = 0;
    for (var interaction in interactions) {
      switch (interaction['emotional_tone']) {
        case 'positive':
          emotionalScore += 100;
          break;
        case 'neutral':
          emotionalScore += 50;
          break;
        case 'negative':
          emotionalScore += 0;
          break;
      }
    }
    emotionalScore = interactions.isNotEmpty
        ? emotionalScore / interactions.length
        : 0;

    // Calculate overall score (weighted average)
    final double overallScore =
        (frequencyScore * 0.3) + (recencyScore * 0.4) + (emotionalScore * 0.3);

    // Update contact's relationship score
    await db.update(
      'contacts',
      {'relationship_score': overallScore},
      where: 'id = ?',
      whereArgs: [contactId],
    );

    return overallScore;
  }
}
