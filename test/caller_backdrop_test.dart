// test/caller_backdrop_test.dart
//
// Covers the pure parts of the relationship-based in-call backdrop: the
// relationship label → mood mapping, and that the clock only changes lightness.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/theme/caller_backdrop.dart';

void main() {
  group('moodForRelationship', () {
    test('immediate family labels', () {
      for (final label in const [
        'Father',
        'Mother',
        'Parent',
        'Son',
        'Daughter',
        'Child',
        'Spouse',
        'Partner',
        'Brother',
        'Sister',
        'Elder Brother',
        'Younger Brother',
        'Elder Sister',
        'Younger Sister',
        'Sibling',
      ]) {
        expect(
          moodForRelationship(label),
          BackdropMood.immediateFamily,
          reason: label,
        );
      }
    });

    test('extended family labels', () {
      for (final label in const [
        'Grandfather',
        'Grandmother',
        'Grandparent',
        'Grandchild',
        'Grandson',
        'Granddaughter',
        'Uncle',
        'Aunt',
        'Nephew',
        'Niece',
        'Cousin',
        'Cousin Brother',
        'Cousin Sister',
        'Father-in-law',
        'Mother-in-law',
        'Son-in-law',
        'Daughter-in-law',
        'Brother-in-law',
        'Sister-in-law',
        'Step-father',
        'Step-mother',
        'Step-son',
        'Step-daughter',
        'Step-brother',
        'Step-sister',
        'Relative',
      ]) {
        expect(
          moodForRelationship(label),
          BackdropMood.extendedFamily,
          reason: label,
        );
      }
    });

    test('friend and work labels', () {
      expect(moodForRelationship('Friend'), BackdropMood.friend);
      expect(moodForRelationship('Neighbour'), BackdropMood.friend);
      expect(moodForRelationship('Colleague'), BackdropMood.work);
    });

    test('null, blank, "Other" and custom names are unknown', () {
      expect(moodForRelationship(null), BackdropMood.unknown);
      expect(moodForRelationship(''), BackdropMood.unknown);
      expect(moodForRelationship('   '), BackdropMood.unknown);
      expect(moodForRelationship('Other'), BackdropMood.unknown);
      expect(moodForRelationship('Gym buddy'), BackdropMood.unknown);
    });

    test('matching ignores case and surrounding spaces', () {
      expect(moodForRelationship('  father  '), BackdropMood.immediateFamily);
      expect(moodForRelationship('ELDER SISTER'), BackdropMood.immediateFamily);
      expect(moodForRelationship('FaTHeR-In-LaW'), BackdropMood.extendedFamily);
    });

    test('every built-in preset maps to a mood without throwing', () {
      // Guards against a preset being added to RelationshipTypes without a
      // matching entry here. Unmapped labels are allowed (they read as
      // unknown → brand gradient), so this only asserts the call is total.
      for (final label in RelationshipTypes.presets) {
        expect(moodForRelationship(label), isA<BackdropMood>(), reason: label);
      }
    });
  });

  group('gradientFor', () {
    // Noon, 5 p.m. and midnight — one sample per lightness bucket boundary.
    final day = DateTime(2026, 7, 30, 13);
    final evening = DateTime(2026, 7, 30, 18);
    final night = DateTime(2026, 7, 30, 23);
    final morning = DateTime(2026, 7, 30, 7);

    test('unknown mood draws no gradient', () {
      expect(gradientFor(BackdropMood.unknown, now: day), isNull);
    });

    test('each real mood produces a two-stop gradient', () {
      for (final mood in const [
        BackdropMood.immediateFamily,
        BackdropMood.extendedFamily,
        BackdropMood.friend,
        BackdropMood.work,
      ]) {
        final g = gradientFor(mood, now: day);
        expect(g, isNotNull, reason: '$mood');
        expect(g!.colors.length, 2, reason: '$mood');
      }
    });

    test('moods differ from each other', () {
      final family = gradientFor(BackdropMood.immediateFamily, now: day)!;
      final work = gradientFor(BackdropMood.work, now: day)!;
      final friend = gradientFor(BackdropMood.friend, now: day)!;
      expect(family.colors.first, isNot(work.colors.first));
      expect(family.colors.first, isNot(friend.colors.first));
      expect(work.colors.first, isNot(friend.colors.first));
    });

    test('time of day changes lightness only, never hue', () {
      for (final mood in const [
        BackdropMood.immediateFamily,
        BackdropMood.extendedFamily,
        BackdropMood.friend,
        BackdropMood.work,
      ]) {
        final samples = [morning, day, evening, night]
            .map((t) => HSLColor.fromColor(gradientFor(mood, now: t)!.colors[0]))
            .toList();
        final hue = samples.first.hue;
        for (final s in samples) {
          // A degree or so of slack: shading round-trips through 8-bit RGB, so
          // the recovered hue is never bit-identical to the input's.
          expect(s.hue, closeTo(hue, 1.5), reason: '$mood hue drifted');
        }
        // Day is the brightest bucket, night the dimmest.
        expect(samples[1].lightness, greaterThan(samples[3].lightness));
      }
    });

    test('dark theme dims the same hues further', () {
      final light = gradientFor(BackdropMood.friend, now: day)!;
      final dark = gradientFor(BackdropMood.friend, now: day, isDark: true)!;
      final l = HSLColor.fromColor(light.colors.first);
      final d = HSLColor.fromColor(dark.colors.first);
      expect(d.hue, closeTo(l.hue, 1.5));
      expect(d.lightness, lessThan(l.lightness));
    });

    test('lightness stays inside the clamp at extreme shifts', () {
      for (final mood in const [
        BackdropMood.immediateFamily,
        BackdropMood.work,
      ]) {
        final g = gradientFor(mood, now: night, isDark: true)!;
        for (final c in g.colors) {
          final hsl = HSLColor.fromColor(c);
          expect(hsl.lightness, inInclusiveRange(0.08, 0.92));
        }
      }
    });

    test('gradient direction matches the brand gradient', () {
      final g = gradientFor(BackdropMood.work, now: day)!;
      expect(g.begin, Alignment.topLeft);
      expect(g.end, Alignment.bottomRight);
    });
  });
}
