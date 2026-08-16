// The camera badge on the account avatar was decoration — an icon in a circle
// with no handler behind it. Tapping the avatar has to actually offer a source
// and keep what comes back.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/models.dart';
import 'package:fedayns_rent_car/screens/tabs/account_tab.dart';
import 'package:fedayns_rent_car/screens/tabs/home_tab.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/common.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<void> pump(WidgetTester tester, AppState state, Widget screen) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: buildAppTheme(Brightness.light),
        home: Scaffold(body: screen),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping the account avatar offers camera or gallery', (tester) async {
    await pump(tester, AppState(), const AccountTab());

    await tester.tap(find.byIcon(Icons.photo_camera_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Ajouter une photo'), findsOneWidget);
    expect(find.text('Prendre une photo'), findsOneWidget);
    expect(find.text('Choisir dans la galerie'), findsOneWidget);
  });

  testWidgets('a chosen photo replaces the placeholder icon', (tester) async {
    final state = AppState();
    await pump(tester, state, const AccountTab());

    expect(find.byIcon(Icons.person_outline_rounded), findsWidgets);

    // Stands in for what the picker returns; bytes so it renders without a file.
    state.setProfilePhoto(CapturedPhoto(path: 'me.jpg', bytes: _pngBytes));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('the home avatar shows the same photo', (tester) async {
    final state = AppState()..setProfilePhoto(CapturedPhoto(path: 'me.jpg', bytes: _pngBytes));
    await pump(tester, state, const HomeTab());

    // The placeholder person icon is gone from the header avatar.
    expect(find.byIcon(Icons.person_outline_rounded), findsNothing);
  });

  test('logging out drops the profile photo', () {
    final state = AppState()..setProfilePhoto(const CapturedPhoto(path: 'me.jpg', bytes: null));
    expect(state.profilePhoto, isNotNull);

    state.logOut();
    expect(state.profilePhoto, isNull, reason: 'the next user must not inherit it');
  });
}

/// Smallest valid PNG: a single transparent pixel.
final _pngBytes = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);
