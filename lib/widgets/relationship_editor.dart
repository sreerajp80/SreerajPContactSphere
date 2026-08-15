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

/// The label chips to offer once [category] is chosen: the category's built-in
/// suggestions, plus any user-managed name from [AppSettings] that belongs to
/// the same category. Duplicates (case-insensitive) are dropped, built-ins
/// first, so the list is stable and never blank.
List<String> _labelsFor(BuildContext context, RelationshipCategory category) {
  final out = <String>[];
  final seen = <String>{};
  void add(String name) {
    final t = name.trim();
    if (t.isEmpty) return;
    if (seen.add(t.toLowerCase())) out.add(t);
  }

  for (final s in category.suggestedLabels) {
    add(s);
  }
  for (final n in context.read<AppSettings>().relationshipNames) {
    if (RelationshipCategory.categoryFor(n) == category) add(n);
  }
  return out;
}

/// The user's choice from the relationship editor: which contact to link, the
/// category it belongs to, and the free-text label (from the owner's
/// perspective).
class RelationshipChoice {
  final int relatedContactId;
  final String relatedContactName;
  final RelationshipCategory category;
  final String type;

  const RelationshipChoice({
    required this.relatedContactId,
    required this.relatedContactName,
    required this.category,
    required this.type,
  });
}

/// The result of editing an existing relationship: its category and label.
class RelationshipTypeChoice {
  final RelationshipCategory category;
  final String type;

  const RelationshipTypeChoice({required this.category, required this.type});
}

/// Opens a bottom sheet to add a relationship: pick another contact (searchable,
/// excluding [excludeIds] and the owner), pick one of the seven categories, then
/// type or tap the label. Returns the choice, or null if dismissed. Shared by
/// the detail, add/edit and sphere screens.
Future<RelationshipChoice?> showRelationshipEditor(
  BuildContext context, {
  required int? ownerContactId,
  required Set<int> excludeIds,
}) {
  return showModalBottomSheet<RelationshipChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _RelationshipEditorSheet(
      ownerContactId: ownerContactId,
      excludeIds: excludeIds,
    ),
  );
}

/// Opens a bottom sheet to change an existing relationship's category and label.
/// Starts on the label step for [currentCategory] (so the common case — fixing a
/// label — is one tap away) with a "Change category" button back to the seven
/// cards. Returns the new category + label, or null if dismissed. [personName]
/// names the related contact in the prompt (pass the first name).
Future<RelationshipTypeChoice?> showRelationshipTypePicker(
  BuildContext context, {
  required String personName,
  String? currentType,
  RelationshipCategory? currentCategory,
}) {
  return showModalBottomSheet<RelationshipTypeChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TypePickerSheet(
      personName: personName,
      currentType: currentType,
      currentCategory:
          currentCategory ?? RelationshipCategory.categoryFor(currentType),
    ),
  );
}

/// The seven categories as tappable cards: emoji, name and the one-line
/// description. Shown as step 2 of the add flow and behind "Change category".
class _CategoryList extends StatelessWidget {
  final RelationshipCategory? selected;
  final ValueChanged<RelationshipCategory> onSelected;

  const _CategoryList({this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      children: [
        for (final c in RelationshipCategory.values)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: c == selected ? accent.withValues(alpha: 0.12) : null,
            child: ListTile(
              leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(
                c.displayName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(c.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onSelected(c),
            ),
          ),
      ],
    );
  }
}

/// The label step: a free-text field plus the suggestion chips for the chosen
/// category. The user may tap a chip or type anything they like.
class _LabelStep extends StatefulWidget {
  final RelationshipCategory category;
  final String? initialLabel;
  final String prompt;
  final VoidCallback onBack;
  final VoidCallback? onChangeCategory;
  final ValueChanged<String> onDone;

  const _LabelStep({
    required this.category,
    required this.initialLabel,
    required this.prompt,
    required this.onBack,
    required this.onChangeCategory,
    required this.onDone,
  });

  @override
  State<_LabelStep> createState() => _LabelStepState();
}

class _LabelStepState extends State<_LabelStep> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialLabel ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onDone(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = _labelsFor(context, widget.category);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
              Expanded(
                child: Text(
                  widget.prompt,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                widget.category.emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.category.displayName,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.onChangeCategory != null)
                TextButton(
                  onPressed: widget.onChangeCategory,
                  child: const Text('Change'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Relationship label',
              hintText: 'e.g. Father',
              border: OutlineInputBorder(),
              isDense: true,
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final l in labels)
                    ChoiceChip(
                      label: Text(l),
                      selected:
                          l.toLowerCase() ==
                          _controller.text.trim().toLowerCase(),
                      onSelected: (_) => widget.onDone(l),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _controller.text.trim().isEmpty ? null : _submit,
                child: const Text('Save'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Standalone picker used to edit an existing relationship's category + label.
class _TypePickerSheet extends StatefulWidget {
  final String personName;
  final String? currentType;
  final RelationshipCategory currentCategory;

  const _TypePickerSheet({
    required this.personName,
    required this.currentType,
    required this.currentCategory,
  });

  @override
  State<_TypePickerSheet> createState() => _TypePickerSheetState();
}

class _TypePickerSheetState extends State<_TypePickerSheet> {
  late RelationshipCategory _category = widget.currentCategory;

  /// True while the seven category cards are showing.
  bool _choosingCategory = false;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: _choosingCategory
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 16, 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () =>
                              setState(() => _choosingCategory = false),
                        ),
                        const Expanded(
                          child: Text(
                            'Pick a category',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _CategoryList(
                      selected: _category,
                      onSelected: (c) => setState(() {
                        _category = c;
                        _choosingCategory = false;
                      }),
                    ),
                  ),
                ],
              )
            : _LabelStep(
                category: _category,
                initialLabel: widget.currentType,
                prompt: 'How is ${widget.personName} related?',
                onBack: () => Navigator.of(context).pop(),
                onChangeCategory: () =>
                    setState(() => _choosingCategory = true),
                onDone: (label) => Navigator.of(context).pop(
                  RelationshipTypeChoice(category: _category, type: label),
                ),
              ),
      ),
    );
  }
}

class _RelationshipEditorSheet extends StatefulWidget {
  final int? ownerContactId;
  final Set<int> excludeIds;

  const _RelationshipEditorSheet({
    required this.ownerContactId,
    required this.excludeIds,
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

  /// Step 1 result: the contact to link. Null while the picker is showing.
  Contact? _picked;

  /// Step 2 result: the category. Null while the category cards are showing.
  RelationshipCategory? _category;

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
    final picked = _picked;
    final category = _category;

    final Widget body;
    if (picked == null) {
      body = _buildContactPicker();
    } else if (category == null) {
      body = _buildCategoryPicker(picked);
    } else {
      body = _LabelStep(
        category: category,
        initialLabel: null,
        prompt: 'How is ${picked.firstName} related?',
        onBack: () => setState(() => _category = null),
        onChangeCategory: () => setState(() => _category = null),
        onDone: (label) => _confirm(picked, category, label),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: body,
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

  Widget _buildCategoryPicker(Contact picked) {
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
                  'Where does ${picked.firstName} belong?',
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
          child: _CategoryList(
            onSelected: (c) => setState(() => _category = c),
          ),
        ),
      ],
    );
  }

  void _confirm(Contact picked, RelationshipCategory category, String label) {
    Navigator.of(context).pop(
      RelationshipChoice(
        relatedContactId: picked.id!,
        relatedContactName: picked.fullName,
        category: category,
        type: label,
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
