// L'écran de choix des dates : navigation, dates passées, jours pris.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/calendar.dart';
import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/data/models.dart';
import 'package:fedayns_rent_car/screens/booking/book_dates.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<AppState> pump(WidgetTester tester, {String car = 'c_duster'}) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = AppState()..startBooking(carById(car));
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(theme: buildAppTheme(Brightness.light), home: const BookDatesScreen()),
    ));
    await tester.pumpAndSettle();
    return state;
  }

  String titreMois(int decalage) {
    final m = moisDecale(aujourdHui, decalage);
    final nom = kMoisFr[m.month - 1];
    return '${nom[0].toUpperCase()}${nom.substring(1)} ${m.year}';
  }

  testWidgets('s\'ouvre sur le mois courant, pas sur juillet 2026', (tester) async {
    await pump(tester);
    expect(find.text(titreMois(0)), findsOneWidget);
    expect(find.text('Juillet 2026'), findsNothing, reason: 'le mois figé du prototype');
  });

  testWidgets('le mois suivant est atteignable', (tester) async {
    await pump(tester);
    await tester.tap(find.bySemanticsLabel('Mois suivant'));
    await tester.pumpAndSettle();
    expect(find.text(titreMois(1)), findsOneWidget);
  });

  testWidgets('on peut parcourir douze mois puis plus', (tester) async {
    await pump(tester);
    for (var i = 1; i <= 11; i++) {
      await tester.tap(find.bySemanticsLabel('Mois suivant'));
      await tester.pumpAndSettle();
    }
    expect(find.text(titreMois(11)), findsOneWidget);

    // Au-delà d'un an, la flèche ne fait plus rien.
    await tester.tap(find.bySemanticsLabel('Mois suivant'));
    await tester.pumpAndSettle();
    expect(find.text(titreMois(11)), findsOneWidget, reason: 'borné à un an');
  });

  testWidgets('on ne remonte pas avant le mois courant', (tester) async {
    await pump(tester);
    await tester.tap(find.bySemanticsLabel('Mois précédent'));
    await tester.pumpAndSettle();
    expect(find.text(titreMois(0)), findsOneWidget, reason: 'le passé n\'est pas réservable');
  });

  testWidgets('un jour passé n\'est pas sélectionnable', (tester) async {
    // On ne teste que si le mois courant a déjà des jours écoulés.
    final today = aujourdHui;
    if (today.day < 2) return;

    final state = await pump(tester);
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    expect(state.draft.pickDate, isNull, reason: 'le 1er est passé, il ne doit rien déclencher');
  });

  testWidgets('choisir deux jours fixe la période', (tester) async {
    final state = await pump(tester);
    final today = aujourdHui;
    final dernier = joursDansLeMois(today.year, today.month);
    // Deux jours à venir dans le mois courant, sinon on passe au suivant.
    if (today.day + 3 > dernier) {
      await tester.tap(find.bySemanticsLabel('Mois suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('14').first);
    } else {
      await tester.tap(find.text('${today.day + 1}').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('${today.day + 3}').first);
    }
    await tester.pumpAndSettle();

    expect(state.draft.pickDate, isNotNull);
    expect(state.draft.retDate, isNotNull);
    expect(state.draft.days, greaterThan(0));
  });

  test('une voiture disponible n\'a aucun jour bloqué', () {
    final app = AppState();
    final dispo = kCars.firstWhere((c) => c.avail == Availability.now);
    expect(app.joursIndisponibles(dispo), isEmpty);
  });

  test('une voiture louée est bloquée jusqu\'à son retour', () {
    final app = AppState();
    final louee = kCars.where((c) => c.avail != Availability.now && c.availDate != null);
    for (final car in louee) {
      final jours = app.joursIndisponibles(car);
      expect(jours, isNotEmpty, reason: '${car.name} est ${car.avail.name} mais rien n\'est bloqué');
      expect(jours, contains(aujourdHui), reason: '${car.name} devrait être bloquée aujourd\'hui');
    }
  });
}
