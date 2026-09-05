// Fedayn's Rent Car — app entry point.
//
// Run:
//   flutter create .        (first time only — scaffolds android/ios/web/etc.)
//   flutter pub get
//   flutter run

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/db/auth_repository.dart';
import 'data/db/booking_repository.dart';
import 'data/db/in_memory_auth_repository.dart';
import 'data/db/settings_store.dart';
import 'data/db/sqlite_auth_repository.dart';
import 'data/db/sqlite_booking_repository.dart';
import 'data/db/sqlite_settings_store.dart';
import 'state/app_state.dart';
import 'widgets/common.dart';
import 'theme.dart';
import 'screens/welcome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xavpcofdkuilbalmoxyi.supabase.co',
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  // sqflite has no web implementation, so the web build keeps accounts in
  // memory for the session. Every other platform persists to SQLite.
  final AuthRepository auth =
      kIsWeb ? InMemoryAuthRepository(withDemoAccount: true) : SqliteAuthRepository();
  final SettingsStore settings = kIsWeb ? InMemorySettingsStore() : SqliteSettingsStore();
  final BookingRepository bookings =
      kIsWeb ? InMemoryBookingRepository() : SqliteBookingRepository();
  runApp(FedaynsApp(state: AppState(auth: auth, settings: settings, bookings: bookings)));
}

class FedaynsApp extends StatelessWidget {
  const FedaynsApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      // Listens to themeMode alone. AnimatedBuilder on the whole state here
      // rebuilt MaterialApp — and therefore the entire tree — every time a
      // favourite or filter changed.
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: state.themeModeListenable,
        builder: (context, themeMode, _) => MaterialApp(
          title: "Fedayn's Rent Car",
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          navigatorObservers: [ToastRouteObserver()],
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: themeMode,
          home: const WelcomeScreen(),
        ),
      ),
    );
  }
}
