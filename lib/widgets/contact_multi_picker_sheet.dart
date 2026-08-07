// lib/widgets/contact_multi_picker_sheet.dart
//
// The multi-select contact picker used to add members to a group or a tag.
// Started life private inside groups_screen.dart; lifted here so the Tags
// screens get the same sheet — and so the household/company suggestions below
// are written once rather than per caller.
//
// Pops with the full selected id set (members included) or null on cancel; the
// caller diffs against [alreadyIn] to decide what to write.
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';

class ContactMultiPickerSheet extends StatefulWidget {
  /// Sheet heading, e.g. `Add to "Family"` or `Add to #work`.
  final String title;

  /// Every selectable contact (callers pass ones with a non-null id).
  final List<Contact> contacts;

  /// Contacts already in the target group/tag: pre-checked and locked on.
  final Set<int> alreadyIn;

  const ContactMultiPickerSheet({
    super.key,
    required this.title,
    required this.contacts,
    required this.alreadyIn,
  });

  @override
  State<ContactMultiPickerSheet> createState() =>
      _ContactMultiPickerSheetState();
}

class _ContactMultiPickerSheetState extends State<ContactMultiPickerSheet> {
  final ContactSyncService _sync = ContactSyncService();

  late final Set<int> _selected;
  String _query = '';

  /// Suggested peers of the current selection, keyed by contact id, plus the
  /// contacts themselves so a suggestion row can render without a re-query.
  List<AffiliationPeer> _suggestions = const [];
  bool _loadingSuggestions = false;

  /// Guards against an out-of-order suggestion response overwriting a newer one
  /// when the user checks several contacts quickly.
  int _suggestionRequest = 0;

  @override
  void initState() {
    super.initState();
    // Members start checked so the sheet shows the current state; they are
    // filtered out of the actual insert on the caller side.
    _selected = {...widget.alreadyIn};
    _refreshSuggestions();
  }

  /// Asks for contacts sharing a house or employer with anything now selected.
  /// Failures are swallowed to an empty list: suggestions are a convenience, and
  /// losing them must never block adding members by hand.
  Future<void> _refreshSuggestions() async {
    if (_selected.isEmpty) {
      setState(() {
        _suggestions = const [];
        _loadingSuggestions = false;
      });
      return;
    }
    final token = ++_suggestionRequest;
    setState(() => _loadingSuggestions = true);
    List<AffiliationPeer> peers;
    try {
      peers = await _sync.affiliationPeers({..._selected});
    } catch (_) {
      peers = const [];
    }
    if (!mounted || token != _suggestionRequest) return;
    setState(() {
      // Anything already selected is not a suggestion any more.
      _suggestions = peers
          .where((p) => !_selected.contains(p.contactId))
          .toList();
      _loadingSuggestions = false;
    });
  }

  void _toggle(int id, bool checked) {
    setState(() {
      if (checked) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
    _refreshSuggestions();
  }

  List<Contact> get _filtered {
    final q = _query.trim();
    if (q.isEmpty) return widget.contacts;
    final like = q.toLowerCase();
    return widget.contacts.where((c) {
      if (c.fullName.toLowerCase().contains(like)) return true;
      // Same test the Contacts page uses, so the two agree on what "matches".
      return nameMatches(q, c.fullName);
    }).toList();
  }

  /// Suggestion rows to draw: hidden while searching, since the user is then
  /// looking for one specific person and the extra section only gets in the way.
  List<_Suggestion> get _visibleSuggestions {
    if (_query.trim().isNotEmpty || _suggestions.isEmpty) return const [];
    final byId = <int, Contact>{
      for (final c in widget.contacts)
        if (c.id != null) c.id!: c,
    };
    final rows = <_Suggestion>[];
    for (final p in _suggestions) {
      final contact = byId[p.contactId];
      if (contact != null) rows.add(_Suggestion(contact: contact, peer: p));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filtered = _filtered;
    final suggestions = _visibleSuggestions;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
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
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: filtered.isEmpty && suggestions.isEmpty
                  ? const Center(child: Text('No contacts found'))
                  : ListView.builder(
                      // Suggestions sit above the full list, behind a header
                      // row; the remaining indices are the list itself.
                      itemCount:
                          filtered.length +
                          (suggestions.isEmpty ? 0 : suggestions.length + 2),
                      itemBuilder: (context, i) {
                        if (suggestions.isNotEmpty) {
                          if (i == 0) return _suggestionHeader(colors);
                          if (i <= suggestions.length) {
                            return _suggestionRow(suggestions[i - 1], colors);
                          }
                          if (i == suggestions.length + 1) {
                            return _allContactsHeader(colors);
                          }
                          return _contactRow(
                            filtered[i - suggestions.length - 2],
                          );
                        }
                        return _contactRow(filtered[i]);
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, _selected),
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: colors.mutedText),
          const SizedBox(width: 6),
          Text(
            'Suggested',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: colors.mutedText,
            ),
          ),
          if (_loadingSuggestions) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }

  Widget _allContactsHeader(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        'All contacts',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: colors.mutedText,
        ),
      ),
    );
  }

  Widget _suggestionRow(_Suggestion s, AppColors colors) {
    final id = s.contact.id!;
    return CheckboxListTile(
      value: _selected.contains(id),
      onChanged: (v) => _toggle(id, v == true),
      title: Text(
        s.contact.fullName.isEmpty ? '(No name)' : s.contact.fullName,
      ),
      subtitle: Text(
        s.peer.reason,
        style: TextStyle(fontSize: 12, color: colors.mutedText),
      ),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _contactRow(Contact c) {
    final id = c.id!;
    final checked = _selected.contains(id);
    final member = widget.alreadyIn.contains(id);
    return CheckboxListTile(
      value: checked,
      // Members can't be unchecked here (removal is done from the contact
      // editor, or the tag screen for tags); keep them locked on.
      onChanged: member ? null : (v) => _toggle(id, v == true),
      title: Text(c.fullName.isEmpty ? '(No name)' : c.fullName),
      subtitle: member ? const Text('Already added') : null,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

/// A suggestion row's contact paired with why it was suggested.
class _Suggestion {
  final Contact contact;
  final AffiliationPeer peer;

  const _Suggestion({required this.contact, required this.peer});
}
