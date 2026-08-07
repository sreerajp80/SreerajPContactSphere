# Change log — Calm / Midnight redesign + Settings, Appearance, Permissions, About

Implements plan `plans/20260629_054554_calm-midnight-redesign-settings.md`.

## Summary

Adopted the design brief from `sample/Smart Contacts.dc.html`: a teal Material 3 **Calm**
theme for light mode and a navy, mood-shifting **Midnight** theme for dark mode, both
seeded from a user-chosen accent color with theme-mode and accent persisted across launches.
Redesigned the contacts screen to match the mockup and added a Settings hub (reached from the
⋮ menu) with Appearance, Permissions and About sub-screens.

## Files added

- `lib/theme/app_theme.dart` — `AppTheme.calm()` / `AppTheme.midnight()` build `ThemeData`
  from an accent seed; `AppColors` `ThemeExtension` carries hero gradient / search fill /
  card surface / muted text tokens; `moodFor(score)` maps 0–100 to a color+label
  (Thriving/Steady/Fading/Needs love); `contrastOn(color)` returns black/white by luminance
  (the readability guarantee). Hero/FAB gradient is derived from any accent via hue rotation.
- `lib/state/app_settings.dart` — `AppSettings extends ChangeNotifier`: theme mode + accent
  override, loaded/saved via `shared_preferences` (`theme_mode`, `accent_color` as ARGB int).
  Null accent keeps each theme's signature default (teal / indigo).
- `lib/constants/app_info.dart` — single-edit source for About: name, version, author, AI
  used, IDE used, last build date, and the "Made with ❤ from India" footer.
- `lib/constants/app_permissions.dart` — declarative permission catalogue (title, reason,
  icon, explicit/implicit group, optional `permission_handler` handle) mirroring the manifest.
- `lib/screens/settings_screen.dart` — hub with three tappable cards.
- `lib/screens/appearance_screen.dart` — Light/Dark/System `SegmentedButton`, preset swatches,
  a custom-painted **HSV color wheel** + brightness slider, a live contrast-checked preview
  chip, and a "Reset to default" action. Applies live and persists.
- `lib/screens/permissions_screen.dart` — Explicit vs Implicit grouped sections with live
  grant-status chips (where queryable) and an "open system settings" action.
- `lib/screens/about_screen.dart` — app icon/name, info card, and the love footer, all from
  `AppInfo`.

## Files changed

- `lib/main.dart` — wraps the app in `ChangeNotifierProvider<AppSettings>` (created +
  `load()`ed) and drives `MaterialApp.theme`/`darkTheme`/`themeMode`. App title set to
  "ContactSphere"; debug banner hidden. `SmartContactsApp` stays self-contained so the
  widget smoke test can pump it directly.
- `lib/screens/contact_list_screen.dart` — full visual redesign while preserving all prior
  behavior (search, secret-contact gating, add/open, import/export, duplicates, groups):
  header with title + lock/groups/⋮ actions (⋮ now includes **Settings**); themed search
  field; relationship-health hero (gradient on Calm, mood-colored glow on Midnight) with a
  custom progress ring and mood face icon; restyled cards with tinted avatar, group tag,
  phone · last-interaction, a streak flame, and a mood-colored score badge; tap-to-expand
  quick-action drawer (Call places a call + logs a provisional interaction; Message/Profile
  open the detail screen); gradient rounded FAB.
- `lib/repositories/interaction_repository.dart` — added `lastInteractionByContact()` and
  `recentInteractionCountByContact({window})`, each a single `GROUP BY` query (no N+1), to
  feed the card last-interaction label and streak badge.
- `test/widget_test.dart` — expects the new "Contacts" header and pumps once for the
  provider; still asserts the search field and add FAB.
- `docs/known-gaps.md` — updated the state-management note (provider now wired for
  `AppSettings`).

## Verification

- `flutter analyze` → No issues found.
- `flutter test` → all 4 tests pass (3 interaction-repository + the widget smoke test).
- No new pub dependencies; no DB schema/model changes. Variant B ("Aura") intentionally not
  implemented.

## Notes / limitations

- The quick-action **Message** button opens the contact detail screen rather than launching
  an SMS app — there is no SMS/url-launcher capability in the project and the plan ruled out
  adding a dependency.
