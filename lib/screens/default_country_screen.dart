// lib/screens/default_country_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';

/// Lets the user pick the Default country used to normalize phone numbers when
/// identifying which contact a call belongs to. Reached from the Settings hub.
///
/// Follows the app's settings design (themed search, `AppColors` tokens, rounded
/// cards). The current selection is surfaced in a pinned accent card above the
/// list, and the matching list row is highlighted and scrolled into view — so
/// what's selected is never buried among the ~250 countries.
class DefaultCountryScreen extends StatefulWidget {
  const DefaultCountryScreen({super.key});

  @override
  State<DefaultCountryScreen> createState() => _DefaultCountryScreenState();
}

class _DefaultCountryScreenState extends State<DefaultCountryScreen> {
  late final List<CountryOption> _all = PhoneNormalizer.allCountries();
  final ScrollController _scroll = ScrollController();
  String _query = '';
  bool _didInitialScroll = false;

  static const double _rowExtent = 64; // approx height of a list row

  List<CountryOption> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.isoString.toLowerCase().contains(q) ||
              c.dialCode.contains(q) ||
              '+${c.dialCode}'.contains(q),
        )
        .toList();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Bring the selected row into view the first time the full list is shown, so
  /// the highlighted country isn't hidden far down the list.
  void _scrollToSelected(List<CountryOption> items, String selected) {
    if (_didInitialScroll || _query.isNotEmpty) return;
    _didInitialScroll = true;
    final index = items.indexWhere((c) => c.isoString == selected);
    if (index < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = (index * _rowExtent) - 120; // leave a little context above
      _scroll.jumpTo(target.clamp(0.0, _scroll.position.maxScrollExtent));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final selected = context.watch<AppSettings>().defaultCountryIso;
    final items = _filtered;
    _scrollToSelected(items, selected);

    CountryOption? current;
    for (final c in _all) {
      if (c.isoString == selected) {
        current = c;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Default country')),
      body: Column(
        children: [
          _search(colors, accent),
          if (current != null) _currentCard(colors, accent, current),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colors.mutedText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Used to match incoming and dialed numbers to your contacts',
                    style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'No countries match "$_query"',
                      style: TextStyle(color: colors.mutedText),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final c = items[i];
                      return _countryRow(
                        colors: colors,
                        accent: accent,
                        country: c,
                        selected: c.isoString == selected,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _search(AppColors colors, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.searchFill,
          borderRadius: BorderRadius.circular(18),
          border: colors.isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.06))
              : null,
        ),
        child: TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search country or code',
            prefixIcon: Icon(Icons.search, color: accent),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  /// Pinned card showing the current selection, so it's unmistakable regardless
  /// of where its row sits in the long list.
  Widget _currentCard(AppColors colors, Color accent, CountryOption current) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: colors.isDark ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.55), width: 1.5),
        ),
        child: Row(
          children: [
            _isoBadge(accent, current.isoString, selected: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected',
                    style: TextStyle(
                      color: accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '+${current.dialCode}',
              style: TextStyle(
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A leading rounded-square badge showing the 2-letter ISO code. Chosen over
  /// flag emoji, which many Android builds render as bare letters anyway.
  Widget _isoBadge(Color accent, String iso, {required bool selected}) {
    final bg = selected ? accent : accent.withValues(alpha: 0.14);
    final fg = selected ? AppTheme.contrastOn(accent) : accent;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        iso,
        style: TextStyle(
          color: fg,
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// A selectable country row. The selected row is filled and bordered in the
  /// accent with a trailing check; unselected rows carry no radio dot, which is
  /// what keeps the long list from reading as a wall of controls.
  Widget _countryRow({
    required AppColors colors,
    required Color accent,
    required CountryOption country,
    required bool selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? accent.withValues(alpha: colors.isDark ? 0.16 : 0.10)
            : colors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            context.read<AppSettings>().setDefaultCountryIso(country.isoString);
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.55)
                    : (colors.isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04)),
                width: selected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                _isoBadge(accent, country.isoString, selected: selected),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    country.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '+${country.dialCode}',
                  style: TextStyle(
                    color: selected ? accent : colors.mutedText,
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.check_circle, color: accent, size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
