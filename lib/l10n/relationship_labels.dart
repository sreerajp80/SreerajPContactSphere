// lib/l10n/relationship_labels.dart
//
// Display names for the seven relationship categories. The enum in
// lib/models/relationship.dart keeps its English `displayName` (used in logs
// and as a stable fallback); screens show these translated names instead.

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';

/// The category's name in the app's language.
String relationshipCategoryLabel(AppLocalizations l, RelationshipCategory c) =>
    switch (c) {
      RelationshipCategory.immediateFamily => l.labelCatImmediateFamily,
      RelationshipCategory.extendedFamily => l.labelCatExtendedFamily,
      RelationshipCategory.familyByMarriage => l.labelCatFamilyByMarriage,
      RelationshipCategory.professional => l.labelCatProfessional,
      RelationshipCategory.educational => l.labelCatEducational,
      RelationshipCategory.social => l.labelCatSocial,
      RelationshipCategory.service => l.labelCatService,
    };

/// One sentence on who belongs in the category, in the app's language.
String relationshipCategoryDescription(
  AppLocalizations l,
  RelationshipCategory c,
) => switch (c) {
  RelationshipCategory.immediateFamily => l.descCatImmediateFamily,
  RelationshipCategory.extendedFamily => l.descCatExtendedFamily,
  RelationshipCategory.familyByMarriage => l.descCatFamilyByMarriage,
  RelationshipCategory.professional => l.descCatProfessional,
  RelationshipCategory.educational => l.descCatEducational,
  RelationshipCategory.social => l.descCatSocial,
  RelationshipCategory.service => l.descCatService,
};
