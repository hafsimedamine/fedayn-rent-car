import 'package:sqflite/sqflite.dart';

import 'account.dart';
import 'app_database.dart';
import 'auth_repository.dart';
import 'password_hasher.dart';

/// Accounts in the device's SQLite database.
class SqliteAuthRepository implements AuthRepository {
  SqliteAuthRepository({Database? db}) : _injected = db;

  final Database? _injected;

  Future<Database> get _db async => _injected ?? await AppDatabase.open();

  @override
  Future<Account> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final db = await _db;
    final normalised = normaliseEmail(email);
    final salt = PasswordHasher.newSalt();

    try {
      final id = await db.insert('users', {
        'full_name': fullName.trim(),
        'email': normalised,
        'phone': phone.trim(),
        'password_hash': await PasswordHasher.hashAsync(password, salt),
        'password_salt': salt,
        'password_iterations': PasswordHasher.defaultIterations,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      return Account(id: id, fullName: fullName.trim(), email: normalised, phone: phone.trim());
    } on DatabaseException catch (e) {
      // Let the UNIQUE constraint be the authority rather than checking first,
      // which would race between the check and the insert.
      if (e.isUniqueConstraintError()) throw const AuthException(AuthError.emailTaken);
      rethrow;
    }
  }

  @override
  Future<Account> signIn({required String email, required String password}) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      where: 'email = ? COLLATE NOCASE',
      whereArgs: [normaliseEmail(email)],
      limit: 1,
    );
    if (rows.isEmpty) throw const AuthException(AuthError.invalidCredentials);

    final row = rows.first;
    final ok = await PasswordHasher.verifyAsync(
      password,
      row['password_salt']! as String,
      row['password_hash']! as String,
      iterations: row['password_iterations']! as int,
    );
    if (!ok) throw const AuthException(AuthError.invalidCredentials);

    return Account.fromRow(row);
  }

  @override
  Future<bool> emailExists(String email) async {
    final db = await _db;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ? COLLATE NOCASE',
      whereArgs: [normaliseEmail(email)],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<Account> updateProfile({
    required int id,
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final db = await _db;
    final normalised = normaliseEmail(email);
    try {
      await db.update(
        'users',
        {'full_name': fullName.trim(), 'email': normalised, 'phone': phone.trim()},
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) throw const AuthException(AuthError.emailTaken);
      rethrow;
    }
    return Account(id: id, fullName: fullName.trim(), email: normalised, phone: phone.trim());
  }

  @override
  Future<int> accountCount() async {
    final db = await _db;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
  }
}
