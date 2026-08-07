// Tests for the local audit log: every contact write is recorded with enough
// detail to be traced and undone.
//
// Covers: create / edit / delete each write one entry with the right action,
// source and snapshots; undo of each action restores the expected state (an
// undone delete comes back with a new id and its children); a merge logs the
// kept contact's edit plus one delete per absorbed contact; and prune keeps the
// newest rows.
//
// SQLite-backed: run this file on its own (`flutter test test/audit_log_test.dart`)
// — the shared sqlite3 native asset can double-copy-crash when several DB test
// files run in one invocation.

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:smart_contacts_dialer/database/database_helper.dart';
import 'package:smart_contacts_dialer/models/audit_entry.dart';
import 'package:smart_contacts_dialer/models/contact.dart';
import 'package:smart_contacts_dialer/models/email.dart';
import 'package:smart_contacts_dialer/models/phone_number.dart';
import 'package:smart_contacts_dialer/repositories/audit_repository.dart';
import 'package:smart_contacts_dialer/repositories/contact_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dbName = 'smart_contacts_test_audit.db';
  final contacts = ContactRepository();
  final audit = AuditRepository();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabaseName(dbName);
  });

  Future<void> freshDb() async {
    await DatabaseHelper().close();
    await databaseFactory.deleteDatabase(join(await getDatabasesPath(), dbName));
  }

  setUp(freshDb);
  tearDown(freshDb);

  Contact sample({
    String first = 'Meera',
    String? last = 'Nair',
    List<String> phones = const ['9876543210'],
    List<String> tags = const ['school'],
  }) {
    return Contact(firstName: first, lastName: last)
      ..phoneNumbers = [
        for (final p in phones) PhoneNumber(number: p, label: 'Mobile', type: 'personal'),
      ]
      ..emails = [Email(email: 'meera@example.com', label: 'Home', type: 'personal')]
      ..tags = [...tags];
  }

  test('insert records a create entry with an after snapshot', () async {
    final id = await contacts.insertContact(sample());

    final entries = await audit.entries();
    expect(entries, hasLength(1));
    final entry = entries.single;
    expect(entry.action, AuditAction.create);
    expect(entry.source, AuditSource.manual);
    expect(entry.contactId, id);
    expect(entry.contactName, 'Meera Nair');
    expect(entry.before, isNull);
    expect(entry.after, isNotNull);
    expect(entry.after!.children['phone_numbers'], hasLength(1));
    expect(entry.canUndo, isTrue);
  });

  test('the source is recorded, and secret entries are hidden by default', () async {
    final secret = sample(first: 'Hidden', last: null)..isSecret = true;
    await contacts.insertContact(secret, source: AuditSource.deviceSync);

    expect(await audit.entries(), isEmpty);
    final all = await audit.entries(includeSecret: true);
    expect(all, hasLength(1));
    expect(all.single.source, AuditSource.deviceSync);
    expect(all.single.isSecret, isTrue);
  });

  test('edit records before + after, and lists the changed fields', () async {
    final id = await contacts.insertContact(sample());
    final loaded = (await contacts.getContactById(id))!;
    loaded.lastName = 'Menon';
    loaded.phoneNumbers = [PhoneNumber(number: '9000000001', label: 'Work', type: 'official')];
    await contacts.updateContact(loaded);

    final entry = (await audit.entries()).first;
    expect(entry.action, AuditAction.update);
    expect(entry.before, isNotNull);
    expect(entry.after, isNotNull);
    final labels = [for (final c in entry.changes) c.label];
    expect(labels, containsAll(<String>['Last name', 'Phone numbers']));
    expect(entry.summary, contains('Last name'));
  });

  test('undoing an edit restores the earlier fields and children', () async {
    final id = await contacts.insertContact(sample());
    final loaded = (await contacts.getContactById(id))!;
    loaded.lastName = 'Menon';
    loaded.phoneNumbers = [PhoneNumber(number: '9000000001', label: 'Work', type: 'official')];
    loaded.tags = ['work'];
    await contacts.updateContact(loaded);

    final editEntry = (await audit.entries()).first;
    final restoredId = await contacts.undoAudit(editEntry);
    expect(restoredId, id);

    final after = (await contacts.getContactById(id))!;
    expect(after.lastName, 'Nair');
    expect(after.phoneNumbers.single.number, '9876543210');
    expect(after.tags, ['school']);

    // The undo is itself recorded.
    final newest = (await audit.entries()).first;
    expect(newest.source, AuditSource.undo);
    expect(newest.action, AuditAction.update);
  });

  test('delete records a snapshot, and undo brings the contact back', () async {
    final id = await contacts.insertContact(sample());
    await contacts.deleteContact(id);
    expect(await contacts.getContactById(id), isNull);

    final deleteEntry = (await audit.entries()).first;
    expect(deleteEntry.action, AuditAction.delete);
    expect(deleteEntry.before, isNotNull);
    expect(deleteEntry.canUndo, isTrue);

    final newId = await contacts.undoAudit(deleteEntry);
    expect(newId, isNotNull);
    expect(newId, isNot(id)); // a restored contact gets a new id

    final restored = (await contacts.getContactById(newId!))!;
    expect(restored.fullName, 'Meera Nair');
    expect(restored.phoneNumbers.single.number, '9876543210');
    expect(restored.emails.single.email, 'meera@example.com');
    expect(restored.tags, ['school']);
  });

  test('undoing a create deletes the contact again', () async {
    final id = await contacts.insertContact(sample());
    final createEntry = (await audit.entries()).single;

    final result = await contacts.undoAudit(createEntry);
    expect(result, isNull);
    expect(await contacts.getContactById(id), isNull);

    // Undoing it twice is refused rather than silently doing nothing.
    expect(
      () => contacts.undoAudit(createEntry),
      throwsA(isA<StateError>()),
    );
  });

  test('a merge logs the kept contact and each absorbed one', () async {
    final keptId = await contacts.insertContact(sample());
    final dupId = await contacts.insertContact(
      sample(phones: ['9876543210']),
    );

    await contacts.mergeContacts(keptId, [dupId]);

    final merged = await audit.entries(actions: {AuditAction.delete});
    expect(merged, hasLength(1));
    expect(merged.single.contactId, dupId);
    expect(merged.single.source, AuditSource.merge);

    final edits = await audit.entries(actions: {AuditAction.update});
    expect(edits.single.contactId, keptId);
    expect(edits.single.summary, contains('Absorbed 1 duplicate'));

    // The absorbed contact can be brought back as its own contact.
    final restoredId = await contacts.undoAudit(merged.single);
    expect(restoredId, isNotNull);
    expect((await contacts.getContactById(restoredId!))!.fullName, 'Meera Nair');
  });

  test('prune drops entries past the retention window', () async {
    final id = await contacts.insertContact(sample());
    await contacts.deleteContact(id);
    expect(await audit.count(), 2);

    // Age the older entry past the window.
    final db = await DatabaseHelper().database;
    final old = DateTime.now()
        .subtract(AuditRepository.retention + const Duration(days: 1))
        .toIso8601String();
    await db.update(
      'audit_log',
      {'changed_at': old},
      where: 'action = ?',
      whereArgs: [AuditAction.create.dbValue],
    );

    final removed = await audit.prune();
    expect(removed, 1);
    final left = await audit.entries();
    expect(left, hasLength(1));
    expect(left.single.action, AuditAction.delete);
  });

  test('clear empties the log but leaves the contacts alone', () async {
    final id = await contacts.insertContact(sample());
    await audit.clear();

    expect(await audit.count(), 0);
    expect(await contacts.getContactById(id), isNotNull);
  });

  test('recorded entries contain SHA-256 hash chaining', () async {
    final id1 = await contacts.insertContact(sample(first: 'Alice'));
    final loaded = (await contacts.getContactById(id1))!;
    loaded.lastName = 'Smith';
    await contacts.updateContact(loaded);

    final entries = await audit.entries(); // newest first
    expect(entries, hasLength(2));
    final updateEntry = entries[0];
    final createEntry = entries[1];

    expect(createEntry.prevHash, AuditEntry.genesisHash);
    expect(createEntry.hash, isNotNull);
    expect(createEntry.hash, isNotEmpty);

    expect(updateEntry.prevHash, createEntry.hash);
    expect(updateEntry.hash, isNotNull);
    expect(updateEntry.hash, isNotEmpty);

    final verifyResult = await audit.verifyChain();
    expect(verifyResult.isValid, isTrue);
    expect(verifyResult.totalEntries, 2);
    expect(verifyResult.verifiedEntries, 2);
  });

  test('tampering with an audit row invalidates the chain verification', () async {
    final id = await contacts.insertContact(sample(first: 'Bob'));
    final db = await DatabaseHelper().database;

    // Direct SQL update (tampering with summary)
    await db.update(
      'audit_log',
      {'summary': 'Tampered Summary'},
      where: 'contact_id = ?',
      whereArgs: [id],
    );

    final verifyResult = await audit.verifyChain();
    expect(verifyResult.isValid, isFalse);
    expect(verifyResult.firstTamperedId, isNotNull);
    expect(verifyResult.errorMessage, contains(RegExp('tamper detected', caseSensitive: false)));
  });

  test('ensureHashesBackfilled backfills hashes for legacy entries', () async {
    final db = await DatabaseHelper().database;
    // Insert an unhashed legacy audit row directly
    await db.insert('audit_log', {
      'contact_name': 'Legacy User',
      'action': 'create',
      'source': 'manual',
      'changed_at': DateTime.now().toIso8601String(),
      'summary': 'Legacy entry without hashes',
      'is_secret': 0,
    });

    final beforeBackfill = (await audit.entries()).first;
    expect(beforeBackfill.hash, isNull);

    await audit.ensureHashesBackfilled();

    final afterBackfill = (await audit.entries()).first;
    expect(afterBackfill.prevHash, AuditEntry.genesisHash);
    expect(afterBackfill.hash, isNotNull);

    final verify = await audit.verifyChain();
    expect(verify.isValid, isTrue);
  });

  test('exportSignedAuditLog generates a sealed JSON file with signature', () async {
    await contacts.insertContact(sample(first: 'Charlie'));
    final file = await audit.exportSignedAuditLog();

    expect(await file.exists(), isTrue);
    final content = await file.readAsString();
    expect(content, contains('auditExport'));
    expect(content, contains('signature'));
    expect(content, contains('HMAC-SHA256'));
  });
}

