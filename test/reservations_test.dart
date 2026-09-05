// Les réservations sont celles de l'utilisateur, et rien d'autre.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:fedayns_rent_car/data/calendar.dart';
import 'package:fedayns_rent_car/data/db/account.dart';
import 'package:fedayns_rent_car/data/db/app_database.dart';
import 'package:fedayns_rent_car/data/db/booking_repository.dart';
import 'package:fedayns_rent_car/data/db/sqlite_booking_repository.dart';
import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/data/models.dart';
import 'package:fedayns_rent_car/screens/tabs/rentals_tab.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';

import 'helpers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('un compte neuf n\'a aucune réservation', () {
    test('les trois onglets sont vides', () {
      final app = AppState();
      for (final kind in BookingKind.values) {
        expect(app.reservationsPar(kind), isEmpty, reason: 'onglet ${kind.name}');
      }
    });

    test('les fixtures ont disparu de la flotte', () {
      // kUpcoming/kActive/kPast affichaient un Duster, une Golf et deux
      // locations passées à qui n'avait jamais rien réservé.
      final source = AppState();
      expect(source.reservations, isEmpty);
    });
  });

  group('l\'onglet à venir', () {
    testWidgets('affiche un état vide en français', (tester) async {
      await loadAppFonts();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(AppScope(
        state: AppState(),
        child: MaterialApp(theme: buildAppTheme(Brightness.light), home: const Scaffold(body: RentalsTab())),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Aucune réservation à venir'), findsOneWidget);
      expect(find.text('Parcourir les voitures'), findsOneWidget);
      expect(find.textContaining('Dacia Duster'), findsNothing, reason: 'la fausse réservation');
    });

    testWidgets('chaque onglet a son propre état vide', (tester) async {
      await loadAppFonts();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(AppScope(
        state: AppState(),
        child: MaterialApp(theme: buildAppTheme(Brightness.light), home: const Scaffold(body: RentalsTab())),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('En cours'));
      await tester.pumpAndSettle();
      expect(find.text('Aucune location en cours'), findsOneWidget);

      await tester.tap(find.text('Passées'));
      await tester.pumpAndSettle();
      expect(find.text('Aucune location passée'), findsOneWidget);
      expect(find.text('Parcourir les voitures'), findsNothing,
          reason: 'un historique ne se remplit pas en parcourant la flotte');
    });
  });

  group('le classement suit les dates réelles', () {
    Booking creer({required int debutDansNJours, int duree = 3}) {
      final debut = aujourdHui.add(Duration(days: debutDansNJours));
      return Booking(
        ref: 'RC$debutDansNJours',
        carId: 'c_duster',
        startDate: debut,
        endDate: debut.add(Duration(days: duree)),
        totalPrice: 1000,
        pickLoc: 'Casablanca — Maarif',
        retLoc: 'Casablanca — Maarif',
      );
    }

    test('une réservation future est à venir', () {
      final app = AppState()..seedReservations([creer(debutDansNJours: 5)]);
      expect(app.reservationsPar(BookingKind.upcoming).length, 1);
      expect(app.reservationsPar(BookingKind.active), isEmpty);
      expect(app.reservationsPar(BookingKind.past), isEmpty);
    });

    test('une réservation en cours aujourd\'hui est active', () {
      final app = AppState()..seedReservations([creer(debutDansNJours: -1, duree: 3)]);
      expect(app.reservationsPar(BookingKind.active).length, 1);
      expect(app.reservationsPar(BookingKind.upcoming), isEmpty);
    });

    test('une réservation terminée est passée', () {
      final app = AppState()..seedReservations([creer(debutDansNJours: -10, duree: 3)]);
      expect(app.reservationsPar(BookingKind.past).length, 1);
    });

    test('le jour du départ, elle devient active', () {
      final app = AppState()..seedReservations([creer(debutDansNJours: 0, duree: 2)]);
      expect(app.reservationsPar(BookingKind.active).length, 1,
          reason: 'la prise en charge est aujourd\'hui');
    });

    test('le jour du retour, elle est encore active', () {
      final debut = aujourdHui.subtract(const Duration(days: 3));
      final app = AppState()
        ..seedReservations([
          Booking(
            ref: 'RC9',
            carId: 'c_duster',
            startDate: debut,
            endDate: aujourdHui,
            totalPrice: 1000,
            pickLoc: 'x',
            retLoc: 'x',
          ),
        ]);
      expect(app.reservationsPar(BookingKind.active).length, 1);
      expect(app.reservationsPar(BookingKind.past), isEmpty);
    });
  });

  group('confirmer une réservation', () {
    test('la fait apparaître dans à venir', () async {
      final repo = InMemoryBookingRepository();
      final app = AppState(bookings: repo);
      app.signedInAs(const Account(id: 1, fullName: 'Amine Tazi', email: 'a@b.ma', phone: '0612345678'));

      app.startBooking(carById('c_duster'));
      final debut = aujourdHui.add(const Duration(days: 4));
      app.draft
        ..pickDate = debut
        ..retDate = debut.add(const Duration(days: 3));

      final booking = await app.confirmerReservation();

      expect(app.reservationsPar(BookingKind.upcoming).map((b) => b.ref), contains(booking.ref));
      expect(booking.carId, 'c_duster');
      expect(booking.totalPrice, app.draft.total);
    });

    test('elle est écrite dans le dépôt', () async {
      final repo = InMemoryBookingRepository();
      final app = AppState(bookings: repo);
      app.signedInAs(const Account(id: 7, fullName: 'Amine Tazi', email: 'a@b.ma', phone: '0612345678'));

      app.startBooking(carById('c_golf'));
      final debut = aujourdHui.add(const Duration(days: 2));
      app.draft
        ..pickDate = debut
        ..retDate = debut.add(const Duration(days: 2));
      await app.confirmerReservation();

      final stockees = await repo.forUser(7);
      expect(stockees.length, 1);
      expect(stockees.first.carId, 'c_golf');
    });

    test('sans période choisie, rien n\'est créé', () {
      final app = AppState(bookings: InMemoryBookingRepository());
      app.signedInAs(const Account(id: 1, fullName: 'A B', email: 'a@b.ma', phone: '0612345678'));
      app.startBooking(carById('c_duster'));
      expect(() => app.confirmerReservation(), throwsStateError);
    });

    test('les références sont uniques', () async {
      final app = AppState(bookings: InMemoryBookingRepository());
      app.signedInAs(const Account(id: 1, fullName: 'A B', email: 'a@b.ma', phone: '0612345678'));
      final refs = <String>{};
      for (var i = 0; i < 50; i++) {
        app.startBooking(carById('c_duster'));
        final debut = aujourdHui.add(Duration(days: 2 + i));
        app.draft
          ..pickDate = debut
          ..retDate = debut.add(const Duration(days: 1));
        refs.add((await app.confirmerReservation()).ref);
      }
      expect(refs.length, 50);
    });
  });

  group('persistance SQL', () {
    late Database db;

    setUp(() async {
      db = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: AppDatabase.schemaVersion,
          onCreate: (db, _) => AppDatabase.createSchema(db),
        ),
      );
    });

    tearDown(() async => db.close());

    test('une réservation survit à une relecture', () async {
      final repo = SqliteBookingRepository(db: db);
      final b = reservationDeTest(ref: 'RC5555');
      await repo.add(b, userId: 3);

      final relues = await repo.forUser(3);
      expect(relues.length, 1);
      expect(relues.first.ref, 'RC5555');
      expect(relues.first.startDate, b.startDate);
      expect(relues.first.endDate, b.endDate);
      expect(relues.first.totalPrice, b.totalPrice);
      expect(relues.first.status, BookingStatus.confirmed);
    });

    test('chaque compte ne voit que les siennes', () async {
      final repo = SqliteBookingRepository(db: db);
      await repo.add(reservationDeTest(ref: 'RC1'), userId: 1);
      await repo.add(reservationDeTest(ref: 'RC2'), userId: 2);

      expect((await repo.forUser(1)).map((b) => b.ref), ['RC1']);
      expect((await repo.forUser(2)).map((b) => b.ref), ['RC2']);
      expect(await repo.forUser(99), isEmpty);
    });

    test('l\'annulation est écrite', () async {
      final repo = SqliteBookingRepository(db: db);
      await repo.add(reservationDeTest(ref: 'RC7'), userId: 1);

      await repo.setStatus('RC7', BookingStatus.cancelled);
      expect((await repo.forUser(1)).single.status, BookingStatus.cancelled);
    });

    test('les colonnes sont celles du schéma convenu', () async {
      final colonnes = (await db.rawQuery('PRAGMA table_info(bookings)'))
          .map((r) => r['name'] as String)
          .toSet();
      expect(colonnes, containsAll(['user_id', 'car_id', 'start_date', 'end_date', 'total_price', 'status']));
    });
  });

  test('la déconnexion vide les réservations', () {
    final app = AppState()..seedReservations([reservationDeTest()]);
    expect(app.reservations, isNotEmpty);

    app.logOut();
    expect(app.reservations, isEmpty, reason: 'le compte suivant ne doit pas les hériter');
  });
}
