// test/export_import_csv_test.dart
//
// Locks the Unicode contract of the CSV export/import format. The whole-book
// CSV that ExportImportService writes is encoded with `Csv(addBom: true)` so
// Excel / Google Sheets read the file as UTF-8 and show non-ASCII names
// correctly. These are pure-Dart csv-package round-trips — no path_provider or
// share_plus platform channels, so they run under `flutter test` on the host.

import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bom = '﻿';

  test('CSV export prepends a UTF-8 BOM so Excel reads it as UTF-8', () {
    final rows = <List<dynamic>>[
      ['First Name', 'Last Name'],
      ['परिवार', 'Menon'], // Devanagari name
    ];

    final csv = Csv(addBom: true).encode(rows);

    expect(
      csv.startsWith(bom),
      isTrue,
      reason: 'exported CSV must start with the UTF-8 BOM',
    );
    // The Unicode name is kept as-is in the text (UTF-8 on disk), not escaped.
    expect(csv, contains('परिवार'));
  });

  test('re-import strips the BOM and round-trips the Unicode name', () {
    final csv = Csv(addBom: true).encode(<List<dynamic>>[
      ['First Name', 'Last Name'],
      ['परिवार', 'Menon'],
    ]);

    // Same decoder configuration the app uses on import.
    final decoded = Csv().decode(csv);

    expect(decoded, hasLength(2));
    // The BOM must not leak into the first header cell.
    expect(decoded.first.first, 'First Name');
    expect(decoded.first.first.toString().startsWith(bom), isFalse);
    // The Unicode data row survives the round-trip unchanged.
    expect(decoded[1][0], 'परिवार');
    expect(decoded[1][1], 'Menon');
  });
}
