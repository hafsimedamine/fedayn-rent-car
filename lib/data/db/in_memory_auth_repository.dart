import '../fleet.dart';
import 'account.dart';
import 'auth_repository.dart';
import 'password_hasher.dart';
import 'seed_credentials.dart';

/// Used where SQLite is unavailable — notably the web build, which has no
/// sqflite implementation. Same contract and the same hashing; it simply does
/// not survive a reload.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository({bool withDemoAccount = false}) {
    // The hash is precomputed, so this is a map insert rather than the ~860 ms
    // key derivation it used to be — no lazy seeding to race against.
    if (withDemoAccount) {
      _byEmail[normaliseEmail(kSeedEmail)] = _Record(
        Account(id: _nextId++, fullName: kSeedFullName, email: normaliseEmail(kSeedEmail), phone: kSeedPhone),
        kSeedHash,
        kSeedSalt,
      );
    }
  }

  final Map<String, _Record> _byEmail = {};
  var _nextId = 1;

  @override
  Future<Account> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final normalised = normaliseEmail(email);
    if (_byEmail.containsKey(normalised)) throw const AuthException(AuthError.emailTaken);

    final salt = PasswordHasher.newSalt();
    final account = Account(
      id: _nextId++,
      fullName: fullName.trim(),
      email: normalised,
      phone: phone.trim(),
    );
    _byEmail[normalised] = _Record(account, await PasswordHasher.hashAsync(password, salt), salt);
    return account;
  }

  @override
  Future<Account> signIn({required String email, required String password}) async {
    final record = _byEmail[normaliseEmail(email)];
    if (record == null) throw const AuthException(AuthError.invalidCredentials);
    if (!await PasswordHasher.verifyAsync(password, record.salt, record.hash)) {
      throw const AuthException(AuthError.invalidCredentials);
    }
    return record.account;
  }

  @override
  Future<bool> emailExists(String email) async {
    return _byEmail.containsKey(normaliseEmail(email));
  }

  @override
  Future<Account> updateProfile({
    required int id,
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final normalised = normaliseEmail(email);
    final current = _byEmail.entries.firstWhere(
      (e) => e.value.account.id == id,
      orElse: () => throw const AuthException(AuthError.unavailable),
    );
    if (normalised != current.key && _byEmail.containsKey(normalised)) {
      throw const AuthException(AuthError.emailTaken);
    }

    final updated = current.value.account
        .copyWith(fullName: fullName.trim(), email: normalised, phone: phone.trim());
    _byEmail.remove(current.key);
    _byEmail[normalised] = _Record(updated, current.value.hash, current.value.salt);
    return updated;
  }

  @override
  Future<int> accountCount() async {
    return _byEmail.length;
  }
}

class _Record {
  _Record(this.account, this.hash, this.salt);

  final Account account;
  final String hash;
  final String salt;
}
