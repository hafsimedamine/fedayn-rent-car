// Password hashing for the local account store.
//
// PBKDF2-HMAC-SHA256 with a per-user random salt. Passwords are never stored,
// and never logged — only the derived key is persisted, alongside the salt and
// the iteration count so the cost can be raised later without invalidating
// existing accounts.

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class PasswordHasher {
  /// Cost. High enough to be meaningfully slow to brute-force, low enough not
  /// to stall a mid-range phone on sign-in.
  static const defaultIterations = 120000;

  static const _keyLength = 32; // bytes, matches SHA-256's output
  static final _random = Random.secure();

  /// 16 random bytes, base64-encoded.
  static String newSalt() {
    final bytes = Uint8List.fromList(List<int>.generate(16, (_) => _random.nextInt(256)));
    return base64Encode(bytes);
  }

  /// Derives the stored key for [password] under [salt].
  static String hash(String password, String salt, {int iterations = defaultIterations}) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final saltBytes = base64Decode(salt);
    final out = Uint8List(_keyLength);

    // PBKDF2 (RFC 8018). One block is enough: dkLen == hLen == 32.
    var written = 0;
    var block = 1;
    while (written < _keyLength) {
      final input = Uint8List(saltBytes.length + 4)
        ..setRange(0, saltBytes.length, saltBytes)
        ..buffer.asByteData().setUint32(saltBytes.length, block, Endian.big);

      var u = Uint8List.fromList(hmac.convert(input).bytes);
      final acc = Uint8List.fromList(u);
      for (var i = 1; i < iterations; i++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var j = 0; j < acc.length; j++) {
          acc[j] ^= u[j];
        }
      }

      final take = (_keyLength - written).clamp(0, acc.length);
      out.setRange(written, written + take, acc);
      written += take;
      block++;
    }
    return base64Encode(out);
  }

  /// Off-thread variants. Deriving the key takes on the order of a second, so
  /// running it inline would visibly freeze the UI while signing in. `compute`
  /// hops to a background isolate (and degrades to the same thread on web,
  /// which has none).
  static Future<String> hashAsync(String password, String salt,
      {int iterations = defaultIterations}) {
    // Web has no isolates, so compute() would run this inline and block the
    // frame — the loading indicator would never get a chance to paint. There,
    // derive in slices and yield between them instead.
    if (kIsWeb) return hashYielding(password, salt, iterations);
    return compute(_hashEntry, (password, salt, iterations));
  }

  /// Same derivation, spread across event-loop turns so the UI keeps painting.
  /// Must stay byte-identical to [hash] — a divergence would mean an account
  /// created on one platform could not sign in on another.
  @visibleForTesting
  static Future<String> hashYielding(String password, String salt, int iterations) async {
    const slice = 4000;
    final hmac = Hmac(sha256, utf8.encode(password));
    final saltBytes = base64Decode(salt);

    final input = Uint8List(saltBytes.length + 4)
      ..setRange(0, saltBytes.length, saltBytes)
      ..buffer.asByteData().setUint32(saltBytes.length, 1, Endian.big);

    var u = Uint8List.fromList(hmac.convert(input).bytes);
    final acc = Uint8List.fromList(u);
    for (var i = 1; i < iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < acc.length; j++) {
        acc[j] ^= u[j];
      }
      if (i % slice == 0) await Future<void>.delayed(Duration.zero);
    }
    return base64Encode(acc);
  }

  static Future<bool> verifyAsync(
    String password,
    String salt,
    String expectedHash, {
    int iterations = defaultIterations,
  }) async {
    final actual = await hashAsync(password, salt, iterations: iterations);
    return _constantTimeEquals(actual, expectedHash);
  }

  /// Constant-time comparison — a length-or-content early exit would leak how
  /// much of a guessed hash was correct.
  static bool verify(
    String password,
    String salt,
    String expectedHash, {
    int iterations = defaultIterations,
  }) {
    return _constantTimeEquals(hash(password, salt, iterations: iterations), expectedHash);
  }

  static bool _constantTimeEquals(String actual, String expected) {
    final a = utf8.encode(actual);
    final b = utf8.encode(expected);
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

/// Top-level so it can be sent to an isolate.
String _hashEntry((String, String, int) args) =>
    PasswordHasher.hash(args.$1, args.$2, iterations: args.$3);
