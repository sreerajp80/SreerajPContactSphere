// lib/screens/groups_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/group.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/group_repository.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/widgets/contact_multi_picker_sheet.dart'
    show ContactMultiPickerSheet;

/// Where a group ringtone is picked from (mirrors the contact editor).
enum _RingtoneSource { phone, file }

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _repository = GroupRepository();
  final _contactRepository = ContactRepository();
  final _telecom = TelecomService();
  List<Group> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final groups = await _repository.getAllGroups();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _say((l) => l.errorFailedLoadGroups('$e'));
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

  Future<void> _createGroup() async {
    final name = await _promptForName();
    if (name == null || name.trim().isEmpty) return;
    try {
      await _repository.createGroup(name.trim());
      await _load();
    } catch (e) {
      _say((l) => l.errorCouldNotCreateGroup);
    }
  }

  Future<String?> _promptForName({String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).titleGroupName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).hintGroupExample,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(AppLocalizations.of(context).actionOk),
          ),
        ],
      ),
    );
  }

  /// Picks a tone (phone ringtones or an audio file, same two sources as the
  /// contact editor) and stores it on [group]. Members without a tone of their
  /// own will ring with it.
  Future<void> _pickGroupRingtone(Group group) async {
    if (group.id == null) return;
    final source = await _chooseRingtoneSource();
    if (source == null || !mounted) return;

    String? path;
    String? label;
    try {
      if (source == _RingtoneSource.phone) {
        final tone = await _telecom.pickRingtone(
          existingUri: group.ringtonePath,
        );
        if (tone == null) return;
        path = tone.path;
        label = tone.label;
      } else {
        // Persistable content:// URI (survives restarts without copying the file).
        final file = await _telecom.pickAudioDocument();
        if (file == null) return;
        path = file.path;
        label = file.label;
      }
    } catch (e) {
      _say((l) => l.errorCouldNotPickRingtone('$e'));
      return;
    }

    try {
      await _repository.setGroupRingtone(group.id!, path: path, label: label);
      await _load();
    } catch (e) {
      _say((l) => l.errorCouldNotSaveRingtone('$e'));
    }
  }

  /// Bottom-sheet chooser: pick from the phone's ringtones or an audio file.
  /// Returns null if dismissed.
  Future<_RingtoneSource?> _chooseRingtoneSource() {
    return showModalBottomSheet<_RingtoneSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: Text(AppLocalizations.of(context).titlePhoneRingtones),
              subtitle: Text(AppLocalizations.of(context).descPhoneRingtones),
              onTap: () => Navigator.pop(sheetContext, _RingtoneSource.phone),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(AppLocalizations.of(context).titleAudioFile),
              subtitle: Text(AppLocalizations.of(context).descAudioFile),
              onTap: () => Navigator.pop(sheetContext, _RingtoneSource.file),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearGroupRingtone(Group group) async {
    if (group.id == null) return;
    try {
      await _repository.setGroupRingtone(group.id!);
      await _load();
    } catch (e) {
      _say((l) => l.errorCouldNotClearRingtone('$e'));
    }
  }

  /// Opens a multi-select contact picker and adds the chosen contacts to
  /// [group]. Contacts already in the group are pre-checked and left as-is.
  Future<void> _addContactsToGroup(Group group) async {
    if (group.id == null) return;
    List<Contact> contacts;
    Set<int> existing;
    try {
      contacts = await _contactRepository.getAllContacts();
      existing = await _repository.contactIdsInGroup(group.id!);
    } catch (e) {
      _say((l) => l.errorCouldNotLoadContacts('$e'));
      return;
    }
    if (!mounted) return;
    final selectable = contacts.where((c) => c.id != null).toList();
    if (selectable.isEmpty) {
      _say((l) => l.errorNoContactsToAdd);
      return;
    }

    final picked = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ContactMultiPickerSheet(
        title: AppLocalizations.of(context).titleAddToGroup(group.name),
        contacts: selectable,
        alreadyIn: existing,
      ),
    );
    if (picked == null || !mounted) return;

    // Only add contacts that were not already members.
    final toAdd = picked.difference(existing);
    if (toAdd.isEmpty) {
      _say((l) => l.msgNoNewContactsAdded);
      return;
    }
    try {
      for (final id in toAdd) {
        await _repository.addContactToGroup(id, group.id!);
      }
      await _load();
      _say((l) => l.msgContactsAddedToGroup(toAdd.length, group.name));
    } catch (e) {
      _say((l) => l.errorCouldNotAddContacts('$e'));
    }
  }

  Future<void> _deleteGroup(Group group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(context).titleDeleteGroupConfirm(group.name),
        ),
        content: Text(AppLocalizations.of(context).descDeleteGroup),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || group.id == null) return;
    try {
      await _repository.deleteGroup(group.id!);
      await _load();
    } catch (e) {
      _say((l) => l.errorDeleteFailed('$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).tooltipGroups)),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        tooltip: AppLocalizations.of(context).tooltipCreateGroup,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
          ? Center(child: Text(AppLocalizations.of(context).emptyNoGroups))
          : ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, i) {
                final g = _groups[i];
                final hasTone = g.ringtonePath != null;
                return ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(g.name),
                  subtitle: Text(
                    hasTone
                        ? '${AppLocalizations.of(context).labelContactCount(g.contactCount)} · ${g.ringtoneLabel ?? AppLocalizations.of(context).labelCustomRingtone}'
                        : AppLocalizations.of(
                            context,
                          ).labelContactCount(g.contactCount),
                  ),
                  trailing: PopupMenuButton<String>(
                    tooltip: AppLocalizations.of(context).tooltipMore,
                    onSelected: (action) {
                      switch (action) {
                        case 'add_contacts':
                          _addContactsToGroup(g);
                        case 'ringtone':
                          _pickGroupRingtone(g);
                        case 'clear_ringtone':
                          _clearGroupRingtone(g);
                        case 'delete':
                          _deleteGroup(g);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'add_contacts',
                        child: ListTile(
                          leading: const Icon(Icons.person_add_alt),
                          title: Text(
                            AppLocalizations.of(
                              context,
                            ).actionAddContactsEllipsis,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'ringtone',
                        child: ListTile(
                          leading: const Icon(Icons.music_note),
                          title: Text(
                            AppLocalizations.of(context).actionRingtoneEllipsis,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (hasTone)
                        PopupMenuItem(
                          value: 'clear_ringtone',
                          child: ListTile(
                            leading: const Icon(Icons.music_off),
                            title: Text(
                              AppLocalizations.of(context).actionClearRingtone,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: Text(
                            AppLocalizations.of(context).actionDelete,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
