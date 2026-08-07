// lib/models/relationship.dart

/// A single directed row of the `relationships` table: [contactId] (the owner)
/// is related to [relatedContactId] as [relationshipType] (described from the
/// owner's perspective, e.g. "Father").
///
/// Links are stored as two reciprocal rows (A→B and B→A) by
/// [RelationshipRepository] so each contact's relationships are a trivial
/// `WHERE contact_id = ?` query and the sphere view is naturally symmetric.
class Relationship {
  int? id;
  int? contactId;
  int? relatedContactId;
  String? relationshipType;

  Relationship({
    this.id,
    this.contactId,
    this.relatedContactId,
    this.relationshipType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_id': contactId,
      'related_contact_id': relatedContactId,
      'relationship_type': relationshipType,
    };
  }

  factory Relationship.fromMap(Map<String, dynamic> map) {
    return Relationship(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int?,
      relatedContactId: map['related_contact_id'] as int?,
      relationshipType: map['relationship_type'] as String?,
    );
  }
}

/// A related contact resolved for display: the other contact's identity fields
/// plus the [relationshipType] from the focus contact's perspective. Used by the
/// detail screen's Relationships section and the ego-sphere view so neither has
/// to re-hydrate full [Contact] aggregates.
class RelatedContact {
  final int contactId;
  final String fullName;

  /// Given name only (no salutation) — the source for avatar initials.
  final String firstName;
  final String? photoPath;
  final double relationshipScore;

  /// The relationship as seen from the focus contact (e.g. "Father", "Friend").
  final String relationshipType;

  const RelatedContact({
    required this.contactId,
    required this.fullName,
    required this.firstName,
    this.photoPath,
    this.relationshipScore = 0.0,
    required this.relationshipType,
  });
}

/// A contact that has at least one relationship defined, resolved for display
/// on the Relation Status list: identity fields plus how many contacts it is
/// linked to. Tapping a row opens the ego-sphere focused on [contactId].
class RelationOverview {
  final int contactId;
  final String fullName;

  /// Given name only (no salutation) — the source for avatar initials.
  final String firstName;
  final String? photoPath;
  final double relationshipScore;

  /// Number of distinct contacts this contact is linked to.
  final int relationCount;

  const RelationOverview({
    required this.contactId,
    required this.fullName,
    required this.firstName,
    this.photoPath,
    this.relationshipScore = 0.0,
    required this.relationCount,
  });
}

/// Common relationship types and the reciprocal mapping used to store the
/// reverse-direction row automatically.
///
/// When the user records "A is B's Father", the reverse row stored on B is
/// `reciprocalOf('Father')` → "Child". Symmetric relationships (Spouse, Sibling,
/// Friend, Colleague, …) map to themselves. Anything unknown defaults to the
/// same label so a link is never lost.
class RelationshipTypes {
  RelationshipTypes._();

  /// Types offered in the picker, grouped loosely family → social.
  static const List<String> presets = <String>[
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Child',
    'Parent',
    'Brother',
    'Sister',
    'Elder Brother',
    'Younger Brother',
    'Elder Sister',
    'Younger Sister',
    'Sibling',
    'Spouse',
    'Partner',
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
    'Friend',
    'Colleague',
    'Neighbour',
    'Relative',
    'Other',
  ];

  /// Explicit reverse labels. Anything not listed falls back to itself.
  static const Map<String, String> _reciprocals = <String, String>{
    'Father': 'Child',
    'Mother': 'Child',
    'Parent': 'Child',
    'Son': 'Parent',
    'Daughter': 'Parent',
    'Child': 'Parent',
    'Grandfather': 'Grandchild',
    'Grandmother': 'Grandchild',
    'Grandparent': 'Grandchild',
    'Grandchild': 'Grandparent',
    'Grandson': 'Grandparent',
    'Granddaughter': 'Grandparent',
    'Uncle': 'Nephew',
    'Aunt': 'Niece',
    'Nephew': 'Uncle',
    'Niece': 'Aunt',
    // Directional siblings — reverse swaps elder ↔ younger.
    'Elder Brother': 'Younger Brother',
    'Younger Brother': 'Elder Brother',
    'Elder Sister': 'Younger Sister',
    'Younger Sister': 'Elder Sister',
    // Directional in-laws — reverse is the opposite generation.
    'Father-in-law': 'Son-in-law',
    'Son-in-law': 'Father-in-law',
    'Mother-in-law': 'Daughter-in-law',
    'Daughter-in-law': 'Mother-in-law',
    // Directional step relations — reverse is the opposite generation.
    'Step-father': 'Step-son',
    'Step-son': 'Step-father',
    'Step-mother': 'Step-daughter',
    'Step-daughter': 'Step-mother',
    // Symmetric — listed for clarity; the fallback would also return these.
    'Brother': 'Sibling',
    'Sister': 'Sibling',
    'Sibling': 'Sibling',
    'Spouse': 'Spouse',
    'Partner': 'Partner',
    'Cousin': 'Cousin',
    'Cousin Brother': 'Cousin Brother',
    'Cousin Sister': 'Cousin Sister',
    'Brother-in-law': 'Brother-in-law',
    'Sister-in-law': 'Sister-in-law',
    'Step-brother': 'Step-brother',
    'Step-sister': 'Step-sister',
    'Friend': 'Friend',
    'Colleague': 'Colleague',
    'Neighbour': 'Neighbour',
    'Relative': 'Relative',
  };

