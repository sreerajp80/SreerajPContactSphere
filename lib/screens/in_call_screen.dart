// lib/screens/in_call_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/call_state.dart';
import 'package:smart_contacts_dialer/models/caller_context.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/widgets/avatar_initial.dart';
import 'package:smart_contacts_dialer/widgets/screenshot_guard_mixin.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/flagged_number_repository.dart';
import 'package:smart_contacts_dialer/repositories/group_repository.dart';
import 'package:smart_contacts_dialer/repositories/relationship_repository.dart';
import 'package:smart_contacts_dialer/services/caller_context_service.dart';
import 'package:smart_contacts_dialer/services/caller_id_service.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/theme/caller_backdrop.dart';
import 'package:smart_contacts_dialer/screens/dialer_screen.dart';
import 'package:smart_contacts_dialer/screens/home_shell.dart';

/// Full-screen in-call UI shown while ContactSphere is the default phone app.
///
/// Driven by [TelecomService.callEvents]: it renders the live call state and
/// wires the answer / reject / mute / speaker / hold / end controls to Telecom.
/// Caller identity is resolved from [ContactRepository] by number. The route is
/// pushed/popped by `main.dart`; this screen owns only what it displays.
class InCallScreen extends StatefulWidget {
  final CallState initialState;

  const InCallScreen({super.key, required this.initialState});

