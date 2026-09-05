// lib/repositories/flagged_number_repository.dart
import 'dart:async' show unawaited;

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';
import 'package:smart_contacts_dialer/utils/phone_normalizer.dart';

/// One user-flagged number: blocked (never rings) or spam (rings silently and
/// is labelled when the spam filter is on). Read-only row over `flagged_numbers`.
class FlaggedNumber {
  final int id;

  /// The number as the user entered it (shown in the management list).
  final String number;

  /// Canonical E.164 match key (raw digits when the input couldn't be parsed).
  final String numberE164;

  /// [FlaggedNumberRepository.kindBlocked] or [FlaggedNumberRepository.kindSpam].
  final String kind;

  final DateTime createdAt;

  const FlaggedNumber({
    required this.id,
    required this.number,
    required this.numberE164,
    required this.kind,
    required this.createdAt,
  });

  factory FlaggedNumber.fromMap(Map<String, dynamic> map) => FlaggedNumber(
    id: map['id'] as int,
    number: (map['number'] as String?) ?? '',
    numberE164: (map['number_e164'] as String?) ?? '',
    kind: (map['kind'] as String?) ?? FlaggedNumberRepository.kindBlocked,
    createdAt:
        DateTime.tryParse((map['created_at'] as String?) ?? '') ??
        DateTime.now(),
  );
}

/// CRUD over the `flagged_numbers` table (the user's blocked / spam lists),
/// plus the push that mirrors those lists into native SharedPreferences so the
/// call-screening service can consult them synchronously — before the phone
/// rings and before the Flutter engine is up on a cold start (the same pattern
/// as the ringtone mirror).
///
/// Numbers are matched *exactly* after normalizing both sides to E.164 under
/// the user's Default country, so "9876543210" and "+91 98765 43210" are the
/// same entry.
class FlaggedNumberRepository {
  static const String kindBlocked = 'blocked';
  static const String kindSpam = 'spam';

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TelecomService _telecom = TelecomService();

  /// Canonical match key for [raw]: E.164 under [defaultIso], falling back to
  /// the bare digit string when the input can't be parsed. Null when there are
  /// no digits at all. Short codes (fewer than 7 digits without an explicit
  /// "+") skip E.164 — the parser would bolt the country code onto them, and
  /// the native screener (which sees the short caller ID verbatim) could then
  /// never match the stored key.
  static String? matchKey(String raw, {required String defaultIso}) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length < 7 && !raw.trim().startsWith('+')) return digits;
    return PhoneNormalizer.toE164(raw, defaultIso: defaultIso) ?? digits;
  }

  /// Flags [number] as [kind]. Normalizes under the persisted Default country
  /// (or [defaultIso] when given). Idempotent: re-flagging an already-flagged
  /// number is a no-op. Returns false when [number] has no digits.
  Future<bool> add(
    String number, {
    required String kind,
    String? defaultIso,
  }) async {
    final iso = defaultIso ?? await AppSettings.readDefaultCountryIso();
    final key = matchKey(number, defaultIso: iso);
    if (key == null) return false;
    final db = await _dbHelper.database;
    await db.rawInsert(
      '''
      INSERT OR IGNORE INTO flagged_numbers (number, number_e164, kind, created_at)
      VALUES (?, ?, ?, ?)
      ''',
      [number.trim(), key, kind, DateTime.now().toIso8601String()],
    );
    unawaited(pushScreeningMirror());
    if (kind == kindBlocked) {
      await _disconnectIfRunning(key);
    }
    return true;
  }

  /// If a call is currently running and matches [key], disconnects it immediately.
  Future<void> _disconnectIfRunning(String key) async {
    try {
      final active = await _telecom.activeCall();
      if (!active.hasCall) return;
      final activeNum = active.number;
      if (activeNum == null || activeNum.isEmpty) return;
      final activeDigits = activeNum.replaceAll(RegExp(r'\D'), '');
      final keyDigits = key.replaceAll(RegExp(r'\D'), '');
      if (keyDigits.isNotEmpty &&
          (keyDigits == activeDigits ||
              (keyDigits.length >= 7 && activeDigits.endsWith(keyDigits)) ||
              (activeDigits.length >= 7 && keyDigits.endsWith(activeDigits)))) {
        await _telecom.disconnect();
      }
    } catch (_) {
      // Best-effort: native mirror also disconnects matching live calls.
    }
  }

  /// Removes one flagged entry by row id.
  Future<void> remove(int id) async {
    final db = await _dbHelper.database;
    await db.delete('flagged_numbers', where: 'id = ?', whereArgs: [id]);
    unawaited(pushScreeningMirror());
  }

  /// Clears [kind] from [number] (normalized the same way [add] stores it).
  Future<void> removeNumber(
    String number, {
    required String kind,
    String? defaultIso,
  }) async {
    final iso = defaultIso ?? await AppSettings.readDefaultCountryIso();
    final key = matchKey(number, defaultIso: iso);
    if (key == null) return;
    final db = await _dbHelper.database;
    await db.delete(
      'flagged_numbers',
      where: 'number_e164 = ? AND kind = ?',
      whereArgs: [key, kind],
    );
    unawaited(pushScreeningMirror());
  }

  /// All entries of [kind], newest first.
  Future<List<FlaggedNumber>> listByKind(String kind) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'flagged_numbers',
      where: 'kind = ?',
      whereArgs: [kind],
      orderBy: 'created_at DESC, id DESC',
    );
    return rows.map(FlaggedNumber.fromMap).toList();
  }

  /// Whether [number] carries [kind], matching by normalized E.164 (with the
  /// digit-string fallback for unparseable inputs).
  Future<bool> isFlagged(
    String number, {
    required String kind,
    String? defaultIso,
  }) async {
    final iso = defaultIso ?? await AppSettings.readDefaultCountryIso();
    final key = matchKey(number, defaultIso: iso);
    if (key == null) return false;
    final db = await _dbHelper.database;
    final rows = await db.query(
      'flagged_numbers',
      columns: ['id'],
      where: 'number_e164 = ? AND kind = ?',
      whereArgs: [key, kind],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Pushes both lists (as bare digit strings — the native side matches on
  /// digits) to the native screening mirror. Fire-and-forget from the CRUD
  /// methods; also called on app load (see [AppSettings.load]) so existing
  /// installs get a mirror without waiting for the next edit.
  Future<void> pushScreeningMirror() async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        'flagged_numbers',
        columns: ['number_e164', 'kind'],
      );
      final blocked = <String>[];
      final spam = <String>[];
      for (final r in rows) {
        final digits = ((r['number_e164'] as String?) ?? '').replaceAll(
          RegExp(r'\D'),
          '',
        );
        if (digits.isEmpty) continue;
        ((r['kind'] as String?) == kindSpam ? spam : blocked).add(digits);
      }
      await _telecom.setScreeningMirror(
        blockedNumbers: blocked,
        spamNumbers: spam,
      );
    } catch (_) {
      // Best-effort: the mirror refreshes on the next change / app load.
    }
  }
}
