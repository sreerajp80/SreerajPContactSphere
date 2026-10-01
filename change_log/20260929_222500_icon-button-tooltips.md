# Localized tooltips on every icon-only button

Implements plan: `plans/20260929_220640_icon-button-tooltips.md`

## What changed

### Tooltips added (engineering standard §7.8)

| File | Control | Tooltip |
|---|---|---|
| `lib/main.dart` | close button on the contact picker | `actionClose` |
| `lib/screens/audit_entry_detail_screen.dart` | back arrow | `tooltipBack` |
| `lib/screens/audit_log_screen.dart` | overflow menu | `tooltipMore` |
| `lib/screens/contact_detail_screen.dart` | call button on a number row | `tooltipCall` |
| `lib/screens/contact_index_health_screen.dart` | refresh | `tooltipCheckAgain` (new) |
| `lib/screens/groups_screen.dart` | add button | `tooltipCreateGroup` (new) |
| `lib/screens/groups_screen.dart` | per-group menu | `tooltipMore` |
| `lib/screens/relationship_screen.dart` | sheet close | `actionClose` |
| `lib/screens/smart_redial_settings_screen.dart` | cancel a waiting redial | `tooltipCancelRedial` (new) |
| `lib/screens/backup/backup_restore_screen.dart` | show / hide password | `tooltipShowPassword` / `tooltipHidePassword` (new) |
| `lib/screens/settings/cloud_backup_settings_screen.dart` | restore | `actionRestore` |
| `lib/screens/settings/online_sync_settings_screen.dart` | remove account | `tooltipRemoveAccount` (new) |
| `lib/screens/sync/sync_views.dart` | copy | `actionCopy` |
| `lib/widgets/relationship_editor.dart` | three back arrows | `tooltipBack` |

### English literal tooltips replaced

- `lib/screens/relationship_screen.dart`: "Centre sphere here" → `tooltipCentreSphere` (new),
  "Open profile" → `tooltipOpenProfile` (new), "Options" → `tooltipMore`.
- `lib/screens/ble_receive_screen.dart`: "Scan again" → `tooltipScanAgain` (new).

Both files now import `AppLocalizations`. Their other English text is unchanged (separate finding).
`dart format` also re-wrapped a few existing lines in these two files.

### New ARB keys

Added to `app_en.arb` (with descriptions), `app_ml.arb` and `app_sa.arb`, then ran
`flutter gen-l10n`.

| Key | English | Malayalam | Sanskrit |
|---|---|---|---|
| `tooltipCheckAgain` | Check again | വീണ്ടും പരിശോധിക്കുക | पुनः परीक्ष्यताम् |
| `tooltipCreateGroup` | Create group | ഗ്രൂപ്പ് സൃഷ്ടിക്കുക | समूहः सृज्यताम् |
| `tooltipCentreSphere` | Centre sphere here | ഇവിടെ കേന്ദ്രീകരിക്കുക | अत्र केन्द्रीक्रियताम् |
| `tooltipOpenProfile` | Open profile | പ്രൊഫൈൽ തുറക്കുക | परिचयः उद्घाट्यताम् |
| `tooltipCancelRedial` | Cancel redial | വീണ്ടും വിളി റദ്ദാക്കുക | पुनराह्वानं निरस्यताम् |
| `tooltipScanAgain` | Scan again | വീണ്ടും തിരയുക | पुनः अन्विष्यताम् |
| `tooltipShowPassword` | Show password | പാസ്‌വേഡ് കാണിക്കുക | गुप्तशब्दः दर्श्यताम् |
| `tooltipHidePassword` | Hide password | പാസ്‌വേഡ് മറയ്ക്കുക | गुप्तशब्दः गोप्यताम् |
| `tooltipRemoveAccount` | Remove account | അക്കൗണ്ട് നീക്കുക | उपयोक्तृविवरणम् अपनीयताम् |

**Needs native-reader review:** all nine Malayalam and Sanskrit strings above (§8.5.4 review rule).

### Tests

- New `test/helpers/tooltip_checks.dart`: `expectAllIconButtonsHaveTooltips` checks every
  `IconButton`, non-extended `FloatingActionButton` and `PopupMenuButton` on screen.
- Called in the screen tests that already run in all three languages: `about_screen_l10n_test`,
  `blocked_numbers_screen_l10n_test`, `core_screens_l10n_test` (Contacts, Dialer, Recents tabs),
  `help_screens_l10n_test`, `phase2e_screens_l10n_test`, `settings_screens_l10n_test` and
  `test/screens/language_settings_screen_test`.
- New `test/l10n/icon_tooltip_source_test.dart`: reads every `.dart` file under `lib/` and fails
  when an `IconButton`, `FloatingActionButton` or `PopupMenuButton` has no `tooltip:`, or when a
  tooltip is a string literal. This also covers screens that have no widget test.

## Checks

- `flutter analyze`: no issues.
- `flutter test test/l10n test/screens test/state`: 215 passed (213 before, plus the 2 new tests).
  This includes the parity, label-length and Sanskrit-delegate tests.
- Also passed, one file per run: `widget_test`, `help_screens_test`, `audit_log_test`,
  `features_screen_test`, `in_call_route_recovery_test`, `backup_service_test`.
