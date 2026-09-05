// Renders every screen at the design's 390x844 and fails on any layout
// exception (RenderFlex overflow included). This is how overflows get caught
// before they reach a device — release builds report nothing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fedayns_rent_car/data/fleet.dart';
import 'package:fedayns_rent_car/state/app_state.dart';
import 'package:fedayns_rent_car/theme.dart';
import 'package:fedayns_rent_car/screens/account/my_documents.dart';
import 'package:fedayns_rent_car/screens/account/contact_us.dart';
import 'package:fedayns_rent_car/screens/account/notification_settings.dart';
import 'package:fedayns_rent_car/screens/account/payment_methods.dart';
import 'package:fedayns_rent_car/screens/account/personal_info.dart';
import 'package:fedayns_rent_car/screens/booking/book_confirm.dart';
import 'package:fedayns_rent_car/screens/booking/book_dates.dart';
import 'package:fedayns_rent_car/screens/booking/book_payment.dart';
import 'package:fedayns_rent_car/screens/booking/book_review.dart';
import 'package:fedayns_rent_car/screens/booking_details.dart';
import 'package:fedayns_rent_car/screens/car_detail.dart';
import 'package:fedayns_rent_car/screens/forgot_password.dart';
import 'package:fedayns_rent_car/screens/login.dart';
import 'package:fedayns_rent_car/screens/main_shell.dart';
import 'package:fedayns_rent_car/screens/register.dart';
import 'package:fedayns_rent_car/screens/success.dart';
import 'package:fedayns_rent_car/screens/verify_cin.dart';
import 'package:fedayns_rent_car/screens/verify_license.dart';
import 'package:fedayns_rent_car/screens/welcome.dart';

import 'helpers.dart';

Widget _wrap(AppState state, Widget home) => AppScope(
      state: state,
      child: MaterialApp(theme: buildAppTheme(Brightness.light), home: home),
    );

void main() {
  setUpAll(loadAppFonts);

  final cases = <String, Widget Function()>{
    'Welcome': () => const WelcomeScreen(),
    'Login': () => const LoginScreen(),
    'Register': () => const RegisterScreen(),
    'ForgotPassword': () => const ForgotPasswordScreen(),
    'VerifyCin': () => const VerifyCinScreen(),
    'VerifyLicense': () => const VerifyLicenseScreen(),
    'Success': () => const SuccessScreen(),
    'Home': () => const MainShell(),
    'Rentals': () => const MainShell(initialTab: 1),
    'Saved': () => const MainShell(initialTab: 2),
    'Account': () => const MainShell(initialTab: 3),
    'CarDetail': () => CarDetailScreen(car: carById('c_duster')),
    'BookDates': () => const BookDatesScreen(),
    'BookReview': () => const BookReviewScreen(),
    'BookPayment': () => const BookPaymentScreen(),
    'BookConfirm': () => const BookConfirmScreen(),
    'BookingDetails': () => BookingDetailsScreen(booking: reservationDeTest()),
    'PersonalInfo': () => const PersonalInfoScreen(),
    'MyDocuments': () => const MyDocumentsScreen(),
    'PaymentMethods': () => const PaymentMethodsScreen(),
    'NotificationSettings': () => const NotificationSettingsScreen(),
    'ContactUs': () => const ContactUsScreen(),
  };

  // 390x844 is the design's mock. 360x800 is the far more common Android
  // size — and the one the app was actually reported on, where the extra 30px
  // of width the mock assumes is simply not there.
  const viewports = {'390x844': Size(390, 844), '360x800': Size(360, 800)};

  viewports.forEach((label, size) {
    cases.forEach((name, build) {
      testWidgets('$name lays out at $label', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // Un brouillon sans dates est légitime (l'utilisateur n'a pas encore
        // choisi), mais les écrans de récapitulatif ne sont atteignables
        // qu'une fois la période fixée — on la fixe donc ici.
        final state = AppState()..startBooking(carById('c_duster'));
        state.draft
          ..pickDate = DateTime(2030, 6, 20)
          ..retDate = DateTime(2030, 6, 24);
        await tester.pumpWidget(_wrap(state, build()));
        await tester.pump(const Duration(milliseconds: 400));

        expect(tester.takeException(), isNull, reason: '$name threw during layout at $label');
      });
    });
  });
}
