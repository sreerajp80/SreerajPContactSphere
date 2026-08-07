// lib/screens/groups_screen.dart
import 'package:flutter/material.dart';

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
      _showMessage('Failed to load groups: $e');
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _createGroup() async {
    final name = await _promptForName();
    if (name == null || name.trim().isEmpty) return;
    try {
      await _repository.createGroup(name.trim());
      await _load();
    } catch (e) {
      _showMessage('Could not create group (name may already exist)');
    }
  }

  Future<String?> _promptForName({String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Group name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Family'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('OK'),
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
      _showMessage('Could not pick ringtone: $e');
      return;
    }

    try {
      await _repository.setGroupRingtone(group.id!, path: path, label: label);
      await _load();
    } catch (e) {
      _showMessage('Could not save ringtone: $e');
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
              title: const Text('Phone ringtones'),
              subtitle: const Text('Choose from the ringtones on this device'),
              onTap: () => Navigator.pop(sheetContext, _RingtoneSource.phone),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Audio file'),
              subtitle: const Text('Pick an audio file from your folders'),
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
      _showMessage('Could not clear ringtone: $e');
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
      _showMessage('Could not load contacts: $e');
      return;
    }
    if (!mounted) return;
    final selectable = contacts.where((c) => c.id != null).toList();
    if (selectable.isEmpty) {
      _showMessage('No contacts to add');
      return;
    }

    final picked = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ContactMultiPickerSheet(
        title: 'Add to "${group.name}"',
        contacts: selectable,
        alreadyIn: existing,
      ),
    );
    if (picked == null || !mounted) return;

    // Only add contacts that were not already members.
    final toAdd = picked.difference(existing);
    if (toAdd.isEmpty) {
      _showMessage('No new contacts added');
      return;
    }
    try {
      for (final id in toAdd) {
        await _repository.addContactToGroup(id, group.id!);
      }
      await _load();
      _showMessage(
        '${toAdd.length} contact(s) added to "${group.name}"',
      );
    } catch (e) {
      _showMessage('Could not add contacts: $e');
    }
  }

  Future<void> _deleteGroup(Group group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${group.name}"?'),
        content: const Text(
          'The group is removed; contacts in it are not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || group.id == null) return;
    try {
      await _repository.deleteGroup(group.id!);
      await _load();
    } catch (e) {
      _showMessage('Delete failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
          ? const Center(child: Text('No groups yet'))
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
                        ? '${g.contactCount} contact(s) · ${g.ringtoneLabel ?? 'Custom ringtone'}'
                        : '${g.contactCount} contact(s)',
                  ),
                  trailing: PopupMenuButton<String>(
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
                      const PopupMenuItem(
                        value: 'add_contacts',
                        child: ListTile(
                          leading: Icon(Icons.person_add_alt),
                          title: Text('Add contacts…'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'ringtone',
                        child: ListTile(
                          leading: Icon(Icons.music_note),
                          title: Text('Ringtone…'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (hasTone)
                        const PopupMenuItem(
                          value: 'clear_ringtone',
                          child: ListTile(
                            leading: Icon(Icons.music_off),
                            title: Text('Clear ringtone'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Delete'),
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
