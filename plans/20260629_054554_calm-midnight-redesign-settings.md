# Calm / Midnight redesign + Settings, Appearance, Permissions, About

**Status:** completed

## Issue / goal

The app currently ships a single hard-coded blue `ThemeData` in `main.dart` and a plain
Material contacts list (`contact_list_screen.dart`). The design brief in `sample/Smart
Contacts.dc.html` defines three mockup directions; we adopt two of them:

- **Light mode → "Calm"** (Variant A): Material 3, cool teal. Background `#f1f7f7`, ink
  `#0f2e2b`, teal accent `#0d9488`, teal→blue gradient hero (`#0fb5a8`→`#3b82f6`).
- **Dark mode → "Midnight"** (Variant C): deep navy `#0a0c16`, card `#12162a`, search
  `#161a2c`, indigo accents `#7c8aff`/`#a8b1ff`, indigo→purple FAB, and a hero card whose
  glow color shifts with the average relationship-health mood.

On top of the two themes we need user-configurable **theme mode** (Light / Dark / System)
and a user-pickable **accent color**, both persisted across launches. And we need three new
screens reachable from the contacts overflow (⋮) menu: **Settings** (hub with 3 cards) →
**Appearance**, **Permissions**, **About**.

There is currently no theme state management (the codebase notes `provider` is declared but
unused). We will wire `provider` + `shared_preferences` (both already in `pubspec.yaml`) for
a small `AppSettings` controller — no new dependencies.

## Files to change / add

### New — theming
- `lib/theme/app_theme.dart` — builds the **Calm** (light) and **Midnight** (dark)
  `ThemeData` from a seed/accent color. Centralizes the mood color scale and gradient/
  surface tokens used by the redesigned screens, plus a `contrastOn(Color)` helper that
  returns black or white based on luminance so accent-colored text/labels stay readable.
- `lib/state/app_settings.dart` — `AppSettings extends ChangeNotifier`: holds `ThemeMode`
  and the selected accent `Color`; loads/saves via `shared_preferences`
  (`theme_mode`, `accent_color` keys; accent stored as an ARGB int). Provides a default
  accent per brightness (teal `#0d9488` for Calm, indigo `#7c8aff` for Midnight) plus a few
  optional preset swatches shown above the wheel as quick-picks.

### New — constants
- `lib/constants/app_info.dart` — single source of truth for the About screen:
  `appName`, `version`, `author`, `aiUsed`, `ideUsed`, `lastBuildDate`, plus the
  "Made with ❤ from India" footer text. Editing this one file updates the About screen.
- `lib/constants/app_permissions.dart` — declarative list of the permissions the app
  uses, each with a title, subtitle/why, icon, and an `explicit` vs `implicit` group flag,
  mirroring `AndroidManifest.xml` (contacts R/W, call phone, read call log, fine/coarse
  location, microphone, biometrics, notifications, media images / legacy storage, BLE
  scan/connect). Drives the Permissions screen.

### New — screens
- `lib/screens/settings_screen.dart` — hub with 3 tappable cards (Appearance, Permissions,
  About) styled in the Calm/Midnight idiom (rounded 20px cards, leading tinted icon).
- `lib/screens/appearance_screen.dart` — Light / Dark / System segmented selector +
  a **full HSV color wheel/spectrum** accent picker (chosen option; custom painter, no new
  dependency): a hue wheel + brightness/saturation slider, with a live preview chip.
  Selecting either updates `AppSettings` live (theme rebuilds immediately) and persists.
  The preview chip and any accent-on-accent text use `contrastOn()` so labels stay legible
  for any picked color.
- `lib/screens/permissions_screen.dart` — permissions from `app_permissions.dart` rendered
  in two grouped sections: **Explicit** (runtime-prompted: contacts, phone/call log, mic,
  location, notifications, photos, biometrics) and **Implicit** (manifest-declared, not
  separately prompted: BLE scan/connect, legacy Bluetooth, internet in debug). Each row
  shows live grant status via `permission_handler` where queryable, with a button to open
  system settings.
- `lib/screens/about_screen.dart` — app icon/name, then a card listing Version, Author,
  AI Used, IDE Used, Last Build Date (all from `app_info.dart`), and the centered
  "Made with ❤ from India" footer.

### Changed — data (for card "last interaction" + streak)
- `lib/repositories/interaction_repository.dart` — add read methods so the list cards can
  show real data (chosen: "Add last-interaction lookup"):
  - `Future<Map<int, DateTime>> lastInteractionByContact()` — one `GROUP BY contact_id`
    query over `interactions` returning the max timestamp per contact (no N+1).
  - `Future<Map<int, int>> recentInteractionCountByContact({Duration window})` — count of
    interactions per contact within a window, used to derive a lightweight "streak" badge.
  The list screen loads both maps once per refresh and maps them onto cards; a contact with
  no interactions simply shows no "last"/streak (the score still renders).

### Changed
- `lib/main.dart` — wrap `SmartContactsApp` in a `ChangeNotifierProvider<AppSettings>`
  (created + `load()`ed before `runApp`), and drive `MaterialApp.theme` /`darkTheme` /
  `themeMode` from it via `AppTheme.calm(accent)` and `AppTheme.midnight(accent)`.
- `lib/screens/contact_list_screen.dart` — redesign to the mockup while preserving all
  existing behavior (search, secret-contact gating, add/open contact, import/export,
  duplicates, groups). Changes:
  - Themed scaffold/background (no hard-coded white fill in the search field).
  - Header row "Contacts" title + action icons (lock toggle, groups, overflow ⋮). The ⋮
    menu gains a **Settings** entry (navigates to `SettingsScreen`) alongside Import /
    Export / Find Duplicates.
  - Relationship-health hero card: gradient (Calm) / glow (Midnight) with avg score `/100`,
    a mood label, and a circular progress ring — replacing the current blue/purple box.
  - Contact cards restyled (tinted initial avatar, name + group tag chip, phone · last
    interaction, mood-colored score badge). Tapping a card still opens the detail screen;
    the long-press/expand quick-action drawer (Call / Message / Profile) is added as an
    inline expandable section, with Call/Message using existing dialer paths and Profile =
    open detail. Score color uses the shared mood scale.
  - FAB restyled (rounded gradient) — same `_addContact` action.
- `docs/known-gaps.md` — update the "State management" bullet (provider is now wired for
  `AppSettings`).

## Theming approach (contrast guarantee)

`AppSettings.accent` seeds `ColorScheme.fromSeed`. For any place we paint text/icons
directly on the raw accent (swatches, score badges, hero), we call
`AppTheme.contrastOn(color)` which computes relative luminance and returns
`Colors.black`/`Colors.white` — satisfying the brief's "text contrasts properly with the
chosen colour" requirement.

## Out of scope (unchanged)

- No DB/schema, repository, or model changes.
- Variant B ("Aura") is not implemented (brief selected Calm + Midnight only).
- Actual Message/SMS sending uses existing capabilities only; no new SMS dependency.
- No new pub dependencies.

## Verification

- `flutter analyze` clean.
- `flutter test` (existing widget smoke test) still passes; adjust the smoke test only if
  the provider wrapper requires it.
- Manual: toggle Light/Dark/System and accent color, confirm persistence across restart and
  legible contrast; open Settings → each of the 3 sub-screens.
