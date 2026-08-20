// lib/screens/call_history_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:smart_contacts_dialer/models/call_record.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/repositories/flagged_number_repository.dart';
import 'package:smart_contacts_dialer/services/call_event_logger.dart';
import 'package:smart_contacts_dialer/services/call_log_import_service.dart';
import 'package:smart_contacts_dialer/state/call_log_events.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/avatar_initial.dart';
import 'package:smart_contacts_dialer/widgets/call_lifecycle_mixin.dart';
import 'package:smart_contacts_dialer/widgets/smart_redial_sheet.dart';
import 'package:smart_contacts_dialer/widgets/voice_input_button.dart';

import 'package:smart_contacts_dialer/screens/contact_detail_screen.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/screens/settings_screen.dart';

/// The "Recents" call history: every logged call, newest first, grouped by day.
/// Tapping a linked call opens the contact; the trailing button calls back
/// (through [CallLifecycleMixin], so it reconciles + asks for feedback too).
class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => CallHistoryScreenState();
}

class CallHistoryScreenState extends State<CallHistoryScreen>
    with WidgetsBindingObserver, CallLifecycleMixin<CallHistoryScreen> {
  final CallLogRepository _repo = CallLogRepository();
  final CallLogImportService _deviceCallLog = CallLogImportService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  /// The live search text. While it is non-empty the list shows DB-backed
  /// search results (the whole history, not just the loaded pages) and paging
  /// is off; clearing it restores the normal paged list.
  String _searchQuery = '';

  List<CallRecord> _calls = const [];
  bool _loading = true;

  /// How many calls are held in memory. Grows a page at a time as the user
  /// scrolls, so a full device-log import stays reachable instead of being cut
  /// off at the first page. A refresh re-reads however many are on screen, so
  /// the list never jumps back to the top page under the user.
  int _loadedCount = _pageSize;
  bool _hasMore = true;
  bool _loadingMore = false;

  static const int _pageSize = 300;

  @override
  void initState() {
    super.initState();
    // Refresh when CallEventLogger finishes writing an incoming/missed call, or
    // when a call is placed/reconciled, so a call handled while this tab is open
    // shows up without leaving it.
    CallLogEvents.instance.addListener(_onCallLogged);
    _scrollController.addListener(_onScroll);
    _load();
    // Bring in anything the phone logged while the app wasn't watching — calls
    // from another dialer, from the lock screen, or while the app was killed.
    _syncDeviceCallLog(force: true);
  }

  @override
  void dispose() {
    CallLogEvents.instance.removeListener(_onCallLogged);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Coming back to the app is the moment a call taken elsewhere should appear.
    if (state == AppLifecycleState.resumed) _syncDeviceCallLog(force: true);
  }

  void _onCallLogged() => _load();

  @override
  void onCallReconciled() => _load();

  /// Re-queries the call history. Called by [HomeShell] when the Recents tab is
  /// selected, so calls placed from other tabs (which reconcile on their own
  /// screens) show up without relaunching the app.
  void reload() {
    _load();
    _syncDeviceCallLog(force: true);
  }

  /// Pulls new calls from the device call log in the background. It notifies
  /// [CallLogEvents] when something changed, which reloads the list.
  /// Never awaited — the list shows what the app already has straight away.
  void _syncDeviceCallLog({bool force = false}) {
    unawaited(_deviceCallLog.syncFromDevice(force: force));
  }

  /// Loads the next page when the user nears the end of the list.
  void _onScroll() {
    // Search results come back in one shot; there is nothing to page.
    if (_searchQuery.isNotEmpty) return;
    if (!_hasMore || _loadingMore || _loading) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      _loadingMore = true;
      _loadedCount += _pageSize;
      _load();
    }
  }

  Future<void> _load() async {
    // Only show the spinner when there is nothing to show yet. Recents now
    // reloads often (a call placed, a call ended, a device sync landing), and
    // replacing the list with a spinner each time would flash the screen.
    if (mounted && _calls.isEmpty) setState(() => _loading = true);
    try {
      // Pull in any calls the screening service blocked since the last look
      // (they never reach the call-event stream), plus any call-waiting calls
      // the in-call service parked (never surfaced to the snapshot logger) and
      // the reasons parked for outgoing calls no screen was watching (a Smart
      // Redial retry dialed natively), then read the history.
      await CallEventLogger().drainBlockedCalls();
      await CallEventLogger().drainCallWaitingCalls();
      await CallEventLogger().drainOutgoingOutcomes();
      final searching = _searchQuery.isNotEmpty;
      final calls = searching
          ? await _repo.searchCalls(_searchQuery)
          : await _repo.recentCalls(limit: _loadedCount);
      if (!mounted) return;
      setState(() {
        _calls = calls;
        // Fewer rows than asked for means we've reached the end of the history.
        _hasMore = !searching && calls.length >= _loadedCount;
        _loading = false;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _calls = const [];
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear call history?'),
        content: const Text(
          'This removes all logged calls from SreerajP Contacts Sphere.',
        ),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repo.clearHistory();
    } catch (_) {
      // ignore; reload reflects reality either way
    }
    await _load();
  }

  /// Left-zone tap: open the linked contact, or — for an unknown number with no
  /// contact page — start "Add to contact" with the number prefilled. Reloads
  /// afterwards so a newly linked/created contact shows on the row.
  Future<void> _openLeft(CallRecord call) async {
    if (call.contactId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ContactDetailScreen(contactId: call.contactId!),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddEditContactScreen(initialNumber: call.phoneNumber),
        ),
      );
    }
    if (mounted) await _load();
  }

  Future<void> _callBack(CallRecord call) async {
    await startCall(
      contactId: call.contactId,
      number: call.phoneNumber,
      displayName: call.displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(colors),
            _buildSearch(context, colors),
            Expanded(child: _body(colors)),
          ],
        ),
      ),
    );
  }

  Widget _header(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Recents',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colors.mutedText),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
          // Hidden while searching — "Clear history" wipes everything, not the
          // filtered rows on screen, which would be a nasty surprise.
          if (_searchQuery.isEmpty && _calls.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: colors.mutedText),
              tooltip: 'Clear history',
              onPressed: _clear,
            ),
        ],
      ),
    );
  }

  /// Search box for the history, styled to match the one on the Contacts
  /// screen. Typing runs a DB-backed search over the whole history, so a call
  /// from months ago is found without scrolling it into memory first.
  Widget _buildSearch(BuildContext context, AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.searchFill,
          borderRadius: BorderRadius.circular(18),
          border: colors.isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.06))
              : null,
          boxShadow: colors.isDark
              ? null
              : [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search calls',
            prefixIcon: Icon(Icons.search, color: accent),
            suffixIcon: _searchQuery.isEmpty
                // Voice search: partial results land in the field live, each
                // running the same search as typing.
                ? VoiceInputButton(
                    onWords: (words, _) {
                      _searchController.text = words;
                      _searchController.selection = TextSelection.collapsed(
                        offset: words.length,
                      );
                      _onSearchChanged(words);
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.close, color: colors.mutedText),
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                      _searchFocusNode.unfocus();
                    },
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    final next = value.trim();
    if (next == _searchQuery) return;
    setState(() {
      _searchQuery = next;
      // Leaving the search drops back to the first page rather than whatever
      // depth the user had scrolled to before searching.
      if (next.isEmpty) _loadedCount = _pageSize;
    });
    _load();
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Widget _body(AppColors colors) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_calls.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _searchQuery.isEmpty
                ? 'No calls yet. Calls you place show up here.'
                : 'No calls match that search.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.mutedText, fontSize: 14),
          ),
        ),
      );
    }

    // Build a flat list of section headers + rows, grouped by calendar day.
    final items = <_HistoryItem>[];
    String? lastBucket;
    for (final call in _calls) {
      final bucket = _dayBucket(call.timestamp);
      if (bucket != lastBucket) {
        items.add(_HistoryItem.header(bucket));
        lastBucket = bucket;
      }
      items.add(_HistoryItem.call(call));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item.isHeader) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
            child: Text(
              item.header!.toUpperCase(),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: colors.mutedText,
              ),
            ),
          );
        }
        return _callCard(item.call!, colors);
      },
    );
  }

  Widget _callCard(CallRecord call, AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final (icon, iconColor) = _typeIcon(call.callType, call.callOutcome, accent);
    // What happened, for a call that has no duration to show. Null for an
    // answered call (the duration already says it) and for a call whose outcome
    // we never learned — an old or imported row then reads exactly as before.
    final outcomeLabel = callOutcomeLabel(call.callOutcome, call.callType);
    // First subtitle line: time · [Blocked] · duration|outcome · SIM · intent.
    final subtitleParts = <String>[
      _timeOfDay(call.timestamp),
      if (call.callType == 'blocked') 'Blocked',
      if (call.duration != null && call.duration! > 0)
        _formatDuration(call.duration!)
      else
        ?outcomeLabel,
      if (call.simLabel != null && call.simLabel!.isNotEmpty) call.simLabel!,
      if (call.callIntent != null && call.callIntent!.isNotEmpty)
        call.callIntent!,
    ];
    // Show the raw number as a second line only when the title is a name (for
    // an unknown caller the title already *is* the number).
    final showNumber =
        call.isLinked &&
        call.phoneNumber.isNotEmpty &&
        call.phoneNumber != call.displayName;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: colors.isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F2A28).withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  spreadRadius: -12,
                ),
              ],
      ),
      // Split tap zones: the left region (avatar + name/subtitle) opens the
      // contact (or "Add to contact" for an unknown number); the right region
      // (type icon + call button) dials. Long-press anywhere shows the actions.
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onLongPress: () => _showActions(call),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _openLeft(call),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        _avatar(call, accent),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                call.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                subtitleParts.join('  ·  '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colors.mutedText,
                                  fontSize: 12.5,
                                ),
                              ),
                              if (showNumber)
                                Text(
                                  call.phoneNumber,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.mutedText,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _callBack(call),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: iconColor, size: 18),
                      IconButton(
                        icon: const Icon(
                          Icons.call,
                          color: Color(0xFF10B981),
                        ),
                        tooltip: 'Call back',
                        onPressed: () => _callBack(call),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The leading avatar for a history row: the linked contact's photo when we
  /// have one, else the first letter of a named contact, else a neutral person
  /// icon for an unknown number (whose "name" is just the raw digits).
  Widget _avatar(CallRecord call, Color accent) {
    final hasPhoto =
        call.photoPath != null && File(call.photoPath!).existsSync();
    final letter =
        call.isLinked &&
            call.contactName != null &&
            call.contactName!.isNotEmpty
        ? initialFor(call.contactName!)
        : null;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        image: hasPhoto
            ? DecorationImage(
                image: FileImage(File(call.photoPath!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? null
          : letter != null
          ? AvatarInitial(
              letter,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            )
          : Icon(Icons.person_outline, color: accent, size: 22),
    );
  }

  /// Long-press actions for a history entry: block/unblock and spam/not-spam
  /// (both feed the native call-screening service), plus removing the row.
  Future<void> _showActions(CallRecord call) async {
    final number = call.phoneNumber.trim();
    final flagged = FlaggedNumberRepository();
    var isBlocked = false;
    var isSpam = false;
    if (number.isNotEmpty) {
      try {
        isBlocked = await flagged.isFlagged(
          number,
          kind: FlaggedNumberRepository.kindBlocked,
        );
        isSpam = await flagged.isFlagged(
          number,
          kind: FlaggedNumberRepository.kindSpam,
        );
      } catch (_) {
        // Show the sheet with both toggles in their default state.
      }
    }
    if (!mounted) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).extension<AppColors>()!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  call.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (number.isNotEmpty) ...[
                ListTile(
                  leading: Icon(
                    isBlocked ? Icons.block_flipped : Icons.block,
                    color: isBlocked
                        ? colors.mutedText
                        : const Color(0xFFEF4444),
                  ),
                  title: Text(isBlocked ? 'Unblock number' : 'Block number'),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(isBlocked ? 'unblock' : 'block'),
                ),
                ListTile(
                  leading: Icon(
                    isSpam ? Icons.report_off_outlined : Icons.report_outlined,
                    color: isSpam ? colors.mutedText : const Color(0xFFF59E0B),
                  ),
                  title: Text(isSpam ? 'Not spam' : 'Mark as spam'),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(isSpam ? 'unspam' : 'spam'),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: Color(0xFFF59E0B)),
                title: const Text('Smart Redial & Reach Me'),
                onTap: () => Navigator.of(sheetContext).pop('smart_redial'),
              ),
              if (number.isNotEmpty) ...[
                ListTile(
                  leading: Icon(Icons.copy_outlined, color: colors.mutedText),
                  title: const Text('Copy number'),
                  onTap: () => Navigator.of(sheetContext).pop('copy'),
                ),
                ListTile(
                  leading: Icon(Icons.share_outlined, color: colors.mutedText),
                  title: const Text('Share number'),
                  onTap: () => Navigator.of(sheetContext).pop('share'),
                ),
              ],
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.mutedText),
                title: const Text('Remove from history'),
                onTap: () => Navigator.of(sheetContext).pop('delete'),
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (action == null || !mounted) return;

    String? message;
    switch (action) {
      case 'block':
        await flagged.add(number, kind: FlaggedNumberRepository.kindBlocked);
        message = '$number blocked — it can no longer ring you';
      case 'unblock':
        await flagged.removeNumber(
          number,
          kind: FlaggedNumberRepository.kindBlocked,
        );
        message = '$number unblocked';
      case 'spam':
        await flagged.add(number, kind: FlaggedNumberRepository.kindSpam);
        message = '$number marked as spam';
      case 'unspam':
        await flagged.removeNumber(
          number,
          kind: FlaggedNumberRepository.kindSpam,
        );
        message = '$number is no longer marked as spam';
      case 'smart_redial':
        await showSmartRedialSheet(
          context,
          phoneNumber: call.phoneNumber,
          contactId: call.contactId,
          displayName: call.displayName,
          // Retry on the SIM this call used, when we know it.
          simId: call.simId,
        );
      case 'copy':
        await Clipboard.setData(ClipboardData(text: number));
        message = 'Copied $number to clipboard';
      case 'share':
        await SharePlus.instance.share(ShareParams(text: number));
      case 'delete':
        await _repo.deleteCall(call.id);

        await _load();
    }
    if (message != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// The trailing arrow: direction first, outcome second.
  ///
  /// Outgoing gets two states rather than one icon per outcome. The glyph's job
  /// here is direction — read at a glance while scrolling — and only the arrow
  /// family carries that; a per-outcome icon set would have to borrow marks like
  /// `block` (already the blocked-call icon, meaning the opposite thing: we
  /// turned *them* away) and direction would stop being readable. The precise
  /// reason is spelled out in the subtitle instead.
  ///
  /// Amber, not red, for an outgoing call that didn't connect: red in this list
  /// means "needs you" (a missed call) or "hostile" (a blocked one), and neither
  /// fits someone simply not picking up.
  (IconData, Color) _typeIcon(String? type, String? outcome, Color accent) {
    switch (type) {
      case 'incoming':
        return (Icons.call_received, const Color(0xFF10B981));
      case 'missed':
        return (Icons.call_missed, const Color(0xFFEF4444));
      case 'blocked':
        return (Icons.block, const Color(0xFFEF4444));
      case 'outgoing':
      default:
        // An unknown outcome keeps the plain outgoing arrow, so rows written
        // before this column existed look exactly as they always did.
        return outgoingDidNotConnect(outcome)
            ? (Icons.call_missed_outgoing, const Color(0xFFF59E0B))
            : (Icons.call_made, accent);
    }
  }

  String _dayBucket(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(when.year, when.month, when.day);
    final diff = today.difference(that).inDays;
    if (diff <= 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(when); // weekday name
    return DateFormat('MMM d, yyyy').format(when);
  }

  String _timeOfDay(DateTime when) => DateFormat.jm().format(when);

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }
}

/// Either a day-section header or a call row in the flattened history list.
class _HistoryItem {
  final String? header;
  final CallRecord? call;
  _HistoryItem.header(this.header) : call = null;
  _HistoryItem.call(this.call) : header = null;
  bool get isHeader => header != null;
}
