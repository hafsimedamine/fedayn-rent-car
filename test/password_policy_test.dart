// Règles du mot de passe et générateur. Le point important : tout mot de passe
// produit par le générateur doit passer la validation — les deux ne peuvent pas
// diverger sans que ce fichier le signale.

import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/password_policy.dart';
import 'package:fedayns_rent_car/widgets/fields.dart';

void main() {
  group('validation', () {
    test('accepte un mot de passe conforme', () {
      for (final v in ['Motdepasse!', 'A1b2c3d!', 'Été2026#chaud', r'XXXXXXX$']) {
        expect(PasswordPolicy.validate(v), isNull, reason: '« $v » refusé à tort');
      }
    });

    test('une majuscule accentuée compte comme une majuscule', () {
      // [A-Z] ne matche pas « É » : dans une application française, exiger une
      // majuscule de « Été2026#chaud » serait absurde.
      expect(PasswordPolicy.validate('Été2026#chaud'), isNull);
      expect(PasswordPolicy.validate('Ça суffit!1'), isNull);
    });

    test('une lettre accentuée ne compte pas comme un symbole', () {
      expect(PasswordPolicy.validate('Été2026chaud'), 'Ajoutez au moins un symbole (par exemple ! ? @ #)');
    });

    test('refuse un mot de passe vide', () {
      expect(PasswordPolicy.validate(''), 'Saisissez un mot de passe');
    });

    test('refuse moins de 8 caractères', () {
      expect(PasswordPolicy.validate('Ab!12'), 'Le mot de passe doit contenir au moins 8 caractères');
    });

    test('refuse sans majuscule', () {
      expect(PasswordPolicy.validate('motdepasse!'), 'Ajoutez au moins une majuscule');
    });

    test('refuse sans symbole', () {
      expect(PasswordPolicy.validate('Motdepasse1'), 'Ajoutez au moins un symbole (par exemple ! ? @ #)');
    });

    test('un symbole est tout ce qui n\'est ni lettre ni chiffre', () {
      // Le générateur n'utilise pas ces caractères, mais les refuser serait
      // absurde si l'utilisateur les tape.
      for (final sym in ['~', '^', '<', '>', '«', '€']) {
        expect(PasswordPolicy.validate('Motdepasse$sym'), isNull, reason: 'symbole « $sym » refusé');
      }
    });

    test('V.pw et PasswordPolicy disent la même chose', () {
      for (final v in ['', 'court', 'minuscules!', 'SansSymbole1', 'Correct!1']) {
        expect(V.pw(v), PasswordPolicy.validate(v), reason: v);
      }
    });
  });

  group('générateur', () {
    test('produit toujours un mot de passe valide', () {
      for (var i = 0; i < 500; i++) {
        final pw = PasswordPolicy.generate();
        expect(PasswordPolicy.validate(pw), isNull, reason: '« $pw » ne passe pas ses propres règles');
      }
    });

    test('respecte la longueur demandée', () {
      expect(PasswordPolicy.generate().length, PasswordPolicy.generatedLength);
      expect(PasswordPolicy.generate(length: 24).length, 24);
      expect(PasswordPolicy.generate(length: 8).length, 8);
    });

    test('refuse une longueur sous le minimum', () {
      expect(() => PasswordPolicy.generate(length: 4), throwsArgumentError);
    });

    test('évite les caractères ambigus', () {
      for (var i = 0; i < 300; i++) {
        expect(PasswordPolicy.generate(), isNot(matches(RegExp(r'[O0lI1]'))),
            reason: 'un caractère ambigu est difficile à recopier');
      }
    });

    test('ne place pas les classes requises toujours au même endroit', () {
      // Sans mélange, le premier caractère serait toujours une majuscule.
      final premiers = <String>{};
      for (var i = 0; i < 200; i++) {
        premiers.add(PasswordPolicy.generate()[0]);
      }
      expect(premiers.map((c) => RegExp(r'[A-Z]').hasMatch(c)).toSet().length, 2,
          reason: 'la première position devrait parfois ne pas être une majuscule');
    });

    test('ne se répète pas', () {
      final vus = <String>{};
      for (var i = 0; i < 200; i++) {
        vus.add(PasswordPolicy.generate());
      }
      expect(vus.length, 200, reason: 'deux tirages identiques sur 200');
    });
  });
}
