// lib/services/air_qr_service.dart
//
// High-performance Optical Fountain & Systematic Stream Decoder & Encoder Engine.
// Allows large vCards and multi-contact payloads to be streamed over camera
// using animated QR codes (AirQR) without Bluetooth or network connections.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:smart_contacts_dialer/models/air_qr_frame.dart';

enum AirQrStatus { idle, receiving, completed, error }

class AirQrProgress {
  final String? streamId;
  final int totalBlocks;
  final int receivedBlockCount;
  final Set<int> capturedIndices;
  final double fps;
  final AirQrStatus status;
  final String? reassembledContent;
  final String? errorMessage;

  const AirQrProgress({
    this.streamId,
    this.totalBlocks = 0,
    this.receivedBlockCount = 0,
    this.capturedIndices = const {},
    this.fps = 0.0,
    required this.status,
    this.reassembledContent,
    this.errorMessage,
  });

  double get progressRatio =>
      totalBlocks > 0 ? (receivedBlockCount / totalBlocks).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progressRatio * 100).round();
}

class AirQrService {
  static const int defaultBlockSize = 180;

  String? _activeStreamId;
  int _totalBlocks = 0;
  final Map<int, List<int>> _resolvedBlocks = {};
  final List<AirQrFrame> _pendingParityFrames = [];

  DateTime? _lastFrameTime;
  int _frameCountInWindow = 0;
  double _currentFps = 0.0;

  /// Resets the receiver session state.
  void reset() {
    _activeStreamId = null;
    _totalBlocks = 0;
    _resolvedBlocks.clear();
    _pendingParityFrames.clear();
    _lastFrameTime = null;
    _frameCountInWindow = 0;
    _currentFps = 0.0;
  }

  /// Processes an incoming raw QR payload frame string and returns current stream progress.
  AirQrProgress processFrameString(String raw, AirQrProgress currentProgress) {
    final frame = AirQrFrame.parse(raw);
    if (frame == null) {
      return currentProgress;
    }

    _updateFps();

    // Check if new stream detected
    if (_activeStreamId == null || _activeStreamId != frame.streamId) {
      reset();
      _activeStreamId = frame.streamId;
      _totalBlocks = frame.totalBlocks;
    }

    // Insert systematic frame directly
    if (!frame.isParity) {
      final index = frame.sequenceIndex;
      if (!_resolvedBlocks.containsKey(index)) {
        if (_validateChecksum(frame.payloadBytes, frame.checksum)) {
          _resolvedBlocks[index] = frame.payloadBytes;
          _reducePendingParityFrames();
        }
      }
    } else {
      // Process LT Fountain Parity Frame
      _addParityFrame(frame);
    }

    final capturedIndices = Set<int>.from(_resolvedBlocks.keys);
    final isComplete =
        _resolvedBlocks.length >= _totalBlocks && _totalBlocks > 0;

    if (isComplete) {
      final reassembled = _reassemblePayload();
      if (reassembled != null) {
        return AirQrProgress(
          streamId: _activeStreamId,
          totalBlocks: _totalBlocks,
          receivedBlockCount: _resolvedBlocks.length,
          capturedIndices: capturedIndices,
          fps: _currentFps,
          status: AirQrStatus.completed,
          reassembledContent: reassembled,
        );
      } else {
        return AirQrProgress(
          streamId: _activeStreamId,
          totalBlocks: _totalBlocks,
          receivedBlockCount: _resolvedBlocks.length,
          capturedIndices: capturedIndices,
          fps: _currentFps,
          status: AirQrStatus.error,
          errorMessage: 'Checksum verification failed during reassembly.',
        );
      }
    }

    return AirQrProgress(
      streamId: _activeStreamId,
      totalBlocks: _totalBlocks,
      receivedBlockCount: _resolvedBlocks.length,
      capturedIndices: capturedIndices,
      fps: _currentFps,
      status: AirQrStatus.receiving,
    );
  }

  void _addParityFrame(AirQrFrame frame) {
    final List<int> unresolvedIndices = [];
    List<int> payload = List.from(frame.payloadBytes);

    for (final idx in frame.indices) {
      if (_resolvedBlocks.containsKey(idx)) {
        payload = _xorBytes(payload, _resolvedBlocks[idx]!);
      } else {
        unresolvedIndices.add(idx);
      }
    }

    if (unresolvedIndices.length == 1) {
      final singleIdx = unresolvedIndices.first;
      if (!_resolvedBlocks.containsKey(singleIdx)) {
        _resolvedBlocks[singleIdx] = payload;
        _reducePendingParityFrames();
      }
    } else if (unresolvedIndices.length > 1) {
      _pendingParityFrames.add(
        AirQrFrame(
          streamId: frame.streamId,
          totalBlocks: frame.totalBlocks,
          sequenceIndex: -1,
          isParity: true,
          degree: unresolvedIndices.length,
          indices: unresolvedIndices,
          checksum: frame.checksum,
          payloadBytes: payload,
        ),
      );
    }
  }

