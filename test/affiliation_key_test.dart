// Unit tests for the household/company match keys behind the group and tag
// member suggestions. Pure Dart — no DB, no binding needed.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_contacts_dialer/utils/affiliation_key.dart';

void main() {
  group('houseAffiliationKey', () {
    test('spelling noise folds onto one key', () {
      final a = houseAffiliationKey('Sreelakshmi', locality: 'Kakkanad');
      final b = houseAffiliationKey('  sreelakshmi ', locality: 'kakkanad');
      final c = houseAffiliationKey('Sreelakshmi (H)', locality: 'Kakkanad');

      expect(a, isNotNull);
      expect(b, a);
      expect(c, a);
    });

    test('the same house name in two places does not merge', () {
      final kochi = houseAffiliationKey('Sreelakshmi', locality: 'Kakkanad');
      final kollam = houseAffiliationKey('Sreelakshmi', locality: 'Karunagappally');

      expect(kochi, isNot(kollam));
    });

    test('a missing locality still yields a key', () {
      expect(houseAffiliationKey('Sreelakshmi'), isNotNull);
    });

    test('blank, too-short and generic values give no key', () {
      expect(houseAffiliationKey(null), isNull);
      expect(houseAffiliationKey(''), isNull);
      expect(houseAffiliationKey('   '), isNull);
      expect(houseAffiliationKey('AB'), isNull);
      expect(houseAffiliationKey('house'), isNull);
      expect(houseAffiliationKey('Home'), isNull);
      expect(houseAffiliationKey('n/a'), isNull);
      expect(houseAffiliationKey('-'), isNull);
    });

    test('Malayalam script survives folding', () {
      final a = houseAffiliationKey('ശ്രീനിവാസ്', locality: 'കാക്കനാട്');
      final b = houseAffiliationKey(' ശ്രീനിവാസ് ', locality: 'കാക്കനാട്');

      expect(a, isNotNull);
      expect(b, a);
    });
  });

  group('companyAffiliationKey', () {
    test('legal suffixes are dropped so spellings agree', () {
      final plain = companyAffiliationKey('Infosys');

      expect(companyAffiliationKey('Infosys Ltd'), plain);
      expect(companyAffiliationKey('INFOSYS LIMITED'), plain);
      expect(companyAffiliationKey('Infosys Pvt Ltd'), plain);
      expect(companyAffiliationKey('infosys.'), plain);
    });

    test('different employers keep different keys', () {
      expect(
        companyAffiliationKey('Infosys'),
        isNot(companyAffiliationKey('Wipro')),
      );
    });

    test('a company named only of suffix words keeps its key', () {
      // "Group" alone is the whole name; stripping it would lose the contact.
      expect(companyAffiliationKey('Group'), isNotNull);
    });

    test('house and company keys never collide', () {
      expect(
        houseAffiliationKey('Infosys'),
        isNot(companyAffiliationKey('Infosys')),
      );
    });

    test('blank and generic values give no key', () {
      expect(companyAffiliationKey(null), isNull);
      expect(companyAffiliationKey(''), isNull);
      expect(companyAffiliationKey('office'), isNull);
      expect(companyAffiliationKey('NA'), isNull);
    });
  });
}
