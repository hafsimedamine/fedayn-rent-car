// Numéro marocain : 10 chiffres, préfixe 06 ou 07.

import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/widgets/fields.dart';

void main() {
  group('accepte', () {
    for (final v in [
      '0612345678',
      '0712345678',
      '06 12 34 56 78',
      '06-12-34-56-78',
      '06.12.34.56.78',
      '0612 345 678',
      '  0612345678  ',
      '+212 612345678',
      '+212 6 12 34 56 78',
      '00212612345678',
      '0761234567'.padRight(10, '8'),
    ]) {
      test('« $v »', () => expect(V.phone(v), isNull, reason: 'refusé à tort'));
    }
  });

  group('refuse', () {
    test('trop court', () {
      expect(V.phone('061234567'), 'Le numéro doit contenir 10 chiffres (9 saisis)');
    });

    test('trop long', () {
      expect(V.phone('06123456789'), 'Le numéro doit contenir 10 chiffres (11 saisis)');
    });

    test('mauvais préfixe', () {
      for (final v in ['0512345678', '0812345678', '0912345678', '0212345678']) {
        expect(V.phone(v), 'Le numéro doit commencer par 06 ou 07', reason: v);
      }
    });

    test('vide', () {
      expect(V.phone(''), 'Saisissez votre numéro de téléphone');
      expect(V.phone('   '), 'Saisissez votre numéro de téléphone');
    });

    test('lettres', () {
      expect(V.phone('06ABCDEFGH'), 'Le numéro ne doit contenir que des chiffres');
    });

    test('un numéro fixe de Casablanca (0522) est refusé', () {
      expect(V.phone('0522123456'), isNotNull);
    });
  });

  group('normalisation', () {
    test('retire la ponctuation', () {
      expect(V.normalisePhone('06 12-34.56(78)'), '0612345678');
    });

    test('ramène +212 à la forme nationale', () {
      expect(V.normalisePhone('+212612345678'), '0612345678');
      expect(V.normalisePhone('00212612345678'), '0612345678');
      expect(V.normalisePhone('212612345678'), '0612345678');
    });

    test('laisse un numéro national intact', () {
      expect(V.normalisePhone('0612345678'), '0612345678');
    });
  });

  test('les messages sont en français', () {
    // Contrôle explicite plutôt qu'une heuristique : une regex sur des mots
    // anglais matchait « phone » à l'intérieur de « téléphone ».
    const attendus = {
      'Saisissez votre numéro de téléphone',
      'Le numéro ne doit contenir que des chiffres',
      'Le numéro doit commencer par 06 ou 07',
    };
    for (final v in ['', '   ', '0512345678', '06ABCDEFGH']) {
      expect(attendus, contains(V.phone(v)), reason: 'message inattendu pour « $v »');
    }
    expect(V.phone('06123'), startsWith('Le numéro doit contenir 10 chiffres'));
  });
}
