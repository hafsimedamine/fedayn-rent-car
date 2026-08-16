/// A registered account, as stored in the `users` table.
///
/// Deliberately carries no password material — the hash and salt never leave
/// the repository layer.
class Account {
  const Account({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  final int id;
  final String fullName;
  final String email;
  final String phone;

  /// First word of the full name, for greetings. Falls back to the whole
  /// string when someone registers with a single-word name.
  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.isEmpty ? fullName.trim() : parts.first;
  }

  Account copyWith({String? fullName, String? email, String? phone}) => Account(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );

  static Account fromRow(Map<String, Object?> row) => Account(
        id: row['id']! as int,
        fullName: row['full_name']! as String,
        email: row['email']! as String,
        phone: row['phone']! as String,
      );
}
