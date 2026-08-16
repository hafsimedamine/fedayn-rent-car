// Preferences have to round-trip and actually reach storage — a switch that
// forgets itself on restart is worse than no switch.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/db/settings_store.dart';
import 'package:fedayns_rent_car/data/notification_prefs.dart';
import 'package:fedayns_rent_car/screens/account/notification_settings.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';

import 'helpers.dart';

void main() {
  setUpAll(loadAppFonts);

  test('defaults keep transactional alerts on and marketing off', () {
    const p = NotificationPrefs();
    expect(p.bookingUpdates, isTrue);
    expect(p.pickupReminders, isTrue);
    expect(p.availabilityAlerts, isTrue);
    expect(p.newOffers, isFalse, reason: 'opt-in, not opt-out');
    expect(p.promoEmails, isFalse);
    expect(p.allChannelsOff, isFalse);
  });

  test('every field round-trips through the stored map', () {
    const p = NotificationPrefs(
      push: false,
      email: false,
      sms: true,
      bookingUpdates: false,
      pickupReminders: false,
      returnReminders: false,
      availabilityAlerts: false,
      priceDrops: true,
      newOffers: true,
      promoEmails: true,
      quietHours: false,
    );
    final back = NotificationPrefs.fromMap(p.toMap());

    expect(back.toMap(), p.toMap());
  });

  test('an unknown or absent key falls back to the default', () {
    final p = NotificationPrefs.fromMap({'notif.push': 'oui', 'notif.newOffers': 'true'});
    expect(p.push, isTrue, reason: 'unparseable, so the default stands');
    expect(p.newOffers, isTrue);
    expect(p.sms, isFalse, reason: 'absent, so the default stands');
  });

  test('allChannelsOff only when all three are off', () {
    expect(const NotificationPrefs(push: false, email: false, sms: false).allChannelsOff, isTrue);
    expect(const NotificationPrefs(push: false, email: false, sms: true).allChannelsOff, isFalse);
  });

  test('changing a preference writes it through to the store', () async {
    final store = InMemorySettingsStore();
    final app = AppState(settings: store);

    app.setNotificationPrefs(app.notifications.copyWith(newOffers: true));
    await Future<void>.delayed(Duration.zero);

    expect((await store.readAll())['notif.newOffers'], 'true');
  });

  test('stored preferences are loaded back into a new state', () async {
    final store = InMemorySettingsStore();
    await store.writeAll(const NotificationPrefs(sms: true, quietHours: false).toMap());

    final app = AppState(settings: store);
    await Future<void>.delayed(Duration.zero);

    expect(app.notifications.sms, isTrue);
    expect(app.notifications.quietHours, isFalse);
  });

  testWidgets('tapping a row toggles and persists it', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final store = InMemorySettingsStore();
    final app = AppState(settings: store);

    await tester.pumpWidget(AppScope(
      state: app,
      child: MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: const NotificationSettingsScreen(),
      ),
    ));

    expect(app.notifications.newOffers, isFalse);
    // Built but below the fold on a 390x844 viewport, so a finder match is
    // not enough — it has to be scrolled into the hit-testable area.
    await tester.ensureVisible(find.text('Nouvelles offres'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nouvelles offres'));
    await tester.pumpAndSettle();

    expect(app.notifications.newOffers, isTrue);
    expect((await store.readAll())['notif.newOffers'], 'true');
  });

  testWidgets('silencing every channel warns instead of pretending', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final app = AppState(settings: InMemorySettingsStore());

    await tester.pumpWidget(AppScope(
      state: app,
      child: MaterialApp(
        theme: buildAppTheme(Brightness.light),
        home: const NotificationSettingsScreen(),
      ),
    ));

    expect(find.text('Tout est coupé'), findsNothing);

    app.setNotificationPrefs(const NotificationPrefs(push: false, email: false, sms: false));
    await tester.pumpAndSettle();

    expect(find.text('Tout est coupé'), findsOneWidget);
  });
}
