// lib/widgets/relationship_editor.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/widgets/avatar_initial.dart';

/// The relationship-type names to offer in the picker: the user-managed list
/// from [AppSettings], or the built-in presets when that list is empty (so the
/// picker is never blank).
List<String> _relationshipTypesFrom(BuildContext context) {
  final names = context.read<AppSettings>().relationshipNames;
  return names.isEmpty ? RelationshipTypes.presets : names;
}

/// The user's choice from the relationship editor: which contact to link and
/// the relationship type (from the owner's perspective).
class RelationshipChoice {
  final int relatedContactId;
  final String relatedContactName;
  final String type;

  const RelationshipChoice({
    required this.relatedContactId,
    required this.relatedContactName,
    required this.type,
  });
}

/// Opens a bottom sheet to add a relationship: pick another contact (searchable,
/// excluding [excludeIds] and the owner), then pick a type. Returns the choice,
/// or null if dismissed. Shared by the detail, add/edit and sphere screens.
Future<RelationshipChoice?> showRelationshipEditor(
  BuildContext context, {
  required int? ownerContactId,
  required Set<int> excludeIds,
}) {
  final types = _relationshipTypesFrom(context);
  return showModalBottomSheet<RelationshipChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _RelationshipEditorSheet(
      ownerContactId: ownerContactId,
      excludeIds: excludeIds,
      types: types,
    ),
  );
}

/// Opens a bottom sheet to change the type of an existing relationship. Shows the
/// same preset chips as the add flow, with [currentType] highlighted. Returns the
/// newly picked type, or null if dismissed. [personName] names the related contact
/// in the prompt (pass the first name).
Future<String?> showRelationshipTypePicker(
  BuildContext context, {
  required String personName,
  String? currentType,
}) {
  final types = _relationshipTypesFrom(context);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TypePickerSheet(
      personName: personName,
      currentType: currentType,
      types: types,
    ),
  );
}

/// The preset relationship types as tappable chips. Shared by the add flow's
/// type step and the standalone [showRelationshipTypePicker]. When [currentType]
/// matches a preset, that chip shows as selected.
class _TypeChipGrid extends StatelessWidget {
  final List<String> types;
  final String? currentType;
  final ValueChanged<String> onSelected;

  const _TypeChipGrid({
    required this.types,
    this.currentType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types
          .map(
            (t) => ChoiceChip(
              label: Text(t),
              selected: t == currentType,
              onSelected: (_) => onSelected(t),
            ),
          )
          .toList(),
    );
  }
}

/// Standalone type-picker sheet used to edit an existing relationship's type.
class _TypePickerSheet extends StatelessWidget {
  final String personName;
  final String? currentType;
  final List<String> types;

  const _TypePickerSheet({
    required this.personName,
    this.currentType,
    required this.types,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'How is $personName related?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _TypeChipGrid(
                      types: types,
                      currentType: currentType,
                      onSelected: (t) => Navigator.of(context).pop(t),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelationshipEditorSheet extends StatefulWidget {
  final int? ownerContactId;
  final Set<int> excludeIds;
  final List<String> types;

  const _RelationshipEditorSheet({
    required this.ownerContactId,
    required this.excludeIds,
    required this.types,
  });

  @override
  State<_RelationshipEditorSheet> createState() =>
      _RelationshipEditorSheetState();
}

class _RelationshipEditorSheetState extends State<_RelationshipEditorSheet> {
  final _repository = ContactRepository();

  List<Contact> _all = [];
  String _query = '';
  bool _loading = true;

  /// Once a contact is chosen we switch to the type-picker step.
  Contact? _picked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final contacts = await _repository.getAllContacts();
      if (!mounted) return;
      setState(() {
        _all = contacts
            .where(
              (c) =>
                  c.id != null &&
                  c.id != widget.ownerContactId &&
                  !widget.excludeIds.contains(c.id),
            )
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _all = [];
        _loading = false;
      });
    }
  }

  List<Contact> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return _all;
    // Mirror the Contacts page name search: a plain lowercase substring match,
    // or [nameMatches] — a transliteration-key match so an English-script
    // (Manglish) query finds a Malayalam-script name and spelling variants
    // (sreeraj/sriraj) fold together, plus a sound-only match so spellings that
    // disagree about vowels still meet (Michael / മൈക്കിൾ).
    final like = q.toLowerCase();
    return _all.where((c) {
      if (c.fullName.toLowerCase().contains(like)) return true;
      return nameMatches(q, c.fullName);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: _picked == null ? _buildContactPicker() : _buildTypePicker(),
      ),
    );
  }

  Widget _buildContactPicker() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Link a contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search contacts',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
              ? const Center(child: Text('No contacts available'))
              : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) {
                    final c = _filtered[i];
                    return ListTile(
                      leading: _avatar(c),
                      title: Text(c.fullName),
                      onTap: () => setState(() => _picked = c),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTypePicker() {
    final picked = _picked!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _picked = null),
              ),
              Expanded(
                child: Text(
                  'How is ${picked.firstName} related?',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _TypeChipGrid(
                  types: widget.types,
                  onSelected: (t) => _confirm(picked, t),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirm(Contact picked, String type) {
    Navigator.of(context).pop(
      RelationshipChoice(
        relatedContactId: picked.id!,
        relatedContactName: picked.fullName,
        type: type,
      ),
    );
  }

  Widget _avatar(Contact c) {
    final hasPhoto = c.photoPath != null && File(c.photoPath!).existsSync();
    return CircleAvatar(
      backgroundImage: hasPhoto ? FileImage(File(c.photoPath!)) : null,
      child: hasPhoto ? null : AvatarInitial(initialFor(c.firstName)),
    );
  }
}
