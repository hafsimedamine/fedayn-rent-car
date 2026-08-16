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
    final d = BookingDraft(car: carById('c_duster')) // 450 MAD/day
      ..pickDay = 20
      ..retDay = 24;

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
    final d = BookingDraft(car: carById('c_duster'))
      ..pickDay = 15
      ..retDay = 18; // spans booked days 16, 17
    expect(d.hasDateConflict, isTrue);

    d
      ..pickDay = 20
      ..retDay = 24;
    expect(d.hasDateConflict, isFalse);
  });

  test('prices group in French style', () {
    expect(fmtMad(250), '250');
    expect(fmtMad(1850), '1 850');
  });
}
