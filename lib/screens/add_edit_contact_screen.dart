// lib/screens/add_edit_contact_screen.dart
//
// Redesigned Add / Edit contact screen. Adapted from
// sample/AddContactScreen.dc.html — a custom-styled form with a sticky avatar
// header and sectioned, label-on-top fields. Light/dark follow the app's Calm
// and Midnight themes via [AppColors] + ColorScheme (no hardcoded palette).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:smart_contacts_dialer/core/constants/blood_groups.dart';
import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/official_details.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/models/sim_account.dart';
import 'package:smart_contacts_dialer/models/social_link.dart';
import 'package:smart_contacts_dialer/repositories/group_repository.dart';
import 'package:smart_contacts_dialer/repositories/relationship_repository.dart';
import 'package:smart_contacts_dialer/services/contact_sync_service.dart';
import 'package:smart_contacts_dialer/services/ephemeral_contact_service.dart';
import 'package:smart_contacts_dialer/services/permission_service.dart';
import 'package:smart_contacts_dialer/services/sim_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';
import 'package:smart_contacts_dialer/widgets/relationship_editor.dart';

/// Design tokens resolved from the active theme so the screen renders the same
/// in Calm (light) and Midnight (dark).
class _Tokens {
  final Color bg;
  final Color field;
  final Color fieldBorder;
  final Color text;
  final Color sub;
  final Color caption;
  final Color accent;
  final Color accentSoft;
  final Color accentText;
  final Color onAccent;
  final Gradient avatar;
  final List<BoxShadow> avatarShadow;
  final Color trackOff;

  const _Tokens({
    required this.bg,
    required this.field,
    required this.fieldBorder,
    required this.text,
    required this.sub,
    required this.caption,
    required this.accent,
    required this.accentSoft,
    required this.accentText,
    required this.onAccent,
    required this.avatar,
    required this.avatarShadow,
    required this.trackOff,
  });

  factory _Tokens.of(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final scheme = theme.colorScheme;
    final isDark = colors.isDark;
    final accent = scheme.primary;
    final accentText = _shiftLightness(accent, isDark ? 0.12 : -0.06);

    return _Tokens(
      bg: theme.scaffoldBackgroundColor,
      field: isDark ? Colors.white.withValues(alpha: 0.045) : Colors.white,
      fieldBorder: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : const Color(0xFF0F2A28).withValues(alpha: 0.16),
      text: scheme.onSurface,
      sub: colors.mutedText,
      caption: colors.mutedText.withValues(alpha: 0.85),
      accent: accent,
      accentSoft: accent.withValues(alpha: isDark ? 0.15 : 0.10),
      accentText: accentText,
      onAccent: AppTheme.contrastOn(accent),
      avatar: colors.brandGradient,
      avatarShadow: [
        BoxShadow(
          color: accent.withValues(alpha: isDark ? 0.55 : 0.45),
          blurRadius: 30,
          offset: const Offset(0, 14),
        ),
      ],
      trackOff: isDark
          ? Colors.white.withValues(alpha: 0.16)
          : const Color(0xFF0F2A28).withValues(alpha: 0.16),
    );
  }

  static Color _shiftLightness(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }
}

