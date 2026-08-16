// The demo account's hash is a compile-time constant so that first launch does
// not pay for a PBKDF2 run. That is only safe while the constant still matches
// what the hasher would produce — otherwise the seeded account silently stops
// accepting its own documented password.

import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/db/password_hasher.dart';
import 'package:fedayns_rent_car/data/db/seed_credentials.dart';
import 'package:fedayns_rent_car/data/fleet.dart';

void main() {
  test('the precomputed hash verifies the seed password', () {
    expect(
      PasswordHasher.verify(kSeedPassword, kSeedSalt, kSeedHash),
      isTrue,
      reason: 'regenerate kSeedHash — the password or defaultIterations changed',
    );
  });

  test('it is the derivation, not a lookalike', () {
    expect(
      PasswordHasher.hash(kSeedPassword, kSeedSalt),
      kSeedHash,
    );
  });

  test('a wrong password still fails against it', () {
    expect(
      PasswordHasher.verify('wrong-password', kSeedSalt, kSeedHash),
      isFalse,
    );
  });
}
