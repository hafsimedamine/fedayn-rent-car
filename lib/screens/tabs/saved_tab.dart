import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/car_card.dart';
import '../../widgets/common.dart';
import '../car_detail.dart';
import '../main_shell.dart';

class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final saved = app.savedCars;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Voitures enregistrées', style: AppText.heading(22)),
                const SizedBox(height: 2),
                Text(
                  saved.isEmpty
                      ? 'Aucune voiture pour le moment'
                      : '${saved.length} voiture${saved.length > 1 ? 's' : ''} que vous aimez',
                  style: AppText.body(13, color: context.p.muted),
                ),
              ],
            ),
            Expanded(
              child: saved.isEmpty
                  ? _EmptyState(onBrowse: () => MainShell.of(context).goToTab(0))
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      itemCount: saved.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final car = saved[i];
                        return CarCard(
                          car: car,
                          isFav: true,
                          onToggleFav: () {
                            app.toggleFav(car.id);
                            showAppToast(context, 'Retiré des favoris', onUndo: () => app.toggleFav(car.id));
                          },
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border_rounded, size: 64, color: Color(0xFFD5DBE3)),
              const SizedBox(height: 20),
              Text('Aucune voiture enregistrée', style: AppText.heading(19)),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Text(
                  "Touchez le cœur d'une voiture pour l'enregistrer ici.",
                  textAlign: TextAlign.center,
                  style: AppText.body(13.5, color: context.p.muted, height: 1.55),
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: onBrowse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
                ),
                child: Text('Parcourir les voitures', style: AppText.body(14, weight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
}
