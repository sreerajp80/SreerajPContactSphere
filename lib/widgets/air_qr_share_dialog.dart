// lib/widgets/air_qr_share_dialog.dart
//
// Animated QR code streaming dialog for sharing complete contacts (with photos,
// rich addresses, and multi-contact batches) over camera optical air-gap.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:smart_contacts_dialer/models/air_qr_frame.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/services/air_qr_service.dart';
import 'package:smart_contacts_dialer/services/vcard_service.dart';

/// Shows an animated AirQR stream dialog for [contact] or a list of contacts.
Future<void> showAirQrShareDialog(
  BuildContext context, {
  Contact? contact,
  List<Contact>? contacts,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => AirQrShareDialog(contact: contact, contacts: contacts),
  );
}

class AirQrShareDialog extends StatefulWidget {
  final Contact? contact;
  final List<Contact>? contacts;

  const AirQrShareDialog({super.key, this.contact, this.contacts});

  @override
  State<AirQrShareDialog> createState() => _AirQrShareDialogState();
}

class _AirQrShareDialogState extends State<AirQrShareDialog> {
  late List<AirQrFrame> _frames;
  int _currentIndex = 0;
  bool _isPlaying = true;
  int _targetFps = 10; // 10 FPS default
  Timer? _streamTimer;

  @override
  void initState() {
    super.initState();
    _prepareFrames();
    _startStreaming();
  }

  void _prepareFrames() {
    final String payload;
    if (widget.contacts != null && widget.contacts!.isNotEmpty) {
      payload = VCardService().toVCardAll(widget.contacts!);
    } else if (widget.contact != null) {
      payload = VCardService().toVCard(widget.contact!);
    } else {
      payload = '';
    }

    _frames = AirQrService.encodePayload(payload);
  }

  void _startStreaming() {
    _streamTimer?.cancel();
    if (!_isPlaying || _frames.isEmpty) return;

    final intervalMs = (1000 / _targetFps).round();
    _streamTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _frames.length;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _startStreaming();
    } else {
      _streamTimer?.cancel();
    }
  }

  void _changeFps(int newFps) {
    setState(() {
      _targetFps = newFps;
    });
    if (_isPlaying) {
      _startStreaming();
    }
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleName = widget.contact?.fullName ??
        '${widget.contacts?.length ?? 0} Contacts';

    if (_frames.isEmpty) {
      return AlertDialog(
        title: Text(titleName),
        content: const Text('Could not generate AirQR payload for this contact.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final currentFrame = _frames[_currentIndex];
    final frameTypeLabel =
        currentFrame.isParity ? 'Fountain Parity' : 'Systematic Block';

    return AlertDialog(
      title: Text(titleName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sensors, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(
                'Optical Air-Gap Stream (${_frames.length} frames)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox.square(
              dimension: 240,
              child: QrImageView(
                data: currentFrame.toQrString(),
                size: 240,
                backgroundColor: Colors.white,
                errorStateBuilder: (_, _) => const Center(
                  child: Text('Frame rendering error'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Frame ${_currentIndex + 1} / ${_frames.length} • $frameTypeLabel',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                iconSize: 32,
                color: theme.colorScheme.primary,
                onPressed: _togglePlayPause,
                tooltip: _isPlaying ? 'Pause stream' : 'Resume stream',
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('5 FPS'),
                selected: _targetFps == 5,
                onSelected: (_) => _changeFps(5),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text('10 FPS'),
                selected: _targetFps == 10,
                onSelected: (_) => _changeFps(10),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text('15 FPS'),
                selected: _targetFps == 15,
                onSelected: (_) => _changeFps(15),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
