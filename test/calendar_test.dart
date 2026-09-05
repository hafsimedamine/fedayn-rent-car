// Le calendrier réel : plus de « juillet 2026 » en dur.

import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/calendar.dart';

void main() {
  group('longueur des mois', () {
    test('mois usuels', () {
      expect(joursDansLeMois(2026, 1), 31);
      expect(joursDansLeMois(2026, 4), 30);
      expect(joursDansLeMois(2026, 12), 31);
    });

    test('février bissextile', () {
      expect(joursDansLeMois(2026, 2), 28);
      expect(joursDansLeMois(2028, 2), 29, reason: '2028 est bissextile');
      expect(joursDansLeMois(2000, 2), 29, reason: '2000 est bissextile (divisible par 400)');
      expect(joursDansLeMois(1900, 2), 28, reason: '1900 ne l\'est pas (divisible par 100)');
    });
  });

  group('début du mois', () {
    test('0 = lundi', () {
      // 1er juin 2026 est un lundi.
      expect(decalagePremierJour(2026, 6), 0);
      // 1er juillet 2026 est un mercredi.
      expect(decalagePremierJour(2026, 7), 2);
      // 1er novembre 2026 est un dimanche.
      expect(decalagePremierJour(2026, 11), 6);
    });

    test('le décalage reste dans la semaine', () {
      for (var annee = 2025; annee <= 2030; annee++) {
        for (var mois = 1; mois <= 12; mois++) {
          final d = decalagePremierJour(annee, mois);
          expect(d, inInclusiveRange(0, 6), reason: '$annee-$mois');
        }
      }
    });
  });

  group('formats français', () {
    test('jour et mois', () {
      expect(formatJourMois(DateTime(2026, 7, 14)), '14 juillet');
      expect(formatJourMois(DateTime(2026, 8, 1)), '1 août');
    });

    test('abrégés corrects', () {
      expect(formatCourt(DateTime(2026, 6, 3)), '3 juin', reason: 'juin ne s\'abrège pas');
      expect(formatCourt(DateTime(2026, 8, 3)), '3 août', reason: 'août ne s\'abrège pas');
      expect(formatCourt(DateTime(2026, 7, 3)), '3 juil.');
      expect(formatCourt(DateTime(2026, 9, 3)), '3 sept.');
    });

    test('période dans le même mois n\'écrit le mois qu\'une fois', () {
      expect(formatPeriode(DateTime(2026, 7, 14), DateTime(2026, 7, 18)), '14 – 18 juil.');
    });

    test('période à cheval sur deux mois écrit les deux', () {
      expect(formatPeriode(DateTime(2026, 7, 30), DateTime(2026, 8, 2)), '30 juil. – 2 août');
    });

    test('durée accordée en nombre', () {
      expect(formatDuree(1), '1 jour');
      expect(formatDuree(4), '4 jours');
    });
  });

  group('calculs', () {
    test('nuits entre deux dates', () {
      expect(nuitsEntre(DateTime(2026, 7, 20), DateTime(2026, 7, 24)), 4);
      expect(nuitsEntre(DateTime(2026, 7, 20), DateTime(2026, 7, 20)), 0);
    });

    test('une heure de la journée ne change pas le compte', () {
      expect(nuitsEntre(DateTime(2026, 7, 20, 23, 59), DateTime(2026, 7, 21, 0, 1)), 1);
    });

    test('la traversée d\'un mois est comptée juste', () {
      expect(nuitsEntre(DateTime(2026, 7, 30), DateTime(2026, 8, 2)), 3);
    });

    test('joursDe est inclusif aux deux bouts', () {
      final jours = joursDe(DateTime(2026, 7, 20), DateTime(2026, 7, 23));
      expect(jours.length, 4);
      expect(jours.first, DateTime(2026, 7, 20));
      expect(jours.last, DateTime(2026, 7, 23));
    });

    test('moisDecale franchit l\'année', () {
      expect(moisDecale(DateTime(2026, 11, 1), 3), DateTime(2027, 2, 1));
      expect(moisDecale(DateTime(2026, 2, 1), -3), DateTime(2025, 11, 1));
    });

    test('memeJour ignore l\'heure', () {
      expect(memeJour(DateTime(2026, 7, 20, 8), DateTime(2026, 7, 20, 22)), isTrue);
      expect(memeJour(DateTime(2026, 7, 20), DateTime(2026, 7, 21)), isFalse);
    });
  });

  test('aujourdHui suit l\'horloge, sans heure', () {
    final maintenant = DateTime.now();
    expect(aujourdHui.year, maintenant.year);
    expect(aujourdHui.month, maintenant.month);
    expect(aujourdHui.day, maintenant.day);
    expect(aujourdHui.hour, 0);
    expect(aujourdHui.minute, 0);
  });
}
