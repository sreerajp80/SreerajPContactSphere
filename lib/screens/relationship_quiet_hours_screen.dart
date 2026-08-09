// lib/screens/relationship_quiet_hours_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/quiet_hours_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/contact_multi_picker_sheet.dart';

/// Configuration screen for Quiet Hours allowed contacts settings.
class RelationshipQuietHoursScreen extends StatefulWidget {
  const RelationshipQuietHoursScreen({super.key});

  @override
  State<RelationshipQuietHoursScreen> createState() =>
      _RelationshipQuietHoursScreenState();
}

class _RelationshipQuietHoursScreenState
    extends State<RelationshipQuietHoursScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final settings = context.watch<AppSettings>();
    final accent = Theme.of(context).colorScheme.primary;
    final enabled = settings.relationshipQuietHoursEnabled;
    final allowedTiers = settings.relationshipQuietHoursAllowedTiers.toSet();
    final allowedTags = settings.relationshipQuietHoursAllowedTags.toSet();
    final allowedContactIds =
        settings.relationshipQuietHoursAllowedContactIds.toSet();

    final customRelationships = allowedTiers
        .where((t) =>
            t != QuietHoursTiers.emergency &&
            t != QuietHoursTiers.starred &&
            t != QuietHoursTiers.immediateFamily &&
            t != QuietHoursTiers.extendedFamily &&
            t != QuietHoursTiers.friends &&
            t != QuietHoursTiers.work)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Relationship-tier quiet hours')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    value: enabled,
                    activeThumbColor: accent,
                    onChanged: (v) => context
                        .read<AppSettings>()
                        .setRelationshipQuietHoursEnabled(v),
                    title: const Text(
                      'Relationship-tier quiet hours',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Silence calls at night except for chosen allowed contacts',
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ),
                  if (enabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: Icon(Icons.nightlight_round, color: accent),
                      title: const Text('Quiet hours range'),
                      trailing: Text(
                        '${settings.relationshipQuietHoursStart} – ${settings.relationshipQuietHoursEnd}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                      onTap: () => _showRelationshipQuietHoursPicker(settings),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Allowed Contacts (Ring Through)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Callers in allowed relationships, tags, or individual contacts ring loudly; all others are silenced.',
                            style: TextStyle(
                              color: colors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // --- Category 1: Specific Relationships & Presets ---
                          Text(
                            'Allowed Relationships & Categories',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: colors.mutedText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              FilterChip(
                                label: const Text('Emergency Contacts (ICE)'),
                                selected: allowedTiers
                                    .contains(QuietHoursTiers.emergency),
                                selectedColor: accent.withValues(alpha: 0.2),
                                checkmarkColor: accent,
                                onSelected: (selected) {
                                  final updated = Set<String>.from(allowedTiers);
                                  if (selected) {
                                    updated.add(QuietHoursTiers.emergency);
                                  } else {
                                    updated.remove(QuietHoursTiers.emergency);
                                  }
                                  context
                                      .read<AppSettings>()
                                      .setRelationshipQuietHoursAllowedTiers(
                                        updated.toList(),
                                      );
                                },
                              ),
                              FilterChip(
                                label: const Text('Starred Contacts'),
                                selected: allowedTiers
                                    .contains(QuietHoursTiers.starred),
                                selectedColor: accent.withValues(alpha: 0.2),
                                checkmarkColor: accent,
                                onSelected: (selected) {
                                  final updated = Set<String>.from(allowedTiers);
                                  if (selected) {
                                    updated.add(QuietHoursTiers.starred);
                                  } else {
                                    updated.remove(QuietHoursTiers.starred);
                                  }
                                  context
                                      .read<AppSettings>()
                                      .setRelationshipQuietHoursAllowedTiers(
                                        updated.toList(),
                                      );
                                },
                              ),
                              ...customRelationships.map((rel) {
                                return Chip(
                                  label: Text(rel),
                                  backgroundColor:
                                      accent.withValues(alpha: 0.15),
                                  labelStyle: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onDeleted: () {
                                    final updated = Set<String>.from(allowedTiers)
                                      ..remove(rel);
                                    context
                                        .read<AppSettings>()
                                        .setRelationshipQuietHoursAllowedTiers(
                                          updated.toList(),
                                        );
                                  },
                                  deleteIconColor: accent,
                                );
                              }),
                              ActionChip(
                                avatar: const Icon(Icons.add, size: 18),
                                label: const Text('Add Relationship'),
                                onPressed: () => _showAddRelationshipSheet(
                                  settings,
                                  allowedTiers,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),


                          // --- Category 2: Tags ---
                          Text(
                            'Allowed Tags',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: colors.mutedText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ...allowedTags.map((tag) {
                                return Chip(
                                  label: Text('#$tag'),
                                  backgroundColor: accent.withValues(alpha: 0.15),
                                  labelStyle: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onDeleted: () {
                                    final updated = Set<String>.from(allowedTags)
                                      ..remove(tag);
                                    context
                                        .read<AppSettings>()
                                        .setRelationshipQuietHoursAllowedTags(
                                          updated.toList(),
                                        );
                                  },
                                  deleteIconColor: accent,
                                );
                              }),
                              ActionChip(
                                avatar: const Icon(Icons.add, size: 18),
                                label: const Text('Add Tag'),
                                onPressed: () => _showAddTagSheet(
                                  settings,
                                  allowedTags.toList(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // --- Category 3: Specific Contacts ---
                          Text(
                            'Specific Contacts',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: colors.mutedText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FutureBuilder<List<Contact>>(
                            future: ContactRepository().getAllContacts(),
                            builder: (context, snapshot) {
                              final allContacts = snapshot.data ?? const [];
                              final contactMap = <int, String>{
                                for (final c in allContacts)
                                  if (c.id != null)
                                    c.id!: c.fullName.isEmpty
                                        ? '(No name)'
                                        : c.fullName,
                              };

                              return Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ...allowedContactIds.map((cid) {
                                    final name =
                                        contactMap[cid] ?? 'Contact #$cid';
                                    return Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: accent,
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      label: Text(name),
                                      onDeleted: () {
                                        final updated =
                                            Set<int>.from(allowedContactIds)
                                              ..remove(cid);
                                        context
                                            .read<AppSettings>()
                                            .setRelationshipQuietHoursAllowedContactIds(
                                              updated.toList(),
                                            );
                                      },
                                    );
                                  }),
                                  ActionChip(
                                    avatar: const Icon(
                                      Icons.person_add_alt_1,
                                      size: 18,
                                    ),
                                    label: const Text('Add Contact'),
                                    onPressed: () => _showAddContactPicker(
                                      settings,
                                      allContacts,
                                      allowedContactIds,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    FutureBuilder<Set<String>>(
                      future: QuietHoursService().resolveAllowedNumbers(
                        allowedTiers,
                        allowedTags,
                        allowedContactIds,
                      ),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Text(
                            'Allowed active numbers: $count',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddRelationshipSheet(
      AppSettings settings, Set<String> currentAllowedTiers) async {
    final accent = Theme.of(context).colorScheme.primary;
    final availablePresets = settings.relationshipNames;

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final selected = Set<String>.from(currentAllowedTiers);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Allowed Relationships',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              settings.setRelationshipQuietHoursAllowedTiers(
                                selected.toList(),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availablePresets.map((rel) {
                            final isSelected = selected.contains(rel) ||
                                selected.contains(rel.toLowerCase());
                            return FilterChip(
                              label: Text(rel),
                              selected: isSelected,
                              selectedColor: accent.withValues(alpha: 0.2),
                              checkmarkColor: accent,
                              onSelected: (checked) {
                                setSheetState(() {
                                  if (checked) {
                                    selected.add(rel);
                                  } else {
                                    selected.remove(rel);
                                    selected.remove(rel.toLowerCase());
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddTagSheet(
      AppSettings settings, List<String> currentTags) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    final syncService = ContactSyncService();
    final tagCounts = await syncService.tagCounts();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final selectedTags = Set<String>.from(currentTags);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Allowed Tags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          settings.setRelationshipQuietHoursAllowedTags(
                            selectedTags.toList(),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (tagCounts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No tags found in contacts. Create tags on contacts first.',
                        style: TextStyle(color: colors.mutedText, fontSize: 13),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tagCounts.map((t) {
                        final isAdded = selectedTags.contains(t.name);
                        return FilterChip(
                          label: Text('#${t.name} (${t.count})'),
                          selected: isAdded,
                          onSelected: (selected) {
                            setSheetState(() {
                              if (selected) {
                                selectedTags.add(t.name);
                              } else {
                                selectedTags.remove(t.name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
          },
        );
      },
    );
  }

  Future<void> _showAddContactPicker(
    AppSettings settings,
    List<Contact> allContacts,
    Set<int> currentContactIds,
  ) async {
    final selected = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ContactMultiPickerSheet(
        title: 'Select Allowed Contacts',
        contacts: allContacts,
        alreadyIn: currentContactIds,
      ),
    );

    if (selected != null) {
      settings.setRelationshipQuietHoursAllowedContactIds(selected.toList());
    }
  }

  Future<void> _showRelationshipQuietHoursPicker(AppSettings settings) async {
    final startParts = settings.relationshipQuietHoursStart
        .split(':')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final endParts = settings.relationshipQuietHoursEnd
        .split(':')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: startParts[0],
        minute: startParts.length > 1 ? startParts[1] : 0,
      ),
      helpText: 'SELECT RELATIONSHIP QUIET HOURS START TIME',
    );
    if (startTime == null || !mounted) return;

    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: endParts[0],
        minute: endParts.length > 1 ? endParts[1] : 0,
      ),
      helpText: 'SELECT RELATIONSHIP QUIET HOURS END TIME',
    );
    if (endTime == null || !mounted) return;

    final formattedStart =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final formattedEnd =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    settings.setRelationshipQuietHoursRange(formattedStart, formattedEnd);
  }
}