  void _reducePendingParityFrames() {
    bool progress = true;
    while (progress) {
      progress = false;
      final remaining = <AirQrFrame>[];

      for (final frame in _pendingParityFrames) {
        final List<int> unresolvedIndices = [];
        List<int> payload = List.from(frame.payloadBytes);

        for (final idx in frame.indices) {
          if (_resolvedBlocks.containsKey(idx)) {
            payload = _xorBytes(payload, _resolvedBlocks[idx]!);
          } else {
            unresolvedIndices.add(idx);
          }
        }

        if (unresolvedIndices.length == 1) {
          final singleIdx = unresolvedIndices.first;
          if (!_resolvedBlocks.containsKey(singleIdx)) {
            _resolvedBlocks[singleIdx] = payload;
            progress = true;
          }
        } else if (unresolvedIndices.length > 1) {
          remaining.add(
            AirQrFrame(
              streamId: frame.streamId,
              totalBlocks: frame.totalBlocks,
              sequenceIndex: -1,
              isParity: true,
              degree: unresolvedIndices.length,
              indices: unresolvedIndices,
              checksum: frame.checksum,
              payloadBytes: payload,
            ),
          );
        }
      }
      _pendingParityFrames.clear();
      _pendingParityFrames.addAll(remaining);
    }
  }

  List<int> _xorBytes(List<int> a, List<int> b) {
    final len = min(a.length, b.length);
    final result = List<int>.filled(len, 0);
    for (int i = 0; i < len; i++) {
      result[i] = a[i] ^ b[i];
    }
    return result;
  }

  void _updateFps() {
    final now = DateTime.now();
    if (_lastFrameTime == null) {
      _lastFrameTime = now;
      _frameCountInWindow = 1;
      return;
    }

    _frameCountInWindow++;
    final diffMs = now.difference(_lastFrameTime!).inMilliseconds;
    if (diffMs >= 1000) {
      _currentFps = (_frameCountInWindow * 1000.0) / diffMs;
      _frameCountInWindow = 0;
      _lastFrameTime = now;
    }
  }

  String? _reassemblePayload() {
    try {
      final List<int> fullBytes = [];
      for (int i = 0; i < _totalBlocks; i++) {
        final block = _resolvedBlocks[i];
        if (block == null) return null;
        fullBytes.addAll(block);
      }

      // Trim trailing padding null bytes
      while (fullBytes.isNotEmpty && fullBytes.last == 0) {
        fullBytes.removeLast();
      }

      final String result = utf8.decode(fullBytes, allowMalformed: true);
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('Payload reassembly error: $e');
      return null;
    }
  }

  /// Standard IEEE 802.3 CRC32 checksum over payload bytes.
  static int computeCrc32(List<int> bytes) {
    int crc = 0xFFFFFFFF;
    for (final b in bytes) {
      crc ^= b;
      for (int i = 0; i < 8; i++) {
        if ((crc & 1) != 0) {
          crc = (crc >> 1) ^ 0xEDB88320;
        } else {
          crc >>= 1;
        }
      }
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }

  bool _validateChecksum(List<int> bytes, int expectedChecksum) {
    return computeCrc32(bytes) == expectedChecksum;
  }

  /// Encodes [payload] into a sequence of systematic and LT Fountain parity frames.
  static List<AirQrFrame> encodePayload(
    String payload, {
    int blockSize = defaultBlockSize,
    int extraParityRatioPercent = 50,
  }) {
    final bytes = utf8.encode(payload);
    final totalBlocks = (bytes.length / blockSize).ceil();
    final streamId = (Random().nextInt(899999) + 100000).toString();

    final List<List<int>> sourceBlocks = [];
    for (int i = 0; i < totalBlocks; i++) {
      final start = i * blockSize;
      final end = min(start + blockSize, bytes.length);
      final chunk = bytes.sublist(start, end);
      if (chunk.length < blockSize) {
        final padded = List<int>.filled(blockSize, 0);
        padded.setRange(0, chunk.length, chunk);
        sourceBlocks.add(padded);
      } else {
        sourceBlocks.add(chunk);
      }
    }

    final List<AirQrFrame> frames = [];

    // 1. Systematic Frames (v1)
    for (int i = 0; i < totalBlocks; i++) {
      final block = sourceBlocks[i];
      final checksum = computeCrc32(block);
      frames.add(
        AirQrFrame(
          streamId: streamId,
          totalBlocks: totalBlocks,
          sequenceIndex: i,
          isParity: false,
          degree: 1,
          indices: [i],
          checksum: checksum,
          payloadBytes: block,
        ),
      );
    }

    // 2. LT Fountain Parity Frames (LT1)
    final parityCount = ((totalBlocks * extraParityRatioPercent) / 100).ceil();
    final rand = Random(42);

    for (int p = 0; p < parityCount; p++) {
      final degree = min(totalBlocks, max(2, rand.nextInt(totalBlocks) + 1));
      final indicesSet = <int>{};
      while (indicesSet.length < degree) {
        indicesSet.add(rand.nextInt(totalBlocks));
      }
      final indicesList = indicesSet.toList()..sort();

      final List<int> combinedPayload = List.filled(blockSize, 0);
      for (final idx in indicesList) {
        final block = sourceBlocks[idx];
        for (int b = 0; b < blockSize; b++) {
          combinedPayload[b] ^= block[b];
        }
      }

      final checksum = computeCrc32(combinedPayload);
      frames.add(
        AirQrFrame(
          streamId: streamId,
          totalBlocks: totalBlocks,
          sequenceIndex: -1,
          isParity: true,
          degree: indicesList.length,
          indices: indicesList,
          checksum: checksum,
          payloadBytes: combinedPayload,
        ),
      );
    }

    return frames;
  }
}
