// lib/screens/number_detail_screen.dart
import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/widgets/call_history_list.dart';
import 'package:smart_contacts_dialer/widgets/call_lifecycle_mixin.dart';

/// The screen for a number that is not saved as a contact, opened from
/// Recents. Two tabs: **History** (every call with this number) and **Add
/// contact** (the add-contact form with the number filled in).
///
/// Saving the form pops this screen with `true`, so the user lands back on
/// Recents, which reloads and shows the new name on the row.
class NumberDetailScreen extends StatefulWidget {
  const NumberDetailScreen({super.key, required this.number});

  final String number;

  @override
  State<NumberDetailScreen> createState() => _NumberDetailScreenState();
}

class _NumberDetailScreenState extends State<NumberDetailScreen>
    with WidgetsBindingObserver, CallLifecycleMixin<NumberDetailScreen> {
  final CallLogRepository _callLog = CallLogRepository();

  /// Calls through [CallLifecycleMixin], so the call is logged, reconciled and
  /// followed by the feedback sheet like a call from Recents.
  Future<void> _call(String number) =>
      startCall(number: number, displayName: number);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.number),
          actions: [
            if (widget.number.trim().isNotEmpty)
              IconButton(
                icon: const Icon(Icons.call, color: Color(0xFF10B981)),
                tooltip: l10n.tooltipCallBack,
                onPressed: () => _call(widget.number),
              ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabHistory),
              Tab(text: l10n.tabAddContact),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CallHistoryList(
              loader: () => _callLog.callsForNumber(widget.number),
              onCall: (call) => _call(call.phoneNumber),
              emptyText: l10n.emptyNoCallsWithNumber,
            ),
            // Kept alive so a half-filled form survives a look at History.
            _KeepAlive(
              child: AddEditContactScreen(
                initialNumber: widget.number,
                embedded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps a tab's widget (and its state) alive while another tab is shown.
class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});

  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
