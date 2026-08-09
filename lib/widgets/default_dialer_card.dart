// lib/widgets/default_dialer_card.dart
import 'package:flutter/material.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';

/// Shows whether ContactSphere is Android's default phone app and lets the user
/// request the role. On non-Android hosts the status query resolves false and
/// tapping is a no-op, so the card simply prompts (harmlessly) to set default.
class DefaultDialerCard extends StatefulWidget {
  const DefaultDialerCard({super.key});

  @override
  State<DefaultDialerCard> createState() => _DefaultDialerCardState();
}

class _DefaultDialerCardState extends State<DefaultDialerCard> {
  final TelecomService _telecom = TelecomService();
  bool _isDefault = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final value = await _telecom.isDefaultDialer();
    if (mounted) setState(() => _isDefault = value);
  }

  Future<void> _request() async {
    if (_isDefault || _busy) return;
    setState(() => _busy = true);
    await _telecom.requestDefaultDialer();
    if (!mounted) return;
    setState(() => _busy = false);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final accent = theme.colorScheme.primary;
    const green = Color(0xFF10B981);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _isDefault ? null : _request,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (_isDefault ? green : accent).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _isDefault ? Icons.verified_outlined : Icons.dialpad,
                  color: _isDefault ? green : accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Default phone app',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isDefault
                          ? 'ContactSphere handles your calls'
                          : 'Set ContactSphere as your default dialer',
                      style: TextStyle(color: colors.mutedText, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_isDefault)
                const Icon(Icons.check_circle, color: green)
              else
                Icon(Icons.chevron_right, color: colors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
