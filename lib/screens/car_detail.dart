// Car detail — gallery, key specs, vehicle info, equipment, included, agency,
// with a sticky price + book bar.

import 'package:flutter/material.dart';

import '../data/fleet.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/car_card.dart';
import '../widgets/common.dart';
import 'booking/book_dates.dart';
import 'modals.dart';
import 'verify_cin.dart';

class CarDetailScreen extends StatelessWidget {
  const CarDetailScreen({super.key, required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final spec = kSpecs[car.id];
    final agency = kAgencies['maarif']!;
    final (dot, availLabel) = CarCard.availability(context, car);
    final bookable = car.avail != Availability.rented;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Hero gallery with back + heart floating over it.
                SliverAppBar(
                  expandedHeight: 260,
                  pinned: true,
                  backgroundColor: context.p.page,
                  surfaceTintColor: Colors.transparent,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: BackChevron(onTap: () => Navigator.of(context).maybePop()),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: HeartButton(
                        isFav: app.isFav(car.id),
                        onTap: () {
                          final wasFav = app.isFav(car.id);
                          app.toggleFav(car.id);
                          showAppToast(context, wasFav ? 'Retiré des favoris' : 'Ajouté aux favoris');
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _Gallery(car: car),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                  sliver: SliverList.list(children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(car.name, style: AppText.heading(24)),
                              const SizedBox(height: 4),
                              Text('${catFr(car.cat)} • ${transFr(car.trans)}',
                                  style: AppText.body(13, weight: FontWeight.w500, color: context.p.mutedLight)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 15, color: Color(0xFFE1B23B)),
                                const SizedBox(width: 4),
                                Text(car.rating, style: AppText.body(13, weight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('${car.reviews} avis', style: AppText.body(11.5, color: context.p.mutedLight)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AvailabilityDot(color: dot, label: availLabel),
                    const SizedBox(height: 20),
                    // Key specs strip
                    Row(
                      children: [
                        _SpecTile(icon: Icons.event_seat_outlined, label: 'Places', value: '${car.seats}'),
                        _SpecTile(icon: Icons.settings_outlined, label: 'Boîte', value: transFr(car.trans)),
                        _SpecTile(
                          icon: car.isElectric ? Icons.bolt_outlined : Icons.local_gas_station_outlined,
                          label: 'Énergie',
                          value: fuelFr(car.fuel),
                        ),
                        if (spec != null) _SpecTile(icon: Icons.sensor_door_outlined, label: 'Portes', value: '${spec.doors}'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('À propos', style: AppText.heading(17)),
                    const SizedBox(height: 8),
                    Text(
                      _about(car),
                      style: AppText.body(13.5, color: context.p.muted, height: 1.6),
                    ),
                    if (spec != null) ...[
                      const SizedBox(height: 24),
                      const SectionLabel('INFORMATIONS DU VÉHICULE'),
                      const SizedBox(height: 10),
                      _InfoTable(rows: [
                        ('Mise en circulation', spec.reg),
                        ('Kilométrage', '${spec.km} km'),
                        ('Immatriculation', spec.plate),
                        ('Couleur', spec.color),
                        if (spec.range != null) ('Autonomie', spec.range!),
                        if (spec.battery != null) ('Batterie', spec.battery!),
                        if (spec.tank != null) ('Réservoir', spec.tank!),
                      ]),
                    ],
                    const SizedBox(height: 24),
                    const SectionLabel('ÉQUIPEMENTS'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in kEquipment)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: context.p.field,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(color: context.p.border),
                            ),
                            child: Text(e, style: AppText.body(12, weight: FontWeight.w500, color: context.p.infoText)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Inclus dans la location', style: AppText.heading(17)),
                    const SizedBox(height: 10),
                    for (final item in kIncluded)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 17, color: AppColors.green),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item, style: AppText.body(13, color: context.p.infoText))),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    const SectionLabel('AGENCE DE PRISE EN CHARGE'),
                    const SizedBox(height: 10),
                    _AgencyCard(agency: agency),
                  ]),
                ),
              ],
            ),
          ),
          // Sticky price + CTA
          StickyBar(
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${fmtMad(car.price)} MAD',
                            style: AppText.heading(22, color: AppColors.accent, weight: FontWeight.w700)),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text('/jour', style: AppText.body(12, weight: FontWeight.w500, color: context.p.mutedLight)),
                        ),
                      ],
                    ),
                    Text('Assurance incluse', style: AppText.body(11.5, color: context.p.mutedLight)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaryButton(
                    label: bookable ? 'Réserver' : 'Indisponible',
                    enabled: bookable,
                    onPressed: () => _book(context, app),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _book(BuildContext context, AppState app) {
    // Renting needs both documents and an approved review; either gap stops
    // the flow here rather than part-way through checkout.
    if (!app.canRent) {
      showVerifyRequiredSheet(
        context,
        missing: app.documentsComplete ? null : app.missingDocumentsLabel,
        onVerify: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VerifyCinScreen())),
      );
      return;
    }
    app.startBooking(car);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookDatesScreen()));
  }

  static String _about(Car car) {
    if (car.isElectric) {
      return "Véhicule 100 % électrique, silencieux et économique — idéal pour la ville et les trajets quotidiens. "
          'Recharge rapide disponible dans nos agences.';
    }
    if (car.cat.contains('SUV')) {
      return 'Un SUV fiable et sobre — idéal pour les voyages en famille et les longues routes à travers le Maroc. '
          'Coffre spacieux et position de conduite surélevée.';
    }
    if (car.cat == 'Luxury') {
      return 'Finition haut de gamme, confort de conduite et équipements premium — pour vos déplacements '
          "professionnels ou vos occasions spéciales.";
    }
    return 'Compacte, maniable et économique — parfaite pour circuler en ville et se garer facilement. '
        'Faible consommation et entretien récent.';
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) => PageView.builder(
        itemCount: 4,
        itemBuilder: (_, __) => Stack(
          fit: StackFit.expand,
          children: [
            CarPlaceholder(name: car.name),
            Image.asset(car.photoAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ],
        ),
      );
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(color: context.p.field, borderRadius: BorderRadius.circular(AppRadius.small)),
          child: Column(
            children: [
              Icon(icon, size: 18, color: context.p.muted),
              const SizedBox(height: 6),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(12, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(label, style: AppText.body(10, color: context.p.mutedLight)),
            ],
          ),
        ),
      );
}

class _InfoTable extends StatelessWidget {
  const _InfoTable({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.p.cardBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  border: i < rows.length - 1
                      ? Border(bottom: BorderSide(color: context.p.divider))
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(rows[i].$1, style: AppText.body(12.5, weight: FontWeight.w500, color: context.p.muted))),
                    Text(rows[i].$2, style: AppText.body(12.5, weight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      );
}

class _AgencyCard extends StatelessWidget {
  const _AgencyCard({required this.agency});

  final Agency agency;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.p.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: context.p.field, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.location_on_outlined, size: 19, color: context.p.muted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(agency.name, style: AppText.body(13.5, weight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(agency.addr, style: AppText.body(11.5, color: context.p.muted, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(agency.hours, style: AppText.body(11.5, color: context.p.mutedLight)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Appeler',
                    height: 42,
                    onPressed: () => showAppToast(context, agency.tel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SecondaryButton(
                    label: 'Itinéraire',
                    height: 42,
                    onPressed: () => showAppToast(context, 'Ouverture de l\'itinéraire'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
