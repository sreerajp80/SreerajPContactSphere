// lib/screens/speed_dial_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/speed_dial_entry.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/speed_dial_repository.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/contact_search_picker_sheet.dart';
import 'package:smart_contacts_dialer/widgets/number_picker_sheet.dart';

/// Asks the user who key [slot] should call, and saves it.
///
/// Shared by the keypad (long-press an empty key) and the Speed Dial settings
/// screen, so both routes behave identically: pick a contact, pick which of its
/// numbers when it has more than one, write the row.
///
/// Returns true when a number was saved. Secret contacts never reach here — the
/// picker hides them, and [SpeedDialRepository.assign] refuses them anyway.
Future<bool> assignSpeedDialSlot(
  BuildContext context,
  int slot, {
  SpeedDialRepository? repository,
  ContactRepository? contacts,
}) async {
  if (!SpeedDialEntry.isValidSlot(slot)) return false;

  final picked = await showContactSearchPickerSheet(
    context,
    title: 'Speed dial $slot',
    requirePhone: true,
  );
  if (picked == null || picked.id == null) return false;

  // The picker returns a slim summary carrying only the primary number, so load
  // the full record to see whether there is a choice of numbers to make.
  final repo = contacts ?? ContactRepository();
  final full = await repo.getContactById(picked.id!);
  final numbers = full?.phoneNumbers ?? picked.phoneNumbers;
  if (numbers.isEmpty) return false;

  var chosen = numbers.first;
  if (numbers.length > 1) {
    if (!context.mounted) return false;
    final pick = await showNumberPickerSheet(
      context,
      displayName: full?.fullName ?? picked.fullName,
      numbers: numbers,
    );
    if (pick == null) return false; // dismissed → leave the key as it was
    chosen = pick;
  }

  return (repository ?? SpeedDialRepository()).assign(
    slot: slot,
    phoneNumber: chosen.number,
    contactId: picked.id,
  );
}

/// Settings screen listing keypad keys 1–9 and who each one calls.
///
/// The same assignments the keypad uses: holding a key on the dialer places the
/// call, and holding an unassigned key opens the picker this screen also uses.
class SpeedDialScreen extends StatefulWidget {
  const SpeedDialScreen({super.key});

  @override
  State<SpeedDialScreen> createState() => _SpeedDialScreenState();
}

class _SpeedDialScreenState extends State<SpeedDialScreen> {
  final SpeedDialRepository _repo = SpeedDialRepository();

  Map<int, SpeedDialEntry> _entries = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    Map<int, SpeedDialEntry> entries;
    try {
      entries = await _repo.all();
    } catch (_) {
      entries = const {};
    }
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _assign(int slot) async {
    final saved = await assignSpeedDialSlot(context, slot, repository: _repo);
    if (saved) await _load();
  }

  Future<void> _clear(int slot) async {
    await _repo.clear(slot);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Speed Dial')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _intro(colors),
                const SizedBox(height: 12),
                for (
                  var slot = SpeedDialEntry.minSlot;
                  slot <= SpeedDialEntry.maxSlot;
                  slot++
                ) ...[
                  _slotTile(slot, _entries[slot], colors),
                  const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }

  Widget _intro(AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.touch_app_outlined, color: colors.mutedText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Hold a keypad key on the dialer to call the person saved on '
                'it. Holding works only when the number box is empty. Secret '
                'contacts cannot be saved to a key.',
                style: TextStyle(color: colors.mutedText, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotTile(int slot, SpeedDialEntry? entry, AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final filled = entry != null;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => _assign(slot),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: filled ? 0.16 : 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$slot',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: filled ? accent : colors.mutedText,
            ),
          ),
        ),
        title: Text(
          filled ? entry.label : 'Not set',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: filled ? null : colors.mutedText,
          ),
        ),
        subtitle: filled
            ? Text(
                entry.phoneNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.mutedText, fontSize: 12.5),
              )
            : Text(
                'Tap to choose a contact',
                style: TextStyle(color: colors.mutedText, fontSize: 12.5),
              ),
        trailing: filled
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Remove from key $slot',
                onPressed: () => _clear(slot),
              )
            : Icon(Icons.chevron_right, color: colors.mutedText),
      ),
    );
  }
}
