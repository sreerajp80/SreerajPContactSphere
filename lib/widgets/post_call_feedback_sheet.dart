// lib/widgets/post_call_feedback_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// The result of the post-call feedback form. Null fields are simply not
/// written by the caller.
class PostCallFeedback {
  /// 'positive' | 'neutral' | 'negative' — the strings the relationship scorer
  /// understands. Null when the user didn't pick a sentiment.
  final String? tone;
  final String? intent;
  final String? notes;

  /// Optional follow-up reminder text + time (only when a contact is linked).
  final String? followUpText;
  final DateTime? followUpTime;

  const PostCallFeedback({
    this.tone,
    this.intent,
    this.notes,
    this.followUpText,
    this.followUpTime,
  });

  bool get hasFeedback =>
      tone != null ||
      (intent != null && intent!.isNotEmpty) ||
      (notes != null && notes!.isNotEmpty);

  bool get hasFollowUp => followUpText != null && followUpText!.isNotEmpty;
}

/// Shows the "How did it go?" sheet after a call. Returns the captured
/// [PostCallFeedback], or null if the user skipped/dismissed it.
///
/// [canRemind] gates the follow-up-reminder section (only meaningful when the
/// call is linked to a contact).
Future<PostCallFeedback?> showPostCallFeedbackSheet(
  BuildContext context, {
  required String displayName,
  required bool canRemind,
}) {
  return showModalBottomSheet<PostCallFeedback>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _PostCallFeedbackSheet(displayName: displayName, canRemind: canRemind),
  );
}

/// Sentiment options, colored from the shared mood palette so they read as the
/// same visual language as relationship health elsewhere in the app.
class _Sentiment {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _Sentiment(this.value, this.label, this.icon, this.color);
}

const _sentiments = <_Sentiment>[
  _Sentiment(
    'positive',
    'Great',
    Icons.sentiment_very_satisfied,
    Color(0xFF10B981),
  ),
  _Sentiment('neutral', 'Okay', Icons.sentiment_neutral, Color(0xFFF59E0B)),
  _Sentiment(
    'negative',
    'Rough',
    Icons.sentiment_dissatisfied,
    Color(0xFFEF4444),
  ),
];

const _intentPresets = <String>[
  'Catch-up',
  'Work',
  'Scheduling',
  'Follow-up',
  'Family',
  'Urgent',
];

class _PostCallFeedbackSheet extends StatefulWidget {
  final String displayName;
  final bool canRemind;

  const _PostCallFeedbackSheet({
    required this.displayName,
    required this.canRemind,
  });

  @override
  State<_PostCallFeedbackSheet> createState() => _PostCallFeedbackSheetState();
}

class _PostCallFeedbackSheetState extends State<_PostCallFeedbackSheet> {
  String? _tone;
  String? _intent;
  final _notesController = TextEditingController();
  final _followUpController = TextEditingController();
  bool _addFollowUp = false;
  DateTime? _followUpTime;

  @override
  void dispose() {
    _notesController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  void _save() {
    final notes = _notesController.text.trim();
    final followUp = _followUpController.text.trim();
    Navigator.of(context).pop(
      PostCallFeedback(
        tone: _tone,
        intent: _intent,
        notes: notes.isEmpty ? null : notes,
        followUpText: (_addFollowUp && followUp.isNotEmpty) ? followUp : null,
        followUpTime: (_addFollowUp && followUp.isNotEmpty)
            ? _followUpTime
            : null,
      ),
    );
  }

  Future<void> _pickFollowUpTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _followUpTime ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _followUpTime ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (!mounted) return;
    setState(() {
      _followUpTime = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 9,
        time?.minute ?? 0,
      );
    });
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                const Text(
                  'How did it go?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Call with ${widget.displayName}',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: colors.mutedText,
                  ),
                ),
                const SizedBox(height: 18),
                _sentimentRow(colors),
                const SizedBox(height: 20),
                _label('What was it about?', colors),
                const SizedBox(height: 10),
                _intentChips(accent, colors),
                const SizedBox(height: 20),
                _label('Notes', colors),
                const SizedBox(height: 10),
                _notesField(accent, colors),
                if (widget.canRemind) ...[
                  const SizedBox(height: 8),
                  _followUpSection(accent, colors),
                ],
                const SizedBox(height: 22),
                _actions(accent, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, AppColors colors) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: colors.mutedText,
    ),
  );

  Widget _sentimentRow(AppColors colors) {
    return Row(
      children: [
        for (final s in _sentiments) ...[
          Expanded(child: _sentimentTile(s, colors)),
          if (s != _sentiments.last) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _sentimentTile(_Sentiment s, AppColors colors) {
    final selected = _tone == s.value;
    return Material(
      color: selected ? s.color.withValues(alpha: 0.16) : colors.searchFill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _tone = selected ? null : s.value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? s.color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                s.icon,
                color: selected ? s.color : colors.mutedText,
                size: 30,
              ),
              const SizedBox(height: 6),
              Text(
                s.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? s.color : colors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _intentChips(Color accent, AppColors colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final preset in _intentPresets)
          _chip(
            label: preset,
            selected: _intent == preset,
            accent: accent,
            colors: colors,
            onTap: () =>
                setState(() => _intent = _intent == preset ? null : preset),
          ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required Color accent,
    required AppColors colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? accent : accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppTheme.contrastOn(accent) : accent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _notesField(Color accent, AppColors colors) {
    return TextField(
      controller: _notesController,
      minLines: 2,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Anything worth remembering?',
        filled: true,
        fillColor: colors.searchFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),
    );
  }

  Widget _followUpSection(Color accent, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: Theme.of(context).copyWith(splashColor: Colors.transparent),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: accent,
            value: _addFollowUp,
            onChanged: (v) => setState(() => _addFollowUp = v),
            title: const Text(
              'Add a follow-up reminder',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Saved for reference — notifications coming soon',
              style: TextStyle(
                fontSize: 11.5,
                color: colors.mutedText,
              ),
            ),
          ),
        ),
        if (_addFollowUp) ...[
          const SizedBox(height: 4),
          TextField(
            controller: _followUpController,
            decoration: InputDecoration(
              hintText: 'e.g. Send the contract',
              filled: true,
              fillColor: colors.searchFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accent, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _pickFollowUpTime,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 18, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    _followUpTime == null
                        ? 'Pick date & time (optional)'
                        : DateFormat(
                            'EEE, MMM d · h:mm a',
                          ).format(_followUpTime!),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _followUpTime == null ? colors.mutedText : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _actions(Color accent, AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: colors.mutedText,
            ),
            child: const Text(
              'Skip',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: colors.brandGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.gradientStart.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.contrastOn(accent),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
