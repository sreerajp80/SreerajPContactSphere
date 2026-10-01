// test/l10n/icon_tooltip_source_test.dart
//
// Engineering standard §7.8: every icon-only control has a tooltip, and the
// tooltip text comes from the ARB files. Widget tests only see the screens they
// pump, so this test reads the source under lib/ and checks every
// IconButton, FloatingActionButton and PopupMenuButton call. It fails when one
// has no `tooltip:` argument, or when a `tooltip:` is a string literal (which
// would stay English under Malayalam and Sanskrit).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Constructor calls that must carry a tooltip. An extended FAB shows its own
/// label, so `FloatingActionButton.extended` is not listed.
final _controlCall = RegExp(
  r'\b(IconButton(?:\.filled|\.filledTonal|\.outlined)?|'
  r'FloatingActionButton(?:\.small|\.large)?|'
  r'PopupMenuButton(?:<[^>(]*>)?)\(',
);

/// A tooltip given as a plain string literal instead of an ARB lookup.
final _literalTooltip = RegExp(r'''tooltip:\s*['"]''');

/// Dart source under lib/, without the generated localization files.
List<File> _sources() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .where((f) => !f.path.contains('app_localizations'))
    .toList();

/// The argument list of the call whose `(` ends at [open], matched by
/// counting brackets.
String _arguments(String source, int open) {
  var depth = 1;
  var i = open;
  while (i < source.length && depth > 0) {
    final c = source[i];
    if (c == '(') depth++;
    if (c == ')') depth--;
    i++;
  }
  return source.substring(open, i);
}

int _line(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

void main() {
  test('every icon-only control in lib/ has a tooltip', () {
    final problems = <String>[];
    for (final file in _sources()) {
      final source = file.readAsStringSync();
      for (final m in _controlCall.allMatches(source)) {
        if (!_arguments(source, m.end).contains('tooltip:')) {
          problems.add(
            '${file.path}:${_line(source, m.start)} ${m.group(1)} has no tooltip',
          );
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('no tooltip in lib/ is an English string literal', () {
    final problems = <String>[];
    for (final file in _sources()) {
      final source = file.readAsStringSync();
      for (final m in _literalTooltip.allMatches(source)) {
        problems.add('${file.path}:${_line(source, m.start)} literal tooltip');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
