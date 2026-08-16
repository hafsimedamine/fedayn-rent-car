// Guards the optimisations, so a later change cannot quietly undo them.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/main.dart';
import 'package:fedayns_rent_car/screens/main_shell.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/car_card.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('only the cards on screen are built', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(AppScope(
      state: AppState(),
      child: MaterialApp(theme: buildAppTheme(Brightness.light), home: const MainShell()),
    ));
    await tester.pumpAndSettle();

    final built = find.byType(CarCard).evaluate().length;
    expect(built, lessThan(kCars.length),
        reason: 'the whole fleet should not be built at once — the list must be lazy');
    expect(built, greaterThan(0));
  });

  testWidgets('toggling a favourite does not rebuild MaterialApp', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = AppState();
    await tester.pumpWidget(FedaynsApp(state: state));
    await tester.pumpAndSettle();

    final appElement = tester.element(find.byType(MaterialApp));
    state.toggleFav('c_sandero');
    await tester.pump();

    // Same element: MaterialApp was not rebuilt, so the tree under it was not
    // thrown away for an unrelated state change.
    expect(tester.element(find.byType(MaterialApp)), same(appElement));
  });

  testWidgets('changing the theme does rebuild MaterialApp', (tester) async {
    final state = AppState();
    await tester.pumpWidget(FedaynsApp(state: state));
    await tester.pumpAndSettle();

    expect(state.themeMode, ThemeMode.light);
    state.setDarkMode(true);
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark, reason: 'theme changes must still reach MaterialApp');
  });

  testWidgets('car thumbnails decode at display size, not full size', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(AppScope(
      state: AppState(),
      child: MaterialApp(theme: buildAppTheme(Brightness.light), home: const MainShell()),
    ));
    await tester.pumpAndSettle();

    final image = tester.widgetList<Image>(find.byType(Image)).firstWhere(
          (i) => i.image is ResizeImage,
          orElse: () => throw StateError('no car thumbnail was resized on decode'),
        );
    final resize = image.image as ResizeImage;
    expect(resize.width, isNotNull);
    expect(resize.width! <= 400, isTrue, reason: 'a 110px thumbnail should not decode at source width');
  });
}
