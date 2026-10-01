// lib/widgets/call_history_list.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:intl/intl.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/l10n/formatting_locale.dart';
import 'package:smart_contacts_dialer/models/call_record.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/state/call_log_events.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/utils/call_type_mapper.dart';
import 'package:smart_contacts_dialer/widgets/post_call_feedback_sheet.dart';

/// The direction icon for a call row: direction first, outcome second.
///
/// Outgoing gets two states rather than one icon per outcome. The glyph's job
/// here is direction — read at a glance while scrolling — and only the arrow
/// family carries that; a per-outcome icon set would have to borrow marks like
/// `block` (already the blocked-call icon, meaning the opposite thing: we
/// turned *them* away) and direction would stop being readable. The precise
/// reason is spelled out in the subtitle instead.
///
/// Amber, not red, for an outgoing call that didn't connect: red in these lists
/// means "needs you" (a missed call) or "hostile" (a blocked one), and neither
/// fits someone simply not picking up.
(IconData, Color) callTypeIcon(String? type, String? outcome, Color accent) {
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
      // before the outcome column existed look exactly as they always did.
      return outgoingDidNotConnect(outcome)
          ? (Icons.call_missed_outgoing, const Color(0xFFF59E0B))
          : (Icons.call_made, accent);
  }
}

/// The day-section header for a call: Today, Yesterday, the weekday within the
/// last week, else the date.
String callDayBucket(BuildContext context, DateTime when) {
  final l10n = AppLocalizations.of(context);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(when.year, when.month, when.day);
  final diff = today.difference(that).inDays;
  if (diff <= 0) return l10n.labelToday;
  if (diff == 1) return l10n.labelYesterday;
  final locale = _formatLocale(context);
  if (diff < 7) return DateFormat('EEEE', locale).format(when);
  return DateFormat('MMM d, yyyy', locale).format(when);
}

/// The call's time of day ("10:32 AM") in the app's language.
String callTimeOfDay(BuildContext context, DateTime when) =>
    DateFormat.jm(_formatLocale(context)).format(when);

/// A call length for display: "45 sec", "3 min", "3 min 12 sec".
String formatCallDuration(AppLocalizations l10n, int seconds) {
  if (seconds < 60) return l10n.labelDurationSeconds(seconds);
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return s == 0
      ? l10n.labelDurationMinutes(m)
      : l10n.labelDurationMinutesSeconds(m, s);
}

/// intl locale for display dates; Sanskrit falls back to English patterns.
String _formatLocale(BuildContext context) =>
    formattingLocale(Localizations.localeOf(context));

/// The calls with one person, newest first and grouped by day — the History
/// tab on a contact's screen and on an unsaved number's screen.
///
/// [loader] fetches the calls; the list re-runs it whenever a call is written
/// ([CallLogEvents]), so a call placed from the tab shows up once it ends.
/// Each row has a call-back button ([onCall]); a long press offers copying the
/// number and removing the row from history.
class CallHistoryList extends StatefulWidget {
  const CallHistoryList({
    super.key,
    required this.loader,
    required this.onCall,
    required this.emptyText,
    this.showNumber = false,
  });

  final Future<List<CallRecord>> Function() loader;
  final void Function(CallRecord call) onCall;

  /// Shown when there are no calls.
  final String emptyText;

  /// Show the number on each row — useful when a contact has several numbers.
  final bool showNumber;

  @override
  State<CallHistoryList> createState() => _CallHistoryListState();
}

class _CallHistoryListState extends State<CallHistoryList>
    with AutomaticKeepAliveClientMixin {
  final CallLogRepository _repo = CallLogRepository();
  List<CallRecord> _calls = const [];
  bool _loading = true;

  // Keep the loaded list when the user flips to another tab and back.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    CallLogEvents.instance.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    CallLogEvents.instance.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final calls = await widget.loader();
      if (!mounted) return;
      setState(() {
        _calls = calls;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _calls = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_calls.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            widget.emptyText,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.mutedText, fontSize: 14),
          ),
        ),
      );
    }

    // A flat list of day headers and call rows.
    final items = <Object>[];
    String? lastBucket;
    for (final call in _calls) {
      final bucket = callDayBucket(context, call.timestamp);
      if (bucket != lastBucket) {
        items.add(bucket);
        lastBucket = bucket;
      }
      items.add(call);
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
            child: Text(
              item.toUpperCase(),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: colors.mutedText,
              ),
            ),
          );
        }
        return _row(item as CallRecord, colors);
      },
    );
  }

  Widget _row(CallRecord call, AppColors colors) {
    final l10n = AppLocalizations.of(context);
    final accent = Theme.of(context).colorScheme.primary;
    final (icon, iconColor) = callTypeIcon(
      call.callType,
      call.callOutcome,
      accent,
    );
    final outcomeLabel = callOutcomeLabel(
      call.callOutcome,
      call.callType,
      l10n,
    );
    // Time · [Blocked] · duration|outcome · SIM · intent — as in Recents.
    final parts = <String>[
      callTimeOfDay(context, call.timestamp),
      if (call.callType == 'blocked') l10n.labelBlocked,
      if (call.duration != null && call.duration! > 0)
        formatCallDuration(l10n, call.duration!)
      else
        ?outcomeLabel,
      if (call.simLabel != null && call.simLabel!.isNotEmpty) call.simLabel!,
      if (call.callIntent != null && call.callIntent!.isNotEmpty)
        postCallIntentLabel(l10n, call.callIntent!),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: colors.isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onLongPress: () => _showActions(call),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parts.join('  ·  '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (widget.showNumber && call.phoneNumber.isNotEmpty)
                        Text(
                          call.phoneNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.mutedText,
                            fontSize: 12.5,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Color(0xFF10B981)),
                  tooltip: l10n.tooltipCallBack,
                  onPressed: call.phoneNumber.isEmpty
                      ? null
                      : () => widget.onCall(call),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Long-press actions for one call: copy its number, or remove the row.
  Future<void> _showActions(CallRecord call) async {
    final l10n = AppLocalizations.of(context);
    final number = call.phoneNumber.trim();
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).extension<AppColors>()!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (number.isNotEmpty)
                ListTile(
                  leading: Icon(Icons.copy_outlined, color: colors.mutedText),
                  title: Text(l10n.actionCopyNumber),
                  onTap: () => Navigator.of(sheetContext).pop('copy'),
                ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.mutedText),
                title: Text(l10n.actionRemoveFromHistory),
                onTap: () => Navigator.of(sheetContext).pop('delete'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (action == null || !mounted) return;
    switch (action) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: number));
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.msgCopiedNumber(number))));
      case 'delete':
        await _repo.deleteCall(call.id);
        await _load();
    }
  }
}
