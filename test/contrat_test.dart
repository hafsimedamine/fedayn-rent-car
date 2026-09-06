// Le contenu du contrat : ce qui doit y figurer, et ce qui ne doit pas manquer.
//
// Vérifié sur la structure plutôt que sur les octets du PDF. Dès qu'une police
// TrueType est embarquée — et il en faut une, les Helvetica intégrées n'ayant
// aucun support Unicode — le texte du document est écrit en identifiants de
// glyphes. Le risque réel est d'oublier une information, pas de mal l'encoder ;
// c'est donc cela qu'on teste, ligne à ligne.

import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/contrat.dart';
import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/data/models.dart';

Booking reservation({
  String ref = 'RC4821',
  String carId = 'c_duster',
  String lieu = 'Casablanca — Maarif',
  int duree = 4,
  int total = 1850,
}) {
  final debut = DateTime(2030, 7, 20);
  return Booking(
    ref: ref,
    carId: carId,
    startDate: debut,
    endDate: debut.add(Duration(days: duree)),
    totalPrice: total,
    pickLoc: lieu,
    retLoc: lieu,
    pickTime: '10:00',
    retTime: '18:00',
  );
}

const client = ClientContrat(
  prenom: 'Mohamed',
  nom: 'Moncef',
  telephone: '0655555555',
  cin: 'TU 123456',
  permis: '19/123456',
);

/// Valeur d'une ligne, cherchée par son libellé.
String valeur(ContratContenu c, String libelle) => c.sections
    .expand((s) => s.lignes)
    .firstWhere((l) => l.$1 == libelle, orElse: () => (libelle, '<absent>'))
    .$2;

