// Consultation et partage du contrat de location.
//
// L'aperçu vient de `printing`, qui apporte aussi l'impression et le partage
// natifs. La génération, elle, reste dans `data/contrat_pdf.dart` : elle ne
// dépend d'aucun canal de plateforme et se teste sans écran.

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data/calendar.dart';
import '../data/contrat_pdf.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ContratScreen extends StatelessWidget {
  const ContratScreen({super.key, required this.booking});

  final Booking booking;

  String get _nomFichier => 'contrat-${booking.ref}.pdf';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final client = app.clientContrat;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TopBar(title: 'Contrat de location', onBack: () => Navigator.of(context).maybePop()),
            if (!client.estComplet) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
                child: _AvisIncomplet(),
              ),
            ],
            Expanded(
              child: PdfPreview(
                build: (format) => genererContratPdf(booking: booking, client: client),
                pdfFileName: _nomFichier,
                canDebug: false,
                canChangeOrientation: false,
                canChangePageFormat: false,
                // Le partage et l'impression restent : ce sont les deux
                // façons de sortir le contrat de l'application.
                allowSharing: true,
                allowPrinting: true,
                loadingWidget: const Center(child: CircularProgressIndicator()),
                onError: (context, error) => _Erreur(message: '$error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Le contrat se génère même sans CIN ni permis, mais il le dit : imprimer un
/// contrat dont l'identité du locataire est vide serait pire que le refuser.
class _AvisIncomplet extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.p.amberSurface,
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: context.p.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Certaines informations manquent au contrat. Complétez votre CIN '
                'et votre permis depuis Compte › Mes documents.',
                style: AppText.body(12, color: context.p.infoText, height: 1.45),
              ),
            ),
          ],
        ),
      );
}

class _Erreur extends StatelessWidget {
  const _Erreur({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf_outlined, size: 48, color: context.p.grayDot),
              const SizedBox(height: 14),
              Text('Le contrat n\'a pas pu être généré',
                  style: AppText.heading(17), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(message,
                  style: AppText.body(12, color: context.p.muted, height: 1.5),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

/// Ouvre le contrat d'une réservation.
void ouvrirContrat(BuildContext context, Booking booking) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContratScreen(booking: booking)));
}

/// Libellé du bouton, avec la période pour situer le contrat.
String libelleContrat(Booking booking) =>
    'Contrat de location · ${formatPeriode(booking.startDate, booking.endDate)}';
