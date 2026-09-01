// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/core/config/app_flavor_config.dart';
import 'package:smart_contacts_dialer/core/errors/error_handlers.dart';
import 'package:smart_contacts_dialer/core/logging/app_logger.dart';
import 'package:smart_contacts_dialer/core/utils/call_log_write_lock.dart';
import 'package:smart_contacts_dialer/models/call_state.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/official_details.dart';
import 'package:smart_contacts_dialer/repositories/call_log_repository.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/screens/app_lock_screen.dart';
import 'package:smart_contacts_dialer/screens/dialer_screen.dart';
import 'package:smart_contacts_dialer/screens/home_shell.dart';
import 'package:smart_contacts_dialer/screens/in_call_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_list_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_detail_screen.dart';
import 'package:smart_contacts_dialer/services/contact_intent_service.dart';
import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/services/call_event_logger.dart';
import 'package:smart_contacts_dialer/services/call_log_import_service.dart';
import 'package:smart_contacts_dialer/services/call_service.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/permission_service.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/services/smart_redial_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/state/call_log_events.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/keyboard_inset_guard.dart';
import 'package:smart_contacts_dialer/widgets/sim_picker_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Install the global error boundaries first (standard §11.1), before anything
  // else can throw. AppLogger tolerates being called before init(), so errors
  // during startup are still captured.
  installGlobalErrorHandlers();
  try {
    await AppLogger.init();
  } catch (_) {
    // Non-fatal: the boundaries still log through AppLogger's pre-init fallback.
  }
  // Paint the UI first. Permissions + the device sync run after the first frame
  // (see [_SmartContactsAppState.initState]) so the native launch screen clears
  // immediately instead of waiting on a permission platform-channel round trip —
  // a dialer must be ready to place a call the moment it opens.
  runApp(const SmartContactsApp());
}

class SmartContactsApp extends StatefulWidget {
  const SmartContactsApp({super.key});

  @override
  State<SmartContactsApp> createState() => _SmartContactsAppState();
}

