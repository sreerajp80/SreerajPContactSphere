// lib/screens/relationship_names_screen.dart
import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/relationship_labels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Relationship-label management, reached from Settings → Contacts. These names
/// are extra label chips offered when linking two contacts (e.g. "Father",
/// "Friend"). Each name is filed under one of the seven relationship categories
/// by its wording, and shows up as a chip once that category is chosen — a name
/// the app does not recognise appears under Social. The list is fully editable
/// and seeded from the built-in defaults; AppLocalizations.of(context).tooltipResetToDefaults restores them.
class RelationshipNamesScreen extends StatefulWidget {
  const RelationshipNamesScreen({super.key});

  @override
  State<RelationshipNamesScreen> createState() =>
      _RelationshipNamesScreenState();
}

class _RelationshipNamesScreenState extends State<RelationshipNamesScreen> {
  /// Opens the add/edit dialog. When [index] is null a new name is appended;
  /// otherwise the name at [index] is replaced. A blank or duplicate name
  /// (case-insensitive, ignoring the row being edited) is rejected.
  Future<void> _editName({int? index}) async {
    final settings = context.read<AppSettings>();
    final names = settings.relationshipNames;
    final controller = TextEditingController(
      text: index == null ? '' : names[index],
    );
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          index == null
              ? AppLocalizations.of(context).titleNewRelationship
              : AppLocalizations.of(context).titleEditRelationship,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).labelRelationshipName,
            hintText: AppLocalizations.of(context).hintRelationshipNameExample,
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(AppLocalizations.of(context).actionSave),
          ),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    final trimmed = text.trim();

    // Reject a duplicate (any other row with the same name, case-insensitive).
    final clash = names.asMap().entries.any(
      (e) => e.key != index && e.value.toLowerCase() == trimmed.toLowerCase(),
    );
    if (clash) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorRelationshipExists),
        ),
      );
      return;
    }

    final next = List<String>.from(names);
    if (index == null) {
      next.add(trimmed);
    } else {
      next[index] = trimmed;
    }
    await context.read<AppSettings>().setRelationshipNames(next);
  }

  Future<void> _removeName(int index) async {
    final settings = context.read<AppSettings>();
    final next = List<String>.from(settings.relationshipNames)..removeAt(index);
    await settings.setRelationshipNames(next);
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleResetRelationshipNames),
        content: Text(AppLocalizations.of(context).descResetRelationshipNames),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(context).actionReset),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AppSettings>().resetRelationshipNames();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final names = context.watch<AppSettings>().relationshipNames;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).titleRelationshipNames),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: AppLocalizations.of(context).tooltipResetToDefaults,
            onPressed: _resetToDefaults,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _explainerNote(colors),
          const SizedBox(height: 12),
          _addNameCard(colors),
          const SizedBox(height: 12),
          if (names.isEmpty) _emptyNote(colors) else _namesCard(colors, names),
        ],
      ),
    );
  }

  Widget _explainerNote(AppColors colors) {
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
                AppLocalizations.of(context).descRelationshipNamesInfo,
                style: TextStyle(color: colors.mutedText, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addNameCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _editName(),
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
                      AppLocalizations.of(context).actionAddRelationshipName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context).descAddRelationshipName,
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

  Widget _emptyNote(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        AppLocalizations.of(context).emptyNoRelationshipNames,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.mutedText, fontSize: 13.5),
      ),
    );
  }

  Widget _namesCard(AppColors colors, List<String> names) {
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
                AppLocalizations.of(
                  context,
                ).labelRelationshipsCount(names.length),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (var i = 0; i < names.length; i++)
              _nameTile(colors, i, names[i]),
          ],
        ),
      ),
    );
  }

  Widget _nameTile(AppColors colors, int index, String name) {
    final accent = Theme.of(context).colorScheme.primary;
    final category = RelationshipCategory.categoryFor(name);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _editName(index: index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.people_alt_outlined, color: accent, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${category.emoji} ${relationshipCategoryLabel(AppLocalizations.of(context), category)}',
                    style: TextStyle(color: colors.mutedText, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: colors.mutedText, size: 20),
              tooltip: AppLocalizations.of(context).actionDelete,
              onPressed: () => _removeName(index),
            ),
          ],
        ),
      ),
    );
  }
}
