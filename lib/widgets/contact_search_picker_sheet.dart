// lib/widgets/contact_search_picker_sheet.dart
//
// The single-select contact picker sheet. Sibling of
// contact_multi_picker_sheet.dart (which picks many for a group or tag).
//
// The point of this widget is that the search is *the same search* the Contacts
// screen runs — `ContactSyncService.searchSummaries`, i.e. the DB query over
// name, phone digits, email, tags, formal name, the romanized translit key and
// the phonetic code. Pickers that filter an in-memory list on
// `fullName.contains(query)` quietly lose number search and every Malayalam /
// Manglish spelling match, which is confusing when the Contacts page finds the
// person and the picker does not.
//
// Pops with the picked contact (a slim summary — only the primary number is
// filled in, so a caller that needs every number should load them on demand) or
// null on cancel.
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/voice_input_button.dart';

/// Opens the picker as a modal sheet. Returns the picked contact, or null.
Future<Contact?> showContactSearchPickerSheet(
  BuildContext context, {
  String title = 'Choose a contact',
  bool requirePhone = false,
}) {
  return showModalBottomSheet<Contact>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) =>
        ContactSearchPickerSheet(title: title, requirePhone: requirePhone),
  );
}

class ContactSearchPickerSheet extends StatefulWidget {
  /// Sheet heading, e.g. `Choose a person to call`.
  final String title;

  /// Show only contacts that have at least one phone number. For callers whose
  /// whole purpose is a number (the emergency card, a dial shortcut) a contact
  /// without one is a dead end.
  final bool requirePhone;

  const ContactSearchPickerSheet({
    super.key,
    this.title = 'Choose a contact',
    this.requirePhone = false,
  });

  @override
  State<ContactSearchPickerSheet> createState() =>
      _ContactSearchPickerSheetState();
}

class _ContactSearchPickerSheetState extends State<ContactSearchPickerSheet> {
  final ContactSyncService _sync = ContactSyncService();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Contact> _shown = const [];
  String _query = '';
  bool _loading = true;
  String? _error;

  /// Bumped on every query change; a reply carrying an old token is stale and
  /// dropped, so a slow search for "ab" can't overwrite the results for "abc".
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _run('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    // setState first so the clear (X) button appears the moment the field stops
    // being empty, without waiting for the DB.
    setState(() => _query = value);
    _run(value);
  }

  /// Empty query → the plain A–Z list; otherwise the same DB-backed search the
  /// Contacts screen uses. Secret contacts stay out (the default), matching what
  /// the Contacts list itself shows.
  Future<void> _run(String query) async {
    final token = ++_request;
    final q = query.trim();
    setState(() {
      _loading = true;
      _error = null;
    });
    List<Contact> results;
    try {
      results = q.isEmpty
          ? await _sync.localSummaries(requirePhone: widget.requirePhone)
          : await _sync.searchSummaries(q);
    } catch (e) {
      if (!mounted || token != _request) return;
      setState(() {
        _shown = const [];
        _loading = false;
        _error = 'Could not load contacts: $e';
      });
      return;
    }
    if (!mounted || token != _request) return;
    // `searchSummaries` has no requirePhone option, so filter its results here.
    // A summary's phoneNumbers holds the primary number only, so "empty" really
    // does mean the contact has no number at all.
    if (widget.requirePhone && q.isNotEmpty) {
      results = results.where((c) => c.phoneNumbers.isNotEmpty).toList();
    }
    setState(() {
      _shown = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
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
              _searchField(context, colors),
              Expanded(child: _body(colors)),
            ],
          ),
        ),
      ),
    );
  }

  /// Same shape as the Contacts search bar (rounded accent-tinted fill, mic when
  /// empty, X when not), so the picker doesn't read as a different app.
  Widget _searchField(BuildContext context, AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.searchFill,
          borderRadius: BorderRadius.circular(18),
          border: colors.isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.06))
              : null,
        ),
        child: TextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          autofocus: true,
          onChanged: _onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Search contacts',
            prefixIcon: Icon(Icons.search, color: accent),
            suffixIcon: _query.isEmpty
                // Voice search: partial words land in the field live, each
                // running the same search as typing.
                ? VoiceInputButton(
                    onWords: (words, _) {
                      _searchCtrl.text = words;
                      _searchCtrl.selection = TextSelection.collapsed(
                        offset: words.length,
                      );
                      _onQueryChanged(words);
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.close, color: colors.mutedText),
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchCtrl.clear();
                      _onQueryChanged('');
                      _searchFocus.unfocus();
                    },
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _body(AppColors colors) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    // Only show the spinner on the very first load; later ones keep the previous
    // results on screen so the list doesn't flash on every keystroke.
    if (_loading && _shown.isEmpty && _query.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_shown.isEmpty) {
      final q = _query.trim();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            q.isEmpty
                ? (widget.requirePhone
                      ? 'No contacts with a number yet.'
                      : 'No contacts yet.')
                : 'No contacts match "$q".',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.mutedText),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: _shown.length,
      itemBuilder: (ctx, i) {
        final c = _shown[i];
        final number = c.phoneNumbers.isEmpty ? null : c.phoneNumbers.first.number;
        return ListTile(
          title: Text(c.fullName.isEmpty ? '(No name)' : c.fullName),
          subtitle: number == null ? null : Text(number),
          onTap: () => Navigator.of(ctx).pop(c),
        );
      },
    );
  }
}
