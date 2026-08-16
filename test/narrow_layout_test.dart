// 360x800 is the phone this was reported on, and it is 30px narrower than the
// design's 390x844 mock — enough that rows which merely looked tight in the
// mock actually overflow.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/screens/main_shell.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/car_card.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<void> pump(WidgetTester tester, AppState state, {Size size = const Size(360, 800)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(theme: buildAppTheme(Brightness.light), home: const MainShell()),
    ));
    await tester.pump(const Duration(milliseconds: 400));
  }

  for (final mode in SortMode.values) {
    testWidgets('Home fits at 360 wide with sort "${mode.label}"', (tester) async {
      await pump(tester, AppState()..sort = mode);
      expect(tester.takeException(), isNull, reason: '"${mode.label}" overflows the sort row');
    });
  }

  testWidgets('a car card fits its narrowest real width', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final car in kCars) {
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: Center(
            // 360 minus the list's 22px side padding.
            child: SizedBox(
              width: 316,
              child: CarCard(car: car, isFav: false, onToggleFav: () {}, onTap: () {}),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${car.name} overflows at 316px');
    }
  });

  testWidgets('nothing on a card is ellipsised at 360', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Every car, because the widest price ("1 200 MAD") squeezes the
    // availability label hardest and the cheapest one hides the problem.
    for (final car in kCars) {
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 316,
              child: CarCard(car: car, isFav: false, onToggleFav: () {}, onTap: () {}),
            ),
          ),
        ),
      ));
      await tester.pump();

      for (final t in tester.widgetList<Text>(find.byType(Text))) {
        final data = t.data;
        if (data == null) continue;
        // The "available from <date>" copy is long by nature; the states that
        // matter are the ones on nearly every card.
        if (data.startsWith('Disponible dès')) continue;
        final rendered = tester.renderObject<RenderParagraph>(find.text(data).first);
        expect(rendered.didExceedMaxLines, isFalse,
            reason: '"$data" is truncated on ${car.name} at 360px');
      }
    }
  });

  testWidgets('the promo carousel is gone from Home', (tester) async {
    await pump(tester, AppState());
    expect(find.textContaining('WEEK20'), findsNothing);
    expect(find.textContaining('Livraison offerte'), findsNothing);
    expect(find.textContaining('-20%'), findsNothing);
  });

  testWidgets('Favoris has no options button in its header', (tester) async {
    final state = AppState();
    await pump(tester, state);
    // Third tab.
    await tester.tap(find.text('Favoris'));
    await tester.pumpAndSettle();

    expect(find.text('Voitures enregistrées'), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsNothing, reason: 'the options button served no purpose');
  });
}
