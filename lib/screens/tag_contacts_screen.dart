// lib/screens/tag_contacts_screen.dart
//
// The contacts carrying a single tag, opened from the Tag Cloud. A lightweight
// list (avatar/initials + name + primary number) that reuses the app's own card
// styling; tapping a row opens the full contact detail.
//
// Also where a tag's membership is edited: add contacts (with household/company
// suggestions, via [ContactMultiPickerSheet]) and remove them one at a time.
// Removing is what lets a tag be emptied and then deleted — see
// [showTagActionsSheet] for why deletion is blocked while members remain.
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/contact_detail_screen.dart';
import 'package:smart_contacts_dialer/widgets/avatar_initial.dart';
import 'package:smart_contacts_dialer/widgets/contact_multi_picker_sheet.dart'
    show ContactMultiPickerSheet;
import 'package:smart_contacts_dialer/widgets/tag_actions_sheet.dart';

class TagContactsScreen extends StatefulWidget {
  /// The exact tag name to list contacts for (without a leading '#').
  final String tag;

  const TagContactsScreen({super.key, required this.tag});

  @override
  State<TagContactsScreen> createState() => _TagContactsScreenState();
}

class _TagContactsScreenState extends State<TagContactsScreen> {
  final ContactSyncService _sync = ContactSyncService();

  /// The tag this screen is showing. Not `widget.tag` directly, because a rename
  /// or merge from the app-bar menu changes which tag we are looking at.
  late String _tag;

  List<Contact> _contacts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tag = widget.tag;
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final rows = await _sync.contactsByTag(_tag);
      if (!mounted) return;
      setState(() {
        _contacts = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _contacts = const [];
        _loading = false;
      });
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Shows a translated snackbar. The message is built only after the
  /// `mounted` check, so this is safe to call after an `await`.
  void _say(String Function(AppLocalizations l) message) {
    if (!mounted) return;
    _showMessage(message(AppLocalizations.of(context)));
  }

  /// Adds contacts to this tag through the shared picker, which suggests people
  /// sharing a house or employer with whoever is already selected.
  Future<void> _addContacts() async {
    List<Contact> all;
    try {
      all = await _sync.localSummaries();
    } catch (e) {
      _say((l) => l.errorCouldNotLoadContacts('$e'));
      return;
    }
    if (!mounted) return;

    final existing = _contacts.map((c) => c.id).whereType<int>().toSet();
    final selectable = all.where((c) => c.id != null).toList();
    if (selectable.isEmpty) {
      _say((l) => l.errorNoContactsToAdd);
      return;
    }

    final picked = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ContactMultiPickerSheet(
        title: AppLocalizations.of(context).titleAddToTag(_tag),
        contacts: selectable,
        alreadyIn: existing,
      ),
    );
    if (picked == null || !mounted) return;

    final toAdd = picked.difference(existing);
    if (toAdd.isEmpty) {
      _say((l) => l.msgNoNewContactsAdded);
      return;
    }
    try {
      final added = await _sync.addTagToContacts(_tag, toAdd);
      await _load();
      _say((l) => l.msgContactsAddedToTag(added, _tag));
    } catch (e) {
      _say((l) => l.errorCouldNotAddContacts('$e'));
    }
  }

  /// Takes this one tag off a single contact, leaving its other tags alone.
  Future<void> _removeContact(Contact contact) async {
    final id = contact.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleRemoveTagConfirm(_tag)),
        content: Text(
          contact.fullName.isEmpty
              ? AppLocalizations.of(context).descRemoveTagFromThis
              : AppLocalizations.of(
                  context,
                ).descRemoveTagFrom(contact.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).actionRemove),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _sync.removeTagFromContacts(_tag, {id});
      await _load();
      _say((l) => l.msgRemovedTag(_tag));
    } catch (e) {
      _say((l) => l.errorCouldNotRemove('$e'));
    }
  }

  /// Rename / merge / delete this tag. A rename retitles the screen; a merge or
  /// delete means this tag no longer exists, so the screen closes.
  Future<void> _editTag() async {
    final result = await showTagActionsSheet(
      context,
      tag: _tag,
      contactCount: _contacts.length,
    );
    if (result == null || !mounted) return;
    switch (result.kind) {
      case TagActionKind.renamed:
        setState(() => _tag = result.newName ?? _tag);
        await _load();
      case TagActionKind.merged:
      case TagActionKind.deleted:
        Navigator.of(context).pop();
    }
  }

  Future<void> _open(Contact contact) async {
    final id = contact.id;
    if (id == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ContactDetailScreen(contactId: id)),
    );
    // Tags may have been edited on the detail screen; refresh so a contact that
    // no longer carries this tag drops out of the list.
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text('#$_tag'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: AppLocalizations.of(context).tooltipRenameMergeDeleteTag,
            onPressed: _loading ? null : _editTag,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _addContacts,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(AppLocalizations.of(context).actionAddContacts),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  // An empty tag exists only until this screen closes, so say
                  // what the two ways forward are.
                  AppLocalizations.of(context).emptyTagNoContacts,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.mutedText, fontSize: 14),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
              itemCount: _contacts.length,
              itemBuilder: (context, index) => _row(_contacts[index], colors),
            ),
    );
  }

  Widget _row(Contact contact, AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final hasPhoto =
        contact.photoPath != null && File(contact.photoPath!).existsSync();
    final number = contact.phoneNumbers.isNotEmpty
        ? contact.phoneNumbers.first.number
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: colors.isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _open(contact),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  image: hasPhoto
                      ? DecorationImage(
                          image: FileImage(File(contact.photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: hasPhoto
                    ? null
                    : AvatarInitial(
                        initialFor(contact.firstName),
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (number != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        number,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: colors.mutedText),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                tooltip: AppLocalizations.of(
                  context,
                ).tooltipRemoveTagFromContact,
                color: colors.mutedText,
                onPressed: () => _removeContact(contact),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
