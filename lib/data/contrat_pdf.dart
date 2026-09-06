// Contrat de location en PDF.
//
// Fonction pure : elle ne dépend que du paquet `pdf`, jamais de `printing`.
// L'aperçu et le partage passent par un canal de plateforme, indisponible sous
// `flutter test` ; en gardant la génération à part, le contrat lui-même reste
// entièrement vérifiable.

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'calendar.dart';
import 'contrat.dart';
import 'fleet.dart';
import 'models.dart';

export 'contrat.dart' show ClientContrat, ContratContenu, SectionContrat, construireContrat;

/// Couleurs du document. Reprises de la palette, mais figées ici : un contrat
/// imprimé ne suit pas le mode sombre de l'application.
const _encre = PdfColor.fromInt(0xFF1B1C3A);
const _accent = PdfColor.fromInt(0xFFA8501B);
const _gris = PdfColor.fromInt(0xFF5F6275);
const _trait = PdfColor.fromInt(0xFFE3DDD4);
const _fondDoux = PdfColor.fromInt(0xFFFBF8F4);

/// Construit le contrat et renvoie le PDF.
///
/// Les polices sont chargées depuis les assets si elles ne sont pas fournies.
/// Ce n'est pas un détail d'esthétique : les Helvetica intégrées au paquet
/// n'ont aucun support Unicode et laissent tomber sans bruit le tiret cadratin
/// de « Conducteur supplémentaire — gratuit » comme de « Casablanca — Maarif ».
Future<Uint8List> genererContratPdf({
  required Booking booking,
  required ClientContrat client,
  pw.Font? police,
  pw.Font? policeGrasse,
  DateTime? emisLe,
}) async {
  final contrat = construireContrat(booking: booking, client: client, emisLe: emisLe);

  final theme = pw.ThemeData.withFont(
    base: police ?? await _inter('assets/fonts/Inter-400.ttf'),
    bold: policeGrasse ?? await _inter('assets/fonts/Inter-600.ttf'),
  );

  final doc = pw.Document(
    title: 'Contrat de location $kBrand — ${contrat.reference}',
    author: kBrand,
    subject: 'Contrat de location de véhicule',
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      margin: const pw.EdgeInsets.fromLTRB(38, 24, 38, 22),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 12),
        child: pw.Text(
          'Page ${context.pageNumber} sur ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: _gris),
        ),
      ),
      build: (context) => [
        _enTete(contrat),
        pw.SizedBox(height: 12),
        for (final section in contrat.sections) ...[
          _section(section),
          pw.SizedBox(height: 9),
        ],
        _montant(contrat),
        pw.SizedBox(height: 9),
        _inclus(contrat),
        pw.SizedBox(height: 8),
        _signatures(contrat.agence),
      ],
    ),
  );

  return doc.save();
}

/// Inter, la police de l'application, en version embarquable dans le PDF.
Future<pw.Font> _inter(String asset) async => pw.Font.ttf(await rootBundle.load(asset));

