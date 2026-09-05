// Full booking detail, opened from a rentals card.

import 'package:flutter/material.dart';

import '../data/fleet.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/car_card.dart';
import '../widgets/common.dart';
import 'modals.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final car = carByName(booking.name);
    final agency = kAgencies.values.firstWhere(
      (a) => booking.loc.contains(a.name.split(' - ').last),
      orElse: () => kAgencies['maarif']!,
    );
    final isActive = booking.kind == BookingKind.active;
    final isPast = booking.kind == BookingKind.past;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TopBar(title: 'Détails', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                children: [
                  Row(
                    children: [
                      CarThumb(car: car, width: 96, height: 72),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(booking.name, style: AppText.heading(18)),
                            const SizedBox(height: 3),
                            Text(catFr(booking.cat), style: AppText.body(12.5, color: context.p.mutedLight)),
                            const SizedBox(height: 6),
                            Text('#${booking.ref}', style: AppText.body(12, weight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const SectionLabel('TRAJET'),
                  const SizedBox(height: 10),
                  _Card(children: [
                    _row(context, 'Période', booking.range),
                    _row(context, 'Durée', booking.days),
                    _row(context, 'Heure de départ', booking.pickTime),
                    _row(context, 'Heure de retour', booking.retTime),
                    _row(context, 'Prise en charge', booking.pickLoc),
                    _row(context, 'Retour', booking.retLoc, last: true),
                  ]),
                  const SizedBox(height: 20),
                  const SectionLabel('INCLUS'),
                  const SizedBox(height: 10),
                  for (final item in kIncluded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 17, color: context.p.green),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item, style: AppText.body(13, color: context.p.infoText))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  const SectionLabel('MONTANT'),
                  const SizedBox(height: 10),
                  _Card(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total', style: AppText.body(13, weight: FontWeight.w600)),
                          Text(booking.total,
                              style: AppText.heading(20, color: context.p.accent, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  const SectionLabel('CODE DE PRISE EN CHARGE'),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        color: context.p.field,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: context.p.border),
                      ),
                      child: Icon(Icons.qr_code_2_rounded, size: 92, color: context.p.navy),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text('Présentez ce code à l\'agence',
                        style: AppText.body(12, color: context.p.mutedLight)),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('AGENCE'),
                  const SizedBox(height: 10),
                  _Card(children: [
                    _row(context, 'Adresse', agency.short),
                    _row(context, 'Téléphone', agency.tel),
                    _row(context, 'Horaires', agency.hours, last: true),
                  ]),
                ],
              ),
            ),
            StickyBar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isActive) ...[
                    PrimaryButton(label: 'Localiser la voiture', onPressed: () => showAppToast(context, 'Localisation…')),
                    const SizedBox(height: 10),
                    SecondaryButton(
                      label: 'Prolonger la location',
                      height: 54,
                      onPressed: () => showAppToast(context, 'Prolongation demandée'),
                    ),
                  ] else if (isPast) ...[
                    PrimaryButton(label: 'Réserver à nouveau', onPressed: () => Navigator.of(context).maybePop()),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: "Contacter l'agence",
                            height: 54,
                            onPressed: () => showAppToast(context, agency.tel),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SecondaryButton(
                            label: 'Itinéraire',
                            height: 54,
                            onPressed: () => showAppToast(context, "Ouverture de l'itinéraire"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SecondaryButton(
                      label: 'Annuler la réservation',
                      danger: true,
                      height: 54,
                      // Once it is cancelled there is nothing left to show on
                      // this screen, so hand the user back to the list.
                      onPressed: () async {
                        if (await showCancelBookingSheet(context, booking.ref) && context.mounted) {
                          Navigator.of(context).maybePop();
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _row(BuildContext context, String label, String value, {bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: context.p.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: AppText.body(12.5, weight: FontWeight.w500, color: context.p.muted))),
            Expanded(
              flex: 2,
              child: Text(value, textAlign: TextAlign.end, style: AppText.body(12.5, weight: FontWeight.w600)),
            ),
          ],
        ),
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: context.p.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.p.cardBorder),
        ),
        child: Column(children: children),
      );
}
