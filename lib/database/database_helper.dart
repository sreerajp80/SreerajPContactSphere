// lib/database/database_helper.dart
import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
// SQLCipher-backed open (encrypts the DB at rest). Prefixed because it exports
// the same top-level names as sqflite; we only use its openDatabase here.
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;
import 'package:path/path.dart';

import 'package:smart_contacts_dialer/models/relationship.dart';
import 'package:smart_contacts_dialer/utils/malayalam_transliterator.dart';
import 'package:smart_contacts_dialer/database/db_key.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// The in-flight open, cached so concurrent first-time callers share ONE
  /// `_initDatabase()` instead of each starting their own. Without this,
  /// multiple services hitting `database` at startup each opened the DB and each
  /// called `DbKey.getOrCreate()`; on a fresh install that generated several
  /// different keys (last write wins in secure storage) while the DB file was
  /// created with a different one — an unrecoverable key/DB mismatch on the next
  /// launch. `??=` is atomic on Dart's single-threaded event loop, so exactly
  /// one open runs.
  static Future<Database>? _opening;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final opening = _opening ??= _initDatabase();
    try {
      final db = await opening;
      _database = db;
      return db;
    } catch (_) {
      _opening = null; // let a later call retry after a failed open
      rethrow;
    }
  }

  static String? _testDatabaseName;

  /// For unit tests: sets a custom database file name (e.g. 'smart_contacts_test_backup.db')
  /// so parallel test runs use isolated databases.
  static void setTestDatabaseName(String? name) {
    _testDatabaseName = name;
  }

  /// Encryption runs only on-device (Android). Under `flutter test` the process
  /// runs on the host VM where SQLCipher / the Keystore are unavailable and the
  /// tests inject `databaseFactoryFfi`; there we open plain sqflite so that
  /// injected factory is honored. This flips based on the runtime platform, so
  /// no test needs to know about encryption.
  static final bool _encryptionEnabled = Platform.isAndroid;

  Future<Database> _initDatabase() async {
    final String dbName = _testDatabaseName ?? 'smart_contacts.db';
    final String path = join(await getDatabasesPath(), dbName);

    if (!_encryptionEnabled) {
      return await openDatabase(
        path,
        version: 27,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    }

    final String key = await DbKey.getOrCreate();
    return await cipher.openDatabase(
      path,
      password: key,
      version: 27,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  /// Runs for every open, before create/upgrade. sqflite does NOT enable
  /// foreign keys by default, so the schema's ON DELETE CASCADE / SET NULL
  /// clauses are inert without this — enabling it here makes them enforced.
  /// Also switches the DB to WAL (Write-Ahead Logging) mode for concurrent
  /// readers with a single writer. WAL persists in the DB file header, but
  /// this hook runs per connection so it is safely (re)applied on every open.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.rawQuery('PRAGMA journal_mode = WAL');
  }

  /// Runs for every open, after create/upgrade. Self-heals schema pieces that a
  /// version-gated migration can miss when a development build bumped the DB
  /// version before the matching migration existed (so `oldVersion` is already
  /// past the gate and the ALTER never runs). Each step is existence-checked via
  /// PRAGMA, so it is cheap and safe to run on every open regardless of version.
  Future<void> _onOpen(Database db) async {
    await _ensureMergedConfirmedColumn(db);
    await _ensureEmergencyTables(db);
    await _ensureAuditTable(db);
    await _ensureEphemeralColumns(db);
    await _ensureConfirmedMergePhonesTable(db);
    await _ensureCallOutcomeColumn(db);
    if (await staleContactSearchKeyCount(db) > 0) {
      await rebuildContactSearchKeys(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Contacts table
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        salutation TEXT,
        first_name TEXT NOT NULL,
        middle_name TEXT,
        last_name TEXT,
        formal_name TEXT,
        name_translit TEXT,
        name_phonetic TEXT,
        sort_first TEXT,
        sort_last TEXT,
        gender TEXT,
        dob TEXT,
        photo_path TEXT,
        card_photo_path TEXT,
        ringtone_path TEXT,
        ringtone_label TEXT,
        blood_group TEXT,
        anniversary TEXT,
        meetiversary TEXT,
        relationship_score REAL DEFAULT 0,
        is_secret INTEGER DEFAULT 0,
        is_favorite INTEGER DEFAULT 0,
        is_self INTEGER DEFAULT 0,
        is_ephemeral INTEGER DEFAULT 0,
        ephemeral_expires_at TEXT,
        ephemeral_auto_delete_call INTEGER DEFAULT 0,
        ephemeral_call_count INTEGER DEFAULT 0,
        device_id TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Phone numbers table
    await db.execute('''
      CREATE TABLE phone_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        number TEXT NOT NULL,
        label TEXT,
        type TEXT CHECK(type IN ('personal', 'official')),
        is_primary INTEGER DEFAULT 0,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');

    // Emails table
    await db.execute('''
      CREATE TABLE emails (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        email TEXT NOT NULL,
        label TEXT,
        type TEXT CHECK(type IN ('personal', 'official')),
        is_primary INTEGER DEFAULT 0,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');

    // Addresses table
    await db.execute('''
      CREATE TABLE addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        type TEXT CHECK(type IN ('personal', 'official')),
        house_name TEXT,
        company_name TEXT,
        street TEXT,
        post_office TEXT,
        city_town TEXT,
        village_municipality TEXT,
        postal_code TEXT,
        state TEXT,
        country TEXT,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');

    // Groups table
    await db.execute('''
      CREATE TABLE groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        ringtone_path TEXT,
        ringtone_label TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Contact-Group relationship table
    await db.execute('''
      CREATE TABLE contact_groups (
        contact_id INTEGER,
        group_id INTEGER,
        PRIMARY KEY (contact_id, group_id),
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE,
        FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE
      )
    ''');

    // Call logs table
    await db.execute('''
      CREATE TABLE call_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        phone_number TEXT NOT NULL,
        call_type TEXT CHECK(call_type IN ('incoming', 'outgoing', 'missed', 'blocked')),
        call_outcome TEXT,
        duration INTEGER,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        call_intent TEXT,
        notes TEXT,
        sim_id TEXT,
        sim_label TEXT,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE SET NULL
      )
    ''');

    // Relationships table
    await db.execute('''
      CREATE TABLE relationships (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        related_contact_id INTEGER,
        relationship_type TEXT,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE,
        FOREIGN KEY (related_contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');

    // Interactions table for relationship scoring
    await db.execute('''
      CREATE TABLE interactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        interaction_type TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        emotional_tone TEXT,
        duration INTEGER,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');

    // Reminders table
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        reminder_text TEXT,
        reminder_time TEXT,
        location TEXT,
        is_completed INTEGER DEFAULT 0,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');

    // Official details table
    await db.execute('''
      CREATE TABLE official_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER UNIQUE,
        designation TEXT,
        department TEXT,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');

    await _createSocialLinksAndTags(db);
    await _createMergedDeviceIds(db);
    await _createFlaggedNumbers(db);
    await _ensureAuditTable(db);
    await _ensureConfirmedMergePhonesTable(db);
    await _createIndexes(db);
  }

  /// Numbers the user has flagged: `kind` = 'blocked' (never ring; rejected by
  /// the native call-screening service) or 'spam' (ring silently + label when
  /// the spam filter is on). One number can carry both kinds (two rows).
  /// `number_e164` is the canonical match key (raw digits when unparseable).
  Future<void> _createFlaggedNumbers(Database db) async {
    await db.execute('''
      CREATE TABLE flagged_numbers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT NOT NULL,
        number_e164 TEXT NOT NULL,
        kind TEXT NOT NULL CHECK(kind IN ('blocked', 'spam')),
        created_at TEXT NOT NULL,
        UNIQUE(number_e164, kind)
      )
    ''');
  }

  /// Records every device address-book `device_id` that has been absorbed into a
  /// contact by the auto-merge-on-import dedup, so an absorbed device contact is
  /// recognised (and skipped) on subsequent syncs instead of being re-imported as
  /// a fresh duplicate. The contact a `device_id` resolves to may differ from
  /// that contact's own `contacts.device_id` (which holds its primary link).
  /// Remembers the phone numbers (normalized digits) involved in a
  /// user-confirmed merge, mapped to the surviving contact. `merged_device_ids`
  /// keys the same fact on Android's device-contact id, but that id is not
  /// permanent — Android can reassign it when it re-links/re-splits a
  /// contact's raw contacts (e.g. a WhatsApp resync), which makes an
  /// already-merged duplicate look brand-new on the next device sync. Keying
  /// this table on the phone number instead survives that reassignment.
  /// `IF NOT EXISTS` + called from both `_onCreate` and `_onOpen` so it
  /// self-heals a DB that was version-bumped during development before this
  /// migration existed (see the other `_ensure*` methods in this file).
  Future<void> _ensureConfirmedMergePhonesTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS confirmed_merge_phones (
        digits TEXT PRIMARY KEY,
        contact_id INTEGER NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_confirmed_merge_phones_contact_id '
      'ON confirmed_merge_phones(contact_id)',
    );
  }

  Future<void> _createMergedDeviceIds(Database db) async {
    await db.execute('''
      CREATE TABLE merged_device_ids (
        device_id TEXT PRIMARY KEY,
        contact_id INTEGER NOT NULL,
        user_confirmed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Social links and free-text tags. Both are per-contact child tables added
  /// in DB v3 to back the redesigned Add/Edit contact screen.
  Future<void> _createSocialLinksAndTags(Database db) async {
    await db.execute('''
      CREATE TABLE social_links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        label TEXT,
        value TEXT NOT NULL,
        is_primary INTEGER DEFAULT 0,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        name TEXT NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Indexes on the foreign keys used for per-contact lookups and joins.
  /// Without these, loading a contact's children is a full scan per table.
  Future<void> _createIndexes(Database db) async {
    const statements = <String>[
      'CREATE INDEX IF NOT EXISTS idx_phone_numbers_contact_id ON phone_numbers(contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_emails_contact_id ON emails(contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_addresses_contact_id ON addresses(contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_contact_groups_group_id ON contact_groups(group_id)',
      'CREATE INDEX IF NOT EXISTS idx_call_logs_contact_id ON call_logs(contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_relationships_contact_id ON relationships(contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_relationships_related_id ON relationships(related_contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_interactions_contact_id ON interactions(contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_reminders_contact_id ON reminders(contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_social_links_contact_id ON social_links(contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_tags_contact_id ON tags(contact_id)',
      'CREATE INDEX IF NOT EXISTS idx_contacts_device_id ON contacts(device_id)',
      'CREATE INDEX IF NOT EXISTS idx_merged_device_ids_contact_id ON merged_device_ids(contact_id)',
      // Speed up duplicate detection: the phone self-join and the name branch.
      'CREATE INDEX IF NOT EXISTS idx_phone_numbers_number ON phone_numbers(number)',
      'CREATE INDEX IF NOT EXISTS idx_contacts_name ON contacts(first_name, last_name)',
      // Speed up the dialer's favorites read.
      'CREATE INDEX IF NOT EXISTS idx_contacts_is_favorite ON contacts(is_favorite)',
      // Speed up the "Self" (phone owner) lookup / list pinning.
      'CREATE INDEX IF NOT EXISTS idx_contacts_is_self ON contacts(is_self)',
      // Speed up ephemeral contact cleanup / queries.
      'CREATE INDEX IF NOT EXISTS idx_contacts_is_ephemeral ON contacts(is_ephemeral)',
    ];
    for (final sql in statements) {
      await db.execute(sql);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 -> v2: add the FK indexes that v1 installs never had.
    if (oldVersion < 2) {
      await _createIndexes(db);
    }
    // v2 -> v3: add social_links + tags tables (and their FK indexes).
    if (oldVersion < 3) {
      await _createSocialLinksAndTags(db);
      await _createIndexes(db);
    }
    // v3 -> v4: per-contact ringtone (file path + display label) on contacts.
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE contacts ADD COLUMN ringtone_path TEXT');
      await db.execute('ALTER TABLE contacts ADD COLUMN ringtone_label TEXT');
    }
    // v4 -> v5: device address-book link for two-way sync.
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE contacts ADD COLUMN device_id TEXT');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_contacts_device_id ON contacts(device_id)',
      );
    }
    // v5 -> v6: track device_ids absorbed by auto-merge-on-import dedup.
    if (oldVersion < 6) {
      await _createMergedDeviceIds(db);
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_merged_device_ids_contact_id ON merged_device_ids(contact_id)',
      );
    }
    // v6 -> v7: indexes that speed up duplicate detection.
    if (oldVersion < 7) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_phone_numbers_number ON phone_numbers(number)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_contacts_name ON contacts(first_name, last_name)',
      );
    }
    // v7 -> v8: favorites flag on contacts (for the dialer's Favorites list).
    if (oldVersion < 8) {
      await db.execute(
        'ALTER TABLE contacts ADD COLUMN is_favorite INTEGER DEFAULT 0',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_contacts_is_favorite ON contacts(is_favorite)',
      );
    }
    // v8 -> v9: which SIM a call came in / went out on (id + display label).
    if (oldVersion < 9) {
      await db.execute('ALTER TABLE call_logs ADD COLUMN sim_id TEXT');
      await db.execute('ALTER TABLE call_logs ADD COLUMN sim_label TEXT');
    }
    // v9 -> v10: per-contact "calling card" image (full-screen in-call backdrop photo).
    if (oldVersion < 10) {
      await db.execute('ALTER TABLE contacts ADD COLUMN card_photo_path TEXT');
    }
    // v10 -> v11: "Self" flag — the phone owner's own record, pinned first.
    if (oldVersion < 11) {
      await db.execute(
        'ALTER TABLE contacts ADD COLUMN is_self INTEGER DEFAULT 0',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_contacts_is_self ON contacts(is_self)',
      );
    }
    // v11 -> v12: romanized name search key, so an English-script query can
    // match Malayalam-script names. Backfilled here for existing rows; the
    // repository keeps it current on every insert/update.
    if (oldVersion < 12) {
      await db.execute('ALTER TABLE contacts ADD COLUMN name_translit TEXT');
      final rows = await db.query(
        'contacts',
        columns: ['id', 'salutation', 'first_name', 'middle_name', 'last_name'],
      );
      final batch = db.batch();
      for (final r in rows) {
        final name = [
          r['salutation'],
          r['first_name'],
          r['middle_name'],
          r['last_name'],
        ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
        batch.update(
          'contacts',
          {'name_translit': searchKey(name)},
          where: 'id = ?',
          whereArgs: [r['id']],
        );
      }
      await batch.commit(noResult: true);
    }
    // v12 -> v13: user-flagged numbers (blocked / spam) for call screening, and
    // a rebuilt call_logs whose CHECK admits the new 'blocked' call type (a
    // CHECK constraint can't be altered in place, so: rename → recreate → copy).
    if (oldVersion < 13) {
      await _createFlaggedNumbers(db);
      await db.execute('ALTER TABLE call_logs RENAME TO call_logs_v12');
      await db.execute('''
        CREATE TABLE call_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER,
          phone_number TEXT NOT NULL,
          call_type TEXT CHECK(call_type IN ('incoming', 'outgoing', 'missed', 'blocked')),
          duration INTEGER,
          timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
          call_intent TEXT,
          notes TEXT,
          sim_id TEXT,
          sim_label TEXT,
          FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE SET NULL
        )
      ''');
      await db.execute('''
        INSERT INTO call_logs (id, contact_id, phone_number, call_type, duration,
                               timestamp, call_intent, notes, sim_id, sim_label)
        SELECT id, contact_id, phone_number, call_type, duration,
               timestamp, call_intent, notes, sim_id, sim_label
        FROM call_logs_v12
      ''');
      await db.execute('DROP TABLE call_logs_v12');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_call_logs_contact_id ON call_logs(contact_id)',
      );
    }
    // v13 -> v14: display label for the (previously schema-only) group ringtone.
    if (oldVersion < 14) {
      await db.execute('ALTER TABLE groups ADD COLUMN ringtone_label TEXT');
    }
    // v14 -> v15: repair stale name_translit keys. Older app versions could leave
    // this column out of sync with the current name (e.g. a rename that did not
    // recompute it), which made an unrelated contact match a name search. Rebuild
    // every row's key from its current name; harmless for rows already correct.
    if (oldVersion < 15) {
      final info = await db.rawQuery('PRAGMA table_info(contacts)');
      if (info.isNotEmpty) {
        final rows = await db.query(
          'contacts',
          columns: ['id', 'salutation', 'first_name', 'middle_name', 'last_name'],
        );
        final batch = db.batch();
        for (final r in rows) {
          final name = [
            r['salutation'],
            r['first_name'],
            r['middle_name'],
            r['last_name'],
          ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
          batch.update(
            'contacts',
            {'name_translit': searchKey(name)},
            where: 'id = ?',
            whereArgs: [r['id']],
          );
        }
        await batch.commit(noResult: true);
      }
    }
    // v15 -> v16: repair relationship rows whose gendered label contradicts the
    // gender of the contact it describes (related_contact_id). Older versions
    // computed the reverse row without regard to gender, so e.g. a female cousin
    // could be stored as "Cousin Brother". Only wrong-gender labels are swapped
    // within the same family; neutral labels and unknown-gender rows are kept.
    if (oldVersion < 16) {
      await repairGenderedRelationshipLabels(db);
    }
    // v16 -> v17 / v17 -> v18: romanized sort keys, so the list sorts Malayalam
    // and English names in one interleaved A–Z order (SQLite NOCASE only folds
    // ASCII, so Malayalam names would otherwise clump after 'z' by code point).
    // Done via [_ensureSortColumns] (existence-checked, so it also self-heals a
    // DB that was version-bumped to 17 during development before this migration
    // existed — the columns would otherwise be permanently missing). The
    // repository keeps the keys current on every insert/update.
    if (oldVersion < 18) {
      await _ensureSortColumns(db);
    }
    // v18 -> v19: distinguish a *user-confirmed* merge (from the Find-duplicates
    // screen) from an *automatic* import-time absorption. The device→app sync's
    // name-based "heal wrong absorption" rule must not undo a deliberate user
    // merge just because the merged contacts have slightly different names.
    // Existence-checked (like [_ensureSortColumns]) so it self-heals a DB that
    // was version-bumped during development before this migration existed.
    if (oldVersion < 19) {
      await _ensureMergedConfirmedColumn(db);
    }
    // v19 -> v20: free-text "formal name" on contacts (stored + searchable).
    // Existence-checked (like the columns above) so it self-heals a DB that was
    // version-bumped during development before this migration existed.
    if (oldVersion < 20) {
      await _ensureFormalNameColumn(db);
    }
    // v20 -> v21: `name_phonetic`, the sound-only search key that lets an
    // English-typed query match a Malayalam-spelled name whose vowels differ
    // (Michael ↔ മൈക്കിൾ). Adding the column also rebuilds `name_translit`,
    // which repairs rows whose stored key drifted from their current name —
    // the other half of the "typed name does not find the contact" bug.
    // Existence-checked (like the columns above) so it self-heals a DB that was
    // version-bumped during development before this migration existed.
    if (oldVersion < 21) {
      await _ensurePhoneticColumn(db);
    }
    // v21 -> v22: the emergency info card (Settings → Emergency info). One
    // `emergency_info` row plus its `emergency_contacts` rows. Existence-checked
    // (like the columns above) so it self-heals a DB that was version-bumped
    // during development before this migration existed.
    if (oldVersion < 22) {
      await _ensureEmergencyTables(db);
    }
    // v22 -> v23: the local audit log (Settings → Audit Log) — one row per
    // contact create / edit / delete, with before+after snapshots so a change
    // can be undone. Existence-checked (like the tables above) so it self-heals
    // a DB that was version-bumped during development before this migration
    // existed.
    if (oldVersion < 23) {
      await _ensureAuditTable(db);
    }
    // v23 -> v24: ephemeral / self-destructing contacts support. Existence-checked
    // so it self-heals a DB that was version-bumped during development before
    // this migration existed.
    if (oldVersion < 24) {
      await _ensureEphemeralColumns(db);
    }
    // v24 -> v25: SHA-256 tamper-proof audit hash chaining columns (prev_hash, hash).
    if (oldVersion < 25) {
      await _ensureAuditTable(db);
    }
    // v25 -> v26: confirmed_merge_phones — remembers the phone numbers involved
    // in a user-confirmed merge, so a device contact re-synced under a new
    // (Android-reassigned) device id is still recognised as already merged
    // instead of being re-imported as a fresh duplicate.
    if (oldVersion < 26) {
      await _ensureConfirmedMergePhonesTable(db);
    }
    // v26 -> v27: call_outcome — what happened on the call, as opposed to
    // call_type which says which way it went. Lets Recents tell an outgoing
    // call that was answered from one that never connected.
    if (oldVersion < 27) {
      await _ensureCallOutcomeColumn(db);
    }
  }

  /// Ensures `call_logs.call_outcome` exists, and seeds it for rows written
  /// before the column did.
  ///
  /// `call_type` conflates direction and outcome: 'missed' and 'blocked' each
  /// imply "not answered", while 'outgoing' says nothing about what happened.
  /// This column holds the outcome on its own, so the outgoing side can carry
  /// one too. Null means "not known" — which is the honest answer for old rows.
  ///
  /// PRAGMA-checked rather than version-gated, so a development DB whose version
  /// ran ahead of this migration still heals on open (see [_onOpen]).
  Future<void> _ensureCallOutcomeColumn(DatabaseExecutor db) async {
    final info = await db.rawQuery('PRAGMA table_info(call_logs)');
    if (info.isEmpty) return;
    final columns = info.map((c) => c['name'] as String).toSet();
    if (columns.contains('call_outcome')) return;

    // No CHECK constraint: an unrecognised outcome must never fail a call-log
    // write, and adding values later must not mean rebuilding the table (which
    // is what the 'blocked' call_type cost us at v13).
    await db.execute('ALTER TABLE call_logs ADD COLUMN call_outcome TEXT');

    // Seed the rows that were already there, but only where the stored data
    // actually settles the question. A call with real duration was answered;
    // a missed or blocked call was not.
    await db.execute('''
      UPDATE call_logs SET call_outcome = 'answered'
      WHERE call_outcome IS NULL AND duration IS NOT NULL AND duration > 0
    ''');
    await db.execute('''
      UPDATE call_logs SET call_outcome = 'no_answer'
      WHERE call_outcome IS NULL AND call_type IN ('missed', 'blocked')
    ''');
    // Outgoing rows with duration 0 are deliberately left null: on old data we
    // can't tell "nobody answered" from "never reconciled", and Recents shows
    // nothing for a null outcome rather than guessing wrong.
  }

  /// Ensures the audit-log table exists and includes cryptographic hash columns.
  /// Uses `IF NOT EXISTS` and PRAGMA column checks rather than trusting the DB
  /// version, so it is safe to call on every open.
  Future<void> ensureAuditTable(DatabaseExecutor db) => _ensureAuditTable(db);

  Future<void> _ensureAuditTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        contact_name TEXT NOT NULL,
        action TEXT NOT NULL,
        source TEXT NOT NULL,
        changed_at TEXT NOT NULL,
        summary TEXT,
        is_secret INTEGER NOT NULL DEFAULT 0,
        before_json TEXT,
        after_json TEXT,
        prev_hash TEXT,
        hash TEXT
      )
    ''');
    final info = await db.rawQuery('PRAGMA table_info(audit_log)');
    if (info.isNotEmpty) {
      final columns = info.map((c) => c['name'] as String).toSet();
      if (!columns.contains('prev_hash')) {
        await db.execute('ALTER TABLE audit_log ADD COLUMN prev_hash TEXT');
      }
      if (!columns.contains('hash')) {
        await db.execute('ALTER TABLE audit_log ADD COLUMN hash TEXT');
      }
    }
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_audit_log_changed_at ON audit_log(changed_at)',
    );
  }

  /// Ensures ephemeral columns (`is_ephemeral`, `ephemeral_expires_at`,
  /// `ephemeral_auto_delete_call`, `ephemeral_call_count`) exist on `contacts`.
  Future<void> ensureEphemeralColumns(DatabaseExecutor db) =>
      _ensureEphemeralColumns(db);

  Future<void> _ensureEphemeralColumns(DatabaseExecutor db) async {
    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    if (info.isEmpty) return;
    final columns = info.map((c) => c['name'] as String).toSet();
    if (!columns.contains('is_ephemeral')) {
      await db.execute(
        'ALTER TABLE contacts ADD COLUMN is_ephemeral INTEGER DEFAULT 0',
      );
    }
    if (!columns.contains('ephemeral_expires_at')) {
      await db.execute('ALTER TABLE contacts ADD COLUMN ephemeral_expires_at TEXT');
    }
    if (!columns.contains('ephemeral_auto_delete_call')) {
      await db.execute(
        'ALTER TABLE contacts ADD COLUMN ephemeral_auto_delete_call INTEGER DEFAULT 0',
      );
    }
    if (!columns.contains('ephemeral_call_count')) {
      await db.execute(
        'ALTER TABLE contacts ADD COLUMN ephemeral_call_count INTEGER DEFAULT 0',
      );
    }
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_contacts_is_ephemeral ON contacts(is_ephemeral)',
    );
  }

  /// Ensures the emergency-card tables exist. Uses `IF NOT EXISTS` rather than
  /// trusting the DB version, so it is safe to call on every open (see
  /// [_onOpen]) and self-heals a development DB whose version ran ahead of its
  /// schema.
  ///
  /// `emergency_info` holds at most one row (`id = 1`). Every medical field has
  /// a matching `show_*` flag: only fields whose flag is 1 are ever copied into
  /// the plaintext lock-screen mirror. `enabled` is the master switch — with it
  /// off nothing leaves the encrypted DB at all.
  Future<void> _ensureEmergencyTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS emergency_info (
        id INTEGER PRIMARY KEY,
        enabled INTEGER NOT NULL DEFAULT 0,
        owner_name TEXT,
        show_owner_name INTEGER NOT NULL DEFAULT 1,
        blood_group TEXT,
        show_blood_group INTEGER NOT NULL DEFAULT 1,
        allergies TEXT,
        show_allergies INTEGER NOT NULL DEFAULT 1,
        medications TEXT,
        show_medications INTEGER NOT NULL DEFAULT 1,
        conditions TEXT,
        show_conditions INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        show_notes INTEGER NOT NULL DEFAULT 1,
        address TEXT,
        show_address INTEGER NOT NULL DEFAULT 0,
        organ_donor INTEGER NOT NULL DEFAULT 0,
        show_organ_donor INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS emergency_contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contact_id INTEGER,
        display_name TEXT NOT NULL,
        number TEXT NOT NULL,
        relation_label TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        show_on_lock INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE SET NULL
      )
    ''');
  }

  /// The one name string every contact search key is built from. Kept here (not
  /// in the repository) so the migration, the repository, and the staleness
  /// check all derive keys from **exactly** the same text — when they disagree,
  /// stored keys look permanently "stale" and search silently misses rows.
  static String contactSearchName(Map<String, Object?> row) => [
    row['salutation'],
    row['first_name'],
    row['middle_name'],
    row['last_name'],
    row['formal_name'],
  ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

  /// Columns [contactSearchName] reads, for the queries that feed it.
  static const List<String> _searchNameColumns = [
    'id',
    'salutation',
    'first_name',
    'middle_name',
    'last_name',
    'formal_name',
  ];

  /// Ensures `contacts.name_phonetic` exists. Checks the actual column (via
  /// PRAGMA) rather than trusting the DB version, so it is safe to call
  /// regardless of how the DB reached its current state. When it adds the
  /// column it rebuilds every row's search keys to fill it.
  ///
  /// Public so the migration and tests can both drive the same code.
  Future<void> ensurePhoneticColumn(DatabaseExecutor db) =>
      _ensurePhoneticColumn(db);

  Future<void> _ensurePhoneticColumn(DatabaseExecutor db) async {
    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    if (info.isEmpty) return;
    final columns = info.map((c) => c['name'] as String).toSet();
    if (!columns.contains('name_phonetic')) {
      await db.execute('ALTER TABLE contacts ADD COLUMN name_phonetic TEXT');
    }
    await rebuildContactSearchKeys(db);
  }

  /// Rewrites `name_translit` + `name_phonetic` for every contact from its
  /// current name. Returns how many rows actually changed, so a caller can say
  /// "N contacts updated" instead of claiming work it may not have done.
  /// Idempotent — a second run changes nothing.
  Future<int> rebuildContactSearchKeys(DatabaseExecutor db) async {
    final rows = await _searchKeyRows(db);
    if (rows == null) return 0;
    final batch = db.batch();
    var changed = 0;
    for (final r in rows) {
      final name = contactSearchName(r);
      final translit = searchKey(name);
      final phonetic = phoneticCode(name);
      if (translit == r['name_translit'] && phonetic == r['name_phonetic']) {
        continue;
      }
      changed++;
      batch.update(
        'contacts',
        {'name_translit': translit, 'name_phonetic': phonetic},
        where: 'id = ?',
        whereArgs: [r['id']],
      );
    }
    if (changed > 0) await batch.commit(noResult: true);
    return changed;
  }

  /// How many contacts have a stored search key that disagrees with their
  /// current name — i.e. how many rows [rebuildContactSearchKeys] would fix.
  /// Read-only, so the Settings screen can report drift without changing data.
  Future<int> staleContactSearchKeyCount(DatabaseExecutor db) async {
    final rows = await _searchKeyRows(db);
    if (rows == null) return 0;
    var stale = 0;
    for (final r in rows) {
      final name = contactSearchName(r);
      if (searchKey(name) != r['name_translit'] ||
          phoneticCode(name) != r['name_phonetic']) {
        stale++;
      }
    }
    return stale;
  }

  /// Every contact's name parts plus its stored keys, or null when the table or
  /// the key columns are not there yet (an older DB mid-migration).
  Future<List<Map<String, Object?>>?> _searchKeyRows(DatabaseExecutor db) async {
    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    if (info.isEmpty) return null;
    final columns = info.map((c) => c['name'] as String).toSet();
    if (!columns.contains('name_translit') ||
        !columns.contains('name_phonetic')) {
      return null;
    }
    return db.query(
      'contacts',
      columns: [
        // `formal_name` only exists from v20; skip it on an older DB rather
        // than failing the whole rebuild.
        ..._searchNameColumns.where(columns.contains),
        'name_translit',
        'name_phonetic',
      ],
    );
  }

  /// Ensures `contacts.formal_name` exists. Checks the actual column (via
  /// PRAGMA) rather than trusting the DB version, so it is safe to call
  /// regardless of how the DB reached its current state. Existing rows keep the
  /// column's default of NULL.
  ///
  /// Public so the migration and tests can both drive the same code.
  Future<void> ensureFormalNameColumn(DatabaseExecutor db) =>
      _ensureFormalNameColumn(db);

  Future<void> _ensureFormalNameColumn(DatabaseExecutor db) async {
    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    if (info.isEmpty) return;
    final columns = info.map((c) => c['name'] as String).toSet();
    if (columns.contains('formal_name')) return;
    await db.execute('ALTER TABLE contacts ADD COLUMN formal_name TEXT');
  }

  /// Ensures `merged_device_ids.user_confirmed` exists. Checks the actual column
  /// (via PRAGMA) rather than trusting the DB version, so it is safe to call
  /// regardless of how the DB reached its current state. Existing rows keep the
  /// column's default of 0 (treated as automatic absorptions).
  Future<void> _ensureMergedConfirmedColumn(DatabaseExecutor db) async {
    final info = await db.rawQuery('PRAGMA table_info(merged_device_ids)');
    if (info.isEmpty) return;
    final columns = info.map((c) => c['name'] as String).toSet();
    if (columns.contains('user_confirmed')) return;
    await db.execute(
      'ALTER TABLE merged_device_ids ADD COLUMN user_confirmed INTEGER NOT NULL DEFAULT 0',
    );
  }

  /// Ensures `contacts.sort_first` / `sort_last` exist and are populated. Checks
  /// the actual columns (via PRAGMA) rather than trusting the DB version, so it
  /// is safe to call regardless of how the DB reached its current state, and
  /// backfills every row from its current name only when it just added a column.
  ///
  /// Public so the migration and tests can both drive the same code.
  Future<void> ensureSortColumns(DatabaseExecutor db) => _ensureSortColumns(db);

  Future<void> _ensureSortColumns(DatabaseExecutor db) async {
    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    if (info.isEmpty) return;
    final columns = info.map((c) => c['name'] as String).toSet();
    var added = false;
    if (!columns.contains('sort_first')) {
      await db.execute('ALTER TABLE contacts ADD COLUMN sort_first TEXT');
      added = true;
    }
    if (!columns.contains('sort_last')) {
      await db.execute('ALTER TABLE contacts ADD COLUMN sort_last TEXT');
      added = true;
    }
    if (!added) return;
    final rows = await db.query(
      'contacts',
      columns: ['id', 'first_name', 'last_name'],
    );
    final batch = db.batch();
    for (final r in rows) {
      batch.update(
        'contacts',
        {
          'sort_first': sortRoman((r['first_name'] as String?) ?? ''),
          'sort_last': sortRoman((r['last_name'] as String?) ?? ''),
        },
        where: 'id = ?',
        whereArgs: [r['id']],
      );
    }
    await batch.commit(noResult: true);
  }

  /// Rewrites each `relationships` row whose gendered label disagrees with the
  /// gender of the contact it describes (`related_contact_id`), using
  /// [RelationshipTypes.forGender]. Neutral labels, non-gendered relations, and
  /// rows whose contact has no/non-binary gender are left unchanged. Returns the
  /// number of rows corrected. Idempotent — a second run corrects nothing.
  ///
  /// Public so the v15→v16 migration and tests can both drive the same code.
  Future<int> repairGenderedRelationshipLabels(DatabaseExecutor db) async {
    final info = await db.rawQuery('PRAGMA table_info(contacts)');
    if (info.isEmpty) return 0;
    final rows = await db.rawQuery('''
      SELECT r.id AS id,
             r.relationship_type AS type,
             c.gender AS gender
      FROM relationships r
      JOIN contacts c ON c.id = r.related_contact_id
    ''');
    var fixed = 0;
    final batch = db.batch();
    for (final r in rows) {
      final type = (r['type'] as String?) ?? '';
      final corrected = RelationshipTypes.forGender(
        type,
        r['gender'] as String?,
      );
      if (corrected != type.trim()) {
        batch.update(
          'relationships',
          {'relationship_type': corrected},
          where: 'id = ?',
          whereArgs: [r['id']],
        );
        fixed++;
      }
    }
    await batch.commit(noResult: true);
    return fixed;
  }

  /// Closes the database. Mainly useful for tests; the singleton is otherwise
  /// kept open for the app's lifetime.
  Future<void> close() async {
    final db = _database;
    _database = null;
    _opening = null;
    if (db != null && db.isOpen) {
      await db.close();
    }
  }
}
