// Where the text you type actually lands inside the box.
//
// InputDecorator centres the label+gap+input block between its content
// paddings, so with a floating label the input drifts low: at (12, 8) the
// typed text sat 28.8px below the top border and 9.5px above the bottom one,
// nearly touching it — and about 10px lower than the placeholder it replaced,
// so the text visibly dropped the moment you started typing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/fields.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<(Rect box, Rect placeholder)> pumpEmpty(WidgetTester tester, TextEditingController c) async {
    // The reporter's phone: 360x800 logical, narrower than the 390x844 mock.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.light),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(26),
          child: AppField(label: 'Adresse e-mail', controller: c, validator: V.none),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return (tester.getRect(find.byType(AppField)), tester.getRect(find.text('Adresse e-mail')));
  }

  testWidgets('the placeholder is centred in the box', (tester) async {
    final (box, placeholder) = await pumpEmpty(tester, TextEditingController());
    expect((placeholder.center.dy - box.center.dy).abs(), lessThan(1.0));
  });

  testWidgets('typed text is centred too, not slumped against the bottom', (tester) async {
    final c = TextEditingController();
    final (box, _) = await pumpEmpty(tester, c);

    await tester.enterText(find.byType(TextField), 'moncef@gmail.com');
    await tester.pumpAndSettle();

    final text = tester.getRect(find.byType(EditableText));
    final above = text.top - box.top;
    final below = box.bottom - text.bottom;

    expect(below, greaterThan(12.0), reason: 'was 9.5 — all but touching the border');
    expect((above - below).abs(), lessThan(8.0), reason: 'was off by 19.3');
  });

  testWidgets('the floating label clears the border', (tester) async {
    final c = TextEditingController();
    final (box, _) = await pumpEmpty(tester, c);

    await tester.enterText(find.byType(TextField), 'moncef@gmail.com');
    await tester.pumpAndSettle();

    final label = tester.getRect(find.text('Adresse e-mail'));
    expect(label.top - box.top, greaterThan(4.0), reason: 'crammed against the top border');
    expect(label.bottom, lessThan(tester.getRect(find.byType(EditableText)).top),
        reason: 'label and value must not overlap');
  });

  testWidgets('the value never spills outside the box', (tester) async {
    final c = TextEditingController();
    final (box, _) = await pumpEmpty(tester, c);

    await tester.enterText(find.byType(TextField), 'moncef@gmail.com');
    await tester.pumpAndSettle();

    final text = tester.getRect(find.byType(EditableText));
    expect(text.top, greaterThanOrEqualTo(box.top));
    expect(text.bottom, lessThanOrEqualTo(box.bottom));
  });
}
