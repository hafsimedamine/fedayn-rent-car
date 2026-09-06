// Le contrat doit être atteignable depuis le détail de la réservation, et
// rempli avec les informations réelles du compte.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/contrat.dart';
import 'package:fedayns_rent_car/data/db/account.dart';
import 'package:fedayns_rent_car/screens/booking_details.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/common.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('le détail d\'une réservation propose le contrat', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(AppScope(
      state: AppState(),
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: buildAppTheme(Brightness.light),
        home: BookingDetailsScreen(booking: reservationDeTest()),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Voir le contrat de location'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Voir le contrat de location'), findsOneWidget);
  });

  group('le locataire est repris du compte', () {
    test('nom complet séparé en prénom puis nom', () {
      final app = AppState();
      app.signedInAs(const Account(
        id: 1,
        fullName: 'Mohamed Moncef',
        email: 'moncef@gmail.com',
        phone: '0655555555',
      ));

      final c = app.clientContrat;
      expect(c.prenom, 'Mohamed');
      expect(c.nom, 'Moncef');
      expect(c.telephone, '0655555555');
    });

    test('un nom en trois mots garde le prénom en tête', () {
      final app = AppState();
      app.signedInAs(const Account(
        id: 1,
        fullName: 'Amine Ben Tazi',
        email: 'a@b.ma',
        phone: '0612345678',
      ));
      expect(app.clientContrat.prenom, 'Amine');
      expect(app.clientContrat.nom, 'Ben Tazi');
    });

    test('les numéros saisis à la vérification arrivent au contrat', () {
      final app = AppState()
        ..markCinUploaded(numero: 'TU 654321')
        ..markLicenseUploaded(numero: '19/998877');

      expect(app.clientContrat.cin, 'TU 654321');
      expect(app.clientContrat.permis, '19/998877');
      expect(app.clientContrat.estComplet, isTrue);
    });

    test('sans vérification, le contrat le signale', () {
      final app = AppState();
      expect(app.clientContrat.cin, isEmpty);
      expect(app.clientContrat.cinAffiche, ClientContrat.absent);
      expect(app.clientContrat.estComplet, isFalse);
    });

    test('retirer un document retire son numéro', () {
      final app = AppState()..markCinUploaded(numero: 'TU 654321');
      expect(app.clientContrat.cin, 'TU 654321');

      app.clearCin();
      expect(app.clientContrat.cin, isEmpty);
    });

    test('la déconnexion efface les numéros', () {
      final app = AppState()
        ..markCinUploaded(numero: 'TU 654321')
        ..markLicenseUploaded(numero: '19/998877');

      app.logOut();
      expect(app.clientContrat.cin, isEmpty);
      expect(app.clientContrat.permis, isEmpty,
          reason: 'le locataire suivant ne doit pas hériter du permis du précédent');
    });
  });
}
