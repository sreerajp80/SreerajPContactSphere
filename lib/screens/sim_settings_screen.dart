// lib/screens/sim_settings_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/services/smart_redial_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/screens/identification_settings_screen.dart';
import 'package:smart_contacts_dialer/screens/quick_replies_screen.dart';


/// Multi-SIM preferences: pick the default SIM for outgoing calls and toggle the
/// per-call SIM prompt. Reached from the Settings hub.
///
/// The SIM list comes from [SimService]; it's empty off Android or when
/// READ_PHONE_STATE isn't granted, in which case the screen explains that
/// multi-SIM controls are unavailable.
class SimSettingsScreen extends StatefulWidget {
  const SimSettingsScreen({super.key});

  @override
  State<SimSettingsScreen> createState() => _SimSettingsScreenState();
}

class _SimSettingsScreenState extends State<SimSettingsScreen> {
  final SimService _sims = SimService();

  List<SimAccount> _accounts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (mounted) setState(() => _loading = true);
    List<SimAccount> sims;
    try {
      sims = await _sims.list(refresh: refresh);
    } catch (_) {
      sims = const [];
    }
    if (!mounted) return;
    setState(() {
      _accounts = sims;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIM & calling'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh SIMs',
            onPressed: _loading ? null : () => _load(refresh: true),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (_accounts.isEmpty)
                  _noSimsNote(colors)
                else ...[
                  _defaultSimCard(colors),
                  const SizedBox(height: 12),
                  _askSimCard(colors),
                  const SizedBox(height: 12),
                  _simColorsCard(colors),
                ],
                const SizedBox(height: 12),
                _identificationCard(colors),
                const SizedBox(height: 12),
                _quickRepliesCard(colors),
                const SizedBox(height: 12),
                _postCallFeedbackCard(colors),
                const SizedBox(height: 12),
                _smartRedialCard(colors),
              ],
            ),

    );
  }

  /// Routes to the caller-ID / spam-filter preferences. Shown even without
  /// SIMs: identification doesn't depend on multi-SIM support.
  Widget _identificationCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const IdentificationSettingsScreen(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.verified_user_outlined, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Identification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Caller identification and spam filtering',
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
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

  /// Routes to the quick-reply manager: the canned messages offered when
  /// rejecting an incoming call with a text. Shown even without SIMs, since
  /// the list itself can be edited any time.
  Widget _quickRepliesCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const QuickRepliesScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.sms_outlined, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick replies',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Messages offered when rejecting a call with a text',
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
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

  Widget _noSimsNote(AppColors colors) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.sim_card_alert_outlined, color: colors.mutedText),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'No SIMs detected. Multi-SIM options need phone permission and a '
                'device with at least one SIM. Grant the phone permission and tap '
                'refresh.',
                style: TextStyle(color: colors.mutedText, fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultSimCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();
    final selected = settings.defaultSimId;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Default SIM',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Which SIM outgoing calls use unless you pick per call',
                    style: TextStyle(color: colors.mutedText, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _optionTile(
              colors: colors,
              accent: accent,
              selected: selected == null,
              title: 'System default',
              subtitle: 'Let Android choose',
              onTap: () => context.read<AppSettings>().setDefaultSimId(null),
            ),
            for (final sim in _accounts)
              _optionTile(
                colors: colors,
                accent: accent,
                selected: selected == sim.phoneAccountId,
                title: sim.displayLabel,
                subtitle: _simSubtitle(sim),
                onTap: () => context.read<AppSettings>().setDefaultSimId(
                  sim.phoneAccountId,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// A radio-style selectable row (built by hand to avoid the version-specific
  /// RadioListTile group API).
  Widget _optionTile({
    required AppColors colors,
    required Color accent,
    required bool selected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? accent : colors.mutedText,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _simSubtitle(SimAccount sim) {
    final slot = sim.slotIndex != null ? 'SIM ${sim.slotIndex! + 1}' : 'SIM';
    final carrier = sim.carrierName?.trim();
    if (carrier != null && carrier.isNotEmpty && carrier != sim.displayLabel) {
      return '$slot · $carrier';
    }
    return slot;
  }

  /// Per-SIM display colors: one row per SIM showing its current color (user
  /// pick or slot default); tapping opens the palette sheet. The color is used
  /// for the SIM name on the calling screen.
  Widget _simColorsCard(AppColors colors) {
    final settings = context.watch<AppSettings>();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SIM colours',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'The SIM name appears in this colour on the calling screen',
                    style: TextStyle(color: colors.mutedText, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            for (final sim in _accounts) _simColorTile(colors, settings, sim),
          ],
        ),
      ),
    );
  }

  Widget _simColorTile(AppColors colors, AppSettings settings, SimAccount sim) {
    final picked = settings.colorForSim(sim.phoneAccountId);
    final color = picked ?? AppTheme.defaultSimColor(sim.slotIndex);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _pickSimColor(sim, picked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.mutedText.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sim.displayLabel,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    picked == null
                        ? '${_simSubtitle(sim)} · Default colour'
                        : _simSubtitle(sim),
                    style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.mutedText, size: 20),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet with the preset palette for [sim]; "Use default" restores the
  /// slot colour. Persists via [AppSettings.setSimColor].
  Future<void> _pickSimColor(SimAccount sim, Color? picked) async {
    final colors = Theme.of(context).extension<AppColors>()!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Colour for ${sim.displayLabel}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final choice in AppTheme.simColorChoices)
                      _colorSwatch(
                        sheetContext,
                        sim,
                        choice,
                        selected:
                            picked != null &&
                            picked.toARGB32() == choice.toARGB32(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    context.read<AppSettings>().setSimColor(
                      sim.phoneAccountId,
                      null,
                    );
                    Navigator.of(sheetContext).pop();
                  },
                  icon: Icon(Icons.restart_alt, color: colors.mutedText),
                  label: Text(
                    'Use default',
                    style: TextStyle(color: colors.mutedText),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _colorSwatch(
    BuildContext sheetContext,
    SimAccount sim,
    Color choice, {
    required bool selected,
  }) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        context.read<AppSettings>().setSimColor(sim.phoneAccountId, choice);
        Navigator.of(sheetContext).pop();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: choice, shape: BoxShape.circle),
        child: selected
            ? Icon(Icons.check, color: AppTheme.contrastOn(choice))
            : null,
      ),
    );
  }

  /// Toggles the post-call "How did it go?" feedback sheet. Off by default;
  /// when on, the sheet is offered once a call has actually ended. Shown even
  /// without SIMs, since the feedback sheet doesn't depend on them.
  Widget _postCallFeedbackCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final enabled = context.watch<AppSettings>().postCallFeedbackEnabled;

    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        value: enabled,
        activeThumbColor: accent,
        onChanged: (v) =>
            context.read<AppSettings>().setPostCallFeedbackEnabled(v),
        title: const Text(
          'Ask after calls',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          'Show the “How did it go?” sheet when a call ends',
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
      ),
    );
  }

  /// Card for configuring Smart Redial & Reach Me mode settings.
  Widget _smartRedialCard(AppColors colors) {
    final settings = context.watch<AppSettings>();
    final enabled = settings.smartRedialEnabled;

    // Rebuilds whenever a task is scheduled/cancelled (including the native
    // auto-cancel-on-callback), so the "N active" badge below never goes
    // stale — SmartRedialService is a plain singleton ChangeNotifier, not
    // threaded through Provider, so context.watch wouldn't pick it up.
    return ListenableBuilder(
      listenable: SmartRedialService(),
      builder: (context, _) =>
          _smartRedialCardContent(colors, settings, enabled),
    );
  }

  Widget _smartRedialCardContent(
    AppColors colors,
    AppSettings settings,
    bool enabled,
  ) {
    final accent = Theme.of(context).colorScheme.primary;
    final activeCount = SmartRedialService().activeTasks.length;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              value: enabled,
              activeThumbColor: accent,
              onChanged: (v) =>
                  context.read<AppSettings>().setSmartRedialEnabled(v),
              title: const Text(
                'Smart Redial & "Reach Me"',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Offer 1-tap auto-retry and reach-me SMS when a call is unanswered',
                style: TextStyle(color: colors.mutedText, fontSize: 13),
              ),
            ),
            if (enabled) ...[
              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(Icons.timer_outlined, color: accent),
                title: const Text('Default retry delay'),
                trailing: Text(
                  '${settings.smartRedialDelayMinutes} min',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                onTap: () => _showDelayDialog(settings),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(Icons.message_outlined, color: accent),
                title: const Text('Preset Reach Me message'),
                subtitle: Text(
                  settings.presetReachMeMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedText, fontSize: 12.5),
                ),
                onTap: () => _showPresetMessageDialog(settings),
              ),
              if (activeCount > 0)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const Icon(Icons.alarm_on, color: Color(0xFF10B981)),
                  title: const Text('Active scheduled redials'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$activeCount active',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: _showActiveRedialsDialog,
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDelayDialog(AppSettings settings) {
    final options = [1, 3, 5, 10, 15, 30];
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Default Retry Delay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mins in options)
              ListTile(
                title: Text('$mins minutes'),
                trailing: settings.smartRedialDelayMinutes == mins
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  settings.setSmartRedialDelayMinutes(mins);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showPresetMessageDialog(AppSettings settings) {
    final controller = TextEditingController(text: settings.presetReachMeMessage);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Preset Reach Me Message'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your preset reach-me message...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              settings.setPresetReachMeMessage(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showActiveRedialsDialog() async {
    // Bring the Dart-side list up to date with native truth before painting
    // anything — otherwise a task that already fired or auto-cancelled while
    // this app was never backgrounded (the only other refresh trigger) would
    // still show as active here.
    await SmartRedialService().refresh();
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => const _ActiveRedialsDialogContent(),
    );
  }


  Widget _askSimCard(AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    final settings = context.watch<AppSettings>();
    final ask = settings.askSimBeforeCall;
    // Prompting only makes sense with 2+ SIMs.
    final canAsk = _accounts.length > 1;

    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        value: ask && canAsk,
        activeThumbColor: accent,
        onChanged: canAsk
            ? (v) => context.read<AppSettings>().setAskSimBeforeCall(v)
            : null,
        title: const Text(
          'Ask which SIM before each call',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          canAsk
              ? 'Show a SIM chooser each time you place a call'
              : 'Needs more than one SIM',
          style: TextStyle(color: colors.mutedText, fontSize: 13),
        ),
      ),
    );
  }
}

/// Content of the "Active Auto-Redials" dialog.
///
/// Rebuilds on every [SmartRedialService] change (schedule, cancel, native
/// reconciliation) and also on a periodic tick, so the "in X min" countdown
/// keeps moving and a task that expires or gets cancelled while this dialog
/// is open disappears from the list live, instead of the dialog needing to
/// be closed and reopened to reflect it.
class _ActiveRedialsDialogContent extends StatefulWidget {
  const _ActiveRedialsDialogContent();

  @override
  State<_ActiveRedialsDialogContent> createState() =>
      _ActiveRedialsDialogContentState();
}

class _ActiveRedialsDialogContentState
    extends State<_ActiveRedialsDialogContent> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = SmartRedialService();
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final tasks = service.activeTasks;
        return AlertDialog(
          title: const Text('Active Auto-Redials'),
          content: tasks.isEmpty
              ? const Text('No active scheduled redials.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final t = tasks[i];
                      return ListTile(
                        title: Text(t.displayName),
                        subtitle: Text('${t.phoneNumber} · in ${t.remainingDuration.inMinutes} min'),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => service.cancelTask(t.id),
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
