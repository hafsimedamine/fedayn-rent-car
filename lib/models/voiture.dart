enum Categorie { citadine, economique, berline, suv, luxe, electrique }

extension CategorieLabel on Categorie {
  String get label => switch (this) {
        Categorie.citadine => 'Citadine',
        Categorie.economique => 'Économique',
        Categorie.berline => 'Berline',
        Categorie.suv => 'SUV',
        Categorie.luxe => 'Luxe',
        Categorie.electrique => 'Électrique',
      };
}

enum Disponibilite { disponible, bientot, louee }

extension DisponibiliteLabel on Disponibilite {
  String get label => switch (this) {
        Disponibilite.disponible => 'Disponible',
        Disponibilite.bientot => 'Bientôt disponible',
        Disponibilite.louee => 'En location',
      };
}

class Voiture {
  final String id;
  final String marque;
  final String modele;
  final int annee;
  final Categorie categorie;
  final String transmission; // Manuelle / Automatique
  final String carburant; // Essence / Diesel / Électrique
  final int nbPlaces;
  final double prixJour; // en MAD
  final double note;
  final int nbAvis;
  final Disponibilite disponibilite;
  final String? disponibleLe; // ex. "16 juil."
  final String photo; // chemin asset local
  final String agence;

  const Voiture({
    required this.id,
    required this.marque,
    required this.modele,
    required this.annee,
    required this.categorie,
    required this.transmission,
    required this.carburant,
    required this.nbPlaces,
    required this.prixJour,
    required this.note,
    required this.nbAvis,
    required this.disponibilite,
    required this.photo,
    required this.agence,
    this.disponibleLe,
  });

  String get nomComplet => '$marque $modele';

  bool get estElectrique => categorie == Categorie.electrique;

  /// Construction depuis Supabase (quand tu brancheras la base).
  factory Voiture.fromMap(Map<String, dynamic> m) => Voiture(
        id: m['id'].toString(),
        marque: m['marque'] as String,
        modele: m['modele'] as String,
        annee: m['annee'] as int? ?? 2022,
        categorie: Categorie.values.firstWhere(
          (c) => c.name == (m['categorie'] as String?),
          orElse: () => Categorie.economique,
        ),
        transmission: m['transmission'] as String? ?? 'Manuelle',
        carburant: m['carburant'] as String? ?? 'Essence',
        nbPlaces: m['nb_places'] as int? ?? 5,
        prixJour: (m['prix_jour'] as num).toDouble(),
        note: (m['note_moyenne'] as num?)?.toDouble() ?? 0,
        nbAvis: m['nb_avis'] as int? ?? 0,
        disponibilite: Disponibilite.values.firstWhere(
          (d) => d.name == (m['statut'] as String?),
          orElse: () => Disponibilite.disponible,
        ),
        photo: m['photo_url'] as String? ?? '',
        agence: m['agence'] as String? ?? 'Casablanca - Maarif',
      );
}
