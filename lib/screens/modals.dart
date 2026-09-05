// Cancel-booking and rate-rental modals, presented as bottom sheets.

import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Confirms cancelling [ref]. Resolves to true once the booking is actually
/// cancelled, so a caller showing the booking on its own screen can leave it.
Future<bool> showCancelBookingSheet(BuildContext context, String ref) async {
  final app = AppScope.read(context);
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetGrabber(),
          const SizedBox(height: 18),
          Text('Annuler cette réservation ?', style: AppText.heading(20)),
          const SizedBox(height: 10),
          Text(
            "L'annulation est gratuite jusqu'à 48 h avant la prise en charge. Passé ce délai, "
            'des frais équivalents à une journée de location peuvent s\'appliquer.',
            style: AppText.body(13.5, color: context.p.muted, height: 1.6),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: "Confirmer l'annulation",
            background: context.p.red,
            onPressed: () {
              Navigator.of(sheetContext).pop(true);
              app.cancelBooking(ref);
              showAppToast(context, 'Réservation $ref annulée');
            },
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Garder la réservation',
            height: 54,
            onPressed: () => Navigator.of(sheetContext).pop(false),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
}

Future<void> showRateRentalSheet(BuildContext context, String ref) {
  final app = AppScope.read(context);
  var stars = 0;
  final comment = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: StatefulBuilder(
        builder: (context2, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetGrabber(),
              const SizedBox(height: 18),
              Text('Noter cette location', style: AppText.heading(20)),
              const SizedBox(height: 6),
              Text('Réservation #$ref', style: AppText.body(13, color: context.p.muted)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    GestureDetector(
                      onTap: () => setSheetState(() => stars = i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i <= stars ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 38,
                          color: const Color(0xFFE1B23B),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: comment,
                maxLines: 3,
                style: AppText.body(14),
                cursorColor: context.p.navy,
                decoration: InputDecoration(
                  hintText: 'Partagez votre expérience (facultatif)',
                  hintStyle: AppText.body(14, color: context.p.mutedLight),
                  filled: true,
                  fillColor: context.p.field,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.field),
                    borderSide: BorderSide(color: context.p.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.field),
                    borderSide: BorderSide(color: context.p.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.field),
                    borderSide: BorderSide(color: context.p.navy, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: "Envoyer l'avis",
                enabled: stars > 0,
                onPressed: () {
                  app.submitReview(ref, stars);
                  Navigator.of(sheetContext).pop();
                  showAppToast(context, 'Avis envoyé — merci !');
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Blocking modal shown when an unverified user tries to book.
Future<void> showVerifyRequiredSheet(
  BuildContext context, {
  required VoidCallback onVerify,
  String? missing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetGrabber(),
          const SizedBox(height: 18),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: context.p.amberSurface, shape: BoxShape.circle),
            child: Icon(Icons.badge_outlined, size: 28, color: context.p.amber),
          ),
          const SizedBox(height: 18),
          Text('Complétez votre vérification', textAlign: TextAlign.center, style: AppText.heading(20)),
          const SizedBox(height: 10),
          Text(
            missing == null
                ? 'Nous devons valider votre CIN et votre permis de conduire avant votre première réservation.'
                : 'Envoyez $missing pour pouvoir réserver une voiture.',
            textAlign: TextAlign.center,
            style: AppText.body(13.5, color: sheetContext.p.muted, height: 1.6),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Vérifier maintenant',
            onPressed: () {
              Navigator.of(sheetContext).pop();
              onVerify();
            },
          ),
          const SizedBox(height: 10),
          SecondaryButton(label: 'Plus tard', height: 54, onPressed: () => Navigator.of(sheetContext).pop()),
        ],
      ),
    ),
  );
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(color: context.p.border, borderRadius: BorderRadius.circular(2)),
        ),
      );
}
