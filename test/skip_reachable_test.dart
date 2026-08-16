// Skipping verification is only a real option if it can be found.
//
// The only way past the step used to be the last widget on a long scrolling
// form — behind the capture cards, four fields and an info banner — so on a
// phone it sat below the fold and read as "there is no way to skip this".

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/screens/verify_cin.dart';
import 'package:fedayns_rent_car/screens/verify_license.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/common.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<void> pumpAt390x844(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(
      state: AppState(),
      child: MaterialApp(theme: buildAppTheme(Brightness.light), home: screen),
    ));
    await tester.pumpAndSettle();
  }

  for (final (name, screen) in [
    ('CIN', const VerifyCinScreen()),
    ('licence', const VerifyLicenseScreen()),
  ]) {
    testWidgets('the $name step offers a skip without scrolling', (tester) async {
      await pumpAt390x844(tester, screen);

      final skip = find.byType(SkipLink);
      expect(skip, findsOneWidget, reason: 'no skip in the header');

      final rect = tester.getRect(skip);
      expect(rect.bottom, lessThanOrEqualTo(844), reason: 'below the fold on a 390x844 phone');
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(390));
    });

    testWidgets('the $name step still offers it at the end of the form', (tester) async {
      await pumpAt390x844(tester, screen);
      expect(find.text("Passer pour l'instant"), findsOneWidget);
    });

    testWidgets('tapping the $name header skip asks before leaving', (tester) async {
      await pumpAt390x844(tester, screen);

      await tester.tap(find.byType(SkipLink));
      await tester.pumpAndSettle();

      expect(find.text('Continuer sans vos documents ?'), findsOneWidget);
      expect(find.text('Réserver une voiture'), findsOneWidget, reason: 'it must say what stays locked');
    });
  }
}
