import 'account.dart';

/// Why a sign-in or registration was refused. Kept as an enum so the UI can
/// pick its own wording rather than displaying whatever the store said.
enum AuthError {
  emailTaken,
  invalidCredentials,
  unavailable,
}

class AuthException implements Exception {
  const AuthException(this.error);

  final AuthError error;

  /// French copy for the UI.
  String get message => switch (error) {
        AuthError.emailTaken => 'Cette adresse e-mail est déjà utilisée.',
        // Deliberately does not say which of the two was wrong — that would
        // let someone probe which addresses have accounts.
        AuthError.invalidCredentials => 'E-mail ou mot de passe incorrect.',
        AuthError.unavailable => 'Service indisponible. Réessayez.',
      };

  @override
  String toString() => 'AuthException(${error.name})';
}

/// Account storage. Implemented over SQLite on device; swapping in a remote
/// API later means writing one more implementation, not touching the screens.
abstract interface class AuthRepository {
  Future<Account> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<Account> signIn({required String email, required String password});

  Future<bool> emailExists(String email);

  /// Persists profile edits. Returns the updated account.
  Future<Account> updateProfile({
    required int id,
    required String fullName,
    required String email,
    required String phone,
  });

  Future<int> accountCount();
}

/// Email is the login key, so it is normalised once here and everywhere.
String normaliseEmail(String email) => email.trim().toLowerCase();
