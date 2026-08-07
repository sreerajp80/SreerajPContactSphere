import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:smart_contacts_dialer/models/call_summary.dart';
import 'package:smart_contacts_dialer/utils/filename_utils.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';
import 'package:smart_contacts_dialer/repositories/relationship_repository.dart';
import 'package:smart_contacts_dialer/services/connected_apps_service.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/ephemeral_contact_service.dart';
import 'package:smart_contacts_dialer/services/pre_call_summary_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';
import 'package:smart_contacts_dialer/widgets/avatar_initial.dart';
import 'package:smart_contacts_dialer/widgets/call_lifecycle_mixin.dart';
import 'package:smart_contacts_dialer/widgets/ble_share_dialog.dart';
import 'package:smart_contacts_dialer/widgets/qr_share_dialog.dart';
import 'package:smart_contacts_dialer/widgets/relationship_editor.dart';
import 'package:smart_contacts_dialer/widgets/screenshot_guard_mixin.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/screens/relationship_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final int contactId;

  const ContactDetailScreen({super.key, required this.contactId});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen>
    with
        WidgetsBindingObserver,
        CallLifecycleMixin<ContactDetailScreen>,
        ScreenshotGuard<ContactDetailScreen> {
  final _repository = ContactRepository();
  final _sync = ContactSyncService();
  final _summaryService = PreCallSummaryService();
  final _relationships = RelationshipRepository();

  Contact? _contact;
  CallSummary? _summary;
  bool _loading = true;

  // Third-party apps (WhatsApp, Telegram, …) that know this contact, read
  // from the Android contacts provider. Empty for local-only contacts.
  final _connectedAppsService = ConnectedAppsService();
  List<ConnectedApp> _connectedApps = const [];

  // In-app preview of the contact's ringtone (native player, not the OS ringer).
  final TelecomService _telecom = TelecomService();
  bool _previewPlaying = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    // Stop any native preview still looping.
    _telecom.stopRingtonePreview();
    super.dispose();
  }

  /// Plays/stops an in-app preview of the contact's ringtone [path] through the
  /// native player, on the ring stream at ring volume — exactly like an actual
  /// call. Preview only — it does not set the OS incoming-call ringer.
  Future<void> _toggleRingtonePreview(String path) async {
    if (_previewPlaying) {
      await _telecom.stopRingtonePreview();
      if (mounted) setState(() => _previewPlaying = false);
      return;
    }
    switch (await _telecom.previewRingtone(path)) {
      case RingtonePreviewStatus.missing:
        // The tone's backing file is gone; this screen is read-only, so point
        // the user at Edit instead of silently rewriting the contact.
        _showSnack(
          'This ringtone is no longer available — pick a new one in Edit.',
        );
        return;
      case RingtonePreviewStatus.muted:
        _showSnack('Ring volume is muted — turn it up to hear the preview.');
      case RingtonePreviewStatus.playing:
        break;
    }
    if (mounted) setState(() => _previewPlaying = true);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Share entry point: lets the user pick the format — a `.vcf` file (opens
  /// the system share sheet), plain text (name and numbers), copying to clipboard,
  /// a QR code, or a direct Bluetooth transfer to a nearby ContactSphere.
  Future<void> _share() async {
    final contact = _contact;
    if (contact == null) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.contact_page_outlined),
              title: const Text('Share as vCard (.vcf)'),
              subtitle: const Text('Send the contact card to WhatsApp or any app'),
              onTap: () => Navigator.of(sheetCtx).pop('vcf'),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Share as Text'),
              subtitle: const Text('Send name & phone numbers as a text message'),
              onTap: () => Navigator.of(sheetCtx).pop('text'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Copy Name & Phone'),
              subtitle: const Text('Copy contact details to clipboard'),
              onTap: () => Navigator.of(sheetCtx).pop('copy'),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2),
              title: const Text('Share as QR code'),
              subtitle: const Text(
                'Show a scannable code or send it as an image',
              ),
              onTap: () => Navigator.of(sheetCtx).pop('qr'),
            ),
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: const Text('Share via Bluetooth'),
              subtitle: const Text('Send directly to a nearby phone'),
              onTap: () => Navigator.of(sheetCtx).pop('ble'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'vcf':
        await _shareVcf(contact);
      case 'text':
        await _shareText(contact);
      case 'copy':
        await _copyContactDetails(contact);
      case 'qr':
        await showQrShareDialog(context, contact);
      case 'ble':
        await showBleShareDialog(context, contact);
    }
  }

  /// Writes the contact (photo included) as a standard vCard 3.0 file to the temp dir and
  /// opens the system share sheet (compatible with WhatsApp, Telegram, and address books).
  Future<void> _shareVcf(Contact contact) async {
    try {
      final vcf = VCardService().toVCard(contact, externalShare: true);
      final dir = await getTemporaryDirectory();
      final safeName = sanitizeFileName(contact.fullName);
      final file = File(p.join(dir.path, '$safeName.vcf'));
      await file.writeAsString(vcf);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/octet-stream')],
          subject: contact.fullName,
        ),
      );
    } catch (e) {
      _showSnack('Could not share contact: $e');
    }
  }

  /// Formats contact name and phone numbers into clean shareable text.
  String _formatContactText(Contact contact) {
    final buffer = StringBuffer();
    buffer.writeln(contact.fullName);
    for (final ph in contact.phoneNumbers) {
      final label = ph.label != null && ph.label!.isNotEmpty ? ' (${ph.label})' : '';
      buffer.writeln('${ph.number}$label');
    }
    return buffer.toString().trim();
  }

  /// Shares name & phone numbers as plain text via system share sheet.
  Future<void> _shareText(Contact contact) async {
    try {
      final text = _formatContactText(contact);
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: contact.fullName,
        ),
      );
    } catch (e) {
      _showSnack('Could not share text: $e');
    }
  }

  /// Copies contact name and phone numbers to system clipboard.
  Future<void> _copyContactDetails(Contact contact) async {
    try {
      final text = _formatContactText(contact);
      await Clipboard.setData(ClipboardData(text: text));
      _showSnack('Contact details copied to clipboard');
    } catch (e) {
      _showSnack('Could not copy contact details: $e');
    }
  }

  /// Copies a single phone number to system clipboard.
  Future<void> _copyPhoneNumber(String number) async {
    try {
      await Clipboard.setData(ClipboardData(text: number));
      _showSnack('Copied $number to clipboard');
    } catch (e) {
      _showSnack('Could not copy number: $e');
    }
  }

  /// The mixin calls this after a placed call is reconciled and feedback saved;
  /// refresh the summary card and score with whatever we captured.
  @override
  void onCallReconciled() => _load();

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final contact = await _repository.getContactById(widget.contactId);
      CallSummary? summary;
      if (contact != null) {
        summary = await _summaryService.getPreCallSummary(widget.contactId);
      }
      if (!mounted) return;
      setState(() {
        _contact = contact;
        _summary = summary;
        _loading = false;
      });
      if (contact != null && contact.isEphemeral) {
        _startTicker();
      } else {
        _ticker?.cancel();
      }
      // Fetched after the first paint so a slow provider query can't hold up
      // the screen; the section simply appears when results arrive.
      final deviceId = contact?.deviceId;
      if (deviceId != null && deviceId.isNotEmpty) {
        _loadConnectedApps(deviceId);
      } else if (_connectedApps.isNotEmpty) {
        setState(() => _connectedApps = const []);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load contact: $e')));
    }
  }

  /// Refreshes the connected-apps rows for the linked device contact.
  Future<void> _loadConnectedApps(String deviceId) async {
    final apps = await _connectedAppsService.fetchConnectedApps(deviceId);
    if (!mounted) return;
    setState(() => _connectedApps = apps);
  }

  /// Opens the tapped action (chat, call, …) in its owning app.
  Future<void> _openConnectedAppAction(ConnectedAppAction action) async {
    if (!await _connectedAppsService.openAction(action)) {
      _showSnack('Could not open this app.');
    }
  }

  /// Places a call to [number] via the shared [CallLifecycleMixin], which logs
  /// the call, reconciles its real outcome on resume, then shows the post-call
  /// feedback sheet and re-scores the relationship.
  Future<void> _call(String number) {
    return startCall(
      contactId: widget.contactId,
      number: number,
      displayName: _contact?.fullName ?? number,
    );
  }

  /// Stars/unstars this contact so it appears in (or drops from) the dialer's
  /// Favorites list. Optimistically flips the local flag, then persists.
  Future<void> _toggleFavorite() async {
    final contact = _contact;
    final id = contact?.id;
    if (contact == null || id == null) return;
    final next = !contact.isFavorite;
    setState(() => contact.isFavorite = next);
    try {
      await _repository.setFavorite(id, next);
    } catch (e) {
      if (!mounted) return;
      setState(() => contact.isFavorite = !next); // revert on failure
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update favorite: $e')));
    }
  }

  Future<void> _edit() async {
    final contact = _contact;
    if (contact == null) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEditContactScreen(contact: contact)),
    );
    if (saved == true) _load();
  }

  /// Confirms, then deletes the contact from the app and — when it is linked to
  /// a device contact — from the device address book too (via
  /// [ContactSyncService]). Pops back to the list on success.
  Future<void> _delete() async {
    final contact = _contact;
    if (contact == null) return;
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
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _openSphere() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RelationshipScreen(focusContactId: widget.contactId),
      ),
    );
    _load(); // relationships may have changed in the sphere
  }

  Future<void> _addRelationship() async {
    final existing = (_contact?.relationships ?? const <RelatedContact>[])
        .map((r) => r.contactId)
        .toSet();
    final choice = await showRelationshipEditor(
      context,
      ownerContactId: widget.contactId,
      excludeIds: existing,
    );
    if (choice == null) return;
    await _relationships.setRelationship(
      contactId: widget.contactId,
      relatedContactId: choice.relatedContactId,
      type: choice.type,
    );
    _load();
  }

  Future<void> _removeRelationship(RelatedContact r) async {
    await _relationships.removeRelationship(
      contactId: widget.contactId,
      relatedContactId: r.contactId,
    );
    _load();
  }

  Future<void> _editRelationship(RelatedContact r) async {
    final newType = await showRelationshipTypePicker(
      context,
      personName: r.firstName,
      currentType: r.relationshipType,
    );
    if (newType == null || newType == r.relationshipType) return;
    await _relationships.setRelationship(
      contactId: widget.contactId,
      relatedContactId: r.contactId,
      type: newType,
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final contact = _contact;
    return Scaffold(
      appBar: AppBar(
        title: Text(contact?.fullName ?? 'Contact'),
        actions: [
          if (contact != null)
            IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: contact.isFavorite ? Colors.amber : null,
              ),
              tooltip: contact.isFavorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              onPressed: _toggleFavorite,
            ),
          if (contact != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share',
              onPressed: _share,
            ),
          if (contact != null)
            IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          if (contact != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _delete,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : contact == null
          ? const Center(child: Text('Contact not found'))
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                if (contact.isEphemeral) _buildEphemeralBanner(contact),
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage:
                        (contact.photoPath != null &&
                            File(contact.photoPath!).existsSync())
                        ? FileImage(File(contact.photoPath!))
                        : null,
                    child:
                        (contact.photoPath == null ||
                            !File(contact.photoPath!).existsSync())
                        ? AvatarInitial(
                            initialFor(contact.firstName),
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    contact.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (contact.cardPhotoPath != null &&
                    File(contact.cardPhotoPath!).existsSync())
                  _buildCallingCard(contact.cardPhotoPath!),
                if (_summary != null) _buildSummaryCard(_summary!),
                if (_connectedApps.isNotEmpty) _buildConnectedApps(),
                ...contact.phoneNumbers.map(
                  (ph) => ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(ph.number),
                    subtitle: ph.label != null ? Text(ph.label!) : null,
                    onLongPress: () => _copyPhoneNumber(ph.number),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: () => _call(ph.number),
                    ),
                  ),
                ),
                ...contact.emails.map(
                  (e) => ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(e.email),
                    subtitle: e.label != null ? Text(e.label!) : null,
                  ),
                ),
                ...contact.socialLinks.map(
                  (s) => ListTile(
                    leading: const Icon(Icons.link),
                    title: Text(s.value),
                    subtitle: (s.label != null && s.label!.isNotEmpty)
                        ? Text(s.label!)
                        : null,
                  ),
                ),
                // An address whose every field is blank has nothing to show —
                // skip it rather than render a tile with only the type label.
                ...contact.addresses
                    .where((a) => a.formatted.isNotEmpty)
                    .map(
                      (a) => ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(a.formatted),
                        subtitle: Text(a.type),
                      ),
                    ),
                if (contact.dob != null)
                  ListTile(
                    leading: const Icon(Icons.cake_outlined),
                    title: Text(_formatDate(contact.dob!)),
                    subtitle: const Text('Birthday'),
                  ),
                if (contact.anniversary != null)
                  ListTile(
                    leading: const Icon(Icons.favorite_outline),
                    title: Text(_formatDate(contact.anniversary!)),
                    subtitle: const Text('Anniversary'),
                  ),
                if (contact.meetiversary != null)
                  ListTile(
                    leading: const Icon(Icons.handshake_outlined),
                    title: Text(_formatDate(contact.meetiversary!)),
                    subtitle: const Text('Meetiversary'),
                  ),
                if (contact.gender != null && contact.gender!.trim().isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(contact.gender!),
                    subtitle: const Text('Gender'),
                  ),
                if (contact.formalName != null &&
                    contact.formalName!.trim().isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: Text(contact.formalName!),
                    subtitle: const Text('Formal name'),
                  ),
                if (contact.bloodGroup != null &&
                    contact.bloodGroup!.trim().isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.bloodtype_outlined),
                    title: Text(contact.bloodGroup!),
                    subtitle: const Text('Blood group'),
                  ),
                if (contact.ringtonePath != null)
                  ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(contact.ringtoneLabel ?? 'Custom ringtone'),
                    subtitle: const Text('Ringtone'),
                    trailing: IconButton(
                      icon: Icon(
                        _previewPlaying ? Icons.stop : Icons.play_arrow,
                      ),
                      tooltip: _previewPlaying ? 'Stop' : 'Preview',
                      onPressed: () =>
                          _toggleRingtonePreview(contact.ringtonePath!),
                    ),
                  ),
                if (contact.officialDetails != null)
                  ListTile(
                    leading: const Icon(Icons.work),
                    title: Text(contact.officialDetails!.designation ?? '—'),
                    subtitle: Text(contact.officialDetails!.department ?? ''),
                  ),
                if (contact.groups.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      spacing: 6,
                      children: contact.groups
                          .map((g) => Chip(label: Text(g)))
                          .toList(),
                    ),
                  ),
                // Tags are free-text labels, distinct from group memberships —
                // prefixed with '#' so the two chip rows read differently.
                if (contact.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      spacing: 6,
                      children: contact.tags
                          .map((t) => Chip(label: Text('#$t')))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 8),
                _buildRelationships(contact),
              ],
            ),
    );
  }

  /// The contact's "calling card" image — tap to open a zoomable full-screen
  /// viewer.
  Widget _buildCallingCard(String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              'Calling card',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          // A small phone-shaped thumbnail — just a representation. Tapping it opens
          // the image full-screen (matching the in-call backdrop size).
          GestureDetector(
            onTap: () => _openImageFullScreen(path),
            child: SizedBox(
              width: 150,
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(path), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens [path] full-screen over a black backdrop with pinch/pan zoom.
  void _openImageFullScreen(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(File(path)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelationships(Contact contact) {
    final relations = contact.relationships;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Relationships',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            if (relations.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.hub_outlined),
                tooltip: 'View sphere',
                onPressed: _openSphere,
              ),
            IconButton(
              icon: const Icon(Icons.add_link),
              tooltip: 'Add relationship',
              onPressed: _addRelationship,
            ),
          ],
        ),
        if (relations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No relationships yet. Tap the link icon to connect a contact.',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          )
        else
          ...relations.map(
            (r) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.people_alt_outlined),
              title: Text(r.fullName),
              subtitle: Text(r.relationshipType),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      RelationshipScreen(focusContactId: r.contactId),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit type',
                    onPressed: () => _editRelationship(r),
                  ),
                  IconButton(
                    icon: const Icon(Icons.link_off),
                    tooltip: 'Remove',
                    onPressed: () => _removeRelationship(r),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _formatDate(DateTime d) =>
      '${d.day} ${_monthNames[d.month - 1]} ${d.year}';

  /// Third-party apps that know this contact, one expandable row per app with
  /// its launchable actions (labels come from each app, already localized).
  Widget _buildConnectedApps() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Connected apps',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ..._connectedApps.map(
            (app) => ExpansionTile(
              leading: app.icon != null
                  ? Image.memory(
                      app.icon!,
                      width: 32,
                      height: 32,
                      gaplessPlayback: true,
                    )
                  : const Icon(Icons.apps),
              title: Text(app.name),
              // No divider lines above/below the expanded tile.
              shape: const Border(),
              collapsedShape: const Border(),
              children: app.actions
                  .map(
                    (a) => ListTile(
                      contentPadding: const EdgeInsets.only(
                        left: 72,
                        right: 16,
                      ),
                      title: Text(a.label),
                      onTap: () => _openConnectedAppAction(a),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(CallSummary summary) {
    final lines = <String>[
      if (summary.upcomingBirthday) '🎂 Birthday coming up within a week',
      // Measured from this contact's own call history; absent when the app has
      // too little to go on. Advice only — the user still places the call.
      if (summary.bestTimeToReach != null) summary.bestTimeToReach!.sentence,
      if (summary.lastCallDuration != null)
        'Last call: ${summary.lastCallDuration}s',
      if (summary.currentTimeInContactTimezone != null)
        'Their time: ${summary.currentTimeInContactTimezone}',
      '${summary.recentInteractions.length} recent interaction(s)',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Before you call',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...lines.map(Text.new),
          ],
        ),
      ),
    );
  }

  Widget _buildEphemeralBanner(Contact contact) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    String countdownText = '';
    if (contact.ephemeralAutoDeleteCall) {
      countdownText = 'Auto-deletes after 1 call (${contact.ephemeralCallCount}/1 calls logged)';
    } else if (contact.ephemeralExpiresAt != null) {
      final diff = contact.ephemeralExpiresAt!.difference(DateTime.now());
      if (diff.isNegative) {
        countdownText = 'Expired — self-destructing soon...';
      } else {
        final hours = diff.inHours.toString().padLeft(2, '0');
        final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
        countdownText = 'Self-destructs in: ${hours}h ${minutes}m ${seconds}s';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.amber.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade700, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ephemeral Contact',
                  style: TextStyle(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SQLCipher Local Only',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              countdownText,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_alarm, size: 16),
                  label: const Text('+24 Hours'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.amber.shade900,
                    side: BorderSide(color: Colors.amber.shade700),
                  ),
                  onPressed: () async {
                    if (contact.id == null) return;
                    await EphemeralContactService().extendExpiry(contact.id!, const Duration(hours: 24));
                    _load();
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.lock_open, size: 16),
                  label: const Text('Keep Permanently'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: accent,
                  ),
                  onPressed: () async {
                    if (contact.id == null) return;
                    await EphemeralContactService().makePermanent(contact.id!);
                    _load();
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_forever, size: 16),
                  label: const Text('Scrub Now'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: () async {
                    if (contact.id == null) return;
                    await EphemeralContactService().scrubEphemeralContact(contact.id!);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && (_contact?.isEphemeral ?? false)) {
        setState(() {});
      }
    });
  }
}
