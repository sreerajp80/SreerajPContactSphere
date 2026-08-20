// lib/screens/business_card_scan_screen.dart
//
// Business card scanner: take a photo of a paper card (or pick one from the
// gallery), read it on-device with BusinessCardScanService, map the lines to
// contact fields with BusinessCardParser, let the user check the result in
// BusinessCardReviewSheet, then open the normal Add contact form prefilled.
//
// Nothing is written to the database here — saving stays the user's action on
// the Add contact screen, the same way the QR import path works.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/screens/add_edit_contact_screen.dart';
import 'package:smart_contacts_dialer/services/business_card_scan_service.dart';
import 'package:smart_contacts_dialer/services/permission_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/theme/app_theme.dart';
import 'package:smart_contacts_dialer/utils/business_card_parser.dart';
import 'package:smart_contacts_dialer/widgets/business_card_review_sheet.dart';

class BusinessCardScanScreen extends StatefulWidget {
  const BusinessCardScanScreen({super.key});

  @override
  State<BusinessCardScanScreen> createState() => _BusinessCardScanScreenState();
}

/// What the screen is showing right now.
enum _Stage { idle, reading, nothingFound, failed }

class _BusinessCardScanScreenState extends State<BusinessCardScanScreen> {
  final _picker = ImagePicker();
  final _scanner = BusinessCardScanService();

  _Stage _stage = _Stage.idle;
  String? _message;

  /// The card image being read, kept so the empty/failed states can show it.
  String? _imagePath;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _scan(ImageSource source) async {
    if (source == ImageSource.camera &&
        !await PermissionService().ensureCamera()) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.failed;
        _message =
            'Camera access is needed to photograph a card. Allow Camera for '
            'SreerajP Contacts Sphere in system settings, or pick a photo instead.';
      });
      return;
    }

    XFile? picked;
    try {
      picked = await _picker.pickImage(source: source);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.failed;
        _message = 'Could not get the image: $e';
      });
      return;
    }
    if (picked == null || !mounted) return;
    final imagePath = picked.path;

    setState(() {
      _stage = _Stage.reading;
      _imagePath = imagePath;
      _message = null;
    });

    // Read the user's Default country before the await — it decides how a bare
    // national number on the card gets its country code.
    final defaultIso = context.read<AppSettings>().defaultCountryIso;

    BusinessCardText text;
    try {
      text = await _scanner.readCard(imagePath);
    } on BusinessCardScanException catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.failed;
        _message = e.message;
      });
      return;
    }

    final draft = BusinessCardParser.parse(
      text.lines,
      defaultIso: defaultIso,
      rawText: text.rawText,
    );

    if (!mounted) return;

    if (draft.isEmpty) {
      setState(() {
        _stage = _Stage.nothingFound;
        _message = text.isEmpty
            ? 'No text was found on this image.'
            : 'Text was found, but no contact details could be read from it.';
      });
      return;
    }

    final accepted = await showBusinessCardReviewSheet(context, draft);
    if (!mounted) return;

    if (accepted == null) {
      // "Retake" — back to the two buttons, ready for another shot.
      setState(() {
        _stage = _Stage.idle;
        _imagePath = null;
      });
      return;
    }

    await _openForm(accepted);
  }

  /// Opens the Add contact form prefilled with [contact]. Pops this screen with
  /// `true` when the contact was saved, so the list behind it reloads.
  Future<void> _openForm(Contact contact) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEditContactScreen(contact: contact)),
    );
    if (!mounted) return;
    if (saved == true) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _stage = _Stage.idle;
        _imagePath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final muted = colors.mutedText;
    final busy = _stage == _Stage.reading;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan business card')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _preview(colors, muted, busy),
                        const SizedBox(height: 20),
                        Text(
                          _headline(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _message ??
                              'Lay the card flat in good light and fill the '
                                  'frame with it. The card is read on this '
                                  'phone — the photo and its text never leave '
                                  'the device.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: busy ? null : () => _scan(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(
                  _stage == _Stage.idle ? 'Take photo' : 'Take another photo',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: busy ? null : () => _scan(ImageSource.gallery),
                icon: const Icon(Icons.image_outlined),
                label: const Text('Choose from gallery'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: busy ? null : () => _openForm(Contact(firstName: '')),
                child: const Text('Enter manually instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _headline() {
    switch (_stage) {
      case _Stage.idle:
        return 'Photograph a business card';
      case _Stage.reading:
        return 'Reading the card…';
      case _Stage.nothingFound:
        return 'Nothing to fill in';
      case _Stage.failed:
        return 'Could not read the card';
    }
  }

  /// The card image once one is picked, a placeholder frame before that, with a
  /// progress overlay while the recognizer runs.
  Widget _preview(AppColors colors, Color muted, bool busy) {
    final path = _imagePath;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: muted.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (path != null)
            Image.file(File(path), fit: BoxFit.cover)
          else
            Center(
              child: Icon(
                Icons.badge_outlined,
                size: 56,
                color: muted.withValues(alpha: 0.6),
              ),
            ),
          if (busy)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.45),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
