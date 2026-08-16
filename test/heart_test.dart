// The favourite heart must render full size when a card is built already
// favourited — the pop tween starts at 0.6, so an unseeded controller left it
// visibly undersized until the user toggled it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/car_card.dart';

double _heartScale(WidgetTester tester) {
  final transition = tester.widget<ScaleTransition>(find.byKey(heartScaleKey));
  return transition.scale.value;
}

Widget _host({required bool isFav, required VoidCallback onTap}) => MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: Scaffold(body: Center(child: HeartButton(isFav: isFav, onTap: onTap))),
    );

void main() {
  _clippingTests();

  testWidgets('renders full size when built already favourited', (tester) async {
    await tester.pumpWidget(_host(isFav: true, onTap: () {}));
    await tester.pump();
    expect(_heartScale(tester), 1.0);
  });

  testWidgets('renders full size when not favourited', (tester) async {
    await tester.pumpWidget(_host(isFav: false, onTap: () {}));
    await tester.pump();
    expect(_heartScale(tester), 1.0);
  });

  testWidgets('pops on the empty -> filled transition and settles at 1.0', (tester) async {
    var fav = false;
    await tester.pumpWidget(StatefulBuilder(
      builder: (context, setState) => _host(isFav: fav, onTap: () => setState(() => fav = true)),
    ));
    await tester.pump();
    expect(_heartScale(tester), 1.0);

    await tester.tap(find.byType(HeartButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(_heartScale(tester), greaterThan(1.0), reason: 'mid-pop it should overshoot');

    await tester.pumpAndSettle();
    expect(_heartScale(tester), 1.0);
  });
}

// ── Clipping ──────────────────────────────────────────────────────────────
// The heart sits at Positioned(top: -2, right: -2), 2px outside the Stack and
// into the card's own padding. A Stack clips by default, so the top and right
// edges of the circular button were being shaved off.
void _clippingTests() {
  testWidgets('the card does not clip the heart button', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(AppScope(
      state: AppState(),
      child: MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: Scaffold(
          body: Center(
            // 390 minus the home list's 22px side padding — the real width.
            child: SizedBox(
              width: 346,
              child: CarCard(car: kCars.first, isFav: true, onToggleFav: () {}, onTap: () {}),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Whatever encloses the heart must not be clipping it away.
    final stack = tester.widget<Stack>(
      find.ancestor(of: find.byType(HeartButton), matching: find.byType(Stack)).first,
    );
    expect(stack.clipBehavior, Clip.none, reason: 'the stack would shave the overhanging 2px');

    // And the whole button really is inside the card's painted bounds.
    final heart = tester.getRect(find.byType(HeartButton));
    final card = tester.getRect(find.byType(CarCard));
    expect(heart.top, greaterThanOrEqualTo(card.top));
    expect(heart.right, lessThanOrEqualTo(card.right));
    expect(heart.width, 34);
    expect(heart.height, 34);
  });
}
