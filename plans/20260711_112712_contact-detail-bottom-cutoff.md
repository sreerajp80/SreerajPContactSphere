# Fix: contact detail screen bottom content cut off

**Status:** completed

## The issue

On the contact detail screen, the bottom part of the page is not fully
visible. When the list is scrolled all the way down, the last relationship
row is cut off behind the phone's bottom system navigation / gesture bar.

## Cause

The screen body is a `ListView` in
[lib/screens/contact_detail_screen.dart](lib/screens/contact_detail_screen.dart)
(around line 383) with a fixed padding:

```dart
body: ...
    : ListView(
        padding: const EdgeInsets.all(16),
        children: [ ... ],
      ),
```

The fixed bottom padding of `16` does not include the device's bottom safe
area (the space taken by the system navigation bar / gesture bar). So the
final list item sits under that bar and its bottom is hidden.

## The plan for the fix

Change the `ListView` padding so the bottom includes the device bottom inset.

- Replace `padding: const EdgeInsets.all(16)` with:

  ```dart
  padding: EdgeInsets.fromLTRB(
    16,
    16,
    16,
    16 + MediaQuery.of(context).padding.bottom,
  ),
  ```

This keeps the left/right/top padding the same and adds the safe-area
bottom inset so the last item clears the navigation bar. The list stays
scrollable, so nothing else changes.

## Files to change

- [lib/screens/contact_detail_screen.dart](lib/screens/contact_detail_screen.dart)
  — adjust the body `ListView` bottom padding only.

## Testing

- Run `flutter analyze` on the changed file.
- Open a contact with several relationships and confirm the last row is fully
  visible when scrolled to the bottom.
