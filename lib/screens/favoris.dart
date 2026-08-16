import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../data/flotte.dart';
import '../widgets/carte_voiture.dart';

class FavorisPage extends StatelessWidget {
  final Set<String> favoris;
  final void Function(String id) onToggleFavori;
  final VoidCallback onParcourir;

  const FavorisPage({
    super.key,
    required this.favoris,
    required this.onToggleFavori,
    required this.onParcourir,
  });

  @override
  Widget build(BuildContext context) {
    final liste = flotte.where((v) => favoris.contains(v.id)).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Voitures enregistrées',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              liste.isEmpty
                  ? 'Aucune voiture pour le moment'
                  : '${liste.length} voiture${liste.length > 1 ? 's' : ''} que vous aimez',
              style: const TextStyle(
                  fontSize: 14.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: liste.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_border,
                              size: 64, color: AppColors.border),
                          const SizedBox(height: 16),
                          const Text('Aucune voiture enregistrée',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              'Touchez le cœur sur une voiture pour la retrouver ici',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 220,
                            child: ElevatedButton(
                              onPressed: onParcourir,
                              child: const Text('Parcourir les voitures'),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: liste.length,
                      itemBuilder: (_, i) => CarteVoiture(
                        voiture: liste[i],
                        favori: true,
                        onFavori: () => onToggleFavori(liste[i].id),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
