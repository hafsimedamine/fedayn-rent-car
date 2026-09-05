// Le champ de confirmation et le bouton « Générer un mot de passe ».

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/password_policy.dart';
import 'package:fedayns_rent_car/screens/register.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/widgets/common.dart';
import 'package:fedayns_rent_car/widgets/fields.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(AppScope(
      state: AppState(),
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: buildAppTheme(Brightness.light),
        home: const RegisterScreen(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  TextField champ(WidgetTester tester, int i) => tester.widgetList<TextField>(find.byType(TextField)).elementAt(i);

  testWidgets('le formulaire a un champ de confirmation', (tester) async {
    await pump(tester);
    expect(find.text('Confirmer le mot de passe'), findsOneWidget);
    expect(find.byType(AppField), findsNWidgets(5));
  });

  testWidgets('les règles sont annoncées avant la faute', (tester) async {
    await pump(tester);
    expect(find.textContaining('une majuscule et un symbole'), findsOneWidget);
  });

  testWidgets('générer remplit les deux champs avec la même valeur', (tester) async {
    await pump(tester);

    await tester.ensureVisible(find.text('Générer un mot de passe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Générer un mot de passe'));
    await tester.pumpAndSettle();

    final pw = champ(tester, 3).controller!.text;
    final pw2 = champ(tester, 4).controller!.text;

    expect(pw, isNotEmpty);
    expect(pw2, pw, reason: 'la confirmation doit être remplie à l\'identique');
    expect(PasswordPolicy.validate(pw), isNull, reason: 'le mot de passe généré doit être conforme');
  });

  testWidgets('générer révèle le mot de passe en clair', (tester) async {
    await pump(tester);
    expect(champ(tester, 3).obscureText, isTrue);

    await tester.ensureVisible(find.text('Générer un mot de passe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Générer un mot de passe'));
    await tester.pumpAndSettle();

    expect(champ(tester, 3).obscureText, isFalse, reason: 'illisible, il ne peut pas être noté');
    expect(champ(tester, 4).obscureText, isFalse);
  });

  testWidgets('deux générations donnent deux mots de passe différents', (tester) async {
    await pump(tester);
    await tester.ensureVisible(find.text('Générer un mot de passe'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Générer un mot de passe'));
    await tester.pumpAndSettle();
    final premier = champ(tester, 3).controller!.text;

    await tester.tap(find.text('Générer un mot de passe'));
    await tester.pumpAndSettle();
    expect(champ(tester, 3).controller!.text, isNot(premier));
  });

  testWidgets('une confirmation qui ne correspond pas est signalée', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField).at(3), 'Motdepasse!1');
    await tester.enterText(find.byType(TextField).at(4), 'Autrechose!1');
    // L'erreur ne s'affiche qu'une fois le champ quitté.
    await tester.tap(find.byType(TextField).at(3));
    await tester.pumpAndSettle();

    expect(find.text('Les deux mots de passe ne correspondent pas'), findsOneWidget);
  });
}
