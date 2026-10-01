// lib/screens/blocked_numbers_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/repositories/flagged_number_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Blocked-numbers management, reached from Settings → Contacts. Numbers here
/// are rejected by the native call-screening service before the phone rings
/// (exact match after normalizing to E.164 under the Default country). Also
/// hosts the "Block unknown" toggle for calls with no / hidden number.
class BlockedNumbersScreen extends StatefulWidget {
  const BlockedNumbersScreen({super.key});

  @override
  State<BlockedNumbersScreen> createState() => _BlockedNumbersScreenState();
}

class _BlockedNumbersScreenState extends State<BlockedNumbersScreen> {
  final FlaggedNumberRepository _repo = FlaggedNumberRepository();

  List<FlaggedNumber> _numbers = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final numbers = await _repo.listByKind(
        FlaggedNumberRepository.kindBlocked,
      );
      if (!mounted) return;
      setState(() {
        _numbers = numbers;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _numbers = const [];
        _loading = false;
      });
    }
  }

  Future<void> _addNumber() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final number = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.titleBlockNumber),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.labelPhoneNumber,
            hintText: l10n.hintPhoneNumberExample,
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(l10n.actionBlock),
          ),
        ],
      ),
    );
    if (number == null || number.trim().isEmpty || !mounted) return;
    final added = await _repo.add(
      number,
      kind: FlaggedNumberRepository.kindBlocked,
    );
    if (!mounted) return;
    if (!added) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorNotAPhoneNumber)));
      return;
    }
    await _load();
  }

  Future<void> _remove(FlaggedNumber entry) async {
    await _repo.remove(entry.id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).msgNumberUnblocked(entry.number),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.titleBlockedNumbers)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _blockUnknownCard(colors, l10n),
                const SizedBox(height: 12),
                _explainerNote(colors, l10n),
                const SizedBox(height: 12),
                _addNumberCard(colors, l10n),
                const SizedBox(height: 12),
                if (_numbers.isEmpty)
                  _emptyNote(colors, l10n)
                else
                  _numbersCard(colors, l10n),
              ],
            ),
    );
  }

  /// Reject calls that carry no / a hidden number.
  Widget _blockUnknownCard(AppColors colors, AppLocalizations l10n) {
    final accent = Theme.of(context).colorScheme.primary;
    final enabled = context.watch<AppSettings>().blockUnknownCallers;

    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        value: enabled,
        activeThumbColor: accent,
        onChanged: (v) => context.read<AppSettings>().setBlockUnknownCallers(v),
        title: Text(
          l10n.labelBlockUnknownCallers,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          l10n.descBlockUnknownCallers,
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
      ),
    );
  }

  Widget _explainerNote(AppColors colors, AppLocalizations l10n) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: colors.mutedText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                l10n.descBlockedNumbersInfo,
                style: TextStyle(color: colors.mutedText, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addNumberCard(AppColors colors, AppLocalizations l10n) {
    final accent = Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _addNumber,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.playlist_add, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.actionAddNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.descAddNumber,
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.mutedText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyNote(AppColors colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        l10n.emptyBlockedNumbers,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.mutedText, fontSize: 13.5),
      ),
    );
  }

  Widget _numbersCard(AppColors colors, AppLocalizations l10n) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                l10n.labelBlockedCount(_numbers.length),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final entry in _numbers) _numberTile(colors, l10n, entry),
          ],
        ),
      ),
    );
  }

  Widget _numberTile(
    AppColors colors,
    AppLocalizations l10n,
    FlaggedNumber entry,
  ) {
    const red = Color(0xFFEF4444);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.block, color: red, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.number,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  // The date is formatted by MaterialLocalizations, not by an
                  // ARB DateTime placeholder: intl ships no CLDR date data for
                  // Sanskrit, so DateFormat.yMMMd('sa') throws. Material's
                  // formatter falls back cleanly on any locale it does not
                  // localize.
                  l10n.labelBlockedOn(
                    MaterialLocalizations.of(
                      context,
                    ).formatShortDate(entry.createdAt),
                  ),
                  style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: colors.mutedText, size: 20),
            tooltip: l10n.tooltipUnblock,
            onPressed: () => _remove(entry),
          ),
        ],
      ),
    );
  }
}
