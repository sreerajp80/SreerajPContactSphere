// lib/screens/contact_list_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/interaction_repository.dart';
import 'package:smart_contacts_dialer/services/auth_service.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/ephemeral_contact_service.dart';
import 'package:smart_contacts_dialer/services/export_import_service.dart';
import 'package:smart_contacts_dialer/services/screen_security_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/widgets/avatar_initial.dart';
import 'package:smart_contacts_dialer/widgets/ble_share_dialog.dart';
import 'package:smart_contacts_dialer/widgets/call_lifecycle_mixin.dart';
import 'package:smart_contacts_dialer/widgets/number_picker_sheet.dart';
import 'package:smart_contacts_dialer/widgets/voice_input_button.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/screens/ble_receive_screen.dart';
import 'package:smart_contacts_dialer/screens/business_card_scan_screen.dart';
import 'package:smart_contacts_dialer/screens/contact_detail_screen.dart';
import 'package:smart_contacts_dialer/screens/duplicates_screen.dart';
import 'package:smart_contacts_dialer/screens/groups_screen.dart';
import 'package:smart_contacts_dialer/screens/qr_scan_screen.dart';
import 'package:smart_contacts_dialer/screens/relation_status_screen.dart';
import 'package:smart_contacts_dialer/screens/settings_screen.dart';

class ContactListScreen extends StatefulWidget {
  final bool pickerMode;
  final ValueChanged<Contact>? onContactSelected;

  const ContactListScreen({
    super.key,
    this.pickerMode = false,
    this.onContactSelected,
  });

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen>
    with WidgetsBindingObserver, CallLifecycleMixin<ContactListScreen> {
  final ContactSyncService _sync = ContactSyncService();
  final ExportImportService _exportImport = ExportImportService();
  final AuthService _auth = AuthService();
  final InteractionRepository _interactions = InteractionRepository();

  /// How many contacts each page of the (slim) local read pulls. The list paints
  /// the first page immediately and appends further pages as the user scrolls.
  static const int _pageSize = 80;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  /// Refreshes the list whenever a device sync lands, no matter who ran it —
  /// on first launch the startup sync (main.dart) only completes after the
  /// user grants the contacts permission, well after this screen's initial
  /// (empty) read.
  StreamSubscription<int>? _syncSub;
  StreamSubscription<int>? _ephemeralSub;

  /// Live progress of an in-flight device sync (first-run, background, or
  /// manual from settings). Non-null while one runs; drives the slim progress
  /// banner shown above the list.
  StreamSubscription<SyncProgress?>? _progressSub;
  SyncProgress? _syncProgress;

  /// Whether the sync progress banner may be shown. Only true for the very
  /// first run's blocking import; background syncs on later launches sync
  /// silently, so relaunching the app doesn't flash a "Syncing…" bar each time.
  bool _showSyncBanner = false;

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];

  /// The "Self" contact (phone owner), pinned above the alphabetical list.
  /// Null when the user hasn't set one. Loaded separately from the paged list
  /// (which excludes it) so paging/counts stay correct.
  Contact? _self;
  Map<int, DateTime> _lastInteraction = {};
  Map<int, int> _recentCounts = {};
  final Set<int> _expanded = {};

  /// Multi-select state. When [_selectionMode] is true the list stops
  /// expanding/opening cards on tap and instead toggles selection, so several
  /// contacts can be deleted at once. Selections are keyed by a stable string
  /// ([_keyFor]) so they survive paging and reloads. The pinned Self contact is
  /// never selectable.
  bool _selectionMode = false;
  final Set<String> _selectedKeys = {};

  String _searchQuery = '';
  bool _showSecretContacts = false;

  /// When true the list shows only favorite contacts (the ★ Favorites chip).
  /// The favorites view is loaded in one unpaged query — favorites are a small
  /// set — so paging is disabled while it is active.
  bool _favoritesOnly = false;
  bool _loading = true;

  int _total = 0; // total stored contacts (for paging)
  bool _loadingMore = false;

  /// Per-letter contact counts for the section headers (e.g. `{'A': 12}`).
  /// Loaded once per refresh with the same filters as the list, so a header can
  /// show its full group size even though contacts stream in page by page.
  Map<String, int> _sectionCounts = const {};
  bool get _hasMore =>
      _searchQuery.isEmpty && !_favoritesOnly && _contacts.length < _total;

