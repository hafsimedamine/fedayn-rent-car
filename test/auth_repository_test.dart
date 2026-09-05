// Exercises the real SQL against a real SQLite engine (in-memory, via FFI) —
// not a stub — so the schema, the UNIQUE constraint and the queries are all
// covered.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fedayns_rent_car/data/db/account.dart';
import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/data/db/app_database.dart';
import 'package:fedayns_rent_car/data/db/auth_repository.dart';
import 'package:fedayns_rent_car/data/db/sqlite_auth_repository.dart';

void main() {
  late Database db;
  late SqliteAuthRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.schemaVersion,
        onCreate: (db, _) => AppDatabase.createSchema(db),
      ),
    );
    repo = SqliteAuthRepository(db: db);
  });

  tearDown(() async => db.close());

  Future<Account> registerUser({String email = 'user@example.com'}) => repo.register(
        fullName: 'Amine Tazi',
        email: email,
        phone: '+212 600 000 000',
        password: 'Motdepasse!1',
      );

  test('registers an account and signs back in', () async {
    final created = await registerUser();
    expect(created.id, greaterThan(0));
    expect(created.email, 'user@example.com');
    expect(created.firstName, 'Amine');

    final signedIn = await repo.signIn(email: 'user@example.com', password: 'Motdepasse!1');
    expect(signedIn.id, created.id);
    expect(signedIn.fullName, 'Amine Tazi');
  });

  test('stores no plaintext password', () async {
    await registerUser();
    final row = (await db.query('users')).single;

    expect(row.values.contains('Motdepasse!1'), isFalse);
    expect(row['password_hash'], isNot(contains('Motdepasse!1')));
    expect(row['password_salt'], isNotNull);
    expect(row['password_iterations'], greaterThan(1000));
  });

  test('rejects a duplicate email regardless of case or padding', () async {
    await registerUser(email: 'user@example.com');

    for (final dupe in ['user@example.com', 'USER@example.com', '  User@Example.com  ']) {
      expect(
        () => registerUser(email: dupe),
        throwsA(isA<AuthException>().having((e) => e.error, 'error', AuthError.emailTaken)),
        reason: '"$dupe" should collide with the existing account',
      );
    }
    expect(await repo.accountCount(), 1);
  });

  test('sign-in is case-insensitive on email', () async {
    await registerUser();
    final signedIn = await repo.signIn(email: 'USER@EXAMPLE.COM', password: 'Motdepasse!1');
    expect(signedIn.email, 'user@example.com');
  });

  test('wrong password and unknown email fail identically', () async {
    await registerUser();

    Future<AuthError> errorFor(String email, String password) async {
      try {
        await repo.signIn(email: email, password: password);
        fail('expected a failure');
      } on AuthException catch (e) {
        return e.error;
      }
    }

    // Same error either way, so the response cannot be used to discover which
    // addresses have accounts.
    expect(await errorFor('user@example.com', 'wrong'), AuthError.invalidCredentials);
    expect(await errorFor('nobody@example.com', 'Motdepasse!1'), AuthError.invalidCredentials);
  });

  test('emailExists reflects the store', () async {
    expect(await repo.emailExists('user@example.com'), isFalse);
    await registerUser();
    expect(await repo.emailExists('  USER@example.com '), isTrue);
  });

  test('updates a profile and keeps sign-in working', () async {
    final created = await registerUser();
    final updated = await repo.updateProfile(
      id: created.id,
      fullName: 'Amine Tazi Alaoui',
      email: 'amine@example.com',
      phone: '+212 611 111 111',
    );

    expect(updated.firstName, 'Amine');
    expect(await repo.emailExists('amine@example.com'), isTrue);
    expect(await repo.emailExists('user@example.com'), isFalse);

    final signedIn = await repo.signIn(email: 'amine@example.com', password: 'Motdepasse!1');
    expect(signedIn.fullName, 'Amine Tazi Alaoui');
  });

  test('a profile update cannot steal another account\'s email', () async {
    final first = await registerUser(email: 'first@example.com');
    await registerUser(email: 'second@example.com');

    expect(
      () => repo.updateProfile(
        id: first.id,
        fullName: 'Amine Tazi',
        email: 'second@example.com',
        phone: '+212 600 000 000',
      ),
      throwsA(isA<AuthException>().having((e) => e.error, 'error', AuthError.emailTaken)),
    );
  });

  test('a fresh database ships with the demo account, and it can sign in', () async {
    // A distinct file, not inMemoryDatabasePath: the ffi factory hands back the
    // already-open in-memory database, so onCreate would never fire and the
    // seed would silently not run.
    final path = '${await databaseFactory.getDatabasesPath()}/seed_test.db';
    await databaseFactory.deleteDatabase(path);
    final seeded = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: AppDatabase.schemaVersion,
        onCreate: (db, _) async {
          await AppDatabase.createSchema(db);
          await AppDatabase.seedDemoAccount(db);
        },
      ),
    );
    final seededRepo = SqliteAuthRepository(db: seeded);

    expect(await seededRepo.accountCount(), 1);
    final account = await seededRepo.signIn(email: kSeedEmail, password: kSeedPassword);
    expect(account.fullName, kSeedFullName);
    expect(account.firstName, 'Mohamed');
    expect(account.phone, kSeedPhone);

    // Seeded like any other account — the password is hashed, not stored.
    final row = (await seeded.query('users')).single;
    expect(row['password_hash'], isNot(contains(kSeedPassword)));
    await seeded.close();
    await databaseFactory.deleteDatabase(path);
  });

  test('seeding twice does not duplicate the demo account', () async {
    await AppDatabase.seedDemoAccount(db);
    await AppDatabase.seedDemoAccount(db);
    expect(await repo.accountCount(), 1);
  });

  test('accounts survive reopening the database', () async {
    // A file-backed database, so this really is persistence and not a cache.
    final path = '${await databaseFactory.getDatabasesPath()}/persist_test.db';
    await databaseFactory.deleteDatabase(path);

    Future<Database> openIt() => databaseFactory.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: AppDatabase.schemaVersion,
            onCreate: (db, _) => AppDatabase.createSchema(db),
          ),
        );

    var handle = await openIt();
    await SqliteAuthRepository(db: handle).register(
      fullName: 'Amine Tazi',
      email: 'persist@example.com',
      phone: '+212 600 000 000',
      password: 'Motdepasse!1',
    );
    await handle.close();

    handle = await openIt();
    final signedIn = await SqliteAuthRepository(db: handle)
        .signIn(email: 'persist@example.com', password: 'Motdepasse!1');
    expect(signedIn.fullName, 'Amine Tazi');
    await handle.close();
    await databaseFactory.deleteDatabase(path);
  });
}
