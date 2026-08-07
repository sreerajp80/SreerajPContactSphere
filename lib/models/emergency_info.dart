// lib/models/emergency_info.dart
//
// The emergency info card (Settings → Emergency info). The full record lives in
// the encrypted DB; a *subset* of it — only the fields the user switched on — is
// mirrored to native SharedPreferences as plaintext so the lock-screen card can
// be drawn without unlocking the phone. See [EmergencyInfo.toMirrorJson] and
// docs/security.md.

/// One person to call in an emergency, as shown on the lock-screen card.
///
/// The name and number are *snapshotted* here even when [contactId] points at a
/// real contact, so building the mirror never has to read the encrypted contact
/// tables (and the card keeps working if that contact is later deleted).
class EmergencyContactEntry {
  int? id;

  /// The app contact this entry was picked from, if any. Nullable: an entry can
  /// be typed in by hand, and the link is cleared if the contact is deleted.
  int? contactId;
  String displayName;
  String number;
  String? relationLabel;
  int sortOrder;

  /// Per-entry opt-in. Only entries with this set reach the mirror.
  bool showOnLock;

  EmergencyContactEntry({
    this.id,
    this.contactId,
    required this.displayName,
    required this.number,
    this.relationLabel,
    this.sortOrder = 0,
    this.showOnLock = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'contact_id': contactId,
    'display_name': displayName,
    'number': number,
    'relation_label': relationLabel,
    'sort_order': sortOrder,
    'show_on_lock': showOnLock ? 1 : 0,
  };

  factory EmergencyContactEntry.fromMap(Map<String, dynamic> map) =>
      EmergencyContactEntry(
        id: map['id'] as int?,
        contactId: map['contact_id'] as int?,
        displayName: (map['display_name'] as String?) ?? '',
        number: (map['number'] as String?) ?? '',
        relationLabel: map['relation_label'] as String?,
        sortOrder: (map['sort_order'] as int?) ?? 0,
        showOnLock: ((map['show_on_lock'] as int?) ?? 1) != 0,
      );

  bool get isUsable => displayName.trim().isNotEmpty && number.trim().isNotEmpty;
}

/// One labelled line of the card, as the native renderer wants it.
class EmergencyRow {
  final String label;
  final String value;
  const EmergencyRow(this.label, this.value);

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}

/// The whole card: the master switch, the medical fields, their per-field
/// "show on lock screen" flags, and the emergency contacts.
class EmergencyInfo {
  /// Master switch. While this is off nothing is mirrored and no lock-screen
  /// notification is posted — the data simply stays in the encrypted DB.
  bool enabled;

  String? ownerName;
  bool showOwnerName;
  String? bloodGroup;
  bool showBloodGroup;
  String? allergies;
  bool showAllergies;
  String? medications;
  bool showMedications;
  String? conditions;
  bool showConditions;
  String? notes;
  bool showNotes;
  String? address;
  bool showAddress;
  bool organDonor;
  bool showOrganDonor;

  List<EmergencyContactEntry> contacts;

  EmergencyInfo({
    this.enabled = false,
    this.ownerName,
    this.showOwnerName = true,
    this.bloodGroup,
    this.showBloodGroup = true,
    this.allergies,
    this.showAllergies = true,
    this.medications,
    this.showMedications = true,
    this.conditions,
    this.showConditions = true,
    this.notes,
    this.showNotes = true,
    this.address,
    this.showAddress = false,
    this.organDonor = false,
    this.showOrganDonor = true,
    List<EmergencyContactEntry>? contacts,
  }) : contacts = contacts ?? <EmergencyContactEntry>[];

  /// Labels shown on the card. Kept here so the edit screen, the preview, and
  /// the mirror all use exactly the same words.
  static const labelBloodGroup = 'Blood group';
  static const labelAllergies = 'Allergies';
  static const labelMedications = 'Medicines';
  static const labelConditions = 'Conditions';
  static const labelNotes = 'Notes';
  static const labelAddress = 'Address';
  static const labelOrganDonor = 'Organ donor';

