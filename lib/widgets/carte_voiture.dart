import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/voiture.dart';

class CarteVoiture extends StatelessWidget {
  final Voiture voiture;
  final bool favori;
  final VoidCallback onFavori;
  final VoidCallback? onTap;

  const CarteVoiture({
    super.key,
    required this.voiture,
    required this.favori,
    required this.onFavori,
    this.onTap,
  });

  Color get _couleurDispo => switch (voiture.disponibilite) {
        Disponibilite.disponible => AppColors.success,
        Disponibilite.bientot => AppColors.warning,
        Disponibilite.louee => AppColors.textSecondary,
      };

  String get _texteDispo => switch (voiture.disponibilite) {
        Disponibilite.disponible => 'Disponible',
        Disponibilite.bientot => 'Dispo. le ${voiture.disponibleLe}',
        Disponibilite.louee => 'En location',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F0F2A3D),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Image + coeur ----------
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.asset(
                    voiture.photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFECEFF2),
                      child: const Center(
                        child: Icon(Icons.directions_car_rounded,
                            size: 44, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                if (voiture.estElectrique)
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _Badge(
                      icon: Icons.eco_rounded,
                      texte: 'Électrique',
                      couleur: AppColors.success,
                    ),
                  ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: onFavori,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        favori ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: favori
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ---------- Infos ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          voiture.nomComplet,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(Icons.star_rounded,
                          size: 18, color: AppColors.accent),
                      const SizedBox(width: 3),
                      Text(
                        '${voiture.note}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        ' (${voiture.nbAvis})',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${voiture.categorie.label} • ${voiture.transmission}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13.5),
                  ),
                  const SizedBox(height: 12),

                  // specs
                  Row(
                    children: [
                      _Spec(
                          icon: Icons.event_seat_outlined,
                          texte: '${voiture.nbPlaces} places'),
                      const SizedBox(width: 14),
                      _Spec(
                          icon: Icons.local_gas_station_outlined,
                          texte: voiture.carburant),
                      const SizedBox(width: 14),
                      const _Spec(icon: Icons.ac_unit_rounded, texte: 'Clim'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),

                  // dispo + prix
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(bottom: 5, right: 7),
                        decoration: BoxDecoration(
                          color: _couleurDispo,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _texteDispo,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: _couleurDispo,
                          ),
                        ),
                      ),
                      Text(
                        '${voiture.prixJour.toStringAsFixed(0)} MAD',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 3, left: 2),
                        child: Text('/jour',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String texte;
  const _Spec({required this.icon, required this.texte});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(texte,
              style: const TextStyle(
                  fontSize: 12.5, color: AppColors.textSecondary)),
        ],
      );
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String texte;
  final Color couleur;
  const _Badge(
      {required this.icon, required this.texte, required this.couleur});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 5),
            Text(texte,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
