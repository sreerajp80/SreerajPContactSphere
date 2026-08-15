import 'dart:async' show Timer;
import 'dart:io' show File;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';
import 'package:smart_contacts_dialer/utils/t9_utils.dart';
import 'package:smart_contacts_dialer/utils/voice_dial_parser.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/widgets/avatar_initial.dart';
import 'package:smart_contacts_dialer/widgets/call_lifecycle_mixin.dart';
import 'package:smart_contacts_dialer/widgets/voice_input_button.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/services/reach_window_service.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_detail_screen.dart';
import 'package:smart_contacts_dialer/screens/settings_screen.dart';

/// A standalone T9 dialpad. Uses a custom number display (not a `TextField`) so
/// the OS keyboard never covers the pad, and surfaces match-as-you-type contact
/// suggestions backed by [ContactRepository.findByPhoneFragment]. Before any
/// digits are typed it shows the user's Favorites. Placing a call goes through
/// [CallLifecycleMixin] for reconciliation + post-call feedback.
///
/// In [addCallMode] the screen is pushed over the in-call UI to dial a second
/// party for a conference: once a call is placed it pops itself so the in-call
/// screen (which reflects the new held/active legs) returns to front.
class DialerScreen extends StatefulWidget {
  final bool addCallMode;
  final bool dtmfMode;

  /// A number to pre-fill the dialpad with when the screen opens — used when a
  /// `tel:` link (ACTION_DIAL/VIEW) routes into the app so the user lands on the
  /// dialer with the number ready to review and call. Null for the normal tab.
  final String? initialNumber;

  const DialerScreen({
    super.key,
    this.addCallMode = false,
    this.dtmfMode = false,
    this.initialNumber,
  });

  @override
  State<DialerScreen> createState() => DialerScreenState();
}