  /// Gendered reverse labels used when the reverse row's subject is **male**.
  /// Only relationships whose reverse depends on the subject's gender are
  /// listed; anything else falls back to [_reciprocals]. The subject is the
  /// contact the reverse label describes (the original owner).
  static const Map<String, String> _reciprocalsMale = <String, String>{
    'Father': 'Son',
    'Mother': 'Son',
    'Parent': 'Son',
    'Son': 'Father',
    'Daughter': 'Father',
    'Child': 'Father',
    'Brother': 'Brother',
    'Sister': 'Brother',
    'Sibling': 'Brother',
    'Cousin': 'Cousin Brother',
    'Cousin Brother': 'Cousin Brother',
    'Cousin Sister': 'Cousin Brother',
    'Grandfather': 'Grandson',
    'Grandmother': 'Grandson',
    'Grandparent': 'Grandson',
    'Grandson': 'Grandfather',
    'Granddaughter': 'Grandfather',
    'Grandchild': 'Grandfather',
    'Uncle': 'Nephew',
    'Aunt': 'Nephew',
    'Nephew': 'Uncle',
    'Niece': 'Uncle',
    'Elder Brother': 'Younger Brother',
    'Elder Sister': 'Younger Brother',
    'Younger Brother': 'Elder Brother',
    'Younger Sister': 'Elder Brother',
  };

  /// Gendered reverse labels used when the reverse row's subject is **female**.
  static const Map<String, String> _reciprocalsFemale = <String, String>{
    'Father': 'Daughter',
    'Mother': 'Daughter',
    'Parent': 'Daughter',
    'Son': 'Mother',
    'Daughter': 'Mother',
    'Child': 'Mother',
    'Brother': 'Sister',
    'Sister': 'Sister',
    'Sibling': 'Sister',
    'Cousin': 'Cousin Sister',
    'Cousin Brother': 'Cousin Sister',
    'Cousin Sister': 'Cousin Sister',
    'Grandfather': 'Granddaughter',
    'Grandmother': 'Granddaughter',
    'Grandparent': 'Granddaughter',
    'Grandson': 'Grandmother',
    'Granddaughter': 'Grandmother',
    'Grandchild': 'Grandmother',
    'Uncle': 'Niece',
    'Aunt': 'Niece',
    'Nephew': 'Aunt',
    'Niece': 'Aunt',
    'Elder Brother': 'Younger Sister',
    'Elder Sister': 'Younger Sister',
    'Younger Brother': 'Elder Sister',
    'Younger Sister': 'Elder Sister',
  };

  /// The label to store on the reverse-direction row for [type].
  ///
  /// [subjectGender] is the gender of the contact the reverse label will
  /// describe (the original owner). When it is `Male` or `Female` (matched
  /// case-insensitively) and [type] has a gender-dependent reverse, the
  /// correctly gendered label is returned — e.g. the reverse of
  /// "Cousin Brother" is "Cousin Sister" when the subject is female. When the
  /// gender is unknown, empty, non-binary, or any other value, a gender-neutral
  /// reverse is used (the historical behaviour), so nothing regresses.
  static String reciprocalOf(String type, {String? subjectGender}) {
    final key = type.trim();
    if (key.isEmpty) return 'Relative';

    final g = (subjectGender ?? '').trim().toLowerCase();
    if (g == 'male') {
      final v = _reciprocalsMale[key];
      if (v != null) return v;
    } else if (g == 'female') {
      final v = _reciprocalsFemale[key];
      if (v != null) return v;
    }

    return _reciprocals[key] ?? key;
  }

  /// Male↔female label pairs whose only difference is the gender of the person
  /// the label describes. Used by [forGender] to repair a row whose gendered
  /// label contradicts the described contact's gender. Each entry is
  /// `[maleLabel, femaleLabel]`.
  static const List<List<String>> _genderPairs = <List<String>>[
    ['Father', 'Mother'],
    ['Son', 'Daughter'],
    ['Brother', 'Sister'],
    ['Elder Brother', 'Elder Sister'],
    ['Younger Brother', 'Younger Sister'],
    ['Cousin Brother', 'Cousin Sister'],
    ['Grandfather', 'Grandmother'],
    ['Grandson', 'Granddaughter'],
    ['Uncle', 'Aunt'],
    ['Nephew', 'Niece'],
    ['Father-in-law', 'Mother-in-law'],
    ['Son-in-law', 'Daughter-in-law'],
    ['Brother-in-law', 'Sister-in-law'],
    ['Step-father', 'Step-mother'],
    ['Step-son', 'Step-daughter'],
    ['Step-brother', 'Step-sister'],
  ];

  /// Corrects a relationship label to agree with the gender of the contact it
  /// describes.
  ///
  /// If [type] is a gender-specific label (one member of a [_genderPairs] entry)
  /// and [gender] is the opposite gender (`Male`/`Female`, matched
  /// case-insensitively), the matching-gender label from the same family is
  /// returned — e.g. `forGender('Cousin Brother', 'Female')` → `'Cousin Sister'`.
  /// In every other case [type] is returned unchanged (trimmed): neutral labels
  /// (Cousin, Sibling, Child, …), non-gendered relations, and rows whose contact
  /// has no gender or a non-binary/custom gender are left as-is.
  static String forGender(String type, String? gender) {
    final key = type.trim();
    final g = (gender ?? '').trim().toLowerCase();
    if (g != 'male' && g != 'female') return key;
    for (final pair in _genderPairs) {
      final male = pair[0];
      final female = pair[1];
      if (g == 'female' && key == male) return female;
      if (g == 'male' && key == female) return male;
    }
    return key;
  }
}