pw.Widget _enTete(ContratContenu contrat) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(kBrand,
                      style: const pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold, color: _encre)),
                  pw.SizedBox(height: 6),
                  pw.Text(contrat.agence.name, style: const pw.TextStyle(fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
                  pw.Text(contrat.agence.addr, style: const pw.TextStyle(fontSize: 9.5, color: _gris)),
                  // Téléphone et e-mail sur une ligne : l'en-tête était le
                  // bloc le plus dépensier, et il poussait la signature sur
                  // une seconde page aux trois quarts vide.
                  pw.Text('Tél. : ${contrat.agence.tel} · ${contrat.agence.email}',
                      style: const pw.TextStyle(fontSize: 9.5, color: _gris)),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: pw.BoxDecoration(
                color: _fondDoux,
                border: pw.Border.all(color: _trait),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('CONTRAT DE LOCATION',
                      style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _accent)),
                  pw.SizedBox(height: 4),
                  pw.Text('N° ${contrat.reference}',
                      style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text('Établi le ${formatComplet(contrat.emisLe)}',
                      style: const pw.TextStyle(fontSize: 8.5, color: _gris)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: _trait, thickness: 1),
      ],
    );

pw.Widget _section(SectionContrat section) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(section.titre.toUpperCase(),
            style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _accent, letterSpacing: 0.8)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.symmetric(inside: const pw.BorderSide(color: _trait)),
          columnWidths: const {0: pw.FlexColumnWidth(2), 1: pw.FlexColumnWidth(3)},
          children: [
            for (final (libelle, valeur) in section.lignes)
              pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                  child: pw.Text(libelle, style: const pw.TextStyle(fontSize: 10, color: _gris)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 3.5, horizontal: 2),
                  child: pw.Text(valeur, style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ),
              ]),
          ],
        ),
      ],
    );

pw.Widget _montant(ContratContenu contrat) => pw.Container(
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(
        color: _fondDoux,
        border: pw.Border.all(color: _trait),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('MONTANT',
              style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _accent, letterSpacing: 0.8)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Tarif journalier × ${contrat.dureeAffichee}', style: const pw.TextStyle(fontSize: 10, color: _gris)),
              pw.Text(contrat.tarifAffiche, style: const pw.TextStyle(fontSize: 10, color: _gris)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: _trait, thickness: 0.7),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Total à régler', style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text(contrat.totalAffiche,
                  style: const pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold, color: _accent)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text('Toutes taxes comprises, frais de service inclus.',
              style: const pw.TextStyle(fontSize: 8.5, color: _gris)),
        ],
      ),
    );

/// Les inclus sur deux colonnes : en liste simple ils poussaient à eux seuls
/// la signature sur une seconde page, aux trois quarts vide.
pw.Widget _inclus(ContratContenu contrat) {
  final items = contrat.inclus;
  final coupe = (items.length / 2).ceil();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('INCLUS DANS LA LOCATION',
          style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _accent, letterSpacing: 0.8)),
      pw.SizedBox(height: 6),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _colonneInclus(items.take(coupe))),
          pw.SizedBox(width: 16),
          pw.Expanded(child: _colonneInclus(items.skip(coupe))),
        ],
      ),
    ],
  );
}

pw.Widget _colonneInclus(Iterable<String> items) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final item in items)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 3,
                  height: 3,
                  margin: const pw.EdgeInsets.only(top: 4, right: 6),
                  decoration: const pw.BoxDecoration(color: _accent, shape: pw.BoxShape.circle),
                ),
                pw.Expanded(child: pw.Text(item, style: const pw.TextStyle(fontSize: 9))),
              ],
            ),
          ),
      ],
    );

/// Enveloppé dans un Container : `pw.Column` sait se scinder entre deux pages,
/// et le bloc se coupait en deux en dupliquant les libellés « Signature du
/// locataire ». Un Container n'est pas sécable et migre d'un seul tenant.
pw.Widget _signatures(Agency agence) => pw.Container(
      child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Le locataire reconnaît avoir pris connaissance des conditions générales '
          'de location et accepte de restituer le véhicule dans son état initial, '
          'à la date et au lieu convenus.',
          style: const pw.TextStyle(fontSize: 8.5, color: _gris, lineSpacing: 2),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(child: _caseSignature('Signature du locataire')),
            pw.SizedBox(width: 24),
            pw.Expanded(child: _caseSignature('Pour ${agence.name}')),
          ],
        ),
      ],
    ),
    );

pw.Widget _caseSignature(String libelle) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(libelle, style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Précédée de la mention « Lu et approuvé »',
            style: const pw.TextStyle(fontSize: 7.5, color: _gris)),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 30,
          decoration: pw.BoxDecoration(border: pw.Border.all(color: _trait)),
        ),
      ],
    );