class DialerScreenState extends State<DialerScreen>
    with WidgetsBindingObserver, CallLifecycleMixin<DialerScreen> {
  final ContactRepository _contacts = ContactRepository();
  final TelecomService _telecom = TelecomService();
  final ReachWindowService _reachWindows = ReachWindowService();

  String _number = '';
  late final TextEditingController _numberController;
  final FocusNode _numberFocusNode = FocusNode();

  int? _linkedContactId;
  String? _linkedName;
  List<PhoneMatch> _suggestions = const [];
  List<PhoneMatch> _favorites = const [];
  List<PhoneMatch> _topContacts = const [];

  /// A spoken name that matched more than one contact: the phrase heard and
  /// the candidates, shown in the strip until the user picks one or types.
  String? _voiceQuery;
  List<PhoneMatch> _voiceMatches = const [];
  DialerTopSource _topSource = DialerTopSource.recent;
  int _queryToken = 0;

  /// Guards live voice-name searches: stale responses (from an earlier partial)
  /// are dropped, and an unchanged phrase is not re-searched.
  int _voiceToken = 0;
  String? _lastVoiceSearch;

  List<_DialKey> _buildKeys(AppSettings settings) {
    final scriptLegends = T9Utils.getScriptKeyLegends(settings.dialpadScript);
    return [
      const _DialKey('1', ''),
      _DialKey('2', 'ABC', scriptLegends['2'] ?? ''),
      _DialKey('3', 'DEF', scriptLegends['3'] ?? ''),
      _DialKey('4', 'GHI', scriptLegends['4'] ?? ''),
      _DialKey('5', 'JKL', scriptLegends['5'] ?? ''),
      _DialKey('6', 'MNO', scriptLegends['6'] ?? ''),
      _DialKey('7', 'PQRS', scriptLegends['7'] ?? ''),
      _DialKey('8', 'TUV', scriptLegends['8'] ?? ''),
      _DialKey('9', 'WXYZ', scriptLegends['9'] ?? ''),
      const _DialKey('*', ''),
      const _DialKey('0', '+'),
      const _DialKey('#', ''),
    ];
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill from a tel: link routed into the app. Keep only dial-safe
    // characters; the suggestion strip then resolves the number to a contact.
    final initial = _dialSafe(widget.initialNumber ?? '');
    _number = initial;
    _numberController = TextEditingController(text: initial);
    _numberController.addListener(_onNumberChanged);
    if (initial.isNotEmpty) {
      _refreshSuggestions();
    }
    _loadFavorites();
  }

  Timer? _backspaceTimer;
  Timer? _backspaceDelayTimer;

  @override
  void dispose() {
    _stopContinuousBackspace();
    _numberController.removeListener(_onNumberChanged);
    _numberController.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }

  void _startContinuousBackspace() {
    _stopContinuousBackspace();
    _backspace();
    _backspaceDelayTimer = Timer(const Duration(milliseconds: 320), () {
      _backspaceTimer = Timer.periodic(const Duration(milliseconds: 65), (_) {
        if (!mounted || _numberController.text.isEmpty) {
          _stopContinuousBackspace();
          return;
        }
        _backspace();
      });
    });
  }

  void _stopContinuousBackspace() {
    _backspaceDelayTimer?.cancel();
    _backspaceDelayTimer = null;
    _backspaceTimer?.cancel();
    _backspaceTimer = null;
  }

  void _onNumberChanged() {
    final newText = _numberController.text;
    if (newText != _number) {
      setState(() {
        _number = newText;
        _linkedContactId = null;
        _linkedName = null;
        _clearVoice();
      });
      _refreshSuggestions();
    }
  }

  /// Re-queries the Favorites and Top-contacts lists. Called by [HomeShell] when
  /// the Dialer tab is selected, since the [IndexedStack] keeps this screen alive
  /// and stars/scores may have changed on another tab since it was built.
  void reload() {
    if (mounted) _loadFavorites();
  }

  void _press(String char) {
    final text = _numberController.text;
    final sel = _numberController.selection;
    int start = sel.start;
    int end = sel.end;
    if (start < 0 || start > text.length) start = text.length;
    if (end < 0 || end > text.length) end = text.length;
    if (start > end) {
      final temp = start;
      start = end;
      end = temp;
    }

    final updatedText = text.replaceRange(start, end, char);
    final newCursor = start + char.length;

    _numberController.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: newCursor),
    );
    _numberFocusNode.requestFocus();
  }



  void _clear() {
    _numberController.value = TextEditingValue.empty;
  }

  void _backspace() {
    final text = _numberController.text;
    if (text.isEmpty) return;

    final sel = _numberController.selection;
    int start = sel.start;
    int end = sel.end;

    if (start >= 0 && end >= 0 && start != end) {
      if (start > end) {
        final temp = start;
        start = end;
        end = temp;
      }
      final updatedText = text.replaceRange(start, end, '');
      _numberController.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: start),
      );
    } else {
      final deletePos = start > 0 ? start - 1 : text.length - 1;
      if (deletePos < 0) return;
      final updatedText = text.replaceRange(deletePos, deletePos + 1, '');
      _numberController.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: deletePos),
      );
    }
  }

  /// Drops any pending voice-match list; call inside setState. Typing,
  /// pasting or picking a match supersedes what was spoken.
  void _clearVoice() {
    _voiceQuery = null;
    _voiceMatches = const [];
    _lastVoiceSearch = null;
  }

  /// A voice phrase from the mic, streamed in: partial results update the field
  /// / match list live so the user sees progress right away, and the final
  /// result resolves a single confident match into a short "Calling…" countdown.
  ///
  /// A spoken number fills the field (never auto-dials). A name runs the same
  /// slim contact search the contacts list uses; one match with a number is
  /// confirmed then dialed, several are listed to pick from.
  Future<void> _onVoiceWords(String words, bool isFinal) async {
    final parsed = VoiceDialParser.parse(words);
    if (parsed == null || !mounted) return;

    if (parsed.isNumber) {
      // Reflect the digits live; a spoken number is never auto-dialed.
      _numberController.value = TextEditingValue(
        text: parsed.value,
        selection: TextSelection.collapsed(offset: parsed.value.length),
      );
      return;
    }

    // Live name search. Partials repeat the same words, so skip a phrase we
    // already searched, and drop a response that arrives after a newer phrase.
    if (!isFinal && parsed.value == _lastVoiceSearch) return;
    _lastVoiceSearch = parsed.value;
    final token = ++_voiceToken;
    final matches = await _voiceSearch(parsed.value);
    if (!mounted || token != _voiceToken) return;

    // One confident match on the *final* phrase → fill and dial after a
    // cancellable countdown. Partials, or several matches, just show the list.
    if (isFinal &&
        matches.length == 1 &&
        matches.first.number.trim().isNotEmpty) {
      _confirmAndCall(matches.first);
      return;
    }
    setState(() {
      _voiceQuery = words;
      _voiceMatches = matches;
    });
  }

  /// Runs the dialer's voice name lookup: an exact/substring match first, then a
  /// stem fallback that resolves an inflected Malayalam name ("സീതയെ" → "സീത")
  /// to its contact. Returns an empty list on any error.
  Future<List<PhoneMatch>> _voiceSearch(String query) async {
    try {
      var hits = await _contacts.searchContactSummaries(query);
      if (hits.isEmpty) {
        hits = await _contacts.searchContactsByNameStem(query);
      }
      return [
        for (final c in hits)
          if (c.id != null)
            PhoneMatch(
              contactId: c.id!,
              contactName: c.fullName,
              firstName: c.firstName,
              number: c.phoneNumbers.isEmpty ? '' : c.phoneNumbers.first.number,
            ),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Fills the field with a single voice match and places the call right away —
  /// the mic already took its time to capture, so nothing stalls after that. A
  /// brief "Calling…" snackbar shows for feedback but does not gate the call.
  void _confirmAndCall(PhoneMatch match) {
    _selectSuggestion(match); // fills the number + linked name, clears voice
    final name = match.contactName.trim().isEmpty
        ? match.number
        : match.contactName;
    _showSnack('Calling $name…');
    _placeCall();
  }

  /// Keeps only characters a dialer can actually dial: digits, a leading-plus
  /// for intl, the DTMF keys `*`/`#`, and the pause/wait separators `,`/`;`.
  /// Everything else (spaces, dashes, parens, letters, newlines) is stripped.
  static String _dialSafe(String raw) =>
      raw.replaceAll(RegExp(r'[^0-9+*#,;]'), '');

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }





  /// Loads the two lists shown in the empty state — starred Favorites and the
  /// highest-scoring Top contacts. Best-effort: on error a list simply stays as
  /// it is. Called on init and whenever a contact edit might have changed either.
  Future<void> _loadFavorites() async {
    final source = context.read<AppSettings>().dialerTopSource;
    try {
      final favs = await _contacts.getFavoriteMatches();
      if (mounted) setState(() => _favorites = favs);
    } catch (_) {
      /* leave favorites as-is */
    }
    try {
      final (top, shownAs) = switch (source) {
        DialerTopSource.relations => (
          await _contacts.getFamilyFriendsMatches(),
          DialerTopSource.relations,
        ),
        DialerTopSource.likelyToAnswer => await _loadLikelyToAnswer(),
        DialerTopSource.recent => (
          await _contacts.getTopRecentMatches(),
          DialerTopSource.recent,
        ),
      };
      if (mounted) {
        setState(() {
          _topSource = shownAs;
          _topContacts = top;
        });
      }
    } catch (_) {
      /* leave top contacts as-is */
    }
  }

  /// The "Likely to answer now" ordering: contacts whose measured answer rate in
  /// the current part of the day is clearly better than their own average, best
  /// first. Falls back to the recency list when nobody has enough history —
  /// an empty section would be worse than the ordinary one.
  ///
  /// Ordering only. These rows behave exactly like the other sources' rows: the
  /// user taps to call, and nothing here dials on its own.
  /// Returns the recency list under [DialerTopSource.recent] when it falls back,
  /// so the caller labels the section honestly instead of promising an ordering
  /// it didn't apply.
  Future<(List<PhoneMatch>, DialerTopSource)> _loadLikelyToAnswer() async {
    final ids = await _reachWindows.contactIdsLikelyNow();
    final matches = ids.isEmpty
        ? const <PhoneMatch>[]
        : await _contacts.getMatchesForIds(ids);
    if (matches.isEmpty) {
      return (await _contacts.getTopRecentMatches(), DialerTopSource.recent);
    }
    return (matches, DialerTopSource.likelyToAnswer);
  }

  Future<void> _refreshSuggestions() async {
    final token = ++_queryToken;
    final query = _number;
    if (query.isEmpty) {
      if (mounted) setState(() => _suggestions = const []);
      return;
    }
    try {
      final matches = await _contacts.findByPhoneFragment(query);
      // Ignore stale responses if the input changed while we were querying.
      if (!mounted || token != _queryToken) return;
      setState(() => _suggestions = matches);
    } catch (_) {
      if (mounted && token == _queryToken) {
        setState(() => _suggestions = const []);
      }
    }
  }

  void _selectSuggestion(PhoneMatch match) {
    if (match.number.trim().isEmpty) {
      // A favorite with no phone can't fill the field — open it instead.
      _openContact(match.contactId);
      return;
    }
    final cleanNumber = _dialSafe(match.number);
    final targetText = cleanNumber.isNotEmpty ? cleanNumber : match.number;
    _numberController.value = TextEditingValue(
      text: targetText,
      selection: TextSelection.collapsed(offset: targetText.length),
    );
    setState(() {
      _linkedContactId = match.contactId;
      _linkedName = match.contactName.isEmpty ? null : match.contactName;
      _clearVoice();
    });
    // Re-query so the tapped contact stays visible as a match. Clearing the
    // list here would make the strip fall into its "no saved contact" branch
    // and wrongly offer "Add to contacts" for a number that is saved.
    _refreshSuggestions();
  }

  Future<void> _openContact(int contactId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactDetailScreen(contactId: contactId),
      ),
    );
    // A favorite may have been toggled while we were away.
    _loadFavorites();
  }

  Future<void> _placeCall() async {
    if (_number.trim().isEmpty) return;
    await startCall(
      contactId: _linkedContactId,
      number: _number,
      displayName: _linkedName ?? _number,
    );
    _popIfAddingCall();
  }

  Future<void> _callMatch(PhoneMatch match) async {
    if (match.number.trim().isEmpty) return;
    await startCall(
      contactId: match.contactId,
      number: match.number,
      displayName: match.contactName.isEmpty ? match.number : match.contactName,
    );
    _popIfAddingCall();
  }

  /// When dialing a second party for a conference, return to the in-call screen
  /// once the call is placed (Telecom holds the first leg). Popping disposes this
  /// screen, so its own reconciliation/feedback doesn't fire for the second leg —
  /// the in-call UI now owns the multi-call state.
  void _popIfAddingCall() {
    if (widget.addCallMode && mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _addToContacts() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditContactScreen(initialNumber: _number),
      ),
    );
    if (saved == true) {
      _loadFavorites();
      _refreshSuggestions();
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    // The "Top contacts" source may have changed while in Settings.
    if (mounted) _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(colors),
            _numberDisplay(colors),
            // Fills the flexible region between number display and dialpad so
            // the dialpad remains in a fixed position at the bottom without jumping.
            Expanded(
              child: _strip(colors),
            ),
            _dialpad(colors),
            const SizedBox(height: 4),
            _callRow(colors),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _appBar(AppColors colors) {
    final isModal = widget.dtmfMode || widget.addCallMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
      child: Row(
        children: [
          if (isModal)
            IconButton(
              icon: Icon(
                widget.dtmfMode ? Icons.close : Icons.arrow_back,
                color: colors.mutedText,
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              tooltip: widget.dtmfMode ? 'Hide keypad' : 'Back',
            ),
          Expanded(
            child: Text(
              widget.dtmfMode
                  ? 'Keypad (DTMF)'
                  : (widget.addCallMode ? 'Add call' : 'Dialer'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) {
              if (v == 'settings') _openSettings();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.searchFill,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.more_vert, size: 20, color: colors.mutedText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberDisplay(AppColors colors) {
    final defaultIso = context.watch<AppSettings>().defaultCountryIso;
    final validation = _number.isNotEmpty
        ? PhoneNormalizer.validateNumber(_number, defaultIso: defaultIso)
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Center(
                    child: TextField(
                      controller: _numberController,
                      focusNode: _numberFocusNode,
                      keyboardType: TextInputType.none,
                      showCursor: true,
                      textAlign: TextAlign.center,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+*#,;]')),
                      ],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintText: 'Start typing to find a contact',
                        hintStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.mutedText,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: VoiceInputButton(
                    tooltip: 'Voice dialing',
                    onWords: _onVoiceWords,
                  ),
                ),
              ],
            ),
          ),
          if (validation != null &&
              validation.formatted != null &&
              validation.formatted != _number)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    validation.isValid
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    size: 13,
                    color: validation.isValid
                        ? Colors.green
                        : colors.mutedText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    validation.formatted!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _strip(AppColors colors) {
    // Typing, with matches → live suggestions.
    if (_number.isNotEmpty && _suggestions.isNotEmpty) {
      final n = _suggestions.length;
      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
        children: [
          _header(n == 1 ? '1 match' : '$n matches', colors),
          for (final m in _suggestions) _matchRow(m, colors, favorite: false),
        ],
      );
    }

    // Typing, no match → offer to add, plus an empty note.
    if (_number.isNotEmpty) {
      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
        children: [
          _addToContactsCard(colors),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 4),
            child: Text(
              'No saved contact for this number yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: colors.mutedText,
              ),
            ),
          ),
        ],
      );
    }

    // A spoken name (voice dialing) → its candidate contacts, or a miss note.
    if (_voiceQuery != null) {
      if (_voiceMatches.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No contact matches "$_voiceQuery".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: colors.mutedText,
              ),
            ),
          ),
        );
      }
      return ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
        children: [
          _header('Heard "$_voiceQuery"', colors),
          for (final m in _voiceMatches) _matchRow(m, colors, favorite: false),
        ],
      );
    }

    // Empty input → Favorites and Top contacts.
    if (_favorites.isEmpty && _topContacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Star a contact to see it here',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.mutedText, fontSize: 13.5),
          ),
        ),
      );
    }
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      children: [
        if (_favorites.isNotEmpty) ...[
          _header('Favorites', colors),
          for (final m in _favorites) _matchRow(m, colors, favorite: true),
        ],
        if (_topContacts.isNotEmpty) ...[
          _header(
            switch (_topSource) {
              DialerTopSource.relations => 'Family & friends',
              DialerTopSource.likelyToAnswer => 'Likely to answer now',
              DialerTopSource.recent => 'Top contacts',
            },
            colors,
          ),
          for (final m in _topContacts) _matchRow(m, colors, favorite: true),
        ],
      ],
    );
  }

  Widget _header(String text, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: colors.mutedText,
        ),
      ),
    );
  }

  Widget _addToContactsCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    return Material(
      color: colors.searchFill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _addToContacts,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.person_add_alt_1, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add to contacts',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _number,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: colors.mutedText,
                      ),
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

  Widget _matchRow(PhoneMatch m, AppColors colors, {required bool favorite}) {
    final accent = Theme.of(context).colorScheme.primary;
    final initial = m.firstName.isNotEmpty ? initialFor(m.firstName) : '#';
    final hasNumber = m.number.trim().isNotEmpty;
    final subtitle = <String>[
      if (m.label != null) m.label!,
      if (hasNumber) m.number,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: colors.isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: favorite
              ? () => _openContact(m.contactId)
              : () => _selectSuggestion(m),
          onLongPress: favorite ? null : () => _openContact(m.contactId),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _avatar(
                  initial,
                  colors,
                  circle: favorite,
                  photoPath: m.photoPath,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.contactName.isEmpty ? m.number : m.contactName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.mutedText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Call',
                  onPressed: hasNumber ? () => _callMatch(m) : null,
                  icon: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: hasNumber ? 0.12 : 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call,
                      size: 16,
                      color: hasNumber ? accent : colors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(
    String initial,
    AppColors colors, {
    required bool circle,
    String? photoPath,
  }) {
    final hasPhoto = photoPath != null && File(photoPath).existsSync();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: hasPhoto ? null : colors.brandGradient,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(11),
        image: hasPhoto
            ? DecorationImage(
                image: FileImage(File(photoPath)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? null
          : AvatarInitial(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  Widget _dialpad(AppColors colors) {
    final settings = context.watch<AppSettings>();
    final keys = _buildKeys(settings);
    final accent = Theme.of(context).colorScheme.primary;
    final grid = GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.85,
      mainAxisSpacing: 8,
      crossAxisSpacing: 12,
      children: keys.map((k) => _key(k, colors)).toList(),
    );

    // Faint ambient color behind the pad so the frosted keys have something to
    // refract — otherwise glass over a flat background reads as a plain tint.
    final glowA = accent.withValues(alpha: colors.isDark ? 0.22 : 0.16);
    final glowB = colors.gradientEnd.withValues(
      alpha: colors.isDark ? 0.20 : 0.14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          Positioned(left: -10, top: 10, child: _ambientGlow(glowA)),
          Positioned(right: -20, bottom: 0, child: _ambientGlow(glowB)),
          grid,
        ],
      ),
    );
  }

  Widget _ambientGlow(Color color) {
    return Container(
      width: 190,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }

  Widget _key(_DialKey k, AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final isZero = k.digit == '0';
    const radius = 20.0;
    final dark = colors.isDark;

    // Translucent frosted fill: brighter top-left, dimmer bottom-right for sheen.
    final fill = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.04),
            ]
          : [
              Colors.white.withValues(alpha: 0.55),
              Colors.white.withValues(alpha: 0.28),
            ],
    );
    // Bright hairline edge — the glass rim.
    final border = Border.all(
      color: dark
          ? Colors.white.withValues(alpha: 0.18)
          : Colors.white.withValues(alpha: 0.60),
    );
    // Soft glow (ambient + faint accent tint), on the outer box so the clip
    // below doesn't cut it off.
    final shadows = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: dark ? 0.40 : 0.10),
        blurRadius: 20,
        offset: const Offset(0, 10),
        spreadRadius: -8,
      ),
      BoxShadow(
        color: accent.withValues(alpha: dark ? 0.14 : 0.10),
        blurRadius: 16,
        offset: const Offset(0, 4),
        spreadRadius: -10,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: fill,
              border: border,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) {
                  if (widget.dtmfMode) {
                    _telecom.playDtmf(k.digit);
                  }
                },
                onTapUp: (_) {
                  if (widget.dtmfMode) {
                    _telecom.stopDtmf();
                  }
                },
                onTapCancel: () {
                  if (widget.dtmfMode) {
                    _telecom.stopDtmf();
                  }
                },
                child: InkWell(
                  highlightColor: accent.withValues(alpha: 0.12),
                  splashColor: accent.withValues(alpha: 0.14),
                  onTap: () => _press(k.digit),
                  onLongPress: isZero ? () => _press('+') : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        k.digit,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                      if (k.letters.isNotEmpty || k.mlLetters.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (k.letters.isNotEmpty)
                              Text(
                                k.letters,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                  color: colors.mutedText,
                                ),
                              ),
                            if (k.letters.isNotEmpty && k.mlLetters.isNotEmpty)
                              Text(
                                ' · ',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.mutedText.withValues(alpha: 0.6),
                                ),
                              ),
                            if (k.mlLetters.isNotEmpty)
                              Text(
                                k.mlLetters,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.mutedText,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _callRow(AppColors colors) {
    if (widget.dtmfMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            const SizedBox(width: 44),
            Expanded(
              child: Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.expand_more, size: 20),
                  label: const Text(
                    'Hide Keypad',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
      );
    }
    final accent = Theme.of(context).colorScheme.primary;
    final enabled = _number.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          // Left spacer balances the right spacer so the call button
          // stays centered.
          const SizedBox(width: 44),
          Expanded(
            child: Center(
              child: GestureDetector(
                onLongPress: _number.isEmpty ? null : _clear,
                child: Opacity(
                  opacity: enabled ? 1 : 0.45,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: colors.brandGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.gradientStart.withValues(alpha: 0.6),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                          spreadRadius: -6,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: enabled ? _placeCall : null,
                        child: Icon(
                          Icons.call,
                          color: AppTheme.contrastOn(accent),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: enabled
                ? Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (_) => _startContinuousBackspace(),
                    onPointerUp: (_) => _stopContinuousBackspace(),
                    onPointerCancel: (_) => _stopContinuousBackspace(),
                    child: IconButton(
                      icon: Icon(
                        Icons.backspace_outlined,
                        color: colors.mutedText,
                        size: 22,
                      ),
                      onPressed: () {},
                      tooltip: 'Backspace (hold to delete continuously)',
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _DialKey {
  final String digit;
  final String letters;
  final String mlLetters;
  const _DialKey(this.digit, this.letters, [this.mlLetters = '']);
}
