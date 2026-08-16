// Opens the on-device SQLite database and owns the schema.

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../fleet.dart';
import 'password_hasher.dart';
import 'seed_credentials.dart';

class AppDatabase {
  AppDatabase._();

  static const fileName = 'fedayns.db';
  static const schemaVersion = 2;

  static Database? _db;

  /// Opens (and creates on first run) the database. Safe to call repeatedly.
  static Future<Database> open() async {
    final existing = _db;
    if (existing != null && existing.isOpen) return existing;

    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, fileName),
      version: schemaVersion,
      onConfigure: (db) async {
        // Off by default in SQLite; without it the FKs added later would not
        // actually be enforced.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await createSchema(db);
      },
      onUpgrade: (db, from, to) async {
        // Each version adds its own step here rather than recreating the
        // database, so accounts survive upgrades.
        if (from < 2) await createSettingsTable(db);
      },
    );
    // Every open, not just onCreate. onCreate fires once in the lifetime of
    // the file, so any install whose database predates the demo account — or
    // predates seeding existing at all — would never get it, and there is no
    // way back short of reinstalling. Insert-or-ignore is idempotent and now
    // costs one statement, since the hash is a constant.
    await seedDemoAccount(db);
    _db = db;
    return db;
  }

  /// The schema, extracted so tests can build it on an in-memory database.
  static Future<void> createSchema(Database db) async {
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
    // Redundant with UNIQUE on most versions, but makes the lookup index
    // explicit and survives the constraint being reworked.
    await db.execute('CREATE INDEX idx_users_email ON users (email COLLATE NOCASE)');
    await createSettingsTable(db);
  }

  /// Device preferences. Separate from [createSchema]'s user table so the v1 →
  /// v2 upgrade can add it on its own.
  static Future<void> createSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// Inserts the demo account if it is not already there.
  ///
  /// Runs on every [open]. It is a no-op once the row exists, and the ignore
  /// conflict algorithm means a real account that has claimed that address is
  /// never touched. Kept out of [createSchema] so tests get an empty table by
  /// default.
  ///
  /// The hash is a compile-time constant rather than something derived here:
  /// deriving it made the first database open pay for a whole PBKDF2 run.
  static Future<void> seedDemoAccount(Database db) async {
    await db.insert(
      'users',
      {
        'full_name': kSeedFullName,
        'email': kSeedEmail,
        'phone': kSeedPhone,
        'password_hash': kSeedHash,
        'password_salt': kSeedSalt,
        'password_iterations': PasswordHasher.defaultIterations,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      // If a real account already claimed that address, leave it alone.
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
