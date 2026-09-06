// lib/models/speed_dial_entry.dart
//
// One speed-dial assignment: a keypad key (1–9) bound to a phone number, and
// optionally to the contact that number came from.
//
// The row lives in the encrypted `speed_dial` table. [displayName] and
// [photoPath] are NOT columns — they are joined in by
// `SpeedDialRepository.all()` so the keypad and the settings list can show who
// a key belongs to without a second query.
class SpeedDialEntry {
  /// The keypad key this entry is bound to, 1–9. Key 0 is not a speed-dial
  /// slot: it keeps its long-press "+" on the dialer.
  final int slot;

  /// The contact this number belongs to, or null when a bare number was saved
  /// (or the contact has since been deleted — though the foreign key's
  /// ON DELETE CASCADE normally removes the whole row in that case).
  final int? contactId;

  final String phoneNumber;

  /// Display only: the linked contact's name, joined in on read. Null for a
  /// bare number.
  final String? displayName;

  /// Display only: the linked contact's avatar path, joined in on read.
  final String? photoPath;

  const SpeedDialEntry({
    required this.slot,
    required this.phoneNumber,
    this.contactId,
    this.displayName,
    this.photoPath,
  });

  /// The lowest and highest keys that can hold a speed-dial number.
  static const int minSlot = 1;
  static const int maxSlot = 9;

  /// Whether [slot] is a key that can hold a speed dial.
  static bool isValidSlot(int slot) => slot >= minSlot && slot <= maxSlot;

  /// What to show for this entry: the contact's name when linked, else the
  /// number itself.
  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return phoneNumber;
  }

  /// Only the columns that belong to the `speed_dial` table — the joined
  /// display fields are deliberately left out.
  Map<String, dynamic> toMap() => {
    'slot': slot,
    'contact_id': contactId,
    'phone_number': phoneNumber,
  };

  factory SpeedDialEntry.fromMap(Map<String, dynamic> map) {
    // The name is assembled in SQL from parts that are all NULL for a bare
    // number, which SQLite hands back as an empty string rather than NULL.
    // Normalise it so "no linked contact" is a single, obvious state.
    final name = (map['display_name'] as String?)?.trim();
    return SpeedDialEntry(
      slot: (map['slot'] as num).toInt(),
      contactId: (map['contact_id'] as num?)?.toInt(),
      phoneNumber: (map['phone_number'] as String?) ?? '',
      displayName: (name == null || name.isEmpty) ? null : name,
      photoPath: map['photo_path'] as String?,
    );
  }
}
