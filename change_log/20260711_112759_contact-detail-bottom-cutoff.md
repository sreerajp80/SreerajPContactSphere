# Change log: fix contact detail screen bottom content cut off

Implements plan
[plans/20260711_112712_contact-detail-bottom-cutoff.md](../plans/20260711_112712_contact-detail-bottom-cutoff.md).

## What was changed

In [lib/screens/contact_detail_screen.dart](../lib/screens/contact_detail_screen.dart),
the body `ListView` padding was changed from a fixed `EdgeInsets.all(16)` to
`EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom)`.

## Why

The fixed bottom padding did not include the device's bottom safe-area inset
(the system navigation / gesture bar). As a result, when the list was scrolled
to the bottom, the last relationship row was hidden behind that bar. Adding the
bottom inset lets the final item clear the navigation bar.

## Verification

- `flutter analyze lib/screens/contact_detail_screen.dart` — no issues found.