  Map<String, dynamic> toMap() => {
    'id': 1,
    'enabled': enabled ? 1 : 0,
    'owner_name': ownerName,
    'show_owner_name': showOwnerName ? 1 : 0,
    'blood_group': bloodGroup,
    'show_blood_group': showBloodGroup ? 1 : 0,
    'allergies': allergies,
    'show_allergies': showAllergies ? 1 : 0,
    'medications': medications,
    'show_medications': showMedications ? 1 : 0,
    'conditions': conditions,
    'show_conditions': showConditions ? 1 : 0,
    'notes': notes,
    'show_notes': showNotes ? 1 : 0,
    'address': address,
    'show_address': showAddress ? 1 : 0,
    'organ_donor': organDonor ? 1 : 0,
    'show_organ_donor': showOrganDonor ? 1 : 0,
  };

  factory EmergencyInfo.fromMap(
    Map<String, dynamic> map, {
    List<EmergencyContactEntry>? contacts,
  }) {
    bool flag(String key, {bool fallback = true}) =>
        ((map[key] as int?) ?? (fallback ? 1 : 0)) != 0;
    return EmergencyInfo(
      enabled: flag('enabled', fallback: false),
      ownerName: map['owner_name'] as String?,
      showOwnerName: flag('show_owner_name'),
      bloodGroup: map['blood_group'] as String?,
      showBloodGroup: flag('show_blood_group'),
      allergies: map['allergies'] as String?,
      showAllergies: flag('show_allergies'),
      medications: map['medications'] as String?,
      showMedications: flag('show_medications'),
      conditions: map['conditions'] as String?,
      showConditions: flag('show_conditions'),
      notes: map['notes'] as String?,
      showNotes: flag('show_notes'),
      address: map['address'] as String?,
      showAddress: flag('show_address', fallback: false),
      organDonor: flag('organ_donor', fallback: false),
      showOrganDonor: flag('show_organ_donor'),
      contacts: contacts,
    );
  }

  /// The medical lines that are switched on and actually have a value.
  List<EmergencyRow> visibleRows() {
    final rows = <EmergencyRow>[];
    void add(String label, String? value, bool show) {
      if (!show) return;
      final text = (value ?? '').trim();
      if (text.isEmpty) return;
      rows.add(EmergencyRow(label, text));
    }

    add(labelBloodGroup, bloodGroup, showBloodGroup);
    add(labelAllergies, allergies, showAllergies);
    add(labelMedications, medications, showMedications);
    add(labelConditions, conditions, showConditions);
    add(labelAddress, address, showAddress);
    add(labelNotes, notes, showNotes);
    if (showOrganDonor && organDonor) {
      rows.add(const EmergencyRow(labelOrganDonor, 'Yes'));
    }
    return rows;
  }

  /// The emergency contacts that are switched on and usable.
  List<EmergencyContactEntry> visibleContacts() {
    final list = contacts.where((c) => c.showOnLock && c.isUsable).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  /// True when the card would show nothing at all — the caller then clears the
  /// mirror instead of publishing an empty card.
  bool get hasNothingToShow =>
      visibleRows().isEmpty && visibleContacts().isEmpty;

  /// The exact payload handed to the native side. **This is the only thing that
  /// leaves the encrypted database in plaintext**, so it is deliberately small:
  /// switched-on labelled lines, plus name/relation/number per shown contact.
  ///
  /// Returns `null` when the master switch is off or there is nothing to show —
  /// the caller clears the mirror in that case.
  Map<String, dynamic>? toMirrorJson() {
    if (!enabled) return null;
    final rows = visibleRows();
    final people = visibleContacts();
    if (rows.isEmpty && people.isEmpty) return null;
    final owner = (ownerName ?? '').trim();
    return {
      'v': 1,
      if (showOwnerName && owner.isNotEmpty) 'owner': owner,
      'rows': rows.map((r) => r.toJson()).toList(),
      'contacts': people
          .map(
            (c) => {
              'name': c.displayName.trim(),
              if ((c.relationLabel ?? '').trim().isNotEmpty)
                'relation': c.relationLabel!.trim(),
              'number': c.number.trim(),
            },
          )
          .toList(),
    };
  }
}
