// Nous contacter has to actually go somewhere and carry the real details.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/screens/account/contact_us.dart';
import 'package:fedayns_rent_car/screens/tabs/account_tab.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/common.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(
      state: AppState(),
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(body: home),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('the screen shows the support phone and email', (tester) async {
    await pump(tester, const ContactUsScreen());

    expect(find.text(kSupportPhone), findsOneWidget);
    expect(find.text(kSupportEmail), findsOneWidget);
    expect(kSupportPhone, '+212 707-534357');
  });

  testWidgets('tapping a row copies it to the clipboard', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await pump(tester, const ContactUsScreen());
    await tester.tap(find.text(kSupportPhone));
    await tester.pumpAndSettle();

    expect(copied, kSupportPhone);
  });

  testWidgets('Nous contacter in Compte opens it', (tester) async {
    await pump(tester, const AccountTab());

    // Past the list's cache extent on an 800px-tall viewport, so it has not
    // been built yet — the list has to be scrolled to it, not just queried.
    await tester.scrollUntilVisible(find.text('Nous contacter'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nous contacter'));
    await tester.pumpAndSettle();

    expect(find.byType(ContactUsScreen), findsOneWidget);
    expect(find.text(kSupportPhone), findsOneWidget);
  });

  testWidgets('neither detail wraps or truncates at 360', (tester) async {
    await pump(tester, const ContactUsScreen());

    for (final value in [kSupportPhone, kSupportEmail]) {
      final rp = tester.renderObject<RenderParagraph>(find.text(value));
      expect(rp.didExceedMaxLines, isFalse, reason: '"$value" is truncated');
      expect(rp.size.height, lessThan(28), reason: '"$value" wrapped onto a second line');
    }
  });

  testWidgets('the footer version matches pubspec', (tester) async {
    await pump(tester, const AccountTab());

    // The footer sits past the list's cache extent, so it is not built until
    // the list is actually scrolled down to it.
    await tester.scrollUntilVisible(
      find.textContaining("Fedayn's Rent Car · v"), 200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('v$kAppVersion'), findsOneWidget);
    expect(kAppVersion, '0.1.1');
  });
}
