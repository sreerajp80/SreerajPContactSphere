// lib/services/speech_service.dart
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:smart_contacts_dialer/core/logging/app_logger.dart';
import 'package:smart_contacts_dialer/services/permission_service.dart';

/// Thin wrapper around the device speech recognizer (`speech_to_text`),
/// shared by voice search (contacts list) and voice dialing (dialer).
///
/// Mirrors the app's other service wrappers: a singleton that never throws
/// into its callers — a denied mic permission, a device without a recognizer,
/// or the host test VM all surface as a `false` return, never a crash.
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speech = SpeechToText();

  /// One-shot init result. `initialize` binds the global status/error
  /// callbacks, so it must run exactly once per process.
  bool _initTried = false;
  bool _available = false;

  /// Completion callback for the *current* listen session, invoked exactly
  /// once when it ends for any reason (final result, silence timeout,
  /// recognizer error, or an explicit [stop]/[cancel]).
  VoidCallback? _onDone;

  bool get isListening => _speech.isListening;

  /// Mic permission + recognizer availability. The permission is re-checked
  /// every call (it can be revoked in Settings); the recognizer probe result
  /// is cached because `initialize` may only run once.
  Future<bool> _ensureAvailable() async {
    if (!await PermissionService().ensureMicrophone()) return false;
    if (_initTried) return _available;
    _initTried = true;
    try {
      _available = await _speech.initialize(
        onStatus: _handleStatus,
        onError: _handleError,
      );
    } catch (e, st) {
      AppLogger.error(
        'SpeechService.initialize failed',
        error: e,
        stackTrace: st,
      );
      _available = false;
    }
    return _available;
  }

  void _handleStatus(String status) {
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      _notifyDone();
    }
  }

  void _handleError(SpeechRecognitionError error) => _notifyDone();

  void _notifyDone() {
    final cb = _onDone;
    _onDone = null;
    cb?.call();
  }

  /// Starts one listen session. [onWords] fires with the words heard so far
  /// while the user speaks (partial results) and once more with
  /// `isFinal: true`; [onDone] fires when the session ends, however it ends,
  /// so the caller can reset its mic UI. Returns false — after telling
  /// [onDone] nothing — when the mic is denied or the device has no
  /// recognizer.
  Future<bool> listen({
    required void Function(String words, bool isFinal) onWords,
    VoidCallback? onDone,
  }) async {
    if (!await _ensureAvailable()) return false;
    if (_speech.isListening) await _speech.stop();
    _onDone = onDone;
    try {
      await _speech.listen(
        onResult: (result) =>
            onWords(result.recognizedWords, result.finalResult),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.search,
          // Stop by itself after a natural pause, and never run on forever.
          // Kept generous so a mid-phrase pause doesn't cut the speaker off
          // before they finish a name.
          pauseFor: const Duration(seconds: 2),
          listenFor: const Duration(seconds: 30),
        ),
      );
      return true;
    } catch (e, st) {
      AppLogger.error('SpeechService.listen failed', error: e, stackTrace: st);
      _notifyDone();
      return false;
    }
  }

  /// Ends the session keeping the last result (the user tapped the mic off).
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {
      /* recognizer already gone — nothing to stop */
    }
    _notifyDone();
  }
}
