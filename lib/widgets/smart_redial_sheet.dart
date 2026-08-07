// lib/widgets/smart_redial_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/screens/sim_settings_screen.dart';
import 'package:smart_contacts_dialer/services/smart_redial_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Shows the Smart Redial & Reach Me bottom sheet when a call goes unanswered or fails.
Future<void> showSmartRedialSheet(
  BuildContext context, {
  required String phoneNumber,
  int? contactId,
  String displayName = 'this contact',
  String? simId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SmartRedialSheet(
      phoneNumber: phoneNumber,
      contactId: contactId,
      displayName: displayName,
      simId: simId,
    ),
  );
}

class _SmartRedialSheet extends StatefulWidget {
  final String phoneNumber;
  final int? contactId;
  final String displayName;
  final String? simId;

  const _SmartRedialSheet({
    required this.phoneNumber,
    this.contactId,
    required this.displayName,
    this.simId,
  });

  @override
  State<_SmartRedialSheet> createState() => _SmartRedialSheetState();
}

class _SmartRedialSheetState extends State<_SmartRedialSheet> {
  final SmartRedialService _redialService = SmartRedialService();
  late int _selectedDelayMinutes;
  late TextEditingController _messageController;
  bool _isEditingMessage = false;

  static const List<int> _delayOptions = [1, 3, 5, 10, 15, 30];

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<AppSettings>(context, listen: false);
    _selectedDelayMinutes = settings.smartRedialDelayMinutes;
    _messageController =
        TextEditingController(text: settings.presetReachMeMessage);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _scheduleAutoRetry() async {
    // Without this permission the native alarm can't be armed at all (it
    // throws and silently schedules nothing) — check first so the user gets
    // a clear "go grant this" prompt instead of a reminder that quietly
    // never fires.
    final hasPermission = await TelecomService().hasExactAlarmPermission();
    if (!hasPermission) {
      if (!mounted) return;
      final shouldOpenSettings = await _showExactAlarmPermissionDialog();
      if (shouldOpenSettings == true) {
        await TelecomService().requestExactAlarmPermission();
      }
      return;
    }

    final SmartRedialTask task;
    try {
      task = await _redialService.scheduleAutoRedial(
        phoneNumber: widget.phoneNumber,
        contactId: widget.contactId,
        displayName: widget.displayName,
        delayMinutes: _selectedDelayMinutes,
        simId: widget.simId,
      );
    } catch (_) {
      // Belt-and-suspenders: the permission check above should already
      // catch the common cause, so this only fires for some other native
      // scheduling failure.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not schedule auto-retry')),
      );
      return;
    }

    if (!mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    navigator.pop();

    messenger.showSnackBar(
      SnackBar(
        // The clock time, not a countdown: this message can stay on screen
        // longer than intended (its dismiss timer only starts once the entry
        // animation finishes, and that stalls while the app is off-screen —
        // e.g. a call arriving right after scheduling), and "in 5 min" would
        // then be quietly wrong.
        content: Text(
          'Auto-retry at ${_clockTime(task.fireAt)} for ${widget.displayName}',
        ),
        action: SnackBarAction(
          label: 'View',
          // Opens SIM & calling settings, which lists the pending redials with
          // a cancel action.
          onPressed: () => navigator.push(
            MaterialPageRoute<void>(builder: (_) => const SimSettingsScreen()),
          ),
        ),
      ),
    );
  }

  /// A wall-clock time like "7:23 PM" — what the user will actually see on the
  /// phone when the retry runs.
  String _clockTime(DateTime when) {
    final hour = when.hour % 12 == 0 ? 12 : when.hour % 12;
    final minute = when.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${when.hour < 12 ? 'AM' : 'PM'}';
  }

  /// Explains why auto-retry needs the "Alarms & reminders" permission and
  /// offers to open the system settings screen to grant it (there's no
  /// runtime request dialog for this one). Returns true if the user chose to
  /// open settings.
  Future<bool?> _showExactAlarmPermissionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Allow "Alarms & reminders"'),
        content: const Text(
          'Auto-Retry needs the "Alarms & reminders" permission so it can '
          'call back on schedule even if this app is closed. Enable it for '
          'ContactSphere in the settings screen that opens next.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final sent = await _redialService.sendReachMeMessage(
      phoneNumber: widget.phoneNumber,
      customMessage: _messageController.text,
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    if (!sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch messaging app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: colors.isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.06))
              : null,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.mutedText.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_missed,
                        color: Color(0xFFF59E0B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Call Unanswered',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.displayName} (${widget.phoneNumber})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: colors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Option 1: Auto-Retry
                _sectionHeader(
                  title: 'OPTION 1: ONE-TAP AUTO-RETRY',
                  colors: colors,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mins in _delayOptions)
                      _delayChip(
                        minutes: mins,
                        selected: _selectedDelayMinutes == mins,
                        accent: accent,
                        colors: colors,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _scheduleAutoRetry,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.timer, size: 18),
                    label: Text(
                      'Auto-Retry in $_selectedDelayMinutes min',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Option 2: Send Reach Me Message
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionHeader(
                      title: 'OPTION 2: REACH ME MESSAGE',
                      colors: colors,
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditingMessage ? Icons.check : Icons.edit_note,
                        size: 20,
                        color: accent,
                      ),
                      tooltip: _isEditingMessage ? 'Done' : 'Edit message',
                      onPressed: () {
                        setState(() {
                          _isEditingMessage = !_isEditingMessage;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (_isEditingMessage)
                  TextField(
                    controller: _messageController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type your reach me message...',
                      filled: true,
                      fillColor: colors.searchFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.searchFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.mutedText.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      _messageController.text,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _sendMessage,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: accent),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text(
                      'Send "Trying to Reach You" SMS',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.mutedText,
                      ),
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

  Widget _sectionHeader({
    required String title,
    required AppColors colors,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: colors.mutedText,
      ),
    );
  }

  Widget _delayChip({
    required int minutes,
    required bool selected,
    required Color accent,
    required AppColors colors,
  }) {
    return FilterChip(
      selected: selected,
      label: Text('$minutes min'),
      selectedColor: accent,
      checkmarkColor: AppTheme.contrastOn(accent),
      labelStyle: TextStyle(
        color: selected ? AppTheme.contrastOn(accent) : null,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
      onSelected: (_) {
        setState(() {
          _selectedDelayMinutes = minutes;
        });
      },
    );
  }
}