  /// Display preferences (Settings → Contacts), mirrored here so the paged
  /// reads and the card renderer can apply them. Kept in sync with [AppSettings]
  /// via [_onSettingsChanged]; the sort/hide flags feed the queries, the name
  /// format only affects rendering.
  AppSettings? _appSettings;
  bool _sortByLastName = false;
  bool _requirePhone = false;
  NameDisplayFormat _nameFormat = NameDisplayFormat.firstFirst;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _syncSub = _sync.onSyncCompleted.listen((_) {
      if (mounted) _reload();
    });
    // Seed from the current state so a sync already running when this screen
    // mounts shows its banner immediately, then follow the live updates.
    _syncProgress = _sync.currentProgress;
    _progressSub = _sync.onSyncProgress.listen((p) {
      if (mounted) setState(() => _syncProgress = p);
    });
    // Seed the display prefs before the first load so the initial query already
    // uses the chosen sort/hide, and follow later changes (read is safe in
    // initState for a listen:false provider access).
    final settings = context.read<AppSettings>();
    _appSettings = settings;
    _sortByLastName = settings.contactSortOrder == ContactSortOrder.lastName;
    _requirePhone = settings.hideContactsWithoutPhone;
    _nameFormat = settings.nameDisplayFormat;
    settings.addListener(_onSettingsChanged);
    EphemeralContactService().startMonitoring();
    _ephemeralSub = EphemeralContactService().onContactScrubbed.listen((_) {
      if (mounted) _reload();
    });
    _firstLoad();
  }

  /// Reacts to a Settings → Contacts change: a sort or hide-filter change
  /// re-reads the (paged) list from the top; a name-format change only repaints.
  /// Ignores the many unrelated [AppSettings] notifications (theme, accent, …).
  void _onSettingsChanged() {
    final s = _appSettings;
    if (s == null || !mounted) return;
    final newSort = s.contactSortOrder == ContactSortOrder.lastName;
    final newRequirePhone = s.hideContactsWithoutPhone;
    final newFormat = s.nameDisplayFormat;
    final needReload =
        newSort != _sortByLastName || newRequirePhone != _requirePhone;
    final needRepaint = newFormat != _nameFormat;
    _sortByLastName = newSort;
    _requirePhone = newRequirePhone;
    _nameFormat = newFormat;
    if (needReload) {
      _reload();
    } else if (needRepaint) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Never leave the secure flag stuck on if we leave while secret contacts
    // are shown.
    if (_showSecretContacts) ScreenSecurity.release('secret_contacts');
    _appSettings?.removeListener(_onSettingsChanged);
    EphemeralContactService().stopMonitoring();
    _syncSub?.cancel();
    _ephemeralSub?.cancel();
    _progressSub?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 600) _loadMore();
  }

  /// Initial screen load. After the device book has been pulled once, we show
  /// the locally-stored contacts immediately (paged) and sync in the background.
  /// On the very first run there is nothing stored yet, so we show the device
  /// book quickly (light, no photos) instead of blocking on the full sync.
  Future<void> _firstLoad() async {
    final initialDone = await _sync.hasCompletedInitialSync();
    // Show the progress banner only for the first-run blocking import; later
    // launches sync in the background without the "Syncing…" bar.
    if (mounted) setState(() => _showSyncBanner = !initialDone);
    if (initialDone) {
      await _reload();
      _backgroundSync();
    } else {
      await _firstRunQuickShow();
    }
  }

  /// Very first run: render the device contacts fast (light fetch, no photos, no
  /// per-contact disk writes) so the user isn't stuck behind a spinner, then run
  /// the full sync in the background and refresh from the de-duplicated store.
  Future<void> _firstRunQuickShow() async {
    setState(() => _loading = true);
    try {
      final quick = await _sync.mergedContacts(
        includeSecret: _showSecretContacts,
        sortByLastName: _sortByLastName,
        requirePhone: _requirePhone,
      );
      if (!mounted) return;
      setState(() {
        _contacts = quick;
        _total = quick.length;
        _filteredContacts = List.of(quick);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
    try {
      await _sync.syncFromDevice();
    } catch (_) {
      // Sync is optional; the quick list stays until the next refresh.
    }
    if (!mounted) return;
    await _reload();
  }

  /// Cheap, local-only refresh: reads the first page of stored contacts (slim,
  /// no device fetch) plus the best-effort interaction hints, without the
  /// full-screen spinner. Used on read-only returns and after mutations that
  /// already synced to the device inside [ContactSyncService].
  Future<void> _reload() async {
    try {
      // The favorites view is a small set — load it whole (no paging).
      final firstPage = await _sync.localSummaries(
        includeSecret: _showSecretContacts,
        favoritesOnly: _favoritesOnly,
        sortByLastName: _sortByLastName,
        requirePhone: _requirePhone,
        limit: _favoritesOnly ? null : _pageSize,
      );
      final total = await _sync.contactCount(
        includeSecret: _showSecretContacts,
        requirePhone: _requirePhone,
      );
      final sections = await _sync.sectionCounts(
        includeSecret: _showSecretContacts,
        favoritesOnly: _favoritesOnly,
        sortByLastName: _sortByLastName,
        requirePhone: _requirePhone,
      );
      final self = await _loadSelf();
      final last = await _loadLastInteractions();
      final recent = await _loadRecentCounts();
      if (!mounted) return;
      setState(() {
        _contacts = firstPage;
        _total = total;
        _sectionCounts = sections;
        _self = self;
        _lastInteraction = last;
        _recentCounts = recent;
        _loading = false;
      });
      _refreshFiltered();
    } catch (e) {
      // The DB can be unavailable (e.g. in tests, or first-run errors); keep the
      // UI usable with an empty list instead of crashing.
      if (!mounted) return;
      setState(() {
        _contacts = [];
        _filteredContacts = [];
        _sectionCounts = const {};
        _self = null;
        _total = 0;
        _loading = false;
      });
    }
  }

  /// Appends the next page of stored contacts as the list nears its end.
  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final next = await _sync.localSummaries(
        includeSecret: _showSecretContacts,
        favoritesOnly: _favoritesOnly,
        sortByLastName: _sortByLastName,
        requirePhone: _requirePhone,
        limit: _pageSize,
        offset: _contacts.length,
      );
      if (!mounted) return;
      setState(() {
        _contacts = [..._contacts, ...next];
        _loadingMore = false;
        if (_searchQuery.isEmpty) _filteredContacts = List.of(_contacts);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  /// Fire-and-forget device pull. No spinner, and no reload here: a completed
  /// sync fires [ContactSyncService.onSyncCompleted], which triggers the
  /// listener installed in [initState] to refresh the list locally.
  Future<void> _backgroundSync() async {
    try {
      await _sync.syncFromDevice();
    } catch (_) {
      // Background sync is best-effort; the list already shows local contacts.
    }
  }

  /// Best-effort load of the pinned "Self" contact. Never throws into the
  /// reload path — a failure just leaves the pin absent.
  Future<Contact?> _loadSelf() async {
    try {
      return await _sync.selfSummary();
    } catch (_) {
      return null;
    }
  }

  Future<Map<int, DateTime>> _loadLastInteractions() async {
    try {
      return await _interactions.lastInteractionByContact();
    } catch (_) {
      // Enrichment is optional; cards still render without it.
      return const {};
    }
  }

  Future<Map<int, int>> _loadRecentCounts() async {
    try {
      return await _interactions.recentInteractionCountByContact();
    } catch (_) {
      return const {};
    }
  }

  /// Re-syncs [_filteredContacts] with the current state: the loaded pages when
  /// there's no query, or a fresh DB-backed search otherwise.
  void _refreshFiltered() {
    if (_searchQuery.isEmpty) {
      setState(() => _filteredContacts = List.of(_contacts));
    } else {
      _runSearch(_searchQuery);
    }
  }

  void _filterContacts(String query) {
    // setState so the clear (X) button shows/hides immediately as the query
    // flips between empty and non-empty, without waiting for the DB search.
    setState(() => _searchQuery = query);
    if (query.isEmpty) {
      setState(() => _filteredContacts = List.of(_contacts));
      return;
    }
    _runSearch(query);
  }

  /// DB-backed search across the whole address book (name/phone/email), so hits
  /// aren't limited to the pages currently loaded into the list.
  Future<void> _runSearch(String query) async {
    try {
      final results = await _sync.searchSummaries(
        query,
        includeSecret: _showSecretContacts,
        favoritesOnly: _favoritesOnly,
      );
      if (!mounted || _searchQuery != query) return; // stale result
      setState(() => _filteredContacts = results);
    } catch (_) {
      if (!mounted || _searchQuery != query) return;
      setState(() => _filteredContacts = const []);
    }
  }

  Future<void> _toggleSecret() async {
    if (_showSecretContacts) {
      setState(() => _showSecretContacts = false);
      await ScreenSecurity.release('secret_contacts');
      await _reload();
      return;
    }
    final ok = await _auth.authenticate();
    if (!ok) {
      _showMessage('Authentication required to view secret contacts');
      return;
    }
    setState(() => _showSecretContacts = true);
    // Keep secret names/numbers out of screenshots and the Recents thumbnail.
    await ScreenSecurity.acquire('secret_contacts');
    await _reload();
  }

  Future<void> _addContact() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddEditContactScreen()),
    );
    if (saved == true) _reload();
  }

  Future<void> _openContact(Contact contact) async {
    if (widget.pickerMode) {
      widget.onContactSelected?.call(contact);
      return;
    }
    if (contact.id == null) {
      // Device-only contact: open the editor pre-filled so saving adopts it into
      // the app DB (keeping the device link).
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AddEditContactScreen(contact: contact),
        ),
      );
      if (saved == true) _reload();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactDetailScreen(contactId: contact.id!),
      ),
    );
    _reload();
  }

  /// Confirms and deletes [contact] from both the app and (when linked) the
  /// device address book via [ContactSyncService].
  Future<void> _confirmDelete(Contact contact) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${contact.fullName}?'),
        content: Text(
          contact.deviceId != null
              ? 'Removes this contact from the app and the device address book.'
              : 'Removes this contact from the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _sync.deleteContact(contact);
      _showMessage('Deleted ${contact.fullName}');
      await _reload();
    } catch (e) {
      _showMessage('Delete failed: $e');
    }
  }

  /// A stable selection key for [c]: its app id when stored, else its device id.
  /// Returns null for a contact with neither (not selectable).
  String? _keyFor(Contact c) {
    if (c.id != null) return 'id:${c.id}';
    if (c.deviceId != null) return 'dev:${c.deviceId}';
    return null;
  }

  bool _isSelected(Contact c) {
    final key = _keyFor(c);
    return key != null && _selectedKeys.contains(key);
  }

  /// Enters selection mode with [c] as the first selected contact (long-press).
  void _enterSelection(Contact c) {
    final key = _keyFor(c);
    if (key == null) return;
    setState(() {
      _selectionMode = true;
      _selectedKeys.add(key);
    });
  }

  /// Toggles [c] in the selection. Deselecting the last contact leaves selection
  /// mode.
  void _toggleSelected(Contact c) {
    final key = _keyFor(c);
    if (key == null) return;
    setState(() {
      if (!_selectedKeys.remove(key)) _selectedKeys.add(key);
      if (_selectedKeys.isEmpty) _selectionMode = false;
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedKeys.clear();
    });
  }

  /// Select-all toggle for the currently visible (filtered) list. If every
  /// visible contact is already selected it clears the selection instead; the
  /// pinned Self contact is not part of [_filteredContacts], so it stays out.
  void _selectAllVisible() {
    final keys = <String>{};
    for (final c in _filteredContacts) {
      final key = _keyFor(c);
      if (key != null) keys.add(key);
    }
    setState(() {
      if (keys.isNotEmpty && keys.every(_selectedKeys.contains)) {
        _selectedKeys.clear();
        _selectionMode = false;
      } else {
        _selectedKeys.addAll(keys);
      }
    });
  }

  /// Resolves the selected keys back to the loaded [Contact] objects (from the
  /// filtered results and the paged list). Keys that no longer resolve to a
  /// loaded contact are simply skipped.
  List<Contact> _selectedContacts() {
    final byKey = <String, Contact>{};
    for (final c in [..._filteredContacts, ..._contacts]) {
      final key = _keyFor(c);
      if (key != null && _selectedKeys.contains(key)) byKey[key] = c;
    }
    return byKey.values.toList();
  }

  /// Confirms and deletes every selected contact via [ContactSyncService], which
  /// removes each from the app DB and (when linked) the device address book.
  Future<void> _confirmDeleteSelected() async {
    final selected = _selectedContacts();
    if (selected.isEmpty) return;
    final count = selected.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $count contacts?'),
        content: const Text(
          'Removes them from the app, and from the device address book where '
          'they are linked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    var deleted = 0;
    var failed = 0;
    for (final c in selected) {
      try {
        await _sync.deleteContact(c);
        deleted++;
      } catch (_) {
        failed++;
      }
    }
    _exitSelection();
    _showMessage(
      failed == 0
          ? 'Deleted $deleted contact(s)'
          : 'Deleted $deleted contact(s), $failed failed',
    );
    await _reload();
  }

  /// Simple tap on Call: dials the contact's default (primary) number via the
  /// shared [CallLifecycleMixin] — which resolves the SIM, logs the call,
  /// reconciles on resume and prompts for feedback. The slim list summary already
  /// loads the primary as the only/first number, so no extra query is needed.
  Future<void> _quickCall(Contact contact) async {
    if (contact.phoneNumbers.isEmpty) {
      _showMessage('No phone number for ${contact.fullName}');
      return;
    }
    await startCall(
      contactId: contact.id,
      number: contact.phoneNumbers.first.number,
      displayName: contact.fullName,
    );
  }

  /// The contact's primary email address from the slim summary (first non-empty
  /// entry), or null when the summary carries none. Drives whether the Email
  /// quick-action is enabled.
  String? _primaryEmail(Contact contact) {
    for (final e in contact.emails) {
      final address = e.email.trim();
      if (address.isNotEmpty) return address;
    }
    return null;
  }

  /// Opens the device's default mail client composing to the contact's primary
  /// email. Falls back to an on-demand load of the full emails when the slim
  /// summary carries none (defensive — the button is normally disabled then).
  Future<void> _quickEmail(Contact contact) async {
    var address = _primaryEmail(contact);
    if (address == null && contact.id != null) {
      try {
        final emails = await _sync.emailsFor(contact.id!);
        for (final e in emails) {
          final a = e.email.trim();
          if (a.isNotEmpty) {
            address = a;
            break;
          }
        }
      } catch (_) {
        // Best-effort; fall through to the no-email message below.
      }
    }

    if (address == null) {
      _showMessage('No email address for ${contact.fullName}');
      return;
    }

    final uri = Uri(scheme: 'mailto', path: address);
    try {
      final launched = await launchUrl(uri);
      if (!launched) {
        _showMessage('No email app available');
      }
    } catch (_) {
      _showMessage('Could not open the email app');
    }
  }

  /// Long-press on Call: lets the user pick which number to dial, then hands off
  /// to [startCall] (which still runs the normal SIM chooser). Loads the full
  /// numbers on demand since the list summary only carries the primary. With a
  /// single number it behaves like a plain tap.
  Future<void> _pickNumberAndCall(Contact contact) async {
    var numbers = contact.phoneNumbers;
    if (contact.id != null) {
      try {
        final full = await _sync.phoneNumbersFor(contact.id!);
        if (full.isNotEmpty) numbers = full;
      } catch (_) {
        // Best-effort; fall back to the summary's primary number.
      }
    }

    if (numbers.isEmpty) {
      _showMessage('No phone number for ${contact.fullName}');
      return;
    }

    PhoneNumber chosen;
    if (numbers.length == 1) {
      chosen = numbers.first;
    } else {
      if (!mounted) return;
      final picked = await showNumberPickerSheet(
        context,
        displayName: contact.fullName,
        numbers: numbers,
      );
      if (picked == null) return; // dismissed → abort
      chosen = picked;
    }

    await startCall(
      contactId: contact.id,
      number: chosen.number,
      displayName: contact.fullName,
    );
  }

  /// Reload the list after a call (the relationship score may have changed).
  @override
  void onCallReconciled() => _reload();

  Future<void> _handleMenu(String value) async {
    switch (value) {
      case 'profile':
        await _openSelf();
        break;
      case 'import_export':
        final action = await _showActionSheet(
          title: 'Import / Export',
          options: const [
            ('import', Icons.file_download_outlined, 'Import CSV'),
            ('export', Icons.file_upload_outlined, 'Export CSV'),
            ('import_vcf', Icons.file_download_outlined, 'Import vCard (.vcf)'),
            ('export_vcf', Icons.file_upload_outlined, 'Export vCard (.vcf)'),
          ],
        );
        if (action != null && mounted) await _handleMenu(action);
        break;
      case 'bluetooth':
        final action = await _showActionSheet(
          title: 'Bluetooth transfer',
          options: const [
            ('send_all_ble', Icons.bluetooth, 'Send all via Bluetooth'),
            ('receive_ble', Icons.bluetooth_searching, 'Receive via Bluetooth'),
          ],
        );
        if (action != null && mounted) await _handleMenu(action);
        break;
      case 'import':
        try {
          final count = await _exportImport.importContacts();
          _showMessage(
            count > 0 ? 'Imported $count contact(s)' : 'Nothing imported',
          );
          if (count > 0) _reload();
        } catch (e) {
          _showMessage('Import failed: $e');
        }
        break;
      case 'export':
        try {
          await _exportImport.exportContacts(
            includeSecret: context.read<AppSettings>().includeSecretInExport,
          );
        } catch (e) {
          _showMessage('Export failed: $e');
        }
        break;
      case 'import_vcf':
        try {
          final count = await _exportImport.importContactsVcf();
          _showMessage(
            count > 0 ? 'Imported $count contact(s)' : 'Nothing imported',
          );
          if (count > 0) _reload();
        } catch (e) {
          _showMessage('Import failed: $e');
        }
        break;
      case 'export_vcf':
        try {
          await _exportImport.exportContactsVcf(
            includeSecret: context.read<AppSettings>().includeSecretInExport,
          );
        } catch (e) {
          _showMessage('Export failed: $e');
        }
        break;
      case 'scan_qr':
        final saved = await Navigator.of(
          context,
        ).push<bool>(MaterialPageRoute(builder: (_) => const QrScanScreen()));
        if (saved == true) _reload();
        break;
      case 'scan_card':
        final added = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const BusinessCardScanScreen()),
        );
        if (added == true) _reload();
        break;
      case 'receive_ble':
        final received = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const BleReceiveScreen()),
        );
        if (received == true) _reload();
        break;
      case 'send_all_ble':
        // Same secret-contacts rule as the CSV/.vcf exports.
        final includeSecret = context.read<AppSettings>().includeSecretInExport;
        try {
          final contacts = await ContactRepository().getAllContacts(
            includeSecret: includeSecret,
          );
          if (contacts.isEmpty) {
            _showMessage('No contacts to send');
            break;
          }
          if (!mounted) return;
          await showBleShareAllDialog(context, contacts);
        } catch (e) {
          _showMessage('Could not start Bluetooth sharing: $e');
        }
        break;
      case 'duplicates':
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DuplicatesScreen()));
        _reload();
        break;
      case 'groups':
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const GroupsScreen()));
        break;
      case 'settings':
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
        // Settings can change the Self record (Add Me) or display options, so
        // refresh the list on return instead of waiting for another trigger.
        if (mounted) await _reload();
        break;
    }
  }

  /// Shows a chooser bottom sheet in the app's standard style (drag handle,
  /// bold title, icon + label rows) and returns the picked option's value, or
  /// null if the sheet is dismissed.
  Future<String?> _showActionSheet({
    required String title,
    required List<(String value, IconData icon, String label)> options,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final muted = Theme.of(sheetContext).extension<AppColors>()!.mutedText;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final (value, icon, label) in options)
                ListTile(
                  leading: Icon(icon, color: muted),
                  title: Text(label),
                  onTap: () => Navigator.of(sheetContext).pop(value),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Opens the "Self" contact (the phone owner): the detail screen if one has
  /// been set, otherwise the Add/Edit form pre-toggled as Self so the user can
  /// create their own record.
  Future<void> _openSelf() async {
    Contact? self = _self;
    try {
      self = await _sync.selfSummary() ?? self;
    } catch (_) {
      // Fall back to the last-loaded value.
    }
    if (!mounted) return;
    if (self?.id != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ContactDetailScreen(contactId: self!.id!),
        ),
      );
    } else {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const AddEditContactScreen(initialIsSelf: true),
        ),
      );
    }
    _reload();
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Switches between the full list and the favorites-only view.
  Future<void> _setFavoritesOnly(bool value) async {
    if (_favoritesOnly == value) return;
    setState(() => _favoritesOnly = value);
    await _reload();
  }

  Future<void> _openRelationStatus() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RelationStatusScreen()));
    // Relations (and thus scores) can change from the sphere — refresh.
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.pickerMode) _buildHeader(context),
            _buildSearch(context, colors),
            _buildFilterChips(context, colors),
            if (_syncProgress != null && _showSyncBanner)
              _buildSyncBanner(colors),
            Expanded(child: _buildList(colors)),
          ],
        ),
      ),
      floatingActionButton: (widget.pickerMode || _selectionMode) ? null : _buildFab(colors),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (_selectionMode) return _buildSelectionHeader(context);
    final muted = Theme.of(context).extension<AppColors>()!.mutedText;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Contacts',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _showSecretContacts ? Icons.lock_open : Icons.lock,
              color: muted,
            ),
            tooltip: 'Secret contacts',
            onPressed: _toggleSecret,
          ),
          IconButton(
            icon: Icon(Icons.favorite_outline, color: muted),
            tooltip: 'Relation status',
            onPressed: _openRelationStatus,
          ),
          IconButton(
            icon: Icon(Icons.group_outlined, color: muted),
            tooltip: 'Groups',
            onPressed: () => _handleMenu('groups'),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: muted),
            onSelected: _handleMenu,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('My Profile')),
              PopupMenuItem(
                value: 'import_export',
                child: Text('Import / Export'),
              ),
              PopupMenuItem(
                value: 'bluetooth',
                child: Text('Bluetooth transfer'),
              ),
              PopupMenuItem(value: 'scan_qr', child: Text('Scan QR code')),
              PopupMenuItem(
                value: 'scan_card',
                child: Text('Scan business card'),
              ),
              PopupMenuItem(
                value: 'duplicates',
                child: Text('Find Duplicates'),
              ),
              PopupMenuDivider(),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
    );
  }

  /// Contextual header shown while multi-select is active: cancel, the selected
  /// count, a select-all toggle, and the bulk-delete action.
  Widget _buildSelectionHeader(BuildContext context) {
    final muted = Theme.of(context).extension<AppColors>()!.mutedText;
    final count = _selectedKeys.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: muted),
            tooltip: 'Cancel selection',
            onPressed: _exitSelection,
          ),
          Expanded(
            child: Text(
              '$count selected',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.select_all, color: muted),
            tooltip: 'Select all',
            onPressed: _selectAllVisible,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: muted),
            tooltip: 'Delete selected',
            onPressed: count == 0 ? null : _confirmDeleteSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context, AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
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
          onChanged: _filterContacts,
          decoration: InputDecoration(
            hintText: 'Search contacts',
            prefixIcon: Icon(Icons.search, color: accent),
            suffixIcon: _searchQuery.isEmpty
                // Voice search: partial results land in the field live, each
                // running the same DB-backed search as typing.
                ? VoiceInputButton(
                    onWords: (words, _) {
                      _searchController.text = words;
                      _searchController.selection = TextSelection.collapsed(
                        offset: words.length,
                      );
                      _filterContacts(words);
                    },
                  )
                : IconButton(
                    icon: Icon(Icons.close, color: colors.mutedText),
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      _filterContacts('');
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

  /// The All / ★ Favorites filter row shown under the search bar. Selected pill
  /// follows the bottom-nav pill styling (soft accent fill + accent text).
  Widget _buildFilterChips(BuildContext context, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          _FilterChipPill(
            label: 'All',
            selected: !_favoritesOnly,
            onTap: () => _setFavoritesOnly(false),
          ),
          const SizedBox(width: 8),
          _FilterChipPill(
            label: 'Favorites',
            icon: Icons.star,
            selected: _favoritesOnly,
            onTap: () => _setFavoritesOnly(true),
          ),
        ],
      ),
    );
  }

  /// Slim banner shown above the list while a device sync runs: a label plus
  /// a thin progress bar — indeterminate while the device book is being read,
  /// determinate ("x of y") once the merge total is known.
  Widget _buildSyncBanner(AppColors colors) {
    final p = _syncProgress!;
    final merging = p.phase == SyncPhase.merging;
    final label = merging
        ? 'Syncing contacts… ${p.processed} of ${p.total}'
        : 'Reading device contacts…';
    final double? value = (merging && p.total > 0)
        ? p.processed / p.total
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: colors.mutedText, fontSize: 12)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: value, minHeight: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppColors colors) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Pin the Self contact above the list, but only in the unfiltered view; a
    // search matching Self already surfaces it (ordered first) in the results,
    // and the favorites view shows only what is actually starred.
    final showSelf = _searchQuery.isEmpty && !_favoritesOnly && _self != null && !widget.pickerMode;
    final leading = showSelf ? 1 : 0;

    if (_filteredContacts.isEmpty && !showSelf) {
      final String message;
      if (_searchQuery.isNotEmpty) {
        message = 'No contacts match "$_searchQuery".';
      } else if (_favoritesOnly) {
        message = 'No favorites yet.\nStar a contact to see it here.';
      } else {
        message = 'No contacts yet. Tap + to add one.';
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.mutedText, fontSize: 14),
          ),
        ),
      );
    }
    // Build the flat row list, inserting an alphabetical header whenever the
    // section letter changes. Headers are shown in the browse views (full and
    // favorites) but not in search results, which are ranked, not alphabetical.
    // The letter comes from the romanized sort key so English and Malayalam
    // names group together (see [sectionLetterFor]).
    final showHeaders = _searchQuery.isEmpty;
    final rows = <Object>[];
    if (showHeaders) {
      String? prev;
      for (final c in _filteredContacts) {
        final letter = _sectionLetterOf(c);
        if (letter != prev) {
          rows.add(_SectionHeader(letter, _sectionCounts[letter]));
          prev = letter;
        }
        rows.add(c);
      }
    } else {
      rows.addAll(_filteredContacts);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 96),
      itemCount: leading + rows.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (showSelf && index == 0) {
          return _buildContactCard(_self!, colors, selectable: false);
        }
        final i = index - leading;
        if (i >= rows.length) {
          // Trailing paging spinner (only present while more pages remain).
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final row = rows[i];
        if (row is _SectionHeader) {
          return _buildSectionHeader(row, colors);
        }
        return _buildContactCard(row as Contact, colors);
      },
    );
  }

  /// The A–Z bucket for [c] under the active sort order, from the romanized sort
  /// key so Malayalam and English names fall in the same buckets.
  String _sectionLetterOf(Contact c) =>
      sectionLetterFor(_sortByLastName ? (c.lastName ?? '') : c.firstName);

  Widget _buildSectionHeader(_SectionHeader header, AppColors colors) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
      child: Row(
        children: [
          Text(
            header.letter,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          if (header.count != null) ...[
            const SizedBox(width: 6),
            Text(
              '(${header.count})',
              style: TextStyle(color: colors.mutedText, fontSize: 12),
            ),
          ],
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: colors.mutedText.withValues(alpha: 0.20),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    Contact contact,
    AppColors colors, {
    bool selectable = true,
  }) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final hasPhoto =
        contact.photoPath != null && File(contact.photoPath!).existsSync();
    final mood = AppTheme.moodFor(contact.relationshipScore);
    final selected = selectable && _isSelected(contact);
    final isOpen =
        contact.id != null && !_selectionMode && _expanded.contains(contact.id);
    final last = contact.id != null ? _lastInteraction[contact.id] : null;
    final streak = contact.id != null ? (_recentCounts[contact.id] ?? 0) : 0;

    final metaParts = <String>[
      if (contact.phoneNumbers.isNotEmpty) contact.phoneNumbers.first.number,
      if (last != null) _relativeTime(last),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selected ? accent.withValues(alpha: 0.10) : colors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: selected
            ? Border.all(color: accent, width: 1.5)
            : colors.isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F2A28).withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                  spreadRadius: -14,
                ),
              ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (widget.pickerMode) {
                _openContact(contact);
                return;
              }
              // While multi-selecting, a tap toggles this card's selection
              // instead of expanding/opening it.
              if (_selectionMode) {
                if (selectable) _toggleSelected(contact);
                return;
              }
              // Device-only contacts have no id and so can't expand — tap opens
              // the editor to adopt them instead.
              if (contact.id == null) {
                _openContact(contact);
                return;
              }
              setState(() {
                if (isOpen) {
                  _expanded.remove(contact.id);
                } else {
                  _expanded.add(contact.id!);
                }
              });
            },
            onLongPress: () {
              if (widget.pickerMode) return;
              // The Self card isn't part of multi-select; keep its single delete.
              if (!selectable) {
                _confirmDelete(contact);
                return;
              }
              if (_selectionMode) {
                _toggleSelected(contact);
              } else {
                _enterSelection(contact);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if (_selectionMode && selectable) ...[
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: selected ? accent : colors.mutedText,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(15),
                      image: hasPhoto
                          ? DecorationImage(
                              image: FileImage(File(contact.photoPath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: hasPhoto
                        ? null
                        : AvatarInitial(
                            initialFor(contact.firstName),
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                contact.displayName(_nameFormat),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (contact.isFavorite) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                            ],
                            if (contact.isEphemeral) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  contact.ephemeralAutoDeleteCall
                                      ? '⏱️ 1-Call'
                                      : '⏱️ Ephemeral',
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                            if (contact.isSelf) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'YOU',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: AppTheme.contrastOn(accent),
                                  ),
                                ),
                              ),
                            ] else if (contact.groups.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  contact.groups.first,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                metaParts.join('  ·  '),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: colors.mutedText,
                                ),
                              ),
                            ),
                            if (streak >= 3) ...[
                              const SizedBox(width: 7),
                              const Icon(
                                Icons.local_fire_department,
                                size: 13,
                                color: Color(0xFFF97316),
                              ),
                              Text(
                                '$streak',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF97316),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: mood.soft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _moodIcon(contact.relationshipScore),
                          color: mood.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${contact.relationshipScore.toInt()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: mood.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              // The Self card can't be called or emailed (it's the phone owner),
              // so it only offers Profile; other contacts get the full row.
              child: contact.isSelf
                  ? Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.person_outline,
                            label: 'Profile',
                            filled: true,
                            onTap: () => _openContact(contact),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.call,
                            label: 'Call',
                            filled: true,
                            onTap: () => _quickCall(contact),
                            onLongPress: () => _pickNumberAndCall(contact),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.person_outline,
                            label: 'Profile',
                            filled: false,
                            onTap: () => _openContact(contact),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.mail_outline,
                            label: 'Email',
                            filled: false,
                            enabled: _primaryEmail(contact) != null,
                            onTap: () => _quickEmail(contact),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.delete_outline,
                            label: 'Delete',
                            filled: false,
                            onTap: () => _confirmDelete(contact),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(AppColors colors) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: colors.brandGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.gradientStart.withValues(alpha: 0.7),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _addContact,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  IconData _moodIcon(double score) {
    if (score >= 75) return Icons.sentiment_very_satisfied;
    if (score >= 50) return Icons.sentiment_satisfied;
    if (score >= 25) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  String _relativeTime(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(when.year, when.month, when.day);
    final dayDiff = today.difference(thatDay).inDays;
    if (dayDiff <= 0) return 'Today';
    if (dayDiff == 1) return 'Yesterday';
    if (dayDiff < 7) return '${dayDiff}d ago';
    if (dayDiff < 30) return '${(dayDiff / 7).floor()}w ago';
    if (dayDiff < 365) return '${(dayDiff / 30).floor()}mo ago';
    return '${(dayDiff / 365).floor()}y ago';
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;

  /// Used as the tooltip / accessibility label — the button itself is icon-only.
  final String label;
  final bool filled;

  /// When false the button is dimmed and non-interactive (e.g. Email with no
  /// address on the contact).
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
    this.enabled = true,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bg = filled ? accent : accent.withValues(alpha: 0.1);
    final fg = filled ? AppTheme.contrastOn(accent) : accent;
    final button = Material(
      color: bg,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Icon(icon, size: 19, color: fg),
        ),
      ),
    );
    return Tooltip(
      message: label,
      child: Opacity(opacity: enabled ? 1.0 : 0.4, child: button),
    );
  }
}

/// A selectable filter pill (All / ★ Favorites) for the contacts list. Selected
/// styling matches the bottom-nav pill: soft accent fill with accent text; the
/// star (when present) uses the app's amber favorite color while selected.
class _FilterChipPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipPill({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final colors = Theme.of(context).extension<AppColors>()!;
    final fg = selected ? accent : colors.mutedText;

    return Material(
      color: selected ? accent.withValues(alpha: 0.16) : colors.searchFill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: selected ? Colors.amber : fg),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row in the contact list that is an alphabetical section header rather than
/// a contact. [count] is the full group size (from the section-count query) or
/// null when it is not yet known (e.g. the transient first-run view).
class _SectionHeader {
  const _SectionHeader(this.letter, this.count);
  final String letter;
  final int? count;
}
