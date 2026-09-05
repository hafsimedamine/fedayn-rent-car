// PBKDF2-HMAC-SHA256 checked against published test vectors. A KDF that only
// round-trips (register then sign in) can still be wrong; these pin the actual
// derived bytes.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/db/password_hasher.dart';

String _hex(String base64Value) =>
    base64Decode(base64Value).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  // Vectors for PBKDF2-HMAC-SHA256, dkLen = 32.
  final saltOfSalt = base64Encode(utf8.encode('salt'));

  test('matches the published vector at c=1', () {
    expect(
      _hex(PasswordHasher.hash('password', saltOfSalt, iterations: 1)),
      '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
    );
  });

  test('matches the published vector at c=2', () {
    expect(
      _hex(PasswordHasher.hash('password', saltOfSalt, iterations: 2)),
      'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43',
    );
  });

  test('matches the published vector at c=4096', () {
    expect(
      _hex(PasswordHasher.hash('password', saltOfSalt, iterations: 4096)),
      'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
    );
  });

  test('the yielding path matches the sync path exactly', () async {
    // Web has no isolates and uses the yielding variant; if the two ever
    // diverged, an account made on web could not sign in on a phone.
    for (final iterations in [1, 2, 1000, 4096]) {
      final salt = PasswordHasher.newSalt();
      expect(
        await PasswordHasher.hashYielding('Motdepasse!1', salt, iterations),
        PasswordHasher.hash('Motdepasse!1', salt, iterations: iterations),
        reason: 'mismatch at \$iterations iterations',
      );
    }
  });

  test('the yielding path matches the published vectors too', () async {
    expect(
      _hex(await PasswordHasher.hashYielding('password', saltOfSalt, 4096)),
      'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
    );
  });

  test('salts are random and 16 bytes', () {
    final a = PasswordHasher.newSalt();
    final b = PasswordHasher.newSalt();
    expect(a, isNot(b));
    expect(base64Decode(a).length, 16);
  });

  test('same password under different salts derives different keys', () {
    final h1 = PasswordHasher.hash('hunter2', PasswordHasher.newSalt(), iterations: 1000);
    final h2 = PasswordHasher.hash('hunter2', PasswordHasher.newSalt(), iterations: 1000);
    expect(h1, isNot(h2), reason: 'salting must defeat precomputed tables');
  });

  test('verify accepts the right password and rejects the wrong one', () {
    final salt = PasswordHasher.newSalt();
    final stored = PasswordHasher.hash('Motdepasse!1', salt, iterations: 1000);

    expect(PasswordHasher.verify('Motdepasse!1', salt, stored, iterations: 1000), isTrue);
    expect(PasswordHasher.verify('motdepasse2', salt, stored, iterations: 1000), isFalse);
    expect(PasswordHasher.verify('', salt, stored, iterations: 1000), isFalse);
  });

  test('the stored value never contains the password', () {
    final salt = PasswordHasher.newSalt();
    final stored = PasswordHasher.hash('Motdepasse!1', salt, iterations: 1000);
    expect(stored.contains('Motdepasse!1'), isFalse);
  });
}
