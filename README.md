# LocaDrive — application de location de voitures

Projet de fin d'études (Master) — Flutter.

## Contenu actuel

- Thème complet (couleurs, typographie, boutons, champs)
- Modèle `Voiture` + flotte de 17 véhicules du marché marocain
- **Les 17 photos sont déjà incluses** dans `assets/images/`
- Écran Accueil : recherche, filtres par catégorie, liste de voitures
- Onglet Favoris : ajout/retrait au cœur, état vide
- Navigation à 4 onglets (Accueil, Locations, Favoris, Compte)
- Interface entièrement en français, prix en MAD

## Lancer le projet

```bash
flutter create . --project-name locadrive   # génère android/ios/web
flutter pub get
flutter run
```

> `flutter create .` ne touche pas aux fichiers existants (lib/, assets/,
> pubspec.yaml) : il ajoute seulement les dossiers de plateforme manquants.

## Prochaines étapes

1. Écran détail voiture
2. Tunnel de réservation (dates → récapitulatif → paiement → confirmation)
3. Authentification + inscription (scan CIN / permis)
4. Branchement Supabase : remplacer `data/flotte.dart` par un appel réseau
   (`Voiture.fromMap` est déjà prêt pour ça)
5. Tableau de bord admin + analytique
