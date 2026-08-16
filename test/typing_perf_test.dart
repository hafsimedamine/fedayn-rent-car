// Typing must not rebuild the world. Every keystroke used to run setState on
// the whole screen (each controller was wired to `setState(() {})`) *and*
// again inside every AppField, so a four-field form rebuilt itself and all of
// its fields on each character.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/screens/login.dart';
import 'package:fedayns_rent_car/screens/register.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/fields.dart';

import 'helpers.dart';

/// (builds of [T], builds of anything) while [action] runs.
Future<(int, int)> countBuilds<T extends Widget>(WidgetTester tester, Future<void> Function() action) async {
  var matching = 0;
  var total = 0;
  debugOnRebuildDirtyWidget = (e, __) {
    total++;
    if (e.widget is T) matching++;
  };
  await action();
  debugOnRebuildDirtyWidget = null;
  return (matching, total);
}

void main() {
  setUpAll(loadAppFonts);

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(
      state: AppState(),
      child: MaterialApp(theme: buildAppTheme(Brightness.light), home: screen),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('typing into Login rebuilds few widgets', (tester) async {
    await pumpScreen(tester, const LoginScreen());
    final field = find.byType(TextField).first;

    final (fields, total) = await countBuilds<AppField>(tester, () async {
      for (final ch in 'abcdefghij'.split('')) {
        await tester.enterText(field, ch * 3);
        await tester.pump();
      }
    });
    debugPrint('LOGIN 10 keystrokes -> AppField builds: $fields, total widget builds: $total');
    // Was 20 and 1832 — every controller was wired to a screen-wide setState.
    expect(fields, lessThanOrEqualTo(2), reason: 'fields must not rebuild per character');
    expect(total, lessThan(900), reason: 'what is left is EditableText/InputDecorator, not our tree');
  });

  testWidgets('typing into Register rebuilds few widgets', (tester) async {
    await pumpScreen(tester, const RegisterScreen());
    final field = find.byType(TextField).first;

    final (fields, total) = await countBuilds<AppField>(tester, () async {
      for (final ch in 'abcdefghij'.split('')) {
        await tester.enterText(field, ch * 3);
        await tester.pump();
      }
    });
    debugPrint('REGISTER 10 keystrokes -> AppField builds: $fields, total widget builds: $total');
    // Was 40 and 2552 — four controllers, each rebuilding the whole screen.
    expect(fields, lessThanOrEqualTo(2), reason: 'the other three fields must stay still');
    expect(total, lessThan(900));
  });
}
