// Le document PDF lui-même : il se génère, il est valide, et les valeurs y
// arrivent réellement.
//
// La vérification du texte se fait en injectant les Helvetica intégrées, qui
// écrivent en clair dans le flux. En production le contrat embarque Inter — les
// Helvetica n'ont aucun support Unicode et perdraient les accents comme le
// tiret cadratin — mais alors le texte est écrit en identifiants de glyphes et
// n'est plus relisible sans décoder les tables ToUnicode. On teste donc ici ce
// que ce chemin peut prouver : les valeurs purement ASCII. Le reste du contenu
// est couvert ligne à ligne par contrat_test.dart.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:fedayns_rent_car/data/contrat_pdf.dart';
import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/data/models.dart';

/// Texte en clair des flux de contenu, décompressés.
String texteDuPdf(Uint8List octets) {
  final morceaux = <String>[];

  void extraire(String contenu) {
    for (final m in RegExp(r'\(((?:[^()\\]|\\.)*)\)\s*Tj').allMatches(contenu)) {
      morceaux.add(m.group(1)!);
    }
    for (final m in RegExp(r'\[(.*?)\]\s*TJ', dotAll: true).allMatches(contenu)) {
      for (final s in RegExp(r'\(((?:[^()\\]|\\.)*)\)').allMatches(m.group(1)!)) {
        morceaux.add(s.group(1)!);
      }
    }
  }

  final brut = latin1.decode(octets, allowInvalid: true);
  for (final m in RegExp(r'stream\r?\n').allMatches(brut)) {
    final fin = brut.indexOf('endstream', m.end);
    if (fin == -1) continue;
    try {
      extraire(latin1.decode(ZLibDecoder().convert(octets.sublist(m.end, fin)), allowInvalid: true));
    } on Object {
      continue; // flux non compressé ou non textuel
    }
  }
  extraire(brut);

  return morceaux.join(' ').replaceAll(r'\(', '(').replaceAll(r'\)', ')');
}

Booking reservation({String ref = 'RC4821', String carId = 'c_duster'}) {
  final debut = DateTime(2030, 7, 20);
  return Booking(
    ref: ref,
    carId: carId,
    startDate: debut,
    endDate: debut.add(const Duration(days: 4)),
    totalPrice: 1850,
    pickLoc: 'Casablanca — Maarif',
    retLoc: 'Casablanca — Maarif',
    pickTime: '10:00',
    retTime: '18:00',
  );
}

const client = ClientContrat(
  prenom: 'Mohamed',
  nom: 'Moncef',
  telephone: '0655555555',
  cin: 'TU 123456',
  permis: '19/123456',
);

void main() {
  setUpAll(() {
    // Le générateur charge Inter depuis les assets par défaut.
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('le document est un PDF valide et non trivial', () async {
    final pdf = await genererContratPdf(booking: reservation(), client: client);

    expect(latin1.decode(pdf.sublist(0, 5)), '%PDF-');
    expect(latin1.decode(pdf.sublist(pdf.length - 6)), contains('EOF'));
    expect(pdf.length, greaterThan(10000), reason: 'une police embarquée pèse à elle seule plusieurs kilo-octets');
  });

  test('la police est embarquée, sans quoi les accents disparaîtraient', () async {
    final pdf = await genererContratPdf(booking: reservation(), client: client);
    final brut = latin1.decode(pdf, allowInvalid: true);

    expect(brut, contains('FontFile2'), reason: 'aucune police TrueType embarquée');
    expect(brut, contains('Inter'));
  });

  test('les métadonnées portent le nom de l\'application', () async {
    final pdf = await genererContratPdf(booking: reservation(), client: client);
    final texte = texteDuPdf(pdf) + latin1.decode(pdf, allowInvalid: true);
    expect(texte, contains('Fedayn'), reason: 'titre ou auteur du document');
  });

  group('valeurs réellement présentes dans le flux (polices Helvetica)', () {
    late String texte;

    setUpAll(() async {
      final pdf = await genererContratPdf(
        booking: reservation(),
        client: client,
        police: pw.Font.helvetica(),
        policeGrasse: pw.Font.helveticaBold(),
        emisLe: DateTime(2030, 7, 15),
      );
      texte = texteDuPdf(pdf);
    });

    test('la référence du contrat', () => expect(texte, contains('RC4821')));

    test('le téléphone, la CIN et le permis du client', () {
      expect(texte, contains('0655555555'));
      expect(texte, contains('TU 123456'));
      expect(texte, contains('19/123456'));
    });

    test('le téléphone de l\'agence', () {
      expect(texte, contains(kAgencies['maarif']!.tel));
    });

    test('l\'immatriculation du véhicule', () {
      expect(texte, contains(kSpecs['c_duster']!.plate));
    });

    test('les heures de prise en charge et de retour', () {
      expect(texte, contains('10:00'));
      expect(texte, contains('18:00'));
    });

    test('la marque, y compris en deux mots', () async {
      final pdf = await genererContratPdf(
        booking: reservation(carId: 'c_evoque'),
        client: client,
        police: pw.Font.helvetica(),
        policeGrasse: pw.Font.helveticaBold(),
      );
      expect(texteDuPdf(pdf), contains('Range Rover'));
    });
  });

  test('le contrat tient sur une seule page', () async {
    // Une page de plus pour deux cases de signature donnait un second feuillet
    // vide aux trois quarts. Le compteur d'objets /Page le vérifie sans
    // dépendre d'un moteur de rendu.
    final pdf = await genererContratPdf(booking: reservation(), client: client);
    final brut = latin1.decode(pdf, allowInvalid: true);
    final pages = RegExp(r'/Type\s*/Page[^s]').allMatches(brut).length;
    expect(pages, 1, reason: 'le contrat déborde sur $pages pages');
  });

  test('même le libellé de période le plus long tient sur une page', () async {
    // Une période à cheval sur deux mois écrit les deux noms de mois.
    final aCheval = Booking(
      ref: 'RC9999',
      carId: 'c_evoque',
      startDate: DateTime(2030, 7, 28),
      endDate: DateTime(2030, 9, 3),
      totalPrice: 45000,
      pickLoc: 'Casablanca — Aéroport Mohammed V',
      retLoc: 'Rabat — Agdal',
      pickTime: '08:00',
      retTime: '23:00',
    );
    final pdf = await genererContratPdf(booking: aCheval, client: client);
    final brut = latin1.decode(pdf, allowInvalid: true);
    expect(RegExp(r'/Type\s*/Page[^s]').allMatches(brut).length, 1);
  });

  test('chaque voiture de la flotte produit un contrat', () async {
    for (final car in kCars) {
      final pdf = await genererContratPdf(booking: reservation(carId: car.id), client: client);
      expect(pdf.length, greaterThan(10000), reason: '${car.name} : contrat vide ou tronqué');
    }
  });

  test('un client incomplet produit tout de même un contrat', () async {
    final pdf = await genererContratPdf(
      booking: reservation(),
      client: const ClientContrat(prenom: '', nom: '', telephone: '', cin: '', permis: ''),
    );
    expect(latin1.decode(pdf.sublist(0, 5)), '%PDF-');
  });
}
