// Single app-wide store. The prototype held everything in one component's
// setState; this keeps the same shape as one ChangeNotifier exposed via
// InheritedNotifier so screens can read/mutate without a DI package.

import 'package:flutter/material.dart';

import '../data/db/account.dart';
import '../data/db/auth_repository.dart';
import '../data/db/settings_store.dart';
import '../data/fleet.dart';
import '../data/models.dart';
import '../data/notification_prefs.dart';

class AppState extends ChangeNotifier {
  AppState({AuthRepository? auth, SettingsStore? settings})
      : _auth = auth,
        _settings = settings {
    if (settings != null) _loadNotificationPrefs(settings);
  }

  // ── Session ──
  final AuthRepository? _auth;

  /// The account store. Null in previews and pure-logic tests, where the
  /// screens fall back to the demo fixtures.
  AuthRepository? get auth => _auth;

  Account? _account;

  /// The signed-in account, once registration or sign-in has happened.
  Account? get account => _account;

  bool get isSignedIn => _account != null;

  void signedInAs(Account account) {
    _account = account;
    piName = account.fullName;
    piEmail = account.email;
    piPhone = account.phone;
    notifyListeners();
  }

  /// Name shown in greetings — the account's first name once signed in, and
  /// the fixture otherwise.
  String get displayFirstName => _account?.firstName ?? kUserFirstName;

  // ── Profile picture ──
  /// Set from Compte by tapping the avatar. Session-only, like the document
  /// photos — the file lives wherever the picker put it.
  CapturedPhoto? profilePhoto;

  void setProfilePhoto(CapturedPhoto photo) {
    profilePhoto = photo;
    notifyListeners();
  }

  void clearProfilePhoto() {
    profilePhoto = null;
    notifyListeners();
  }

  // ── Notification preferences ──
  final SettingsStore? _settings;

  NotificationPrefs notifications = const NotificationPrefs();

  /// Read off the main path: startup must not wait on a disk read, so the
  /// screen shows defaults for the frame or two before this lands.
  Future<void> _loadNotificationPrefs(SettingsStore store) async {
    final stored = await store.readAll();
    if (stored.isEmpty) return;
    notifications = NotificationPrefs.fromMap(stored);
    notifyListeners();
  }

  /// Applies [next] immediately and persists it in the background — the switch
  /// must not wait on the write to animate.
  void setNotificationPrefs(NotificationPrefs next) {
    notifications = next;
    notifyListeners();
    _settings?.writeAll(next.toMap());
  }

  // ── Appearance ──
  /// Drives MaterialApp.themeMode. Its own listenable so toggling a favourite
  /// does not rebuild MaterialApp and everything beneath it.
  final ValueNotifier<ThemeMode> themeModeListenable = ValueNotifier(ThemeMode.light);

  ThemeMode get themeMode => themeModeListenable.value;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  @override
  void dispose() {
    themeModeListenable.dispose();
    super.dispose();
  }

  /// Resets session-scoped state. Appearance is a device preference and
  /// deliberately survives.
  void logOut() {
    _account = null;
    cinUploaded = false;
    licenseUploaded = false;
    cinPhoto = null;
    licensePhoto = null;
    profilePhoto = null;
    favs
      ..clear()
      ..addAll({'c_golf', 'c_duster', 'c_merc'});
    chip = 'All';
    sort = SortMode.recommended;
    cancelledBookings.clear();
    piName = kUserName;
    piPhone = kUserPhone;
    piEmail = kUserEmail;
    draft = BookingDraft();
    notifyListeners();
  }

