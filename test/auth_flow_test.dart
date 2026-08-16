// Register against a real SQLite database, then sign back in — and check the
// home greeting uses the account's own first name rather than a fixture.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fedayns_rent_car/data/db/app_database.dart';
import 'package:fedayns_rent_car/data/db/sqlite_auth_repository.dart';
import 'package:fedayns_rent_car/main.dart';
import 'package:fedayns_rent_car/state/app_state.dart';

import 'helpers.dart';

/// Taps a button whose handler does real I/O (SQLite) and off-thread hashing,
/// then waits for the loading barrier to come back down.
///
/// The two halves need opposite things: the work only progresses under
/// `runAsync` (testWidgets' fake clock never lets a real future complete),
/// while the barrier only paints under `pump` — and [runWithLoading]
/// deliberately waits for that paint before starting. So this alternates them.
Future<void> _submitAndSettle(WidgetTester tester, Finder button) async {
  await tester.runAsync(() => tester.tap(button));

  const step = Duration(milliseconds: 20);
  for (var i = 0; i < 150; i++) {
    await tester.pump(step);
    if (!tester.any(find.byType(CircularProgressIndicator))) break;
    await tester.runAsync(() => Future<void>.delayed(step));
  }
  await tester.pumpAndSettle();
}

void main() {
  late Database db;
  late AppState state;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await loadAppFonts();
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.schemaVersion,
        onCreate: (db, _) => AppDatabase.createSchema(db),
      ),
    );
    state = AppState(auth: SqliteAuthRepository(db: db));
  });

  tearDown(() async => db.close());

  Future<void> fillRegistration(WidgetTester tester, {required String email}) async {
    await tester.enterText(find.byType(TextField).at(0), 'Amine Tazi');
    await tester.enterText(find.byType(TextField).at(1), email);
    await tester.enterText(find.byType(TextField).at(2), '0612345678');
    await tester.enterText(find.byType(TextField).at(3), 'motdepasse1');
    await tester.pump();
    await tester.tap(find.textContaining("J'accepte les"));
    await tester.pumpAndSettle();
  }

  testWidgets('registering writes a row and greets by first name', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(FedaynsApp(state: state));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    await fillRegistration(tester, email: 'amine@example.com');

    await _submitAndSettle(tester, find.widgetWithText(ElevatedButton, 'Créer un compte'));

    // The account is really in the database.
    expect(await tester.runAsync(() => SqliteAuthRepository(db: db).accountCount()), 1);
    expect(state.account?.email, 'amine@example.com');
    expect(state.displayFirstName, 'Amine');

    // Registration lands on the CIN step, not the home screen.
    expect(find.text('Vérifier votre identité'), findsOneWidget);
  });

  testWidgets('a duplicate email is refused with a visible reason', (tester) async {
    await tester.runAsync(() => SqliteAuthRepository(db: db).register(
          fullName: 'Amine Tazi',
          email: 'amine@example.com',
          phone: '+212 600 000 000',
          password: 'motdepasse1',
        ));

    tester.view.physicalSize = const Size(390, 1400); // room for the banner
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(FedaynsApp(state: state));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    await fillRegistration(tester, email: 'amine@example.com');

    await _submitAndSettle(tester, find.widgetWithText(ElevatedButton, 'Créer un compte'));

    expect(find.text('Cette adresse e-mail est déjà utilisée.'), findsOneWidget);
    expect(state.isSignedIn, isFalse);
    expect(await tester.runAsync(() => SqliteAuthRepository(db: db).accountCount()), 1,
        reason: 'no second row');
  });

  testWidgets('signing in with the wrong password is refused', (tester) async {
    await tester.runAsync(() => SqliteAuthRepository(db: db).register(
          fullName: 'Amine Tazi',
          email: 'amine@example.com',
          phone: '+212 600 000 000',
          password: 'motdepasse1',
        ));

    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(FedaynsApp(state: state));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'amine@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.pump();
    await _submitAndSettle(tester, find.widgetWithText(ElevatedButton, 'Se connecter'));

    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
    expect(state.isSignedIn, isFalse);
  });

  testWidgets('signing in with the right password reaches the app and greets by name', (tester) async {
    await tester.runAsync(() => SqliteAuthRepository(db: db).register(
          fullName: 'Amine Tazi',
          email: 'amine@example.com',
          phone: '+212 600 000 000',
          password: 'motdepasse1',
        ));

    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(FedaynsApp(state: state));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'amine@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'motdepasse1');
    await tester.pump();
    await _submitAndSettle(tester, find.widgetWithText(ElevatedButton, 'Se connecter'));

    expect(state.isSignedIn, isTrue);
    expect(find.text('Bonjour, Amine'), findsOneWidget);
  });
}
