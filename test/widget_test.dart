// Smoke tests: the app boots to Welcome, and the booking price/gating maths
// (the parts most likely to regress silently) behave as designed.

import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/main.dart';
import 'package:fedayns_rent_car/state/app_state.dart';

void main() {
  testWidgets('boots to the welcome screen', (tester) async {
    await tester.pumpWidget(FedaynsApp(state: AppState()));
    await tester.pump();

    expect(find.text("Fedayn's Rent Car"), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  test('booking total = days x rate + extras + fee - promo', () {
    final base = DateTime(2030, 6, 20);
    final d = BookingDraft(car: carById('c_duster')) // 450 MAD/jour
      ..pickDate = base
      ..retDate = base.add(const Duration(days: 4));

    expect(d.days, 4);
    expect(d.base, 1800);
    expect(d.total, 1850); // + 50 service fee

    d.extraChildSeat = true;
    expect(d.total, 1890); // + 40

    d.promoApplied = true;
    expect(d.discount, 360); // 20% of base
    expect(d.total, 1530);
  });

  test('additional driver gates the continue action until complete', () {
    final d = BookingDraft(car: carById('c_duster'));
    expect(d.canProceed, isTrue); // option off

    d.extraDriver = true;
    expect(d.canProceed, isFalse);

    d
      ..adName = 'Second Driver'
      ..adCin = 'TU 654321'
      ..adLicense = '19/654321';
    expect(d.canProceed, isFalse); // expiry still empty

    d.adExpiry = '15/06/2035';
    expect(d.canProceed, isTrue);
  });

  test('overlapping an already-booked day is a conflict', () {
    // Les jours pris viennent maintenant de l'état réel de la voiture et sont
    // fournis au brouillon, plus d'une constante figée sur juillet 2026.
    final pris = {DateTime(2030, 6, 16), DateTime(2030, 6, 17)};
    final d = BookingDraft(car: carById('c_duster'), indisponibles: pris)
      ..pickDate = DateTime(2030, 6, 15)
      ..retDate = DateTime(2030, 6, 18);
    expect(d.hasDateConflict, isTrue);

    d
      ..pickDate = DateTime(2030, 6, 20)
      ..retDate = DateTime(2030, 6, 24);
    expect(d.hasDateConflict, isFalse);
  });

  test('le jour du retour peut être un jour repris par quelqu\'un d\'autre', () {
    // On rend la voiture le matin : elle peut repartir le jour même.
    final d = BookingDraft(
      car: carById('c_duster'),
      indisponibles: {DateTime(2030, 6, 18)},
    )
      ..pickDate = DateTime(2030, 6, 15)
      ..retDate = DateTime(2030, 6, 18);
    expect(d.hasDateConflict, isFalse);
  });

  test('prices group in French style', () {
    expect(fmtMad(250), '250');
    expect(fmtMad(1850), '1 850');
  });
}
