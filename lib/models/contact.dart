// lib/models/contact.dart
import 'package:smart_contacts_dialer/state/app_settings.dart'
    show ContactSortOrder, NameDisplayFormat;
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/official_details.dart';
import 'package:smart_contacts_dialer/models/social_link.dart';
import 'package:smart_contacts_dialer/models/relationship.dart';

class Contact {
  int? id;
  String? salutation;
  String firstName;
  String? middleName;
  String? lastName;

  /// A free-text formal way to write or address the contact (e.g. a full
  /// honorific name). Stored and searchable, but not used as the display name.
  String? formalName;

  String? gender;
  DateTime? dob;
  String? photoPath;

  /// Path to the contact's "calling card" image — a full-screen portrait shown
  /// as the in-call backdrop, independent of the avatar [photoPath]. App-only:
  /// never written to or read from the device address book (it has no field for
  /// a second image), so it lives only in the app's SQLite store.
  String? cardPhotoPath;
  String? ringtonePath;
  String? ringtoneLabel;
  String? bloodGroup;
  DateTime? anniversary;
  DateTime? meetiversary;
  double relationshipScore;
  bool isSecret;

  /// True when the user has starred this contact. Surfaces the contact in the
  /// dialer's Favorites list (shown before any digits are typed). Toggled from
  /// the contact detail screen.
  bool isFavorite;

  /// True for the single "Self" contact — the details of the person using this
  /// phone. Pinned to the top of the contact list irrespective of sort order.
  /// At most one contact carries this flag (enforced in [ContactRepository]).
  /// App-only: like a secret contact, Self is never written to the device book.
  bool isSelf;

  /// True when this is a temporary, self-destructing contact entry.
  bool isEphemeral;

  /// Absolute expiry timestamp for timed self-destruction (e.g. 2h, 24h, 7d).
  DateTime? ephemeralExpiresAt;

  /// True when the contact auto-deletes immediately after 1 call is placed/completed.
  bool ephemeralAutoDeleteCall;

  /// Count of calls logged for this ephemeral contact.
  int ephemeralCallCount;

  /// The Telecom `phoneAccountId` of the SIM this contact should be called on,
  /// or null for "no preference — use the global default SIM".
  ///
  /// App-only, like [cardPhotoPath]: the device address book has no field for
  /// it, so it is never pushed to or read from the system contacts provider,
  /// and it is not part of vCard/CSV export. An id that no longer matches a SIM
  /// in the phone is ignored at call time and the global default is used.
  String? preferredSimId;

  /// The SIM's label when the preference was set. Display only — [preferredSimId]
  /// is what actually routes the call. Kept so a contact can still be described
  /// before the SIM list has loaded.
  String? preferredSimLabel;

  /// Links this app contact to a contact in the device address book. Null means
  /// app-only (never written to the device). Set when a contact is imported from
  /// or pushed to the device; cleared when a contact is made secret (secret
  /// contacts are app-only and pulled out of the device — see ContactSyncService).
  String? deviceId;

  DateTime? createdAt;
  DateTime? updatedAt;

  // Related data
  List<PhoneNumber> phoneNumbers = [];
  List<Email> emails = [];
  List<Address> addresses = [];
  List<SocialLink> socialLinks = [];
  List<String> groups = [];
  List<String> tags = [];
  OfficialDetails? officialDetails;

  /// Display-only: the contact's related contacts, populated on hydrate. Not
  /// part of [toMap]/[fromMap] — relationships live in their own table and are
  /// managed via [RelationshipRepository].
  List<RelatedContact> relationships = [];

  /// Remote sync fields for Google / Microsoft / CardDAV online sync
  String? remoteSyncId;
  String? syncEtag;
  String? lastSyncedAt;
  String? syncProvider;
  bool needsSync;

