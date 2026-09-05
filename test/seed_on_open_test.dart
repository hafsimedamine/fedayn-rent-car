// The demo account has to be there on an install that already has a database.
//
// It used to be inserted only from onCreate, which fires once in the lifetime
// of the file. Anyone whose database was created before the seed existed —
// which is anyone who had run an earlier build — never got the account, and
// there was no way to get it short of reinstalling. This walks that exact
// history: a v1 database with no demo account, then a normal open.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fedayns_rent_car/data/db/app_database.dart';
import 'package:fedayns_rent_car/data/db/sqlite_auth_repository.dart';
import 'package:fedayns_rent_car/data/fleet.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late String path;

  setUp(() async {
    path = '${await databaseFactory.getDatabasesPath()}/${AppDatabase.fileName}';
    await AppDatabase.close();
    await databaseFactory.deleteDatabase(path);
  });

  tearDown(() async {
    await AppDatabase.close();
    await databaseFactory.deleteDatabase(path);
  });

  /// A database as an older build left it: schema v1, users table, no seed.
  Future<void> createLegacyDatabase() async {
    final legacy = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE users (
              id                  INTEGER PRIMARY KEY AUTOINCREMENT,
              full_name           TEXT    NOT NULL,
              email               TEXT    NOT NULL UNIQUE COLLATE NOCASE,
              phone               TEXT    NOT NULL,
              password_hash       TEXT    NOT NULL,
              password_salt       TEXT    NOT NULL,
              password_iterations INTEGER NOT NULL,
              created_at          INTEGER NOT NULL
            )
          ''');
        },
      ),
    );
    expect((await legacy.rawQuery('SELECT COUNT(*) AS n FROM users')).single['n'], 0);
    await legacy.close();
  }

  test('a database that predates seeding still gets the demo account', () async {
    await createLegacyDatabase();

    final db = await AppDatabase.open();
    final account = await SqliteAuthRepository(db: db).signIn(
      email: kSeedEmail,
      password: kSeedPassword,
    );
    expect(account.fullName, kSeedFullName);
    expect(account.phone, kSeedPhone);
  });

  test('the v1 database is migrated as well as seeded', () async {
    await createLegacyDatabase();

    final db = await AppDatabase.open();
    expect(await db.getVersion(), AppDatabase.schemaVersion);
    // The settings table arrived with v2; writing to it proves the migration ran.
    await db.insert('settings', {'key': 'k', 'value': 'v'});
    expect((await db.query('settings')).single['value'], 'v');
  });

  test('a fresh install gets it too, exactly once', () async {
    var db = await AppDatabase.open();
    expect((await db.rawQuery('SELECT COUNT(*) AS n FROM users')).single['n'], 1);

    // Reopening must not add a second copy.
    await AppDatabase.close();
    db = await AppDatabase.open();
    expect((await db.rawQuery('SELECT COUNT(*) AS n FROM users')).single['n'], 1);
  });

  test('a real account on that address is never overwritten', () async {
    // Someone registers the seed address themselves before any seeding runs.
    await createLegacyDatabase();
    final pre = await databaseFactory.openDatabase(path);
    await SqliteAuthRepository(db: pre).register(
      fullName: 'Quelqu\'un Dautre',
      email: kSeedEmail,
      phone: '+212 611 111 111',
      password: 'Motdepasse!1',
    );
    await pre.close();

    final db = await AppDatabase.open();
    final repo = SqliteAuthRepository(db: db);
    expect((await db.rawQuery('SELECT COUNT(*) AS n FROM users')).single['n'], 1);

    // Their password still works; the seed did not clobber the row.
    final account = await repo.signIn(email: kSeedEmail, password: 'Motdepasse!1');
    expect(account.fullName, 'Quelqu\'un Dautre');
  });
}
