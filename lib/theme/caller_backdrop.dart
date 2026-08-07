// lib/theme/caller_backdrop.dart
//
// The last step of the in-call backdrop fallback chain.
//
// `InCallScreen` paints, in order of preference:
//   1. the contact's calling card photo,
//   2. their profile photo,
//   3. a generated gradient chosen by their relationship to the phone owner
//      (this file),
//   4. the plain brand gradient.
//
// Step 3 exists so a call from a contact who has no photo at all still says
// something about who is calling: family reads warm, work reads flat and cool.
// Nothing here touches the database or the filesystem — [moodForRelationship]
// and [gradientFor] are pure functions so they can be unit tested directly.

import 'package:flutter/material.dart';

/// The feel of a caller's backdrop, derived from their relationship label.
///
/// A small set on purpose: [RelationshipTypes.presets] has ~45 labels, and one
/// gradient per label would be noise rather than information.
enum BackdropMood {
  /// Parents, children, spouse/partner, siblings.
  immediateFamily,

  /// Grandparents, grandchildren, uncles/aunts, nephews/nieces, cousins,
  /// in-laws, step-relations, and the generic "Relative".
  extendedFamily,

  /// Friends and neighbours.
  friend,

  /// Work contacts.
  work,

  /// "Other", a custom relationship name, or no relationship on record. Draws
  /// no gradient — the caller falls back to the brand gradient.
  unknown,
}

/// Relationship label → mood. Keys are lower-cased; lookups go through
/// [moodForRelationship], which trims and lower-cases first. Anything missing
/// here is [BackdropMood.unknown] by design: the user can rename relationship
/// types (see `AppSettings.relationshipNames`), and an unrecognised name should
/// quietly get the brand gradient rather than a guessed mood.
const Map<String, BackdropMood> _moodByLabel = <String, BackdropMood>{
  // Immediate family.
  'father': BackdropMood.immediateFamily,
  'mother': BackdropMood.immediateFamily,
  'parent': BackdropMood.immediateFamily,
  'son': BackdropMood.immediateFamily,
  'daughter': BackdropMood.immediateFamily,
  'child': BackdropMood.immediateFamily,
  'spouse': BackdropMood.immediateFamily,
  'partner': BackdropMood.immediateFamily,
  'brother': BackdropMood.immediateFamily,
  'sister': BackdropMood.immediateFamily,
  'elder brother': BackdropMood.immediateFamily,
  'younger brother': BackdropMood.immediateFamily,
  'elder sister': BackdropMood.immediateFamily,
  'younger sister': BackdropMood.immediateFamily,
  'sibling': BackdropMood.immediateFamily,
  // Extended family.
  'grandfather': BackdropMood.extendedFamily,
  'grandmother': BackdropMood.extendedFamily,
  'grandparent': BackdropMood.extendedFamily,
  'grandchild': BackdropMood.extendedFamily,
  'grandson': BackdropMood.extendedFamily,
  'granddaughter': BackdropMood.extendedFamily,
  'uncle': BackdropMood.extendedFamily,
  'aunt': BackdropMood.extendedFamily,
  'nephew': BackdropMood.extendedFamily,
  'niece': BackdropMood.extendedFamily,
  'cousin': BackdropMood.extendedFamily,
  'cousin brother': BackdropMood.extendedFamily,
  'cousin sister': BackdropMood.extendedFamily,
  'father-in-law': BackdropMood.extendedFamily,
  'mother-in-law': BackdropMood.extendedFamily,
  'son-in-law': BackdropMood.extendedFamily,
  'daughter-in-law': BackdropMood.extendedFamily,
  'brother-in-law': BackdropMood.extendedFamily,
  'sister-in-law': BackdropMood.extendedFamily,
  'step-father': BackdropMood.extendedFamily,
  'step-mother': BackdropMood.extendedFamily,
  'step-son': BackdropMood.extendedFamily,
  'step-daughter': BackdropMood.extendedFamily,
  'step-brother': BackdropMood.extendedFamily,
  'step-sister': BackdropMood.extendedFamily,
  'relative': BackdropMood.extendedFamily,
  // Social.
  'friend': BackdropMood.friend,
  'neighbour': BackdropMood.friend,
  // Work.
  'colleague': BackdropMood.work,
  // Explicitly no mood.
  'other': BackdropMood.unknown,
};

/// The mood for [relationshipType], or [BackdropMood.unknown] when the label is
/// null, blank, or not one of the built-in types.
BackdropMood moodForRelationship(String? relationshipType) {
  final label = relationshipType?.trim().toLowerCase();
  if (label == null || label.isEmpty) return BackdropMood.unknown;
  return _moodByLabel[label] ?? BackdropMood.unknown;
}

/// The two-stop color pair for each mood, before time-of-day shading.
///
/// These are fixed design tokens rather than derivations of the user's accent:
/// the whole point is that the moods differ in *hue* (warm family vs. cool
/// work), which a single accent color cannot express. [BackdropMood.work] uses
/// the closest-together pair on purpose, so a work call reads as a flat,
/// businesslike card next to the family gradients.
const Map<BackdropMood, List<Color>> _moodColors = <BackdropMood, List<Color>>{
  BackdropMood.immediateFamily: <Color>[
    Color(0xFFF59E0B), // amber
    Color(0xFFBE185D), // deep rose
  ],
  BackdropMood.extendedFamily: <Color>[
    Color(0xFFF8B58B), // peach
    Color(0xFFA85B43), // clay
  ],
  BackdropMood.friend: <Color>[
    Color(0xFF14B8A6), // teal
    Color(0xFF4F46E5), // indigo
  ],
  BackdropMood.work: <Color>[
    Color(0xFF475569), // slate
    Color(0xFF33556E), // steel blue
  ],
};

/// How much the clock shifts the gradient's lightness. Hue and saturation are
/// left alone, so an evening family call is a dimmer version of the same warm
/// gradient rather than a different palette.
double _lightnessShiftForHour(int hour) {
  if (hour >= 5 && hour < 11) return 0.04; // morning
  if (hour >= 11 && hour < 17) return 0.08; // day
  if (hour >= 17 && hour < 21) return -0.02; // evening
  return -0.10; // night
}

/// Applies [shift] to [color]'s lightness only, clamped away from pure black
/// and white so the gradient never collapses to a flat block.
Color _shade(Color color, double shift) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness + shift).clamp(0.08, 0.92)).toColor();
}

/// The backdrop gradient for [mood] at [now], or null for
/// [BackdropMood.unknown] — the caller then uses the brand gradient.
///
/// [isDark] darkens the whole pair a little further for the Midnight theme, so
/// the in-call screen doesn't glow brighter than the rest of the app at night.
/// The gradient runs top-left → bottom-right, matching [AppColors.brandGradient],
/// so swapping between the two doesn't move the light source.
LinearGradient? gradientFor(
  BackdropMood mood, {
  required DateTime now,
  bool isDark = false,
}) {
  final base = _moodColors[mood];
  if (base == null) return null;
  final shift = _lightnessShiftForHour(now.hour) + (isDark ? -0.06 : 0.0);
  return LinearGradient(
    colors: <Color>[_shade(base[0], shift), _shade(base[1], shift)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
