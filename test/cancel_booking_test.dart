// Cancelling has to actually take the card away — the toast said "annulée"
// while the booking sat there unchanged.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/screens/tabs/rentals_tab.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/common.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  test('cancelling records the ref and survives nothing else', () {
    final app = AppState();
    expect(app.isCancelled('RC2847'), isFalse);

    app.cancelBooking('RC2847');
    expect(app.isCancelled('RC2847'), isTrue);

    app.logOut();
    expect(app.isCancelled('RC2847'), isFalse, reason: 'the next user starts clean');
  });

  testWidgets('the cancelled card fades out and leaves the list', (tester) async {
    final app = AppState();
    final ref = kUpcoming.first.ref;

    await tester.pumpWidget(AppScope(
      state: app,
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: buildAppTheme(Brightness.light),
        home: const Scaffold(body: RentalsTab()),
      ),
    ));

    expect(find.text('#$ref'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Confirmer l'annulation"));
    await tester.pump();

    // Mid-animation the card is still mounted but already fading.
    await tester.pump(const Duration(milliseconds: 140));
    final opacity = tester.widget<FadeTransition>(
      find.ancestor(of: find.text('#$ref'), matching: find.byType(FadeTransition)).first,
    );
    expect(opacity.opacity.value, lessThan(1.0));
    expect(opacity.opacity.value, greaterThan(0.0));

    await tester.pumpAndSettle();
    expect(find.text('#$ref'), findsNothing, reason: 'gone once the animation finishes');
  });
}
