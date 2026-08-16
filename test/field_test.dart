// Guards the floating-label geometry. The label used to be a Stack overlay
// while InputDecorator vertically centred the input, so the two collided and
// the label read as leftover placeholder text sitting on the value.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/widgets/fields.dart';

Future<void> _pumpField(WidgetTester tester, TextEditingController c) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(26),
        child: AppField(label: 'Nom complet', controller: c),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('label never overlaps the typed value', (tester) async {
    await _pumpField(tester, TextEditingController(text: 'user@example.com'));

    final label = tester.getRect(find.text('Nom complet'));
    final input = tester.getRect(find.byType(EditableText));

    expect(label.bottom, lessThan(input.top),
        reason: 'floated label must sit clear of the input line');
  });

  testWidgets('keeps the 58px height the design specifies', (tester) async {
    await _pumpField(tester, TextEditingController());
    expect(tester.getRect(find.byType(AppField)).height, 58.0);
  });

  testWidgets('label rests over the input when empty, floats once filled', (tester) async {
    final c = TextEditingController();
    await _pumpField(tester, c);

    final resting = tester.getRect(find.text('Nom complet'));
    final input = tester.getRect(find.byType(EditableText));
    // Empty: the label acts as the placeholder, sharing the input's line.
    expect(resting.top, greaterThan(input.top - 8));

    c.text = 'Test User';
    await tester.pumpAndSettle();

    final floated = tester.getRect(find.text('Nom complet'));
    expect(floated.top, lessThan(resting.top), reason: 'label should rise on input');
  });
}
