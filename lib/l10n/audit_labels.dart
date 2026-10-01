// lib/l10n/audit_labels.dart
//
// Display text for the audit log. `AuditEntry` (lib/models/audit_entry.dart)
// names actions, sources and changed fields in English, and those names also go
// into the stored, hash-chained record. The record is left as it is; these
// helpers only translate what the screen shows.

import 'package:smart_contacts_dialer/l10n/app_localizations.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';

/// "Added", "Edited" or "Deleted" in the app's language.
String auditActionLabel(AppLocalizations l, AuditAction action) =>
    switch (action) {
      AuditAction.create => l.labelAuditAdded,
      AuditAction.update => l.labelAuditEdited,
      AuditAction.delete => l.labelAuditDeleted,
    };

/// Who made the change, in the app's language.
String auditSourceLabel(AppLocalizations l, AuditSource source) =>
    switch (source) {
      AuditSource.manual => l.labelSourceManual,
      AuditSource.deviceSync => l.labelSourceDeviceSync,
      AuditSource.merge => l.labelSourceMerge,
      AuditSource.restore => l.labelSourceRestore,
      AuditSource.p2pSync => l.labelSourceP2pSync,
      AuditSource.import => l.labelSourceImport,
      AuditSource.undo => l.labelSourceUndo,
      AuditSource.unknown => l.labelSourceUnknown,
    };

/// What the Undo button will do for an entry of this action.
String auditUndoDescription(AppLocalizations l, AuditAction action) =>
    switch (action) {
      AuditAction.create => l.descUndoCreate,
      AuditAction.update => l.descUndoUpdate,
      AuditAction.delete => l.descUndoDelete,
    };

/// A changed field's name, from the English label `AuditEntry.diff` gives it.
/// Unknown labels are shown as they are.
String auditFieldLabel(AppLocalizations l, String english) => switch (english) {
  'Salutation' => l.labelSalutation,
  'First name' => l.labelFirstName,
  'Middle name' => l.labelMiddleName,
  'Last name' => l.labelLastName,
  'Formal name' => l.labelFormalName,
  'Gender' => l.labelGender,
  'Date of birth' => l.labelDateOfBirth,
  'Photo' => l.labelPhoto,
  'Calling card' => l.labelCallingCard,
  'Ringtone' => l.labelRingtone,
  'Blood group' => l.labelBloodGroup,
  'Anniversary' => l.labelAnniversary,
  'Meetiversary' => l.labelMeetiversary,
  'Secret' => l.labelSecret,
  'Favourite' => l.labelFavourite,
  'Self' => l.labelSelf,
  'Phone contacts link' => l.labelPhoneContactsLink,
  'Phone numbers' => l.labelPhoneNumbers,
  'Emails' => l.labelEmails,
  'Addresses' => l.labelAddresses,
  'Social links' => l.labelSocialLinks,
  'Work details' => l.labelWorkDetails,
  'Tags' => l.navTags,
  'Groups' => l.tooltipGroups,
  _ => english,
};

/// A changed value. Yes/No flags are translated; everything else is data.
String auditValueText(AppLocalizations l, String value) => switch (value) {
  'Yes' => l.actionYes,
  'No' => l.actionNo,
  _ => value,
};
