// lib/widgets/business_card_review_sheet.dart
//
// Confirmation step for the business card scanner. Shows every field the parser
// read off the card, each with a checkbox, plus the full recognized text for
// anything it could not place. Returns the contact built from the *ticked*
// fields only — or null if the user backs out. Nothing is saved here; the caller
// hands the result to the Add contact form.

import 'package:flutter/material.dart';

import 'package:smart_contacts_dialer/models/address.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/official_details.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/models/social_link.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/utils/business_card_parser.dart';

/// Shows the review sheet for [draft]. Resolves to the contact to prefill the
/// Add contact form with, or null when the user cancels.
Future<Contact?> showBusinessCardReviewSheet(
  BuildContext context,
  BusinessCardDraft draft,
) {
  return showModalBottomSheet<Contact>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => BusinessCardReviewSheet(draft: draft),
  );
}

/// One reviewable field: what it is, what was read, and whether to keep it.
class _Row {
  final String label;
  final String value;
  final IconData icon;

  /// Writes this field onto the contact being built.
  final void Function(Contact) apply;

  bool keep = true;

  _Row({
    required this.label,
    required this.value,
    required this.icon,
    required this.apply,
  });
}

class BusinessCardReviewSheet extends StatefulWidget {
  final BusinessCardDraft draft;

  const BusinessCardReviewSheet({super.key, required this.draft});

  @override
  State<BusinessCardReviewSheet> createState() =>
      _BusinessCardReviewSheetState();
}

class _BusinessCardReviewSheetState extends State<BusinessCardReviewSheet> {
  late final List<_Row> _rows = _buildRows(widget.draft.contact);
  bool _showRawText = false;

  /// Flattens the draft into reviewable rows. Only fields that were actually
  /// read appear — an empty field is not shown at all.
  List<_Row> _buildRows(Contact c) {
    final rows = <_Row>[];

    final nameParts = [
      c.salutation,
      c.firstName,
      c.middleName,
      c.lastName,
    ].where((p) => p != null && p.trim().isNotEmpty).join(' ');
    if (nameParts.trim().isNotEmpty) {
      rows.add(
        _Row(
          label: 'Name',
          value: nameParts,
          icon: Icons.person_outline,
          apply: (out) {
            out.salutation = c.salutation;
            out.firstName = c.firstName;
            out.middleName = c.middleName;
            out.lastName = c.lastName;
          },
        ),
      );
    }

    for (final phone in c.phoneNumbers) {
      rows.add(
        _Row(
          label: 'Phone',
          value: phone.number,
          icon: Icons.call_outlined,
          apply: (out) => out.phoneNumbers = [
            ...out.phoneNumbers,
            PhoneNumber(
              number: phone.number,
              type: phone.type,
              label: phone.label,
              isPrimary: out.phoneNumbers.isEmpty,
            ),
          ],
        ),
      );
    }

    for (final email in c.emails) {
      rows.add(
        _Row(
          label: 'Email',
          value: email.email,
          icon: Icons.mail_outline,
          apply: (out) => out.emails = [
            ...out.emails,
            Email(
              email: email.email,
              type: email.type,
              label: email.label,
              isPrimary: out.emails.isEmpty,
            ),
          ],
        ),
      );
    }

    final designation = c.officialDetails?.designation;
    if (designation != null && designation.trim().isNotEmpty) {
      rows.add(
        _Row(
          label: 'Designation',
          value: designation,
          icon: Icons.badge_outlined,
          apply: (out) => out.officialDetails = OfficialDetails(
            designation: designation,
            department: c.officialDetails?.department,
          ),
        ),
      );
    }

    // The work address is reviewed piece by piece, because OCR gets the company
    // right far more often than it gets the street split right.
    for (final address in c.addresses) {
      // The ticked pieces all land on one work address, created on first use.
      Address ensureAddress(Contact out) {
        if (out.addresses.isEmpty) {
          out.addresses = [Address(type: address.type)];
        }
        return out.addresses.first;
      }

      void addPiece(String label, String? value, void Function(Address) set) {
        if (value == null || value.trim().isEmpty) return;
        rows.add(
          _Row(
            label: label,
            value: value,
            icon: Icons.business_outlined,
            apply: (out) => set(ensureAddress(out)),
          ),
        );
      }

      addPiece('Company', address.companyName, (a) => a.companyName = address.companyName);
      addPiece('Street', address.street, (a) => a.street = address.street);
      addPiece('City', address.cityTown, (a) => a.cityTown = address.cityTown);
      addPiece('State', address.state, (a) => a.state = address.state);
      addPiece('Postal code', address.postalCode, (a) => a.postalCode = address.postalCode);
      addPiece('Country', address.country, (a) => a.country = address.country);
    }

    for (final link in c.socialLinks) {
      rows.add(
        _Row(
          label: link.label ?? 'Link',
          value: link.value,
          icon: Icons.link_outlined,
          apply: (out) => out.socialLinks = [
            ...out.socialLinks,
            SocialLink(
              label: link.label,
              value: link.value,
              isPrimary: out.socialLinks.isEmpty,
            ),
          ],
        ),
      );
    }

    return rows;
  }

  /// Builds the contact from the ticked rows only.
  Contact _accepted() {
    final out = Contact(firstName: '');
    for (final row in _rows) {
      if (row.keep) row.apply(out);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final muted = colors.mutedText;
    final anyKept = _rows.any((r) => r.keep);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Read from the card',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Untick anything that came out wrong. You can still edit '
              'everything on the next screen.',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final row in _rows)
                      CheckboxListTile(
                        value: row.keep,
                        onChanged: (v) => setState(() => row.keep = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          row.value,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          row.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                        secondary: Icon(row.icon, color: muted, size: 20),
                      ),
                    if (_rows.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No fields could be read from this card.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                    if (widget.draft.unmatchedLines.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Not placed in a field: '
                        '${widget.draft.unmatchedLines.join(' · ')}',
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _showRawText = !_showRawText),
                      icon: Icon(
                        _showRawText ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                      ),
                      label: Text(
                        _showRawText ? 'Hide all scanned text' : 'Show all scanned text',
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    if (_showRawText)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SelectableText(
                          widget.draft.rawText.isEmpty
                              ? 'Nothing was recognized.'
                              : widget.draft.rawText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: anyKept
                        ? () => Navigator.of(context).pop(_accepted())
                        : null,
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
