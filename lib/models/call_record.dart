// lib/models/call_record.dart
//
// One row of call history: a `call_logs` row joined to its contact's display
// name (when the call is linked to a known contact). Named `CallRecord` to
// avoid colliding with the `call_log` package's `CallLogEntry`.
//
// Read-only — built by [CallLogRepository] from a LEFT JOIN, never persisted as
// a whole. Sentiment (`emotional_tone`) lives on the `interactions` table and
// drives relationship scoring; it is intentionally not part of this row because
// `call_logs` and `interactions` aren't linked per-call. History therefore
// surfaces `call_intent`/`notes`, which do live on `call_logs`.
class CallRecord {
  final int id;
  final int? contactId;

  /// Joined from `contacts` — null when the call isn't linked to a contact
  /// (e.g. dialed an unknown number).
  final String? contactName;

  final String phoneNumber;

  /// 'incoming' | 'outgoing' | 'missed', or null while still provisional.
  final String? callType;

  /// What happened on the call — see `AppCallOutcome`. Separate from [callType],
  /// which only says which way the call went; without this an answered outgoing
  /// call and one that rang out are indistinguishable. Null means "not known":
  /// rows written before the column existed, and imported rows where the device
  /// log settles nothing.
  final String? callOutcome;

  /// Duration in seconds; null while a placed call hasn't been reconciled.
  final int? duration;

  final DateTime timestamp;
  final String? callIntent;
  final String? notes;

  /// The SIM the call came in / went out on. [simId] is the phone-account id
  /// (matches the device call log); [simLabel] is the human label to display.
  /// Both null for calls logged before multi-SIM, or when the SIM is unknown.
  final String? simId;
  final String? simLabel;

  /// Joined from `contacts.photo_path` — the linked contact's avatar image.
  /// Null when the call isn't linked or the contact has no photo.
  final String? photoPath;

  const CallRecord({
    required this.id,
    this.contactId,
    this.contactName,
    required this.phoneNumber,
    this.callType,
    this.callOutcome,
    this.duration,
    required this.timestamp,
    this.callIntent,
    this.notes,
    this.simId,
    this.simLabel,
    this.photoPath,
  });

  /// Best display label: the joined contact name, else the raw number (or 'Unknown').
  String get displayName => (contactName != null && contactName!.isNotEmpty)
      ? contactName!
      : (phoneNumber.isNotEmpty ? phoneNumber : 'Unknown');

  bool get isLinked => contactId != null;

  /// Builds from a joined row. The query aliases the contact's name column to
  /// `contact_name`; everything else maps straight off `call_logs`.
  factory CallRecord.fromJoinedMap(Map<String, dynamic> map) {
    final ts = map['timestamp'] as String?;
    return CallRecord(
      id: map['id'] as int,
      contactId: map['contact_id'] as int?,
      contactName: map['contact_name'] as String?,
      phoneNumber: (map['phone_number'] as String?) ?? '',
      callType: map['call_type'] as String?,
      callOutcome: map['call_outcome'] as String?,
      duration: map['duration'] as int?,
      timestamp: ts != null ? DateTime.parse(ts) : DateTime.now(),
      callIntent: map['call_intent'] as String?,
      notes: map['notes'] as String?,
      simId: map['sim_id'] as String?,
      simLabel: map['sim_label'] as String?,
      photoPath: map['photo_path'] as String?,
    );
  }
}