/// Create a new contact (pass no [contact]) or edit an existing one.
class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;

  /// Pre-fills the first phone field when creating a new contact (i.e. when
  /// [contact] is null). Used by the dialer's "Add to contacts" action to carry
  /// the typed number into the form. Ignored when editing an existing contact.
  final String? initialNumber;

  /// Pre-enables the "This is me" (Self) toggle when creating a new contact
  /// (i.e. when [contact] is null). Used by the contact list's "My Profile"
  /// action to start creating the phone owner's own record. Ignored when
  /// editing an existing contact (its own [Contact.isSelf] is used instead).
  final bool initialIsSelf;

  const AddEditContactScreen({
    super.key,
    this.contact,
    this.initialNumber,
    this.initialIsSelf = false,
  });

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _sync = ContactSyncService();
  final _groupRepository = GroupRepository();
  final _relationshipRepository = RelationshipRepository();
  final _picker = ImagePicker();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _phoneLabels = [
    'Mobile',
    'Home',
    'Work',
    'Main',
    'iPhone',
    'Fax',
    'Other',
  ];
  static const _emailLabels = ['Personal', 'Home', 'Work', 'School', 'Other'];
  static const _socialLabels = [
    'LinkedIn',
    'X (Twitter)',
    'Instagram',
    'Facebook',
    'GitHub',
    'Website',
  ];
  static const _genderLabels = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];
  static const _tagPool = [
    'VIP',
    'Mentor',
    'Client',
    'Investor',
    'Neighbor',
    'Family',
  ];

  late final TextEditingController _salutation;
  late final TextEditingController _firstName;
  late final TextEditingController _middleName;
  late final TextEditingController _lastName;
  late final TextEditingController _formalName;
  late final TextEditingController _designation;
  late final TextEditingController _department;

  // Work (official) address.
  late final TextEditingController _workCompany;
  late final TextEditingController _workStreet;
  late final TextEditingController _workCity;
  late final TextEditingController _workState;
  late final TextEditingController _workPostal;
  late final TextEditingController _workCountry;

  late final TextEditingController _tagInput;
  late final TextEditingController _groupInput;

  final List<_LabeledEntry> _phones = [];
  final List<_LabeledEntry> _emails = [];
  final List<_LabeledEntry> _socials = [];
  final List<_AddressEntry> _addresses = [];
  final List<String> _tags = [];
  // Distinct tag names already used across contacts, loaded once for
  // autocomplete suggestions as the user types.
  final List<String> _allTags = [];
  final List<_GroupChip> _groups = [];

  /// Home country (ISO alpha-2) that seeds new phone rows' country chip and
  /// interprets bare national numbers. Starts at a provisional default and is
  /// replaced by the user's persisted Default country in [_loadHomeCountry].
  String _homeCountryIso = 'US';

  /// Original ([raw]) and last-derived national ([derived]) values for each
  /// phone row, keyed by entry id — lets [_loadHomeCountry] re-split rows the
  /// user hasn't edited once the real home country is known.
  final Map<int, ({String raw, String derived})> _phoneSeeds = {};

  /// Pending relationships shown in the form. Persisted on save once the
  /// contact's id is known (a new contact has none until [insertContact]).
  final List<_PendingRel> _relations = [];

  /// Related-contact ids present when the form opened — used on save to detect
  /// which links the user removed.
  final Set<int> _originalRelationIds = {};

  // Blood group single-value picker. Empty means "not set". A value saved
  // before the picker existed that cannot be cleaned up is kept as-is and
  // offered as an extra chip, so editing a contact never drops it.
  String _bloodGroup = '';
  String? _bloodGroupLegacy;
  bool _bloodMenuOpen = false;

  // Gender single-value picker.
  String _gender = '';
  bool _genderCustom = false;
  bool _genderMenuOpen = false;
  late final TextEditingController _genderText;

  DateTime? _dob;
  DateTime? _anniversary;
  DateTime? _meetiversary;

  String? _photoPath;
  String? _cardPhotoPath;
  String? _ringtonePath;
  String? _ringtoneLabel;

  /// The SIM this contact should be called on (Telecom `phoneAccountId`), or
  /// null for "use the default SIM". The section is only built when the phone
  /// reports two or more SIMs — on a single-SIM phone the choice is meaningless.
  String? _preferredSimId;
  String? _preferredSimLabel;

  /// SIMs found on the phone, loaded once in [initState]. Empty until it
  /// returns, and empty for good off Android or without the phone permission.
  List<SimAccount> _sims = const [];

  // In-app preview of the picked ringtone (native player, not the OS ringer).
  final TelecomService _telecom = TelecomService();
  bool _previewPlaying = false;

  bool _isSecret = false;
  bool _isSelf = false;
  bool _isEphemeral = false;
  EphemeralExpiryOption _ephemeralOption = EphemeralExpiryOption.twentyFourHours;
  bool _saving = false;
  bool _firstNameInvalid = false;

  int _idSeq = 0;
  int _nextId() => ++_idSeq;

  late _Tokens _t;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;

    _salutation = TextEditingController(text: c?.salutation ?? '');
    _firstName = TextEditingController(text: c?.firstName ?? '');
    _middleName = TextEditingController(text: c?.middleName ?? '');
    _lastName = TextEditingController(text: c?.lastName ?? '');
    _formalName = TextEditingController(text: c?.formalName ?? '');
    _designation = TextEditingController(
      text: c?.officialDetails?.designation ?? '',
    );
    _department = TextEditingController(
      text: c?.officialDetails?.department ?? '',
    );
    _tagInput = TextEditingController();
    // Rebuild the tag suggestions as the user types.
    _tagInput.addListener(_onTagInputChanged);
    _groupInput = TextEditingController();
    // Rebuild the group suggestions as the user types.
    _groupInput.addListener(_onTagInputChanged);
    _genderText = TextEditingController();

    // Blood group. Anything the cleaner cannot read is kept verbatim so an old
    // hand-typed value survives an edit; the picker shows it as an extra chip.
    final blood = c?.bloodGroup?.trim() ?? '';
    if (blood.isNotEmpty) {
      final standard = normalizeBloodGroup(blood);
      _bloodGroup = standard ?? blood;
      if (standard == null) _bloodGroupLegacy = blood;
    }

    // Gender.
    final gender = c?.gender?.trim() ?? '';
    if (gender.isNotEmpty) {
      if (_genderLabels.contains(gender)) {
        _gender = gender;
      } else {
        _genderCustom = true;
        _gender = gender;
        _genderText.text = gender;
      }
    }

    _dob = c?.dob;
    _anniversary = c?.anniversary;
    _meetiversary = c?.meetiversary;

    // Work address (type == 'official').
    final workAddr = _firstWhereOrNull(
      c?.addresses ?? const <Address>[],
      (a) => a.type == 'official',
    );
    _workCompany = TextEditingController(text: workAddr?.companyName ?? '');
    _workStreet = TextEditingController(text: workAddr?.street ?? '');
    _workCity = TextEditingController(text: workAddr?.cityTown ?? '');
    _workState = TextEditingController(text: workAddr?.state ?? '');
    _workPostal = TextEditingController(text: workAddr?.postalCode ?? '');
    _workCountry = TextEditingController(text: workAddr?.country ?? '');

    // Personal addresses (type == 'personal') — one card each.
    final personalAddrs = (c?.addresses ?? const <Address>[]).where(
      (a) => a.type == 'personal',
    );
    for (final a in personalAddrs) {
      _addresses.add(_AddressEntry.fromAddress(_nextId(), a));
    }
    if (_addresses.isEmpty) _addresses.add(_AddressEntry(_nextId()));

    // Phones / emails / socials.
    if (c != null) {
      for (final ph in c.phoneNumbers) {
        _phones.add(_buildPhone(ph.label, ph.number, ph.isPrimary));
      }
      for (final e in c.emails) {
        _emails.add(
          _LabeledEntry.from(
            _nextId(),
            _emailLabels,
            e.label,
            e.email,
            e.isPrimary,
          ),
        );
      }
      // Primary is now positional (row 0). Move the stored primary to the front
      // so its colour highlight lands on the right row and edits round-trip.
      _movePrimaryFirst(_phones);
      _movePrimaryFirst(_emails);
      for (final s in c.socialLinks) {
        _socials.add(
          _LabeledEntry.from(_nextId(), _socialLabels, s.label, s.value, false),
        );
      }
      _tags.addAll(c.tags);
      for (final r in c.relationships) {
        _relations.add(
          _PendingRel(
            contactId: r.contactId,
            name: r.fullName,
            type: r.relationshipType,
            category: r.category,
          ),
        );
        _originalRelationIds.add(r.contactId);
      }
    }
    if (_phones.isEmpty) {
      // Seed the typed number from the dialer's "Add to contacts" action (only
      // when creating a new contact — an edit already has its phones above).
      final seed = c == null ? (widget.initialNumber?.trim() ?? '') : '';
      if (seed.isNotEmpty) {
        _phones.add(_buildPhone('Mobile', seed, true));
      } else {
        _phones.add(_LabeledEntry.preset(_nextId(), 'Mobile', isPrimary: true));
      }
    }
    if (_emails.isEmpty) {
      _emails.add(_LabeledEntry.preset(_nextId(), 'Personal', isPrimary: true));
    }
    if (_socials.isEmpty) {
      _socials.add(_LabeledEntry.preset(_nextId(), 'LinkedIn'));
    }

    _photoPath = c?.photoPath;
    _cardPhotoPath = c?.cardPhotoPath;
    _ringtonePath = c?.ringtonePath;
    _ringtoneLabel = c?.ringtoneLabel;
    _preferredSimId = c?.preferredSimId;
    _preferredSimLabel = c?.preferredSimLabel;
    _isSecret = c?.isSecret ?? false;
    _isSelf = c?.isSelf ?? widget.initialIsSelf;
    _isEphemeral = c?.isEphemeral ?? false;
    if (c != null && c.isEphemeral) {
      if (c.ephemeralAutoDeleteCall) {
        _ephemeralOption = EphemeralExpiryOption.autoDeleteCall;
      } else if (c.ephemeralExpiresAt != null) {
        final diff = c.ephemeralExpiresAt!.difference(DateTime.now());
        if (diff.inHours <= 3) {
          _ephemeralOption = EphemeralExpiryOption.twoHours;
        } else if (diff.inDays <= 2) {
          _ephemeralOption = EphemeralExpiryOption.twentyFourHours;
        } else {
          _ephemeralOption = EphemeralExpiryOption.sevenDays;
        }
      }
    }

    _loadGroups();
    _loadHomeCountry();
    _loadTags();
    _loadSims();
  }

  /// Loads the phone's SIMs so the "Preferred SIM" section can be shown. Stays
  /// empty (and the section stays hidden) on a single-SIM phone, off Android, or
  /// without the phone permission.
  Future<void> _loadSims() async {
    List<SimAccount> sims;
    try {
      sims = await SimService().list();
    } catch (_) {
      sims = const [];
    }
    if (!mounted) return;
    setState(() => _sims = sims);
  }

  void _onTagInputChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadTags() async {
    try {
      final all = await _sync.allTagNames();
      if (!mounted) return;
      setState(() {
        _allTags
          ..clear()
          ..addAll(all);
      });
    } catch (_) {
      // Suggestions are optional; leave the pool empty on failure.
    }
  }

  void _onPhoneFieldChanged() {
    if (mounted) setState(() {});
  }

  /// Builds a phone row from a stored/seeded [value], splitting off its country
  /// code (or defaulting to the home country) so the value field holds only the
  /// national number and the chip shows the right dial code. Records the seed so
  /// [_loadHomeCountry] can re-derive it once the real home country is known.
  _LabeledEntry _buildPhone(String? label, String value, bool isPrimary) {
    final entry = _LabeledEntry.from(
      _nextId(),
      _phoneLabels,
      label,
      value,
      isPrimary,
    );
    entry.value.addListener(_onPhoneFieldChanged);
    _applyPhoneSplit(entry, value);
    _phoneSeeds[entry.id] = (raw: value, derived: entry.value.text);
    return entry;
  }

  /// Splits [raw] into a country chip + national number on [entry], defaulting
  /// to the home country when [raw] carries no country code.
  void _applyPhoneSplit(_LabeledEntry entry, String raw) {
    final parts = PhoneNormalizer.split(raw, defaultIso: _homeCountryIso);
    if (parts == null) {
      entry.countryIso = _homeCountryIso;
      return;
    }
    entry.countryIso = parts.iso;
    entry.value.text = parts.national;
  }

  /// Loads the user's persisted Default country and, if it differs from the
  /// provisional one, re-derives untouched phone rows so a bare national number
  /// adopts the correct home country / dial code.
  Future<void> _loadHomeCountry() async {
    final iso = await AppSettings.readDefaultCountryIso();
    if (!mounted || iso == _homeCountryIso) return;
    setState(() {
      _homeCountryIso = iso;
      for (final entry in _phones) {
        final seed = _phoneSeeds[entry.id];
        // Only rows still holding their seeded value (user hasn't edited yet).
        if (seed == null || entry.value.text != seed.derived) continue;
        _applyPhoneSplit(entry, seed.raw);
        _phoneSeeds[entry.id] = (raw: seed.raw, derived: entry.value.text);
      }
    });
  }

  /// Opens the country picker for a phone [entry] and applies the choice.
  Future<void> _pickPhoneCountry(_LabeledEntry entry) async {
    final current = entry.countryIso ?? _homeCountryIso;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CountryPickerSheet(selectedIso: current),
    );
    if (picked == null || !mounted) return;
    setState(() => entry.countryIso = picked);
  }

  /// Dial code shown on a phone row's country chip (e.g. "+91").
  String _dialLabel(_LabeledEntry entry) {
    final iso = entry.countryIso ?? _homeCountryIso;
    return '+${PhoneNormalizer.dialCodeForIso(iso) ?? ''}';
  }

  Future<void> _loadGroups() async {
    final selected = widget.contact?.groups.toSet() ?? <String>{};
    try {
      final all = await _groupRepository.getAllGroups();
      if (!mounted) return;
      setState(() {
        final names = <String>{};
        for (final g in all) {
          names.add(g.name);
          _groups.add(_GroupChip(g.name, selected.contains(g.name)));
        }
        // Selected groups not present in the master list (defensive).
        for (final s in selected) {
          if (!names.contains(s)) _groups.add(_GroupChip(s, true));
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        for (final s in selected) {
          _groups.add(_GroupChip(s, true));
        }
      });
    }
  }

  @override
  void dispose() {
    for (final t in [
      _salutation,
      _firstName,
      _middleName,
      _lastName,
      _formalName,
      _designation,
      _department,
      _workCompany,
      _workStreet,
      _workCity,
      _workState,
      _workPostal,
      _workCountry,
      _tagInput,
      _groupInput,
      _genderText,
    ]) {
      t.dispose();
    }
    for (final e in [..._phones, ..._emails, ..._socials]) {
      e.dispose();
    }
    for (final a in _addresses) {
      a.dispose();
    }
    // Stop any native preview still looping.
    _telecom.stopRingtonePreview();
    super.dispose();
  }

  // ----- actions -------------------------------------------------------------

  /// Picks the contact's profile photo. The image may be shot live or chosen
  /// from the gallery, so this offers Camera as well as Gallery. The result is
  /// copied into the app's documents dir (camera captures land in an evictable
  /// cache) so the path stays valid — see [_persistPhoto].
  Future<void> _pickPhoto() async {
    final source = await _chooseImageSource();
    if (source == null) return;
    if (source == ImageSource.camera && !await _ensureCamera()) return;
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) return;
      final stored = await _persistPhoto(file.path, 'contact_photos', 'photo');
      if (!mounted) return;
      setState(() => _photoPath = stored);
    } catch (e) {
      _showMessage('Could not pick image: $e');
    }
  }

  /// Picks the "calling card" image — the full-screen portrait shown as the
  /// in-call backdrop. It may be shot live or picked, so this offers Camera as
  /// well as Gallery. The picked file is copied into the
  /// app's documents dir (camera captures land in an evictable cache) so the
  /// path stays valid — see [_persistPhoto].
  Future<void> _pickCardPhoto() async {
    final source = await _chooseImageSource();
    if (source == null) return;
    if (source == ImageSource.camera && !await _ensureCamera()) return;
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) return;
      final stored = await _persistPhoto(file.path, 'card_photos', 'card');
      if (!mounted) return;
      setState(() => _cardPhotoPath = stored);
    } catch (e) {
      _showMessage('Could not pick calling card: $e');
    }
  }

  /// Shows the shared Camera / Gallery chooser sheet. Returns the chosen
  /// [ImageSource], or null if the user dismissed the sheet.
  Future<ImageSource?> _chooseImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _t.bg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: _t.accent),
              title: Text('Take photo', style: TextStyle(color: _t.text)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: _t.accent),
              title: Text(
                'Choose from gallery',
                style: TextStyle(color: _t.text),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  /// Requests the runtime CAMERA permission before launching the camera.
  /// `android.permission.CAMERA` is declared in the manifest, so `image_picker`
  /// needs it granted or the capture fails. Shows a message and returns false
  /// when the user denies it.
  Future<bool> _ensureCamera() async {
    final granted = await PermissionService().ensureCamera();
    if (!granted) _showMessage('Camera permission is needed to take a photo.');
    return granted;
  }

  /// Copies a picked/captured image into `<appDocuments>/<subDir>/` under a
  /// timestamped `<prefix>_...` name and returns the stable copy's path (mirrors
  /// DeviceContactService's photo persistence). Falls back to the original path
  /// if the copy fails.
  Future<String> _persistPhoto(
    String sourcePath,
    String subDir,
    String prefix,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photoDir = Directory(p.join(dir.path, subDir));
      if (!await photoDir.exists()) await photoDir.create(recursive: true);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final ext = p.extension(sourcePath).isNotEmpty
          ? p.extension(sourcePath)
          : '.jpg';
      final dest = p.join(photoDir.path, '${prefix}_$stamp$ext');
      await File(sourcePath).copy(dest);
      return dest;
    } catch (_) {
      return sourcePath; // best-effort; keep the original path if copy fails
    }
  }

  void _clearCardPhoto() => setState(() => _cardPhotoPath = null);

  /// Lets the user pick a tone from the phone's built-in ringtones or an audio
  /// file, then stores it on the contact.
  Future<void> _pickRingtone() async {
    final source = await _chooseRingtoneSource();
    if (source == null || !mounted) return;

    String? path;
    String? label;
    try {
      if (source == _RingtoneSource.phone) {
        final tone = await _telecom.pickRingtone(existingUri: _ringtonePath);
        if (tone == null) return;
        path = tone.path;
        label = tone.label;
      } else {
        // Persistable content:// URI (survives restarts without copying the file).
        final file = await _telecom.pickAudioDocument();
        if (file == null) return;
        path = file.path;
        label = file.label;
      }
    } catch (e) {
      _showMessage('Could not pick ringtone: $e');
      return;
    }

    if (!mounted) return;
    await _stopPreview(); // don't keep a replaced tone playing
    setState(() {
      _ringtonePath = path;
      _ringtoneLabel = label;
    });
  }

  /// Bottom-sheet chooser: pick from the phone's ringtones or an audio file.
  /// Returns null if dismissed.
  Future<_RingtoneSource?> _chooseRingtoneSource() {
    return showModalBottomSheet<_RingtoneSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Phone ringtones'),
              subtitle: const Text('Choose from the ringtones on this device'),
              onTap: () => Navigator.pop(sheetContext, _RingtoneSource.phone),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: const Text('Audio file'),
              subtitle: const Text('Pick an audio file from your folders'),
              onTap: () => Navigator.pop(sheetContext, _RingtoneSource.file),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearRingtone() async {
    await _stopPreview();
    setState(() {
      _ringtonePath = null;
      _ringtoneLabel = null;
    });
  }

  /// Plays/stops an in-app preview of the picked ringtone through the native
  /// player, on the ring stream at ring volume — exactly like an actual call.
  /// This is only a preview — it does not set the OS incoming-call ringer.
  Future<void> _toggleRingtonePreview() async {
    final path = _ringtonePath;
    if (path == null) return;
    if (_previewPlaying) {
      await _stopPreview();
      return;
    }
    switch (await _telecom.previewRingtone(path)) {
      case RingtonePreviewStatus.missing:
        // The tone's backing file is gone — revert this tone to default.
        _revertMissingTone();
        return;
      case RingtonePreviewStatus.muted:
        _showMessage('Ring volume is muted — turn it up to hear the preview.');
      case RingtonePreviewStatus.playing:
        break;
    }
    if (mounted) setState(() => _previewPlaying = true);
  }

  /// The picked tone's backing file is gone (deleted/moved, or a lost grant): tell
  /// the user and clear it so the contact falls back to the default (saved on Save).
  void _revertMissingTone() {
    if (!mounted) return;
    setState(() {
      _previewPlaying = false;
      _ringtonePath = null;
      _ringtoneLabel = null;
    });
    _showMessage(
      'This ringtone is no longer available — reverting to default.',
    );
  }

  Future<void> _stopPreview() async {
    if (!_previewPlaying) return;
    await _telecom.stopRingtonePreview();
    if (mounted) setState(() => _previewPlaying = false);
  }

  Future<void> _pickDate(
    DateTime? current,
    ValueChanged<DateTime?> onPick,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => onPick(picked));
  }

  void _toggleMenu(List<_LabeledEntry> list, _LabeledEntry entry) {
    setState(() {
      for (final e in list) {
        e.menuOpen = e == entry && !e.menuOpen;
      }
    });
  }

  void _chooseLabel(_LabeledEntry entry, String label) {
    setState(() {
      entry.label.text = label;
      entry.custom = false;
      entry.menuOpen = false;
    });
  }

  void _enableCustom(_LabeledEntry entry) {
    setState(() {
      entry.custom = true;
      entry.menuOpen = false;
      entry.label.text = '';
    });
  }

  void _addEntry(List<_LabeledEntry> list, String defaultLabel) {
    final entry = _LabeledEntry.preset(_nextId(), defaultLabel);
    if (identical(list, _phones)) {
      entry.value.addListener(_onPhoneFieldChanged);
    }
    setState(() => list.add(entry));
    // Move focus into the new row's value field once it's laid out, so the user
    // can type straight away.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) entry.valueFocus.requestFocus();
    });
  }

  void _removeEntry(List<_LabeledEntry> list, _LabeledEntry entry) {
    setState(() {
      if (identical(list, _phones)) {
        entry.value.removeListener(_onPhoneFieldChanged);
      }
      list.remove(entry);
      entry.dispose();
    });
  }

  /// Moves the entry flagged primary (from loaded data) to the front of [list]
  /// so the positional primary rule and its colour highlight agree with what
  /// was stored. No-op if there's no primary or it's already first.
  void _movePrimaryFirst(List<_LabeledEntry> list) {
    final idx = list.indexWhere((e) => e.isPrimary);
    if (idx > 0) list.insert(0, list.removeAt(idx));
  }

  /// Confirms and removes a repeater row. Invoked from the row's swipe-to-delete
  /// action. [noun] names what's being removed in the prompt (e.g. "phone").
  Future<void> _confirmRemoveEntry(
    List<_LabeledEntry> list,
    _LabeledEntry entry,
    String noun,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove $noun?'),
        content: Text('This $noun will be removed from the contact.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) _removeEntry(list, entry);
  }

  void _addTag([String? value]) {
    final t = (value ?? _tagInput.text).trim();
    if (t.isEmpty) return;
    setState(() {
      final lower = t.toLowerCase();
      // Already added (ignoring case)? Do nothing.
      final alreadyAdded = _tags.any((e) => e.toLowerCase() == lower);
      if (!alreadyAdded) {
        // Reuse the stored casing of a known tag so we keep one canonical
        // spelling (e.g. "Family") instead of whatever the user typed.
        final canonical = _firstWhereOrNull(
          _allTags,
          (e) => e.toLowerCase() == lower,
        );
        _tags.add(canonical ?? t);
      }
      _tagInput.clear();
    });
  }

  /// Selects an existing group (case-insensitive) or creates a new one. Called
  /// from the suggestion chips, the add button, and the enter key.
  void _addGroup([String? value]) {
    final trimmed = (value ?? _groupInput.text).trim();
    if (trimmed.isEmpty) return;
    // `*` is the "list every group" wildcard, not a group name.
    if (trimmed == '*') return;
    setState(() {
      final existing = _firstWhereOrNull(
        _groups,
        (g) => g.name.toLowerCase() == trimmed.toLowerCase(),
      );
      if (existing != null) {
        existing.on = true;
      } else {
        _groups.add(_GroupChip(trimmed, true));
      }
      _groupInput.clear();
    });
  }

  Future<void> _addRelationship() async {
    final exclude = _relations.map((r) => r.contactId).toSet();
    final choice = await showRelationshipEditor(
      context,
      ownerContactId: widget.contact?.id,
      excludeIds: exclude,
    );
    if (choice == null) return;
    setState(() {
      _relations.add(
        _PendingRel(
          contactId: choice.relatedContactId,
          name: choice.relatedContactName,
          type: choice.type,
          category: choice.category,
        ),
      );
    });
  }

  void _removeRelationship(_PendingRel rel) {
    setState(() => _relations.remove(rel));
  }

  /// Reconciles the form's relationships against what was stored when it opened:
  /// removes links the user deleted, then (re)writes the rest. Runs after the
  /// contact id is known. Best-effort — a relationship failure must not lose the
  /// saved contact.
  Future<void> _persistRelationships(int contactId) async {
    try {
      final desired = _relations.map((r) => r.contactId).toSet();
      for (final originalId in _originalRelationIds) {
        if (!desired.contains(originalId)) {
          await _relationshipRepository.removeRelationship(
            contactId: contactId,
            relatedContactId: originalId,
          );
        }
      }
      for (final rel in _relations) {
        await _relationshipRepository.setRelationship(
          contactId: contactId,
          relatedContactId: rel.contactId,
          type: rel.type,
          category: rel.category,
        );
      }
    } catch (_) {
      // Leave whatever persisted; the contact itself is already saved.
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final firstName = _firstName.text.trim();
    if (firstName.isEmpty) {
      setState(() => _firstNameInvalid = true);
      _showMessage('First name is required');
      return;
    }
    setState(() => _saving = true);

    try {
      final contact = (widget.contact ?? Contact(firstName: ''))
        ..salutation = _nullIfEmpty(_salutation.text)
        ..firstName = firstName
        ..middleName = _nullIfEmpty(_middleName.text)
        ..lastName = _nullIfEmpty(_lastName.text)
        ..formalName = _nullIfEmpty(_formalName.text)
        ..bloodGroup = _nullIfEmpty(_bloodGroup)
        ..gender = _genderCustom
            ? _nullIfEmpty(_genderText.text)
            : _nullIfEmpty(_gender)
        ..dob = _dob
        ..anniversary = _anniversary
        // A Self record carries no meetiversary (the field is hidden for it).
        ..meetiversary = _isSelf ? null : _meetiversary
        ..photoPath = _photoPath
        // A Self record carries no calling card (the section is hidden for it).
        ..cardPhotoPath = _isSelf ? null : _cardPhotoPath
        ..ringtonePath = _ringtonePath
        ..ringtoneLabel = _ringtoneLabel
        ..preferredSimId = _preferredSimId
        ..preferredSimLabel = _preferredSimLabel
        ..isSecret = _isSecret
        ..isSelf = _isSelf
        ..isEphemeral = _isEphemeral
        ..ephemeralAutoDeleteCall =
            _isEphemeral && (_ephemeralOption == EphemeralExpiryOption.autoDeleteCall)
        ..ephemeralExpiresAt = (_isEphemeral && _ephemeralOption != EphemeralExpiryOption.autoDeleteCall)
            ? DateTime.now().add(_ephemeralOption.duration!)
            : null;

      // Validate phone numbers:
      for (final p in _phones) {
        if (p.value.text.trim().isNotEmpty) {
          final composed = PhoneNormalizer.compose(
            iso: p.countryIso ?? _homeCountryIso,
            national: p.value.text,
          );
          final res = PhoneNormalizer.validateNumber(
            composed,
            defaultIso: p.countryIso ?? _homeCountryIso,
          );
          if (!res.isPossible && res.errorReason != null) {
            _showMessage('Invalid phone number: ${p.value.text} (${res.errorReason})');
            setState(() => _saving = false);
            return;
          }
        }
      }

      // Primary is positional: the first non-empty entry is primary, the rest
      // are not (isPrimary is true only while the target list is still empty).
      final phones = <PhoneNumber>[];
      for (final p in _phones) {
        final composed = PhoneNormalizer.compose(
          iso: p.countryIso ?? _homeCountryIso,
          national: p.value.text,
        );
        if (composed.isNotEmpty) {
          phones.add(
            PhoneNumber(
              number: composed,
              label: _entryLabel(p),
              type: 'personal',
              isPrimary: phones.isEmpty,
            ),
          );
        }
      }
      contact.phoneNumbers = phones;
      final emails = <Email>[];
      for (final e in _emails) {
        if (e.value.text.trim().isNotEmpty) {
          emails.add(
            Email(
              email: e.value.text.trim(),
              label: _entryLabel(e),
              type: 'personal',
              isPrimary: emails.isEmpty,
            ),
          );
        }
      }
      contact.emails = emails;
      contact.socialLinks = [
        for (final s in _socials)
          if (s.value.text.trim().isNotEmpty)
            SocialLink(value: s.value.text.trim(), label: _entryLabel(s)),
      ];

      final addresses = <Address>[];
      for (final a in _addresses) {
        final addr = a.toAddress();
        if (addr.formatted.isNotEmpty) addresses.add(addr);
      }
      final work = Address(
        type: 'official',
        companyName: _nullIfEmpty(_workCompany.text),
        street: _nullIfEmpty(_workStreet.text),
        cityTown: _nullIfEmpty(_workCity.text),
        state: _nullIfEmpty(_workState.text),
        postalCode: _nullIfEmpty(_workPostal.text),
        country: _nullIfEmpty(_workCountry.text),
      );
      if (work.formatted.isNotEmpty) addresses.add(work);
      contact.addresses = addresses;

      contact.tags = List<String>.from(_tags);
      contact.groups = [
        for (final g in _groups)
          if (g.on) g.name,
      ];

      final official = OfficialDetails(
        designation: _nullIfEmpty(_designation.text),
        department: _nullIfEmpty(_department.text),
      );
      contact.officialDetails = official.isEmpty ? null : official;

      // Routes through the sync service: inserts or updates the app row (id ==
      // null -> insert, e.g. adopting a device-only contact) and applies the
      // two-way / secret device rules. Returns the persisted app contact id.
      final contactId = await _sync.saveContact(contact);
      await _persistRelationships(contactId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showMessage('Save failed: $e');
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _entryLabel(_LabeledEntry e) => _nullIfEmpty(e.label.text);

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ----- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _t = _Tokens.of(context);
    return Scaffold(
      backgroundColor: _t.bg,
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _saving,
          child: Column(
            children: [
              _topBar(),
              _avatarHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  children: [
                    _nameSection(),
                    const SizedBox(height: 22),
                    _personalSection(),
                    const SizedBox(height: 22),
                    _ringtoneSection(),
                    const SizedBox(height: 22),
                    // Only meaningful with 2+ SIMs, and never for your own
                    // record (you don't call yourself).
                    if (_sims.length > 1 && !_isSelf) ...[
                      _preferredSimSection(),
                      const SizedBox(height: 22),
                    ],
                    // The calling card (the in-call full-screen backdrop) is
                    // irrelevant for your own record.
                    if (!_isSelf) ...[
                      _cardPhotoSection(),
                      const SizedBox(height: 22),
                    ],
                    _repeaterSection(
                      title: 'Phone numbers',
                      list: _phones,
                      presets: _phoneLabels,
                      valueHint: '555 0123',
                      keyboardType: TextInputType.phone,
                      hasPrimary: true,
                      defaultLabel: 'Mobile',
                      addLabel: 'Add phone',
                      removeNoun: 'phone',
                      showCountryCode: true,
                    ),
                    const SizedBox(height: 22),
                    _repeaterSection(
                      title: 'Emails',
                      list: _emails,
                      presets: _emailLabels,
                      valueHint: 'name@email.com',
                      keyboardType: TextInputType.emailAddress,
                      hasPrimary: true,
                      defaultLabel: 'Personal',
                      addLabel: 'Add email',
                      removeNoun: 'email',
                    ),
                    const SizedBox(height: 22),
                    _tagsSection(),
                    const SizedBox(height: 22),
                    _groupsSection(),
                    const SizedBox(height: 22),
                    _relationshipsSection(),
                    const SizedBox(height: 22),
                    _repeaterSection(
                      title: 'Social links',
                      list: _socials,
                      presets: _socialLabels,
                      valueHint: 'URL or @handle',
                      keyboardType: TextInputType.url,
                      hasPrimary: false,
                      defaultLabel: 'LinkedIn',
                      addLabel: 'Add social link',
                      removeNoun: 'social link',
                      labelWidth: 128,
                    ),
                    const SizedBox(height: 22),
                    _personalAddressSection(),
                    const SizedBox(height: 22),
                    _workAddressSection(),
                    const SizedBox(height: 22),
                    _officialSection(),
                    const SizedBox(height: 22),
                    _ephemeralSection(),
                    const SizedBox(height: 22),
                    _secretSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIconButton(
            icon: Icons.arrow_back,
            background: Colors.transparent,
            foreground: _t.text,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Text(
            _isSelf
                ? (_isEditing ? 'Edit me' : 'Add me')
                : (_isEditing ? 'Edit contact' : 'Add contact'),
            style: TextStyle(
              color: _t.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          _circleIconButton(
            icon: Icons.check,
            background: _t.accentSoft,
            foreground: _t.accent,
            onTap: _saving ? null : _save,
            size: 48,
            iconSize: 26,
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required Color background,
    required Color foreground,
    VoidCallback? onTap,
    double size = 40,
    double iconSize = 22,
  }) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: foreground),
        ),
      ),
    );
  }

  Widget _avatarHeader() {
    final hasPhoto = _photoPath != null && File(_photoPath!).existsSync();
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 6, 0, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _t.fieldBorder)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _t.avatar,
                    boxShadow: _t.avatarShadow,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasPhoto
                      ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                      : const Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _t.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _t.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, size: 15, color: _t.onAccent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Text(
            hasPhoto ? 'Change photo' : 'Add photo',
            style: TextStyle(
              color: _t.accentText,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ----- sections ------------------------------------------------------------

  Widget _nameSection() {
    return _section('Name', [
      _inputField(
        caption: 'Salutation',
        controller: _salutation,
        hint: 'Mr / Ms / Dr',
      ),
      const SizedBox(height: 10),
      _inputField(
        caption: 'First name *',
        controller: _firstName,
        hint: 'Enter first name',
        error: _firstNameInvalid,
        onChanged: (_) {
          if (_firstNameInvalid) setState(() => _firstNameInvalid = false);
        },
      ),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _inputField(
              caption: 'Middle name',
              controller: _middleName,
              hint: 'Optional',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _inputField(
              caption: 'Last name',
              controller: _lastName,
              hint: 'Optional',
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      _inputField(
        caption: 'Formal name',
        controller: _formalName,
        hint: 'How the contact is formally addressed',
      ),
      const SizedBox(height: 10),
      _bloodGroupField(),
    ]);
  }

  Widget _personalSection() {
    return _section('Personal details', [
      _genderField(),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _dateField(
              caption: 'Date of birth',
              value: _dob,
              onPick: (d) => _dob = d,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _dateField(
              caption: 'Anniversary',
              value: _anniversary,
              onPick: (d) => _anniversary = d,
            ),
          ),
        ],
      ),
      // Meetiversary ("the day you met") is meaningless for your own record.
      if (!_isSelf) ...[
        const SizedBox(height: 10),
        _dateField(
          caption: 'Meetiversary · the day you met',
          value: _meetiversary,
          onPick: (d) => _meetiversary = d,
        ),
      ],
    ]);
  }

  /// Picks which SIM this contact's calls go out on. "Default SIM" (null) means
  /// no preference — the global default in Settings is used, exactly as before.
  ///
  /// Only built when the phone has 2+ SIMs (see the build list). The label is
  /// stored alongside the id so the contact screen can name the SIM even before
  /// the SIM list has loaded.
  Widget _preferredSimSection() {
    return _section('Preferred SIM', [
      Text(
        'Which SIM to call this person on. Leave it on Default to use your '
        'usual SIM.',
        style: TextStyle(color: _t.sub, fontSize: 12.5),
      ),
      const SizedBox(height: 10),
      _preferredSimOption(
        title: 'Default SIM',
        subtitle: 'Use the SIM set in Settings',
        selected: _preferredSimId == null,
        onTap: () => setState(() {
          _preferredSimId = null;
          _preferredSimLabel = null;
        }),
      ),
      for (final sim in _sims) ...[
        const SizedBox(height: 8),
        _preferredSimOption(
          title: sim.displayLabel,
          subtitle: sim.slotIndex != null
              ? 'SIM ${sim.slotIndex! + 1}'
              : 'On this phone',
          selected: _preferredSimId == sim.phoneAccountId,
          onTap: () => setState(() {
            _preferredSimId = sim.phoneAccountId;
            _preferredSimLabel = sim.displayLabel;
          }),
        ),
      ],
    ]);
  }

  Widget _preferredSimOption({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return _shell(
      accentBorder: selected,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 20,
            color: selected ? _t.accent : _t.sub,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _t.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _t.sub, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ringtoneSection() {
    final hasTone = _ringtonePath != null;
    return _section('Ringtone', [
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _shell(
                caption: 'Ringtone',
                onTap: _pickRingtone,
                child: Row(
                  children: [
                    Icon(
                      hasTone ? Icons.music_note : Icons.notifications_none,
                      size: 18,
                      color: hasTone ? _t.accent : _t.sub,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasTone ? (_ringtoneLabel ?? 'Selected') : 'None',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasTone
                              ? _t.text
                              : _t.caption.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasTone) ...[
              const SizedBox(width: 8),
              _squareButton(
                icon: _previewPlaying ? Icons.stop : Icons.play_arrow,
                iconColor: _previewPlaying ? _t.accent : _t.sub,
                background: _previewPlaying ? _t.accentSoft : _t.field,
                border: _previewPlaying ? _t.accent : _t.fieldBorder,
                onTap: _toggleRingtonePreview,
              ),
              const SizedBox(width: 8),
              _squareButton(
                icon: Icons.close,
                iconColor: _t.sub,
                background: _t.field,
                border: _t.fieldBorder,
                onTap: _clearRingtone,
              ),
            ],
          ],
        ),
      ),
    ]);
  }

  /// A tappable, card-shaped picker for the contact's "calling card" image —
  /// deliberately a portrait rectangle (the in-call backdrop), not the circular
  /// avatar. Shows
  /// the picked image with a remove button, or an "Add calling card" placeholder.
  Widget _cardPhotoSection() {
    final hasCard =
        _cardPhotoPath != null && File(_cardPhotoPath!).existsSync();
    return _section('Calling card', [
      // A small phone-shaped thumbnail — just a representation of the calling card,
      // not a life-size preview. The real thing is shown full-screen during calls.
      SizedBox(
        width: 150,
        child: GestureDetector(
          onTap: _pickCardPhoto,
          child: AspectRatio(
            aspectRatio:
                9 / 16, // portrait — mirrors the full-screen in-call backdrop
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _t.field,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _t.fieldBorder),
              ),
              child: hasCard
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(_cardPhotoPath!), fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _clearCardPhoto,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wallpaper_outlined, size: 30, color: _t.sub),
                        const SizedBox(height: 8),
                        Text(
                          'Add calling card',
                          style: TextStyle(
                            color: _t.accentText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Photo shown full-screen during calls',
                          style: TextStyle(color: _t.caption, fontSize: 11.5),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    ]);
  }

  /// Blood group picker: the same menu-button + chips pattern as the gender
  /// field, but with no "Custom" option — the eight groups are the only valid
  /// answers, and free text is what caused typos like "0+" in the first place.
  Widget _bloodGroupField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _menuButton(
          caption: 'Blood group',
          value: _bloodGroup.isEmpty ? 'Select' : _bloodGroup,
          onTap: () => setState(() => _bloodMenuOpen = !_bloodMenuOpen),
        ),
        if (_bloodMenuOpen) ...[
          const SizedBox(height: 8),
          _chipWrap([
            for (final o in [...kBloodGroups, ?_bloodGroupLegacy])
              _chip(
                o,
                selected: _bloodGroup == o,
                onTap: () => setState(() {
                  _bloodGroup = o;
                  _bloodMenuOpen = false;
                }),
              ),
            if (_bloodGroup.isNotEmpty)
              _chip(
                'Clear',
                selected: false,
                onTap: () => setState(() {
                  _bloodGroup = '';
                  _bloodMenuOpen = false;
                }),
              ),
          ]),
        ],
      ],
    );
  }

  Widget _genderField() {
    final Widget head = _genderCustom
        ? _shell(
            caption: 'Gender',
            accentBorder: true,
            child: _bareTextField(controller: _genderText, hint: 'Describe'),
          )
        : _menuButton(
            caption: 'Gender',
            value: _gender.isEmpty ? 'Select' : _gender,
            onTap: () => setState(() => _genderMenuOpen = !_genderMenuOpen),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        head,
        if (_genderMenuOpen && !_genderCustom) ...[
          const SizedBox(height: 8),
          _chipWrap([
            for (final o in _genderLabels)
              _chip(
                o,
                selected: !_genderCustom && _gender == o,
                onTap: () => setState(() {
                  _gender = o;
                  _genderCustom = false;
                  _genderMenuOpen = false;
                }),
              ),
            _customChip(
              () => setState(() {
                _genderCustom = true;
                _genderMenuOpen = false;
                _genderText.text = '';
              }),
            ),
          ]),
        ],
      ],
    );
  }

  Widget _repeaterSection({
    required String title,
    required List<_LabeledEntry> list,
    required List<String> presets,
    required String valueHint,
    required TextInputType keyboardType,
    required bool hasPrimary,
    required String defaultLabel,
    required String addLabel,
    required String removeNoun,
    double labelWidth = 120,
    bool showCountryCode = false,
  }) {
    return _section(title, [
      // Auto-closes any other open swipe action when one row is swiped.
      SlidableAutoCloseBehavior(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < list.length; i++) ...[
              _repeaterRow(
                list: list,
                entry: list[i],
                index: i,
                presets: presets,
                valueHint: valueHint,
                keyboardType: keyboardType,
                hasPrimary: hasPrimary,
                removeNoun: removeNoun,
                labelWidth: labelWidth,
                showCountryCode: showCountryCode,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
      _addButton(addLabel, () => _addEntry(list, defaultLabel)),
    ]);
  }

  Widget _repeaterRow({
    required List<_LabeledEntry> list,
    required _LabeledEntry entry,
    required int index,
    required List<String> presets,
    required String valueHint,
    required TextInputType keyboardType,
    required bool hasPrimary,
    required String removeNoun,
    required double labelWidth,
    bool showCountryCode = false,
  }) {
    final String? phoneVal =
        showCountryCode && entry.value.text.trim().isNotEmpty
            ? PhoneNormalizer.validateNumber(
                PhoneNormalizer.compose(
                  iso: entry.countryIso ?? _homeCountryIso,
                  national: entry.value.text,
                ),
                defaultIso: entry.countryIso ?? _homeCountryIso,
              ).errorReason
            : null;

    final canRemove = list.length > 1;
    // Primary is positional: row 0 of a section that has a primary concept.
    // Indicated by colour (accent border + soft fill) rather than a star.
    final isPrimaryRow = hasPrimary && index == 0;
    final row = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: labelWidth,
            child: entry.custom
                ? _shell(
                    accentBorder: true,
                    child: _bareTextField(
                      controller: entry.label,
                      hint: 'Custom',
                      bold: true,
                    ),
                  )
                : _menuButton(
                    value: entry.label.text,
                    bold: true,
                    primary: isPrimaryRow,
                    onTap: () => _toggleMenu(list, entry),
                  ),
          ),
          const SizedBox(width: 8),
          if (showCountryCode) ...[
            SizedBox(
              width: 84,
              child: _menuButton(
                value: _dialLabel(entry),
                bold: true,
                primary: isPrimaryRow,
                onTap: () => _pickPhoneCountry(entry),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: _shell(
              primary: isPrimaryRow,
              accentBorder: phoneVal != null,
              child: _bareTextField(
                controller: entry.value,
                focusNode: entry.valueFocus,
                hint: valueHint,
                keyboardType: keyboardType,
              ),
            ),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Swipe left to reveal a Delete action (with confirmation). The only
        // remaining row isn't swipeable — a section keeps at least one row.
        if (canRemove)
          Slidable(
            key: ValueKey(entry.id),
            groupTag: list,
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.28,
              children: [
                SlidableAction(
                  onPressed: (_) =>
                      _confirmRemoveEntry(list, entry, removeNoun),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Delete',
                  borderRadius: BorderRadius.circular(14),
                ),
              ],
            ),
            child: row,
          )
        else
          row,
        if (phoneVal != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 13, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  phoneVal,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        if (entry.menuOpen && !entry.custom) ...[
          const SizedBox(height: 8),
          _chipWrap([
            for (final o in presets)
              _chip(
                o,
                selected: !entry.custom && entry.label.text == o,
                onTap: () => _chooseLabel(entry, o),
              ),
            _customChip(() => _enableCustom(entry)),
          ]),
        ],
      ],
    );
  }

  Widget _tagsSection() {
    final query = _tagInput.text.trim().toLowerCase();
    final added = _tags.map((t) => t.toLowerCase()).toSet();
    final List<String> suggestions;
    if (query.isEmpty) {
      // No input yet: offer the default starter pool.
      suggestions = _tagPool
          .where((t) => !added.contains(t.toLowerCase()))
          .take(4)
          .toList();
    } else {
      // Wildcard "contains" match anywhere in an existing tag name, excluding
      // tags already added. An exact case-insensitive match still shows (so the
      // user can adopt "Family" when they typed "family"); only an exact
      // same-casing match is redundant with the input and hidden.
      suggestions = _allTags
          .where(
            (t) =>
                t.toLowerCase().contains(query) &&
                t != _tagInput.text.trim() &&
                !added.contains(t.toLowerCase()),
          )
          .take(6)
          .toList();
    }
    return _section('Tags', [
      if (_tags.isNotEmpty) ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in _tags)
              Container(
                padding: const EdgeInsets.fromLTRB(13, 7, 8, 7),
                decoration: BoxDecoration(
                  color: _t.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        color: _t.accentText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _tags.remove(tag)),
                      child: Icon(Icons.close, size: 14, color: _t.accentText),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 11),
      ],
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _shell(
                caption: 'Add tag',
                child: _bareTextField(
                  controller: _tagInput,
                  hint: 'Type and press enter',
                  onSubmitted: (_) => _addTag(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _squareButton(
              icon: Icons.add,
              iconColor: _t.onAccent,
              background: _t.accent,
              border: _t.accent,
              width: 48,
              onTap: _addTag,
            ),
          ],
        ),
      ),
      if (suggestions.isNotEmpty) ...[
        const SizedBox(height: 11),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in suggestions)
              _DashedChip(
                color: _t.fieldBorder,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                onTap: () => _addTag(s),
                child: Text(
                  '+ $s',
                  style: TextStyle(
                    color: _t.sub,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    ]);
  }

  Widget _groupsSection() {
    final query = _groupInput.text.trim().toLowerCase();
    final selected = _groups.where((g) => g.on).toList();
    // Suggestions appear only once the user types — an untouched field used to
    // dump the first few groups on screen, which pushed the rest of the form
    // down for no reason. `*` is the escape hatch for "show me everything".
    final unselected = _groups.where((g) => !g.on);
    final suggestions = query.isEmpty
        ? const <_GroupChip>[]
        : (query == '*'
                  ? unselected
                  : unselected.where((g) => g.name.toLowerCase().contains(query)))
              .take(20)
              .toList();
    return _section('Add to group', [
      if (selected.isNotEmpty) ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in selected)
              Container(
                padding: const EdgeInsets.fromLTRB(13, 7, 8, 7),
                decoration: BoxDecoration(
                  color: _t.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 15, color: _t.onAccent),
                    const SizedBox(width: 6),
                    Text(
                      g.name,
                      style: TextStyle(
                        color: _t.onAccent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => g.on = false),
                      child: Icon(Icons.close, size: 14, color: _t.onAccent),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 11),
      ],
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _shell(
                caption: 'Add to group',
                child: _bareTextField(
                  controller: _groupInput,
                  hint: 'Type to search, * for all, or add new',
                  onSubmitted: (_) => _addGroup(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _squareButton(
              icon: Icons.add,
              iconColor: _t.onAccent,
              background: _t.accent,
              border: _t.accent,
              width: 48,
              onTap: _addGroup,
            ),
          ],
        ),
      ),
      if (suggestions.isNotEmpty) ...[
        const SizedBox(height: 11),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in suggestions)
              _DashedChip(
                color: _t.fieldBorder,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                onTap: () => _addGroup(g.name),
                child: Text(
                  '+ ${g.name}',
                  style: TextStyle(
                    color: _t.sub,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    ]);
  }

  Widget _relationshipsSection() {
    return _section('Relationships', [
      if (_relations.isEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Link this contact to people they know.',
            style: TextStyle(color: _t.sub, fontSize: 12.5),
          ),
        )
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in _relations)
              Container(
                padding: const EdgeInsets.only(
                  left: 14,
                  right: 6,
                  top: 6,
                  bottom: 6,
                ),
                decoration: BoxDecoration(
                  color: _t.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${r.category.emoji} ${r.name} · ${r.type}',
                      style: TextStyle(
                        color: _t.accentText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _removeRelationship(r),
                      child: Icon(Icons.close, size: 16, color: _t.sub),
                    ),
                  ],
                ),
              ),
          ],
        ),
      _addButton('Add relationship', _addRelationship),
    ]);
  }

  Widget _personalAddressSection() {
    return _section('Personal address', [
      for (int i = 0; i < _addresses.length; i++) ...[
        _addressCard(_addresses[i], i + 1),
        const SizedBox(height: 10),
      ],
      _addButton('Add address', () {
        setState(() => _addresses.add(_AddressEntry(_nextId())));
      }),
    ]);
  }

  Widget _addressCard(_AddressEntry a, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => a.open = !a.open),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: a.open ? 0 : -0.25,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: _t.accentText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ADDRESS $index',
                      style: TextStyle(
                        color: _t.accentText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_addresses.length > 1)
              GestureDetector(
                onTap: () => setState(() {
                  _addresses.remove(a);
                  a.dispose();
                }),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove, size: 14, color: _t.sub),
                    const SizedBox(width: 4),
                    Text(
                      'Remove',
                      style: TextStyle(
                        color: _t.sub,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (a.open) ...[
          const SizedBox(height: 10),
          _inputField(
            caption: 'Street',
            controller: a.street,
            hint: 'House no, street',
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _inputField(caption: 'City / Town', controller: a.city),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _inputField(caption: 'State', controller: a.state),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _inputField(
                  caption: 'Postal code',
                  controller: a.postal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _inputField(caption: 'Country', controller: a.country),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _workAddressSection() {
    return _section('Work address', [
      _inputField(
        caption: 'Company name',
        controller: _workCompany,
        hint: 'Where they work',
      ),
      const SizedBox(height: 10),
      _inputField(
        caption: 'Office / Street',
        controller: _workStreet,
        hint: 'Building, street',
      ),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _inputField(caption: 'City / Town', controller: _workCity),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _inputField(caption: 'State', controller: _workState),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _inputField(caption: 'Postal code', controller: _workPostal),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _inputField(caption: 'Country', controller: _workCountry),
          ),
        ],
      ),
    ]);
  }

  Widget _officialSection() {
    return _section('Official details', [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _inputField(
              caption: 'Designation',
              controller: _designation,
              hint: 'Title',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _inputField(
              caption: 'Department',
              controller: _department,
              hint: 'Team',
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _ephemeralSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _t.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEphemeral ? _t.accent : _t.fieldBorder,
          width: _isEphemeral ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏱️ Ephemeral contact',
                      style: TextStyle(
                        color: _t.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Temporary entry. Self-destructs automatically.',
                      style: TextStyle(
                        color: _t.caption,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isEphemeral,
                onChanged: (v) => setState(() => _isEphemeral = v),
                activeThumbColor: Colors.white,
                activeTrackColor: _t.accent,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: _t.trackOff,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ],
          ),
          if (_isEphemeral) ...[
            const SizedBox(height: 14),
            Text(
              'Expiry options',
              style: TextStyle(
                color: _t.sub,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EphemeralExpiryOption.values.map((opt) {
                final isSel = _ephemeralOption == opt;
                return ChoiceChip(
                  label: Text(
                    opt.label,
                    style: TextStyle(
                      color: isSel ? _t.onAccent : _t.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: isSel,
                  selectedColor: _t.accent,
                  backgroundColor: _t.accentSoft,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _ephemeralOption = opt);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _t.accentSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_clock_outlined, size: 16, color: _t.accentText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stored exclusively in local SQLCipher DB. Never synced to Google or phone contacts.',
                      style: TextStyle(
                        color: _t.accentText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _secretSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _t.field,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _t.fieldBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secret contact',
                  style: TextStyle(
                    color: _t.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hidden behind authentication',
                  style: TextStyle(
                    color: _t.caption,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isSecret,
            onChanged: (v) => setState(() => _isSecret = v),
            activeThumbColor: Colors.white,
            activeTrackColor: _t.accent,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: _t.trackOff,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  // ----- shared building blocks ---------------------------------------------

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title),
        const SizedBox(height: 11),
        ...children,
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _t.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: _t.text,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _shell({
    String? caption,
    required Widget child,
    bool accentBorder = false,
    bool error = false,
    bool primary = false,
    VoidCallback? onTap,
  }) {
    final borderColor = error
        ? Colors.redAccent
        : (accentBorder || primary)
        ? _t.accent
        : _t.fieldBorder;
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: primary ? _t.accentSoft : _t.field,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (caption != null) ...[
            Text(
              caption.toUpperCase(),
              style: TextStyle(
                color: _t.caption,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
          ],
          child,
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: content,
    );
  }

  Widget _inputField({
    required String caption,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool error = false,
    ValueChanged<String>? onChanged,
  }) {
    return _shell(
      caption: caption,
      error: error,
      child: _bareTextField(
        controller: controller,
        hint: hint,
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Widget _bareTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    String? hint,
    TextInputType? keyboardType,
    bool bold = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      cursorColor: _t.accent,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: onSubmitted != null
          ? TextInputAction.done
          : TextInputAction.next,
      style: TextStyle(
        color: _t.text,
        fontSize: bold ? 14 : 15,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: hint,
        hintStyle: TextStyle(
          color: _t.caption.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
          fontSize: bold ? 14 : 15,
        ),
      ),
    );
  }

  Widget _menuButton({
    String? caption,
    required String value,
    required VoidCallback onTap,
    bool bold = false,
    bool primary = false,
  }) {
    return _shell(
      caption: caption,
      onTap: onTap,
      primary: primary,
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _t.text,
                fontSize: bold ? 14 : 15,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, size: 16, color: _t.sub),
        ],
      ),
    );
  }

  Widget _dateField({
    required String caption,
    required DateTime? value,
    required ValueChanged<DateTime?> onPick,
  }) {
    return _shell(
      caption: caption,
      onTap: () => _pickDate(value, onPick),
      child: Text(
        value == null ? 'Select' : _fmtDate(value),
        style: TextStyle(
          color: value == null ? _t.caption.withValues(alpha: 0.7) : _t.text,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _squareButton({
    required IconData icon,
    required Color iconColor,
    required Color background,
    required Color border,
    required VoidCallback onTap,
    double width = 44,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Center(child: Icon(icon, size: 18, color: iconColor)),
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onTap) {
    return _DashedChip(
      color: _t.fieldBorder,
      radius: 13,
      fullWidth: true,
      padding: const EdgeInsets.all(11),
      activeColor: _t.accentSoft,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 16, color: _t.accentText),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: _t.accentText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipWrap(List<Widget> chips) {
    return Wrap(spacing: 7, runSpacing: 7, children: chips);
  }

  Widget _chip(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _t.accent : _t.accentSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _t.onAccent : _t.accentText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _customChip(VoidCallback onTap) {
    return _DashedChip(
      color: _t.fieldBorder,
      radius: 10,
      onTap: onTap,
      child: Text(
        '+ Custom',
        style: TextStyle(
          color: _t.accentText,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  // ----- small generic helpers ----------------------------------------------

  static T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }
}

/// A pill/box with a dashed border (the design's "+ Custom", "Add …", "+ New
/// group", and tag-suggestion affordances). Flutter has no dashed border out of
/// the box, so it's painted.
class _DashedChip extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsets padding;
  final bool fullWidth;
  final VoidCallback onTap;
  final Color? activeColor;

  const _DashedChip({
    required this.child,
    required this.color,
    required this.onTap,
    this.radius = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    this.fullWidth = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: color, radius: radius),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

/// Mutable form state for one phone / email / social row.
class _LabeledEntry {
  final int id;
  final TextEditingController value;
  final TextEditingController label;

  /// Focus node for the value field, so a freshly added row can grab focus and
  /// let the user type right away (see [_addEntry]).
  final FocusNode valueFocus = FocusNode();
  bool custom;
  bool menuOpen = false;
  bool isPrimary;

  /// Selected country (ISO alpha-2) for phone rows, shown as the `+<dialCode>`
  /// chip and combined with [value] into E.164 on save. Null for email/social
  /// rows, which have no country chip.
  String? countryIso;

  _LabeledEntry({
    required this.id,
    String value = '',
    String label = '',
    this.custom = false,
    this.isPrimary = false,
    this.countryIso,
  }) : value = TextEditingController(text: value),
       label = TextEditingController(text: label);

  factory _LabeledEntry.preset(int id, String label, {bool isPrimary = false}) {
    return _LabeledEntry(id: id, label: label, isPrimary: isPrimary);
  }

  /// Builds from a loaded value. A label not in [presets] (and non-empty) is
  /// treated as a custom label.
  factory _LabeledEntry.from(
    int id,
    List<String> presets,
    String? label,
    String value,
    bool isPrimary, {
    String? countryIso,
  }) {
    final l = label?.trim() ?? '';
    final custom = l.isNotEmpty && !presets.contains(l);
    return _LabeledEntry(
      id: id,
      value: value,
      label: l.isEmpty ? presets.first : l,
      custom: custom,
      isPrimary: isPrimary,
      countryIso: countryIso,
    );
  }

  void dispose() {
    value.dispose();
    label.dispose();
    valueFocus.dispose();
  }
}

/// A toggleable group chip in the "Add to group" section.
class _GroupChip {
  final String name;
  bool on;
  _GroupChip(this.name, this.on);
}

/// A relationship the user has staged in the form, persisted on save.
class _PendingRel {
  final int contactId;
  final String name;
  final String type;

  /// Which of the seven buckets the link belongs to. For a link loaded from the
  /// DB this is the stored category; for one just added it is the user's pick.
  final RelationshipCategory category;

  _PendingRel({
    required this.contactId,
    required this.name,
    required this.type,
    required this.category,
  });
}

/// Mutable form state for one collapsible personal-address card.
class _AddressEntry {
  final int id;
  final TextEditingController street;
  final TextEditingController city;
  final TextEditingController state;
  final TextEditingController postal;
  final TextEditingController country;
  bool open = true;

  _AddressEntry(
    this.id, {
    String street = '',
    String city = '',
    String state = '',
    String postal = '',
    String country = '',
  }) : street = TextEditingController(text: street),
       city = TextEditingController(text: city),
       state = TextEditingController(text: state),
       postal = TextEditingController(text: postal),
       country = TextEditingController(text: country);

  factory _AddressEntry.fromAddress(int id, Address a) {
    return _AddressEntry(
      id,
      street: a.street ?? '',
      city: a.cityTown ?? '',
      state: a.state ?? '',
      postal: a.postalCode ?? '',
      country: a.country ?? '',
    );
  }

  Address toAddress() {
    String? n(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    return Address(
      type: 'personal',
      street: n(street),
      cityTown: n(city),
      state: n(state),
      postalCode: n(postal),
      country: n(country),
    );
  }

  void dispose() {
    street.dispose();
    city.dispose();
    state.dispose();
    postal.dispose();
    country.dispose();
  }
}

/// Bottom-sheet country picker for a phone row's `+code` chip. Searchable over
/// all countries; pops the chosen ISO alpha-2 string (or null on dismiss).
/// Follows the app's design (themed search, ISO badge rows) — deliberately not
/// a flag-emoji list, matching [DefaultCountryScreen].
class _CountryPickerSheet extends StatefulWidget {
  final String selectedIso;

  const _CountryPickerSheet({required this.selectedIso});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late final List<CountryOption> _all = PhoneNormalizer.allCountries();
  String _query = '';

  List<CountryOption> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.isoString.toLowerCase().contains(q) ||
              c.dialCode.contains(q) ||
              '+${c.dialCode}'.contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final accent = Theme.of(context).colorScheme.primary;
    final items = _filtered;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: colors.mutedText.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                children: [
                  const Text(
                    'Select country code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.searchFill,
                  borderRadius: BorderRadius.circular(18),
                  border: colors.isDark
                      ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                      : null,
                ),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search country or code',
                    prefixIcon: Icon(Icons.search, color: accent),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No countries match "$_query"',
                        style: TextStyle(color: colors.mutedText),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (context, i) =>
                          _row(colors, accent, items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(AppColors colors, Color accent, CountryOption country) {
    final selected = country.isoString == widget.selectedIso;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? accent.withValues(alpha: colors.isDark ? 0.16 : 0.10)
            : colors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).pop(country.isoString),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? accent.withValues(alpha: 0.55)
                    : (colors.isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04)),
                width: selected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                _isoBadge(accent, country.isoString, selected: selected),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    country.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '+${country.dialCode}',
                  style: TextStyle(
                    color: selected ? accent : colors.mutedText,
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.check_circle, color: accent, size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _isoBadge(Color accent, String iso, {required bool selected}) {
    final bg = selected ? accent : accent.withValues(alpha: 0.14);
    final fg = selected ? AppTheme.contrastOn(accent) : accent;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        iso,
        style: TextStyle(
          color: fg,
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Where a picked ringtone comes from: the phone's built-in ringtones or a file.
enum _RingtoneSource { phone, file }
