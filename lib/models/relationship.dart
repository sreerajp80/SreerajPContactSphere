// lib/models/relationship.dart

/// The seven fixed buckets every relationship belongs to.
///
/// A relationship has two parts: this **category** (structural, one of seven,
/// stored in `relationships.relationship_category`) and a free-text **label**
/// like "Father" or "Cousin Brother" (stored in `relationships.relationship_type`).
///
/// The category is what the sphere view draws: however many contacts a person is
/// linked to, the ring never holds more than seven nodes. The label is what the
/// user actually reads inside a category.
enum RelationshipCategory {
  immediateFamily(
    'immediate_family',
    'Immediate Family',
    '👨‍👩‍👧‍👦',
    'The people you live with or grew up with.',
  ),
  extendedFamily(
    'extended_family',
    'Extended Family',
    '👪',
    'Blood relatives outside your immediate family.',
  ),
  familyByMarriage(
    'family_by_marriage',
    'Family by Marriage',
    '💍',
    'In-laws and step relatives.',
  ),
  professional(
    'professional',
    'Professional',
    '💼',
    'People you work with or do business with.',
  ),
  educational(
    'educational',
    'Educational',
    '🎓',
    'People from school, college or training.',
  ),
  social('social', 'Social', '🤝', 'Friends, neighbours and other links.'),
  service(
    'service',
    'Service',
    '🏥',
    'People whose services you use.',
  );

  /// The value written to the database. Kept separate from [name] so renaming an
  /// enum value never breaks stored rows.
  final String storageKey;

  /// The name shown on sphere nodes, sheets and pickers.
  final String displayName;

  /// A small emoji used as the category's face in the UI.
  final String emoji;

  /// One plain-English line explaining who belongs here.
  final String description;

  const RelationshipCategory(
    this.storageKey,
    this.displayName,
    this.emoji,
    this.description,
  );

  /// The category whose [storageKey] is [key], or null when [key] is null,
  /// blank, or not one of the seven (e.g. a row written by a newer version).
  static RelationshipCategory? fromStorageKey(String? key) {
    final k = (key ?? '').trim();
    if (k.isEmpty) return null;
    for (final c in RelationshipCategory.values) {
      if (c.storageKey == k) return c;
    }
    return null;
  }

  /// The category a free-text [label] belongs to, used to place old rows during
  /// the v28→v29 migration and to categorise a label the user typed by hand.
  /// Anything unrecognised lands in [RelationshipCategory.social] — a safe,
  /// never-wrong-in-a-harmful-way default.
  static RelationshipCategory categoryFor(String? label) {
    final key = (label ?? '').trim().toLowerCase();
    if (key.isEmpty) return RelationshipCategory.social;
    return _labelCategories[key] ?? RelationshipCategory.social;
  }

  /// Labels offered as chips once this category is chosen. The user is free to
  /// type something else — these are only shortcuts.
  List<String> get suggestedLabels => _suggestedLabels[this] ?? const [];
}

/// Known label → category. Lower-cased keys; looked up by [RelationshipCategory.categoryFor].
const Map<String, RelationshipCategory> _labelCategories =
    <String, RelationshipCategory>{
      // Immediate family.
      'spouse': RelationshipCategory.immediateFamily,
      'husband': RelationshipCategory.immediateFamily,
      'wife': RelationshipCategory.immediateFamily,
      'father': RelationshipCategory.immediateFamily,
      'mother': RelationshipCategory.immediateFamily,
      'parent': RelationshipCategory.immediateFamily,
      'son': RelationshipCategory.immediateFamily,
      'daughter': RelationshipCategory.immediateFamily,
      'child': RelationshipCategory.immediateFamily,
      'brother': RelationshipCategory.immediateFamily,
      'sister': RelationshipCategory.immediateFamily,
      'sibling': RelationshipCategory.immediateFamily,
      'elder brother': RelationshipCategory.immediateFamily,
      'younger brother': RelationshipCategory.immediateFamily,
      'elder sister': RelationshipCategory.immediateFamily,
      'younger sister': RelationshipCategory.immediateFamily,
      // Extended family.
      'grandfather': RelationshipCategory.extendedFamily,
      'grandmother': RelationshipCategory.extendedFamily,
      'grandparent': RelationshipCategory.extendedFamily,
      'grandchild': RelationshipCategory.extendedFamily,
      'grandson': RelationshipCategory.extendedFamily,
      'granddaughter': RelationshipCategory.extendedFamily,
      'uncle': RelationshipCategory.extendedFamily,
      'aunt': RelationshipCategory.extendedFamily,
      'nephew': RelationshipCategory.extendedFamily,
      'niece': RelationshipCategory.extendedFamily,
      'cousin': RelationshipCategory.extendedFamily,
      'cousin brother': RelationshipCategory.extendedFamily,
      'cousin sister': RelationshipCategory.extendedFamily,
      'relative': RelationshipCategory.extendedFamily,
      // Family by marriage.
      'father-in-law': RelationshipCategory.familyByMarriage,
      'mother-in-law': RelationshipCategory.familyByMarriage,
      'son-in-law': RelationshipCategory.familyByMarriage,
      'daughter-in-law': RelationshipCategory.familyByMarriage,
      'brother-in-law': RelationshipCategory.familyByMarriage,
      'sister-in-law': RelationshipCategory.familyByMarriage,
      'step-father': RelationshipCategory.familyByMarriage,
      'step-mother': RelationshipCategory.familyByMarriage,
      'step-son': RelationshipCategory.familyByMarriage,
      'step-daughter': RelationshipCategory.familyByMarriage,
      'step-brother': RelationshipCategory.familyByMarriage,
      'step-sister': RelationshipCategory.familyByMarriage,
      // Professional.
      'colleague': RelationshipCategory.professional,
      'manager': RelationshipCategory.professional,
      'boss': RelationshipCategory.professional,
      'client': RelationshipCategory.professional,
      'mentor': RelationshipCategory.professional,
      'business partner': RelationshipCategory.professional,
      'employee': RelationshipCategory.professional,
      'supplier': RelationshipCategory.professional,
      // Educational.
      'teacher': RelationshipCategory.educational,
      'classmate': RelationshipCategory.educational,
      'professor': RelationshipCategory.educational,
      'tutor': RelationshipCategory.educational,
      'student': RelationshipCategory.educational,
      'batchmate': RelationshipCategory.educational,
      // Social.
      'friend': RelationshipCategory.social,
      'best friend': RelationshipCategory.social,
      'neighbour': RelationshipCategory.social,
      'neighbor': RelationshipCategory.social,
      'roommate': RelationshipCategory.social,
      'godparent': RelationshipCategory.social,
      'partner': RelationshipCategory.social,
      'other': RelationshipCategory.social,
      // Service.
      'doctor': RelationshipCategory.service,
      'lawyer': RelationshipCategory.service,
      'accountant': RelationshipCategory.service,
      'caregiver': RelationshipCategory.service,
      'driver': RelationshipCategory.service,
      'plumber': RelationshipCategory.service,
      'electrician': RelationshipCategory.service,
    };

