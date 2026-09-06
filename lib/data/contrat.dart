// Contenu du contrat de location, indépendamment de sa mise en page.
//
// Séparé du rendu PDF pour une raison pratique : dès qu'une police TrueType est
// embarquée, `pdf` écrit le texte sous forme d'identifiants de glyphes, et on ne
// peut plus relire le document sans décoder ses tables ToUnicode. Or le risque
// réel n'est pas l'encodage des octets, c'est d'oublier une information au
// contrat. Cette structure-là se vérifie ligne à ligne.

import 'calendar.dart';
import 'fleet.dart';
import 'models.dart';

/// Le locataire, tel qu'il figure au contrat.
class ClientContrat {
  const ClientContrat({
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.cin,
    required this.permis,
  });

  final String prenom;
  final String nom;
  final String telephone;
  final String cin;
  final String permis;

  /// Ce qui n'a pas été fourni est signalé sur le document plutôt que laissé
  /// en blanc : une case vide se lit comme un oubli d'impression.
  static const absent = 'Non renseigné';

  static String _ou(String v) => v.trim().isEmpty ? absent : v.trim();

  String get prenomAffiche => _ou(prenom);
  String get nomAffiche => _ou(nom);
  String get telephoneAffiche => _ou(telephone);
  String get cinAffiche => _ou(cin);
  String get permisAffiche => _ou(permis);

  bool get estComplet => [prenom, nom, telephone, cin, permis].every((v) => v.trim().isNotEmpty);
}

/// Un bloc de lignes « libellé : valeur ».
class SectionContrat {
  const SectionContrat(this.titre, this.lignes);

  final String titre;
  final List<(String libelle, String valeur)> lignes;
}

/// Tout ce qui doit apparaître au contrat.
class ContratContenu {
  const ContratContenu({
    required this.reference,
    required this.emisLe,
    required this.agence,
    required this.sections,
    required this.tarifJournalier,
    required this.jours,
    required this.totalMad,
    required this.inclus,
  });

  final String reference;
  final DateTime emisLe;
  final Agency agence;
  final List<SectionContrat> sections;
  final int tarifJournalier;
  final int jours;
  final int totalMad;
  final List<String> inclus;

  String get totalAffiche => '${fmtMad(totalMad)} MAD';
  String get tarifAffiche => '${fmtMad(tarifJournalier)} MAD / jour';
  String get dureeAffichee => formatDuree(jours);

  /// Toutes les valeurs du document, pour vérifier qu'aucune ne manque.
  Iterable<String> get toutesLesValeurs sync* {
    yield reference;
    yield agence.name;
    yield agence.addr;
    yield agence.tel;
    for (final s in sections) {
      for (final (_, valeur) in s.lignes) {
        yield valeur;
      }
    }
    yield* inclus;
    yield totalAffiche;
  }
}

/// Assemble le contrat à partir d'une réservation et de son locataire.
ContratContenu construireContrat({
  required Booking booking,
  required ClientContrat client,
  DateTime? emisLe,
}) {
  final car = carById(booking.carId);
  final spec = kSpecs[booking.carId];
  final (marque, modele) = marqueEtModele(car);
  final jours = nuitsEntre(booking.startDate, booking.endDate);

  return ContratContenu(
    reference: booking.ref,
    emisLe: emisLe ?? DateTime.now(),
    agence: agencePourLieu(booking.pickLoc),
    tarifJournalier: car.price,
    jours: jours,
    totalMad: booking.totalPrice,
    inclus: kIncluded,
    sections: [
      SectionContrat('Locataire', [
        ('Nom', client.nomAffiche),
        ('Prénom', client.prenomAffiche),
        ('Téléphone', client.telephoneAffiche),
        ('Numéro de CIN', client.cinAffiche),
        ('Numéro de permis', client.permisAffiche),
      ]),
      SectionContrat('Véhicule', [
        ('Marque', marque),
        ('Modèle', modele.isEmpty ? '—' : modele),
        ('Catégorie', catFr(car.cat)),
        ('Immatriculation', spec?.plate ?? '—'),
      ]),
      SectionContrat('Période de location', [
        ('Date de début', '${formatComplet(booking.startDate)} à ${booking.pickTime}'),
        ('Date de fin', '${formatComplet(booking.endDate)} à ${booking.retTime}'),
        ('Durée', formatDuree(jours)),
        ('Lieu de prise en charge', booking.pickLoc),
        ('Lieu de restitution', booking.retLoc),
      ]),
    ],
  );
}
