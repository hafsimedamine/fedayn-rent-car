// The overlay must appear while work is in flight and always come back down —
// including when the work throws.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/loading_overlay.dart';

void main() {
  testWidgets('shows while running and dismisses on success', (tester) async {
    final completer = Completer<String>();
    String? result;

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              result = await runWithLoading(context, () => completer.future, message: 'Connexion…');
            },
            child: const Text('go'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Connexion…'), findsOneWidget);

    completer.complete('done');
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(result, 'done');
  });

  testWidgets('the spinner is on screen before the work starts', (tester) async {
    // The bug this guards: the barrier route was pushed but the work began in
    // the same turn, so a second of key derivation ran with the previous
    // screen still painted and the app looked frozen.
    var spinnerWhenWorkBegan = false;

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => runWithLoading(context, () async {
              spinnerWhenWorkBegan = tester.any(find.byType(CircularProgressIndicator));
              return 0;
            }),
            child: const Text('go'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(spinnerWhenWorkBegan, isTrue);
    expect(find.byType(CircularProgressIndicator), findsNothing, reason: 'and it comes back down');
  });

  testWidgets('the message sits under a Material, so it is not debug-red', (tester) async {
    // A DialogRoute inserts no Material. Without one, Text falls back to the
    // framework's red-on-yellow "missing style", which is exactly how this
    // rendered once the barrier started painting.
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: const Scaffold(body: LoadingBarrier(message: 'Connexion…')),
    ));

    expect(
      find.ancestor(of: find.text('Connexion…'), matching: find.byType(Material)),
      findsWidgets,
    );
    final style = tester.widget<Text>(find.text('Connexion…')).style;
    expect(style?.color, isNot(const Color(0xFFFF0000)));
  });

  testWidgets('dismisses even when the work fails', (tester) async {
    final completer = Completer<String>();
    Object? caught;

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              try {
                await runWithLoading(context, () => completer.future);
              } catch (e) {
                caught = e;
              }
            },
            child: const Text('go'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.completeError(StateError('boom'));
    await tester.pumpAndSettle();

    // A stranded barrier would lock the app permanently.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(caught, isA<StateError>());
  });

  testWidgets('back cannot dismiss it while work is in flight', (tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => runWithLoading(context, () => completer.future),
            child: const Text('go'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump();

    final popped = await tester.binding.handlePopRoute();
    // Discrete pumps, not pumpAndSettle: the indeterminate spinner animates
    // forever, so nothing ever "settles" while the barrier is up.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(popped, isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget,
        reason: 'the barrier must survive a back press');

    completer.complete();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