class _SmartContactsAppState extends State<SmartContactsApp>
    with WidgetsBindingObserver {
  // Lets the call-event listener drive navigation from outside the widget tree.
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  /// Lets [_syncRedialsWithCall] retire a SnackBar from outside a widget that
  /// has a Scaffold in its context.
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// App-lock gate state. [_shouldLockOnResume] starts true so a cold start
  /// locks; it's re-armed whenever the app is backgrounded. [_lockShown] is true
  /// while the lock route is on screen, and [_locking] guards the async gate
  /// against overlapping lifecycle events.
  bool _shouldLockOnResume = true;
  bool _lockShown = false;
  bool _locking = false;
  StreamSubscription<CallState>? _callSub;
  final CallEventLogger _callLogger = CallEventLogger();
  final SimService _simService = SimService();
  bool _inCallRouteShown = false;

  /// The pushed in-call route, kept so a call ending while the app is
  /// backgrounded can remove it without animation (see [_onCall]).
  Route<void>? _inCallRoute;

  /// Guards the SIM chooser so a call parked in `SELECT_PHONE_ACCOUNT` only
  /// prompts once, not on every snapshot Telecom emits while it waits. Reset
  /// when the call leaves the selecting state.
  bool _selectingHandled = false;

  /// Bridge for vCards opened/shared into the app (a `.vcf` tapped in a file
  /// manager, mail, WhatsApp, …). MainActivity parks the file's text and either
  /// we poll it on startup or a `vcardReceived` nudge tells us to collect now.
  static const MethodChannel _vcardChannel = MethodChannel(
    'contact_sphere/vcard',
  );

  /// The telecom channel, listened here only for the `dialReceived` nudge that a
  /// dial/call intent (a missed-call "Call back", a tapped `tel:` link) delivers
  /// to the already-running app. TelecomService uses the same channel name for
  /// outgoing calls; a method-call handler doesn't interfere with those.
  static const MethodChannel _telecomChannel = MethodChannel(
    'contact_sphere/telecom',
  );

  /// A call placed from a "Call back" intent, awaiting reconciliation once it
  /// ends (back-fills the real duration/type in Recents). See [_onCall].
  PendingCall? _callbackPending;
  bool _callbackSawOngoing = false;

  @override
  void initState() {
    super.initState();
    // Collect vCards handed to the already-running app (warm intents).
    _vcardChannel.setMethodCallHandler((call) async {
      if (call.method == 'vcardReceived') await _collectPendingVCard();
      return null;
    });
    // Collect a dial/call number handed to the already-running app (warm intents),
    // or trigger an immediate device call-log sync when the system CallLog updates.
    _telecomChannel.setMethodCallHandler((call) async {
      if (call.method == 'dialReceived') {
        await _collectPendingDial();
      } else if (call.method == 'onCallLogChanged') {
        unawaited(CallLogImportService().syncFromDevice(force: true));
      }
      return null;
    });
    // Collect contact intents handed to the already-running app (warm intents).
    ContactIntentService().setIntentListener(() async {
      await _collectPendingContactIntent();
    });
    // Observe lifecycle so the app re-locks when it returns from the background
    // (see [didChangeAppLifecycleState] / [_maybeLock]).
    WidgetsBinding.instance.addObserver(this);
    // When ContactSphere is the default phone app, show our own in-call screen
    // as calls come and go. No-ops on non-Android hosts (empty stream).
    _callSub = TelecomService().callEvents.listen(_onCall);
    // Log incoming/missed calls (with their SIM) into Recents. Also no-ops off
    // Android / when we're not the default dialer.
    _callLogger.start();
    // Request permissions and pull the device book AFTER the first frame paints,
    // so startup isn't blocked on a permission round trip. Requesting here also
    // shows the OS prompt over the visible UI rather than a blank launch screen.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  /// Off the launch critical path: request core permissions, then kick off the
  /// best-effort device-book sync. The permission request never throws (guarded
  /// anyway), and the sync is fire-and-forget — it no-ops when access is absent
  /// and re-checks the grant itself.
  Future<void> _bootstrap() async {
    // Show the app lock first (if enabled) so content isn't visible behind it,
    // and so the unlock prompt doesn't collide with the permission prompts.
    await _maybeLock();
    try {
      await PermissionService().requestPermissions();
    } catch (_) {
      // Non-fatal: features will re-request permissions on demand.
    }
    // Restore any Smart Redial reminders scheduled before the app was last
    // closed, and start listening so a call back from the scheduled number
    // auto-cancels the reminder.
    unawaited(SmartRedialService().init());
    unawaitedSyncFromDevice();
    // Same for the phone's call log: pull in whatever was logged while the app
    // wasn't running, so Recents is complete on the first look rather than only
    // holding the calls the app itself witnessed. Fire-and-forget; it never
    // throws and no-ops when the call log can't be read.
    unawaited(CallLogImportService().syncFromDevice());
    // One-shot repair of Recents rows that were written twice for one call
    // (before the live logger deduped). Runs once per install, before nothing
    // in particular — it only touches history that is already there.
    unawaited(_mergeDuplicateCallsOnce());
    // Cold start via a vCard intent: the text was parked before the channel
    // existed, so collect it now that the UI can show the review screen.
    await _collectPendingVCard();
    // Cold start via a dial/call intent (a missed-call "Call back", a tel: link):
    // the number was parked before the channel existed; collect it now.
    await _collectPendingDial();
    // Cold start via a contact intent (view, edit, insert, pick):
    await _collectPendingContactIntent();
  }

  /// Collapses Recents rows that are two records of one call, once per install.
  ///
  /// These were written when the live logger and the device-log import crossed:
  /// each wrote a row without seeing the other's. The live logger now dedupes,
  /// so only history from before that needs the repair. Best-effort and silent —
  /// Recents is refreshed only if something actually changed.
  Future<void> _mergeDuplicateCallsOnce() async {
    try {
      if (await AppSettings.readCallLogDuplicatesMerged()) return;
      final removed = await CallLogWriteLock.run(
        () => CallLogRepository().mergeDuplicateCalls(),
      );
      await AppSettings.writeCallLogDuplicatesMerged();
      if (removed > 0) CallLogEvents.instance.notifyCallLogged();
    } catch (_) {
      // Non-fatal: the history just keeps the duplicate rows it already had.
    }
  }

  /// Fetches (and clears) any number parked in MainActivity from a dial/call
  /// intent and acts on it: an ACTION_CALL ("Call back") places the call right
  /// away through our own dialer path; an ACTION_DIAL/VIEW (`tel:` link) opens
  /// the dialer pre-filled so the user can review before calling. No-ops on
  /// non-Android hosts / when nothing is parked.
  Future<void> _collectPendingDial() async {
    final pending = await TelecomService().getPendingDial();
    if (pending == null) return;
    if (pending.autoCall) {
      await _placeCallback(pending.number);
      // Covers a Smart Redial reminder that just auto-fired (this is also
      // how the missed-call "Call back" arrives, where it's simply a no-op):
      // native already dropped its own record, so catch the Dart-side list
      // up immediately rather than waiting for the next resume.
      unawaited(SmartRedialService().refresh());
    } else {
      _navKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => DialerScreen(initialNumber: pending.number),
        ),
      );
    }
  }

  /// Fetches (and clears) any contact intent parked in MainActivity and handles it.
  Future<void> _collectPendingContactIntent() async {
    final intent = await ContactIntentService().getPendingContactIntent();
    if (intent == null) return;

    final nav = _navKey.currentState;
    final ctx = _navKey.currentContext;
    if (nav == null || ctx == null || !ctx.mounted) return;

    int? resolvedContactId;
    String? deviceId;
    if (intent.uri != null) {
      final parsedUri = Uri.tryParse(intent.uri!);
      if (parsedUri != null && parsedUri.pathSegments.isNotEmpty) {
        deviceId = parsedUri.pathSegments.lastWhere(
          (seg) => int.tryParse(seg) != null,
          orElse: () => '',
        );
        if (deviceId.isNotEmpty) {
          final repo = ContactRepository();
          final contact = await repo.getContactByDeviceId(deviceId);
          resolvedContactId = contact?.id;
        }
      }
    }

    switch (intent.action) {
      case ContactIntentAction.view:
        if (resolvedContactId != null) {
          await nav.push(
            MaterialPageRoute<void>(
              builder: (_) => ContactDetailScreen(contactId: resolvedContactId!),
            ),
          );
        } else {
          _showSnack('Contact details not found in SreerajP Contacts Sphere.');
        }
        break;
      case ContactIntentAction.edit:
      case ContactIntentAction.insertOrEdit:
        if (resolvedContactId != null) {
          final repo = ContactRepository();
          final contact = await repo.getContactById(resolvedContactId);
          if (contact != null) {
            await nav.push(
              MaterialPageRoute<void>(
                builder: (_) => AddEditContactScreen(contact: contact),
              ),
            );
          }
        } else {
          // Pre-fill fields for insertion
          final name = intent.extras['name'] ?? '';
          final phone = intent.extras['phone'] ?? '';
          final email = intent.extras['email'] ?? '';
          final postal = intent.extras['postal'] ?? '';
          final company = intent.extras['company'] ?? '';
          final title = intent.extras['job_title'] ?? '';

          final phoneNumbers = phone.isNotEmpty ? [PhoneNumber(number: phone, type: 'personal', isPrimary: true)] : <PhoneNumber>[];
          final emails = email.isNotEmpty ? [Email(email: email, type: 'personal', isPrimary: true)] : <Email>[];
          final addresses = postal.isNotEmpty ? [Address(street: postal, type: 'personal')] : <Address>[];

          final contact = Contact(
            firstName: name.isNotEmpty ? name : 'New Contact',
          );
          contact.phoneNumbers = phoneNumbers;
          contact.emails = emails;
          contact.addresses = addresses;
          if (company.isNotEmpty || title.isNotEmpty) {
            contact.officialDetails = OfficialDetails(
              designation: title,
              department: company,
            );
          }

          await nav.push(
            MaterialPageRoute<void>(
              builder: (_) => AddEditContactScreen(contact: contact),
            ),
          );
        }
        break;
      case ContactIntentAction.insert:
        final name = intent.extras['name'] ?? '';
        final phone = intent.extras['phone'] ?? '';
        final email = intent.extras['email'] ?? '';
        final postal = intent.extras['postal'] ?? '';
        final company = intent.extras['company'] ?? '';
        final title = intent.extras['job_title'] ?? '';

        final phoneNumbers = phone.isNotEmpty ? [PhoneNumber(number: phone, type: 'personal', isPrimary: true)] : <PhoneNumber>[];
        final emails = email.isNotEmpty ? [Email(email: email, type: 'personal', isPrimary: true)] : <Email>[];
        final addresses = postal.isNotEmpty ? [Address(street: postal, type: 'personal')] : <Address>[];

        final contact = Contact(
          firstName: name.isNotEmpty ? name : 'New Contact',
        );
        contact.phoneNumbers = phoneNumbers;
        contact.emails = emails;
        contact.addresses = addresses;
        if (company.isNotEmpty || title.isNotEmpty) {
          contact.officialDetails = OfficialDetails(
            designation: title,
            department: company,
          );
        }

        await nav.push(
          MaterialPageRoute<void>(
            builder: (_) => AddEditContactScreen(contact: contact),
          ),
        );
        break;
      case ContactIntentAction.pick:
        await nav.push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(
                title: const Text('Select Contact'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ContactIntentService().submitContactPickerResult();
                  },
                ),
              ),
              body: ContactListScreen(
                pickerMode: true,
                onContactSelected: (selectedContact) async {
                  final devId = selectedContact.deviceId;
                  if (devId == null || devId.isEmpty) {
                    _showSnack('Cannot pick this contact: not synced with the system book.');
                    return;
                  }

                  final contactUri = 'content://com.android.contacts/contacts/$devId';

                  String? chosenPhone;
                  String? chosenEmail;

                  final isPhoneMime = intent.mimeType?.contains('phone') == true;
                  final isEmailMime = intent.mimeType?.contains('email') == true;

                  if (isPhoneMime && selectedContact.phoneNumbers.isNotEmpty) {
                    if (selectedContact.phoneNumbers.length == 1) {
                      chosenPhone = selectedContact.phoneNumbers.first.number;
                    } else {
                      final ph = await showDialog<PhoneNumber>(
                        context: ctx,
                        builder: (dialogCtx) => SimpleDialog(
                          title: const Text('Choose a number'),
                          children: selectedContact.phoneNumbers.map((p) {
                            return SimpleDialogOption(
                              onPressed: () => Navigator.pop(dialogCtx, p),
                              child: Text('${p.number} (${p.type})'),
                            );
                          }).toList(),
                        ),
                      );
                      if (ph == null) return;
                      chosenPhone = ph.number;
                    }
                  } else if (isEmailMime && selectedContact.emails.isNotEmpty) {
                    if (selectedContact.emails.length == 1) {
                      chosenEmail = selectedContact.emails.first.email;
                    } else {
                      final em = await showDialog<Email>(
                        context: ctx,
                        builder: (dialogCtx) => SimpleDialog(
                          title: const Text('Choose an email'),
                          children: selectedContact.emails.map((e) {
                            return SimpleDialogOption(
                              onPressed: () => Navigator.pop(dialogCtx, e),
                              child: Text('${e.email} (${e.type})'),
                            );
                          }).toList(),
                        ),
                      );
                      if (em == null) return;
                      chosenEmail = em.email;
                    }
                  }

                  await ContactIntentService().submitContactPickerResult(
                    contactUri: contactUri,
                    phone: chosenPhone,
                    email: chosenEmail,
                  );
                },
              ),
            ),
          ),
        );
        break;
      default:
        break;
    }
  }

  /// Places a "Call back" immediately through [CallService] (so it flows through
  /// our in-call UI when we're the default dialer, and is logged in Recents), and
  /// arms reconciliation for when the call ends (see [_onCall]). A call parked on
  /// a SIM choice is handled by the existing `SELECT_PHONE_ACCOUNT` path in
  /// [_onCall]. Failures surface as a snackbar rather than a silent no-op.
  Future<void> _placeCallback(String number) async {
    // Honour the multi-SIM setting exactly like the dialer (see
    // CallLifecycleMixin._resolveSim): when the user enabled "ask which SIM" and
    // there are 2+ SIMs, show the picker; otherwise use the configured default SIM
    // (null = system default). Dismissing the picker cancels the call-back.
    SimAccount? sim;
    final ctx = _navKey.currentContext;
    final settings = ctx != null
        ? Provider.of<AppSettings>(ctx, listen: false)
        : null;
    if (settings != null && settings.askSimBeforeCall) {
      final sims = await _simService.list();
      final pickCtx = _navKey.currentContext;
      if (sims.length > 1 && pickCtx != null && pickCtx.mounted) {
        final chosen = await showSimPickerSheet(pickCtx, sims: sims);
        if (chosen == null) return; // dismissed → don't place the call
        sim = chosen;
      } else {
        sim = await _simService.defaultSim(settings.defaultSimId);
      }
    } else {
      sim = await _simService.defaultSim(settings?.defaultSimId);
    }
    try {
      _callbackPending = await CallService().placeCall(
        number: number,
        sim: sim,
      );
      _callbackSawOngoing = false;
    } on CallPermissionDeniedException {
      _showSnack('Call permission denied');
    } catch (e) {
      _showSnack('Could not place call: $e');
    }
  }

  /// When a "Call back" placed by [_placeCallback] ends on the event stream,
  /// reconciles its provisional Recents row with the real duration/type from the
  /// device call log. Mirrors the `CallLifecycleMixin` end-detection (an explicit
  /// disconnected phase, or a drop to "no call" after the call was seen ongoing),
  /// but skips the post-call feedback sheet — a notification-initiated callback
  /// has no screen to host it.
  void _reconcileCallbackIfEnded(CallState state) {
    final pending = _callbackPending;
    if (pending == null) return;
    if (state.phase.isOngoing) {
      _callbackSawOngoing = true;
      return;
    }
    final ended =
        state.phase == CallPhase.disconnected ||
        (!state.hasCall && _callbackSawOngoing);
    if (!ended) return;
    _callbackPending = null;
    _callbackSawOngoing = false;
    unawaited(CallService().reconcile(pending));
  }

  /// Fetches (and clears) any vCard text parked in MainActivity and routes it:
  /// a single contact opens the Add/Edit screen pre-filled for review — saving
  /// runs the normal two-way sync, so it lands in the app DB and the device
  /// book; multiple contacts get a confirm dialog and a bulk import through the
  /// same sync path. No-ops on non-Android hosts (missing channel).
  Future<void> _collectPendingVCard() async {
    String? text;
    try {
      text = await _vcardChannel.invokeMethod<String>('getPendingVCard');
    } catch (_) {
      return; // no platform side (tests / non-Android)
    }
    if (text == null || text.trim().isEmpty) return;

    List<Contact> parsed;
    try {
      parsed = await VCardService().fromVCard(text);
    } catch (_) {
      parsed = const <Contact>[];
    }

    final nav = _navKey.currentState;
    final ctx = _navKey.currentContext;
    if (nav == null || ctx == null || !ctx.mounted) return;

    if (parsed.isEmpty) {
      _showSnack('Could not read any contact from that vCard.');
      return;
    }

    if (parsed.length == 1) {
      await nav.push<bool>(
        MaterialPageRoute(
          builder: (_) => AddEditContactScreen(contact: parsed.first),
        ),
      );
      return;
    }

    final approved = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Import contacts'),
        content: Text(
          'This vCard file contains ${parsed.length} contacts. Import them '
          'into SreerajP Contacts Sphere and your phone contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (approved != true) return;

    final sync = ContactSyncService();
    var imported = 0;
    for (final contact in parsed) {
      try {
        await sync.saveContact(contact);
        imported++;
      } catch (_) {
        // Keep going; report what actually made it.
      }
    }
    _showSnack('Imported $imported contact(s)');
  }

  void _showSnack(String message) {
    final ctx = _navKey.currentContext;
    if (ctx == null || !ctx.mounted) return;
    ScaffoldMessenger.maybeOf(
      ctx,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _callSub?.cancel();
    _callLogger.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      // Leaving the foreground: never keep the keyboard alive behind whatever
      // took over (a call, the lock screen, another app). Besides being the
      // right thing on its own, an IME dismissed by the system while we are
      // paused is what strands the stale bottom inset — see [KeyboardInsetGuard].
      _dismissKeyboard();
    }
    if (state == AppLifecycleState.resumed) {
      // Returning to the foreground: show the lock if it's due.
      _maybeLock();
      // Native may have fired or auto-cancelled a Smart Redial reminder while
      // this process stayed alive in the background; catch the list up so it
      // doesn't keep showing a task that's no longer actually pending.
      unawaited(SmartRedialService().refresh());
    } else if (state == AppLifecycleState.paused) {
      // Backgrounded: re-arm so the next foreground locks again.
      _shouldLockOnResume = true;
    }
  }

  /// Shows the app-lock screen when the lock is enabled and due. Blocks (awaits
  /// the unlock) so callers on the launch path stay behind the lock. No-ops when
  /// the lock isn't due, is disabled, the device can't authenticate, or a live
  /// call is on screen (locking must never hide an active call). The [_locking]
  /// guard keeps overlapping lifecycle events from pushing two locks.
  Future<void> _maybeLock() async {
    if (_lockShown || _locking || !_shouldLockOnResume) return;
    if (_inCallRoute?.isCurrent ?? false) return;
    _locking = true;
    try {
      final mode = await AppSettings.readLockMode();
      if (mode == LockMode.none) {
        _shouldLockOnResume = false;
        return;
      }
      // Device lock was chosen but the device screen lock is now gone (the user
      // removed it): authentication can't run. Don't trap the user out of their
      // own app — turn App lock off and warn them it's now unprotected.
      if (mode == LockMode.deviceLock && !await AuthService().isAvailable) {
        _shouldLockOnResume = false;
        await _disableLockAndWarn();
        return;
      }
      final nav = _navKey.currentState;
      if (nav == null) return;
      _shouldLockOnResume = false;
      _lockShown = true;
      await nav.push(
        MaterialPageRoute<bool>(
          fullscreenDialog: true,
          builder: (_) => AppLockScreen(mode: mode),
        ),
      );
      _lockShown = false;
    } finally {
      _locking = false;
    }
  }

  /// Turns App lock off (device-lock mode lost its device credential) and warns
  /// the user once that the app is now unprotected. Best-effort: needs a live
  /// context under the [AppSettings] provider, which exists by the time the
  /// launch/resume gate runs.
  Future<void> _disableLockAndWarn() async {
    final ctx = _navKey.currentContext;
    if (ctx == null) return;
    try {
      await Provider.of<AppSettings>(
        ctx,
        listen: false,
      ).setLockMode(LockMode.none);
    } catch (_) {
      // Non-fatal: the warning below still tells the user what happened.
    }
    if (!ctx.mounted) return;
    await showDialog<void>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('App lock turned off'),
        content: const Text(
          'Your device screen lock was removed, so App lock could no longer '
          'protect the app and has been turned off. Set a device lock or an app '
          'PIN in Settings to turn it back on.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Drops focus so the on-screen keyboard goes away. Safe to call at any time.
  void _dismissKeyboard() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus != null && focus.hasFocus) focus.unfocus();
  }

  void _onCall(CallState state) {
    // A call takes the screen; a search field must not hold the keyboard open
    // behind it (see [didChangeAppLifecycleState]).
    _dismissKeyboard();
    _reconcileCallbackIfEnded(state);
    _syncRedialsWithCall(state);

    final nav = _navKey.currentState;
    if (nav == null) return;

    // A call we placed with no chosen SIM ("System default") can park in the
    // selecting state when the OS has no default outgoing SIM. As the default
    // dialer we own the chooser: prompt for a SIM and resolve the call onto it.
    if (state.phase == CallPhase.selecting) {
      if (!_selectingHandled) {
        _selectingHandled = true;
        _promptForSim();
      }
      return;
    }
    _selectingHandled = false;

    if (state.phase.isOngoing && !_inCallRouteShown) {
      _inCallRouteShown = true;
      final route = MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => InCallScreen(initialState: state),
      );
      _inCallRoute = route;
      nav.push(route).whenComplete(() {
        _inCallRouteShown = false;
        if (_inCallRoute == route) _inCallRoute = null;
      });
    } else if (!state.phase.isOngoing && _inCallRouteShown) {
      _inCallRouteShown = false;
      final route = _inCallRoute;
      _inCallRoute = null;
      if (route != null) {
        // Clear anything the in-call screen pushed above itself (the Add-call
        // dialer, a confirm dialog, the reject-with-message sheet). Only needed
        // when the in-call route isn't on top; when backgrounded / over the lock
        // screen nothing is stacked above, so this never runs (or animates) there.
        if (route.isActive && !route.isCurrent) {
          nav.popUntil((r) => r == route || r.isFirst);
        }
        // Remove the in-call route WITHOUT an exit animation. An animated pop
        // started while the app is being sent to the background (call answered
        // over the lock screen, then ended → task moved to back) freezes
        // mid-transition and replays on the next launch — the "stale calling
        // screen" flash. removeRoute completes instantly and frame-independently,
        // so nothing is left to replay. We can't rely on the lifecycle state
        // here: native moves the task to back concurrently with this end event,
        // so we may still read `resumed`.
        nav.removeRoute(route);
      }
    }
  }

  /// Keeps the Smart Redial list honest across a call that happens while the
  /// app is open.
  ///
  /// Native cancels a scheduled retry on its own the moment the same number
  /// calls back (before the phone even rings), and fires one on its own too.
  /// The in-call screen is a route inside this same activity, so a call
  /// produces no pause/resume — without this, the Dart-side list (and the
  /// settings "Active scheduled redials" row) would keep showing a task that
  /// no longer exists until the app is backgrounded and reopened.
  ///
  /// A call arriving also retires any message still on screen: a SnackBar's
  /// dismiss timer only starts once its entry animation finishes, which stalls
  /// while the app is off-screen, so an "Auto-retry at …" confirmation can
  /// otherwise sit there long after the retry was cancelled.
  void _syncRedialsWithCall(CallState state) {
    final hasCall = state.hasCall;
    if (hasCall == _sawCallForRedials) return;
    _sawCallForRedials = hasCall;
    if (hasCall) {
      _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    } else {
      unawaited(SmartRedialService().refresh());
    }
  }

  /// Edge detection for [_syncRedialsWithCall] — the call stream emits many
  /// snapshots per call, and this work belongs to the transitions only.
  bool _sawCallForRedials = false;

  /// Shows the SIM chooser for a call waiting on a phone-account selection and
  /// resolves the call onto the chosen SIM. Cancelling (or no SIMs to offer)
  /// disconnects the parked call so it doesn't hang. Best-effort.
  Future<void> _promptForSim() async {
    final telecom = TelecomService();
    try {
      final sims = await _simService.list();
      final ctx = _navKey.currentContext;
      if (sims.isEmpty || ctx == null || !ctx.mounted) {
        await telecom.disconnect();
        return;
      }
      final chosen = await showSimPickerSheet(ctx, sims: sims);
      if (chosen != null) {
        await telecom.selectPhoneAccount(chosen);
      } else {
        await telecom.disconnect();
      }
    } catch (_) {
      // If anything goes wrong resolving the SIM, don't leave the call parked.
      await telecom.disconnect();
    }
  }

  /// How fast a rightward drag must end (logical px/s) to count as the
  /// back-swipe. Matches the shell's tab-swipe threshold so the two gestures
  /// feel the same.
  static const double _backSwipeVelocity = 300;

  /// Swipe right → back to the parent screen. Sits *above* the [Navigator]
  /// (via [MaterialApp.builder]) so every pushed route gets it without
  /// per-screen wiring; anything inside a route that claims horizontal drags
  /// (slidable rows, sliders, text fields) wins the gesture arena, and the
  /// [HomeShell]'s own detector takes over when nothing is pushed. `maybePop`
  /// keeps any route-level pop guards in charge.
  void _onBackSwipe(DragEndDetails details) {
    if ((details.primaryVelocity ?? 0) < _backSwipeVelocity) return;
    // Never swipe away a live call: the in-call screen only leaves when the
    // call ends (see _onCall) or through its own controls.
    if (_inCallRoute?.isCurrent ?? false) return;
    final nav = _navKey.currentState;
    if (nav == null || !nav.canPop()) return;
    nav.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    // The app owns its AppSettings provider so it stays self-contained (and the
    // widget smoke test can pump it directly). `load()` runs lazily after the
    // first frame; defaults apply until persisted values arrive.
    return ChangeNotifierProvider<AppSettings>(
      create: (_) => AppSettings()..load(),
      child: Consumer<AppSettings>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppFlavorConfig.instance.appName,
            navigatorKey: _navKey,
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            // Standard §8.1: declare the Global localization delegates so built-in
            // Material widgets (date pickers, dialogs, tooltips) render correctly on
            // non-English device locales. App strings are English; `ml` is listed so
            // Material widgets localize to Malayalam on Malayalam devices.
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ml')],
            // Keep the device's regional English (e.g. en_IN, en_GB) instead of
            // letting Flutter strip it to bare `en` (which intl treats as en_US).
            // This makes built-in widgets like the date picker use the system's
            // date format. App strings stay English; ml devices keep Malayalam.
            localeListResolutionCallback: (deviceLocales, supported) {
              if (deviceLocales != null) {
                for (final locale in deviceLocales) {
                  if (locale.languageCode == 'en') return locale;
                  if (locale.languageCode == 'ml') return const Locale('ml');
                }
              }
              return const Locale('en');
            },
            theme: AppTheme.calm(
              settings.lightAccent,
              fontFamily: settings.fontFamily,
            ),
            darkTheme: AppTheme.midnight(
              settings.darkAccent,
              fontFamily: settings.fontFamily,
            ),
            themeMode: settings.themeMode,
            builder: (context, child) {
              // App-wide text scaling: the in-app Text size setting is the single
              // source of truth for scale, so override MediaQuery's textScaler.
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: TextScaler.linear(settings.textScaleFactor),
                ),
                // Above the Navigator so every route is covered: ignores a
                // keyboard inset left behind after the IME was dismissed out
                // from under us (a call arriving mid-search), which otherwise
                // leaves every screen cropped until the app restarts.
                child: KeyboardInsetGuard(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragEnd: _onBackSwipe,
                    child: child!,
                  ),
                ),
              );
            },
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
