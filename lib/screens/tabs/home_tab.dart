import 'package:flutter/material.dart';

import '../../data/fleet.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/car_card.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_picker.dart';
import '../../widgets/skip_verification.dart';
import '../../widgets/sort_sheet.dart';
import '../verify_cin.dart';
import '../car_detail.dart';
import '../main_shell.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final cars = app.visibleCars;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            sliver: SliverList.list(children: [
          const Center(child: BrandLogo(size: 34)),
          const SizedBox(height: 16),
          Divider(color: context.p.chipBg, height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // No emoji: the bundled font subset has no glyph for one,
                    // so it renders as a notdef box on the web build.
                    Text('Bonjour, ${app.displayFirstName}', style: AppText.heading(22)),
                    const SizedBox(height: 2),
                    Text('Trouvez la voiture idéale', style: AppText.body(13, color: context.p.muted)),
                  ],
                ),
              ),
              _Avatar(verified: app.isVerified, onTap: () => MainShell.of(context).goToTab(3)),
            ],
          ),
          if (!app.documentsComplete) ...[
            const SizedBox(height: 16),
            VerificationReminder(
              missing: app.missingDocumentsLabel,
              onResume: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VerifyCinScreen()),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const _SearchBar(),
          const SizedBox(height: 16),
          // Filter chips — horizontally scrollable, bleeding to the screen edges.
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: kFilterChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final chip = kFilterChips[i];
                final selected = app.chip == chip;
                return GestureDetector(
                  onTap: () => app.setChip(chip),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? context.p.accent : context.p.chipBg,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      chipFr(chip),
                      style:
                          AppText.body(12.5, weight: FontWeight.w600,
                              color: selected ? context.p.onAccent : context.p.muted),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          // Two lines, not one. At 360px the heading (176px) and the longest
          // sort label ("Trier · Les plus populaires", 171px) need 355px
          // against the 316px available — no amount of flexing fits them side
          // by side, and squeezing either one just moves the ellipsis around.
          Text('Voitures disponibles', style: AppText.heading(17)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => showSortSheet(context),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Trier · ${app.sort.label}',
                        style: AppText.body(12.5, weight: FontWeight.w600, color: context.p.accent)),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: context.p.accent),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (cars.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text('Aucune voiture ne correspond à ce filtre.',
                  textAlign: TextAlign.center,
                  style: AppText.body(13, weight: FontWeight.w500, color: context.p.mutedLight)),
            ),
        ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            sliver: SliverList.separated(
              itemCount: cars.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final car = cars[i];
                return CarCard(
                  car: car,
                  isFav: app.isFav(car.id),
                  onToggleFav: () {
                    final wasFav = app.isFav(car.id);
                    app.toggleFav(car.id);
                    showAppToast(
                      context,
                      wasFav ? 'Retiré des favoris' : 'Ajouté aux favoris',
                      onUndo: () => app.toggleFav(car.id),
                    );
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
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.verified, required this.onTap});

  final bool verified;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: context.p.chipBg, shape: BoxShape.circle),
                child: photoImage(AppScope.of(context).profilePhoto) ??
                    Icon(Icons.person_outline_rounded, size: 22, color: context.p.mutedLight),
              ),
              if (verified)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: context.p.green,
                      shape: BoxShape.circle,
                      // Matches the page, not always white — a white ring on a
                      // dark background is the light theme leaking through.
                      border: Border.all(color: context.p.page, width: 2),
                    ),
                    child: Icon(Icons.check_rounded, size: 9, color: context.p.page),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) => Container(
        height: 52,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(color: context.p.searchBg, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18, color: context.p.mutedLight),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                style: AppText.body(13.5, weight: FontWeight.w500),
                cursorColor: context.p.navy,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Rechercher par modèle, marque ou lieu',
                  hintStyle: AppText.body(13.5, weight: FontWeight.w500, color: context.p.mutedLight),
                ),
              ),
            ),
          ],
        ),
      );
}