  void setDarkMode(bool on) {
    themeModeListenable.value = on ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // ── Prototype toggles (were design-tool props) ──
  /// The outcome review *would* return once documents exist. Flipping this to
  /// [VerifyState.pending] or [VerifyState.rejected] exercises those branches;
  /// it can never make an account look verified while documents are missing.
  VerifyState reviewOutcome = VerifyState.verified;
  bool rentalsEmpty = false;
  bool savedEmpty = false;
  bool scanFailsFirstAttempt = false;
  bool paymentDeclinesFirstAttempt = false;

  // ── Document verification ──
  /// Set once the user has actually supplied each document. Skipping the step
  /// leaves these false, which is what locks renting.
  bool cinUploaded = false;
  bool licenseUploaded = false;

  /// What the user actually supplied, so the document screens can show it back
  /// to them instead of a generic placeholder.
  CapturedPhoto? cinPhoto;
  CapturedPhoto? licensePhoto;

  bool get documentsComplete => cinUploaded && licenseUploaded;

  void markCinUploaded({CapturedPhoto? photo}) {
    cinUploaded = true;
    if (photo != null) cinPhoto = photo;
    notifyListeners();
  }

  void markLicenseUploaded({CapturedPhoto? photo}) {
    licenseUploaded = true;
    if (photo != null) licensePhoto = photo;
    notifyListeners();
  }

  void clearCin() {
    cinUploaded = false;
    cinPhoto = null;
    notifyListeners();
  }

  void clearLicense() {
    licenseUploaded = false;
    licensePhoto = null;
    notifyListeners();
  }

  /// Per-document status. A document that was never supplied is
  /// [VerifyState.missing] — it cannot inherit an approval it never went
  /// through, which is what used to make an empty account read "Vérifié".
  VerifyState get cinStatus => cinUploaded ? reviewOutcome : VerifyState.missing;
  VerifyState get licenseStatus => licenseUploaded ? reviewOutcome : VerifyState.missing;

  /// The account's overall standing: never better than its weakest document.
  VerifyState get verifyState => documentsComplete ? reviewOutcome : VerifyState.missing;

  /// What is still outstanding, for the reminder copy.
  String get missingDocumentsLabel {
    if (documentsComplete) return '';
    if (!cinUploaded && !licenseUploaded) return 'votre CIN et votre permis de conduire';
    return cinUploaded ? 'votre permis de conduire' : 'votre CIN';
  }

  /// Renting requires both documents *and* an approved review. Skipping the
  /// step is allowed, but it leaves the account unable to book.
  bool get canRent => verifyState == VerifyState.verified;

  /// Whether the account has passed review — both documents in, both approved.
  bool get isVerified => verifyState == VerifyState.verified;

  // ── Favourites ──
  final Set<String> favs = {'c_golf', 'c_duster', 'c_merc'};

  bool isFav(String id) => favs.contains(id);

  void toggleFav(String id) {
    favs.contains(id) ? favs.remove(id) : favs.add(id);
    notifyListeners();
  }

  List<Car> get savedCars => savedEmpty ? const [] : kCars.where((c) => favs.contains(c.id)).toList();

  // ── Home tab filter ──
  String chip = 'All';
  SortMode sort = SortMode.recommended;

  void setChip(String c) {
    chip = c;
    notifyListeners();
  }

  void setSort(SortMode s) {
    sort = s;
    notifyListeners();
  }

  /// Cars for the current chip, in the current sort order.
  List<Car> get visibleCars {
    final list = chip == 'All'
        ? List<Car>.from(kCars)
        : kCars.where((c) => c.filters.contains(chip)).toList();

    int byRating(Car a, Car b) => double.parse(b.rating).compareTo(double.parse(a.rating));
    // "Newest" ranks on the vehicle's age in the spec sheet; anything without
    // a spec sorts last rather than disappearing.
    int age(Car c) => kSpecs[c.id]?.years ?? 99;

    switch (sort) {
      case SortMode.recommended:
        break;
      case SortMode.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortMode.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortMode.rating:
        list.sort(byRating);
      case SortMode.popular:
        list.sort((a, b) => b.reviews.compareTo(a.reviews));
      case SortMode.newest:
        list.sort((a, b) {
          final d = age(a).compareTo(age(b));
          return d != 0 ? d : byRating(a, b);
        });
    }
    return list;
  }

  // ── Saved cards ── (fixtures; last-4 digits are invented)
  final List<SavedCard> cards = [
    const SavedCard(id: 'k1', brand: 'VISA', last: '3456', exp: '08 / 30', isDefault: true),
    const SavedCard(id: 'k2', brand: 'MC', last: '8821', exp: '11 / 27', isDefault: false),
  ];

  void removeCard(String id) {
    cards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ── Cancelled bookings ──
  /// Refs the user has cancelled. The fixture lists are const, so cancellation
  /// is recorded here and the rentals list filters against it.
  final Set<String> cancelledBookings = {};

  bool isCancelled(String ref) => cancelledBookings.contains(ref);

  void cancelBooking(String ref) {
    if (cancelledBookings.add(ref)) notifyListeners();
  }

  // ── Reviews left on past rentals (ref -> stars) ──
  final Map<String, int> reviews = {'RC2650': 5};

  void submitReview(String ref, int stars) {
    reviews[ref] = stars == 0 ? 5 : stars;
    notifyListeners();
  }

  // ── Profile ──
  String piName = kUserName;
  String piPhone = kUserPhone;
  String piEmail = kUserEmail;

  void savePersonalInfo({required String name, required String phone, required String email}) {
    piName = name;
    piPhone = phone;
    piEmail = email;
    notifyListeners();
  }

  // ── Booking draft ──
  BookingDraft draft = BookingDraft();

  void startBooking(Car car) {
    draft = BookingDraft(car: car);
    notifyListeners();
  }
}

/// Sort orders offered by the Home filter sheet.
enum SortMode {
  recommended,
  priceAsc,
  priceDesc,
  rating,
  popular,
  newest;

  String get label => switch (this) {
        SortMode.recommended => 'Recommandé',
        SortMode.priceAsc => 'Prix croissant',
        SortMode.priceDesc => 'Prix décroissant',
        SortMode.rating => 'Mieux notées',
        SortMode.popular => 'Les plus populaires',
        SortMode.newest => 'Les plus récentes',
      };

  String get hint => switch (this) {
        SortMode.recommended => 'Notre sélection',
        SortMode.priceAsc => 'Du moins cher au plus cher',
        SortMode.priceDesc => 'Du plus cher au moins cher',
        SortMode.rating => 'Meilleures notes en premier',
        SortMode.popular => "Le plus d'avis en premier",
        SortMode.newest => 'Mise en circulation la plus récente',
      };
}

/// The in-progress booking. Mirrors the bk* keys from the prototype state.
class BookingDraft {
  BookingDraft({Car? car}) : car = car ?? carById('c_duster');

  Car car;
  int? pickDay = 20;
  int? retDay = 24;
  String pickTime = '10:00';
  String retTime = '10:00';
  String pickLoc = kLocations[0];
  bool retSameAsPick = true;
  String retLoc = kLocations[1];

  bool extraDriver = false;
  bool extraChildSeat = false;
  bool promoApplied = false;

  // Additional-driver sub-form (required when extraDriver is on).
  String adName = '';
  String adCin = '';
  String adLicense = '';
  String adExpiry = '';
  bool adTouched = false;

  bool get adComplete =>
      adName.trim().isNotEmpty && adCin.trim().isNotEmpty && adLicense.trim().isNotEmpty && adExpiry.trim().isNotEmpty;

  /// "Proceed to payment" is gated on the sub-form when the option is checked.
  bool get canProceed => !extraDriver || adComplete;

  int get days {
    final p = pickDay, r = retDay;
    if (p == null || r == null) return 0;
    return (r - p).clamp(0, 365);
  }

  bool get hasDateConflict {
    final p = pickDay, r = retDay;
    if (p == null || r == null) return false;
    return kBookedDays.any((d) => d >= p && d < r);
  }

  int get base => days * car.price;
  int get extras => extraChildSeat ? 40 : 0;
  static const int serviceFee = 50;
  int get discount => promoApplied ? (base * 0.2).round() : 0;
  int get total => base + extras + serviceFee - discount;

  String get effectiveRetLoc => retSameAsPick ? pickLoc : retLoc;
}

/// Inherited access: `AppScope.of(context)`.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing above this widget');
    return scope!.notifier!;
  }

  /// Read without subscribing — for event handlers.
  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing above this widget');
    return scope!.notifier!;
  }
}