  Contact({
    this.id,
    this.salutation,
    required this.firstName,
    this.middleName,
    this.lastName,
    this.formalName,
    this.gender,
    this.dob,
    this.photoPath,
    this.cardPhotoPath,
    this.ringtonePath,
    this.ringtoneLabel,
    this.bloodGroup,
    this.anniversary,
    this.meetiversary,
    this.relationshipScore = 0.0,
    this.isSecret = false,
    this.isFavorite = false,
    this.isSelf = false,
    this.isEphemeral = false,
    this.ephemeralExpiresAt,
    this.ephemeralAutoDeleteCall = false,
    this.ephemeralCallCount = 0,
    this.preferredSimId,
    this.preferredSimLabel,
    this.deviceId,
    this.createdAt,
    this.updatedAt,
    this.remoteSyncId,
    this.syncEtag,
    this.lastSyncedAt,
    this.syncProvider,
    this.needsSync = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'salutation': salutation,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'formal_name': formalName,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'photo_path': photoPath,
      'card_photo_path': cardPhotoPath,
      'ringtone_path': ringtonePath,
      'ringtone_label': ringtoneLabel,
      'blood_group': bloodGroup,
      'anniversary': anniversary?.toIso8601String(),
      'meetiversary': meetiversary?.toIso8601String(),
      'relationship_score': relationshipScore,
      'is_secret': isSecret ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'is_self': isSelf ? 1 : 0,
      'is_ephemeral': isEphemeral ? 1 : 0,
      'ephemeral_expires_at': ephemeralExpiresAt?.toIso8601String(),
      'ephemeral_auto_delete_call': ephemeralAutoDeleteCall ? 1 : 0,
      'ephemeral_call_count': ephemeralCallCount,
      'preferred_sim_id': preferredSimId,
      'preferred_sim_label': preferredSimLabel,
      'device_id': deviceId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'remote_sync_id': remoteSyncId,
      'sync_etag': syncEtag,
      'last_synced_at': lastSyncedAt,
      'sync_provider': syncProvider,
      'needs_sync': needsSync ? 1 : 0,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      salutation: map['salutation'],
      firstName: map['first_name'],
      middleName: map['middle_name'],
      lastName: map['last_name'],
      formalName: map['formal_name'],
      gender: map['gender'],
      dob: map['dob'] != null ? DateTime.parse(map['dob']) : null,
      photoPath: map['photo_path'],
      cardPhotoPath: map['card_photo_path'],
      ringtonePath: map['ringtone_path'],
      ringtoneLabel: map['ringtone_label'],
      bloodGroup: map['blood_group'],
      anniversary: map['anniversary'] != null
          ? DateTime.parse(map['anniversary'])
          : null,
      meetiversary: map['meetiversary'] != null
          ? DateTime.parse(map['meetiversary'])
          : null,
      relationshipScore: map['relationship_score'] ?? 0.0,
      isSecret: map['is_secret'] == 1,
      isFavorite: map['is_favorite'] == 1,
      isSelf: map['is_self'] == 1,
      isEphemeral: map['is_ephemeral'] == 1,
      ephemeralExpiresAt: map['ephemeral_expires_at'] != null
          ? DateTime.parse(map['ephemeral_expires_at'])
          : null,
      ephemeralAutoDeleteCall: map['ephemeral_auto_delete_call'] == 1,
      ephemeralCallCount: map['ephemeral_call_count'] ?? 0,
      preferredSimId: map['preferred_sim_id'] as String?,
      preferredSimLabel: map['preferred_sim_label'] as String?,
      deviceId: map['device_id'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      remoteSyncId: map['remote_sync_id'],
      syncEtag: map['sync_etag'],
      lastSyncedAt: map['last_synced_at'],
      syncProvider: map['sync_provider'],
      needsSync: map['needs_sync'] == 1,
    );
  }

  String get fullName {
    return [
      salutation,
      firstName,
      middleName,
      lastName,
    ].where((e) => e != null && e.isNotEmpty).join(' ');
  }

  /// The contact's name arranged per [format]. [NameDisplayFormat.firstFirst]
  /// returns [fullName] ("First Last"); [NameDisplayFormat.lastFirst] returns
  /// "Last, First Middle". Falls back to [fullName] when there is no last name.
  String displayName(NameDisplayFormat format) {
    if (format == NameDisplayFormat.firstFirst) return fullName;
    final last = lastName;
    if (last == null || last.isEmpty) return fullName;
    final rest = [
      salutation,
      firstName,
      middleName,
    ].where((e) => e != null && e.isNotEmpty).join(' ');
    return rest.isEmpty ? last : '$last, $rest';
  }

  /// A lower-cased key for sorting the contact list per [order]. Sorts on the
  /// leading name component for the chosen order, then the other, so ties break
  /// sensibly. Empty components sort as an empty string.
  String sortKey(ContactSortOrder order) {
    final first = (firstName).toLowerCase();
    final last = (lastName ?? '').toLowerCase();
    return order == ContactSortOrder.lastName ? '$last $first' : '$first $last';
  }
}