  @override
  State<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends State<InCallScreen>
    with ScreenshotGuard<InCallScreen> {
  final TelecomService _telecom = TelecomService();
  final ContactRepository _contacts = ContactRepository();
  final SimService _sim = SimService();
  final FlaggedNumberRepository _flagged = FlaggedNumberRepository();
  final CallerContextService _callerContextService = CallerContextService();
  final RelationshipRepository _relationships = RelationshipRepository();

  late CallState _state;
  StreamSubscription<CallState>? _sub;
  Timer? _ticker;
  String? _resolvedName;
  CallerContext? _callerContext;

  /// Given name of the resolved contact (no salutation) — avatar initial only.
  String? _resolvedFirstName;
  String? _resolvedFor; // number we resolved a name for, to avoid re-querying

  /// Resolved contact name for the background/waiting call ([_state.heldNumber]),
  /// shown on the call-waiting card. [_resolvedHeldFor] guards against re-querying
  /// the same number on every event.
  String? _resolvedHeldName;
  String? _resolvedHeldFor;

  // SIM label + display color for the call's phoneAccountId, shown so the user
  // can tell which SIM an incoming/outgoing call is on. [_resolvedSimFor] is the
  // account id we last resolved, to avoid re-querying on every rebuild (mirrors
  // [_resolvedFor]). The color is the user's pick from SIM & calling settings,
  // else the slot default, so each SIM reads in its own color.
  String? _resolvedSimLabel;
  Color _resolvedSimColor = AppTheme.defaultSimColor(null);
  String? _resolvedSimFor;

  /// Full-bleed background image for the call: the contact's calling card if set,
  /// else their profile photo, else null (then [_resolvedMoodGradient], then the
  /// brand gradient).
  String? _resolvedImagePath;

  /// Backdrop mood for a caller with no photo of either kind, derived from their
  /// relationship to the phone owner (see `theme/caller_backdrop.dart`). The
  /// gradient itself is built in [build] so it follows the theme and the clock;
  /// [BackdropMood.unknown] and null both mean "use the brand gradient".
  BackdropMood? _resolvedMood;

  /// Local identification for a caller who isn't a saved contact ("Suspected
  /// spam", "Telemarketing", …), when the Caller identification setting is on.
  CallerIdInfo? _callerId;

  /// Whether the call's number is on the user's blocked list. Drives the Block
  /// control's label (Block ↔ Blocked) and which action its dialog offers.
  bool _isBlocked = false;

  // Incoming-ringtone resolution state, reset per physical call (by [callId]).
  // Precedence is contact tone > per-SIM tone > native default; the flags stop a
  // later-resolving SIM tone from clobbering a contact tone that already won.
  int _ringtoneCallId = 0;
  bool _contactToneApplied = false;
  bool _simToneApplied = false;

  // In-call DTMF keypad overlay: whether it's shown and the digits entered on it
  // this session (for the small readout above the pad — display only).
  bool _showKeypad = false;
  String _dtmfEntry = '';

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
    _resolveRingtone(_state);
    _resolveName(_state.number);
    _resolveHeldName(_state.heldNumber);
    _resolveSim(_state.phoneAccountId);
    _sub = _telecom.callEvents.listen((s) {
      if (!mounted) return;
      setState(() {
        _state = s;
        // DTMF only reaches a connected call; drop the pad if it's no longer active.
        if (s.phase != CallPhase.active) _showKeypad = false;
      });
      _resolveRingtone(s);
      _resolveName(s.number);
      _resolveHeldName(s.heldNumber);
      _resolveSim(s.phoneAccountId);
    });
    // Refresh the duration label once a second while connected.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _state.connectTimeMillis > 0) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  /// Applies the per-SIM ringtone for a ringing call (once per physical call),
  /// unless a contact-specific tone has already been applied. The native ringer
  /// starts the default tone immediately; this swaps in the SIM's tone for calls
  /// where the caller has no ringtone of their own. Best-effort.
  void _resolveRingtone(CallState s) {
    if (s.callId != _ringtoneCallId) {
      _ringtoneCallId = s.callId;
      _contactToneApplied = false;
      _simToneApplied = false;
    }
    if (s.phase != CallPhase.ringing || _simToneApplied) return;
    _simToneApplied = true;
    unawaited(_applySimRingtone(s));
  }

  Future<void> _applySimRingtone(CallState s) async {
    final tone = await AppSettings.readSimRingtone(s.phoneAccountId);
    if (tone == null || tone.path.isEmpty) return;
    // Don't override a contact's own tone, and only while still ringing.
    if (!mounted || _contactToneApplied || _state.phase != CallPhase.ringing) {
      return;
    }
    unawaited(_telecom.setIncomingRingtone(tone.path, source: 'sim'));
  }

  Future<void> _resolveName(String? number) async {
    if (number == null || number.isEmpty || number == _resolvedFor) return;
    _resolvedFor = number;
    try {
      final iso = await AppSettings.readDefaultCountryIso();
      // Refresh the Block control for this number (best-effort; stays false
      // on failure). Guarded against a number change while the query ran.
      unawaited(
        _flagged
            .isFlagged(
              number,
              kind: FlaggedNumberRepository.kindBlocked,
              defaultIso: iso,
            )
            .then((blocked) {
              if (mounted && _resolvedFor == number) {
                setState(() => _isBlocked = blocked);
              }
            })
            .catchError((_) {}),
      );
      final matches = await _contacts.findByFullNumber(number, defaultIso: iso);
      if (!mounted) return;
      final match = matches.isNotEmpty ? matches.first : null;
      final name = (match != null && match.contactName.isNotEmpty)
          ? match.contactName
          : null;
      final firstName = (match != null && match.firstName.isNotEmpty)
          ? match.firstName
          : null;
      setState(() {
        _resolvedName = name;
        _resolvedFirstName = firstName;
      });
      // Push the name to native so the call notification (ringing or ongoing,
      // incoming or outgoing) shows it instead of the raw number (native can't
      // resolve it). An empty push clears a stale name when the number changes
      // (add call / swap) and the new number has no match. Native no-ops once
      // the call has ended.
      unawaited(_telecom.setCallerName(name ?? ''));
      // A saved contact needs no identification badge; otherwise see what the
      // local caller-ID rules can say about the number.
      if (match == null) {
        unawaited(_resolveCallerId(number));
      } else if (_callerId != null) {
        setState(() => _callerId = null);
        unawaited(_telecom.setCallerLabel(''));
      }
      // Load the full contact for its backdrop image: calling card first, then
      // profile photo. Best-effort.
      if (match != null) {
        final contact = await _contacts.getContactById(match.contactId);
        if (!mounted) return;
        final image = contact?.cardPhotoPath ?? contact?.photoPath;
        final resolvedImage = (image != null && File(image).existsSync())
            ? image
            : null;
        setState(() {
          _resolvedImagePath = resolvedImage;
          _resolvedMood = null;
        });
        // No photo of either kind: fall back to a gradient keyed on how this
        // caller relates to the phone owner, so the screen still says something
        // about who is calling. Only runs in the photo-less case.
        if (resolvedImage == null) {
          unawaited(_resolveMoodBackdrop(match.contactId, number));
        }
        // If this caller has a custom ringtone — their own, else their group's
        // (same fallback as the mirror, see ContactRepository.
        // ringtoneMirrorEntries) — and the call is still ringing, swap the
        // native default tone for it. Best-effort; the native side ignores it
        // when the ringer isn't sounding.
        var ringtone = contact?.ringtonePath;
        if ((ringtone == null || ringtone.isEmpty) && contact?.id != null) {
          ringtone = await GroupRepository().groupRingtoneForContact(
            contact!.id!,
          );
          if (!mounted) return;
        }
        if (ringtone != null &&
            ringtone.isNotEmpty &&
            _state.phase == CallPhase.ringing) {
          // Contact/group tone wins over any per-SIM tone (see
          // [_applySimRingtone]); both push at the 'contact' tier.
          _contactToneApplied = true;
          unawaited(_telecom.setIncomingRingtone(ringtone, source: 'contact'));
        }
        // Resolve Smart Caller Context ("Why is this person calling?")
        unawaited(
          _callerContextService
              .getCallerContextByContactId(
                match.contactId,
                contactName: name,
              )
              .then((ctx) {
                if (mounted && _resolvedFor == number) {
                  setState(() => _callerContext = ctx);
                }
              })
              .catchError((_) {}),
        );
      } else {
        setState(() {
          _resolvedImagePath = null;
          _resolvedMood = null;
          _callerContext = null;
        });
      }
    } catch (_) {
      // Best-effort; fall back to showing the raw number / gradient.
    }
  }

  /// Picks the relationship-based backdrop mood for [contactId] — the last step
  /// before the brand gradient, used only when the contact has neither a calling
  /// card photo nor a profile photo.
  ///
  /// The label is the one the phone owner recorded for this contact, so "family"
  /// means family *of the owner*. Contacts with no relationship on record (the
  /// common case) resolve to [BackdropMood.unknown] and keep the brand gradient.
  /// Best-effort: any failure leaves the mood unset. [number] guards against the
  /// call's number changing (add call / swap) while the query ran.
  Future<void> _resolveMoodBackdrop(int contactId, String number) async {
    try {
      final type = await _relationships.relationshipToSelf(contactId);
      if (!mounted || _resolvedFor != number) return;
      final mood = moodForRelationship(type);
      if (mood == BackdropMood.unknown) return; // brand gradient, as before
      setState(() => _resolvedMood = mood);
    } catch (_) {
      // Best-effort; the brand gradient stays.
    }
  }

  /// Resolves the background/waiting call's number to a contact name for the
  /// call-waiting card. Lightweight (name only, no identity/tone side-effects)
  /// and cached by number. Clears when there's no held call. Best-effort.
  Future<void> _resolveHeldName(String? number) async {
    if (number == null || number.isEmpty) {
      if (_resolvedHeldName != null || _resolvedHeldFor != null) {
        setState(() {
          _resolvedHeldName = null;
          _resolvedHeldFor = null;
        });
      }
      return;
    }
    if (number == _resolvedHeldFor) return;
    _resolvedHeldFor = number;
    try {
      final iso = await AppSettings.readDefaultCountryIso();
      final matches = await _contacts.findByFullNumber(number, defaultIso: iso);
      if (!mounted || _resolvedHeldFor != number) return;
      final match = matches.isNotEmpty ? matches.first : null;
      setState(() {
        _resolvedHeldName = (match != null && match.contactName.isNotEmpty)
            ? match.contactName
            : null;
      });
    } catch (_) {
      // Best-effort; the card falls back to the number.
    }
  }

  /// Identifies a non-contact caller from local sources (spam marks, the TRAI
  /// number series) when the Caller identification setting is on, then pushes
  /// the label to the native call notification. Best-effort; guarded against a
  /// number change while the lookup ran.
  Future<void> _resolveCallerId(String number) async {
    try {
      if (!await AppSettings.readCallerIdEnabled()) return;
      final info = await CallerIdService().identify(number);
      if (!mounted || _resolvedFor != number) return;
      setState(() => _callerId = info);
      unawaited(_telecom.setCallerLabel(info?.label ?? ''));
    } catch (_) {
      // Best-effort; the call shows the bare number.
    }
  }

  /// Resolves the human SIM label and display color for the call's
  /// [phoneAccountId] so the identity block can show which SIM the call is on.
  /// The color is the user's pick (SIM & calling settings), else the slot
  /// default. Cached by account id to avoid re-querying on every event;
  /// best-effort (leaves the chip hidden on failure).
  Future<void> _resolveSim(String? phoneAccountId) async {
    if (phoneAccountId == null ||
        phoneAccountId.isEmpty ||
        phoneAccountId == _resolvedSimFor) {
      return;
    }
    _resolvedSimFor = phoneAccountId;
    try {
      final account = await _sim.accountFor(phoneAccountId);
      final picked = await AppSettings.readSimColor(phoneAccountId);
      if (!mounted) return;
      setState(() {
        _resolvedSimLabel = account?.displayLabel;
        _resolvedSimColor =
            picked ?? AppTheme.defaultSimColor(account?.slotIndex);
      });
    } catch (_) {
      // Best-effort; leave the SIM chip hidden.
    }
  }

  String get _title {
    if (_resolvedName != null) return _resolvedName!;
    final n = _state.number;
    return (n == null || n.isEmpty) ? 'Unknown' : n;
  }

  String get _statusLabel {
    switch (_state.phase) {
      case CallPhase.ringing:
        return 'Incoming call';
      case CallPhase.dialing:
      case CallPhase.connecting:
        return 'Calling…';
      case CallPhase.holding:
        return 'On hold';
      case CallPhase.disconnecting:
      case CallPhase.disconnected:
        return 'Call ended';
      case CallPhase.active:
        return _durationLabel();
      default:
        return '';
    }
  }

  String _durationLabel() {
    if (_state.connectTimeMillis <= 0) return 'Connected';
    final secs =
        ((DateTime.now().millisecondsSinceEpoch - _state.connectTimeMillis) ~/
                1000)
            .clamp(0, 359999);
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final imagePath = _resolvedImagePath;
    final hasImage = imagePath != null;
    // No photo: a relationship-keyed gradient if we resolved one, else the brand
    // gradient. Built here (not when resolved) so it follows the theme and the
    // time of day.
    final mood = _resolvedMood;
    final gradient =
        (mood == null
            ? null
            : gradientFor(mood, now: DateTime.now(), isDark: colors.isDark)) ??
        colors.brandGradient;
    // Over a full-bleed photo we sit on a dark scrim, so white reads best;
    // otherwise contrast against whichever gradient we're painting.
    final fg = hasImage
        ? Colors.white
        : AppTheme.contrastOn(gradient.colors.first);

    return PopScope(
      canPop: false, // the call, not the back button, ends the screen
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop: full-bleed caller image (calling card or profile photo)
            // with a scrim for legibility, else the relationship/brand gradient.
            if (hasImage) ...[
              Image.file(File(imagePath), fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ] else
              DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
            // Hidden (but kept alive) while the DTMF keypad overlay is open so
            // its labels don't bleed through the keypad digits.
            Visibility(
              visible: !_showKeypad,
              maintainState: true,
              child: SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _identity(fg, showAvatar: !hasImage),
                    if (_state.heldNumber != null) ...[
                      const SizedBox(height: 16),
                      // A second call that is *ringing* (call waiting) gets a card
                      // with Answer/Decline; a genuinely held call gets the banner.
                      if (_state.heldPhase == CallPhase.ringing)
                        _callWaitingCard(fg)
                      else
                        _heldBanner(fg),
                    ],
                    const Spacer(flex: 3),
                    _controls(fg),
                    const SizedBox(height: 16),
                    _secondaryActions(fg),
                    const SizedBox(height: 20),
                    _primaryActions(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            // In-call DTMF keypad, over everything when open.
            if (_showKeypad) _dtmfPad(fg),
          ],
        ),
      ),
    );
  }

  /// A card for a second, *ringing* call (call waiting) while another call is
  /// active: shows who's calling and Answer / Decline buttons. Answering holds
  /// the current call (Telecom's auto-hold); declining leaves it untouched.
  Widget _callWaitingCard(Color fg) {
    final held = _state.heldNumber ?? '';
    final title = (_resolvedHeldName != null && _resolvedHeldName!.isNotEmpty)
        ? _resolvedHeldName!
        : (held.isEmpty ? 'Unknown' : held);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_callback, size: 22, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Incoming call',
                  style: TextStyle(
                    color: fg.withValues(alpha: 0.8),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _waitingButton(
            icon: Icons.call_end,
            color: const Color(0xFFEF4444),
            onTap: _telecom.rejectWaiting,
          ),
          const SizedBox(width: 10),
          _waitingButton(
            icon: Icons.call,
            color: const Color(0xFF10B981),
            onTap: _telecom.answerWaiting,
          ),
        ],
      ),
    );
  }

  /// A small round action button for the call-waiting card.
  Widget _waitingButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  /// A compact chip for the backgrounded (held) call, e.g. "9876543210 — on hold".
  Widget _heldBanner(Color fg) {
    final held = _state.heldNumber ?? '';
    final label = held.isEmpty ? 'Second call' : held;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pause_circle_outline, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(
            '$label — on hold',
            style: TextStyle(
              color: fg,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _identity(Color fg, {bool showAvatar = true}) {
    final initial = _resolvedFirstName?.isNotEmpty == true
        ? initialFor(_resolvedFirstName!)
        : '#';
    return Column(
      children: [
        if (showAvatar) ...[
          CircleAvatar(
            radius: 52,
            backgroundColor: fg.withValues(alpha: 0.18),
            child: AvatarInitial(
              initial,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          _title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: fg,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _statusLabel,
          style: TextStyle(fontSize: 15, color: fg.withValues(alpha: 0.85)),
        ),
        if (_callerId != null) ...[
          const SizedBox(height: 12),
          _callerIdChip(_callerId!),
        ] else if (_state.verificationStatus == 'failed') ...[
          // The screening/spam signals outrank the softer network hint.
          const SizedBox(height: 12),
          _verificationChip(),
        ],
        if (_resolvedSimLabel != null) ...[
          const SizedBox(height: 12),
          _simChip(_resolvedSimLabel!),
        ],
        if (_callerContext != null && _callerContext!.hasContext) ...[
          const SizedBox(height: 12),
          _callerContextCard(fg, _callerContext!),
        ],
      ],
    );
  }

  /// Glassmorphic Smart Context Card answering "Why is this person calling?"
  /// on incoming calls, or giving background on the contact for outgoing ones
  /// (you placed the call, so "why they are calling" doesn't apply).
  Widget _callerContextCard(Color fg, CallerContext ctx) {
    final headline = ctx.buildSmartHeadline();
    final headerText = _state.direction == CallDirection.outgoing
        ? 'ABOUT THIS CONTACT'
        : 'WHY THEY ARE CALLING';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 14,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              Text(
                headerText,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.75),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: fg,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              if (ctx.relationshipLabel != null &&
                  ctx.relationshipLabel!.isNotEmpty)
                _contextBadge(
                  icon: Icons.people_outline,
                  label: ctx.relationshipLabel!,
                  color: const Color(0xFF60A5FA),
                  fg: fg,
                ),
              if (ctx.lastSpokeLabel != null && ctx.lastSpokeLabel!.isNotEmpty)
                _contextBadge(
                  icon: Icons.history,
                  label: ctx.lastSpokeLabel!,
                  color: const Color(0xFF34D399),
                  fg: fg,
                ),
              for (final rem in ctx.pendingReminders)
                _contextBadge(
                  icon: Icons.notification_important_outlined,
                  label: rem,
                  color: const Color(0xFFF87171),
                  fg: fg,
                ),
              if (ctx.upcomingEventLabel != null &&
                  ctx.upcomingEventLabel!.isNotEmpty)
                _contextBadge(
                  icon: Icons.cake_outlined,
                  label: ctx.upcomingEventLabel!,
                  color: const Color(0xFFFBBF24),
                  fg: fg,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contextBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Identification badge for a non-contact caller: red for suspected spam,
  /// amber for informational labels (telemarketing / service series). Same
  /// solid dark scrim as [_simChip] so it reads over photo backdrops.
  Widget _callerIdChip(CallerIdInfo info) {
    final color = info.isSpam
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            info.isSpam ? Icons.report_outlined : Icons.campaign_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            info.label,
            style: TextStyle(
              color: color,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Shown when the network reports the caller's number failed STIR/SHAKEN
  /// verification — the caller ID may be spoofed.
  Widget _verificationChip() {
    const amber = Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: amber.withValues(alpha: 0.55)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gpp_maybe_outlined, size: 16, color: amber),
          SizedBox(width: 6),
          Text(
            'Caller ID not verified',
            style: TextStyle(
              color: amber,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Small pill naming the SIM the call is on, in the SIM's display color.
  /// Sits on a solid dark scrim (not the translucent foreground the other
  /// chips use) so it stays legible over light photo backdrops too.
  Widget _simChip(String label) {
    final simColor = _resolvedSimColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: simColor.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sim_card_outlined, size: 16, color: simColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: simColor,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Whether the call carries a usable caller number (hidden/private callers
  /// don't) — gates the Block and Reply controls.
  bool get _hasNumber => _state.number != null && _state.number!.isNotEmpty;

  /// Primary in-call toggles. While a call is *ringing* the row is Reply /
  /// Speaker / Block: Reply declines with an SMS (quick replies), Speaker arms
  /// "answer on speaker" before picking up (the app-owned ringtone plays on the
  /// ring stream, so this doesn't reroute the ringtone — it takes effect once
  /// the call connects), Block adds the caller to the blocked list and declines.
  /// Mute/Hold need a connected call, so the full Mute/Speaker/Hold row appears
  /// only when active/holding.
  Widget _controls(Color fg) {
    if (_state.phase == CallPhase.ringing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_hasNumber)
            _toggle(
              icon: Icons.sms_outlined,
              label: 'Reply',
              active: false,
              fg: fg,
              onTap: _showReplySheet,
            ),
          _speakerToggle(fg),
          if (_hasNumber) _blockToggle(fg),
        ],
      );
    }
    final connected =
        _state.phase == CallPhase.active || _state.phase == CallPhase.holding;
    if (!connected) return const SizedBox(height: 72);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _toggle(
          icon: _state.muted ? Icons.mic_off : Icons.mic,
          label: 'Mute',
          active: _state.muted,
          fg: fg,
          onTap: () => _telecom.setMuted(!_state.muted),
        ),
        _speakerToggle(fg),
        _toggle(
          icon: Icons.pause,
          label: 'Hold',
          active: _state.phase == CallPhase.holding,
          fg: fg,
          onTap: !_state.canHold
              ? null
              : () => _state.phase == CallPhase.holding
                    ? _telecom.unhold()
                    : _telecom.hold(),
        ),
      ],
    );
  }

  Widget _speakerToggle(Color fg) => _toggle(
    icon: _state.speaker ? Icons.volume_up : Icons.volume_down,
    label: 'Speaker',
    active: _state.speaker,
    fg: fg,
    onTap: () => _telecom.setSpeaker(!_state.speaker),
  );

  /// Second row of controls for a connected call: keypad (DTMF), plus add-call /
  /// merge / swap when the call/carrier supports them. Hidden until connected.
  Widget _secondaryActions(Color fg) {
    final connected =
        _state.phase == CallPhase.active || _state.phase == CallPhase.holding;
    if (!connected) return const SizedBox(height: 72);

    final items = <Widget>[
      _toggle(
        icon: Icons.dialpad,
        label: 'Keypad',
        active: _showKeypad,
        fg: fg,
        // DTMF only reaches the far end on a connected (not held) call.
        onTap: !_state.canDtmf
            ? null
            : () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DialerScreen(dtmfMode: true),
                  ),
                );
              },
      ),
    ];
    if (_state.canAddCall) {
      items.add(
        _toggle(
          icon: Icons.add_call,
          label: 'Add call',
          active: false,
          fg: fg,
          onTap: _openAddCall,
        ),
      );
    }
    if (_state.canMerge) {
      items.add(
        _toggle(
          icon: Icons.merge_type,
          label: 'Merge',
          active: false,
          fg: fg,
          onTap: _telecom.mergeCalls,
        ),
      );
    }
    if (_state.canSwap) {
      items.add(
        _toggle(
          icon: Icons.swap_calls,
          label: 'Swap',
          active: false,
          fg: fg,
          onTap: _telecom.swapCalls,
        ),
      );
    }
    if (_hasNumber) items.add(_blockToggle(fg));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: items);
  }

  /// The Block control (ringing row + connected secondary row). Reads
  /// "Blocked" once the number is on the list; tapping opens the block /
  /// unblock dialog.
  Widget _blockToggle(Color fg) => _toggle(
    icon: Icons.block,
    label: _isBlocked ? 'Blocked' : 'Block',
    active: _isBlocked,
    fg: fg,
    onTap: _confirmBlock,
  );

  /// Confirmation dialog for the Block control. Blocking adds the number to
  /// the blocked list (Settings → Contacts → Blocked numbers) — future calls
  /// are rejected before ringing — and declines the call if it's still
  /// ringing. When the number is already blocked, offers Unblock instead.
  Future<void> _confirmBlock() async {
    final number = _state.number;
    if (number == null || number.isEmpty) return;
    final unblocking = _isBlocked;
    final hasRunningCall = _state.hasCall;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(unblocking ? 'Unblock this number?' : 'Block this number?'),
        content: Text(
          unblocking
              ? 'Calls from $number will ring normally again.'
              : 'Future calls from $number will be rejected before your phone '
                    'rings.${hasRunningCall ? ' This call will be disconnected immediately.' : ''}\n\n'
                    'You can manage blocked numbers in Settings → Contacts → '
                    'Blocked numbers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(unblocking ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (unblocking) {
      await _flagged.removeNumber(
        number,
        kind: FlaggedNumberRepository.kindBlocked,
      );
      if (mounted) setState(() => _isBlocked = false);
    } else {
      await _flagged.add(number, kind: FlaggedNumberRepository.kindBlocked);
      if (mounted) setState(() => _isBlocked = true);
      // Disconnect the running call from the newly blocked caller immediately;
      // the screening service takes over from the next call on.
      if (_state.hasCall) unawaited(_telecom.disconnect());
    }
  }

  /// Bottom sheet for rejecting the ringing call with a text: the quick
  /// replies from Settings → SIM & calling → Quick replies, plus a
  /// "Write your own…" free-text option. Picking a message declines the call
  /// and Telecom sends the SMS to the caller (on the SIM the call arrived on).
  Future<void> _showReplySheet() async {
    final replies = await AppSettings.readQuickReplies();
    if (!mounted || _state.phase != CallPhase.ringing) return;
    final colors = Theme.of(context).extension<AppColors>()!;
    final message = await showModalBottomSheet<String>(
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
                const Text(
                  'Reply with a message',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Declines the call and texts the caller',
                  style: TextStyle(color: colors.mutedText, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final reply in replies)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.sms_outlined),
                          title: Text(reply),
                          onTap: () => Navigator.of(sheetContext).pop(reply),
                        ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.edit_outlined),
                        title: const Text('Write your own…'),
                        onTap: () async {
                          final custom = await _promptCustomReply(sheetContext);
                          if (custom != null &&
                              custom.trim().isNotEmpty &&
                              sheetContext.mounted) {
                            Navigator.of(sheetContext).pop(custom.trim());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (message == null || message.trim().isEmpty || !mounted) return;
    // The call may have been answered elsewhere / ended while the sheet was up.
    if (_state.phase != CallPhase.ringing) return;
    await _telecom.rejectWithMessage(message.trim());
  }

  /// Free-text dialog for a one-off reply (when no quick reply fits). Returns
  /// the typed message, or null when cancelled.
  Future<String?> _promptCustomReply(BuildContext hostContext) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: hostContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Reply with…'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 160,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'Type a message to send',
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  /// Opens the app tabs (starting on Contacts tab) over the call to place a second party.
  /// Once a call is placed, it pops back to reveal this screen with the new held/active legs.
  Future<void> _openAddCall() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HomeShell(addCallMode: true),
      ),
    );
  }

  /// Full-screen DTMF keypad shown over the call. Each key sends a tone while
  /// pressed (stops on release) and appends to the on-screen readout.
  Widget _dtmfPad(Color fg) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.92),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Center(
                        child: Text(
                          _dtmfEntry,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: _dtmfEntry.isEmpty
                          ? null
                          : GestureDetector(
                              onLongPress: () => setState(() => _dtmfEntry = ''),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.backspace_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (_dtmfEntry.isNotEmpty) {
                                    setState(() {
                                      _dtmfEntry = _dtmfEntry.substring(
                                        0,
                                        _dtmfEntry.length - 1,
                                      );
                                    });
                                  }
                                },
                                tooltip: 'Delete',
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final row in rows)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [for (final d in row) _dtmfKey(d)],
                ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => setState(() => _showKeypad = false),
                child: const Text(
                  'Hide',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dtmfKey(String digit) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTapDown: (_) {
          _telecom.playDtmf(digit);
          setState(() => _dtmfEntry += digit);
        },
        onTapUp: (_) => _telecom.stopDtmf(),
        onTapCancel: _telecom.stopDtmf,
        child: Container(
          width: 68,
          height: 68,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
          child: Text(
            digit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle({
    required IconData icon,
    required String label,
    required bool active,
    required Color fg,
    VoidCallback? onTap,
  }) {
    final disabled = onTap == null;
    final tint = disabled ? fg.withValues(alpha: 0.35) : fg;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Material(
            color: active
                ? fg.withValues(alpha: 0.9)
                : fg.withValues(alpha: 0.14),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: 60,
                height: 60,
                child: Icon(
                  icon,
                  color: active ? Theme.of(context).colorScheme.primary : tint,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: tint, fontSize: 12.5)),
        ],
      ),
    );
  }

  /// Answer/reject for an incoming call, or a single end button otherwise.
  Widget _primaryActions() {
    if (_state.phase == CallPhase.ringing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bigButton(
            icon: Icons.call_end,
            color: const Color(0xFFEF4444),
            onTap: _telecom.disconnect,
          ),
          _bigButton(
            icon: Icons.call,
            color: const Color(0xFF10B981),
            onTap: _telecom.answer,
          ),
        ],
      );
    }
    return _bigButton(
      icon: Icons.call_end,
      color: const Color(0xFFEF4444),
      onTap: _telecom.disconnect,
    );
  }

  Widget _bigButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