/// The label chips shown after a category is picked.
const Map<RelationshipCategory, List<String>> _suggestedLabels =
    <RelationshipCategory, List<String>>{
      RelationshipCategory.immediateFamily: [
        'Spouse',
        'Father',
        'Mother',
        'Son',
        'Daughter',
        'Brother',
        'Sister',
        'Elder Brother',
        'Younger Brother',
        'Elder Sister',
        'Younger Sister',
      ],
      RelationshipCategory.extendedFamily: [
        'Grandfather',
        'Grandmother',
        'Grandson',
        'Granddaughter',
        'Uncle',
        'Aunt',
        'Nephew',
        'Niece',
        'Cousin',
        'Cousin Brother',
        'Cousin Sister',
        'Relative',
      ],
      RelationshipCategory.familyByMarriage: [
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
      ],
      RelationshipCategory.professional: [
        'Colleague',
        'Manager',
        'Client',
        'Mentor',
        'Business Partner',
        'Employee',
        'Supplier',
      ],
      RelationshipCategory.educational: [
        'Teacher',
        'Classmate',
        'Professor',
        'Tutor',
        'Student',
        'Batchmate',
      ],
      RelationshipCategory.social: [
        'Friend',
        'Best Friend',
        'Neighbour',
        'Roommate',
        'Godparent',
        'Partner',
        'Other',
      ],
      RelationshipCategory.service: [
        'Doctor',
        'Lawyer',
        'Accountant',
        'Caregiver',
        'Driver',
        'Plumber',
        'Electrician',
      ],
    };

/// A single directed row of the `relationships` table: [contactId] (the owner)
/// is related to [relatedContactId] as [relationshipType] (described from the
/// owner's perspective, e.g. "Father"), inside [category] (one of the seven
/// [RelationshipCategory] storage keys).
///
/// Links are stored as two reciprocal rows (A→B and B→A) by
/// [RelationshipRepository] so each contact's relationships are a trivial
/// `WHERE contact_id = ?` query and the sphere view is naturally symmetric.
class Relationship {
  int? id;
  int? contactId;
  int? relatedContactId;
  String? relationshipType;

  /// The [RelationshipCategory.storageKey] this link belongs to. Null only on
  /// rows written before v29 that the migration has not touched yet.
  String? category;

  Relationship({
    this.id,
    this.contactId,
    this.relatedContactId,
    this.relationshipType,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_id': contactId,
      'related_contact_id': relatedContactId,
      'relationship_type': relationshipType,
      'relationship_category': category,
    };
  }

  factory Relationship.fromMap(Map<String, dynamic> map) {
    return Relationship(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int?,
      relatedContactId: map['related_contact_id'] as int?,
      relationshipType: map['relationship_type'] as String?,
      category: map['relationship_category'] as String?,
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

  /// The stored [RelationshipCategory.storageKey] for this link, or null on a
  /// pre-v29 row. Use [category] to read it as an enum.
  final String? categoryKey;

  const RelatedContact({
    required this.contactId,
    required this.fullName,
    required this.firstName,
    this.photoPath,
    this.relationshipScore = 0.0,
    required this.relationshipType,
    this.categoryKey,
  });

  /// The category this link belongs to. Falls back to deriving it from the
  /// label, so a row the migration missed still lands somewhere sensible.
  RelationshipCategory get category =>
      RelationshipCategory.fromStorageKey(categoryKey) ??
      RelationshipCategory.categoryFor(relationshipType);
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
