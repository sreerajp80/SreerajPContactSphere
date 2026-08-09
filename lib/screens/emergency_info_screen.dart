// lib/screens/emergency_info_screen.dart
//
// Settings → Emergency info. Edits the card that can be shown on the lock
// screen without unlocking the phone.
//
// The record lives in the encrypted DB like everything else. Only the lines
// switched on here are copied to the plaintext native mirror the lock-screen
// card reads (see EmergencyInfoRepository.pushMirror and docs/security.md), so
// every field carries its own eye toggle and the whole feature is off until the
// user turns it on.
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/core/constants/blood_groups.dart';
import 'package:smart_contacts_dialer/models/emergency_info.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/emergency_info_repository.dart';
import 'package:smart_contacts_dialer/services/emergency_card_service.dart';
import 'package:smart_contacts_dialer/services/emergency_share_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/contact_search_picker_sheet.dart';
import 'package:smart_contacts_dialer/widgets/number_picker_sheet.dart';

class EmergencyInfoScreen extends StatefulWidget {
  const EmergencyInfoScreen({super.key});

  @override
  State<EmergencyInfoScreen> createState() => _EmergencyInfoScreenState();
}

class _EmergencyInfoScreenState extends State<EmergencyInfoScreen>
    with WidgetsBindingObserver {
  final EmergencyInfoRepository _repo = EmergencyInfoRepository();
  final EmergencyCardService _cardService = EmergencyCardService();

  EmergencyInfo _info = EmergencyInfo();

  /// Why the system may be keeping the card off the lock screen. Refreshed on
  /// resume, because the user fixes it in system settings and comes back.
  EmergencyNotificationStatus _notif = const EmergencyNotificationStatus();
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;

  final _ownerCtrl = TextEditingController();

  /// Picked blood group, or null when not set. A value saved before the picker
  /// existed that cannot be cleaned up is kept and offered as an extra entry.
  String? _blood;
  String? _bloodLegacy;

  final _allergiesCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the system settings the warning row sent them to.
    if (state == AppLifecycleState.resumed) _refreshNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ownerCtrl.dispose();
    _allergiesCtrl.dispose();
    _medsCtrl.dispose();
    _conditionsCtrl.dispose();
    _notesCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final info = await _repo.load();
    if (!mounted) return;
    // Nothing saved yet: start the owner name from the "Self" contact so the
    // card is useful with one tap.
    if ((info.ownerName ?? '').isEmpty) {
      info.ownerName = await _selfName();
    }
    if (!mounted) return;
    setState(() {
      _info = info;
      _ownerCtrl.text = info.ownerName ?? '';
      final blood = info.bloodGroup?.trim() ?? '';
      if (blood.isNotEmpty) {
        final standard = normalizeBloodGroup(blood);
        _blood = standard ?? blood;
        if (standard == null) _bloodLegacy = blood;
      }
      _allergiesCtrl.text = info.allergies ?? '';
      _medsCtrl.text = info.medications ?? '';
      _conditionsCtrl.text = info.conditions ?? '';
      _notesCtrl.text = info.notes ?? '';
      _addressCtrl.text = info.address ?? '';
      _loading = false;
    });
    await _refreshNotificationStatus();
  }

  Future<void> _refreshNotificationStatus() async {
    final status = await _cardService.status();
    if (!mounted) return;
    setState(() => _notif = status);
  }

  Future<String?> _selfName() async {
    try {
      final all = await ContactRepository().getAllContacts();
      for (final c in all) {
        if (c.isSelf) return c.fullName;
      }
    } catch (_) {
      // Best-effort prefill only.
    }
    return null;
  }

  void _touch(VoidCallback change) {
    setState(() {
      change();
      _dirty = true;
    });
  }

  /// Copies the text fields back into the model, then saves and republishes.
  Future<void> _save() async {
    setState(() => _saving = true);
    _info
      ..ownerName = _ownerCtrl.text.trim()
      ..bloodGroup = _blood ?? ''
      ..allergies = _allergiesCtrl.text.trim()
      ..medications = _medsCtrl.text.trim()
      ..conditions = _conditionsCtrl.text.trim()
      ..notes = _notesCtrl.text.trim()
      ..address = _addressCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _repo.save(_info);
      // The channel only exists once a card has been published.
      await _refreshNotificationStatus();
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            !_info.enabled
                ? 'Saved. The lock screen card is off.'
                : _info.hasNothingToShow
                ? 'Saved. Nothing is switched on to show yet.'
                : 'Saved. The card is on your lock screen.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave without saving?'),
        content: const Text('Your changes to the emergency card are not saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Future<void> _showShareOptions() async {
    final currentInfo = EmergencyInfo(
      enabled: _info.enabled,
      ownerName: _ownerCtrl.text.trim(),
      showOwnerName: _info.showOwnerName,
      bloodGroup: _blood ?? '',
      showBloodGroup: _info.showBloodGroup,
      allergies: _allergiesCtrl.text.trim(),
      showAllergies: _info.showAllergies,
      medications: _medsCtrl.text.trim(),
      showMedications: _info.showMedications,
      conditions: _conditionsCtrl.text.trim(),
      showConditions: _info.showConditions,
      notes: _notesCtrl.text.trim(),
      showNotes: _info.showNotes,
      address: _addressCtrl.text.trim(),
      showAddress: _info.showAddress,
      organDonor: _info.organDonor,
      showOrganDonor: _info.showOrganDonor,
      contacts: _info.contacts,
    );

    if (currentInfo.hasNothingToShow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing on the card is switched on to share.')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Share as Text'),
              subtitle: const Text('Send formatted details via messaging or email'),
              onTap: () {
                Navigator.of(ctx).pop();
                EmergencyShareService().shareAsText(currentInfo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Share as Card Image'),
              subtitle: const Text('Send visual ICE card image (PNG)'),
              onTap: () {
                Navigator.of(ctx).pop();
                EmergencyShareService().shareAsImage(currentInfo);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmLeave()) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Emergency info'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share ICE Card',
              onPressed: _loading || _saving ? null : _showShareOptions,
            ),
            TextButton(
              onPressed: _loading || _saving ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _warningBanner(colors),
                  const SizedBox(height: 12),
                  _masterCard(colors),
                  const SizedBox(height: 12),
                  _medicalCard(colors),
                  const SizedBox(height: 12),
                  _contactsCard(colors),
                  const SizedBox(height: 12),
                  _previewCard(colors),
                ],
              ),
      ),
    );
  }

  // ---- sections ----

  Widget _warningBanner(AppColors colors) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_open_outlined, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Anything you switch on here can be read by anyone holding your '
              'phone, without your PIN. That is the point of an emergency card — '
              'so switch on only what a stranger should see.',
              style: TextStyle(fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _masterCard(AppColors colors) => _card(
    colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _info.enabled,
          title: const Text(
            'Show on lock screen',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'Adds a persistent notification with 1-tap emergency call action. '
            'Opens the card over the lock screen with a high-contrast emergency QR code.',
          ),
          onChanged: (v) => _touch(() => _info.enabled = v),
        ),
        if (_info.enabled) ..._lockScreenHelp(),
        const Divider(height: 20),
        TextField(
          controller: _ownerCtrl,
          decoration: const InputDecoration(
            labelText: 'Name shown on the card',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _dirty = true,
        ),
        _showRow(
          'Show the name',
          _info.showOwnerName,
          (v) => _touch(() => _info.showOwnerName = v),
        ),
      ],
    ),
  );

  /// Status + help shown under the master switch.
  ///
  /// Android gives no way to force a notification onto the lock screen, and no
  /// way to read the system's "hide silent notifications" choice, so the honest
  /// thing is to report what we can see and point at the setting for the rest.
  List<Widget> _lockScreenHelp() {
    final theme = Theme.of(context);
    final blocked = _notif.isBlocked;
    final silent = _notif.mayBeHiddenOnLockScreen;

    return [
      if (blocked || silent)
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: blocked
                ? theme.colorScheme.errorContainer.withValues(alpha: 0.45)
                : theme.colorScheme.tertiaryContainer.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    blocked
                        ? Icons.notifications_off_outlined
                        : Icons.notifications_paused_outlined,
                    size: 20,
                    color: blocked
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      blocked
                          ? 'Notifications for this app are switched off, so the '
                                'card cannot show anywhere.'
                          : 'This notification is set to silent. The lock screen '
                                'hides silent notifications on many phones.',
                      style: const TextStyle(fontSize: 13, height: 1.35),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _cardService.openChannelSettings,
                  child: const Text('Open notification settings'),
                ),
              ),
            ],
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _showLockScreenTips,
          icon: const Icon(Icons.help_outline, size: 18),
          label: const Text('Not seeing it on the lock screen?'),
        ),
      ),
    ];
  }

  Future<void> _showLockScreenTips() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Not seeing it on the lock screen?'),
        content: const Text(
          'The phone decides which notifications the lock screen shows. Check '
          'this system setting:\n\n'
          'Settings → Notifications → Notifications on lock screen\n\n'
          'Pick "Show conversations, default and silent". If it is set to '
          '"Hide silent notifications" or "Don\'t show any notifications", the '
          'emergency card cannot appear there — no app can override that.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open ?? false) await _cardService.openLockScreenSettings();
  }

  Widget _medicalCard(AppColors colors) => _card(
    colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Medical details', colors),
        const SizedBox(height: 4),
        _bloodGroupField(),
        _field(
          _allergiesCtrl,
          EmergencyInfo.labelAllergies,
          'e.g. Penicillin, peanuts',
          _info.showAllergies,
          (v) => _touch(() => _info.showAllergies = v),
          lines: 2,
        ),
        _field(
          _medsCtrl,
          EmergencyInfo.labelMedications,
          'Medicines you take regularly',
          _info.showMedications,
          (v) => _touch(() => _info.showMedications = v),
          lines: 2,
        ),
        _field(
          _conditionsCtrl,
          EmergencyInfo.labelConditions,
          'e.g. Diabetes, epilepsy',
          _info.showConditions,
          (v) => _touch(() => _info.showConditions = v),
          lines: 2,
        ),
        _field(
          _addressCtrl,
          EmergencyInfo.labelAddress,
          'Home address',
          _info.showAddress,
          (v) => _touch(() => _info.showAddress = v),
          lines: 2,
        ),
        _field(
          _notesCtrl,
          EmergencyInfo.labelNotes,
          'Anything else a helper should know',
          _info.showNotes,
          (v) => _touch(() => _info.showNotes = v),
          lines: 3,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _info.organDonor,
          title: const Text('Organ donor'),
          onChanged: (v) => _touch(() => _info.organDonor = v),
        ),
        if (_info.organDonor)
          _showRow(
            'Show "Organ donor"',
            _info.showOrganDonor,
            (v) => _touch(() => _info.showOrganDonor = v),
          ),
      ],
    ),
  );

  Widget _contactsCard(AppColors colors) => _card(
    colors,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('People to call', colors),
        Text(
          'Each one gets a Call button on the card. The call is placed straight '
          'from the lock screen.',
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
        const SizedBox(height: 8),
        if (_info.contacts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No one added yet.',
              style: TextStyle(color: colors.mutedText),
            ),
          ),
        for (var i = 0; i < _info.contacts.length; i++)
          _contactRow(_info.contacts[i], i, colors),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _addFromContacts,
              icon: const Icon(Icons.person_add_alt),
              label: const Text('From contacts'),
            ),
            OutlinedButton.icon(
              onPressed: () => _editByHand(null),
              icon: const Icon(Icons.dialpad),
              label: const Text('Type a number'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _contactRow(EmergencyContactEntry entry, int index, AppColors colors) {
    final relation = (entry.relationLabel ?? '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  relation.isEmpty
                      ? entry.displayName
                      : '${entry.displayName} · $relation',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  entry.number,
                  style: TextStyle(color: colors.mutedText, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: entry.showOnLock ? 'Shown on the card' : 'Hidden',
            icon: Icon(
              entry.showOnLock ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () => _touch(() => entry.showOnLock = !entry.showOnLock),
          ),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editByHand(index),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.close),
            onPressed: () => _touch(() => _info.contacts.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _previewCard(AppColors colors) {
    final rows = _info.enabled
        ? EmergencyInfo(
            enabled: true,
            ownerName: _ownerCtrl.text,
            showOwnerName: _info.showOwnerName,
            bloodGroup: _blood ?? '',
            showBloodGroup: _info.showBloodGroup,
            allergies: _allergiesCtrl.text,
            showAllergies: _info.showAllergies,
            medications: _medsCtrl.text,
            showMedications: _info.showMedications,
            conditions: _conditionsCtrl.text,
            showConditions: _info.showConditions,
            notes: _notesCtrl.text,
            showNotes: _info.showNotes,
            address: _addressCtrl.text,
            showAddress: _info.showAddress,
            organDonor: _info.organDonor,
            showOrganDonor: _info.showOrganDonor,
          ).visibleRows()
        : const <EmergencyRow>[];
    final people = _info.enabled
        ? _info.visibleContacts()
        : const <EmergencyContactEntry>[];

    return _card(
      colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('What a stranger will see', colors),
          const SizedBox(height: 6),
          if (!_info.enabled)
            Text(
              'Nothing — the card is switched off.',
              style: TextStyle(color: colors.mutedText),
            )
          else if (rows.isEmpty && people.isEmpty)
            Text(
              'Nothing yet. Fill in a field and switch it on.',
              style: TextStyle(color: colors.mutedText),
            )
          else ...[
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('${r.label}: ${r.value}'),
              ),
            for (final c in people)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('${c.displayName} — ${c.number}'),
              ),
          ],
          const SizedBox(height: 6),
          Text(
            'Tap Save to apply changes to the lock screen.',
            style: TextStyle(color: colors.mutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ---- adding people ----

  /// Picks a contact, then one of their numbers, and snapshots name + number.
  Future<void> _addFromContacts() async {
    final picked = await showContactSearchPickerSheet(
      context,
      title: 'Choose a person to call',
      requirePhone: true,
    );
    if (picked == null || !mounted) return;

    // The picker returns a slim summary, which carries the primary number only.
    // Load the rest on demand so a contact with several numbers still gets the
    // chooser; on failure fall back to the primary the summary already has.
    List<PhoneNumber> numbers = picked.phoneNumbers;
    if (picked.id != null) {
      try {
        final all = await ContactRepository().getPhoneNumbers(picked.id!);
        if (all.isNotEmpty) numbers = all;
      } catch (_) {
        // Keep the summary's primary number.
      }
    }
    if (!mounted || numbers.isEmpty) return;

    PhoneNumber? number = numbers.first;
    if (numbers.length > 1) {
      number = await showNumberPickerSheet(
        context,
        displayName: picked.fullName,
        numbers: numbers,
      );
    }
    if (number == null || !mounted) return;

    _touch(() {
      _info.contacts.add(
        EmergencyContactEntry(
          contactId: picked.id,
          displayName: picked.fullName,
          number: number!.number,
          relationLabel: number.label,
          sortOrder: _info.contacts.length,
        ),
      );
    });
  }

  /// Adds ([index] null) or edits a hand-typed entry.
  Future<void> _editByHand(int? index) async {
    final existing = index == null ? null : _info.contacts[index];
    final nameCtrl = TextEditingController(text: existing?.displayName ?? '');
    final numberCtrl = TextEditingController(text: existing?.number ?? '');
    final relationCtrl = TextEditingController(
      text: existing?.relationLabel ?? '',
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == null ? 'Add a person' : 'Edit person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
            ),
            TextField(
              controller: numberCtrl,
              decoration: const InputDecoration(labelText: 'Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: relationCtrl,
              decoration: const InputDecoration(
                labelText: 'Relation (optional)',
                hintText: 'e.g. Wife, Doctor',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    final name = nameCtrl.text.trim();
    final number = numberCtrl.text.trim();
    final relation = relationCtrl.text.trim();
    nameCtrl.dispose();
    numberCtrl.dispose();
    relationCtrl.dispose();
    if (saved != true || !mounted) return;
    if (name.isEmpty || number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A name and a number are both needed.')),
      );
      return;
    }
    _touch(() {
      if (existing == null) {
        _info.contacts.add(
          EmergencyContactEntry(
            displayName: name,
            number: number,
            relationLabel: relation.isEmpty ? null : relation,
            sortOrder: _info.contacts.length,
          ),
        );
      } else {
        existing
          ..displayName = name
          ..number = number
          ..relationLabel = relation.isEmpty ? null : relation
          // A hand-edited entry no longer tracks the contact it came from.
          ..contactId = existing.contactId;
      }
    });
  }

  // ---- small building blocks ----

  Widget _card(AppColors colors, {required Widget child}) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    decoration: BoxDecoration(
      color: colors.cardSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );

  Widget _sectionTitle(String text, AppColors colors) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    ),
  );

  /// Blood group is a closed set, so it is picked, never typed — a typo here
  /// would be read off the lock screen by a stranger in an emergency.
  Widget _bloodGroupField() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String?>(
          initialValue: _blood,
          decoration: const InputDecoration(
            labelText: EmergencyInfo.labelBloodGroup,
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(child: Text('Not set')),
            for (final g in [...kBloodGroups, ?_bloodLegacy])
              DropdownMenuItem<String?>(value: g, child: Text(g)),
          ],
          onChanged: (v) => setState(() {
            _blood = v;
            _dirty = true;
          }),
        ),
        _showRow(
          'Show on lock screen',
          _info.showBloodGroup,
          (v) => _touch(() => _info.showBloodGroup = v),
        ),
      ],
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label,
    String hint,
    bool show,
    ValueChanged<bool> onShowChanged, {
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          minLines: lines,
          maxLines: lines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() => _dirty = true),
        ),
        _showRow('Show on lock screen', show, onShowChanged),
      ],
    ),
  );

  /// The per-field "show on lock screen" toggle, kept compact so it reads as a
  /// property of the field above it rather than a separate setting.
  Widget _showRow(String label, bool value, ValueChanged<bool> onChanged) => Row(
    children: [
      Icon(
        value ? Icons.visibility : Icons.visibility_off,
        size: 18,
        color: Theme.of(context).extension<AppColors>()!.mutedText,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).extension<AppColors>()!.mutedText,
          ),
        ),
      ),
      Switch(value: value, onChanged: onChanged),
    ],
  );
}
