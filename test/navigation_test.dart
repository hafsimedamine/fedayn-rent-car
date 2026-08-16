// Home's avatar must reach the Account tab, and logging out must actually
// leave the signed-in app rather than just showing a toast.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/screens/login.dart';
import 'package:fedayns_rent_car/screens/main_shell.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';

import 'helpers.dart';

Widget _app(AppState state, {Widget? home}) => AppScope(
      state: state,
      child: MaterialApp(theme: buildAppTheme(Brightness.light), home: home ?? const MainShell()),
    );

void main() {
  setUpAll(loadAppFonts);

  testWidgets('tapping the home avatar opens the Account tab', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(AppState()));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour, $kUserFirstName'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Mon compte'), findsOneWidget);
  });

  testWidgets('logging out confirms, then returns to Login', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = AppState();
    await tester.pumpWidget(_app(state, home: const MainShell(initialTab: 3)));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Se déconnecter'), 300);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se déconnecter').last);
    await tester.pumpAndSettle();

    // Cancelling keeps you signed in.
    expect(find.text('Se déconnecter ?'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    // Still signed in. (The header is scrolled out of the list's viewport, so
    // assert on the screen rather than its title.)
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    // Confirming leaves the app.
    await tester.tap(find.text('Se déconnecter').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Se déconnecter'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainShell), findsNothing, reason: 'signed-in app must be off the stack');
  });

  test('logOut clears session state but keeps the theme', () {
    final s = AppState()
      ..setDarkMode(true)
      ..setChip('SUV')
      ..setSort(SortMode.priceDesc)
      ..toggleFav('c_500')
      ..savePersonalInfo(name: 'X Y', phone: '0600000000', email: 'x@y.z');

    s.logOut();

    expect(s.chip, 'All');
    expect(s.sort, SortMode.recommended);
    expect(s.isFav('c_500'), isFalse);
    expect(s.piEmail, kUserEmail);
    expect(s.isDarkMode, isTrue, reason: 'appearance is a device preference');
  });
}
