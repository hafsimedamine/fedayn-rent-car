// A toast must not follow the user off the screen that raised it, and must
// clear itself after 3s.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/widgets/common.dart';

Widget _app() => MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorObservers: [ToastRouteObserver()],
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => showAppToast(context, 'Ajouté aux favoris'),
                  child: const Text('toast'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Scaffold(body: Text('next'))),
                  ),
                  child: const Text('go'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('a toast carrying an Undo action still self-dismisses', (tester) async {
    // SnackBar.persist defaults to `action != null`, so this used to stay on
    // screen until the user navigated away.
    await tester.pumpWidget(MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => showAppToast(context, 'Ajouté aux favoris', onUndo: () {}),
            child: const Text('toast'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('toast'));
    await tester.pump();
    expect(find.text('Ajouté aux favoris'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);

    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('Ajouté aux favoris'), findsNothing,
        reason: 'an Undo toast must time out like any other');
  });

  testWidgets('clears itself after 3s', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('toast'));
    await tester.pump();
    expect(find.text('Ajouté aux favoris'), findsOneWidget);

    // Advance in frames rather than one jump: the 3s dwell is followed by an
    // exit animation, which needs frames to run to completion.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('Ajouté aux favoris'), findsNothing);
  });

  testWidgets('clears when the user navigates to another page', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('toast'));
    await tester.pump();
    expect(find.text('Ajouté aux favoris'), findsOneWidget);

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('Ajouté aux favoris'), findsNothing,
        reason: 'toast must not follow the user onto the next page');
  });
}