void main() {
  late ContratContenu contrat;

  setUp(() {
    contrat = construireContrat(
      booking: reservation(),
      client: client,
      emisLe: DateTime(2030, 7, 15),
    );
  });

  group("en-tête de l'agence", () {
    test('le nom de l\'application est intact', () {
      expect(kBrand, "Fedayn's Rent Car");
    });

    test('l\'agence correspond au lieu de prise en charge', () {
      expect(contrat.agence.name, kAgencies['maarif']!.name);
      expect(contrat.agence.addr, kAgencies['maarif']!.addr);
      expect(contrat.agence.tel, kAgencies['maarif']!.tel);
    });

    test('chaque lieu proposé mène à une agence', () {
      for (final lieu in kLocations) {
        final c = construireContrat(booking: reservation(lieu: lieu), client: client);
        expect(c.agence.name, isNotEmpty, reason: '« $lieu » ne résout aucune agence');
      }
      expect(agencePourLieu('Rabat — Agdal').name, kAgencies['agdal']!.name);
      expect(agencePourLieu('Casablanca — Airport').name, kAgencies['aeroport']!.name);
    });

    test('un lieu inconnu retombe sur le siège plutôt que sur rien', () {
      expect(agencePourLieu('Tanger — Inexistant').name, kAgencies['maarif']!.name);
    });

    test('la référence et la date d\'établissement', () {
      expect(contrat.reference, 'RC4821');
      expect(contrat.emisLe, DateTime(2030, 7, 15));
    });
  });

  group('locataire', () {
    test('nom, prénom, téléphone, CIN et permis', () {
      expect(valeur(contrat, 'Nom'), 'Moncef');
      expect(valeur(contrat, 'Prénom'), 'Mohamed');
      expect(valeur(contrat, 'Téléphone'), '0655555555');
      expect(valeur(contrat, 'Numéro de CIN'), 'TU 123456');
      expect(valeur(contrat, 'Numéro de permis'), '19/123456');
    });

    test('une information absente est signalée, pas laissée en blanc', () {
      final c = construireContrat(
        booking: reservation(),
        client: const ClientContrat(prenom: 'Amine', nom: 'Tazi', telephone: '', cin: '', permis: ''),
      );
      expect(valeur(c, 'Numéro de CIN'), ClientContrat.absent);
      expect(valeur(c, 'Numéro de permis'), ClientContrat.absent);
      expect(valeur(c, 'Téléphone'), ClientContrat.absent);
      expect(valeur(c, 'Nom'), 'Tazi', reason: 'ce qui est fourni doit rester');
    });

    test('estComplet distingue un dossier plein d\'un dossier partiel', () {
      expect(client.estComplet, isTrue);
      expect(const ClientContrat(prenom: 'A', nom: 'B', telephone: '06', cin: '', permis: 'X').estComplet, isFalse);
    });
  });

  group('véhicule', () {
    test('marque, modèle, catégorie et immatriculation', () {
      expect(valeur(contrat, 'Marque'), 'Dacia');
      expect(valeur(contrat, 'Modèle'), 'Duster');
      expect(valeur(contrat, 'Catégorie'), catFr(carById('c_duster').cat));
      expect(valeur(contrat, 'Immatriculation'), kSpecs['c_duster']!.plate);
    });

    test('une marque en deux mots n\'est pas coupée au premier espace', () {
      final c = construireContrat(booking: reservation(carId: 'c_evoque'), client: client);
      expect(valeur(c, 'Marque'), 'Range Rover');
      expect(valeur(c, 'Modèle'), 'Evoque');
    });

    test('toutes les voitures de la flotte donnent une immatriculation', () {
      for (final car in kCars) {
        final c = construireContrat(booking: reservation(carId: car.id), client: client);
        expect(valeur(c, 'Immatriculation'), isNot('—'), reason: '${car.name} sans plaque');
        expect(valeur(c, 'Marque'), isNotEmpty, reason: '${car.name} sans marque');
      }
    });
  });

  group('période et montant', () {
    test('dates de début et de fin, avec les heures', () {
      expect(valeur(contrat, 'Date de début'), '20 juillet 2030 à 10:00');
      expect(valeur(contrat, 'Date de fin'), '24 juillet 2030 à 18:00');
    });

    test('durée en jours', () {
      expect(contrat.jours, 4);
      expect(valeur(contrat, 'Durée'), '4 jours');
    });

    test('la durée s\'accorde au singulier', () {
      final c = construireContrat(booking: reservation(duree: 1), client: client);
      expect(c.dureeAffichee, '1 jour');
    });

    test('total en MAD, groupé à la française', () {
      // fmtMad sépare les milliers par une espace insécable (U+00A0) : coder
      // une espace ordinaire dans l'attendu ferait échouer sur un caractère
      // invisible.
      expect(contrat.totalAffiche, '${fmtMad(1850)} MAD');
      expect(contrat.totalAffiche, contains('\u00A0'));
      expect(contrat.totalMad, 1850);
    });

    test('le tarif journalier vient de la voiture', () {
      expect(contrat.tarifJournalier, carById('c_duster').price);
      expect(contrat.tarifAffiche, '${fmtMad(450)} MAD / jour');
    });

    test('les deux lieux figurent au contrat', () {
      expect(valeur(contrat, 'Lieu de prise en charge'), 'Casablanca — Maarif');
      expect(valeur(contrat, 'Lieu de restitution'), 'Casablanca — Maarif');
    });
  });

  test('la liste des inclus est celle de la flotte, complète', () {
    expect(contrat.inclus, kIncluded);
    expect(contrat.inclus, isNotEmpty);
  });

  test('aucune valeur du contrat n\'est vide', () {
    for (final v in contrat.toutesLesValeurs) {
      expect(v.trim(), isNotEmpty, reason: 'une ligne du contrat est vide');
    }
  });

  test('les libellés sont en français', () {
    final libelles = contrat.sections.expand((s) => s.lignes).map((l) => l.$1).toList();
    expect(libelles, containsAll(['Nom', 'Prénom', 'Téléphone', 'Numéro de CIN', 'Numéro de permis']));
    expect(libelles, containsAll(['Marque', 'Modèle', 'Catégorie', 'Immatriculation']));
    expect(libelles, containsAll(['Date de début', 'Date de fin', 'Durée']));
    expect(contrat.sections.map((s) => s.titre), ['Locataire', 'Véhicule', 'Période de location']);
  });
}
